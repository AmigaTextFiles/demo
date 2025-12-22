/*
  miniMIG.c V1.0 20160208
  (c) 2015-2016   Massimiliano Scarano   mscarano@libero.it
  Support my projects for Amiga with a PayPal donation thanks.
  PayPal donate to mscarano@libero.it



  This demo is to welcome my Minimig V1.1 designed by Dennis van Weeren
  and commercially manufactured by ACube Systems.
  It shows how to make direct programming of the Commodore Amiga hardware using C language.
  It consists of the following "old-school" effects:
  - 2D stars
  - copper gradients
  - font text scroller
  Compiled with SAS/C 6.58 and Includes release 40.13 (AmigaOS 3.1).
  Source code supplied for educational purpose only.



  Both .exe and .adf supplied.
  It should work on any PAL Amiga, with a Motorola 68000 cpu and OCS chipset,
  and whatever OS (Kickstart + Workbench) version.
  Tested OK:
  - Amiga Forever 2013 (WinUAE)
  - Mimimig OCS, 68SEC000 / normal, 512 KB Chip, 512 KB Fast, Kickstart 1.3
  - Minimig ECS, 68SEC000 / turbo, 1 MB Chip, 512 KB Fast, Kickstart 1.3



  Notes:
  - My Minimig configuration:
    Bootloader   BYQ100413
    FPGA core    FYQ100818
    ARM Firmware AYQ100818
  - No optimizer options used, the demo should run at constant full frame rate (50 Hz).
  - Commodore Includes 40.13 were distributed with SAS/C 6.51.

*/



#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include <exec/types.h>
#include <exec/memory.h>
#include <dos.h>
#include <graphics/gfxbase.h>
#include <graphics/gfx.h>
#include <hardware/custom.h>

#include <proto/exec.h>
#include <proto/graphics.h>



#define function

#define LOWORD( L )   ( ( WORD ) ( L ) )
#define HIWORD( L )   ( ( WORD ) ( ( ( LONG ) ( L ) >> 16 ) & 0xFFFF ) )

#define SPR0PTH 0x120
#define SPR0PTL 0x122
#define SPR1PTH 0x124
#define SPR1PTL 0x126
#define SPR2PTH 0x128
#define SPR2PTL 0x12a
#define SPR3PTH 0x12c
#define SPR3PTL 0x12e
#define SPR4PTH 0x130
#define SPR4PTL 0x132
#define SPR5PTH 0x134
#define SPR5PTL 0x136
#define SPR6PTH 0x138
#define SPR6PTL 0x13a
#define SPR7PTH 0x13c
#define SPR7PTL 0x13e

#define DIWSTRT 0x8e
#define DIWSTOP 0x90
#define DDFSTRT 0x92
#define DDFSTOP 0x94
#define BPLCON1 0x102
#define BPLCON2 0x104
#define BPL1MOD 0x108
#define BPL2MOD 0x10a

#define BPLCON0 0x100

#define BPL0PTH 0xe0
#define BPL0PTL 0xe2
#define BPL1PTH 0xe4
#define BPL1PTL 0xe6
#define BPL2PTH 0xe8
#define BPL2PTL 0xea
#define BPL3PTH 0xec
#define BPL3PTL 0xee
#define BPL4PTH 0xf0
#define BPL4PTL 0xf2

#define COLOR00 0x180
#define COLOR01 0x182
#define COLOR02 0x184
#define COLOR03 0x186
#define COLOR04 0x188
#define COLOR05 0x18a
#define COLOR06 0x18c
#define COLOR07 0x18e
#define COLOR08 0x190
#define COLOR09 0x192
#define COLOR10 0x194
#define COLOR11 0x196
#define COLOR12 0x198
#define COLOR13 0x19a
#define COLOR14 0x19c
#define COLOR15 0x19e
#define COLOR16 0x1a0
#define COLOR17 0x1a2
#define COLOR18 0x1a4
#define COLOR19 0x1a6
#define COLOR20 0x1a8
#define COLOR21 0x1aa
#define COLOR22 0x1ac
#define COLOR23 0x1ae
#define COLOR24 0x1b0
#define COLOR25 0x1b2
#define COLOR26 0x1b4
#define COLOR27 0x1b6
#define COLOR28 0x1b8
#define COLOR29 0x1ba
#define COLOR30 0x1bc
#define COLOR31 0x1be

#define INTREQ 0x9c

#define BITPLANE320x256 10240 /* size in bytes */

#define STARS  20 /* number of stars for each parallax layer */
#define LAYERS  3 /* number of parallax layers */



/* logo by http://somuch.guru/ */
const UWORD Logo[ 416 ] =
{
  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
  0x0000, 0x0003, 0x8000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x000F, 0xE000,
  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
  0x0000, 0x0000, 0x0000, 0x003F, 0xF800, 0x0000, 0x0000, 0x0000,
  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
  0x00FF, 0xFE00, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x007F, 0xFC00, 0x0000,
  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
  0x0000, 0x0000, 0x001F, 0xF000, 0x0000, 0x0000, 0x0000, 0x0000,
  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0007,
  0xC000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
  0x0000, 0x0000, 0x0000, 0x0000, 0x0003, 0x8000, 0x0000, 0x0000,
  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0600, 0x0000, 0x0000,
  0x303F, 0xFF80, 0x07FE, 0x01FF, 0xF000, 0x01FF, 0xFE00, 0x0000,
  0x0000, 0x0000, 0x0F00, 0x0000, 0x0000, 0x7801, 0xFF80, 0x07FE,
  0x000F, 0xF000, 0x0FE0, 0x3F80, 0x0000, 0x0000, 0x0000, 0x1F80,
  0x0000, 0x0000, 0xFC01, 0xFFC0, 0x0FFE, 0x000F, 0xF000, 0x3F80,
  0x0FC0, 0x0000, 0x0000, 0x0000, 0x1F80, 0x0000, 0x0000, 0xFC01,
  0xFFC0, 0x0FFE, 0x000F, 0xF000, 0x7F00, 0x07C0, 0x0000, 0x0000,
  0x0000, 0x0F00, 0x0000, 0x0000, 0x7801, 0xFFE0, 0x1FFE, 0x000F,
  0xF000, 0xFE00, 0x03C0, 0x0000, 0x0000, 0x0000, 0x0600, 0x0000,
  0x0000, 0x3001, 0xDFE0, 0x1FFE, 0x000F, 0xF001, 0xFE00, 0x01C0,
  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0001, 0xCFF0,
  0x3DFE, 0x000F, 0xF003, 0xFE00, 0x0000, 0x0000, 0x0000, 0x0000,
  0x0000, 0x0000, 0x0000, 0x0001, 0xCFF0, 0x39FE, 0x000F, 0xF003,
  0xFC00, 0x0000, 0x03FE, 0x1FC1, 0xFE01, 0xFE01, 0xFF8F, 0xF00F,
  0xF001, 0xC7F8, 0x79FE, 0x000F, 0xF003, 0xFC00, 0x0000, 0x003E,
  0x7FE7, 0xFF00, 0x3F00, 0x1FBF, 0xF801, 0xF801, 0xC7F8, 0x71FE,
  0x000F, 0xF007, 0xFC00, 0x0000, 0x003F, 0xE3FE, 0x7F00, 0x3F00,
  0x1FF1, 0xF801, 0xF801, 0xC3FC, 0xF1FE, 0x000F, 0xF007, 0xFC00,
  0x0000, 0x007F, 0x83F8, 0x7F00, 0x7F00, 0x3FC1, 0xF803, 0xF801,
  0xC3FC, 0xE1FE, 0x000F, 0xF007, 0xFC00, 0x0000, 0x007F, 0x07F0,
  0xFF00, 0x7E00, 0x3F81, 0xF803, 0xF001, 0xC1FF, 0xE1FE, 0x000F,
  0xF007, 0xFC00, 0x0000, 0x00FE, 0x07E0, 0xFE00, 0xFE00, 0x7F03,
  0xF807, 0xF001, 0xC1FF, 0xC1FE, 0x000F, 0xF003, 0xFC03, 0xFFF0,
  0x00FE, 0x0FE0, 0xFE00, 0xFC00, 0x7F03, 0xF007, 0xE001, 0xC0FF,
  0xC1FE, 0x000F, 0xF003, 0xFC00, 0x1FF0, 0x00FC, 0x0FE1, 0xFC00,
  0xFC00, 0x7E07, 0xF007, 0xE001, 0xC0FF, 0x81FE, 0x000F, 0xF001,
  0xFE00, 0x1FF0, 0x01FC, 0x0FC1, 0xFCE1, 0xFC70, 0xFE07, 0xE30F,
  0xE381, 0xC07F, 0x81FE, 0x000F, 0xF000, 0xFE00, 0x1FE0, 0x01F8,
  0x1FC3, 0xF9E1, 0xF8F0, 0xFC0F, 0xE70F, 0xC781, 0xC03F, 0x01FE,
  0x000F, 0xF000, 0x7E00, 0x1FE0, 0x03F8, 0x1F83, 0xFBC1, 0xF9E1,
  0xFC0F, 0xCF0F, 0xCF01, 0xC03E, 0x01FE, 0x000F, 0xF000, 0x3F00,
  0x1FC0, 0x03F0, 0x3F83, 0xFF81, 0xFFC1, 0xF80F, 0xDE0F, 0xFE01,
  0xC01E, 0x01FE, 0x000F, 0xF000, 0x1FC0, 0x7F00, 0x07F0, 0x3F03,
  0xFF01, 0xFF03, 0xF80F, 0xFC0F, 0xF801, 0xC00C, 0x01FF, 0xF00F,
  0xFF80, 0x03FF, 0xFC00, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000
};



/* 8x8 font by TMC / Scoop Design (C64) */
const UBYTE Font[ 64 ][ 8 ] =
{
  { 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 }, /* Space */
  { 0x00, 0x18, 0x18, 0x18, 0x18, 0x18, 0x00, 0x18 }, /* ! */
  { 0x00, 0x6c, 0x6c, 0x00, 0x00, 0x00, 0x00, 0x00 }, /* " */
  { 0x00, 0x36, 0x7f, 0x36, 0x36, 0x7f, 0x36, 0x00 }, /* # */
  { 0x00, 0x08, 0x3c, 0x68, 0x3c, 0x16, 0x7c, 0x10 }, /* $ */
  { 0x00, 0x00, 0x66, 0x6c, 0x18, 0x36, 0x66, 0x00 }, /* % */
  { 0x00, 0x1c, 0x36, 0x1c, 0x3f, 0x66, 0x7b, 0x00 }, /* & */
  { 0x0c, 0x18, 0x30, 0x00, 0x00, 0x00, 0x00, 0x00 }, /* ' */
  { 0x00, 0x03, 0x06, 0x0c, 0x0c, 0x0c, 0x06, 0x03 }, /* ( */
  { 0x00, 0x60, 0x30, 0x18, 0x18, 0x18, 0x30, 0x60 }, /* ) */
  { 0x00, 0x18, 0x42, 0x18, 0x7e, 0x18, 0x42, 0x18 }, /* * */
  { 0x00, 0x00, 0x1c, 0x1c, 0x7f, 0x1c, 0x1c, 0x00 }, /* + */
  { 0x00, 0x00, 0x00, 0x00, 0x00, 0x30, 0x30, 0x60 }, /* , */
  { 0x00, 0x00, 0x00, 0x00, 0x7f, 0x00, 0x00, 0x00 }, /* - */
  { 0x00, 0x00, 0x00, 0x00, 0x00, 0x30, 0x30, 0x00 }, /* . */
  { 0x00, 0x00, 0x03, 0x06, 0x0c, 0x18, 0x30, 0x60 }, /* / */
  { 0x00, 0x00, 0x7f, 0x63, 0x63, 0x63, 0x7f, 0x00 }, /* 0 */
  { 0x00, 0x00, 0x3c, 0x0c, 0x0c, 0x0c, 0x0c, 0x1e }, /* 1 */
  { 0x00, 0x00, 0x7f, 0x03, 0x7f, 0x70, 0x7f, 0x00 }, /* 2 */
  { 0x00, 0x00, 0x7f, 0x03, 0x1f, 0x03, 0x7f, 0x00 }, /* 3 */
  { 0x70, 0x70, 0x76, 0x76, 0x7f, 0x06, 0x06, 0x00 }, /* 4 */
  { 0x00, 0x00, 0x7f, 0x70, 0x7e, 0x07, 0x7e, 0x00 }, /* 5 */
  { 0x70, 0x70, 0x70, 0x70, 0x7f, 0x73, 0x7f, 0x00 }, /* 6 */
  { 0x00, 0x00, 0x7f, 0x03, 0x03, 0x03, 0x03, 0x03 }, /* 7 */
  { 0x00, 0x00, 0x7f, 0x73, 0x7f, 0x73, 0x7f, 0x00 }, /* 8 */
  { 0x00, 0x00, 0x7f, 0x73, 0x7f, 0x03, 0x03, 0x03 }, /* 9 */
  { 0x00, 0x00, 0x18, 0x18, 0x00, 0x18, 0x18, 0x00 }, /* : */
  { 0x00, 0x00, 0x18, 0x18, 0x00, 0x18, 0x18, 0x30 }, /* ; */
  { 0x00, 0x0c, 0x18, 0x30, 0x60, 0x30, 0x18, 0x0c }, /* < */
  { 0x00, 0x00, 0x00, 0x3c, 0x00, 0x3c, 0x00, 0x00 }, /* = */
  { 0x00, 0x30, 0x18, 0x0c, 0x06, 0x0c, 0x18, 0x30 }, /* > */
  { 0x00, 0x00, 0x7f, 0x63, 0x0f, 0x0c, 0x00, 0x0c }, /* ? */
  { 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 }, /* @   ??? */
  { 0x00, 0x00, 0xff, 0x03, 0x7f, 0x73, 0x73, 0x00 }, /* A */
  { 0x00, 0x00, 0xfe, 0x03, 0x7e, 0x73, 0x7e, 0x00 }, /* B */
  { 0x00, 0x00, 0x3f, 0x70, 0x70, 0x70, 0x3f, 0x00 }, /* C */
  { 0x00, 0x00, 0xfe, 0x03, 0x73, 0x73, 0x7e, 0x00 }, /* D */
  { 0x00, 0x00, 0xff, 0x00, 0x7f, 0x70, 0x7f, 0x00 }, /* E */
  { 0x00, 0x00, 0x7f, 0x00, 0x7f, 0x60, 0x60, 0x00 }, /* F */
  { 0x00, 0x00, 0x3f, 0x70, 0x73, 0x73, 0x3f, 0x00 }, /* G */
  { 0x00, 0x00, 0x73, 0x73, 0x7f, 0x73, 0x73, 0x70 }, /* H */
  { 0x00, 0x00, 0x1c, 0x1c, 0x1c, 0x1c, 0x1c, 0x00 }, /* I */
  { 0x00, 0x00, 0xff, 0x06, 0x06, 0x06, 0x7e, 0x00 }, /* J */
  { 0x00, 0x00, 0x73, 0x76, 0x7c, 0x76, 0x73, 0x00 }, /* K */
  { 0x00, 0x70, 0x70, 0x70, 0x70, 0x70, 0x7f, 0x00 }, /* L */
  { 0x00, 0x00, 0x63, 0x77, 0x7f, 0x6b, 0x63, 0x60 }, /* M */
  { 0x40, 0x60, 0x73, 0x7b, 0x7f, 0x77, 0x73, 0x01 }, /* N */
  { 0x00, 0x00, 0xfe, 0x03, 0x63, 0x63, 0x3e, 0x00 }, /* O */
  { 0x00, 0x00, 0xfe, 0x03, 0x7e, 0x70, 0x70, 0x00 }, /* P */
  { 0x00, 0x00, 0x3e, 0x63, 0x63, 0x6f, 0x3e, 0x03 }, /* Q */
  { 0x00, 0x00, 0xfe, 0x03, 0x7e, 0x66, 0x63, 0x00 }, /* R */
  { 0x00, 0x00, 0x0f, 0x1c, 0x1c, 0x1c, 0xf8, 0x00 }, /* S */
  { 0x00, 0x00, 0xff, 0x1c, 0x1c, 0x1c, 0x1c, 0x00 }, /* T */
  { 0x00, 0x00, 0x73, 0x73, 0x73, 0x73, 0x3e, 0x00 }, /* U */
  { 0x00, 0x00, 0x73, 0x73, 0x73, 0x3e, 0x1c, 0x00 }, /* V */
  { 0x03, 0x03, 0x63, 0x6b, 0x7f, 0x77, 0x63, 0x00 }, /* W */
  { 0x00, 0x00, 0x73, 0x73, 0x3e, 0x73, 0x73, 0x00 }, /* X */
  { 0x00, 0x00, 0x73, 0x73, 0x7f, 0x1c, 0x1c, 0x1c }, /* Y */
  { 0x00, 0x00, 0xff, 0x0e, 0x1c, 0x38, 0x7f, 0x00 }, /* Z */
  { 0x00, 0x3c, 0x38, 0x38, 0x38, 0x38, 0x38, 0x3c }, /* [ */
  { 0x00, 0x00, 0x1f, 0x38, 0xfe, 0x70, 0x7f, 0x00 }, /* £ */
  { 0x00, 0x3c, 0x1c, 0x1c, 0x1c, 0x1c, 0x1c, 0x3c }, /* ] */
  { 0x00, 0x18, 0x3c, 0x7e, 0x18, 0x18, 0x18, 0x18 }, /* ARROW UP */
  { 0x00, 0x00, 0x10, 0x3f, 0x7f, 0x3f, 0x10, 0x00 }, /* ARROW LEFT */
};



const BYTE ID[] = "$VER: miniMig V1.0 - 20160208 by   Massimiliano Scarano   mscarano@libero.it\n";



const UBYTE MsgText[] =
"ALIENTECH PROUDLY PRESENTS A DEMO TO WELCOME MY MINIMIG V1.1 , LEFT MOUSE BUTTON TO EXIT.\
 DEMO V1.0 RELEASED 08-FEB-2016.\
 THIS IS MY 2ND PRODUCTION FOR THE DEMO SCENE,\
 DEMO WRITTEN IN C LANGUAGE WITH DIRECT PROGRAMMING OF THE AMIGA HARDWARE,\
 SORRY NO HD SURROUND SOUND THIS TIME :)\
 CAN THE MINIMIG (CPU TURBO MODE) BE CONSIDERED AS A NEW DEMO PLATFORM?\
 GREETINGS: MY WIFE AND DAUGHTER THANKS FOR YOUR PATIENCE, VINSOFT, JOELED, PHOTON THANKS FOR COPPERSHADE.ORG,\
 STINGRAY, BONEFISH THANKS FOR EXE2ADF, DENNIS VAN WEEREN THANKS FOR THE MINIMIG, POUET.NET.\
 CONTACT ALIENTECH BY EMAIL:   MSCARANO AT LIBERO.IT  \
 ONLY AMIGA MAKES IT POSSIBLE ;)\
 NOW TEXT RESTARTS ...   ";



UWORD chip CopperList[] =
{
  /* reset sprite pointers */
  SPR0PTH, 0x0000, SPR0PTL, 0x0000,
  SPR1PTH, 0x0000, SPR1PTL, 0x0000,
  SPR2PTH, 0x0000, SPR2PTL, 0x0000,
  SPR3PTH, 0x0000, SPR3PTL, 0x0000,
  SPR4PTH, 0x0000, SPR4PTL, 0x0000,
  SPR5PTH, 0x0000, SPR5PTL, 0x0000,
  SPR6PTH, 0x0000, SPR6PTL, 0x0000,
  SPR7PTH, 0x0000, SPR7PTL, 0x0000,

  /* redifinition of important registers */
  DIWSTRT, 0x2c81, /* top-left corner of the display window */
  DIWSTOP, 0x2cc1, /* bottom-right corner of the display window */
  DDFSTRT, 0x0038, /* bitplane data fetch wait times (in cycles) from the start of the row */
  DDFSTOP, 0x00d0, /* bitplane data fetch wait times (in cycles) from the stop of the row */
  BPLCON1, 0x0000, /* horizontal scroll */
  BPLCON2, 0x0000,
  BPL1MOD, 0x0028, /* jump number of bytes in memory in order to read the next line of bitplane data */
  BPL2MOD, 0x0028, /* jump number of bytes in memory in order to read the next line of bitplane data */

  /* define colors and resolution */
  BPLCON0, 0x1200, /* 1 bitplane = 2 colors, Lowres 320x256 */

  /* BPLPOINTERS */
  BPL0PTH, 0x0000, BPL0PTL, 0x0000,
  BPL1PTH, 0x0000, BPL1PTL, 0x0000,
  BPL2PTH, 0x0000, BPL2PTL, 0x0000,
  BPL3PTH, 0x0000, BPL3PTL, 0x0000,
  BPL4PTH, 0x0000, BPL4PTL, 0x0000,

  /* palette */
  COLOR00, 0x0224, COLOR01, 0x0f5f, COLOR02, 0x0000, COLOR03, 0x0000,
  COLOR04, 0x0000, COLOR05, 0x0000, COLOR06, 0x0000, COLOR07, 0x0000,
  COLOR08, 0x0000, COLOR09, 0x0000, COLOR10, 0x0000, COLOR11, 0x0000,
  COLOR12, 0x0000, COLOR13, 0x0000, COLOR14, 0x0000, COLOR15, 0x0000,
  COLOR16, 0x0000, COLOR17, 0x0f5f, COLOR18, 0x0f55, COLOR19, 0x055f,
  COLOR20, 0x0000, COLOR21, 0x0000, COLOR22, 0x0000, COLOR23, 0x0000,
  COLOR24, 0x0000, COLOR25, 0x0000, COLOR26, 0x0000, COLOR27, 0x0000,
  COLOR28, 0x0000, COLOR29, 0x0000, COLOR30, 0x0000, COLOR31, 0x0000,

  /* @@@ WAIT special effects here ... */

  /* vertical red gradient */
  0x2c01, 0xff00, COLOR01, 0x0f00, /* 1st line of display window */
  0x2d01, 0xff00, COLOR01, 0x0e00,
  0x2e01, 0xff00, COLOR01, 0x0d00,
  0x2f01, 0xff00, COLOR01, 0x0c00,
  0x3001, 0xff00, COLOR01, 0x0b00,
  0x3101, 0xff00, COLOR01, 0x0a00,
  0x3201, 0xff00, COLOR01, 0x0900,
  0x3301, 0xff00, COLOR01, 0x0800,

  /* vertical grey gradient */
  0x3601, 0xff00, COLOR01, 0x0fff,
  0x3701, 0xff00, COLOR01, 0x0fff,
  0x3801, 0xff00, COLOR01, 0x0eee,
  0x3901, 0xff00, COLOR01, 0x0eee,
  0x3a01, 0xff00, COLOR01, 0x0ddd,
  0x3b01, 0xff00, COLOR01, 0x0ddd,
  0x3c01, 0xff00, COLOR01, 0x0ccc,
  0x3d01, 0xff00, COLOR01, 0x0ccc,
  0x3e01, 0xff00, COLOR01, 0x0bbb,
  0x3f01, 0xff00, COLOR01, 0x0bbb,
  0x4001, 0xff00, COLOR01, 0x0aaa,
  0x4101, 0xff00, COLOR01, 0x0aaa,
  0x4201, 0xff00, COLOR01, 0x0999,
  0x4301, 0xff00, COLOR01, 0x0999,
  0x4401, 0xff00, COLOR01, 0x0888,
  0x4501, 0xff00, COLOR01, 0x0888,
  0x4601, 0xff00, COLOR01, 0x0777,
  0x4701, 0xff00, COLOR01, 0x0777,
  0x4801, 0xff00, COLOR01, 0x0666,
  0x4901, 0xff00, COLOR01, 0x0666,
  0x4a01, 0xff00, COLOR01, 0x0555,

  0x4b01, 0xff00, COLOR01, 0x0f5f,

  0xffdf, 0xfffe, COLOR00, 0x0224, /* line 255 */

  /* vertical blue gradient */
  0x2401, 0xff00, COLOR00, 0x0008, /* last 8 visible lines */
  0x2501, 0xff00, COLOR00, 0x0009,
  0x2601, 0xff00, COLOR00, 0x000a,
  0x2701, 0xff00, COLOR00, 0x000b,
  0x2801, 0xff00, COLOR00, 0x000c,
  0x2901, 0xff00, COLOR00, 0x000d,
  0x2a01, 0xff00, COLOR00, 0x000e,
  0x2b01, 0xff00, COLOR00, 0x000f, /* last visible line */

  0x2c01, 0xff00, COLOR00, 0x0224,

  0xffff, 0xfffe /* end */
};



/*
  ( STARS * LAYERS ) stars implemented with a single hardware sprite
  reused ( STARS * LAYERS ) times from VSTART=64 to VSTART=182.

  Each star consists of 4 words:
  word 1: hi byte VSTART (Y), low byte HSTART (X)
  word 2: hi byte VSTOP, low byte control
  word 3: image data line, bitplane 0
  word 4: image data line, bitplane 1
*/
UWORD chip Stars[] = /* ( ( STARS * LAYERS ) * 4 ) + 2 */
{
  0x4000, 0x4100, 0x1000, 0x0000, 0x4200, 0x4300, 0x1000, 0x0000,
  0x4400, 0x4500, 0x1000, 0x0000, 0x4600, 0x4700, 0x1000, 0x0000,
  0x4800, 0x4900, 0x1000, 0x0000, 0x4A00, 0x4B00, 0x1000, 0x0000,
  0x4C00, 0x4D00, 0x1000, 0x0000, 0x4E00, 0x4F00, 0x1000, 0x0000,
  0x5000, 0x5100, 0x1000, 0x0000, 0x5200, 0x5300, 0x1000, 0x0000,
  0x5400, 0x5500, 0x1000, 0x0000, 0x5600, 0x5700, 0x1000, 0x0000,
  0x5800, 0x5900, 0x1000, 0x0000, 0x5A00, 0x5B00, 0x1000, 0x0000,
  0x5C00, 0x5D00, 0x1000, 0x0000, 0x5E00, 0x5F00, 0x1000, 0x0000,
  0x6000, 0x6100, 0x1000, 0x0000, 0x6200, 0x6300, 0x1000, 0x0000,
  0x6400, 0x6500, 0x1000, 0x0000, 0x6600, 0x6700, 0x1000, 0x0000,

  0x6800, 0x6900, 0x1000, 0x0000, 0x6A00, 0x6B00, 0x1000, 0x0000,
  0x6C00, 0x6D00, 0x1000, 0x0000, 0x6E00, 0x6F00, 0x1000, 0x0000,
  0x7000, 0x7100, 0x1000, 0x0000, 0x7200, 0x7300, 0x1000, 0x0000,
  0x7400, 0x7500, 0x1000, 0x0000, 0x7600, 0x7700, 0x1000, 0x0000,
  0x7800, 0x7900, 0x1000, 0x0000, 0x7A00, 0x7B00, 0x1000, 0x0000,
  0x7C00, 0x7D00, 0x1000, 0x0000, 0x7E00, 0x7F00, 0x1000, 0x0000,
  0x8000, 0x8100, 0x1000, 0x0000, 0x8200, 0x8300, 0x1000, 0x0000,
  0x8400, 0x8500, 0x1000, 0x0000, 0x8600, 0x8700, 0x1000, 0x0000,
  0x8800, 0x8900, 0x1000, 0x0000, 0x8A00, 0x8B00, 0x1000, 0x0000,
  0x8C00, 0x8D00, 0x1000, 0x0000, 0x8E00, 0x8F00, 0x1000, 0x0000,

  0x9000, 0x9100, 0x1000, 0x0000, 0x9200, 0x9300, 0x1000, 0x0000,
  0x9400, 0x9500, 0x1000, 0x0000, 0x9600, 0x9700, 0x1000, 0x0000,
  0x9800, 0x9900, 0x1000, 0x0000, 0x9A00, 0x9B00, 0x1000, 0x0000,
  0x9C00, 0x9D00, 0x1000, 0x0000, 0x9E00, 0x9F00, 0x1000, 0x0000,
  0xA000, 0xA100, 0x1000, 0x0000, 0xA200, 0xA300, 0x1000, 0x0000,
  0xA400, 0xA500, 0x1000, 0x0000, 0xA600, 0xA700, 0x1000, 0x0000,
  0xA800, 0xA900, 0x1000, 0x0000, 0xAA00, 0xAB00, 0x1000, 0x0000,
  0xAC00, 0xAD00, 0x1000, 0x0000, 0xAE00, 0xAF00, 0x1000, 0x0000,
  0xB000, 0xB100, 0x1000, 0x0000, 0xB200, 0xB300, 0x1000, 0x0000,
  0xB400, 0xB500, 0x1000, 0x0000, 0xB600, 0xB700, 0x1000, 0x0000,

  0x0000, 0x0000 /* end, reserved, must init to 0 0 */
};



struct GfxBase* GfxBase_p;
struct Custom* Hardware_p;
struct View* OldView_p;
UWORD OldDmacon, OldIntena, OldIntreq, OldAdkcon;
UBYTE* DBuf[ 2 ]; /* double buffer, screen buffer 0, screen buffer 1 */



void TakeSystem( void );
void RestoreSystem( void );
void WaitVB( void );
BOOL CheckLMBDown( void );
void InitStars( void );
void UpdateStars( UBYTE Layer );
void ScrollText( UBYTE ScreenBuffer );
void InitLogo( void );



/*
*/
function main()
{
  UBYTE K;
  UBYTE ScreenBuffer;
  UBYTE FramesCounter0, FramesCounter1;



  /* use of the graphics library only to locate and restore the system copper list */
  if ( ( GfxBase_p = ( struct GfxBase* ) OpenLibrary( "graphics.library", 0 ) ) == NULL )
  {
    fprintf( stderr, "%s\n", "OpenLibrary() failed" );
    exit( EXIT_FAILURE );
  } /* if */

  /* allocate the chip memory for bitplanes */
  for ( K = 0; K < 2; K++ )
  {
    if ( ( DBuf[ K ] = ( UBYTE* ) AllocMem( BITPLANE320x256 * 2, MEMF_CHIP | MEMF_CLEAR ) ) == NULL )
    {
      fprintf( stderr, "%s\n", "AllocMem() failed" );
      exit( EXIT_FAILURE );
    } /* if */
  } /* for */

  /* set up a pointer to the hardware registers */
  Hardware_p = ( struct Custom* ) 0xdff000;

  /* store the bitplane pointer in the copper list */
  CopperList[ 51 ] = HIWORD( DBuf[ 1 ] );
  CopperList[ 53 ] = LOWORD( DBuf[ 1 ] );

  /* store the sprite pointer in the copper list */
  CopperList[ 1 ] = HIWORD( Stars );
  CopperList[ 3 ] = LOWORD( Stars );

  InitLogo(); InitStars();

  TakeSystem();



  ScreenBuffer = 1;
  FramesCounter0 = FramesCounter1 = 0;

  /* main loop */
  /* it should run at constant full frame rate (50 Hz) */
  do
  {
    WaitVB(); /* scan line 300 ? */

    /*@@@ demo effects here @@@*/

    ScrollText( ScreenBuffer ^ 1 );   UpdateStars( 0 );

    FramesCounter0 += 1;
    switch ( FramesCounter0 )
    {
      case 2:
        UpdateStars( 1 );
        FramesCounter0 = 0;
        break;
    } /* switch */

    FramesCounter1 += 1;
    switch ( FramesCounter1 )
    {
      case 4:
        UpdateStars( 2 );
        FramesCounter1 = 0;
        break;
    } /* switch */

    ScreenBuffer = ScreenBuffer ^ 1;

    switch ( ScreenBuffer )
    {
      case 0:
        /* store the new bitplane pointer in the copper list */
        CopperList[ 51 ] = HIWORD( DBuf[ 0 ] );
        CopperList[ 53 ] = LOWORD( DBuf[ 0 ] );
        break;

      case 1:
        /* store the new bitplane pointer in the copper list */
        CopperList[ 51 ] = HIWORD( DBuf[ 1 ] );
        CopperList[ 53 ] = LOWORD( DBuf[ 1 ] );
        break;
    } /* switch */

  } while ( ! CheckLMBDown() ); /* LMB ? */ /* do */



  RestoreSystem();

  for ( K = 0; K < 2; K++ )
  {
    if ( DBuf[ K ] )
    {
      FreeMem( DBuf[ K ], BITPLANE320x256 * 2 );
    } /* if */
  } /* for */

  CloseLibrary( ( struct Library* ) GfxBase_p );

  exit( EXIT_SUCCESS );
}






/*
  Non-system startup-code
*/
/*
Some notes:

* Detect the processor, and use VBR if necessary
* If you use sprites, set the resolution in BPLCON3, since LoadView(NULL) fails to reset it if the user has a hires mousepointer. If BPLCON3 is in your coplist that would cover that anyway.
* Set Intreq twice at the end of interrupts. This is a workaround for 040 & 060 based A4000 systems. For example, a level 6 interrupt should look like:

movem.l d0-d7/a0-a6,-(sp)
lea $dff000,a6

; .... code ....

move.w #$2000,Intreq(a6)
move.w #$2000,Intreq(a6)
movem.l (sp)+,d0-d7/a0-a6
rte

This way your code should gracefully kill and restore the OS on everything from a 256k KS1.x A1000 up to an OS3.9 mediator based A4000 and everything inbetween.



INTENASET = %1100000000100000
;            ab-------cdefg--
; a: SET/CLR Bit
; b: Master Bit
; c: Blitter Int
; d: Vert Blank Int
; e: Copper Int
; f: IO Ports/Timers
; g: Software Int

DMASET = %1000001111100000
;         a----bcdefghi--j
; a: SET/CLR Bit
; b: Blitter Priority
; c: Enable DMA
; d: Bit Plane DMA
; e: Copper DMA
; f: Blitter DMA
; g: Sprite DMA
; h: Disk DMA
; i..j: Audio Channel 0-3

*/
function void TakeSystem( void )
{
#define INTENASET 0xc020
#define DMASET    0x83e0

/*
1) Store the current view and coplist from graphicsbase (offsets 34 and 38 ;-) ).
2) Call LoadView() with nothing in A1. This removes the intuition display, and will switch out Picasso96 screens etc.
3) Do two "WaitTOF()"s. This allows enough time for interlaced displays to be turned off
*/
  OldView_p = GfxBase_p->ActiView;
  LoadView( NULL );
  WaitTOF();
  WaitTOF();

/*
4) Call "OwnBlitter()" and "WaitBlit()" to take over control of the blitter safely
*/
  OwnBlitter();
  WaitBlit();

/*
5) Call Forbid() to turn off multitasking
*/
  Forbid();

/*
6) Store DMACONR, INTENAR, INREQR and ADKCONR, or'd with $8000 for later
*/
  OldDmacon = Hardware_p->dmaconr | 0x8000;
  OldIntena = Hardware_p->intenar | 0x8000;
  OldIntreq = Hardware_p->intreqr | 0x8000;
  OldAdkcon = Hardware_p->adkconr | 0x8000;

/*
7) Put $7fff into DMACON, INTENA and ADKCON to turn off all DMA an interrupts
*/
  Hardware_p->dmacon = 0x7fff;
  Hardware_p->intena = 0x7fff;
  Hardware_p->adkcon = 0x7fff;

/*
8) Load your copperlist into Cop1lc, and write to Copjmp1
*/
  Hardware_p->cop1lc = ( ULONG ) CopperList;

/*
9) Set up your interrupts. Remember to use VBR if there is a 68020+ present! Also save any interrupt vectors before you overwrite them
*/
  Hardware_p->intena = 0xc000; /* INTENASET 1100000000100000 +
                                            1100000000000000 */

/*
10) Turn on DMA and interrupts you require
*/
  Hardware_p->dmacon = 0x83a0; /* DMASET 1000001111100000 +
                                         1000001110100000 */



  return;

#undef INTENASET
#undef DMASET
}






/*
*/
function void RestoreSystem( void )
{
/*
1) Put $7fff into DMACON, INTENA and ADKCON
*/
  Hardware_p->dmacon = 0x7fff;
  Hardware_p->intena = 0x7fff;
  Hardware_p->adkcon = 0x7fff;

/*
2) Restore system interrupt pointers
*/

/*
3) Restore copper from gfxbase into cop1lc, and write to copjmp1
*/
  Hardware_p->cop1lc = ( ULONG ) GfxBase_p->copinit;
  Hardware_p->cop2lc = ( ULONG ) GfxBase_p->LOFlist;

/*
4) Move the stored (and $8000 or'd) DMACONR, INTENAR and ADKCONR values into DMACON, INTENA and ADKCON
*/
  Hardware_p->dmacon = OldDmacon;
  Hardware_p->intena = OldIntena;
  Hardware_p->intreq = OldIntreq;
  Hardware_p->adkcon = OldAdkcon;

/*
5) Call LoadView() with the view you stored from graphicbase. This will bring P96 screens back etc.
*/
  LoadView( OldView_p );
  WaitTOF();
  WaitTOF();

/*
6) Call DisownBlitter()
*/
  DisownBlitter();

/*
7) Call Permit()
*/
  Permit();



  return;
}






/*
  - Wait for vertical blanking. The vertical blanking time starts at scan line 300.
*/
function void WaitVB( void )
{
  ULONG VPos, ScanLine;



  ScanLine = 300 << 8;

  do
  {
    VPos = * ( ULONG* ) 0xdff004; /* VPOSR */
  } while ( ( VPos & 0x1ff00 ) != ScanLine );

  return;
}






/*
*/
function BOOL CheckLMBDown( void )
{
  if ( ( * ( UBYTE* ) 0xbfe001 & 64 ) == 0 ) /* CIAAPRA, LMB ? */
  {
    return TRUE;
  } /* if */
  else
  {
    return FALSE;
  } /* else */
}






/*
  - Some hardcoded constants used.
  - VSTART visibility range [ $2c=44 ; $f2=242 ], initial V position of a sprite 16 pixels wide
  - HSTART visibility range [ $40=64 ; $d8=216 ], initial H position of a sprite 16 pixels wide
  - Origin of the display window $40, $2c
*/
function void InitStars( void )
{
  UBYTE I;
  FLOAT X;
  UBYTE VSTART, HSTART;
  UBYTE LAYER;



  srand( time( NULL ) );
  LAYER = 0;
  for ( I = 0, VSTART = 44 + 64; I < ( ( STARS * LAYERS ) * 4 ); I += 4, VSTART += 2 )
  {
    X = rand() / ( FLOAT ) RAND_MAX;
    HSTART = ( UBYTE ) ( X * 152 );
    HSTART += 64;

    Stars[ I + 0 ] = ( ( UWORD ) VSTART << 8 ) | HSTART;
    Stars[ I + 1 ] = ( ( ( UWORD ) VSTART + 1 ) << 8 );

    /* set color of stars for each layer */
    if ( LAYER == 0 )
    {
      Stars[ I + 2 ] = 0x1000;
      Stars[ I + 3 ] = 0x0000;
    } /* if */
    else if ( LAYER == 1 )
    {
      Stars[ I + 2 ] = 0x0000;
      Stars[ I + 3 ] = 0x1000;
    } /* else if */
    else if ( LAYER == 2 )
    {
      Stars[ I + 2 ] = 0x1000;
      Stars[ I + 3 ] = 0x1000;
    } /* else if */

    if ( ++LAYER > 2 )
    {
      LAYER = 0;
    } /* if */

/*
printf( "<%d>, %f, %x, %x, %x, %x\n", I, X, Stars[ I + 0 ], Stars[ I + 1 ], Stars[ I + 2 ], Stars[ I + 3 ] );
*/

  } /* for */

  return;
}






/*
  - Some hardcoded constants used.
*/
function void UpdateStars( UBYTE Layer )
{
  UBYTE I;
  UBYTE HSTART;
  UBYTE VHBITS;
  static const UBYTE EndLoop = ( STARS * LAYERS ) * 4;



  switch ( Layer )
  {
    case 0: /* front most */
      I = 0;
      break;

    case 1:
      I = 4;
      break;

    case 2:
      I = 8;
      break;
  } /* switch */



  for ( ; I < EndLoop; I += 12 )
  {
    HSTART = ( UBYTE ) ( Stars[ I + 0 ] & 0x00ff );
    VHBITS = ( UBYTE ) ( Stars[ I + 1 ] & 0x00ff );

    VHBITS = VHBITS ^ 1;

    if ( VHBITS == 0 )
    {
      HSTART += 1;
    } /* if */

    if ( HSTART >= 240 )
    {
      HSTART = 48;
    } /* if */

    Stars[ I + 0 ] &= 0xff00;
    Stars[ I + 0 ] |= HSTART;
    Stars[ I + 1 ] &= 0xff00;
    Stars[ I + 1 ] |= VHBITS;

  } /* for */



  return;
}






/*
  - Bitplane rows are padded to 16-bit words (horizontal padding), there is no vertical padding.
  - Some hardcoded constants used.

Line 248 19840 ... 19879
Line 249 19920 ... 19959
Line 250 20000 ... 20039
Line 251 20080 ... 20119
Line 252 20160 ... 20199
Line 253 20240 ... 20279
Line 254 20320 ... 20359
Line 255 20400 ... 20439

*/
function void ScrollText( UBYTE ScreenBuffer )
{
  UWORD I, J;
  UWORD Temp;
  UBYTE CurrChar;

  static UBYTE ScrolledPixels = 0;
  static UWORD CurrPos = 0;
  static UBYTE CurrCharLine[ 8 ] = { 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 };
  static const UWORD HPad[ 8 ] = { 80 * 0, 80 * 1, 80 * 2, 80 * 3, 80 * 4, 80 * 5, 80 * 6, 80 * 7 };



  switch ( ScreenBuffer )
  {
    case 0:
      if ( ScrolledPixels == 0 )
      {
        CurrChar = MsgText[ CurrPos++ ];

        if ( CurrChar == '\0' )
        {
          CurrPos = 0;
          CurrChar = MsgText[ CurrPos++ ];
        } /* if */

        CurrCharLine[ 0 ] = Font[ CurrChar - 32 ][ 0 ];
        CurrCharLine[ 1 ] = Font[ CurrChar - 32 ][ 1 ];
        CurrCharLine[ 2 ] = Font[ CurrChar - 32 ][ 2 ];
        CurrCharLine[ 3 ] = Font[ CurrChar - 32 ][ 3 ];
        CurrCharLine[ 4 ] = Font[ CurrChar - 32 ][ 4 ];
        CurrCharLine[ 5 ] = Font[ CurrChar - 32 ][ 5 ];
        CurrCharLine[ 6 ] = Font[ CurrChar - 32 ][ 6 ];
        CurrCharLine[ 7 ] = Font[ CurrChar - 32 ][ 7 ];
      } /* if */



      for ( I = 8; I--; ) /* copy font per line */
      {
        /* beginning */
        J = 19840 + HPad[ I ];
        DBuf[ 0 ][ J ] = DBuf[ 1 ][ J ];

        DBuf[ 0 ][ J ] <<= 1;

        /* middle */
        for ( J = 19841 + HPad[ I ]; J <= 19878 + HPad[ I ]; J++ )
        {
          DBuf[ 0 ][ J ] = DBuf[ 1 ][ J ];

          Temp = ( UWORD ) DBuf[ 0 ][ J ];
          Temp <<= 1;
          DBuf[ 0 ][ J - 1 ] |= ( UBYTE ) ( Temp >> 8 );
          DBuf[ 0 ][ J ] = ( UBYTE ) ( Temp & 0x00ff );
        } /* for */

        /* end */
        J = 19879 + HPad[ I ];
        DBuf[ 0 ][ J ] = DBuf[ 1 ][ J ];

        Temp = ( UWORD ) DBuf[ 0 ][ J ];
        Temp <<= 1;
        DBuf[ 0 ][ J - 1 ] |= ( UBYTE ) ( Temp >> 8 );
        DBuf[ 0 ][ J ] = ( UBYTE ) ( Temp & 0x00ff );

        Temp = ( UWORD ) CurrCharLine[ I ];
        Temp <<= 1;
        DBuf[ 0 ][ J ] |= ( UBYTE ) ( Temp >> 8 );
        CurrCharLine[ I ] = ( UBYTE ) ( Temp & 0x00ff );
      } /* for */

      if ( ++ScrolledPixels >= 8 )
      {
        ScrolledPixels = 0;
      } /* if */

      break;



    case 1:
      if ( ScrolledPixels == 0 )
      {
        CurrChar = MsgText[ CurrPos++ ];

        if ( CurrChar == '\0' )
        {
          CurrPos = 0;
          CurrChar = MsgText[ CurrPos++ ];
        } /* if */

        CurrCharLine[ 0 ] = Font[ CurrChar - 32 ][ 0 ];
        CurrCharLine[ 1 ] = Font[ CurrChar - 32 ][ 1 ];
        CurrCharLine[ 2 ] = Font[ CurrChar - 32 ][ 2 ];
        CurrCharLine[ 3 ] = Font[ CurrChar - 32 ][ 3 ];
        CurrCharLine[ 4 ] = Font[ CurrChar - 32 ][ 4 ];
        CurrCharLine[ 5 ] = Font[ CurrChar - 32 ][ 5 ];
        CurrCharLine[ 6 ] = Font[ CurrChar - 32 ][ 6 ];
        CurrCharLine[ 7 ] = Font[ CurrChar - 32 ][ 7 ];
      } /* if */



      for ( I = 8; I--; ) /* copy font per line */
      {
        /* beginning */
        J = 19840 + HPad[ I ];
        DBuf[ 1 ][ J ] = DBuf[ 0 ][ J ];

        DBuf[ 1 ][ J ] <<= 1;

        /* middle */
        for ( J = 19841 + HPad[ I ]; J <= 19878 + HPad[ I ]; J++ )
        {
          DBuf[ 1 ][ J ] = DBuf[ 0 ][ J ];

          Temp = ( UWORD ) DBuf[ 1 ][ J ];
          Temp <<= 1;
          DBuf[ 1 ][ J - 1 ] |= ( UBYTE ) ( Temp >> 8 );
          DBuf[ 1 ][ J ] = ( UBYTE ) ( Temp & 0x00ff );
        } /* for */

        /* end */
        J = 19879 + HPad[ I ];
        DBuf[ 1 ][ J ] = DBuf[ 0 ][ J ];

        Temp = ( UWORD ) DBuf[ 1 ][ J ];
        Temp <<= 1;
        DBuf[ 1 ][ J - 1 ] |= ( UBYTE ) ( Temp >> 8 );
        DBuf[ 1 ][ J ] = ( UBYTE ) ( Temp & 0x00ff );

        Temp = ( UWORD ) CurrCharLine[ I ];
        Temp <<= 1;
        DBuf[ 1 ][ J ] |= ( UBYTE ) ( Temp >> 8 );
        CurrCharLine[ I ] = ( UBYTE ) ( Temp & 0x00ff );
      } /* for */

      if ( ++ScrolledPixels >= 8 )
      {
        ScrolledPixels = 0;
      } /* if */

      break;

  } /* switch */

  return;
}






/*
  - Some hardcoded constants used.
  - Logo 208x32x1

Line   0     0 ...  39
Line   1    80 ... 119

Line 248 19840 ... 19879
Line 249 19920 ... 19959

*/
function void InitLogo( void )
{
  UWORD I, J;
  UBYTE* Logo_p;
  UBYTE CurrChar;
  UWORD CurrPos;
                     /*0123456789012345678901234567890123456789*/
  UBYTE LineText0[] = "    NEVER GIVE UP, NEVER SURRENDER!     ";
  UBYTE LineText1[] = "CODE                           ALIENTECH";
  UBYTE LineText2[] = "LOGO                 HTTP://SOMUCH.GURU/";
  UBYTE LineText3[] = "FONT            TMC / SCOOP DESIGN (C64)";



  /* copy logo into bitplanes at Y = 0 */
  Logo_p = ( UBYTE* ) Logo;
  for ( I = 0; I < 32; I++ )
  {
    for ( J = 0 + 7 + ( 80 * I ); J <= 25 + 7 + ( 80 * I ); J++ )
    {
      DBuf[ 0 ][ J ] = DBuf[ 1 ][ J ] = *Logo_p++;
    } /* for */
  } /* for */



  /* copy text into bitplanes at Y = 40 */
  CurrPos = 0;
  while ( ( CurrChar = LineText0[ CurrPos++ ] ) != '\0' )
  {
    for ( I = 0; I < 8; I++ ) /* copy font per line */
    {
      for ( J = 3200 + ( CurrPos - 1 ) + ( 80 * I ); J <= 3200 + ( CurrPos - 1 ) + ( 80 * I ); J++ )
      {
        DBuf[ 0 ][ J ] = DBuf[ 1 ][ J ] = Font[ CurrChar - 32 ][ I ];
      } /* for */
    } /* for */
  } /* while */



  /* copy text into bitplanes at Y = 192 */
  CurrPos = 0;
  while ( ( CurrChar = LineText1[ CurrPos++ ] ) != '\0' )
  {
    for ( I = 0; I < 8; I++ ) /* copy font per line */
    {
      for ( J = 15360 + ( CurrPos - 1 ) + ( 80 * I ); J <= 15360 + ( CurrPos - 1 ) + ( 80 * I ); J++ )
      {
        DBuf[ 0 ][ J ] = DBuf[ 1 ][ J ] = Font[ CurrChar - 32 ][ I ];
      } /* for */
    } /* for */
  } /* while */



  /* copy text into bitplanes at Y = 208 */
  CurrPos = 0;
  while ( ( CurrChar = LineText2[ CurrPos++ ] ) != '\0' )
  {
    for ( I = 0; I < 8; I++ ) /* copy font per line */
    {
      for ( J = 16640 + ( CurrPos - 1 ) + ( 80 * I ); J <= 16640 + ( CurrPos - 1 ) + ( 80 * I ); J++ )
      {
        DBuf[ 0 ][ J ] = DBuf[ 1 ][ J ] = Font[ CurrChar - 32 ][ I ];
      } /* for */
    } /* for */
  } /* while */



  /* copy text into bitplanes at Y = 224 */
  CurrPos = 0;
  while ( ( CurrChar = LineText3[ CurrPos++ ] ) != '\0' )
  {
    for ( I = 0; I < 8; I++ ) /* copy font per line */
    {
      for ( J = 17920 + ( CurrPos - 1 ) + ( 80 * I ); J <= 17920 + ( CurrPos - 1 ) + ( 80 * I ); J++ )
      {
        DBuf[ 0 ][ J ] = DBuf[ 1 ][ J ] = Font[ CurrChar - 32 ][ I ];
      } /* for */
    } /* for */
  } /* while */



  return;
}






/* Amiga rules, EOF */
