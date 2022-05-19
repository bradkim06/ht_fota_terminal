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

#define TEST_LEN 0x2400
#define MTEST_LEN 0x1400
#define SHELL_LEN 0x2400

#define LIBRARY_LEN 0x2600
#define NFC_PROTOCOL_LEN 0x1600

#define USER_FLASH_ORIGIN 0x10200

#define METER_LEN 0x2200
#define APP_LEN 0x1000
#define RTC_ALARM_LEN 0xE00
#define MAIN_LEN 0x200
#define DATA_FLASH_LEN 0x1E00
#define UART_LEN 0xE00
#define FLASH_DRIVER_LEN 0xE00
#define LCD_DRIVER_LEN 0x800
#define FLASH_UTIL_LEN 0x400
#define BATTERY_LEN 0x400
#define METER_MISC_LEN 0x200
#define OSAL_TIMER_LEN 0x600
#define TASK_MGR_LEN 0x400
#define NB_PROCESS_LEN 0x2000
#define NB_RESPONSE_LEN 0x1A00
#define MESSAGE_LEN 0x1800
#define MODEM_LEN 0x1600

#define USER_FLASH_ORIGIN2 0x20200
#define NFC_I2C_LEN 0xE00


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
    MAIN_CODE	        	: origin = 0x5C00, length = 0x400
    TEST                    : origin = end(MAIN_CODE), length = TEST_LEN
    MTEST                   : origin = end(TEST), length = MTEST_LEN
    SHELL                   : origin = end(MTEST), length = SHELL_LEN
    LIBRARY                 : origin = end(SHELL), length = LIBRARY_LEN
    BATTERY                 : origin = end(LIBRARY), length = BATTERY_LEN
    NFC_PROTOCOL            : origin = end(BATTERY), length = NFC_PROTOCOL_LEN
    FLASHB                  : origin = end(NFC_PROTOCOL), length = 0xFFD2 - end(NFC_PROTOCOL)
    METER                   : origin = USER_FLASH_ORIGIN, length = METER_LEN
    DATA_FLASH              : origin = end(METER), length = DATA_FLASH_LEN
    APP                     : origin = end(DATA_FLASH), length = APP_LEN
    RTC_ALARM               : origin = end(APP), length = RTC_ALARM_LEN
    UART                    : origin = end(RTC_ALARM), length = UART_LEN
    FLASH_DRIVER            : origin = end(UART), length = FLASH_DRIVER_LEN
    LCD_DRIVER              : origin = end(FLASH_DRIVER), length = LCD_DRIVER_LEN
    FLASH_UTIL              : origin = end(LCD_DRIVER), length = FLASH_UTIL_LEN
    METER_MISC              : origin = end(FLASH_UTIL), length = METER_MISC_LEN
    OSAL_TIMER              : origin = end(METER_MISC), length = OSAL_TIMER_LEN
    TASK_MGR                : origin = end(OSAL_TIMER), length = TASK_MGR_LEN
    MODEM                   : origin = end(TASK_MGR), length = MODEM_LEN
    NB_RESPONSE             : origin = end(MODEM), length = NB_RESPONSE_LEN
    MESSAGE                 : origin = end(NB_RESPONSE), length = MESSAGE_LEN
    NB_PROCESS              : origin = end(MESSAGE), length = 0x20000 - end(MESSAGE)
    FOTA_FLASH              : origin = USER_FLASH_ORIGIN2, length = FOTA_LEN
    MD5                     : origin = end(FOTA_FLASH), length = 0x1000
    NFC_I2C                 : origin = end(MD5), length = NFC_I2C_LEN
    FLASHD                  : origin = end(NFC_I2C),length = 0x23400 - end(NFC_I2C)
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
    main_text : align(512) {
        main.obj (.text)
    } > MAIN_CODE

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
        test.obj (.const:TestTasksArray), .=align(SMALL_ALIGN);
        test.obj (.const:.string)
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
    } > SHELL (HIGH)

    .shell_const : align(CODE_ALIGN) {
        shell.obj (.const:CmdSet), .=align(SMALL_ALIGN);
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
        nfcProtocol.obj (.text:recvNodeConfSetV3), . = align(SMALL_ALIGN);
        nfcProtocol.obj (.text:recvBdControlReq), . = align(SMALL_ALIGN);
        nfcProtocol.obj (.text:sendMeterReport), . = align(SMALL_ALIGN);
        nfcProtocol.obj (.text:sendNodeConfReportV3), . = align(SMALL_ALIGN);
        nfcProtocol.obj (.text:sendBdControlAck), . = align(SMALL_ALIGN);
        nfcProtocol.obj (.text:NFCAPP_meterAdjustResp), . = align(SMALL_ALIGN);
        nfcProtocol.obj (.text:NFCAPP_meterAdjustReq), . = align(SMALL_ALIGN);
        nfcProtocol.obj (.text:sendServerConnectReport), . = align(SMALL_ALIGN);
        nfcProtocol.obj (.text:NFCAPP_runMessage), . = align(SMALL_ALIGN);
        nfcProtocol.obj (.text:recvNbiotIdSet), . = align(SMALL_ALIGN);
        nfcProtocol.obj (.text:recvFwUpdateReq), . = align(SMALL_ALIGN);
        nfcProtocol.obj (.text:recvFlashDataReq), . = align(SMALL_ALIGN);
        nfcProtocol.obj (.text:setRtcV1), . = align(SMALL_ALIGN);
        nfcProtocol.obj (.text:recvFlashDateListReq), . = align(SMALL_ALIGN);
        nfcProtocol.obj (.text:sendFwUpdateResp), . = align(SMALL_ALIGN);
        nfcProtocol.obj (.text:sendDeviceInfo), . = align(SMALL_ALIGN);
        nfcProtocol.obj (.text:send), . = align(SMALL_ALIGN);
        nfcProtocol.obj (.text:sendNbiotIdReport), . = align(SMALL_ALIGN);
        nfcProtocol.obj (.text:sendMeterAdjustError), . = align(SMALL_ALIGN);
        nfcProtocol.obj (.text:copyToAsyncCmd), . = align(SMALL_ALIGN);
        nfcProtocol.obj (.text:jumpToBSL), . = align(SMALL_ALIGN);
        nfcProtocol.obj (.text:readRtcV1), . = align(SMALL_ALIGN);
        nfcProtocol.obj (.text:sendFwVerReport), . = align(SMALL_ALIGN);
        nfcProtocol.obj (.text:NFCAPP_continueSend), . = align(SMALL_ALIGN);
        nfcProtocol.obj (.text:dev_clock_internal), . = align(SMALL_ALIGN);
        nfcProtocol.obj (.text:recvMeterAdjustRequest), . = align(SMALL_ALIGN);
        nfcProtocol.obj (.text:NFCAPP_clearAsyncCmd), . = align(SMALL_ALIGN);
        nfcProtocol.obj (.text:recvMeterReq), . = align(SMALL_ALIGN);
        nfcProtocol.obj (.text:recvServerConnectReq), . = align(SMALL_ALIGN);
        nfcProtocol.obj (.text:disable_OFIE), . = align(SMALL_ALIGN);
        nfcProtocol.obj (.text:getMyDeviceCode)
    } > NFC_PROTOCOL

    nfcProtocol_const : align(CODE_ALIGN) {
        nfcProtocol.obj (.const:.string)
    } > NFC_PROTOCOL (HIGH)

    .meter_text : align(CODE_ALIGN) {
        meter.obj (.text:read_onetl_meter), . = align(SMALL_ALIGN);
        meter.obj (.text:read_shinhan_d_meter), . = align(SMALL_ALIGN);
        meter.obj (.text:METER_collectStoredData), . = align(SMALL_ALIGN);
        meter.obj (.text:read_mns_d_meter), . = align(SMALL_ALIGN);
        meter.obj (.text:METER_addStoredData), . = align(SMALL_ALIGN);
        meter.obj (.text:METER_displayStoredData), . = align(SMALL_ALIGN);
        meter.obj (.text:read_std_d_meter), . = align(SMALL_ALIGN);
        meter.obj (.text:METER_enable), . = align(SMALL_ALIGN);
        meter.obj (.text:METER_displayTempData), . = align(SMALL_ALIGN);
        meter.obj (.text:METER_std_adjustReq), . = align(SMALL_ALIGN);
        meter.obj (.text:METER_ontel_sendRequest), . = align(SMALL_ALIGN);
        meter.obj (.text:METER_std_adjustResp), . = align(SMALL_ALIGN);
        meter.obj (.text:METER_recvResponse), . = align(SMALL_ALIGN);
        meter.obj (.text:checkInterval), . = align(SMALL_ALIGN);
        meter.obj (.text:METER_getMeterName), . = align(SMALL_ALIGN);
        meter.obj (.text:METER_bypassReq), . = align(SMALL_ALIGN);
        meter.obj (.text:METER_addTempData), . = align(SMALL_ALIGN);
        meter.obj (.text:METER_clearIntervalData), . = align(SMALL_ALIGN);
        meter.obj (.text:METER_needNewMetering), . = align(SMALL_ALIGN);
        meter.obj (.text:METER_std_lcdMarkReq), . = align(SMALL_ALIGN);
        meter.obj (.text:METER_bypassResp), . = align(SMALL_ALIGN);
        meter.obj (.text:METER_std_lcdTestReq), . = align(SMALL_ALIGN);
        meter.obj (.text:METER_std_configRequest), . = align(SMALL_ALIGN);
        meter.obj (.text:METER_std_sendRequest), . = align(SMALL_ALIGN);
        meter.obj (.text:METER_saveInFlash), . = align(SMALL_ALIGN);
        meter.obj (.text:METER_sendRequest), . = align(SMALL_ALIGN);
        meter.obj (.text:METER_shinhan_sendRequest), . = align(SMALL_ALIGN);
        meter.obj (.text:METER_saveMeterInfo), . = align(SMALL_ALIGN);
        meter.obj (.text:METER_mns_sendRequest), . = align(SMALL_ALIGN);
        meter.obj (.text:METER_clearStoredData), . = align(SMALL_ALIGN);
        meter.obj (.text:METER_getFirstValidPos), . = align(SMALL_ALIGN);
        meter.obj (.text:hex2int), . = align(SMALL_ALIGN);
        meter.obj (.text:METER_disable), . = align(SMALL_ALIGN);
        meter.obj (.text:METER_getMeterData), . = align(SMALL_ALIGN);
        meter.obj (.text:METER_getMeterStatus), . = align(SMALL_ALIGN);
        meter.obj (.text:METER_deleteStoredData), . = align(SMALL_ALIGN);
        meter.obj (.text:METER_isAllFF), . = align(SMALL_ALIGN);
        meter.obj (.text:METER_deleteTempData), . = align(SMALL_ALIGN);
        meter.obj (.text:METER_deleteAllData), . = align(SMALL_ALIGN);
        meter.obj (.text:METER_getLastData), . = align(SMALL_ALIGN);
        meter.obj (.text:METER_getMeterCaliber_dp), . = align(SMALL_ALIGN);
        meter.obj (.text:METER_getNumberOfStoredData), . = align(SMALL_ALIGN);
        meter.obj (.text:METER_getSaveInterval), . = align(SMALL_ALIGN);
        meter.obj (.text:METER_getSerialNum), . = align(SMALL_ALIGN);
        meter.obj (.text:METER_getTempData)
    } > METER

    .meter_const : align(CODE_ALIGN) {
        meter.obj (.const:$P$T0$1), . = align(SMALL_ALIGN);
        meter.obj (.const:.string)
    } > METER (HIGH)

    dataFlash_text : align(CODE_ALIGN) {
        dataFlash.obj (.text:get_dataSavePos), . = align(SMALL_ALIGN);
        dataFlash.obj (.text:dataFlash_sendData), . = align(SMALL_ALIGN);
        dataFlash.obj (.text:make_dateList), . = align(SMALL_ALIGN);
        dataFlash.obj (.text:saveData), . = align(SMALL_ALIGN);
        dataFlash.obj (.text:read_dataSector), . = align(SMALL_ALIGN);
        dataFlash.obj (.text:fix_mapSector), . = align(SMALL_ALIGN);
        dataFlash.obj (.text:print_dataReport), . = align(SMALL_ALIGN);
        dataFlash.obj (.text:dataFlash_displayDataSector), . = align(SMALL_ALIGN);
        dataFlash.obj (.text:dataFlash_displayMapSector), . = align(SMALL_ALIGN);
        dataFlash.obj (.text:make_nfcDataReport), . = align(SMALL_ALIGN);
        dataFlash.obj (.text:readAndSort_map), . = align(SMALL_ALIGN);
        dataFlash.obj (.text:verifySectors), . = align(SMALL_ALIGN);
        dataFlash.obj (.text:dataFlash_save), . = align(SMALL_ALIGN);
        dataFlash.obj (.text:read_mapSector), . = align(SMALL_ALIGN);
        dataFlash.obj (.text:writeSector), . = align(SMALL_ALIGN);
        dataFlash.obj (.text:dataFlash_readData), . = align(SMALL_ALIGN);
        dataFlash.obj (.text:dataFlash_getList), . = align(SMALL_ALIGN);
        dataFlash.obj (.text:read_dataUnit), . = align(SMALL_ALIGN);
        dataFlash.obj (.text:eraseSector), . = align(SMALL_ALIGN);
        dataFlash.obj (.text:readSector), . = align(SMALL_ALIGN);
        dataFlash.obj (.text:dataFlash_eraseSector), . = align(SMALL_ALIGN);
        dataFlash.obj (.text:hex2binary), . = align(SMALL_ALIGN);
        dataFlash.obj (.text:isValidMeterValue), . = align(SMALL_ALIGN);
        dataFlash.obj (.text:get_flashAddress), . = align(SMALL_ALIGN);
        dataFlash.obj (.text:isValidDate), . = align(SMALL_ALIGN);
        dataFlash.obj (.text:cal_checksum), . = align(SMALL_ALIGN);
        dataFlash.obj (.text:waitIdle), . = align(SMALL_ALIGN);
        dataFlash.obj (.text:dataFlash_init), . = align(SMALL_ALIGN);
        dataFlash.obj (.text:dataFlash_genData)
    } > DATA_FLASH

    dataFlash_const : align(CODE_ALIGN) {
        dataFlash.obj (.const:.string)
    } > DATA_FLASH (HIGH)

    .app_text : align(CODE_ALIGN) {
        app.obj (.text:APP_showConfig), . = align(SMALL_ALIGN);
        app.obj (.text:APP_tasks), . = align(SMALL_ALIGN);
        app.obj (.text:APP_init), . = align(SMALL_ALIGN);
        app.obj (.text:meteringRetry), . = align(SMALL_ALIGN);
        app.obj (.text:meteringUpdateData), . = align(SMALL_ALIGN);
        app.obj (.text:ctrlReportInterval), . = align(SMALL_ALIGN);
        app.obj (.text:APP_runMetering), . = align(SMALL_ALIGN);
        app.obj (.text:meteringCompleted), . = align(SMALL_ALIGN);
        app.obj (.text:meteringRecvResp), . = align(SMALL_ALIGN);
        app.obj (.text:APP_prepareToSleep), . = align(SMALL_ALIGN);
        app.obj (.text:REBOOT_SYSTEM), . = align(SMALL_ALIGN);
        app.obj (.text:APP_checkTimeInterval), . = align(SMALL_ALIGN);
        app.obj (.text:APP_runPeriodicReport), . = align(SMALL_ALIGN);
        app.obj (.text:meteringTimeout)
    } > APP

    .app_const : align(CODE_ALIGN) {
        app.obj (.const:.string)
    } > APP (HIGH)

    rtcAlarm_text : align(CODE_ALIGN) {
        rtcAlarm.obj (.text:RTC_Alarm_Scheduler_normal), . = align(SMALL_ALIGN);
        rtcAlarm.obj (.text:RTC_runAlarm), . = align(SMALL_ALIGN);
        rtcAlarm.obj (.text:RTC_calcSecDiff), . = align(SMALL_ALIGN);
        rtcAlarm.obj (.text:RTC_Alarm_Scheduler_short), . = align(SMALL_ALIGN);
        rtcAlarm.obj (.text:RTC_init), . = align(SMALL_ALIGN);
        rtcAlarm.obj (.text:RTC_incDateHour), . = align(SMALL_ALIGN);
        rtcAlarm.obj (.text:RTC_set), . = align(SMALL_ALIGN);
        rtcAlarm.obj (.text:rtcAlarmSet), . = align(SMALL_ALIGN);
        rtcAlarm.obj (.text:RTC_calcHourDiff), . = align(SMALL_ALIGN);
        rtcAlarm.obj (.text:RTC_isValidDate), . = align(SMALL_ALIGN);
        rtcAlarm.obj (.text:RTC_writeTime), . = align(SMALL_ALIGN);
        rtcAlarm.obj (.text:RTC_read), . = align(SMALL_ALIGN);
        rtcAlarm.obj (.text:RTC_needTimeSync), . = align(SMALL_ALIGN);
        rtcAlarm.obj (.text:setDefaultRTC), . = align(SMALL_ALIGN);
        rtcAlarm.obj (.text:RTC_alarmSchedule), . = align(SMALL_ALIGN);
        rtcAlarm.obj (.text:RTC_calcMinDiff), . = align(SMALL_ALIGN);
        rtcAlarm.obj (.text:RTC_isTimeSync)
    } > RTC_ALARM

    rtcAlarm_const : align(CODE_ALIGN) {
        rtcAlarm.obj (.const:$P$T0$1), . = align(SMALL_ALIGN);
        rtcAlarm.obj (.const:$P$T1$2), . = align(SMALL_ALIGN);
        rtcAlarm.obj (.const:.string:MaxDays), . = align(SMALL_ALIGN);
        rtcAlarm.obj (.const:.string)
    } > RTC_ALARM (HIGH)

    uart_text : align(CODE_ALIGN) {
        uart.obj (.text:UART_open), . = align(SMALL_ALIGN);
        uart.obj (.text:mallocUartBuf), . = align(SMALL_ALIGN);
        uart.obj (.text:UART_close), . = align(SMALL_ALIGN);
        uart.obj (.text:UART_send), . = align(SMALL_ALIGN);
        uart.obj (.text:printf_ts), . = align(SMALL_ALIGN);
        uart.obj (.text:UART_receive), . = align(SMALL_ALIGN);
        uart.obj (.text:printf), . = align(SMALL_ALIGN);
        uart.obj (.text:PRINT_string), . = align(SMALL_ALIGN);
        uart.obj (.text:UART_getChar), . = align(SMALL_ALIGN);
        uart.obj (.text:UART_debugMode), . = align(SMALL_ALIGN);
        uart.obj (.text:set_meterPortForBSL), . = align(SMALL_ALIGN);
        uart.obj (.text:UART_init), . = align(SMALL_ALIGN);
        uart.obj (.text:mallocBuf), . = align(SMALL_ALIGN);
        uart.obj (.text:fota_uart), . = align(SMALL_ALIGN);
        uart.obj (.text:PRINT_enable), . = align(SMALL_ALIGN);
        uart.obj (.text:PRINT_resume), . = align(SMALL_ALIGN);
        uart.obj (.text:PRINT_disable), . = align(SMALL_ALIGN);
        uart.obj (.text:PRINT_stop)
    } > UART

    uart_const : align(CODE_ALIGN) {
        uart.obj (.const:$P$T0$1), . = align(SMALL_ALIGN);
        uart.obj (.const:$P$T1$4), . = align(SMALL_ALIGN);
        uart.obj (.const:.string)
    } > UART (HIGH)

    flashDriver_text : align(CODE_ALIGN) {
        flashDriver.obj (.text:FLASH_readConfigInfo), . = align(SMALL_ALIGN);
        flashDriver.obj (.text:readConfig), . = align(SMALL_ALIGN);
        flashDriver.obj (.text:FLASH_saveConfigInfo), . = align(SMALL_ALIGN);
        flashDriver.obj (.text:readID), . = align(SMALL_ALIGN);
        flashDriver.obj (.text:saveConfig), . = align(SMALL_ALIGN);
        flashDriver.obj (.text:saveID), . = align(SMALL_ALIGN);
        flashDriver.obj (.text:distributingReportTime), . = align(SMALL_ALIGN);
        flashDriver.obj (.text:int2bcd), . = align(SMALL_ALIGN);
        flashDriver.obj (.text:bcd2int), . = align(SMALL_ALIGN);
        flashDriver.obj (.text:ip2hexArray), . = align(SMALL_ALIGN);
        flashDriver.obj (.text:FLASH_updateResetCount), . = align(SMALL_ALIGN);
        flashDriver.obj (.text:saveConfChecksum), . = align(SMALL_ALIGN);
        flashDriver.obj (.text:calChecksum)
    } > FLASH_DRIVER

    flashDriver_const : align(CODE_ALIGN) {
        flashDriver.obj (.const:.string)
    } > FLASH_DRIVER (HIGH)

    lcdDriver_text : align(CODE_ALIGN) {
        lcdDriver.obj (.text:LCD_displayValue), . = align(SMALL_ALIGN);
        lcdDriver.obj (.text:sendMsgToLCD), . = align(SMALL_ALIGN);
        lcdDriver.obj (.text:LCD_updateMeterValue), . = align(SMALL_ALIGN);
        lcdDriver.obj (.text:LCD_displayString), . = align(SMALL_ALIGN);
        lcdDriver.obj (.text:LCD_init), . = align(SMALL_ALIGN);
        lcdDriver.obj (.text:LCD_displayFirmwareVersion), . = align(SMALL_ALIGN);
        lcdDriver.obj (.text:LCD_enable), . = align(SMALL_ALIGN);
        lcdDriver.obj (.text:LCD_Exist), . = align(SMALL_ALIGN);
        lcdDriver.obj (.text:LCD_displayError), . = align(SMALL_ALIGN);
        lcdDriver.obj (.text:LCD_clear), . = align(SMALL_ALIGN);
        lcdDriver.obj (.text:LCD_displayAll), . = align(SMALL_ALIGN);
        lcdDriver.obj (.text:LCD_wait), . = align(SMALL_ALIGN);
        lcdDriver.obj (.text:LCD_disable), . = align(SMALL_ALIGN);
        lcdDriver.obj (.text:LCD_accessModem), . = align(SMALL_ALIGN);
        lcdDriver.obj (.text:lcdDataTx), . = align(SMALL_ALIGN);
        lcdDriver.obj (.text:LCD_redraw)
    } > LCD_DRIVER

    lcdDriver_const : align(CODE_ALIGN) {
        lcdDriver.obj (.const:$P$T0$1), . = align(SMALL_ALIGN);
        lcdDriver.obj (.const:.string)
    } > LCD_DRIVER (HIGH)

    flashUtil_text : align(CODE_ALIGN) {
        MSP430FlashUtil.obj (.text:MSP430FLASH_write), . = align(SMALL_ALIGN);
        MSP430FlashUtil.obj (.text:MSP430FLASH_erasePage), . = align(SMALL_ALIGN);
        MSP430FlashUtil.obj (.text:MSP430FLASH_read)
    } > FLASH_UTIL

    flashUtil_const : align(CODE_ALIGN) {
        MSP430FlashUtil.obj (.const:.string)
    } > FLASH_UTIL (HIGH)

    battery_text : align(CODE_ALIGN) {
        battery.obj (.text:readBatteryADC), . = align(SMALL_ALIGN);
        battery.obj (.text:BATT_getVoltage), . = align(SMALL_ALIGN);
        battery.obj (.text:addBatteryADC), . = align(SMALL_ALIGN);
        battery.obj (.text:BATT_getLevel), . = align(SMALL_ALIGN);
        battery.obj (.text:BATT_init), . = align(SMALL_ALIGN);
        battery.obj (.text:BATT_loadLastVoltage), . = align(SMALL_ALIGN);
        battery.obj (.text:BATT_getLastVoltage)
    } > BATTERY

    meterMisc_text : align(CODE_ALIGN) {
        check_meter_misc.obj (.text:MISC_NfcPortSelect), . = align(SMALL_ALIGN);
        check_meter_misc.obj (.text:MISC_getDeviceType), . = align(SMALL_ALIGN);
        check_meter_misc.obj (.text:MISC_getBslType), . = align(SMALL_ALIGN);
        check_meter_misc.obj (.text:MISC_delayUs)
    } > METER_MISC

    osalTimer_text : align(CODE_ALIGN) {
        osal_Timer.obj (.text:addEventTimer), . = align(SMALL_ALIGN);
        osal_Timer.obj (.text:OSAL_startEventTimer), . = align(SMALL_ALIGN);
        osal_Timer.obj (.text:delevtEventTimer), . = align(SMALL_ALIGN);
        osal_Timer.obj (.text:TIMER_getMsecDiff), . = align(SMALL_ALIGN);
        osal_Timer.obj (.text:OSAL_stopEventTimer), . = align(SMALL_ALIGN);
        osal_Timer.obj (.text:findEventTimer), . = align(SMALL_ALIGN);
        osal_Timer.obj (.text:TIMER_init), . = align(SMALL_ALIGN);
        osal_Timer.obj (.text:TIMER_getMsec), . = align(SMALL_ALIGN);
        osal_Timer.obj (.text:TIMER_start), . = align(SMALL_ALIGN);
        osal_Timer.obj (.text:TIMER_stop)
    } > OSAL_TIMER

    osalTimer_const : align(CODE_ALIGN) {
        osal.obj (.text:OSAL_setEvent), . = align(SMALL_ALIGN);
        osal_Timer.obj (.const:.string)
    } > OSAL_TIMER (HIGH)

    taskMgr_text : align(CODE_ALIGN) {
        Task_Mgr.obj (.text:TASKMGR_run), . = align(SMALL_ALIGN);
        Task_Mgr.obj (.text:TASKMGR_init)
    } > TASK_MGR

    taskMgr_const : {
        Task_Mgr.obj (.const:TasksArray), . = align(SMALL_ALIGN);
        Task_Mgr.obj (.const), . = align(SMALL_ALIGN);
        Task_Mgr.obj (.const:.string)
    } > TASK_MGR (HIGH)

    modem_text : align(CODE_ALIGN) {
        modem.obj (.text:MODEM_timeout), . = align(SMALL_ALIGN);
        modem.obj (.text:saveModemErrorLog), . = align(SMALL_ALIGN);
        modem.obj (.text:MODEM_stop), . = align(SMALL_ALIGN);
        modem.obj (.text:MODEM_close), . = align(SMALL_ALIGN);
        modem.obj (.text:MODEM_getStateOrResult), . = align(SMALL_ALIGN);
        modem.obj (.text:MODEM_read), . = align(SMALL_ALIGN);
        modem.obj (.text:MODEM_turnOff), . = align(SMALL_ALIGN);
        modem.obj (.text:MODEM_getAccessState), . = align(SMALL_ALIGN);
        modem.obj (.text:MODEM_write), . = align(SMALL_ALIGN);
        modem.obj (.text:MODEM_turnOn), . = align(SMALL_ALIGN);
        modem.obj (.text:MODEM_open), . = align(SMALL_ALIGN);
        modem.obj (.text:MODEM_copyCtn), . = align(SMALL_ALIGN);
        modem.obj (.text:str2BcdForImeiAndImsi), . = align(SMALL_ALIGN);
        modem.obj (.text:MODEM_initialization), . = align(SMALL_ALIGN);
        modem.obj (.text:MODEM_changeBaudrate), . = align(SMALL_ALIGN);
        modem.obj (.text:MODEM_copyIccid), . = align(SMALL_ALIGN);
        modem.obj (.text:MODEM_copyLastAccessTime), . = align(SMALL_ALIGN);
        modem.obj (.text:MODEM_sleep), . = align(SMALL_ALIGN);
        modem.obj (.text:MODEM_wakeup), . = align(SMALL_ALIGN);
        modem.obj (.text:MODEM_enable), . = align(SMALL_ALIGN);
        modem.obj (.text:MODEM_handler), . = align(SMALL_ALIGN);
        modem.obj (.text:MODEM_disable), . = align(SMALL_ALIGN);
        modem.obj (.text:MODEM_getLastRsrp), . = align(SMALL_ALIGN);
        modem.obj (.text:MODEM_getLastRsrq), . = align(SMALL_ALIGN);
        modem.obj (.text:MODEM_getLastRssi), . = align(SMALL_ALIGN);
        modem.obj (.text:MODEM_copyCseId), . = align(SMALL_ALIGN);
        modem.obj (.text:MODEM_getLastSNR), . = align(SMALL_ALIGN);
        modem.obj (.text:MODEM_copyImei), . = align(SMALL_ALIGN);
        modem.obj (.text:MODEM_copyImsi)
    } > MODEM

    modem_const : align(CODE_ALIGN) {
        modem.obj (.const:$P$T3$1), . = align(SMALL_ALIGN);
        modem.obj (.const:$P$T4$2), . = align(SMALL_ALIGN);
        modem.obj (.const:.string)
    } > MODEM (HIGH)

    nbiotResponse_text : align(CODE_ALIGN) {
        nbiotResponse.obj (.text:MODEM_response), . = align(SMALL_ALIGN);
        nbiotResponse.obj (.text:parse_fota_downlink), . = align(SMALL_ALIGN);
        nbiotResponse.obj (.text:parse_server_notify), . = align(SMALL_ALIGN);
        nbiotResponse.obj (.text:parse_radioQuality), . = align(SMALL_ALIGN);
        nbiotResponse.obj (.text:parse_imsi), . = align(SMALL_ALIGN);
        nbiotResponse.obj (.text:parse_bs_param), . = align(SMALL_ALIGN);
        nbiotResponse.obj (.text:parse_cclk), . = align(SMALL_ALIGN);
        nbiotResponse.obj (.text:parse_pf_downlink), . = align(SMALL_ALIGN);
        nbiotResponse.obj (.text:parseQGMR), . = align(SMALL_ALIGN);
        nbiotResponse.obj (.text:parse_lwm2m_server), . = align(SMALL_ALIGN);
        nbiotResponse.obj (.text:parse_ncdp), . = align(SMALL_ALIGN);
        nbiotResponse.obj (.text:parse_cereg), . = align(SMALL_ALIGN);
        nbiotResponse.obj (.text:parse_imei), . = align(SMALL_ALIGN);
        nbiotResponse.obj (.text:parse_ep_name), . = align(SMALL_ALIGN);
        nbiotResponse.obj (.text:parse_iccid), . = align(SMALL_ALIGN);
        nbiotResponse.obj (.text:parseQLWULDATAEX)
    } > NB_RESPONSE

    nbiotResponse_const : align(CODE_ALIGN) {
        nbiotResponse.obj (.const:.string)
    } > NB_RESPONSE (HIGH)

    message_text : align(CODE_ALIGN) {
        message.obj (.text:MODEM_qaData), . = align(SMALL_ALIGN);
        message.obj (.text:MODEM_errData), . = align(SMALL_ALIGN);
        message.obj (.text:insert_multiData), . = align(SMALL_ALIGN);
        message.obj (.text:MODEM_checkDlMessage), . = align(SMALL_ALIGN);
        message.obj (.text:MODEM_recvIntervalReq), . = align(SMALL_ALIGN);
        message.obj (.text:insert_meteringTime), . = align(SMALL_ALIGN);
        message.obj (.text:MODEM_recvFotaReq), . = align(SMALL_ALIGN);
        message.obj (.text:insert_termInfo), . = align(SMALL_ALIGN);
        message.obj (.text:MODEM_sendCurrentData), . = align(SMALL_ALIGN);
        message.obj (.text:MODEM_sendPeriodicData), . = align(SMALL_ALIGN);
        message.obj (.text:insert_oneData), . = align(SMALL_ALIGN);
        message.obj (.text:insert_radioQuality), . = align(SMALL_ALIGN);
        message.obj (.text:MODEM_recvRepRange), . = align(SMALL_ALIGN);
        message.obj (.text:insert_meterInfo), . = align(SMALL_ALIGN);
        message.obj (.text:printMessage), . = align(SMALL_ALIGN);
        message.obj (.text:MODEM_recvResetReq), . = align(SMALL_ALIGN);
        message.obj (.text:MODEM_recvAckString), . = align(SMALL_ALIGN);
        message.obj (.text:insert_id), . = align(SMALL_ALIGN);
        message.obj (.text:cal_checksum), . = align(SMALL_ALIGN);
        message.obj (.text:insert_meteringParam)
    } > MESSAGE

    message_const : align(CODE_ALIGN) {
        message.obj (.const:.string)
    } > MESSAGE (HIGH)

    nbiotProcess_text : align(CODE_ALIGN) {
        nbiotProcess.obj (.text:dFota), . = align(SMALL_ALIGN);
        nbiotProcess.obj (.text:init), . = align(SMALL_ALIGN);
        nbiotProcess.obj (.text:setModemData), . = align(SMALL_ALIGN);
        nbiotProcess.obj (.text:fota), . = align(SMALL_ALIGN);
        nbiotProcess.obj (.text:updateQa), . = align(SMALL_ALIGN);
        nbiotProcess.obj (.text:transfer), . = align(SMALL_ALIGN);
        nbiotProcess.obj (.text:getEndPointName), . = align(SMALL_ALIGN);
        nbiotProcess.obj (.text:bip), . = align(SMALL_ALIGN);
        nbiotProcess.obj (.text:retry), . = align(SMALL_ALIGN);
        nbiotProcess.obj (.text:certify), . = align(SMALL_ALIGN);
        nbiotProcess.obj (.text:attachNw), . = align(SMALL_ALIGN);
        nbiotProcess.obj (.text:MODEM_process), . = align(SMALL_ALIGN);
        nbiotProcess.obj (.text:sendAtCommand), . = align(SMALL_ALIGN);
        nbiotProcess.obj (.text:idle), . = align(SMALL_ALIGN);
        nbiotProcess.obj (.text:detachNw), . = align(SMALL_ALIGN);
        nbiotProcess.obj (.text:sendNoRespAtCommand), . = align(SMALL_ALIGN);
        nbiotProcess.obj (.text:getErrorReportMessage), . = align(SMALL_ALIGN);
        nbiotProcess.obj (.text:getMeterDataMessage), . = align(SMALL_ALIGN);
        nbiotProcess.obj (.text:getQaReportMessage), . = align(SMALL_ALIGN);
        nbiotProcess.obj (.text:MODEM_generateCseID), . = align(SMALL_ALIGN);
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
        nbiotProcess.obj (.const:AtCmdRunRegister)
        nbiotProcess.obj (.const:AtCmdULDATAEX), . = align(SMALL_ALIGN);
        nbiotProcess.obj (.const:.string)
    } > NB_PROCESS (HIGH)

    .md5_text : align(CODE_ALIGN) {
        md5.obj (.text)
    } > MD5

    .uuid_text : align(CODE_ALIGN) {
        uuid.obj (.text)
    } > MD5 (HIGH)

    nfci2c_text : align(CODE_ALIGN) {
        NFC_i2c.obj (.text:NTAG_writeBlock), . = align(SMALL_ALIGN);
        NFC_i2c.obj (.text:NTAG_writeBytes), . = align(SMALL_ALIGN);
        NFC_i2c.obj (.text:NFC_sendMessage), . = align(SMALL_ALIGN);
        NFC_i2c.obj (.text:I2C_txMultipleBytes), . = align(SMALL_ALIGN);
        NFC_i2c.obj (.text:NTAG_readBytes), . = align(SMALL_ALIGN);
        NFC_i2c.obj (.text:NFC_factoryResetTag), . = align(SMALL_ALIGN);
        NFC_i2c.obj (.text:I2C_rxMultipleBytes), . = align(SMALL_ALIGN);
        NFC_i2c.obj (.text:NFC_recvMessage), . = align(SMALL_ALIGN);
        NFC_i2c.obj (.text:NFC_checkRead), . = align(SMALL_ALIGN);
        NFC_i2c.obj (.text:NTAG_setTransferDir), . = align(SMALL_ALIGN);
        NFC_i2c.obj (.text:NFC_tagDetect), . = align(SMALL_ALIGN);
        NFC_i2c.obj (.text:NTAG_readSessionRegister), . = align(SMALL_ALIGN);
        NFC_i2c.obj (.text:I2C_writeData), . = align(SMALL_ALIGN);
        NFC_i2c.obj (.text:I2C_readData), . = align(SMALL_ALIGN);
        NFC_i2c.obj (.text:NFC_tagEnable), . = align(SMALL_ALIGN);
        NFC_i2c.obj (.text:NTAG_writeSessionRegister), . = align(SMALL_ALIGN);
        NFC_i2c.obj (.text:I2C_rxBytes), . = align(SMALL_ALIGN);
        NFC_i2c.obj (.text:I2C_txBytes), . = align(SMALL_ALIGN);
        NFC_i2c.obj (.text:NFC_fdEnable), . = align(SMALL_ALIGN);
        NFC_i2c.obj (.text:NFC_tagDisable), . = align(SMALL_ALIGN);
        NFC_i2c.obj (.text:NTAG_readBlock), . = align(SMALL_ALIGN);
        NFC_i2c.obj (.text:NTAG_setPthruOnOff), . = align(SMALL_ALIGN);
        NFC_i2c.obj (.text:NFC_FD_input), . = align(SMALL_ALIGN);
        NFC_i2c.obj (.text:NFC_fdDisable), . = align(SMALL_ALIGN);
        NFC_i2c.obj (.text:NTAG_setFDOffFunction), . = align(SMALL_ALIGN);
        NFC_i2c.obj (.text:NTAG_setFDOnFunction), . = align(SMALL_ALIGN);
        NFC_i2c.obj (.text:NFC_init)
    } > NFC_I2C

    nfci2c_const : align(CODE_ALIGN) {
        NFC_i2c.obj (.const:.string:DefaultBeginingOfMemory), . = align(SMALL_ALIGN);
        NFC_i2c.obj (.const:.string:NullBlock), . = align(SMALL_ALIGN);
        NFC_i2c.obj (.const:.string:DefaultPage56), . = align(SMALL_ALIGN);
        NFC_i2c.obj (.const:.string:DefaultPage57), . = align(SMALL_ALIGN);
        NFC_i2c.obj (.const:.string:DefaultPage58)
    } > NFC_I2C (HIGH)

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

