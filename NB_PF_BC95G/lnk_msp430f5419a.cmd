/* ============================================================================ */
/* Copyright (c) 2019, Texas Instruments Incorporated                           */
/*  All rights reserved.                                                        */
/*                                                                              */
/*  Redistribution and use in source and binary forms, with or without          */
/*  modification, are permitted provided that the following conditions          */
/*  are met:                                                                    */
/*                                                                              */
/*  *  Redistributions of source code must retain the above copyright           */
/*     notice, this list of conditions and the following disclaimer.            */
/*                                                                              */
/*  *  Redistributions in binary form must reproduce the above copyright        */
/*     notice, this list of conditions and the following disclaimer in the      */
/*     documentation and/or other materials provided with the distribution.     */
/*                                                                              */
/*  *  Neither the name of Texas Instruments Incorporated nor the names of      */
/*     its contributors may be used to endorse or promote products derived      */
/*     from this software without specific prior written permission.            */
/*                                                                              */
/*  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" */
/*  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,       */
/*  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR      */
/*  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR            */
/*  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,       */
/*  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,         */
/*  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; */
/*  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,    */
/*  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR     */
/*  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,              */
/*  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.                          */
/* ============================================================================ */

/******************************************************************************/
/* lnk_msp430f5419a.cmd - LINKER COMMAND FILE FOR LINKING MSP430F5419A PROGRAMS     */
/*                                                                            */
/*   Usage:  lnk430 <obj files...>    -o <out file> -m <map file> lnk.cmd     */
/*           cl430  <src files...> -z -o <out file> -m <map file> lnk.cmd     */
/*                                                                            */
/*----------------------------------------------------------------------------*/
/* These linker options are for command line linking only.  For IDE linking,  */
/* you should set your linker options in Project Properties                   */
/* -c                                               LINK USING C CONVENTIONS  */
/* -stack  0x0100                                   SOFTWARE STACK SIZE       */
/* -heap   0x0100                                   HEAP AREA SIZE            */
/*                                                                            */
/*----------------------------------------------------------------------------*/
/* Version: 1.207                                                             */
/*----------------------------------------------------------------------------*/

/****************************************************************************/
/* Specify the system memory map                                            */
/****************************************************************************/
/* FLASHB boundaries have been changed to fix CPU20 (see errata sheet)      */

/* FLASH */
#define USER_TEST_ORIGIN 0x6000

#define TEST_LEN 0x2000
#define MTEST_LEN 0x1200
#define SHELL_LEN 0x2400

#define LIBRARY_LEN 0x2600

#define USER_FLASH_ORIGIN 0x10200

#define METER_LEN 0x1C00
#define DATA_FLASH_LEN 0x1A00
#define APP_LEN 0x1000
#define NFC_PROTOCOL_LEN 0x1400
#define NFC_I2C_LEN 0xC00
#define RTC_ALARM_LEN 0xC00
#define MAIN_LEN 0x200
#define UART_LEN 0xE00
#define FLASH_DRIVER_LEN 0xC00
#define UTIL_LEN 0x1000
#define MODEM_LEN 0x1200
#define NB_RESPONSE_LEN 0x1800
#define MESSAGE_LEN 0x1800
#define NB_PROCESS_LEN 0x2000

#define USER_FLASH_ORIGIN2 0x20200


/* RAM */
#define RAM_ORIGIN 0x1C00

#define FOTA_LEN 0x1000
#define NOINIT_LEN 0x80
#define PROC_DATA_LEN 0x2E0
#define STATIC_DATA_LEN 0x60
#define FOTA_DATA_LEN 0x90
#define METER_DATA_LEN 0x250
#define MODEM_DATA_LEN 0x3A0
#define LIBRARY_DATA_LEN 0x20
#define DATA_RAM_LEN 0x160

MEMORY
{
    SFR                     : origin = 0x0000, length = 0x0010
    PERIPHERALS_8BIT        : origin = 0x0010, length = 0x00F0
    PERIPHERALS_16BIT       : origin = 0x0100, length = 0x0100
    FOTA_RAM                : origin = RAM_ORIGIN, length = FOTA_LEN
    NOINIT_RAM              : origin = end(FOTA_RAM), length = NOINIT_LEN
    NB_PROC_DATA            : origin = end(NOINIT_RAM), length = PROC_DATA_LEN
    STATIC_DATA             : origin = end(NB_PROC_DATA), length = STATIC_DATA_LEN
    FOTA_DATA               : origin = end(STATIC_DATA), length = FOTA_DATA_LEN
    METER_DATA              : origin = end(FOTA_DATA), length = METER_DATA_LEN
    MODEM_DATA              : origin = end(METER_DATA), length = MODEM_DATA_LEN
    LIBRARY_DATA            : origin = end(MODEM_DATA), length = LIBRARY_DATA_LEN
    DATA_RAM                : origin = end(LIBRARY_DATA), length = DATA_RAM_LEN
    RAM                     : origin = end(DATA_RAM), length = 0x3CC0 - end(DATA_RAM)
    HEAP                    : origin = 0x3CC0, length = 0xFA0
    STACK                   : origin = 0x4C60, length = 0xFA0
    INFOA                   : origin = 0x1980, length = 0x0080
    INFOB                   : origin = 0x1900, length = 0x0080
    INFOC                   : origin = 0x1880, length = 0x0080
    INFOD                   : origin = 0x1800, length = 0x0080
    MAIN_CODE	        	: origin = 0x5C00, length = 0x400
    TEST                    : origin = end(MAIN_CODE), length = TEST_LEN
    MTEST                   : origin = end(TEST), length = MTEST_LEN
    SHELL                   : origin = end(MTEST), length = SHELL_LEN
    LIBRARY                 : origin = end(SHELL), length = LIBRARY_LEN
    FLASHB                  : origin = end(LIBRARY), length = 0xFFD2 - end(LIBRARY)
    METER                   : origin = USER_FLASH_ORIGIN, length = METER_LEN
    DATA_FLASH              : origin = end(METER), length = DATA_FLASH_LEN
    APP                     : origin = end(DATA_FLASH), length = APP_LEN
    NFC_PROTOCOL            : origin = end(APP), length = NFC_PROTOCOL_LEN
    NFC_I2C                 : origin = end(NFC_PROTOCOL), length = NFC_I2C_LEN
    RTC_ALARM               : origin = end(NFC_I2C), length = RTC_ALARM_LEN
    UART                    : origin = end(RTC_ALARM), length = UART_LEN
    FLASH_DRIVER            : origin = end(UART), length = FLASH_DRIVER_LEN
    UTIL                    : origin = end(FLASH_DRIVER), length = UTIL_LEN
    MODEM                   : origin = end(UTIL), length = MODEM_LEN
    NB_RESPONSE             : origin = end(MODEM), length = NB_RESPONSE_LEN
    MESSAGE                 : origin = end(NB_RESPONSE), length = MESSAGE_LEN
    NB_PROCESS              : origin = end(MESSAGE), length = 0x20000 - end(MESSAGE)
    FOTA_FLASH              : origin = USER_FLASH_ORIGIN2, length = FOTA_LEN
    MD5                     : origin = end(FOTA_FLASH), length = 0x1000
    FLASHD                  : origin = end(MD5),length = 0x23400 - end(MD5)
    INT41                   : origin = 0xFFD2, length = 0x0002
    INT42                   : origin = 0xFFD4, length = 0x0002
    INT43                   : origin = 0xFFD6, length = 0x0002
    INT44                   : origin = 0xFFD8, length = 0x0002
    INT45                   : origin = 0xFFDA, length = 0x0002
    INT46                   : origin = 0xFFDC, length = 0x0002
    INT47                   : origin = 0xFFDE, length = 0x0002
    INT48                   : origin = 0xFFE0, length = 0x0002
    INT49                   : origin = 0xFFE2, length = 0x0002
    INT50                   : origin = 0xFFE4, length = 0x0002
    INT51                   : origin = 0xFFE6, length = 0x0002
    INT52                   : origin = 0xFFE8, length = 0x0002
    INT53                   : origin = 0xFFEA, length = 0x0002
    INT54                   : origin = 0xFFEC, length = 0x0002
    INT55                   : origin = 0xFFEE, length = 0x0002
    INT56                   : origin = 0xFFF0, length = 0x0002
    INT57                   : origin = 0xFFF2, length = 0x0002
    INT58                   : origin = 0xFFF4, length = 0x0002
    INT59                   : origin = 0xFFF6, length = 0x0002
    INT60                   : origin = 0xFFF8, length = 0x0002
    INT61                   : origin = 0xFFFA, length = 0x0002
    INT62                   : origin = 0xFFFC, length = 0x0002
    RESET                   : origin = 0xFFFE, length = 0x0002
}

/****************************************************************************/
/* Specify the sections allocation into memory                              */
/****************************************************************************/


SECTIONS
{
#define CODE_ALIGN 512

    .nbiotProcess_data : {
        nbiotProcess.obj (.data:ul_data)
        nbiotProcess.obj (.data:raw_data)
        nbiotProcess.obj (.data:StepFlowIndex)
    } > NB_PROC_DATA

    .static_data : {
        NFC_i2c.obj (.data:RxBuffer)
        NFC_i2c.obj (.data:TxBuffer)
        rtcAlarm.obj (.data:AlarmList)
        rtcAlarm.obj (.data:TimeSyncDate)
        battery.obj (.data:BattAdcBuffer)
        lcdDriver.obj (.data:currentLCD)
    } > STATIC_DATA

    .fota_data : {
        fota.obj (.data:fotaPort)
        fota.obj (.data:initialMsgSize)
        fota.obj (.data:socket)
        fota.obj (.data:Fota)
    } > FOTA_DATA

    .meter_data : {
        meter.obj (.data:StoredMeterData)
    } > METER_DATA

    .modem_data : {
        modem.obj (.data:modem)
        modem.obj (.data:modemComm)
    } > MODEM_DATA

    .library_data : {
        --library=rts430x_lc_ld_eabi.lib (.data:_tz)
        --library=rts430x_lc_ld_eabi.lib (.data:_lock)
        --library=rts430x_lc_ld_eabi.lib (.data:_unlock)
        --library=rts430x_lc_ld_eabi.lib<strtok.c.obj> (.data)
        --library=rts430x_lc_ld_eabi.lib<errno.c.obj> (.data)
        --library=rts430x_lc_ld_eabi.lib<memory.c.obj> (.data)
    } > LIBRARY_DATA

    .data_ram : {
        nfcProtocol.obj (.data:nfcAsyncRx)
        md5.obj (.data:PADDING)
        mTest.obj (.data:modemTestCtx)
        modem.obj (.data:modemCtx)
        meter.obj (.data:TempMeterData)
        flashDriver.obj (.data:FlashAddr)
        lcdDriver.obj (.data:lcdCon)
        app.obj (.data:Metering)
    } > DATA_RAM

    .data : {
        rts430x_lc_ld_eabi.lib (.data)
        osal_Timer.obj (.data)
        rtcAlarm.obj (.data)
        Task_Mgr.obj (.data)
        battery.obj (.data)
        lcdDriver.obj (.data:lcdCon)
        main.obj (.data)
        test.obj (.data)
        fota.obj (.data)
        shell.obj (.data)
        uart.obj (.data)
        modem.obj (.data)
        app.obj (.data)
        nbiotResponse.obj (.data)
        nfcProtocol.obj (.data)
        nbiotProcess.obj (.data)
        *(.data)
    } > RAM              /* Global vars              */
    .bss        : align(CODE_ALIGN) {} > RAM (HIGH)             /* Global & static vars              */
    .TI.noinit  : {} > NOINIT_RAM           /* For #pragma noinit                */
    .sysmem     : {} > HEAP                 /* Dynamic memory allocation area    */
    .stack      : {} > STACK                /* Software system stack             */
    MAIN		: align(CODE_ALIGN) {} > MAIN_CODE
    main_text : align(CODE_ALIGN) {
        main.obj (.text)
    } > MAIN_CODE (HIGH)

    .test_text : align(CODE_ALIGN) {
        test.obj (.text:TEST_pmrsn)
        test.obj (.text:TEST_readMeter)
        test.obj (.text:TEST_pmwsn)
        test.obj (.text:TEST_writeMeter)
        test.obj (.text:TEST_setMeterType)
        test.obj (.text:saveTerminalConfig)
        test.obj (.text:TEST_run)
        test.obj (.text:TEST_readFlash)
        test.obj (.text:TEST_pmeter)
        test.obj (.text:TEST_lpm3)
        test.obj (.text:TEST_runTasks)
        test.obj (.text:TEST_meteringParamer)
        test.obj (.text:TEST_readBattery)
        test.obj (.text:TEST_prsn)
        test.obj (.text:TEST_resetNFC)
        test.obj (.text:TEST_lpm2)
        test.obj (.text:TEST_pwmeter)
        test.obj (.text:TEST_readRTC)
        test.obj (.text:TEST_setRTC)
        test.obj (.text:TEST_riCtrlMode)
        test.obj (.text:TEST_writeSerialNum)
        test.obj (.text:TEST_readSerialNum)
        test.obj (.text:TEST_debugPrint)
        test.obj (.text:TEST_shortInterval)
        test.obj (.text:TEST_sleepMode)
        test.obj (.text:TEST_eraseFlash)
        test.obj (.text:TEST_lcd)
        test.obj (.text:interruptTask)
        test.obj (.text:TEST_reedSensor)
        test.obj (.text:TEST_checkNFC)
        test.obj (.text:TEST_checkTestMode)
        test.obj (.text:TEST_pwsn)
        test.obj (.text:TEST_meterLCD)
        test.obj (.text:TEST_readFwVersion)
        test.obj (.text:TEST_stop)
        test.obj (.text:reedResponse)
        test.obj (.text:TEST_config)
    } > TEST

    .test_const : align(CODE_ALIGN) {
        test.obj (.const:TestTasksArray)
        test.obj (.const:.string)
    } > TEST (HIGH)

    .mtest_text : align(CODE_ALIGN) {
        mTest.obj (.text:TEST_prnbid)
        mTest.obj (.text:parseNbiotModemResp)
        mTest.obj (.text:printAtCmdList)
        mTest.obj (.text:TEST_modemResponse)
        mTest.obj (.text:TEST_modem)
        mTest.obj (.text:TEST_pnbctx)
        mTest.obj (.text:waitModemBipOk)
        mTest.obj (.text:waitModemReady)
        mTest.obj (.text:waitModemAck)
        mTest.obj (.text:TEST_pwserver)
        mTest.obj (.text:TEST_prserver)
        mTest.obj (.text:TEST_prfota)
        mTest.obj (.text:TEST_pwfota)
        mTest.obj (.text:sendToModem)
        mTest.obj (.text:TEST_pmodem)
        mTest.obj (.text:waitModem)
        mTest.obj (.text:TEST_initModem)
        mTest.obj (.text:resetModem)
    } > MTEST

    .mtest_const : align(CODE_ALIGN) {
        mTest.obj (.const:.string)
    } > MTEST (HIGH)

    .shell_text : align(CODE_ALIGN) {
        shell.obj (.text:SHELL_run)
        shell.obj (.text:SHELL_gets)
        shell.obj (.text:SHELL_getChar)
        shell.obj (.text:help)
        shell.obj (.text:getArguments)
        shell.obj (.text:whatCommand)
        shell.obj (.text:SHELL_decimal)
        shell.obj (.text:SHELL_init)
        shell.obj (.text:SHELL_string)
    } > SHELL (HIGH)

    .shell_const : align(CODE_ALIGN) {
        shell.obj (.const:CmdSet)
        shell.obj (.const:.string)
    } > SHELL

    .library_text : align(CODE_ALIGN) {
        --library=rts430x_lc_ld_eabi.lib (.text:__mktime32)
        --library=rts430x_lc_ld_eabi.lib (.text:__mspabi_divull)
        --library=rts430x_lc_ld_eabi.lib (.text:__TI_printfi_nofloat:_setfield___TI_printfi_nofloat)
        --library=rts430x_lc_ld_eabi.lib (.text:__TI_printfi_nofloat:__TI_printfi_nofloat)
        --library=rts430x_lc_ld_eabi.lib (.text:__TI_printfi_nofloat:_getarg_diouxp___TI_printfi_nofloat)
        --library=rts430x_lc_ld_eabi.lib (.text:aligned_alloc)
        --library=rts430x_lc_ld_eabi.lib (.text:__TI_printfi_nofloat:_ltostr___TI_printfi_nofloat)
        --library=rts430x_lc_ld_eabi.lib (.text:free)
        --library=rts430x_lc_ld_eabi.lib (.text:__TI_printfi_nofloat:_pproc_diouxp___TI_printfi_nofloat)
        --library=rts430x_lc_ld_eabi.lib (.text:__mspabi_divlli)
        --library=rts430x_lc_ld_eabi.lib (.text:__TI_printfi_nofloat:_pproc_fwp___TI_printfi_nofloat)
        --library=rts430x_lc_ld_eabi.lib (.text:__TI_printfi_nofloat:_pproc_wstr___TI_printfi_nofloat)
        --library=rts430x_lc_ld_eabi.lib (.text:split)
        --library=rts430x_lc_ld_eabi.lib (.text:__TI_printfi_nofloat:_pproc_str___TI_printfi_nofloat)
        --library=rts430x_lc_ld_eabi.lib (.text:__TI_auto_init_nobinit_nopinit_hold_wdt:__TI_auto_init_nobinit_nopinit_hold_wdt)
        --library=rts430x_lc_ld_eabi.lib (.text:snprintf)
        --library=rts430x_lc_ld_eabi.lib (.text:decompress:lzss:__TI_decompress_lzss)
        --library=rts430x_lc_ld_eabi.lib (.text:atol)
        --library=rts430x_lc_ld_eabi.lib (.text:vsnprintf)
        --library=rts430x_lc_ld_eabi.lib (.text:_outs)
        --library=rts430x_lc_ld_eabi.lib (.text:atoi)
        --library=rts430x_lc_ld_eabi.lib (.text:strtok)
        --library=rts430x_lc_ld_eabi.lib (.text:__mpyll)
        --library=rts430x_lc_ld_eabi.lib (.text:__mspabi_remlli)
        --library=rts430x_lc_ld_eabi.lib (.text:strncpy)
        --library=rts430x_lc_ld_eabi.lib (.text:free_list_insert)
        --library=rts430x_lc_ld_eabi.lib (.text:sprintf)
        --library=rts430x_lc_ld_eabi.lib (.text:__mspabi_srall)
        --library=rts430x_lc_ld_eabi.lib (.text:l_asr_const)
        --library=rts430x_lc_ld_eabi.lib (.text:l_lsl_const)
        --library=rts430x_lc_ld_eabi.lib (.text:l_lsr_const)
        --library=rts430x_lc_ld_eabi.lib (.text:memcpy)
        --library=rts430x_lc_ld_eabi.lib (.text:__mspabi_sllll)
        --library=rts430x_lc_ld_eabi.lib (.text:__mspabi_srlll)
        --library=rts430x_lc_ld_eabi.lib (.text:strncmp)
        --library=rts430x_lc_ld_eabi.lib (.text:memccpy)
        --library=rts430x_lc_ld_eabi.lib (.text:memcmp)
        --library=rts430x_lc_ld_eabi.lib (.text:strcspn)
        --library=rts430x_lc_ld_eabi.lib (.text:strspn)
        --library=rts430x_lc_ld_eabi.lib (.text:_outc)
        --library=rts430x_lc_ld_eabi.lib (.text:free_list_remove)
        --library=rts430x_lc_ld_eabi.lib (.text:wcslen)
        --library=rts430x_lc_ld_eabi.lib (.text:decompress:ZI:__TI_zero_init)
        --library=rts430x_lc_ld_eabi.lib (.text:strcmp)
        --library=rts430x_lc_ld_eabi.lib (.text:decompress:none:__TI_decompress_none)
        --library=rts430x_lc_ld_eabi.lib (.text:heap_start)
        --library=rts430x_lc_ld_eabi.lib (.text:llabs)
        --library=rts430x_lc_ld_eabi.lib (.text:strcpy)
        --library=rts430x_lc_ld_eabi.lib (.text:l_lsr)
        --library=rts430x_lc_ld_eabi.lib (.text:isxdigit)
        --library=rts430x_lc_ld_eabi.lib (.text:isdigit)
        --library=rts430x_lc_ld_eabi.lib (.text:malloc)
        --library=rts430x_lc_ld_eabi.lib (.text:abs)
        --library=rts430x_lc_ld_eabi.lib (.text:abort)
        --library=rts430x_lc_ld_eabi.lib (.text:_system_pre_init)
        --library=rts430x_lc_ld_eabi.lib (.text:_nop)
        --library=rts430x_lc_ld_eabi.lib (.text:_system_post_cinit)
        --library=rts430x_lc_ld_eabi.lib<div32u.asm.obj> (.text)
        --library=rts430x_lc_ld_eabi.lib<div32s.asm.obj> (.text)
        --library=rts430x_lc_ld_eabi.lib<div16s.asm.obj> (.text)
        --library=rts430x_lc_ld_eabi.lib<mult32_f5hw.asm.obj> (.text)
        --library=rts430x_lc_ld_eabi.lib<mult16_f5hw.asm.obj> (.text)
        --library=rts430x_lc_ld_eabi.lib<div16u.asm.obj> (.text)
        --library=rts430x_lc_ld_eabi.lib<rotl32.asm.obj> (.text)
        --library=rts430x_lc_ld_eabi.lib<lsl16.asm.obj> (.text)
    } > LIBRARY

    .library_const : align(CODE_ALIGN) {
        --library=rts430x_lc_ld_eabi.lib (.const:.string:_ctypes_)
        --library=rts430x_lc_ld_eabi.lib (.const:mon_len)
        --library=rts430x_lc_ld_eabi.lib (.const:mon_day)
        --library=rts430x_lc_ld_eabi.lib (.const:.string)
    } > LIBRARY (HIGH)

    nfcProtocol_text : align(CODE_ALIGN) {
        nfcProtocol.obj (.text:recvNodeConfSetV3)
        nfcProtocol.obj (.text:recvBdControlReq)
        nfcProtocol.obj (.text:sendMeterReport)
        nfcProtocol.obj (.text:sendNodeConfReportV3)
        nfcProtocol.obj (.text:sendBdControlAck)
        nfcProtocol.obj (.text:NFCAPP_meterAdjustResp)
        nfcProtocol.obj (.text:NFCAPP_meterAdjustReq)
        nfcProtocol.obj (.text:sendServerConnectReport)
        nfcProtocol.obj (.text:NFCAPP_runMessage)
        nfcProtocol.obj (.text:recvNbiotIdSet)
        nfcProtocol.obj (.text:recvFwUpdateReq)
        nfcProtocol.obj (.text:recvFlashDataReq)
        nfcProtocol.obj (.text:setRtcV1)
        nfcProtocol.obj (.text:recvFlashDateListReq)
        nfcProtocol.obj (.text:sendFwUpdateResp)
        nfcProtocol.obj (.text:sendDeviceInfo)
        nfcProtocol.obj (.text:send)
        nfcProtocol.obj (.text:sendNbiotIdReport)
        nfcProtocol.obj (.text:sendMeterAdjustError)
        nfcProtocol.obj (.text:copyToAsyncCmd)
        nfcProtocol.obj (.text:jumpToBSL)
        nfcProtocol.obj (.text:readRtcV1)
        nfcProtocol.obj (.text:sendFwVerReport)
        nfcProtocol.obj (.text:NFCAPP_continueSend)
        nfcProtocol.obj (.text:dev_clock_internal)
        nfcProtocol.obj (.text:recvMeterAdjustRequest)
        nfcProtocol.obj (.text:NFCAPP_clearAsyncCmd)
        nfcProtocol.obj (.text:recvMeterReq)
        nfcProtocol.obj (.text:recvServerConnectReq)
        nfcProtocol.obj (.text:disable_OFIE)
        nfcProtocol.obj (.text:getMyDeviceCode)
    } > NFC_PROTOCOL

    nfcProtocol_const : align(CODE_ALIGN) {
        nfcProtocol.obj (.const:.string)
    } > NFC_PROTOCOL (HIGH)

    .meter_text : align(CODE_ALIGN) {
        meter.obj (.text:read_onetl_meter)
        meter.obj (.text:read_shinhan_d_meter)
        meter.obj (.text:METER_collectStoredData)
        meter.obj (.text:read_mns_d_meter)
        meter.obj (.text:METER_addStoredData)
        meter.obj (.text:METER_displayStoredData)
        meter.obj (.text:read_std_d_meter)
        meter.obj (.text:METER_enable)
        meter.obj (.text:METER_displayTempData)
        meter.obj (.text:METER_std_adjustReq)
        meter.obj (.text:METER_ontel_sendRequest)
        meter.obj (.text:METER_std_adjustResp)
        meter.obj (.text:METER_recvResponse)
        meter.obj (.text:checkInterval)
        meter.obj (.text:METER_getMeterName)
        meter.obj (.text:METER_bypassReq)
        meter.obj (.text:METER_addTempData)
        meter.obj (.text:METER_clearIntervalData)
        meter.obj (.text:METER_needNewMetering)
        meter.obj (.text:METER_std_lcdMarkReq)
        meter.obj (.text:METER_bypassResp)
        meter.obj (.text:METER_std_lcdTestReq)
        meter.obj (.text:METER_std_configRequest)
        meter.obj (.text:METER_std_sendRequest)
        meter.obj (.text:METER_saveInFlash)
        meter.obj (.text:METER_sendRequest)
        meter.obj (.text:METER_shinhan_sendRequest)
        meter.obj (.text:METER_saveMeterInfo)
        meter.obj (.text:METER_mns_sendRequest)
        meter.obj (.text:METER_clearStoredData)
        meter.obj (.text:METER_getFirstValidPos)
        meter.obj (.text:hex2int)
        meter.obj (.text:METER_disable)
        meter.obj (.text:METER_getMeterData)
        meter.obj (.text:METER_getMeterStatus)
        meter.obj (.text:METER_deleteStoredData)
        meter.obj (.text:METER_isAllFF)
        meter.obj (.text:METER_deleteTempData)
        meter.obj (.text:METER_deleteAllData)
        meter.obj (.text:METER_getLastData)
        meter.obj (.text:METER_getMeterCaliber_dp)
        meter.obj (.text:METER_getNumberOfStoredData)
        meter.obj (.text:METER_getSaveInterval)
        meter.obj (.text:METER_getSerialNum)
        meter.obj (.text:METER_getTempData)
    } > METER

    .meter_const : align(CODE_ALIGN) {
        meter.obj (.const:$P$T0$1)
        meter.obj (.const:.string)
    } > METER (HIGH)

    dataFlash_text : align(CODE_ALIGN) {
        dataFlash.obj (.text:get_dataSavePos)
        dataFlash.obj (.text:dataFlash_sendData)
        dataFlash.obj (.text:make_dateList)
        dataFlash.obj (.text:saveData)
        dataFlash.obj (.text:read_dataSector)
        dataFlash.obj (.text:fix_mapSector)
        dataFlash.obj (.text:print_dataReport)
        dataFlash.obj (.text:dataFlash_displayDataSector)
        dataFlash.obj (.text:dataFlash_displayMapSector)
        dataFlash.obj (.text:make_nfcDataReport)
        dataFlash.obj (.text:readAndSort_map)
        dataFlash.obj (.text:verifySectors)
        dataFlash.obj (.text:dataFlash_save)
        dataFlash.obj (.text:read_mapSector)
        dataFlash.obj (.text:writeSector)
        dataFlash.obj (.text:dataFlash_readData)
        dataFlash.obj (.text:dataFlash_getList)
        dataFlash.obj (.text:read_dataUnit)
        dataFlash.obj (.text:eraseSector)
        dataFlash.obj (.text:readSector)
        dataFlash.obj (.text:dataFlash_eraseSector)
        dataFlash.obj (.text:hex2binary)
        dataFlash.obj (.text:isValidMeterValue)
        dataFlash.obj (.text:get_flashAddress)
        dataFlash.obj (.text:isValidDate)
        dataFlash.obj (.text:cal_checksum)
        dataFlash.obj (.text:waitIdle)
        dataFlash.obj (.text:dataFlash_init)
        dataFlash.obj (.text:dataFlash_genData)
    } > DATA_FLASH

    dataFlash_const : align(CODE_ALIGN) {
        dataFlash.obj (.const:.string)
    } > DATA_FLASH (HIGH)

    .app_text : align(CODE_ALIGN) {
        app.obj (.text:APP_showConfig)
        app.obj (.text:APP_tasks)
        app.obj (.text:APP_init)
        app.obj (.text:meteringRetry)
        app.obj (.text:meteringUpdateData)
        app.obj (.text:ctrlReportInterval)
        app.obj (.text:APP_runMetering)
        app.obj (.text:meteringCompleted)
        app.obj (.text:meteringRecvResp)
        app.obj (.text:APP_prepareToSleep)
        app.obj (.text:REBOOT_SYSTEM)
        app.obj (.text:APP_checkTimeInterval)
        app.obj (.text:APP_runPeriodicReport)
        app.obj (.text:meteringTimeout)
    } > APP

    .app_const : align(CODE_ALIGN) {
        app.obj (.const:.string)
    } > APP (HIGH)

    rtcAlarm_text : align(CODE_ALIGN) {
        rtcAlarm.obj (.text:RTC_Alarm_Scheduler_normal)
        rtcAlarm.obj (.text:RTC_runAlarm)
        rtcAlarm.obj (.text:RTC_calcSecDiff)
        rtcAlarm.obj (.text:RTC_Alarm_Scheduler_short)
        rtcAlarm.obj (.text:RTC_init)
        rtcAlarm.obj (.text:RTC_incDateHour)
        rtcAlarm.obj (.text:RTC_set)
        rtcAlarm.obj (.text:rtcAlarmSet)
        rtcAlarm.obj (.text:RTC_calcHourDiff)
        rtcAlarm.obj (.text:RTC_isValidDate)
        rtcAlarm.obj (.text:RTC_writeTime)
        rtcAlarm.obj (.text:RTC_read)
        rtcAlarm.obj (.text:RTC_needTimeSync)
        rtcAlarm.obj (.text:setDefaultRTC)
        rtcAlarm.obj (.text:RTC_alarmSchedule)
        rtcAlarm.obj (.text:RTC_calcMinDiff)
        rtcAlarm.obj (.text:RTC_isTimeSync)
    } > RTC_ALARM

    rtcAlarm_const : align(CODE_ALIGN) {
        rtcAlarm.obj (.const:$P$T0$1)
        rtcAlarm.obj (.const:$P$T1$2)
        rtcAlarm.obj (.const:.string:MaxDays)
        rtcAlarm.obj (.const:.string)
    } > RTC_ALARM (HIGH)

    uart_text : align(CODE_ALIGN) {
        uart.obj (.text:UART_open)
        uart.obj (.text:mallocUartBuf)
        uart.obj (.text:UART_close)
        uart.obj (.text:UART_send)
        uart.obj (.text:printf_ts)
        uart.obj (.text:UART_receive)
        uart.obj (.text:printf)
        uart.obj (.text:PRINT_string)
        uart.obj (.text:UART_getChar)
        uart.obj (.text:UART_debugMode)
        uart.obj (.text:set_meterPortForBSL)
        uart.obj (.text:UART_init)
        uart.obj (.text:mallocBuf)
        uart.obj (.text:fota_uart)
        uart.obj (.text:PRINT_enable)
        uart.obj (.text:PRINT_resume)
        uart.obj (.text:PRINT_disable)
        uart.obj (.text:PRINT_stop)
    } > UART

    uart_const : align(CODE_ALIGN) {
        uart.obj (.const:$P$T0$1)
        uart.obj (.const:$P$T1$4)
        uart.obj (.const:.string)
    } > UART (HIGH)

    flashDriver_text : align(CODE_ALIGN) {
        flashDriver.obj (.text:FLASH_readConfigInfo)
        flashDriver.obj (.text:readConfig)
        flashDriver.obj (.text:FLASH_saveConfigInfo)
        flashDriver.obj (.text:readID)
        flashDriver.obj (.text:saveConfig)
        flashDriver.obj (.text:saveID)
        flashDriver.obj (.text:distributingReportTime)
        flashDriver.obj (.text:int2bcd)
        flashDriver.obj (.text:bcd2int)
        flashDriver.obj (.text:ip2hexArray)
        flashDriver.obj (.text:FLASH_updateResetCount)
        flashDriver.obj (.text:saveConfChecksum)
        flashDriver.obj (.text:calChecksum)
    } > FLASH_DRIVER

    flashDriver_const : align(CODE_ALIGN) {
        flashDriver.obj (.const:.string)
    } > FLASH_DRIVER (HIGH)

    lcdDriver_text : align(CODE_ALIGN) {
        lcdDriver.obj (.text:LCD_displayValue)
        lcdDriver.obj (.text:sendMsgToLCD)
        lcdDriver.obj (.text:LCD_updateMeterValue)
        lcdDriver.obj (.text:LCD_displayString)
        lcdDriver.obj (.text:LCD_init)
        lcdDriver.obj (.text:LCD_displayFirmwareVersion)
        lcdDriver.obj (.text:LCD_enable)
        lcdDriver.obj (.text:LCD_Exist)
        lcdDriver.obj (.text:LCD_displayError)
        lcdDriver.obj (.text:LCD_clear)
        lcdDriver.obj (.text:LCD_displayAll)
        lcdDriver.obj (.text:LCD_wait)
        lcdDriver.obj (.text:LCD_disable)
        lcdDriver.obj (.text:LCD_accessModem)
        lcdDriver.obj (.text:lcdDataTx)
        lcdDriver.obj (.text:LCD_redraw)
        MSP430FlashUtil.obj (.text:MSP430FLASH_write)
        MSP430FlashUtil.obj (.text:MSP430FLASH_erasePage)
        MSP430FlashUtil.obj (.text:MSP430FLASH_read)
        check_meter_misc.obj (.text:MISC_NfcPortSelect)
        check_meter_misc.obj (.text:MISC_getDeviceType)
        check_meter_misc.obj (.text:MISC_getBslType)
        check_meter_misc.obj (.text:MISC_delayUs)
        battery.obj (.text:readBatteryADC)
        battery.obj (.text:BATT_getVoltage)
        battery.obj (.text:addBatteryADC)
        battery.obj (.text:BATT_getLevel)
        battery.obj (.text:BATT_init)
        battery.obj (.text:BATT_loadLastVoltage)
        battery.obj (.text:BATT_getLastVoltage), .=align(CODE_ALIGN);
        Task_Mgr.obj (.text:TASKMGR_run)
        Task_Mgr.obj (.text:TASKMGR_init)
        osal_Timer.obj (.text:addEventTimer)
        osal_Timer.obj (.text:OSAL_startEventTimer)
        osal_Timer.obj (.text:delevtEventTimer)
        osal_Timer.obj (.text:TIMER_getMsecDiff)
        osal_Timer.obj (.text:OSAL_stopEventTimer)
        osal_Timer.obj (.text:findEventTimer)
        osal_Timer.obj (.text:TIMER_init)
        osal_Timer.obj (.text:TIMER_getMsec)
        osal_Timer.obj (.text:TIMER_start)
        osal_Timer.obj (.text:TIMER_stop)
    } > UTIL

    lcdDriver_const : align(CODE_ALIGN) {
        lcdDriver.obj (.const:$P$T0$1)
        lcdDriver.obj (.const:.string)
        MSP430FlashUtil.obj (.const:.string)
        Task_Mgr.obj (.const:TasksArray)
        Task_Mgr.obj (.const)
        Task_Mgr.obj (.const:.string)
        osal.obj (.text:OSAL_setEvent)
        osal_Timer.obj (.const:.string)
    } > UTIL (HIGH)

    modem_text : align(CODE_ALIGN) {
        modem.obj (.text:MODEM_timeout)
        modem.obj (.text:saveModemErrorLog)
        modem.obj (.text:MODEM_stop)
        modem.obj (.text:MODEM_close)
        modem.obj (.text:MODEM_getStateOrResult)
        modem.obj (.text:MODEM_read)
        modem.obj (.text:MODEM_turnOff)
        modem.obj (.text:MODEM_getAccessState)
        modem.obj (.text:MODEM_write)
        modem.obj (.text:MODEM_turnOn)
        modem.obj (.text:MODEM_open)
        modem.obj (.text:MODEM_copyCtn)
        modem.obj (.text:str2BcdForImeiAndImsi)
        modem.obj (.text:MODEM_initialization)
        modem.obj (.text:MODEM_changeBaudrate)
        modem.obj (.text:MODEM_copyIccid)
        modem.obj (.text:MODEM_copyLastAccessTime)
        modem.obj (.text:MODEM_sleep)
        modem.obj (.text:MODEM_wakeup)
        modem.obj (.text:MODEM_enable)
        modem.obj (.text:MODEM_handler)
        modem.obj (.text:MODEM_disable)
        modem.obj (.text:MODEM_getLastRsrp)
        modem.obj (.text:MODEM_getLastRsrq)
        modem.obj (.text:MODEM_getLastRssi)
        modem.obj (.text:MODEM_copyCseId)
        modem.obj (.text:MODEM_getLastSNR)
        modem.obj (.text:MODEM_copyImei)
        modem.obj (.text:MODEM_copyImsi)
    } > MODEM

    modem_const : align(CODE_ALIGN) {
        modem.obj (.const:$P$T3$1)
        modem.obj (.const:$P$T4$2)
        modem.obj (.const:.string)
    } > MODEM (HIGH)

    nbiotResponse_text : align(CODE_ALIGN) {
        nbiotResponse.obj (.text:parse_fota_downlink)
        nbiotResponse.obj (.text:parse_server_notify)
        nbiotResponse.obj (.text:parse_radioQuality)
        nbiotResponse.obj (.text:parse_imsi)
        nbiotResponse.obj (.text:parse_bs_param)
        nbiotResponse.obj (.text:parse_cclk)
        nbiotResponse.obj (.text:parse_pf_downlink)
        nbiotResponse.obj (.text:parseQGMR)
        nbiotResponse.obj (.text:parse_lwm2m_server)
        nbiotResponse.obj (.text:parse_ncdp)
        nbiotResponse.obj (.text:parse_cereg)
        nbiotResponse.obj (.text:parse_imei)
        nbiotResponse.obj (.text:parse_ep_name)
        nbiotResponse.obj (.text:parse_iccid)
        nbiotResponse.obj (.text:parseQLWULDATAEX)
        nbiotResponse.obj (.text:MODEM_response)
    } > NB_RESPONSE

    nbiotResponse_const : align(CODE_ALIGN) {
        nbiotResponse.obj (.const:.string)
    } > NB_RESPONSE (HIGH)

    message_text : align(CODE_ALIGN) {
        message.obj (.text:MODEM_qaData)
        message.obj (.text:MODEM_errData)
        message.obj (.text:insert_multiData)
        message.obj (.text:MODEM_checkDlMessage)
        message.obj (.text:MODEM_recvIntervalReq)
        message.obj (.text:insert_meteringTime)
        message.obj (.text:MODEM_recvFotaReq)
        message.obj (.text:insert_termInfo)
        message.obj (.text:MODEM_sendCurrentData)
        message.obj (.text:MODEM_sendPeriodicData)
        message.obj (.text:insert_oneData)
        message.obj (.text:insert_radioQuality)
        message.obj (.text:MODEM_recvRepRange)
        message.obj (.text:insert_meterInfo)
        message.obj (.text:printMessage)
        message.obj (.text:MODEM_recvResetReq)
        message.obj (.text:MODEM_recvAckString)
        message.obj (.text:insert_id)
        message.obj (.text:cal_checksum)
        message.obj (.text:insert_meteringParam)
    } > MESSAGE

    message_const : align(CODE_ALIGN) {
        message.obj (.const:.string)
    } > MESSAGE (HIGH)

    nbiotProcess_text : align(CODE_ALIGN) {
        nbiotProcess.obj (.text:dFota)
        nbiotProcess.obj (.text:init)
        nbiotProcess.obj (.text:setModemData)
        nbiotProcess.obj (.text:fota)
        nbiotProcess.obj (.text:updateQa)
        nbiotProcess.obj (.text:transfer)
        nbiotProcess.obj (.text:getEndPointName)
        nbiotProcess.obj (.text:bip)
        nbiotProcess.obj (.text:retry)
        nbiotProcess.obj (.text:certify)
        nbiotProcess.obj (.text:attachNw)
        nbiotProcess.obj (.text:MODEM_process)
        nbiotProcess.obj (.text:sendAtCommand)
        nbiotProcess.obj (.text:idle)
        nbiotProcess.obj (.text:detachNw)
        nbiotProcess.obj (.text:sendNoRespAtCommand)
        nbiotProcess.obj (.text:getErrorReportMessage)
        nbiotProcess.obj (.text:getMeterDataMessage)
        nbiotProcess.obj (.text:getQaReportMessage)
        nbiotProcess.obj (.text:MODEM_generateCseID)
        nbiotProcess.obj (.text:MODEM_detach)
    } > NB_PROCESS

    nbiotProcess_const : align(CODE_ALIGN) {
        nbiotProcess.obj (.const:AtCmdSwReset)
        nbiotProcess.obj (.const:AtCmdDetachNw)
        nbiotProcess.obj (.const:AtCmdGetIMEI)
        nbiotProcess.obj (.const:AtCmdGetIMSI)
        nbiotProcess.obj (.const:AtCmdGetICCID)
        nbiotProcess.obj (.const:AtCmdGetRadioQuality)
        nbiotProcess.obj (.const:AtCmdGetNwAlarm)
        nbiotProcess.obj (.const:AtCmdGetTime)
        nbiotProcess.obj (.const:AtCmdSetRfCtrl)
        nbiotProcess.obj (.const:AtCmdSetPSM)
        nbiotProcess.obj (.const:AtCmdSetBAND)
        nbiotProcess.obj (.const:AtCmdSetReselect)
        nbiotProcess.obj (.const:AtCmdSetNwAlarm)
        nbiotProcess.obj (.const:AtCmdSocketCreate)
        nbiotProcess.obj (.const:AtCmdTcpConnect)
        nbiotProcess.obj (.const:AtCmdTcpSendUL)
        nbiotProcess.obj (.const:AtCmdSocketSendUL)
        nbiotProcess.obj (.const:AtCmdSocketClose)
        nbiotProcess.obj (.const:AtCmdSetReportPSM)
        nbiotProcess.obj (.const:AtCmdGetReportPSM)
        nbiotProcess.obj (.const:AtCmdSocketRecvDL)
        nbiotProcess.obj (.const:AtCmdGetFwRev)
        nbiotProcess.obj (.const:AtCmdSetLWM2M)
        nbiotProcess.obj (.const:AtCmdSetLWServer)
        nbiotProcess.obj (.const:AtCmdSetEPN)
        nbiotProcess.obj (.const:AtCmdSetBSPS)
        nbiotProcess.obj (.const:AtCmdGetLWServer)
        nbiotProcess.obj (.const:AtCmdGetBSPS)
        nbiotProcess.obj (.const:AtCmdGetEPN)
        nbiotProcess.obj (.const:AtCmdSwtLWM2M)
        nbiotProcess.obj (.const:AtCmdGetSwtLWM2M)
        nbiotProcess.obj (.const:AtCmdSetFOTA)
        nbiotProcess.obj (.const:AtCmdULDATAEX)
        nbiotProcess.obj (.const:.string)
    } > NB_PROCESS (HIGH)

    .md5_text : align(CODE_ALIGN) {
        md5.obj (.text)
    } > MD5

    .uuid_text : align(CODE_ALIGN) {
        uuid.obj (.text)
    } > MD5 (HIGH)

    nfci2c_text : align(CODE_ALIGN) {
        NFC_i2c.obj (.text:NTAG_writeBlock)
        NFC_i2c.obj (.text:NTAG_writeBytes)
        NFC_i2c.obj (.text:NFC_sendMessage)
        NFC_i2c.obj (.text:I2C_txMultipleBytes)
        NFC_i2c.obj (.text:NTAG_readBytes)
        NFC_i2c.obj (.text:NFC_factoryResetTag)
        NFC_i2c.obj (.text:I2C_rxMultipleBytes)
        NFC_i2c.obj (.text:NFC_recvMessage)
        NFC_i2c.obj (.text:NFC_checkRead)
        NFC_i2c.obj (.text:NTAG_setTransferDir)
        NFC_i2c.obj (.text:NFC_tagDetect)
        NFC_i2c.obj (.text:NTAG_readSessionRegister)
        NFC_i2c.obj (.text:I2C_writeData)
        NFC_i2c.obj (.text:I2C_readData)
        NFC_i2c.obj (.text:NFC_tagEnable)
        NFC_i2c.obj (.text:NTAG_writeSessionRegister)
        NFC_i2c.obj (.text:I2C_rxBytes)
        NFC_i2c.obj (.text:I2C_txBytes)
        NFC_i2c.obj (.text:NFC_fdEnable)
        NFC_i2c.obj (.text:NFC_tagDisable)
        NFC_i2c.obj (.text:NTAG_readBlock)
        NFC_i2c.obj (.text:NTAG_setPthruOnOff)
        NFC_i2c.obj (.text:NFC_FD_input)
        NFC_i2c.obj (.text:NFC_fdDisable)
        NFC_i2c.obj (.text:NTAG_setFDOffFunction)
        NFC_i2c.obj (.text:NTAG_setFDOnFunction)
        NFC_i2c.obj (.text:NFC_init)
    } > NFC_I2C

    nfci2c_const : align(CODE_ALIGN) {
        NFC_i2c.obj (.const:.string:DefaultBeginingOfMemory)
        NFC_i2c.obj (.const:.string:NullBlock)
        NFC_i2c.obj (.const:.string:DefaultPage56)
        NFC_i2c.obj (.const:.string:DefaultPage57)
        NFC_i2c.obj (.const:.string:DefaultPage58)
    } > NFC_I2C (HIGH)

    int00_section : > FLASHB(HIGH)
    {
         --library=rts430x_lc_ld_eabi.lib(.text:_isr:_c_int00_noargs)
    }

    .ramcode : {
        * (.text:_isr)
        test.obj (.text:TEST_isTestMode)
        check_meter_misc.obj (.text:MISC_delayMs)
        flashDriver.obj (.text:ascii2BCD)
        flashDriver.obj (.text:ascii2Hex)
        meter.obj (.text:std_checksum)
        --library=rts430x_lc_ld_eabi.lib(.text:strlen)
        --library=rts430x_lc_ld_eabi.lib(.text:strstr)
        --library=rts430x_lc_ld_eabi.lib(.text:memset)
        fota.obj (.text)
        fota.obj (.const)
    } load=FOTA_FLASH, run=FOTA_RAM, 
    LOAD_START(ramcode_ld_start),
    RUN_START(ramcode_rn_start),
    SIZE(ramcode_size)

#ifndef __LARGE_CODE_MODEL__
    .text       : align(CODE_ALIGN) {} >> FLASHB | FLASHD      /* Code                              */
#else
    .text       : align(CODE_ALIGN) {} > FLASHB       /* Code                              */
#endif
/* Errata Flash Read Error and Susceptibility for MSP430F54xxA 
Manual placement of interrupt service routines into memory locations above 0x008000
can eliminate the effect on interrupt vector address fetches. */
    .cinit      : align(CODE_ALIGN) {} > FLASHB                /* Initialization tables             */
#ifndef __LARGE_DATA_MODEL__
    .const      : align(CODE_ALIGN) {} >> FLASHB | FLASHD                /* Constant data                     */
#else
    .const      : align(CODE_ALIGN) {} > FLASHB      /* Constant data                     */
#endif
    .cio        : align(CODE_ALIGN) {} > RAM                  /* C I/O Buffer                      */

    .pinit      : align(CODE_ALIGN) {} > FLASHB                /* C++ Constructor tables            */
    .binit      : align(CODE_ALIGN) {} > FLASHB                /* Boot-time Initialization tables   */
    .init_array : align(CODE_ALIGN) {} > FLASHB                /* C++ Constructor tables            */
    .mspabi.exidx : align(CODE_ALIGN) {} > FLASHB              /* C++ Constructor tables            */
    .mspabi.extab : align(CODE_ALIGN) {} > FLASHB              /* C++ Constructor tables            */

    .infoA     : {} > INFOA              /* MSP430 INFO FLASH Memory segments */
    .infoB     : {} > INFOB
    .infoC     : {} > INFOC
    .infoD     : {} > INFOD

    /* MSP430 Interrupt vectors          */
    /* .int00       : {}               > INT00 */
    /* .int01       : {}               > INT01 */
    /* .int02       : {}               > INT02 */
    /* .int03       : {}               > INT03 */
    /* .int04       : {}               > INT04 */
    /* .int05       : {}               > INT05 */
    /* .int06       : {}               > INT06 */
    /* .int07       : {}               > INT07 */
    /* .int08       : {}               > INT08 */
    /* .int09       : {}               > INT09 */
    /* .int10       : {}               > INT10 */
    /* .int11       : {}               > INT11 */
    /* .int12       : {}               > INT12 */
    /* .int13       : {}               > INT13 */
    /* .int14       : {}               > INT14 */
    /* .int15       : {}               > INT15 */
    /* .int16       : {}               > INT16 */
    /* .int17       : {}               > INT17 */
    /* .int18       : {}               > INT18 */
    /* .int19       : {}               > INT19 */
    /* .int20       : {}               > INT20 */
    /* .int21       : {}               > INT21 */
    /* .int22       : {}               > INT22 */
    /* .int23       : {}               > INT23 */
    /* .int24       : {}               > INT24 */
    /* .int25       : {}               > INT25 */
    /* .int26       : {}               > INT26 */
    /* .int27       : {}               > INT27 */
    /* .int28       : {}               > INT28 */
    /* .int29       : {}               > INT29 */
    /* .int30       : {}               > INT30 */
    /* .int31       : {}               > INT31 */
    /* .int32       : {}               > INT32 */
    /* .int33       : {}               > INT33 */
    /* .int34       : {}               > INT34 */
    /* .int35       : {}               > INT35 */
    /* .int36       : {}               > INT36 */
    /* .int37       : {}               > INT37 */
    /* .int38       : {}               > INT38 */
    /* .int39       : {}               > INT39 */
    /* .int40       : {}               > INT40 */
    RTC          : { * ( .int41 ) } > INT41 type = VECT_INIT
    PORT2        : { * ( .int42 ) } > INT42 type = VECT_INIT
    USCI_B3      : { * ( .int43 ) } > INT43 type = VECT_INIT
    USCI_A3      : { * ( .int44 ) } > INT44 type = VECT_INIT
    USCI_B1      : { * ( .int45 ) } > INT45 type = VECT_INIT
    USCI_A1      : { * ( .int46 ) } > INT46 type = VECT_INIT
    PORT1        : { * ( .int47 ) } > INT47 type = VECT_INIT
    TIMER1_A1    : { * ( .int48 ) } > INT48 type = VECT_INIT
    TIMER1_A0    : { * ( .int49 ) } > INT49 type = VECT_INIT
    DMA          : { * ( .int50 ) } > INT50 type = VECT_INIT
    USCI_B2      : { * ( .int51 ) } > INT51 type = VECT_INIT
    USCI_A2      : { * ( .int52 ) } > INT52 type = VECT_INIT
    TIMER0_A1    : { * ( .int53 ) } > INT53 type = VECT_INIT
    TIMER0_A0    : { * ( .int54 ) } > INT54 type = VECT_INIT
    ADC12        : { * ( .int55 ) } > INT55 type = VECT_INIT
    USCI_B0      : { * ( .int56 ) } > INT56 type = VECT_INIT
    USCI_A0      : { * ( .int57 ) } > INT57 type = VECT_INIT
    WDT          : { * ( .int58 ) } > INT58 type = VECT_INIT
    TIMER0_B1    : { * ( .int59 ) } > INT59 type = VECT_INIT
    TIMER0_B0    : { * ( .int60 ) } > INT60 type = VECT_INIT
    UNMI         : { * ( .int61 ) } > INT61 type = VECT_INIT
    SYSNMI       : { * ( .int62 ) } > INT62 type = VECT_INIT
    .reset       : {}               > RESET  /* MSP430 Reset vector         */
}

/****************************************************************************/
/* Include peripherals memory map                                           */
/****************************************************************************/

-l msp430f5419a.cmd

