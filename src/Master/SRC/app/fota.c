#include "app.h"
#include "check_meter_misc.h"
#include "intrinsics.h"
#include "modem.h"
#include "osal.h"
#include "osal_Timer.h"
#include <stdio.h>
#include <string.h>
#include <stdarg.h>
#include <msp430.h>
#include "common_header.h"
#include "fota.h"
#include "uart.h"
#include "flashDriver.h"
#include "meter.h"

#define CONNECT_SERVER 1
#define SEND_FW_VER 2
#define SOCK_CLOSE 3

#define MASS_ERASE 1
#define SECT_ERASE 2

#define SEND_READY 1
#define SEND_ACK 2
#define SEND_REPEAT 3
#define SEND_FINISH 4

#define FOTA_DELAY 10

FotaStatus_t Fota;

char rxBuf[RX_MAX_LEN];
int rxLen;

static int checkFlashBusy()
{
	while (1) {
		if ((FCTL3 & BUSY) == 0) {
			return 1;
		}
	}
}

static void eraseCode(unsigned long addr, int option)
{
	if (checkFlashBusy()) {
		FCTL3 = FWKEY;
		if (option == SECT_ERASE) {
			FCTL1 = FWKEY + ERASE; // Set Erase bit
		} else if (option == MASS_ERASE) {
			FCTL1 = FWKEY + MERAS; // Set Erase bit
		}

		if (checkFlashBusy()) {
			__data20_write_char(addr, 0);
		}

		asm(" bis.w #0,R3 "); // Flash contents: 0x03 0xd3
		asm(" bis.w #0,R3 "); // Flash contents: 0x03 0xd3
		asm(" bis.w #0,R3 "); // Flash contents: 0x03 0xd3

		if (checkFlashBusy()) {
			FCTL1 = FWKEY; // Set Erase bit
			FCTL3 = FWKEY + LOCK;
		}
	}
	checkFlashBusy();
}

static void writeCode(unsigned long addr, volatile unsigned char data[], int size)
{
	if (checkFlashBusy()) {
		FCTL3 = FWKEY; // clear lock
		FCTL1 = FWKEY + WRT; // Set Write bit

		for (int i = 0; i < size; i++) {
			if (checkFlashBusy()) {
				__data20_write_char(addr + i, data[i]);
			}
		}

		if (checkFlashBusy()) {
			FCTL1 = FWKEY; // Set Erase bit
			FCTL3 = FWKEY + LOCK;
		}
	}

	checkFlashBusy();
}

static void fotaPrint(char *str)
{
#ifdef FOTA_DEBUG
	while (*str != 0) {
		while (!(UCTXIFG & UCA1IFG))
			; //Ensure that transmit interrupt flag is set
		UCA1TXBUF = *str++; //Load UCA0TXBUF with current string element
	}
#endif
}

static void modemRxClear()
{
	for (int i = 0; i < sizeof(rxBuf); i++) {
		rxBuf[i] = 0;
	}
	rxLen = 0;
}

static void modemSend(char *str)
{
	modemRxClear();
	while (*str != 0) {
		while (!(UCTXIFG & UCA2IFG))
			; //Ensure that transmit interrupt flag is set
		UCA2TXBUF = *str++; //Load UCA0TXBUF with current string element
	}
}

static void fotaModemPrint(char *p)
{
#ifdef FOTA_DEBUG
	fotaPrint("[RX] ");
	for (int i = 0; i < strlen(p); i++) {
		char ch = *(p + i);
		if (ch == '\r' || ch == '\n') {
			fotaPrint(".");
		} else {
			fotaPrint(&ch);
		}
	}
	fotaPrint("\n\r");
#endif
}

static void fotaSend(char *str)
{
	modemSend(str);
	fotaPrint("[TX] ");
	fotaPrint(str);
}

int testatoi(char *cdata)
{
	int data = 0;

	while (*cdata) {
		if (*cdata >= '0' && *cdata <= '9') {
			if (data != 0) {
				int mulData = data;
				for (int i = 0; i < 9; i++) {
					data += mulData;
				}
			}
			data = data + *cdata;
			data = data - '0';
		} else {
			return data;
		}

		cdata++;
	}

	return data;
}

static void recvModem(char *sendMsg, char *recvMsg, int repeat)
{
	fotaSend(sendMsg);
	while (1) {
		volatile int len = 0;
		volatile int count = 0;
		for (; count < 6000; count++) {
			MISC_delayMs(FOTA_DELAY);
			if (len != rxLen) {
				len = rxLen;
			} else if (len > 1) {
				break;
			}
		}

#ifdef FOTA_DEBUG
		fotaModemPrint(rxBuf);
#endif

		if (strstr(rxBuf, recvMsg)) {
			return;
		} else {
			modemRxClear();
			MISC_delayMs(3000);
			if (repeat) {
				fotaSend(sendMsg);
			}
		}
	}
}

static void fotaRecv()
{
#define AT_MODEM_RX "+NSONMI:"
#define AT_DFOTA_PORT "18099,"

	while (1) {
		volatile int len = 0;
		volatile int count = 0;
		for (; count < 6000; count++) {
			MISC_delayMs(FOTA_DELAY);
			if (len != rxLen) {
				len = rxLen;
			} else if (len > 1) {
				break;
			}
		}

		if (len > 1) {
			char *p = NULL;

			if ((p = strstr(rxBuf, AT_MODEM_RX))) {
				fotaModemPrint(rxBuf);
				fotaSend("AT+NSORF=1,1024\n\r");
			} else if ((p = strstr(rxBuf, AT_DFOTA_PORT))) {
				// data len
				p = strstr(p, ",") + 1;
				int payloadLen = testatoi(p);

				// payload
				p = strstr(p, ",") + 1;
				volatile unsigned char rxData[517];
				for (int i = 0; i < payloadLen; i++) {
					rxData[i] = ascii2BCD(*(p + 0), *(p + 1));
					p += 2;
				}

				unsigned char checksum =
					std_checksum((unsigned char *)rxData, payloadLen - 1);

				if (rxData[payloadLen - 1] == checksum) {
					volatile unsigned long address = 0;
					for (int i = 1; i < 4; i++) {
						if (address) {
							unsigned long mulData = address;
							for (int j = 0; j < 255; j++) {
								address += mulData;
							}
						}
						address |= rxData[i];
					}

					if (rxData[0] == 0xB1) {
						eraseCode(address, SECT_ERASE);
						writeCode(address, &rxData[4], payloadLen - 5);
						send(SEND_ACK);
					} else if (rxData[0] == 0xB3) {
						send(SEND_FINISH);
						fotaPrint("FOTA Finish\n\r");
						__disable_interrupt();
						eraseCode(address, SECT_ERASE);
						writeCode(address, &rxData[4], payloadLen - 5);
						MISC_delayMs(5000);
						PMMCTL0 = (PMMPW + PMMSWPOR);
					}
				} else {
					fotaPrint("checksum fail\n\r");
					send(SEND_REPEAT);
				}
			} else if ((p = strstr(rxBuf, "+NSOCLI:"))) {
				recvModem("at+cgatt=0\n\r", "+NPSMR:1", 0);
				fotaPrint("socket closed sleep\n\r");
				break;
			} else {
				fotaModemPrint(rxBuf);
				modemRxClear();
			}
		} else {
			send(SEND_REPEAT);
		}
	}

	// LDO work
	P2SEL &= ~BM(0);
	P2DIR |= BM(0);
	P2OUT &= ~BM(0); // make low

	P2OUT &= ~0x20;

	for (int i = 0; i < 5; i++) {
		// minute
		MISC_delayMs(60000);
	}
}

static void send(int option)
{
	if (option == SEND_READY) {
		fotaSend("AT+NSOSD=1,2,C1C1\n\r");
	} else if (option == SEND_ACK) {
		fotaSend("AT+NSOSD=1,2,C2C2\n\r");
	} else if (option == SEND_REPEAT) {
		fotaSend("AT+NSOSD=1,2,C3C3\n\r");
	} else if (option == SEND_FINISH) {
		fotaSend("AT+NSOSD=1,2,C4C4\n\r");
	}
}

void startFota()
{
	Fota.Status = 1;

	while (1) {
		char *str = "fota start, send Ready\n\r";
		fotaPrint(str);
		char *natspeed = "at+natspeed=115200,30,0,0,1\n\r";
		recvModem(natspeed, "OK", 0);
		MODEM_changeBaudrate(UART_BAUDRATE_115200);
		send(SEND_READY);

		fotaRecv();

		readyFota();
	}
}

void modemWakeup()
{
	// LDO work
	P2SEL &= ~BM(0);
	P2DIR |= BM(0);
	P2OUT |= BM(0); // make high

	MISC_delayMs(100);
}

void readyFota()
{
	Fota.Status = 1;

	modemWakeup();
	for (int i = 0; i < 100; i++) {
		MISC_delayMs(100);
	}

	recvModem("at+cfun=1\n\r", "OK", 1);
	recvModem("at+cgatt=1\n\r", "OK", 1);
	recvModem("at+cereg=5\n\r", "OK", 1);
	recvModem("at+cereg?\n\r", "+CEREG:5,1", 1);
	recvModem("AT+NSOCR=STREAM,6,0,1\n\r", "OK", 0);
	recvModem("AT+NSOCO=1,1.233.95.235,18099\n\r", "+NSONMI:1,4", 0);
	recvModem("AT+NSORF=1,4\n\r", "OK", 0);
	recvModem("AT+NSOSD=1,2,C2C2,0x100,101\n\r", "+NSONMI:1,5", 0);
	recvModem("AT+NSORF=1,5\n\r", "OK", 0);
}
