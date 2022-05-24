#include "app.h"
#include "check_meter_misc.h"
#include "intrinsics.h"
#include "modem.h"
#include "nbiotModem.h"
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

#define FOTA_DELAY 20
#define FOTA_5SEC 250
#define FOTA_10SEC 500
#define FOTA_60SEC 3000

FotaStatus_t Fota = { 0 };
static char socket[3] = { 0 };
static char fotaPort[6] = { 0 };
static char initialMsgSize[4] = { 0 };

char *rxBuf = NULL;
int rxLen = 0;

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
			if (data[i] == 0xFF) {
				continue;
			}

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
	for (int i = 0; i < RX_MAX_LEN; i++) {
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

static void fotaModemPrint(char *p, int len)
{
#ifdef FOTA_DEBUG
	fotaPrint("[RX] ");
	for (int i = 0; i < len; i++) {
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
	fotaPrint(str);
}

static int fotaatoi(char *cdata)
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

static int waitRx(volatile int *len)
{
	MISC_delayMs(FOTA_DELAY);
	if (*len != rxLen) {
		*len = rxLen;
	} else if (*len > 1) {
		return 1;
	}

	return 0;
}

static int recvModem(char *sendMsg, char *recvMsg, int t)
{
	fotaSend(sendMsg);
	volatile int len = 0;
	while (t--) {
		if (waitRx(&len)) {
			if (strstr(rxBuf, recvMsg)) {
				fotaModemPrint(rxBuf, rxLen);
				modemRxClear();
				return 0;
			}
		}
	}

	modemRxClear();
	MISC_delayMs(1000);
	return -1;
}

static void fotaRecv()
{
	while (1) {
		volatile int len = 0;
		volatile int count = 0;
		for (; count < 6000; count++) {
			if (waitRx(&len)) {
				break;
			}
		}

		if (len > 1) {
			char *p = NULL;

#define AT_MODEM_RX "+NSONMI:"
			if ((p = strstr(rxBuf, AT_MODEM_RX))) {
				fotaModemPrint(rxBuf, rxLen);
				fotaSend("AT+NSORF=1,1024\n\r");
			} else if ((p = strstr(rxBuf, fotaPort))) {
				// data len
				p = strstr(p, ",");
				p = strstr(p, ",") + 1;
				int payloadLen = fotaatoi(p);

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
					// address parsing
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
						// last update
						send(SEND_FINISH);
						fotaPrint("FOTA Finish\n\r");
						__disable_interrupt();
						eraseCode(address, SECT_ERASE);
						writeCode(address, &rxData[4], payloadLen - 5);
						MISC_delayMs(5000);
						reboot();
					}
				} else {
					fotaPrint("checksum fail\n\r");
					send(SEND_REPEAT);
				}
			} else if ((p = strstr(rxBuf, "+NSOCLI:"))) {
				fotaModemPrint(rxBuf, rxLen);
				recvModem("at+cgatt=0\n\r", "+NPSMR:1", FOTA_10SEC);
				fotaPrint("socket closed");
				break;
			} else {
				modemRxClear();
			}
		} else {
			recvModem("at+cgatt=0\n\r", "+NPSMR:1", FOTA_10SEC);
			fotaPrint("server no response");
			fotaSend("at+nsocl=");
			fotaSend(socket);
			fotaSend("\n\r");
			fotaPrint("socket closed");
			break;
		}
	}

	fotaPrint("sleep\n\r");
}

static void reboot()
{
	PMMCTL0 = (PMMPW + PMMSWPOR);
}

static int send(int option)
{
	int ret = 0;
	if (option == SEND_READY) {
		ret = txData("2,C1C1\n\r");
	} else if (option == SEND_ACK) {
		ret = txData("2,C2C2\n\r");
	} else if (option == SEND_REPEAT) {
		ret = txData("2,C3C3\n\r");
	} else if (option == SEND_FINISH) {
		ret = txData("2,C4C4\n\r");
	}

	return ret;
}

void startFota()
{
	Fota.Status = 1;
	fota_uart();

	rxBuf = (char *)malloc(RX_MAX_LEN);
	if (rxBuf == NULL) {
		fotaPrint("malloc(Fota rxBuf) failed\n\r");
		reboot();
	}
	snprintf(socket, sizeof(socket), "%1d", modemCtx.socket);
	snprintf(fotaPort, sizeof(fotaPort), "%d", Fota.Info.port);
	snprintf(initialMsgSize, sizeof(initialMsgSize), "%d,", FOTA_REQMSG_SIZE);

	fotaPrint("fota start, send Ready\n\r");
	if (recvModem("at+natspeed=57600,30,0,0,1\n\r", "OK", FOTA_10SEC)) {
		reboot();
	}

	MODEM_changeBaudrate(UART_BAUDRATE_57600);
	MISC_delayMs(100);

	if (send(SEND_READY) == -1) {
		reboot();
	}

	while (1) {
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

static int txData(char *msg)
{
	fotaSend("AT+NSOSD=");
	fotaSend(socket);
	fotaSend(",");
	return recvModem(msg, "OK", FOTA_10SEC);
}

static int repeatCmd(char *sendMsg, char *recvMsg, int t, int retry)
{
	for (int i = 0; i < retry; i++) {
		if (recvModem(sendMsg, recvMsg, t) == 0) {
			return 0;
		}
	}

	recvModem("at+cgatt=0\n\r", "+NPSMR:1", FOTA_10SEC);
	fotaPrint("ready fail sleep\n\r");
	return -1;
}

static void readyFota()
{
RETRY:
	// LDO work
	P2SEL &= ~BM(0);
	P2DIR |= BM(0);
	P2OUT &= ~BM(0); // make low

	P2OUT &= ~0x20;
	for (int i = 0; i < 5; i++) {
		// minute
		// MISC_delayMs(60000);
		MISC_delayMs(1000);
	}

	modemWakeup();
	MISC_delayMs(10000);

	if (repeatCmd("at+cfun=1\n\r", "OK", FOTA_5SEC, 3)) {
		goto RETRY;
	}
	if (repeatCmd("at+cfun=1\n\r", "OK", FOTA_5SEC, 3)) {
		goto RETRY;
	}
	if (repeatCmd("at+cgatt=1\n\r", "OK", FOTA_5SEC, 3)) {
		goto RETRY;
	}
	if (repeatCmd("at+cereg=5\n\r", "OK", FOTA_5SEC, 3)) {
		goto RETRY;
	}
	if (repeatCmd("at+cereg?\n\r", "+CEREG:5,1", FOTA_10SEC, 18)) {
		goto RETRY;
	}

	if (recvModem("AT+NSOCR=STREAM,6,0,1\n\r", "OK", FOTA_5SEC)) {
		goto RETRY;
	}
	// connect fota server
	fotaSend("AT+NSOCO=");
	fotaSend(socket);
	fotaSend(",");
	fotaSend(Fota.Info.ip);
	fotaSend(",");
	fotaSend(fotaPort);
	if (recvModem("\n\r", "+NSONMI", FOTA_60SEC)) {
		goto RETRY;
	}

	fotaSend("AT+NSORF=");
	fotaSend(socket);
	fotaSend(",");
	if (recvModem("4\n\r", "OK", FOTA_10SEC)) {
		goto RETRY;
	}

	// fota initial msg send
	fotaSend("AT+NSOSD=");
	fotaSend(socket);
	fotaSend(",");
	fotaSend(initialMsgSize);
	fotaSend(Fota.reqMsg);
	if (recvModem("\n\r", "+NSONMI", FOTA_60SEC)) {
		goto RETRY;
	}

	fotaSend("AT+NSORF=");
	fotaSend(socket);
	fotaSend(",");
	if (recvModem("5\n\r", "OK", FOTA_10SEC)) {
		goto RETRY;
	}

	if (send(SEND_READY) == -1) {
		goto RETRY;
	}
}
