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
#define USER_TEST_ORIGIN 0x5E00

#define TEST_LEN 0x2600
#define MTEST_LEN 0x1400
#define SHELL_LEN 0x2600

#define LIBRARY_ORIGIN 0xBE00
#define LIBRARY_LEN 0x2800

#define USER_FLASH_ORIGIN 0x10200

#define METER_LEN 0x1C00
#define APP_LEN 0x1000
#define NFC_PROTOCOL_LEN 0x1200
#define RTC_ALARM_LEN 0xA00
#define MAIN_LEN 0x400
#define DATA_FLASH_LEN 0x1A00
#define UART_LEN 0xE00
#define NFC_I2C_LEN 0xC00
#define FLASH_DRIVER_LEN 0xC00
#define LCD_DRIVER_LEN 0x600
#define FLASH_UTIL_LEN 0x400
#define BATTERY_LEN 0x200
#define METER_MISC_LEN 0x200
#define OSAL_TIMER_LEN 0x400
#define TASK_MGR_LEN 0x200
#define NB_PROCESS_LEN 0x2000
#define NB_RESPONSE_LEN 0x1800
#define MESSAGE_LEN 0x1400
#define MODEM_LEN 0x1000


/* RAM */
#define RAM_ORIGIN 0x1C00

#define FOTA_LEN 0x1000
#define NOINIT_LEN 0x80
#define PROC_BSS_LEN 0x300
#define STATIC_BSS_LEN 0xB0
#define FOTA_DATA_LEN 0xF0
#define METER_BSS_LEN 0x260
#define MODEM_DATA_LEN 0x3A0
#define DATA_RAM_LEN 0x1A0

MEMORY
{
    SFR                     : origin = 0x0000, length = 0x0010
    PERIPHERALS_8BIT        : origin = 0x0010, length = 0x00F0
    PERIPHERALS_16BIT       : origin = 0x0100, length = 0x0100
    FOTA_RAM                : origin = RAM_ORIGIN, length = FOTA_LEN
    NOINIT_RAM              : origin = end(FOTA_RAM), length = NOINIT_LEN
    NB_PROC_BSS             : origin = end(NOINIT_RAM), length = PROC_BSS_LEN
    OTHER_BSS               : origin = end(NB_PROC_BSS), length = STATIC_BSS_LEN
    FOTA_DATA               : origin = end(OTHER_BSS), length = FOTA_DATA_LEN
    METER_BSS               : origin = end(FOTA_DATA), length = METER_BSS_LEN
    MODEM_BSS               : origin = end(METER_BSS), length = MODEM_DATA_LEN
    DATA_RAM                : origin = end(MODEM_BSS), length = DATA_RAM_LEN
    RAM                     : origin = end(DATA_RAM), length = 0x3CC0 - end(DATA_RAM)
    HEAP                    : origin = 0x3CC0, length = 0xFA0
    STACK                   : origin = 0x4C60, length = 0xFA0
    INFOA                   : origin = 0x1980, length = 0x0080
    INFOB                   : origin = 0x1900, length = 0x0080
    INFOC                   : origin = 0x1880, length = 0x0080
    INFOD                   : origin = 0x1800, length = 0x0080
    MAIN_CODE	        	: origin = 0x5C00, length = 0x0200
    TEST                    : origin = 0x5E00, length = TEST_LEN
    MTEST                   : origin = end(TEST), length = MTEST_LEN
    SHELL                   : origin = end(MTEST), length = SHELL_LEN
    LIBRARY                 : origin = LIBRARY_ORIGIN, length = LIBRARY_LEN
    FLASHB                  : origin = end(LIBRARY), length = 0xFFD2 - end(LIBRARY)
    METER                   : origin = USER_FLASH_ORIGIN, length = METER_LEN
    APP                     : origin = end(METER), length = APP_LEN
    NFC_PROTOCOL            : origin = end(APP), length = NFC_PROTOCOL_LEN
    RTC_ALARM               : origin = end(NFC_PROTOCOL), length = RTC_ALARM_LEN
    MAIN_TEXT               : origin = end(RTC_ALARM), length = MAIN_LEN
    DATA_FLASH              : origin = end(MAIN_TEXT), length = DATA_FLASH_LEN
    UART                    : origin = end(DATA_FLASH), length = UART_LEN
    NFC_I2C                 : origin = end(UART), length = NFC_I2C_LEN
    FLASH_DRIVER            : origin = end(NFC_I2C), length = FLASH_DRIVER_LEN
    LCD_DRIVER              : origin = end(FLASH_DRIVER), length = LCD_DRIVER_LEN
    FLASH_UTIL              : origin = end(LCD_DRIVER), length = FLASH_UTIL_LEN
    BATTERY                 : origin = end(FLASH_UTIL), length = BATTERY_LEN
    METER_MISC              : origin = end(BATTERY), length = METER_MISC_LEN
    OSAL_TIMER              : origin = end(METER_MISC), length = OSAL_TIMER_LEN
    TASK_MGR                : origin = end(OSAL_TIMER), length = TASK_MGR_LEN
    MODEM                   : origin = end(TASK_MGR), length = MODEM_LEN
    NB_RESPONSE             : origin = end(MODEM), length = NB_RESPONSE_LEN
    MESSAGE                 : origin = end(NB_RESPONSE), length = MESSAGE_LEN
    NB_PROCESS              : origin = end(MESSAGE), length = 0x20000 - end(MESSAGE)
    FOTA_FLASH              : origin = 0x20200, length = FOTA_LEN
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
#define RAM_ALIGN 32
#define SMALL_ALIGN 64
#define CODE_ALIGN 512

    .nbiotProcess_bss : {
        nbiotProcess.obj (.bss:ul_data), . = align(RAM_ALIGN);
        nbiotProcess.obj (.bss:raw_data), . = align(RAM_ALIGN);
        nbiotProcess.obj (.bss:StepFlowIndex)
    } > NB_PROC_BSS

    .static_bss : {
        NFC_i2c.obj (.bss:RxBuffer), . = align(RAM_ALIGN);
        NFC_i2c.obj (.bss:TxBuffer), . = align(RAM_ALIGN);
        rtcAlarm.obj (.bss:AlarmList), . = align(RAM_ALIGN);
        rtcAlarm.obj (.bss:TimeSyncDate), . = align(RAM_ALIGN);
        battery.obj (.bss:BattAdcBuffer), . = align(RAM_ALIGN);
        lcdDriver.obj (.bss:currentLCD)
    } > OTHER_BSS

    .fota_data : {
        fota.obj (.bss:fotaPort), . = align(RAM_ALIGN);
        fota.obj (.bss:initialMsgSize), . = align(RAM_ALIGN);
        fota.obj (.bss:socket), . = align(RAM_ALIGN);
        fota.obj (.data:Fota)
    } > FOTA_DATA

    .meter_bss : {
        meter.obj (.bss:StoredMeterData)
    } > METER_BSS

    .modem_data : {
        modem.obj (.data:modem), . = align(RAM_ALIGN);
        modem.obj (.data:modemComm)
    } > MODEM_BSS

    .data_ram : {
        --library=rts430x_lc_ld_eabi.lib (.data:_tz)
        --library=rts430x_lc_ld_eabi.lib (.data:_lock)
        --library=rts430x_lc_ld_eabi.lib (.data:_unlock)
        nfcProtocol.obj (.data:nfcAsyncRx), . = align(RAM_ALIGN);
        md5.obj (.data:PADDING), . = align(RAM_ALIGN);
        mTest.obj (.data:modemTestCtx), . = align(RAM_ALIGN);
        modem.obj (.data:modemCtx), . = align(RAM_ALIGN);
        meter.obj (.data:TempMeterData), . = align(RAM_ALIGN);
        flashDriver.obj (.data:FlashAddr), . = align(RAM_ALIGN);
        app.obj (.data:Metering)
    } > DATA_RAM

    .data : {
        rts430x_lc_ld_eabi.lib (.data), . = align(RAM_ALIGN);
        osal_Timer.obj (.data), . = align(RAM_ALIGN);
        rtcAlarm.obj (.data), . = align(RAM_ALIGN);
        Task_Mgr.obj (.data), . = align(RAM_ALIGN);
        battery.obj (.data), . = align(RAM_ALIGN);
        lcdDriver.obj (.data:lcdCon), . = align(RAM_ALIGN);
        main.obj (.data), . = align(RAM_ALIGN);
        test.obj (.data), . = align(RAM_ALIGN);
        fota.obj (.data), . = align(RAM_ALIGN);
        shell.obj (.data), . = align(RAM_ALIGN);
        uart.obj (.data), . = align(RAM_ALIGN);
        modem.obj (.data), . = align(RAM_ALIGN);
        app.obj (.data), . = align(RAM_ALIGN);
        nbiotResponse.obj (.data), . = align(RAM_ALIGN);
        nfcProtocol.obj (.data), . = align(RAM_ALIGN);
        nbiotProcess.obj (.data), . = align(RAM_ALIGN);
        *(.data)
    } > RAM              /* Global vars              */
    .bss        : align(CODE_ALIGN) {} > RAM (HIGH)             /* Global & static vars              */
    .TI.noinit  : {} > NOINIT_RAM           /* For #pragma noinit                */
    .sysmem     : {} > HEAP                 /* Dynamic memory allocation area    */
    .stack      : {} > STACK                /* Software system stack             */
    MAIN		: align(CODE_ALIGN) {} > MAIN_CODE


    .test_text : align(CODE_ALIGN) fill=0xFF {
        test.obj (.text:TEST_pmrsn), .=align(SMALL_ALIGN);
        test.obj (.text:TEST_readMeter), .=align(SMALL_ALIGN);
        test.obj (.text:TEST_pmwsn), .=align(SMALL_ALIGN);
        test.obj (.text:TEST_writeMeter), .=align(SMALL_ALIGN);
        test.obj (.text:TEST_setMeterType), .=align(SMALL_ALIGN);
        test.obj (.text:saveTerminalConfig), .=align(SMALL_ALIGN);
        test.obj (.text:TEST_run), .=align(SMALL_ALIGN);
        test.obj (.text:TEST_readFlash), .=align(SMALL_ALIGN);
        test.obj (.text:TEST_pmeter), .=align(SMALL_ALIGN);
        test.obj (.text:TEST_lpm3), .=align(SMALL_ALIGN);
        test.obj (.text:TEST_runTasks), .=align(SMALL_ALIGN);
        test.obj (.text:TEST_meteringParamer), .=align(SMALL_ALIGN);
        test.obj (.text:TEST_readBattery), .=align(SMALL_ALIGN);
        test.obj (.text:TEST_prsn), .=align(SMALL_ALIGN);
        test.obj (.text:TEST_resetNFC), .=align(SMALL_ALIGN);
        test.obj (.text:TEST_lpm2), .=align(SMALL_ALIGN);
        test.obj (.text:TEST_pwmeter), .=align(SMALL_ALIGN);
        test.obj (.text:TEST_readRTC), .=align(SMALL_ALIGN);
        test.obj (.text:TEST_setRTC), .=align(SMALL_ALIGN);
        test.obj (.text:TEST_riCtrlMode), .=align(SMALL_ALIGN);
        test.obj (.text:TEST_writeSerialNum), .=align(SMALL_ALIGN);
        test.obj (.text:TEST_readSerialNum), .=align(SMALL_ALIGN);
        test.obj (.text:TEST_debugPrint), .=align(SMALL_ALIGN);
        test.obj (.text:TEST_shortInterval), .=align(SMALL_ALIGN);
        test.obj (.text:TEST_sleepMode), .=align(SMALL_ALIGN);
        test.obj (.text:TEST_eraseFlash), .=align(SMALL_ALIGN);
        test.obj (.text:TEST_lcd), .=align(SMALL_ALIGN);
        test.obj (.text:interruptTask), .=align(SMALL_ALIGN);
        test.obj (.text:TEST_reedSensor), .=align(SMALL_ALIGN);
        test.obj (.text:TEST_checkNFC), .=align(SMALL_ALIGN);
        test.obj (.text:TEST_checkTestMode), .=align(SMALL_ALIGN);
        test.obj (.text:TEST_pwsn), .=align(SMALL_ALIGN);
        test.obj (.text:TEST_meterLCD), .=align(SMALL_ALIGN);
        test.obj (.text:TEST_readFwVersion), .=align(SMALL_ALIGN);
        test.obj (.text:TEST_stop), .=align(SMALL_ALIGN);
        test.obj (.text:reedResponse), .=align(SMALL_ALIGN);
        test.obj (.text:TEST_config)
    } > TEST

    .test_const : align(CODE_ALIGN) fill=0xff {
        test.obj (.const:.string), .=align(SMALL_ALIGN);
        test.obj (.const:TestTasksArray)
    } > TEST (HIGH)

    .mtest_text : align(CODE_ALIGN) fill=0xff {
        mTest.obj (.text:TEST_prnbid), .=align(SMALL_ALIGN);
        mTest.obj (.text:parseNbiotModemResp), .=align(SMALL_ALIGN);
        mTest.obj (.text:printAtCmdList), .=align(SMALL_ALIGN);
        mTest.obj (.text:TEST_modemResponse), .=align(SMALL_ALIGN);
        mTest.obj (.text:TEST_modem), .=align(SMALL_ALIGN);
        mTest.obj (.text:TEST_pnbctx), .=align(SMALL_ALIGN);
        mTest.obj (.text:waitModemBipOk), .=align(SMALL_ALIGN);
        mTest.obj (.text:waitModemReady), .=align(SMALL_ALIGN);
        mTest.obj (.text:waitModemAck), .=align(SMALL_ALIGN);
        mTest.obj (.text:TEST_pwserver), .=align(SMALL_ALIGN);
        mTest.obj (.text:TEST_prserver), .=align(SMALL_ALIGN);
        mTest.obj (.text:TEST_prfota), .=align(SMALL_ALIGN);
        mTest.obj (.text:TEST_pwfota), .=align(SMALL_ALIGN);
        mTest.obj (.text:sendToModem), .=align(SMALL_ALIGN);
        mTest.obj (.text:TEST_pmodem), .=align(SMALL_ALIGN);
        mTest.obj (.text:waitModem), .=align(SMALL_ALIGN);
        mTest.obj (.text:TEST_initModem), .=align(SMALL_ALIGN);
        mTest.obj (.text:resetModem)
    } > MTEST

    .mtest_const : align(CODE_ALIGN) fill=0xff {
        mTest.obj (.const:.string)
    } > MTEST (HIGH)

    .shell_text : align(CODE_ALIGN) fill=0xff {
        shell.obj (.text:SHELL_run), .=align(SMALL_ALIGN);
        shell.obj (.text:SHELL_gets), .=align(SMALL_ALIGN);
        shell.obj (.text:SHELL_getChar), .=align(SMALL_ALIGN);
        shell.obj (.text:help), .=align(SMALL_ALIGN);
        shell.obj (.text:getArguments), .=align(SMALL_ALIGN);
        shell.obj (.text:whatCommand), .=align(SMALL_ALIGN);
        shell.obj (.text:SHELL_decimal), .=align(SMALL_ALIGN);
        shell.obj (.text:SHELL_init), .=align(SMALL_ALIGN);
        shell.obj (.text:SHELL_string)
    } > SHELL

    .shell_const : align(CODE_ALIGN) {
        shell.obj (.const:.string), .=align(SMALL_ALIGN);
        shell.obj (.const:CmdSet)
    } > SHELL (HIGH)

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
    } > LIBRARY

    .library_const : align(CODE_ALIGN) {
        --library=rts430x_lc_ld_eabi.lib (.const:.string:_ctypes_), .=align(SMALL_ALIGN);
        --library=rts430x_lc_ld_eabi.lib (.const:mon_len), .=align(SMALL_ALIGN);
        --library=rts430x_lc_ld_eabi.lib (.const:mon_day), .=align(SMALL_ALIGN);
        --library=rts430x_lc_ld_eabi.lib (.const:.string)
    } > LIBRARY (HIGH)

    .md5_text : align(CODE_ALIGN) {
        md5.obj (.text)
    } > MD5

    .uuid_text : align(CODE_ALIGN) {
        uuid.obj (.text)
    } > MD5 (HIGH)

    .meter_text : align(CODE_ALIGN) {
        meter.obj (.text)
    } > METER

    .meter_const : align(CODE_ALIGN) {
        meter.obj (.const)
    } > METER (HIGH)

    .app_text : align(CODE_ALIGN) {
        app.obj (.text)
    } > APP

    .app_const : align(CODE_ALIGN) {
        app.obj (.const)
    } > APP (HIGH)

    nfcProtocol_text : align(CODE_ALIGN) {
        nfcProtocol.obj (.text)
    } > NFC_PROTOCOL

    nfcProtocol_const : align(CODE_ALIGN) {
        nfcProtocol.obj (.const)
    } > NFC_PROTOCOL (HIGH)

    rtcAlarm_text : align(CODE_ALIGN) {
        rtcAlarm.obj (.text)
    } > RTC_ALARM

    rtcAlarm_const : align(CODE_ALIGN) {
        rtcAlarm.obj (.const)
    } > RTC_ALARM (HIGH)

    main_text : align(CODE_ALIGN) {
        main.obj (.text)
    } > MAIN_TEXT

    dataFlash_text : align(CODE_ALIGN) {
        dataFlash.obj (.text)
    } > DATA_FLASH

    dataFlash_const : align(CODE_ALIGN) {
        dataFlash.obj (.const)
    } > DATA_FLASH (HIGH)

    uart_text : align(CODE_ALIGN) {
        uart.obj (.text)
    } > UART

    uart_const : align(CODE_ALIGN) {
        uart.obj (.const)
    } > UART (HIGH)

    nfci2c_text : align(CODE_ALIGN) {
        NFC_i2c.obj (.text)
    } > NFC_I2C

    nfci2c_const : align(CODE_ALIGN) {
        NFC_i2c.obj (.const)
    } > NFC_I2C (HIGH)

    flashDriver_text : align(CODE_ALIGN) {
        flashDriver.obj (.text)
    } > FLASH_DRIVER

    flashDriver_const : align(CODE_ALIGN) {
        flashDriver.obj (.const)
    } > FLASH_DRIVER (HIGH)

    lcdDriver_text : align(CODE_ALIGN) {
        lcdDriver.obj (.text)
    } > LCD_DRIVER

    lcdDriver_const : align(CODE_ALIGN) {
        lcdDriver.obj (.const)
    } > LCD_DRIVER (HIGH)

    flashUtil_text : align(CODE_ALIGN) {
        MSP430FlashUtil.obj (.text)
    } > FLASH_UTIL

    flashUtil_const : align(CODE_ALIGN) {
        MSP430FlashUtil.obj (.const)
    } > FLASH_UTIL (HIGH)

    battery_text : align(CODE_ALIGN) {
        battery.obj (.text)
    } > BATTERY

    meterMisc_text : align(CODE_ALIGN) {
        check_meter_misc.obj (.text)
    } > METER_MISC

    osalTimer_text : align(CODE_ALIGN) {
        osal_Timer.obj (.text)
    } > OSAL_TIMER

    osalTimer_const : align(CODE_ALIGN) {
        osal.obj (.text)
        osal_Timer.obj (.const)
    } > OSAL_TIMER (HIGH)

    taskMgr_text : align(CODE_ALIGN) {
        Task_Mgr.obj (.text)
    } > TASK_MGR

    taskMgr_const : {
        Task_Mgr.obj (.const)
    } > TASK_MGR (HIGH)

    modem_text : align(CODE_ALIGN) {
        modem.obj (.text)
    } > MODEM

    modem_const : align(CODE_ALIGN) {
        modem.obj (.const)
    } > MODEM (HIGH)

    nbiotResponse_text : align(CODE_ALIGN) {
        nbiotResponse.obj (.text)
    } > NB_RESPONSE

    nbiotResponse_const : align(CODE_ALIGN) {
        nbiotResponse.obj (.const)
    } > NB_RESPONSE (HIGH)

    message_text : align(CODE_ALIGN) {
        message.obj (.text)
    } > MESSAGE

    message_const : align(CODE_ALIGN) {
        message.obj (.const)
    } > MESSAGE (HIGH)

    nbiotProcess_text : align(CODE_ALIGN) {
        nbiotProcess.obj (.text)
    } > NB_PROCESS

    nbiotProcess_const : align(CODE_ALIGN) {
        nbiotProcess.obj (.const)
    } > NB_PROCESS (HIGH)

    int00_section : > FLASHB(HIGH)
    {
         --library=rts430x_lc_ld_eabi.lib(.text:_isr:_c_int00_noargs)
    }

    ram_code {
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
    } load=FOTA_FLASH, run=FOTA_RAM

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

