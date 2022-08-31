#include "device.h"
#include "flashDriver.h"
#include "intrinsics.h"
#include "stdio.h"
#include "string.h"
#include <msp430.h>
#include <ctype.h>
#include <time.h>

#include "common_header.h"
#include "uart.h"
#include "check_meter_misc.h"
#include "Task_Mgr.h"
#include "meter.h"
#include "osal.h"
#include "osal_Timer.h"
#include "app.h"
#include "rtcAlarm.h"
#include "lcdDriver.h"
#include "assert.h"

#include "modem.h"
#include "uuid.h"
#include "message.h"
#include "nbiotModem.h"
#include "fota.h"
#include "nbiotResponse.h"

// AT command deregister delay
#define DEREGISTER_DELAY 5000

// FOTA timeout
#define FOTA_TIMEOUT 60000
#define FOTA_RETRY 0

// QA report timeout
#define AT_CMD_LGU_QA_TIMEOUT 1000

// AT command default timeout/retry
#define AT_CMD_DEFAULT_TIMEOUT 3000
#define AT_CMD_DEFAULT_RETRY 5

// QLWULDATA timeout/retry
#define AT_CMD_DATA_SEND_TIMEOUT 30000
#define AT_CMD_DATA_SEND_RETRY 1

// NPSMR timeout/retry
#define AT_CMD_CHECK_PSM_TIMEOUT 5000
#define AT_CMD_CHECK_PSM_RETRY 4

// Attach, Detach, No ack UDP timeout/retry
#define AT_CMD_ATTACH_TIMEOUT 10000
#define AT_CMD_ATTACH_RETRY 14

#define DETACH_DELAY_TIME 5000

#define AT_CMD_COMM_TIMEOUT 5000
#define AT_CMD_COMM_DETACH_RETRY 0

// Modem Reset timeout/retry
#define AT_CMD_RESET_TIMEOUT 15000
#define AT_CMD_RESET_RETRY 0

// LWM2M data transfer timeout/retry
#define AT_CMD_LWM2M_TIMEOUT 90000
#define AT_CMD_LWM2M_DL_WAIT 60000
#define AT_CMD_LWM2M_RETRY 0

// MODEM remote open timeout/retry
#define MODEM_CHECK_ALIVE_TIMEOUT 5000
#define MODEM_CHECK_ALIVE_RETRY 11

#define MODEM_ENTER_PSM_TIMEOUT 30000
#define MODEM_FW_DOWN_REQ_TIMEOUT 40000
#define MODEM_FW_DOWNLOAD_TIMEOUT 300000
#define MODEM_FW_UPGRADE_TIMEOUT 150000
#define MODEM_FOTA_COMPLETE_WAIT 60000

#define MODEM_EVENT_INTERVAL 1000
#define MODEM_BOOTUP_INTERVAL 6000

#define END_STEP_FLOW_INDEX 0xFF
#define ENTER_PSM_FLOW_INDEX 0xFE

extern Config_t conf;
extern Modem_t modem;

static uchar raw_data[LEN_MAX_NBIOT_DATA] = { 0 };
static char ul_data[LEN_MAX_AT_DATA + 1] = { 0 };
static uint32 startEventTimeMsec = 0;

typedef struct {
	uint8 idle;
	uint8 bip;
	uint8 init;
	uint8 attach;
	uint8 updateQa;
	uint8 transfer;
	uint8 certify;
	uint8 fota;
	uint8 dfota;
	uint8 detach;
	uint8 retry;
} StepFlowIndex_t;
static StepFlowIndex_t StepFlowIndex = { 0 };

// NB-IoT Modem AT command list
static const AtCmd_t AtCmdSwReset = { AT_CMD_IDX_SW_RESET, "AT+NRB" };
static const AtCmd_t AtCmdDetachNw = { AT_CMD_IDX_DETACH_NW, "AT+CGATT" };
static const AtCmd_t AtCmdSetRfCtrl = { AT_CMD_IDX_SET_RF_CTRL, "AT+CFUN" };
static const AtCmd_t AtCmdSocketCreate = { AT_CMD_IDX_SOCKET_CREATE, "AT+NSOCR" };
static const AtCmd_t AtCmdSocketClose = { AT_CMD_IDX_SOCKET_CLOSE, "AT+NSOCL" };

static const AtCmd_t AtCmdSetFOTA = { AT_CMD_IDX_SET_FOTA, "AT+QLWFOTAIND" };

/**
 * @brief Get the End Point Name(= CSE ID) object
 *
 * @param service_code  LG U+ Platform service code
 * @param ctnStr        USIM CTN (format is string)
 * @param iccidStr      USIM ICCID (format is string)
 * @return char*        End point string (It is allocated on the heap. so, have to free)
 */
static char *getEndPointName(const char *serviceCode, const char *ctnStr, const char *iccidStr)
{
#define LEN_SHORT_UUID 10
#define LEN_UUID_PARAM (LEN_MODEM_CTN + LEN_MODEM_ICCID)

	char uuidParam[LEN_UUID_PARAM + 1];
	char uuid[LEN_MODEM_UUID + 1];
	char shortUuid[LEN_SHORT_UUID + 1];

	// Make parameter for making Endpoint Name
	snprintf(uuidParam, LEN_UUID_PARAM + 1, "%s%s", ctnStr, iccidStr);

	// Make UUID
	uuid_t u;
	uuid_create_md5_from_name(&u, uuidParam, LEN_UUID_PARAM);
	snprintf(uuid, LEN_MODEM_UUID + 1, "%8.8lx-%4.4x-%4.4x-%2.2x%2.2x-", u.time_low, u.time_mid,
		 u.time_hi_and_version, u.clock_seq_hi_and_reserved, u.clock_seq_low);
	for (unsigned int i = 0; i < 6; i++) {
		snprintf(uuid, LEN_MODEM_UUID + 1, "%s%2.2x", uuid, u.node[i]);
	}

	// Make Short UUID from UUID
	// UUDI의 앞 5자리 Copy
	snprintf(shortUuid, 6, "%s", &uuid[0]);
	snprintf(&shortUuid[5], 6, "%s",
		 &uuid[LEN_MODEM_UUID - 5]); // UUDI의 뒤 5자리 Copy

	// Make Endpoint Name
	memset(ul_data, 0, sizeof(ul_data));
	snprintf(ul_data, LEN_MODEM_EP_NAME + 1, "ASN_CSE-D-%s-%s", shortUuid, serviceCode);

	return ul_data;
}

/**
 * @brief Set the Modem data object for operating
 */
static void setModemData()
{
	// Check and Copy IMEI
	printf_ts("IMEI    : %s", modem.imeiStr);

	uchar imei[8];
	MODEM_copyImei(imei);
	if (memcmp(conf.imei, imei, 8) != 0) {
		memcpy(conf.imei, imei, 8);
		FLASH_saveConfigInfo(&conf);
		printf(" - changed IMEI\n");
	} else {
		printf("\n");
	}

	// Check IMSI
	printf_ts("IMSI    : %s", modem.imsiStr);
	if (modem.modemType == MODEM_TYPE_KT) {
		printf("(KT)\n");
	} else if (modem.modemType == MODEM_TYPE_UPLUS) {
		printf("(UPLUS)\n");
	} else {
		printf("(UNKNOWN)\n");
	}

	// Make CTN
	snprintf(modem.ctnStr, LEN_MODEM_CTN + 1, "0%s", &modem.imsiStr[5]);
	printf_ts("CTN     : %s\n", modem.ctnStr);
	printf_ts("ICCID   : %s\n", modem.iccidStr);

	// Make End point name (= CSE ID)
	char *epName = getEndPointName(conf.serviceCode, modem.ctnStr, modem.iccidStr);
	memcpy(modem.epName, epName, sizeof(modem.epName));

	printf_ts("Endpoint : %s\n", modem.epName);

	// Make Bootstrap paramter
	char model[TERM_MODEL_STRING_LEN + 1];
	if (SMART_WATER_METER(conf.termModel)) {
		memcpy(model, "HTM-115Q", TERM_MODEL_STRING_LEN + 1);
	} else {
		memcpy(model, "HAT-124Q", TERM_MODEL_STRING_LEN + 1);
	}

	// 3가지 형식 존재
	// 1. NL7121500001 이전 버전 (imei 앞2개, 뒤 1개 제외)
	// EX : IMEI=359689090501559 >> devSn=968909050155
	// char devSn[13];
	// memcpy(devSn, &modem.imeiStr[2], 12);
	// devSn[12] = 0; // Last char is set string end

	// 2. NL7121500001 ~ NL7121601798, NL7121705401 ~ NL7121705402 (생산년도(21) + 3번 케이스)
	// Bootstrap 상의 serial number 는 ICCID의 10자리 사용.
	// char devSn[13];
	// snprintf(devSn, 12, "21%s", &modem.iccidStr[LEN_MODEM_ICCID - 11]);

	// 3. NL7121601801 이후 (ICCID의 마지막 1자리 제외한 10자리)
	// USIM Model num 4 + Usim S/N num 6
	// EX : ICCID = 8982068086002814399 >> devSn = 8600281439
	char devSn[11];
	memcpy(devSn, &modem.iccidStr[LEN_MODEM_ICCID - 11], 10);
	devSn[10] = 0; // Last char is set string end

	snprintf(modem.bsParam, LEN_MODEM_BS_PARAM + 1, "%s,%s,%s,%s,%s", conf.serviceCode, devSn,
		 modem.ctnStr, &modem.iccidStr[LEN_MODEM_ICCID - 6], model);

	printf_ts("BS param : %s\n", modem.bsParam);
}

/**
 * @brief AT command send wrapper function
 *
 * @param timeout timeout(ms) of each AT command
 * @param retry   AT command retry count
 * @param cmd     AT command (string)
 * @param param   Parameter (string, support format)
 * @param ...     Parameter format argument
 */
static void sendAtCommand(uint32 timeout, int retry, const AtCmd_t *atCmd, char *param, ...)
{
	if (retry >= 0) {
		snprintf(modemComm.atData, LEN_MAX_AT_DATA, "%s", atCmd->cmd);

		if (param != NULL) {
			va_list arg;
			va_start(arg, param);
			int paramLen =
				vsnprintf((modemComm.atData + strlen(atCmd->cmd)),
					  (LEN_MAX_AT_DATA - strlen(atCmd->cmd)), param, arg);
			va_end(arg);
		}

		modemComm.atCmd = atCmd;
		modemComm.retry = retry;
		modemComm.timeout = timeout;

		modemCtx.status.busy = 1;
		modemCtx.status.error = 0;
		MODEM_write(modemComm.atData);

		OSAL_startEventTimer(AppTaskId, APP_EVENT_MODEM_TIMEOUT, modemComm.timeout);
	}
}

/**
 * @brief AT command send wrapper function (no wait response)
 *
 * @param delay   delay(ms) after sending each AT command
 * @param cmd     AT command (string)
 * @param param   Parameter (string, support format)
 * @param ...     Parameter format argument
 */
static void sendNoRespAtCommand(uint32 delay, const AtCmd_t *atCmd, char *param, ...)
{
	snprintf(modemComm.atData, LEN_MAX_AT_DATA, "%s", atCmd->cmd);

	if (param != NULL) {
		va_list arg;
		va_start(arg, param);
		int paramLen = vsnprintf((modemComm.atData + strlen(atCmd->cmd)),
					 (LEN_MAX_AT_DATA - strlen(atCmd->cmd)), param, arg);
		va_end(arg);
	}

	modemComm.atCmd = atCmd;
	modemComm.retry = 0;
	modemComm.timeout = 0;

	modemCtx.status.busy = 0;
	MODEM_write(modemComm.atData);

	MISC_delayMs(delay);
}

/**
 * @brief Get the Qa Report Message object
 *        Return message is allocated on the heap. so, have to free
 *
 * @param messageLen QA report message length
 * @return char*     QA report message (converted to string)
 */
static char *getQaReportMessage(int *messageLen)
{
	memset(raw_data, 0, sizeof(raw_data));
	// len 58
	int len = MODEM_qaData(raw_data);

	// Hex data를 ASCII로 변환하여 저장할 버퍼의 길이이므로
	// 본래 데이터 길이의 x2에 '\0'를 위한 +1로 정의.
	int dataLen = (len * 2) + 1;
	memset(ul_data, 0, sizeof(ul_data));

	for (unsigned int i = 0; i < len; i++) {
		snprintf(ul_data, dataLen, "%s%02X", ul_data, *(raw_data + i));
	}

	*messageLen = len;
	return ul_data;
}

/**
 * @brief Get the Error Report Message object
 *        Return message is allocated on the heap. so, have to free
 *
 * @param messageLen Error report message length
 * @return char*     Error report message (converted to stringe)
 */
static char *getErrorReportMessage(int *messageLen)
{
	memset(raw_data, 0, sizeof(raw_data));
	// len 35
	int len = MODEM_errData(raw_data, modemCtx.pfUlCnt, modemCtx.pfDlCnt, modemCtx.ulCnt,
				modemCtx.dlCnt);

	// Hex data를 ASCII로 변환하여 저장할 버퍼의 길이이므로
	// 본래 데이터 길이의 x2에 '\0'를 위한 +1로 정의.
	int dataLen = (len * 2) + 1;
	memset(ul_data, 0, sizeof(ul_data));

	for (unsigned int i = 0; i < len; i++) {
		snprintf(ul_data, dataLen, "%s%02X", ul_data, *(raw_data + i));
	}

	*messageLen = len;
	return ul_data;
}

/**
 * @brief Get the Meter Data Message object
 *        Return message is allocated on the heap. so, have to free
 *
 * @param isJoin     Flag specifying whether the message is a JOIN message or not.
 * @param messageLen Meter data report message length
 * @return char*     Meter data report message (converted to string)
 */

static char *getMeterDataMessage(BOOL isJoin, int *messageLen)
{
	memset(raw_data, 0, LEN_MAX_NBIOT_DATA);
	unsigned int len;
	if (isJoin) {
		len = MODEM_sendCurrentData(raw_data);
	} else {
		len = MODEM_sendPeriodicData(raw_data);
	}

	// Hex data를 ASCII로 변환하여 저장할 버퍼의 길이이므로
	// 본래 데이터 길이의 x2에 '\0'를 위한 +1로 정의.
	memset(ul_data, 0, sizeof(ul_data));

	for (unsigned int i = 0; i < len; i++) {
		snprintf(ul_data, LEN_MAX_AT_DATA, "%s%02X", ul_data, *(raw_data + i));
	}

	*messageLen = len;
	return ul_data;
}

/**
 * @brief IDLE step operator
 *
 * @return ModemStep_t    return next step
 */
static ModemStep_t idle()
{
	ModemStep_t nextStep =
		modemCtx.step; // step 종료 전 까지 현재 step을 next step 으로 return.
	modemCtx.errCode = MODEM_ERROR_NONE;
	modemCtx.retryCount = 0;
	modemCtx.retryStep = MODEM_STEP_UNKNOWN;

	modemCtx.proc.value = 0;
	// Check previous Modem state with enable sleep flag.
	if (modemCtx.status.psmOn) {
		nextStep = MODEM_STEP_ATTACH_NW;
	} else {
		modemCtx.proc.runInit = (conf.isModemInit) ? 0 : 1;
		nextStep = MODEM_STEP_BIP;
	}

	if (RTC_isTimeSync()) {
		Date_t now;
		RTC_read(&now);
		if (RTC_calcHourDiff(&modem.lastUpdateTime, &now) >= LG_QA_HOUR_INTERVAL) {
			modemCtx.proc.updateQa = 1;
		}
	} else {
		modemCtx.proc.updateQa = 1;
	}

	if (modemCtx.proc.runInit) {
		printf_ts("PROC : Enable Modem Init.\n");
	}
	if (modemCtx.proc.updateQa) {
		printf_ts("PROC : Enable Update QA.\n");
	}

	printf_ts("PROC : Enable FOTA.\n");
	// FOTA 수행을 위한 Flag 초기화
	modemCtx.lwm2m.fotaDownReq = 0;
	modemCtx.lwm2m.fotaUpgradeReq = 0;
	modemCtx.lwm2m.fotaFinish = 0;

	return nextStep;
}

/**
 * @brief BIP step operator (V120의 경우 BIP를 지원하지 않으므로 모뎀동작 여부만 확인.)
 *
 * @return ModemStep_t    return next step
 */
static ModemStep_t bip()
{
	ModemStep_t nextStep =
		modemCtx.step; // step 종료 전 까지 현재 step을 next step 으로 return.
	modemCtx.errCode = MODEM_ERROR_USIM_INVALID;

	if (modemCtx.stepReset) {
		StepFlowIndex.bip = 0;
	}

	switch (StepFlowIndex.bip) {
	case 0: {
		startEventTimeMsec = TIMER_getMsec();
		OSAL_setEvent(AppTaskId, APP_EVENT_MODEM_PROCESS);
		StepFlowIndex.bip++;
	} break;

	case 1: {
		if (TIMER_getMsecDiff(startEventTimeMsec) >= MODEM_BOOTUP_INTERVAL) {
			OSAL_setEvent(AppTaskId, APP_EVENT_MODEM_PROCESS);
			StepFlowIndex.bip++;
		} else {
			OSAL_startEventTimer(AppTaskId, APP_EVENT_MODEM_PROCESS,
					     MODEM_EVENT_INTERVAL);
		}
	} break;

	case 2: {
		static const AtCmd_t AtCmdCheckAlive = { AT_CMD_IDX_CHECK_ALIVE, "AT" };
		sendAtCommand(AT_CMD_DEFAULT_TIMEOUT, AT_CMD_DEFAULT_RETRY, &AtCmdCheckAlive, NULL);
		StepFlowIndex.bip++;
	} break;

	case 3: {
		static const AtCmd_t AtCmdGetIMSI = { AT_CMD_IDX_GET_IMSI, "AT+CIMI" };
		sendAtCommand(MODEM_CHECK_ALIVE_TIMEOUT, MODEM_CHECK_ALIVE_RETRY, &AtCmdGetIMSI,
			      NULL);
		StepFlowIndex.bip++;
	} break;

	case END_STEP_FLOW_INDEX:
	default: {
		uchar imsi[8];
		MODEM_copyImsi(imsi);
		if (memcmp(conf.imsi, imsi, 8) != 0) {
			memcpy(conf.imsi, imsi, 8);
			saveConfChecksum();
			printf_ts("MODEM : changed USIM\n");
		}

		nextStep = MODEM_STEP_INIT;
	} break;
	}

	return nextStep;
}

/**
 * @brief BC95G modem INIT step operator
 *
 * @return ModemStep_t    return next step
 */
static ModemStep_t init()
{
	static const AtCmd_t AtCmdSetLWServer = { AT_CMD_IDX_SET_LWM2M_SERVER, "AT+QLWSERVERIP" };

	ModemStep_t nextStep =
		modemCtx.step; // step 종료 전 까지 현재 step을 next step 으로 return.
	modemCtx.errCode = MODEM_ERROR_AT_CMD_NO_RESP;

	if (modemCtx.stepReset) {
		StepFlowIndex.init = 0;
	}

	switch (StepFlowIndex.init) {
	case 0: {
		static const AtCmd_t AtCmdGetICCID = { AT_CMD_IDX_GET_ICCID, "AT+NCCID" };
		sendAtCommand(AT_CMD_DEFAULT_TIMEOUT, AT_CMD_DEFAULT_RETRY, &AtCmdGetICCID, NULL);
		StepFlowIndex.init++;
	} break;

	case 1: {
		static const AtCmd_t AtCmdGetIMEI = { AT_CMD_IDX_GET_IMEI, "AT+CGSN" };
		sendAtCommand(AT_CMD_DEFAULT_TIMEOUT, AT_CMD_DEFAULT_RETRY, &AtCmdGetIMEI, "=1");
		StepFlowIndex.init++;
	} break;

	case 2: {
		setModemData();
		static const AtCmd_t AtCmdGetLWServer = { AT_CMD_IDX_GET_LWM2M_SERVER,
							  "AT+QLWSERVERIP?" };
		sendAtCommand(AT_CMD_DEFAULT_TIMEOUT, AT_CMD_DEFAULT_RETRY, &AtCmdGetLWServer,
			      NULL);
		StepFlowIndex.init++;
	} break;

	case 3: {
		static const AtCmd_t AtCmdGetEPN = { AT_CMD_IDX_GET_EPN, "AT+QLWEPNS?" };
		sendAtCommand(AT_CMD_DEFAULT_TIMEOUT, AT_CMD_DEFAULT_RETRY, &AtCmdGetEPN, NULL);
		StepFlowIndex.init++;
	} break;

	case 4: {
		static const AtCmd_t AtCmdGetBSPS = { AT_CMD_IDX_GET_BSPS, "AT+QLWMBSPS?" };
		sendAtCommand(AT_CMD_DEFAULT_TIMEOUT, AT_CMD_DEFAULT_RETRY, &AtCmdGetBSPS, NULL);
		StepFlowIndex.init++;
	} break;

	case 5: {
		static const AtCmd_t AtCmdGetSwtLWM2M = { AT_CMD_IDX_GET_SWITCH_LWM2M,
							  "AT+QREGSWT?" };
		sendAtCommand(AT_CMD_DEFAULT_TIMEOUT, AT_CMD_DEFAULT_RETRY, &AtCmdGetSwtLWM2M,
			      NULL);
		StepFlowIndex.init++;
	} break;

	case 6: {
		static const AtCmd_t AtCmdGetFwRev = { AT_CMD_IDX_GET_FW_REV, "AT+QGMR" };
		sendAtCommand(AT_CMD_DEFAULT_TIMEOUT, AT_CMD_DEFAULT_RETRY, &AtCmdGetFwRev, NULL);
		StepFlowIndex.init =
			(modemCtx.proc.runInit) ? (StepFlowIndex.init + 1) : END_STEP_FLOW_INDEX;
	} break;

	case 7: {
		sendAtCommand(AT_CMD_RESET_TIMEOUT, AT_CMD_RESET_RETRY, &AtCmdSwReset, NULL);
		StepFlowIndex.init++;
	} break;

	case 8: {
		sendAtCommand(AT_CMD_DEFAULT_TIMEOUT, AT_CMD_DEFAULT_RETRY, &AtCmdSetRfCtrl, "=0");
		StepFlowIndex.init++;
	} break;

	case 9: {
		static const AtCmd_t AtCmdSetBAND = { AT_CMD_IDX_SET_BAND, "AT+NBAND" };
		sendAtCommand(AT_CMD_DEFAULT_TIMEOUT, AT_CMD_DEFAULT_RETRY, &AtCmdSetBAND, "=5");
		StepFlowIndex.init++;
	} break;

	case 10: {
		static const AtCmd_t AtCmdSetPSM = { AT_CMD_IDX_SET_PSM, "AT+CPSMS" };
		sendAtCommand(AT_CMD_DEFAULT_TIMEOUT, AT_CMD_DEFAULT_RETRY, &AtCmdSetPSM, "=0");
		StepFlowIndex.init++;
	} break;

	case 11: {
		static const AtCmd_t AtCmdSetReselect = { AT_CMD_IDX_SET_RESELECT, "AT+NCONFIG" };
		sendAtCommand(AT_CMD_DEFAULT_TIMEOUT, AT_CMD_DEFAULT_RETRY, &AtCmdSetReselect,
			      "=CELL_RESELECTION,TRUE");
		StepFlowIndex.init++;
	} break;

	case 12: {
		sendAtCommand(AT_CMD_DEFAULT_TIMEOUT, AT_CMD_DEFAULT_RETRY, &AtCmdSetLWServer,
			      "=BS,%s,%d", conf.serverIp, conf.serverPort);
		StepFlowIndex.init++;
	} break;

	case 13: {
		sendAtCommand(AT_CMD_DEFAULT_TIMEOUT, AT_CMD_DEFAULT_RETRY, &AtCmdSetLWServer,
			      "=LWM2M,%s,%d", conf.serverIp, conf.serverPort);
		StepFlowIndex.init++;
	} break;

	case 14: {
		static const AtCmd_t AtCmdSetEPN = { AT_CMD_IDX_SET_EPN, "AT+QLWEPNS" };
		sendAtCommand(AT_CMD_DEFAULT_TIMEOUT, AT_CMD_DEFAULT_RETRY, &AtCmdSetEPN,
			      "=1,\"%s\"", modem.epName);
		StepFlowIndex.init++;
	} break;

	case 15: {
		static const AtCmd_t AtCmdSetBSPS = { AT_CMD_IDX_SET_BSPS, "AT+QLWMBSPS" };
		sendAtCommand(AT_CMD_DEFAULT_TIMEOUT, AT_CMD_DEFAULT_RETRY, &AtCmdSetBSPS, "=%s",
			      modem.bsParam);
		StepFlowIndex.init++; // BS start after 15sec after attach complete
	} break;

	case 16: {
		static const AtCmd_t AtCmdSetLWM2M = { AT_CMD_IDX_SET_LWM2M,
						       "AT+QBOOTSTRAPHOLDOFF" };
		sendAtCommand(AT_CMD_DEFAULT_TIMEOUT, AT_CMD_DEFAULT_RETRY, &AtCmdSetLWM2M, "=0");
		StepFlowIndex.init++;
	} break;

	case 17: {
		static const AtCmd_t AtCmdSwtLWM2M = { AT_CMD_IDX_SWITCH_LWM2M, "AT+QREGSWT" };
		sendAtCommand(AT_CMD_DEFAULT_TIMEOUT, AT_CMD_DEFAULT_RETRY, &AtCmdSwtLWM2M, "=1");
		StepFlowIndex.init++;
	} break;

#define STEP_RESET_MODEM 18
	case STEP_RESET_MODEM: {
		sendAtCommand(AT_CMD_RESET_TIMEOUT, AT_CMD_RESET_RETRY, &AtCmdSwReset, NULL);
		StepFlowIndex.init++;
	} break;

	case 19: {
		sendAtCommand(AT_CMD_DEFAULT_TIMEOUT, AT_CMD_DEFAULT_RETRY, &AtCmdSetFOTA, "=1");
		StepFlowIndex.init = END_STEP_FLOW_INDEX;
	} break;

	case END_STEP_FLOW_INDEX:
	default: {
		if (!conf.isModemInit) {
			conf.isModemInit = TRUE;
			FLASH_saveConfigInfo(&conf);
		}

		// 모듈에서 자동으로 수행하는 통신(LWM2M 등)을 초기화 하기 위해 Reset.
		modemCtx.proc.runInit = 0;
		nextStep = MODEM_STEP_ATTACH_NW;
	} break;
	}

	return nextStep;
}

/**
 * @brief Attach step operator
 *
 * @return ModemStep_t    return next step
 */
static ModemStep_t attachNw()
{
	// step 종료 전 까지 현재 step을 next step 으로 return.
	ModemStep_t nextStep = modemCtx.step;
	modemCtx.errCode = MODEM_ERROR_AT_CMD_NO_RESP;

	if (modemCtx.stepReset) {
		StepFlowIndex.attach = 0;
	}

	switch (StepFlowIndex.attach) {
	case 0: {
		sendAtCommand(AT_CMD_DEFAULT_TIMEOUT, AT_CMD_DEFAULT_RETRY, &AtCmdSetRfCtrl, "=1");
		StepFlowIndex.attach++;
	} break;

	case 1: {
		// CGATT possible return error(means now attach trying)
		sendAtCommand(AT_CMD_DEFAULT_TIMEOUT, AT_CMD_DEFAULT_RETRY, &AtCmdDetachNw, "=1");
		StepFlowIndex.attach++;
	} break;

	case 2: {
		static const AtCmd_t AtCmdGetReportPSM = { AT_CMD_IDX_GET_REPORT_PSM, "AT+NPSMR?" };
		sendAtCommand(AT_CMD_CHECK_PSM_TIMEOUT, AT_CMD_CHECK_PSM_RETRY, &AtCmdGetReportPSM,
			      NULL);
		StepFlowIndex.attach++;
	} break;

	case 3: {
		static const AtCmd_t AtCmdSetNwAlarm = { AT_CMD_IDX_SET_NW_ALARM, "AT+CEREG" };
		sendAtCommand(AT_CMD_DEFAULT_TIMEOUT, AT_CMD_DEFAULT_RETRY, &AtCmdSetNwAlarm, "=5");
		StepFlowIndex.attach++;
	} break;

	case 4: {
		modemCtx.errCode = MODEM_ERROR_ATTACH_FAIL;
		static const AtCmd_t AtCmdGetNwAlarm = { AT_CMD_IDX_GET_NW_ALARM, "AT+CEREG?" };
		sendAtCommand(AT_CMD_ATTACH_TIMEOUT, AT_CMD_ATTACH_RETRY, &AtCmdGetNwAlarm, NULL);
		StepFlowIndex.attach++;
	} break;

	case 5: {
#define GET_TIME_TIMEOUT 5000
#define GET_TIME_RETRY 11
		static const AtCmd_t AtCmdGetTime = { AT_CMD_IDX_GET_TIME, "AT+CCLK?" };
		sendAtCommand(GET_TIME_TIMEOUT, GET_TIME_RETRY, &AtCmdGetTime, NULL);
		StepFlowIndex.attach++;
	} break;

	case 6: {
		static const AtCmd_t AtCmdGetRadioQuality = { AT_CMD_IDX_GET_RADIO_QUALITY,
							      "AT+NUESTATS" };
		sendAtCommand(AT_CMD_DEFAULT_TIMEOUT, AT_CMD_DEFAULT_RETRY, &AtCmdGetRadioQuality,
			      "=RADIO");
		StepFlowIndex.attach++;
	} break;

	case 7: {
		static const AtCmd_t AtCmdSetReportPSM = { AT_CMD_IDX_SET_REPORT_PSM, "AT+NPSMR" };
		sendAtCommand(AT_CMD_DEFAULT_TIMEOUT, AT_CMD_DEFAULT_RETRY, &AtCmdSetReportPSM,
			      "=1");
		StepFlowIndex.attach++;
	} break;

	default: {
		if (modemCtx.proc.updateQa) {
			nextStep = MODEM_STEP_UPDATE_QA;
		} else {
			nextStep = MODEM_STEP_CERTIFY;
		}
	} break;
	}

	// step 종료 전 까지 현재 step을 next step 으로 return.
	return nextStep;
}

/**
 * @brief QA uplink send step operator
 *
 * @return ModemStep_t    return next step
 */
static ModemStep_t updateQa()
{
	static const AtCmd_t AtCmdSocketSendUL = { AT_CMD_IDX_SOCKET_SEND_UL, "AT+NSOST" };
	ModemStep_t nextStep =
		modemCtx.step; // step 종료 전 까지 현재 step을 next step 으로 return.
	modemCtx.errCode = MODEM_ERROR_AT_CMD_NO_RESP;

	if (modemCtx.stepReset) {
		StepFlowIndex.updateQa = 0;
	}

	switch (StepFlowIndex.updateQa) {
	case 0: {
		sendAtCommand(AT_CMD_DEFAULT_TIMEOUT, AT_CMD_DEFAULT_RETRY, &AtCmdSocketCreate,
			      "=DGRAM,17,560,0");
		StepFlowIndex.updateQa++;
	} break;

	case 1: {
		int len;
		char *data = getQaReportMessage(&len);

		sendAtCommand(AT_CMD_DEFAULT_TIMEOUT, AT_CMD_DEFAULT_RETRY, &AtCmdSocketSendUL,
			      "=%d,%s,%ld,%d,%s", modemCtx.socket, LG_QA_SERVER_IP,
			      LG_QA_SERVER_PORT, len, data);
		StepFlowIndex.updateQa++;
	} break;

	case 2: {
		int len;
		char *data = getErrorReportMessage(&len);

		sendAtCommand(AT_CMD_DEFAULT_TIMEOUT, AT_CMD_DEFAULT_RETRY, &AtCmdSocketSendUL,
			      "=%d,%s,%ld,%d,%s", modemCtx.socket, LG_ERR_SERVER_IP,
			      LG_ERR_SERVER_PORT, len, data);
		StepFlowIndex.updateQa++;
	} break;

	case 3: {
		modemCtx.ulCnt = modemCtx.dlCnt = 0;
		modemCtx.pfUlCnt = modemCtx.pfDlCnt = 0;
		memset(modemCtx.errLog, 0, sizeof(modemCtx.errLog));
		sendAtCommand(AT_CMD_DEFAULT_TIMEOUT, AT_CMD_DEFAULT_RETRY, &AtCmdSocketClose,
			      "=%d", modemCtx.socket);
		StepFlowIndex.updateQa++;
	} break;

	default: {
		nextStep = MODEM_STEP_CERTIFY;
		RTC_read(&modem.lastUpdateTime);

		modemCtx.proc.updateQa = 0;
	} break;
	}

	return nextStep;
}

/**
 * @brief Transfer step operator
 *
 * @return ModemStep_t    return next step
 */
static ModemStep_t transfer()
{
	static uint16 transfer_count = 0;

	ModemStep_t nextStep =
		modemCtx.step; // step 종료 전 까지 현재 step을 next step 으로 return.
	modemCtx.errCode = MODEM_ERROR_AT_CMD_NO_RESP;

	if (modemCtx.stepReset) {
		StepFlowIndex.transfer = 0;
		modemCtx.waitDl = FALSE;
		printf_ts("transfer count : %d\n", ++transfer_count);
	}

	switch (StepFlowIndex.transfer) {
	case 0: {
		int len;
		extern uint8 AppProcess;
		BOOL isJoin = (AppProcess == APP_PERIODIC_REPORT) ? FALSE : TRUE;
		char *data = getMeterDataMessage(isJoin, &len);

		// Uplink 전송 전 Downlink length 초기화.
		// 단말기 입장에서 Uplink 전송 이전의 Downlink가 유효하다고 판단하기 힘드므로 무시.
		modemComm.dlDataLen = 0;
		// 데이터 전송 후 다시 PSM 진입 확인을 위해 Flag 초기화.
		modemCtx.status.psmOn = 0;

		modemCtx.errCode = MODEM_ERROR_PF_UL_FAIL;
		static const AtCmd_t AtCmdULDATAEX = { AT_CMD_IDX_QLWULDATAEX, "AT+QLWULDATAEX" };
		sendAtCommand(AT_CMD_DATA_SEND_TIMEOUT, AT_CMD_DATA_SEND_RETRY, &AtCmdULDATAEX,
			      "=0,%d,%s,0x0100,0", len, data);

		StepFlowIndex.transfer++;
	} break;

	case 1: {
		startEventTimeMsec = TIMER_getMsec();
		OSAL_setEvent(AppTaskId, APP_EVENT_MODEM_PROCESS);
		StepFlowIndex.transfer++;
	} break;

	case 2: {
		if (modemComm.dlDataLen > 0) {
			// Ack Ok
			METER_clearStoredData();
			modemCtx.waitDl = FALSE;
			MODEM_checkDlMessage((void *)modemComm.dlData, modemComm.dlDataLen);

			StepFlowIndex.transfer = END_STEP_FLOW_INDEX;
			OSAL_setEvent(AppTaskId, APP_EVENT_MODEM_PROCESS);
		} else if (TIMER_getMsecDiff(startEventTimeMsec) >= AT_CMD_LWM2M_DL_WAIT) {
			printf_ts("DL : LWM2M downlink req timeout\n");

			if (modemCtx.waitDl) {
				// Uplink Ok
				METER_clearIntervalData();
			}

			StepFlowIndex.transfer = END_STEP_FLOW_INDEX;
			OSAL_setEvent(AppTaskId, APP_EVENT_MODEM_PROCESS);
		} else {
			OSAL_startEventTimer(AppTaskId, APP_EVENT_MODEM_PROCESS,
					     MODEM_EVENT_INTERVAL);
		}
	} break;

	case END_STEP_FLOW_INDEX:
	default: {
		if (Fota.Req) {
			nextStep = MODEM_STEP_DFOTA;
		} else if (modemCtx.lwm2m.fotaDownReq) {
			nextStep = MODEM_STEP_FOTA;
		} else {
			nextStep = MODEM_STEP_DETACH_NW;
		}
	} break;
	}

	return nextStep;
}

/**
 * @brief BC95G modem certify step operator (통신사 플랫폼 인증 과정)
 *
 * @return ModemStep_t    return next step
 */
static ModemStep_t certify()
{
	ModemStep_t nextStep = modemCtx.step;
	modemCtx.errCode = MODEM_ERROR_PF_CERITY_FAIL;

	if (modemCtx.stepReset) {
		StepFlowIndex.certify = 0;
	}

	switch (StepFlowIndex.certify) {
	case 0: {
		startEventTimeMsec = TIMER_getMsec();
		OSAL_setEvent(AppTaskId, APP_EVENT_MODEM_PROCESS);
		StepFlowIndex.certify++;
	} break;

	case 1: {
		if (modemCtx.lwm2m.obsObj10250 || modemCtx.lwm2m.obsObj16241) {
			OSAL_setEvent(AppTaskId, APP_EVENT_MODEM_PROCESS);
			StepFlowIndex.certify++;
		} else {
			if (TIMER_getMsecDiff(startEventTimeMsec) >= AT_CMD_LWM2M_TIMEOUT) {
				OSAL_setEvent(AppTaskId, APP_EVENT_MODEM_PROCESS);
				StepFlowIndex.certify = END_STEP_FLOW_INDEX;
			} else {
				OSAL_startEventTimer(AppTaskId, APP_EVENT_MODEM_PROCESS,
						     MODEM_EVENT_INTERVAL);
			}
		}
	} break;

	case END_STEP_FLOW_INDEX:
	default: {
		if (modemCtx.lwm2m.obsObj10250 || modemCtx.lwm2m.obsObj16241) {
			nextStep = MODEM_STEP_TRANSFER;
		} else {
			printf_ts("PF : Fail to register\n");
			// 이전 command retry 방지
			memset(&modemComm, 0, sizeof(modemComm));
			OSAL_setEvent(AppTaskId, APP_EVENT_MODEM_TIMEOUT);
		}
	} break;
	}

	return nextStep;
}

/**
 * @brief FOTA step operator
 *
 * @return ModemStep_t    return next step
 */
static ModemStep_t fota()
{
	ModemStep_t nextStep = modemCtx.step;
	modemCtx.errCode = MODEM_ERROR_PF_FOTA_FAIL;

	if (modemCtx.stepReset) {
		StepFlowIndex.fota = 0;
	}

	switch (StepFlowIndex.fota) {
	case 0: {
		startEventTimeMsec = TIMER_getMsec();
		OSAL_setEvent(AppTaskId, APP_EVENT_MODEM_PROCESS);
		StepFlowIndex.fota++;
	} break;

	case 1: {
		if (modemCtx.lwm2m.fotaDownReq) {
			sendAtCommand(AT_CMD_LWM2M_TIMEOUT, AT_CMD_LWM2M_RETRY, &AtCmdSetFOTA,
				      "=2");
			StepFlowIndex.fota++;
		} else if (modemCtx.status.psmOn) { // FOTA downlink request 대기 중 PSM 진입 시 처리.
			OSAL_setEvent(AppTaskId, APP_EVENT_MODEM_PROCESS);
			StepFlowIndex.fota = ENTER_PSM_FLOW_INDEX;
		} else {
			if (TIMER_getMsecDiff(startEventTimeMsec) >= MODEM_FW_DOWN_REQ_TIMEOUT) {
				OSAL_setEvent(AppTaskId, APP_EVENT_MODEM_PROCESS);
				StepFlowIndex.fota = END_STEP_FLOW_INDEX;
			} else {
				OSAL_startEventTimer(AppTaskId, APP_EVENT_MODEM_PROCESS,
						     MODEM_EVENT_INTERVAL);
			}
		}
	} break;

	case 2: {
		startEventTimeMsec = TIMER_getMsec();
		OSAL_setEvent(AppTaskId, APP_EVENT_MODEM_PROCESS);
		StepFlowIndex.fota++;
	} break;

	case 3: {
		if (modemCtx.lwm2m.fotaUpgradeReq) {
			sendAtCommand(AT_CMD_LWM2M_TIMEOUT, AT_CMD_LWM2M_RETRY, &AtCmdSetFOTA,
				      "=4");
			StepFlowIndex.fota++;
		} else {
			if (TIMER_getMsecDiff(startEventTimeMsec) >= MODEM_FW_DOWNLOAD_TIMEOUT) {
				OSAL_setEvent(AppTaskId, APP_EVENT_MODEM_PROCESS);
				StepFlowIndex.fota = END_STEP_FLOW_INDEX;
			} else {
				OSAL_startEventTimer(AppTaskId, APP_EVENT_MODEM_PROCESS,
						     MODEM_EVENT_INTERVAL);
			}
		}
	} break;

	case 4: {
		startEventTimeMsec = TIMER_getMsec();
		OSAL_setEvent(AppTaskId, APP_EVENT_MODEM_PROCESS);
		StepFlowIndex.fota++;
	} break;

	case 5: {
		if (modemCtx.lwm2m.fotaFinish) {
			OSAL_setEvent(AppTaskId, APP_EVENT_MODEM_PROCESS);
			StepFlowIndex.fota++;
		} else {
			if (TIMER_getMsecDiff(startEventTimeMsec) >= MODEM_FW_UPGRADE_TIMEOUT) {
				OSAL_setEvent(AppTaskId, APP_EVENT_MODEM_PROCESS);
				StepFlowIndex.fota = END_STEP_FLOW_INDEX;
			} else {
				OSAL_startEventTimer(AppTaskId, APP_EVENT_MODEM_PROCESS,
						     MODEM_EVENT_INTERVAL);
			}
		}
	} break;

	case 6: {
		startEventTimeMsec = TIMER_getMsec();
		OSAL_setEvent(AppTaskId, APP_EVENT_MODEM_PROCESS);
		StepFlowIndex.fota++;
	} break;

	case 7: {
		// FOTA 완료 후 완료 확인을 위한 재인증을 대기한다(1분)
		// 재인증 성공실패 여부와 관계없이 단말기 입장에서 FOTA는 성공한 것이므로
		// 성공여부를 판단하지 않는다.
		if (TIMER_getMsecDiff(startEventTimeMsec) >= MODEM_FOTA_COMPLETE_WAIT) {
			OSAL_setEvent(AppTaskId, APP_EVENT_MODEM_PROCESS);
			StepFlowIndex.fota = END_STEP_FLOW_INDEX;
		} else {
			OSAL_startEventTimer(AppTaskId, APP_EVENT_MODEM_PROCESS,
					     MODEM_EVENT_INTERVAL);
		}
	} break;

	case ENTER_PSM_FLOW_INDEX: {
		nextStep = MODEM_STEP_IDLE;
	} break;

	case END_STEP_FLOW_INDEX:
	default: {
		if (!modemCtx.lwm2m.fotaDownReq) {
			printf_ts("PF : Fail to enter PSM during No FOTA download request\n");
			MODEM_stop(FAIL);
		} else {
			if (!modemCtx.lwm2m.fotaUpgradeReq) {
				printf_ts("PF : FOTA upgrade req timeout.\n");
				MODEM_stop(FAIL);
			} else {
				if (!modemCtx.lwm2m.fotaFinish) {
					printf_ts("PF : FOTA complete timeout.\n");
					MODEM_stop(FAIL);
				} else {
					// FOTA 완료 후 MODEM 초기화 재수행을 위해 init flag 초기화
					conf.isModemInit = FALSE;
					FLASH_saveConfigInfo(&conf);

					nextStep = MODEM_STEP_DETACH_NW;
				}
			}
		}
	} break;
	}

	return nextStep;
}

static ModemStep_t dFota()
{
	static const AtCmd_t AtCmdSocketRecvDL = { AT_CMD_IDX_SOCKET_RECV_DL, "AT+NSORF" };

	ModemStep_t nextStep =
		modemCtx.step; // step 종료 전 까지 현재 step을 next step 으로 return.
	modemCtx.errCode = MODEM_ERROR_AT_CMD_NO_RESP;

	if (modemCtx.stepReset) {
		StepFlowIndex.dfota = 0;
	}

	switch (StepFlowIndex.dfota) {
	case 0: {
		sendAtCommand(FOTA_TIMEOUT, FOTA_RETRY, &AtCmdSocketCreate, "=STREAM,6,0,1");
		StepFlowIndex.dfota++;
	} break;

	case 1: {
		static const AtCmd_t AtCmdTcpConnect = { AT_CMD_IDX_TCP_CONNECT, "AT+NSOCO" };
		sendAtCommand(FOTA_TIMEOUT, FOTA_RETRY, &AtCmdTcpConnect, "=%d,%s,%d",
			      modemCtx.socket, Fota.Info.ip, Fota.Info.port);
		StepFlowIndex.dfota++;
	} break;

	case 2: {
		sendAtCommand(FOTA_TIMEOUT, FOTA_RETRY, &AtCmdSocketRecvDL, "=%d,%d",
			      modemCtx.socket, modemComm.dlDataLen);
		StepFlowIndex.dfota++;
	} break;

	case 3: {
		if (strcmp(FIRMWARE_VER, Fota.Info.version) == 0) {
			printf_ts("Curr[%s], Update[%s] Equal, No update\n", FIRMWARE_VER,
				  Fota.Info.version);
			memset(&Fota, 0, sizeof(Fota));
			sendNoRespAtCommand(DEREGISTER_DELAY, &AtCmdSocketClose, "=%d",
					    modemCtx.socket);
			nextStep = MODEM_STEP_DETACH_NW;
			break;
		}

		char msg[FOTA_REQMSG_SIZE];
		snprintf(msg, FOTA_REQMSG_SIZE, "C1%s%s%s%s", FIRMWARE_VER, Fota.Info.version,
			 modem.imeiStr, modem.imsiStr);
		memset(Fota.reqMsg, 0, sizeof(Fota.reqMsg));

		char checksum = 0;
		for (unsigned int i = 0; i < sizeof(msg); i++) {
			char data = *(msg + i);
			checksum += data;
			snprintf(Fota.reqMsg, FOTA_REQMSG_SIZE * 2 - 1, "%s%02X", Fota.reqMsg,
				 data);
		}
		snprintf(Fota.reqMsg, FOTA_REQMSG_SIZE * 2 + 2, "%s%02X", Fota.reqMsg, checksum);

		static const AtCmd_t AtCmdTcpSendUL = { AT_CMD_IDX_TCP_CONNECT, "AT+NSOSD" };
		sendAtCommand(FOTA_TIMEOUT, FOTA_RETRY, &AtCmdTcpSendUL, "=%d,%d,%s,0x100,101",
			      modemCtx.socket, FOTA_REQMSG_SIZE, Fota.reqMsg);
		StepFlowIndex.dfota++;
	} break;

	case 4: {
		sendAtCommand(FOTA_TIMEOUT, FOTA_RETRY, &AtCmdSocketRecvDL, "=%d,%d",
			      modemCtx.socket, modemComm.dlDataLen);
		StepFlowIndex.dfota++;
	} break;

	default:
		P2OUT &= ~0x20;
		TIMER_stop();
		LCD_disable();
		METER_disable();
		startFota();
		break;
	}

	return nextStep;
}

/**
 * @brief Detach step operator
 *
 * @return ModemStep_t    return next step
 */
static ModemStep_t detachNw()
{
	ModemStep_t nextStep = modemCtx.step;
	// detach fail none error
	modemCtx.errCode = MODEM_ERROR_NONE;

	if (modemCtx.stepReset) {
		StepFlowIndex.detach = 0;
	}

	switch (StepFlowIndex.detach) {
	case 0: {
		// FOTA 완료 시 기존 인증절차도 초기화 되므로 De-register를 할 필요가 없음.
		// 다만, 단말 F/W에서 진행여부를 판단하는 Flag이므로 초기화는 안함.
		sendAtCommand(AT_CMD_COMM_TIMEOUT, AT_CMD_COMM_DETACH_RETRY, &AtCmdDetachNw, "=0");

		startEventTimeMsec = TIMER_getMsec();
		StepFlowIndex.detach++;
	} break;

	case 1: {
		// wait detach time
		if (TIMER_getMsecDiff(startEventTimeMsec) >= DETACH_DELAY_TIME) {
			OSAL_setEvent(AppTaskId, APP_EVENT_MODEM_PROCESS);
			StepFlowIndex.detach++;
		} else if (modemCtx.status.psmOn) {
			OSAL_setEvent(AppTaskId, APP_EVENT_MODEM_PROCESS);
			StepFlowIndex.detach++;
		} else {
			OSAL_startEventTimer(AppTaskId, APP_EVENT_MODEM_PROCESS,
					     MODEM_EVENT_INTERVAL);
		}
	} break;

	default: {
		nextStep = MODEM_STEP_IDLE;
	} break;
	}

	return nextStep;
}

/**
 * @brief RETRY step operator
 *
 * @return ModemStep_t    return next step
 */
static ModemStep_t retry()
{
	// step 종료 전 까지 현재 step을 next step 으로 return.
	ModemStep_t nextStep = modemCtx.step;
	modemCtx.errCode = MODEM_ERROR_AT_CMD_NO_RESP;

	if (modemCtx.stepReset) {
		StepFlowIndex.retry = 0;
	}

	switch (StepFlowIndex.retry) {
	case 0: {
		if (modemCtx.status.cellreg == MODEM_CELLREG_ATTACHED) {
			sendAtCommand(AT_CMD_COMM_TIMEOUT, AT_CMD_COMM_DETACH_RETRY, &AtCmdDetachNw,
				      "=0");
		} else {
			OSAL_setEvent(AppTaskId, APP_EVENT_MODEM_PROCESS);
		}
		StepFlowIndex.retry++;
	} break;

	case 1: {
		// wait detach time
		if (TIMER_getMsecDiff(startEventTimeMsec) >= DETACH_DELAY_TIME) {
			OSAL_setEvent(AppTaskId, APP_EVENT_MODEM_PROCESS);
			StepFlowIndex.retry++;
		} else if (modemCtx.status.cellreg != MODEM_CELLREG_ATTACHED) {
			OSAL_setEvent(AppTaskId, APP_EVENT_MODEM_PROCESS);
			StepFlowIndex.retry++;
		} else {
			OSAL_startEventTimer(AppTaskId, APP_EVENT_MODEM_PROCESS,
					     MODEM_EVENT_INTERVAL);
		}
	} break;

	case 2: {
		if (modemCtx.proc.hwRstRetry) {
			MODEM_turnOff();
		}
		StepFlowIndex.retry++;
		OSAL_setEvent(AppTaskId, APP_EVENT_MODEM_PROCESS);
	} break;

	case 3: {
		if (modemCtx.proc.hwRstRetry) {
			MODEM_turnOn();
		} else {
			sendAtCommand(AT_CMD_RESET_TIMEOUT, AT_CMD_RESET_RETRY, &AtCmdSwReset,
				      NULL);
		}
		startEventTimeMsec = TIMER_getMsec();
		StepFlowIndex.retry++;
		OSAL_setEvent(AppTaskId, APP_EVENT_MODEM_PROCESS);
	} break;

	case 4: {
		if (TIMER_getMsecDiff(startEventTimeMsec) >= MODEM_BOOTUP_INTERVAL) {
			StepFlowIndex.retry++;
		}
		OSAL_setEvent(AppTaskId, APP_EVENT_MODEM_PROCESS);
	} break;

	default: {
		if (modemCtx.proc.hwRstRetry) {
			// H/W reset 시 Idle 바로 다음 Step인 BIP 부터 수행.
			nextStep = MODEM_STEP_BIP;
		} else {
			nextStep = MODEM_STEP_ATTACH_NW;
		}
	} break;
	}

	return nextStep;
}

BOOL MODEM_generateCseID(const char *serviceCode, const char *ctnStr, const char *iccidStr,
			 char *buffer, int size)
{
	if (ctnStr == NULL || iccidStr == NULL || serviceCode == NULL) {
		return FALSE;
	}

	if (strlen(serviceCode) != LEN_MODEM_SERVICE_CODE) {
		return FALSE;
	}

	char *cseid = getEndPointName(serviceCode, ctnStr, iccidStr);
	if (buffer != NULL && size > 0) {
		memcpy(buffer, cseid, size);
	} else {
		memcpy(modem.epName, cseid, sizeof(modem.epName));
	}

	return TRUE;
}

void MODEM_detach()
{
/*
     * 외부 Interrupt에 의한 단말기 Reboot전 Detach 및 Deregister 이므로
     * 서버/기지국 응답을 대기하지 않고 일정 Delay 후 종료한다.
     * 해당 동작은 UDP 기반이거나 예외처리 시 허용되는 동작이기 때문에 가능하다.
     */
#define DETACH_DELAY_MS 5000
	// Detach 전송.
	sendNoRespAtCommand(DETACH_DELAY_MS, &AtCmdDetachNw, "=0");
}

BOOL MODEM_process()
{
	OSAL_stopEventTimer(AppTaskId, APP_EVENT_MODEM_TIMEOUT);

	ModemStep_t nextStep = MODEM_STEP_UNKNOWN;
	switch (modemCtx.step) {
	case MODEM_STEP_IDLE:
		nextStep = idle();
		break;
	case MODEM_STEP_BIP:
		nextStep = bip();
		break;
	case MODEM_STEP_INIT:
		nextStep = init();
		break;
	case MODEM_STEP_ATTACH_NW:
		nextStep = attachNw();
		break;
	case MODEM_STEP_UPDATE_QA:
		nextStep = updateQa();
		break;
	case MODEM_STEP_TRANSFER:
		nextStep = transfer();
		break;
	case MODEM_STEP_CERTIFY:
		nextStep = certify();
		break;
	case MODEM_STEP_FOTA:
		nextStep = fota();
		break;
	case MODEM_STEP_DETACH_NW:
		nextStep = detachNw();
		break;
	case MODEM_STEP_RETRY:
		nextStep = retry();
		break;
	case MODEM_STEP_DFOTA:
		nextStep = dFota();
		break;
	default:
		return FALSE;
	}

	// 동작 중간에 stop된 경우를 고려.
	if (modemCtx.step != nextStep && !modemCtx.status.stop) {
#if defined(DEBUG)
		printf_ts("MODEM : current(%s) next(%s) busy(%d) stop(%d) error(%d) cellreg(%d)\n",
			  MODEM_STEP_STRING(modemCtx.step), MODEM_STEP_STRING(nextStep),
			  modemCtx.status.busy, modemCtx.status.stop, modemCtx.errCode,
			  modemCtx.status.cellreg);
#endif

		// 완료된 현재 step과 retry step이 동일한 경우
		// retry 동작이 정상적으로 수행된 것을 의미하므로 retry 관련 context를 초기화.
		if (modemCtx.step == modemCtx.retryStep) {
			// modemCtx.retryCount = 0;
			modemCtx.retryStep = MODEM_STEP_UNKNOWN;
		}

		modemCtx.step = nextStep;
		// step이 변경될 경우 해당 step을 최초부터 시작하기 위해 reset flag를 설정
		modemCtx.stepReset = TRUE;

		// If next step is IDLE and retry step is not set, process finish end success.
		if (modemCtx.step == MODEM_STEP_IDLE) {
			MODEM_stop(SUCCESS);
		} else {
			OSAL_setEvent(AppTaskId, APP_EVENT_MODEM_PROCESS);
		}
	} else {
		modemCtx.stepReset = FALSE;
	}

	return TRUE;
}
