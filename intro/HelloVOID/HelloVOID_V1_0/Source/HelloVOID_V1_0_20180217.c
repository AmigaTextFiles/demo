/*
  HelloVOID.c V1.0 20180217
  (c) 2018   Massimiliano Scarano   mscarano@libero.it
  Support my projects for Amiga with a PayPal donation thanks.
  PayPal donate to mscarano@libero.it

  Coded by Massimiliano "AlienTech" Scarano for the Amiga demo group VOID.



  This demo shows how to make direct programming of the Commodore Amiga hardware using C language.
  It is designed like in the early 90s.
  It consists of the following "old-school" effects:
  - sine scroller (blitter)
  - 2D stars (hardware sprites)
  - MOD music (paula)
  The Player Playroutine P6112 assembled with PhxAss V4.40.
  Compiled with SAS/C 6.58 and Includes release 40.13 (AmigaOS 3.1).
  Source code supplied for educational purpose only.



  Both .exe and .adf supplied.
  It should work on any PAL Amiga, with a Motorola 68000 cpu and OCS chipset,
  and whatever OS (Kickstart + Workbench) version.
  Tested OK:
  - Amiga Forever 2013 (WinUAE)
  - Minimig V1.1 OCS, 68SEC000 / 7.09 MHz (Normal), 512 KB Chip, 0 KB Fast, Kickstart 1.3
  - Minimig V1.1 OCS, 68SEC000 / 7.09 MHz (Normal), 512 KB Chip, 512 KB Fast, Kickstart 1.3
  - Minimig V1.1 ECS, 68SEC000 / 49.63 MHz (Turbo), 1 MB Chip, 512 KB Fast, Kickstart 1.3



  Version history:
  - V1.0 20180217, first public release



  Notes:
  - My Minimig configuration:
    Bootloader   BYQ100413
    FPGA core    FYQ100818
    ARM Firmware AYQ100818
  - The demo should run at constant full frame rate (50 Hz),
    the screen is updated every frame.
  - Commodore Includes 40.13 were distributed with SAS/C 6.51.
  - RAW gfx format consists of all rows of the 1st bitplane, followed by all rows of the 2nd bitplane and so on.
  - Build with:
    > phxass p61.s
    > sc link HelloVOID_V1_?_YYYYMMDD.c p61.o

*/



#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <proto/dos.h>
#include <proto/exec.h>
#include <proto/graphics.h>

#include <exec/memory.h>
#include <exec/execbase.h>
#include <graphics/gfxbase.h>
#include <hardware/dmabits.h>

#include <time.h>

#include "p61.h"



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
#define SCRATCHAREA 672 /* size in bytes */

#define STARS  20 /* number of stars for each parallax layer */
#define LAYERS  3 /* number of parallax layers */



const BYTE ID[] = "$VER: HelloVOID V1.0 - 20180217 by   Massimiliano Scarano   mscarano@libero.it\n";



const UBYTE MsgText[] =
"ALIENTECH OF VOID PROUDLY PRESENTS A DEMO CALLED HELLOVOID, LEFT MOUSE BUTTON TO EXIT.\
 DEMO V1.0 20180217 RELEASED FOR REVISION 2018.\
 THIS PRODUCTION IS TO SAY HELLO TO VOID MEMBERS AFTER I JOINED, HI MATES.\
 TO THE NEW-SCHOOL FANS OUT THERE THIS IS NOT JUST A SIMPLE SHADER,\
 THIS DEMO IS WRITTEN IN C LANGUAGE WITH DIRECT PROGRAMMING OF THE COMMODORE AMIGA HARDWARE.\
 CREDITS:\
 DESIGN, CODE: ALIENTECH\
 LOGO: PUNI AND ALIENTECH\
 FONT: WWW.RINKYDINKELECTRONICS.COM\
 MUSIC: MAZE\
 GREETINGS: PCHELKA777, BLUE UNICORN, VINSOFT, INVENT, VOID.\
 PLEASE SUPPORT MY PROJECTS FOR AMIGA WITH A PAYPAL DONATION TO MSCARANO@LIBERO.IT THANKS.\
 ONLY AMIGA MAKES IT POSSIBLE ;)\
 ... ALIENS ARE AMONG US ...\
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
  /* the bitplane is 40 bytes wide and 40 are visible thus the mod is 40 - 40 */
  BPL1MOD, 0x0000, /* jump number of bytes in memory in order to read the next line of bitplane data, odd planes */
  BPL2MOD, 0x0000, /* jump number of bytes in memory in order to read the next line of bitplane data, even planes */

  /* define colors and resolution */
  BPLCON0, 0x3200, /* 3 bitplanes = 8 colors, Lowres 320x256 */

  /* BPLPOINTERS */
  BPL0PTH, 0x0000, BPL0PTL, 0x0000,
  BPL1PTH, 0x0000, BPL1PTL, 0x0000,
  BPL2PTH, 0x0000, BPL2PTL, 0x0000,
  BPL3PTH, 0x0000, BPL3PTL, 0x0000,
  BPL4PTH, 0x0000, BPL4PTL, 0x0000,

  /* PaletteRGB4 generated by PPaint 7.1 */
  COLOR00, 0x0000, COLOR01, 0x0335, COLOR02, 0x0447, COLOR03, 0x0558,
  COLOR04, 0x0669, COLOR05, 0x088A, COLOR06, 0x099C, COLOR07, 0x0EEE,
  COLOR08, 0x0000, COLOR09, 0x0000, COLOR10, 0x0000, COLOR11, 0x0000,
  COLOR12, 0x0000, COLOR13, 0x0000, COLOR14, 0x0000, COLOR15, 0x0000,
  COLOR16, 0x0000, COLOR17, 0x0fff, COLOR18, 0x0999, COLOR19, 0x0555,
  COLOR20, 0x0000, COLOR21, 0x0000, COLOR22, 0x0000, COLOR23, 0x0000,
  COLOR24, 0x0000, COLOR25, 0x0000, COLOR26, 0x0000, COLOR27, 0x0000,
  COLOR28, 0x0000, COLOR29, 0x0000, COLOR30, 0x0000, COLOR31, 0x0000,

  /* @@@ WAIT special effects here ... */

  /* vertical color gradient */
  0x2c01, 0xfffe, COLOR00, 0x080f, /* 1st line of display window */
  0x2d01, 0xfffe, COLOR00, 0x080e,
  0x2e01, 0xfffe, COLOR00, 0x080d,
  0x2f01, 0xfffe, COLOR00, 0x080c,
  0x3001, 0xfffe, COLOR00, 0x080b,
  0x3101, 0xfffe, COLOR00, 0x080a,
  0x3201, 0xfffe, COLOR00, 0x0809,
  0x3301, 0xfffe, COLOR00, 0x0808,

  0x3401, 0xfffe, COLOR00, 0x0000,

  /* color of the sine scroller */
  0x9d01, 0xfffe, COLOR01, 0x061f,
  0xc901, 0xfffe, COLOR01, 0x061f,

  0xca01, 0xfffe, COLOR01, 0x0335,

  0xffdf, 0xfffe, COLOR00, 0x0000, /* line 255 */

  /* vertical color gradient */
  0x2401, 0xfffe, COLOR00, 0x0808, /* last 8 visible lines */
  0x2501, 0xfffe, COLOR00, 0x0809,
  0x2601, 0xfffe, COLOR00, 0x080a,
  0x2701, 0xfffe, COLOR00, 0x080b,
  0x2801, 0xfffe, COLOR00, 0x080c,
  0x2901, 0xfffe, COLOR00, 0x080d,
  0x2a01, 0xfffe, COLOR00, 0x080e,
  0x2b01, 0xfffe, COLOR00, 0x080f, /* last visible line */

  0x2c01, 0xfffe, COLOR00, 0x0000,

  0xffff, 0xfffe /* end */
};



/*
  - Values of the vertical positions of the sine scrolltext.
  - From line 111 to line 143.
  - Values already multiplied by 40 for bitplane address.
*/
UWORD SineTab[] = /* 124 */
{
  127 * 40, 128 * 40, 129 * 40, 130 * 40, 130 * 40, 131 * 40,
  132 * 40, 133 * 40, 134 * 40, 134 * 40, 135 * 40, 136 * 40, 136 * 40, 137 * 40, 138 * 40, 138 * 40,
  139 * 40, 139 * 40, 140 * 40, 140 * 40, 141 * 40, 141 * 40, 142 * 40, 142 * 40, 142 * 40, 142 * 40,
  143 * 40, 143 * 40, 143 * 40, 143 * 40, 143 * 40, 143 * 40, 143 * 40, 143 * 40, 143 * 40, 143 * 40,
  142 * 40, 142 * 40, 142 * 40, 142 * 40, 141 * 40, 141 * 40, 140 * 40, 140 * 40, 139 * 40, 139 * 40,
  138 * 40, 138 * 40, 137 * 40, 136 * 40, 136 * 40, 135 * 40, 134 * 40, 134 * 40, 133 * 40, 132 * 40,
  131 * 40, 130 * 40, 130 * 40, 129 * 40, 128 * 40, 127 * 40,

  127 * 40, 126 * 40, 125 * 40, 124 * 40, 124 * 40, 123 * 40,
  122 * 40, 121 * 40, 120 * 40, 120 * 40, 119 * 40, 118 * 40, 118 * 40, 117 * 40, 116 * 40, 116 * 40,
  115 * 40, 115 * 40, 114 * 40, 114 * 40, 113 * 40, 113 * 40, 112 * 40, 112 * 40, 112 * 40, 112 * 40,
  111 * 40, 111 * 40, 111 * 40, 111 * 40, 111 * 40, 111 * 40, 111 * 40, 111 * 40, 111 * 40, 111 * 40,
  112 * 40, 112 * 40, 112 * 40, 112 * 40, 113 * 40, 113 * 40, 114 * 40, 114 * 40, 115 * 40, 115 * 40,
  116 * 40, 116 * 40, 117 * 40, 118 * 40, 118 * 40, 119 * 40, 120 * 40, 120 * 40, 121 * 40, 122 * 40,
  123 * 40, 124 * 40, 124 * 40, 125 * 40, 126 * 40, 127 * 40
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
struct DosLibrary* DOSBase_p;

struct Custom* Hardware_p;
struct View* OldView_p;
UWORD OldDmacon, OldIntena, OldIntreq, OldAdkcon;

UBYTE* DBuf[ 2 ]; /* double buffer, screen buffer 0, screen buffer 1 */

UBYTE* Pic_p;
LONG PicSize;

UBYTE* Font_p;
LONG FontSize;

UBYTE* Mod_p;
LONG ModSize;



void TakeSystem( void );
void RestoreSystem( void );
void WaitVB( void );
BOOL CheckLMBDown( void );
void ScrollText( UBYTE OffScreenBuffer );
UBYTE* ReadFile( BYTE* FileName_p, LONG* FileSize_p, ULONG MemType );
void PrintChar( UBYTE OffScreenBuffer, UBYTE CurrChar );
void Scroll( UBYTE OffScreenBuffer );
void WaitBlitter( void );
void Copy( UBYTE OffScreenBuffer );
void PrintSysInfo( void );
void PrintCredits( void );
void ClearScreenArea( UBYTE OffScreenBuffer );
void SineScroll( UBYTE OffScreenBuffer );
void InitStars( void );
void UpdateStars( UBYTE Layer );



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
    fprintf( stderr, "%s\n", "OpenLibrary( graphics ) failed" );
    exit( EXIT_FAILURE );
  } /* if */

  /* use of the dos library only to load data */
  if ( ( DOSBase_p = ( struct DosLibrary* ) OpenLibrary( "dos.library", 0 ) ) == NULL )
  {
    fprintf( stderr, "%s\n", "OpenLibrary( dos ) failed" );
    exit( EXIT_FAILURE );
  } /* if */

  /* load bitmap picture, allocate the best available cleared memory */
  if ( ( Pic_p = ReadFile( "DemoData/Logo320x256x8.raw", &PicSize, MEMF_CLEAR ) ) == NULL )
  {
    fprintf( stderr, "%s\n", "ReadFile() failed, image not loaded" );
    exit( EXIT_FAILURE );
  } /* if */

/*
printf( "<%d>\n", PicSize );
*/

  /* load bitmap font */
  /* !"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ   59 chars */
  if ( ( Font_p = ReadFile( "DemoData/Font944x16x2.raw", &FontSize, MEMF_CHIP | MEMF_CLEAR ) ) == NULL )
  {
    fprintf( stderr, "%s\n", "ReadFile() failed, font not loaded" );
    exit( EXIT_FAILURE );
  } /* if */

  /* load module */
  if ( ( Mod_p = ReadFile( "DemoData/ToTheLimit.p61", &ModSize, MEMF_CHIP | MEMF_CLEAR ) ) == NULL )
  {
    fprintf( stderr, "%s\n", "ReadFile() failed, music not loaded" );
    exit( EXIT_FAILURE );
  } /* if */

  /* allocate the chip memory for bitplanes */
  for ( K = 0; K < 2; K++ )
  {
    if ( ( DBuf[ K ] = ( UBYTE* ) AllocMem( ( BITPLANE320x256 * 3 ) + SCRATCHAREA, MEMF_CHIP | MEMF_CLEAR ) ) == NULL )
    {
      fprintf( stderr, "%s\n", "AllocMem() failed" );
      exit( EXIT_FAILURE );
    } /* if */
  } /* for */

  /* copy picture to bitplanes */
  memcpy( DBuf[ 0 ], Pic_p, PicSize );
  memcpy( DBuf[ 1 ], Pic_p, PicSize );

  /* set up a pointer to the hardware registers */
  Hardware_p = ( struct Custom* ) 0xdff000;

  /* store the bitplane pointers in the copper list */
  CopperList[ 51 ] = HIWORD( DBuf[ 1 ] + ( BITPLANE320x256 * 0 ) );
  CopperList[ 53 ] = LOWORD( DBuf[ 1 ] + ( BITPLANE320x256 * 0 ) );

  CopperList[ 55 ] = HIWORD( DBuf[ 1 ] + ( BITPLANE320x256 * 1 ) );
  CopperList[ 57 ] = LOWORD( DBuf[ 1 ] + ( BITPLANE320x256 * 1 ) );

  CopperList[ 59 ] = HIWORD( DBuf[ 1 ] + ( BITPLANE320x256 * 2 ) );
  CopperList[ 61 ] = LOWORD( DBuf[ 1 ] + ( BITPLANE320x256 * 2 ) );

  /* store the sprite pointer in the copper list */
  CopperList[ 1 ] = HIWORD( Stars );
  CopperList[ 3 ] = LOWORD( Stars );

  InitStars();

  PrintSysInfo(); /* No PS4 found ;) */

  TakeSystem();

  P61_Init( ( APTR ) Mod_p, NULL, NULL );



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
        /* store the bitplane pointers in the copper list */
        CopperList[ 51 ] = HIWORD( DBuf[ 0 ] + ( BITPLANE320x256 * 0 ) );
        CopperList[ 53 ] = LOWORD( DBuf[ 0 ] + ( BITPLANE320x256 * 0 ) );

        CopperList[ 55 ] = HIWORD( DBuf[ 0 ] + ( BITPLANE320x256 * 1 ) );
        CopperList[ 57 ] = LOWORD( DBuf[ 0 ] + ( BITPLANE320x256 * 1 ) );

        CopperList[ 59 ] = HIWORD( DBuf[ 0 ] + ( BITPLANE320x256 * 2 ) );
        CopperList[ 61 ] = LOWORD( DBuf[ 0 ] + ( BITPLANE320x256 * 2 ) );
        break;

      case 1:
        /* store the bitplane pointers in the copper list */
        CopperList[ 51 ] = HIWORD( DBuf[ 1 ] + ( BITPLANE320x256 * 0 ) );
        CopperList[ 53 ] = LOWORD( DBuf[ 1 ] + ( BITPLANE320x256 * 0 ) );

        CopperList[ 55 ] = HIWORD( DBuf[ 1 ] + ( BITPLANE320x256 * 1 ) );
        CopperList[ 57 ] = LOWORD( DBuf[ 1 ] + ( BITPLANE320x256 * 1 ) );

        CopperList[ 59 ] = HIWORD( DBuf[ 1 ] + ( BITPLANE320x256 * 2 ) );
        CopperList[ 61 ] = LOWORD( DBuf[ 1 ] + ( BITPLANE320x256 * 2 ) );
        break;
    } /* switch */

  } while ( ! CheckLMBDown() ); /* LMB ? */ /* do */



  P61_End();

  RestoreSystem();

  PrintCredits();

  for ( K = 0; K < 2; K++ )
  {
    if ( DBuf[ K ] )
    {
      FreeMem( DBuf[ K ], ( BITPLANE320x256 * 3 ) + SCRATCHAREA );
    } /* if */
  } /* for */

  if ( Mod_p )
  {
    FreeMem( Mod_p, ModSize );
  } /* if */

  if ( Font_p )
  {
    FreeMem( Font_p, FontSize );
  } /* if */

  if ( Pic_p )
  {
    FreeMem( Pic_p, PicSize );
  } /* if */

  CloseLibrary( ( struct Library* ) DOSBase_p );

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
  Hardware_p->intena = 0x7fff; /**/

/*
10) Turn on DMA and interrupts you require
*/
  Hardware_p->dmacon = 0x83e0; /* DMASET 1000001111100000 +
                                         1000001111100000 */



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
  - Waits for vertical blanking. The vertical blanking time starts at scan line 300.
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
  - The blitter is used for this font text scroller.
  - Some hardcoded constants used.

*/
function void ScrollText( UBYTE OffScreenBuffer )
{
  UBYTE CurrChar;
  static UBYTE ScrolledPixels = 0;
  static UWORD CurrPos = 0;



  switch ( OffScreenBuffer )
  {
    case 0:
      Copy( 0 );

      if ( ScrolledPixels == 0 )
      {
        CurrChar = MsgText[ CurrPos++ ];

        if ( CurrChar == '\0' )
        {
          CurrPos = 0;
          CurrChar = MsgText[ CurrPos++ ];
        } /* if */

        PrintChar( 0, CurrChar );

      } /* if */

      Scroll( 0 );   ClearScreenArea( 0 ); SineScroll( 0 );

      if ( ++ScrolledPixels >= 16 )
      {
        ScrolledPixels = 0;
      } /* if */

      break;

    case 1:
      Copy( 1 );

      if ( ScrolledPixels == 0 )
      {
        CurrChar = MsgText[ CurrPos++ ];

        if ( CurrChar == '\0' )
        {
          CurrPos = 0;
          CurrChar = MsgText[ CurrPos++ ];
        } /* if */

        PrintChar( 1, CurrChar );

      } /* if */

      Scroll( 1 );   ClearScreenArea( 1 ); SineScroll( 1 );

      if ( ++ScrolledPixels >= 16 )
      {
        ScrolledPixels = 0;
      } /* if */

      break;

  } /* switch */

  return;
}






/*
  - Loads demo data.
*/
function UBYTE* ReadFile( BYTE* FileName_p, LONG* FileSize_p, ULONG MemType )
{
  BPTR FileLock = NULL;
  struct FileInfoBlock* FileInfoBlock_p = NULL;
  UBYTE* Data_p;
  BPTR File = NULL;



  if ( ( FileLock = Lock( FileName_p, ACCESS_READ ) ) == NULL )
  {
    return NULL;
  } /* if */

  if ( ( FileInfoBlock_p = ( struct FileInfoBlock* ) AllocMem( sizeof ( struct FileInfoBlock ), NULL ) ) == NULL )
  {
    return NULL;
  } /* if */

  if ( Examine( FileLock, FileInfoBlock_p ) == FALSE )
  {
    return NULL;
  } /* if */

  *FileSize_p = FileInfoBlock_p->fib_Size;

  if ( ( Data_p = ( UBYTE* ) AllocMem( *FileSize_p, MemType ) ) == NULL )
  {
    return NULL;
  } /* if */

  if ( ( File = Open( FileName_p, MODE_OLDFILE ) ) == NULL )
  {
    return NULL;
  } /* if */

  Read( File, Data_p, *FileSize_p );

  Close( File );
  UnLock( FileLock );
  FreeMem( FileInfoBlock_p, sizeof ( struct FileInfoBlock ) );

  return Data_p;
}






/*
  - Prints a letter into a not visibile part of the screen.

SCRATCHAREA

Line  0 30720 ... 30761
Line  1 30762 ... 30803
Line  2 ...
Line  3 ...
Line  4 ...
Line  5 ...
Line  6 ...
Line  7 ...
Line  8 ...
Line  9 ...
Line 10 ...
Line 11 ...
Line 12 ...
Line 13 ...
Line 14 31308 ... 31349
Line 15 31350 ... 31391

*/
function void PrintChar( UBYTE OffScreenBuffer, UBYTE CurrChar )
{
  WaitBlitter();

  /* copy from channel A to channel D, no shifts, ascending mode */
  Hardware_p->bltcon0 = 0x9f0;
  Hardware_p->bltcon1 = 0x0;

  Hardware_p->bltafwm = 0xffff;
  Hardware_p->bltalwm = 0xffff;

  Hardware_p->bltapt = ( APTR ) &( Font_p[ ( CurrChar - 32 ) + ( CurrChar - 32 ) ] ); /* address of source (top left corner of font char) */

  switch ( OffScreenBuffer )
  {
    /* Destination = ( Line * BitplaneLengthBytes ) + BitplaneVisibleBytes */
    case 0:
      Hardware_p->bltdpt = ( APTR ) &( DBuf[ 0 ][ 30760 ] ); /* address of destination (fixed top left corner in the bitplane) */
      break;

    case 1:
      Hardware_p->bltdpt = ( APTR ) &( DBuf[ 1 ][ 30760 ] ); /* address of destination (fixed top left corner in the bitplane) */
      break;
  } /* switch */

  Hardware_p->bltamod = 118 - 2; /* mod = bytes to skip for source */
  Hardware_p->bltdmod = 42 - 2; /* mod = bytes to skip for destination */
  Hardware_p->bltsize = ( 16 << 6 ) + 1; /* UWORD rectangle size (h = 16 lines, w = 1 word), starts blit */

  return;
}






/*
  - Each call scrolls the text 1 pixel to left, into a not visibile part of the screen.
*/
function void Scroll( UBYTE OffScreenBuffer )
{
  WaitBlitter();

  /* copy from channel A to channel D, with 1 pixel shift, descending mode */
  Hardware_p->bltcon0 = 0x19f0;
  Hardware_p->bltcon1 = 0x2;

  Hardware_p->bltafwm = 0xffff; /* whole */
  Hardware_p->bltalwm = 0x7fff; /* cancel left most bit */

  switch ( OffScreenBuffer )
  {
    /* Source and Destination = ( Line * BitplaneLengthBytes ) + BitplaneVisibleBytes */
    case 0:
      /* source and destination are equal */
      Hardware_p->bltapt = ( APTR ) &( DBuf[ 0 ][ 31390 ] ); /* address of source (bitplane) */
      Hardware_p->bltdpt = ( APTR ) &( DBuf[ 0 ][ 31390 ] ); /* address of destination (bitplane) */
      break;

    case 1:
      /* source and destination are equal */
      Hardware_p->bltapt = ( APTR ) &( DBuf[ 1 ][ 31390 ] ); /* address of source (bitplane) */
      Hardware_p->bltdpt = ( APTR ) &( DBuf[ 1 ][ 31390 ] ); /* address of destination (bitplane) */
      break;
  } /* switch */

  /* scroll of an image as wide as the whole screen, mods = 0 */
  Hardware_p->bltamod = 0; /* mod for source */
  Hardware_p->bltdmod = 0; /* mod for destination */
  Hardware_p->bltsize = ( 16 << 6 ) + 21; /* UWORD size */

  return;
}






/*
asm("1: btst #6,0xdff002\n"
    "   bnes 1b");
*/
function void WaitBlitter( void )
{
  if ( Hardware_p->dmaconr & DMAF_BLTDONE )
  {
    ;
  } /* if */

  while ( Hardware_p->dmaconr & DMAF_BLTDONE )
  {
    ;
  } /* while */

  return;
}






/*
  - Makes a copy of the scroll area which is a not visibile part of the screen.
*/
function void Copy( UBYTE OffScreenBuffer )
{
  WaitBlitter();

  /* copy from channel A to channel D, no shifts, ascending mode */
  Hardware_p->bltcon0 = 0x9f0;
  Hardware_p->bltcon1 = 0x0;

  Hardware_p->bltafwm = 0xffff;
  Hardware_p->bltalwm = 0xffff;

  switch ( OffScreenBuffer )
  {
    case 0:
      Hardware_p->bltapt = ( APTR ) &( DBuf[ 1 ][ 30720 ] ); /* address of source (top left corner) */
      Hardware_p->bltdpt = ( APTR ) &( DBuf[ 0 ][ 30720 ] ); /* address of destination (top left corner) */
      break;

    case 1:
      Hardware_p->bltapt = ( APTR ) &( DBuf[ 0 ][ 30720 ] ); /* address of source (top left corner) */
      Hardware_p->bltdpt = ( APTR ) &( DBuf[ 1 ][ 30720 ] ); /* address of destination (top left corner) */
      break;
  } /* switch */

  Hardware_p->bltamod = 0; /* mod for source */
  Hardware_p->bltdmod = 0; /* mod for destination */
  Hardware_p->bltsize = ( 16 << 6 ) + 21; /* UWORD size */

  return;
}






/*
  - Prints some system info.
  - 030/040 is not recognized by Kickstart 1.3 or lower,
    it is assumed that 020+ should correspond to Kickstart 2.0 or higher.

*/
function void PrintSysInfo( void )
{
  struct ExecBase* SysBase_p = * ( struct ExecBase** ) 4;



  fprintf( stdout, "%s\n", "Amiga:" );

  if ( SysBase_p->AttnFlags & AFF_68060 )
  {
    fprintf( stdout, "%s\n", "CPU: 68060 / 68EC060 / 68LC060" );
    fprintf( stdout, "%s\n", "FPU: ?" );
  } /* if */
  else if ( SysBase_p->AttnFlags & AFF_68040 )
  {
    if ( SysBase_p->AttnFlags & AFF_FPU40 )
    {
      fprintf( stdout, "%s\n", "CPU: 68040 / 68EC040" );
      fprintf( stdout, "%s\n", "FPU: 68040" );
    } /* if */
    else
    {
      fprintf( stdout, "%s\n", "CPU: 68LC040" );
      fprintf( stdout, "%s\n", "FPU: NONE" );
    } /* else */
  } /* else if */
  else if ( SysBase_p->AttnFlags & AFF_68030 )
  {
    fprintf( stdout, "%s\n", "CPU: 68030 / 68EC030" );
  } /* else if */
  else if ( SysBase_p->AttnFlags & AFF_68020 )
  {
    fprintf( stdout, "%s\n", "CPU: 68020 / 68EC020" );
  } /* else if */
  else if ( SysBase_p->AttnFlags & AFF_68010 )
  {
    fprintf( stdout, "%s\n", "CPU: 68010" );
  } /* else if */
  else
  {
    fprintf( stdout, "%s\n", "CPU: 68000 / 68EC000 / 68SEC000" );
  } /* else */



  if ( SysBase_p->AttnFlags & AFF_68882 )
  {
    fprintf( stdout, "%s\n", "FPU: 68882" );
  } /* if */
  else if ( SysBase_p->AttnFlags & AFF_68881 )
  {
    fprintf( stdout, "%s\n", "FPU: 68881" );
  } /* else if */
  else
  {
    fprintf( stdout, "%s\n", "FPU: NONE" );
  } /* else */



  if ( ( GfxBase_p->ChipRevBits0 & GFXF_AA_LISA ) && ( GfxBase_p->ChipRevBits0 & GFXF_AA_ALICE ) )
  {
    fprintf( stdout, "%s\n", "CHIPSET: AGA" );
  } /* if */
  else if ( ( GfxBase_p->ChipRevBits0 & GFXF_HR_DENISE ) && ( GfxBase_p->ChipRevBits0 & GFXF_HR_AGNUS ) )
  {
    fprintf( stdout, "%s\n", "CHIPSET: ECS" );
  } /* else if */
  else
  {
    fprintf( stdout, "%s\n", "CHIPSET: OCS" );
  } /* else */

  fprintf( stdout, "\n\n\n" );

  return;
}






/*
*/
function void PrintCredits( void )
{
  fprintf( stdout, "%s\n", "Credits:" );
  fprintf( stdout, "%s\n", "Design, code: AlienTech   Massimiliano Scarano   mscarano@libero.it" );
  fprintf( stdout, "%s\n", "Logo: Puni and AlienTech" );
  fprintf( stdout, "%s\n", "Font: courtesy of www.rinkydinkelectronics.com" );
  fprintf( stdout, "%s\n", "Music: Maze" );
  fprintf( stdout, "%s\n", "Music player: various authors" );

  return;
}






/*
  - This routine clears the screen through the blitter.
  - Only the sine scroll area is cleared: from line 111 to line 143 (+ 16).
*/
function void ClearScreenArea( UBYTE OffScreenBuffer )
{
  WaitBlitter();

  /* clear */
  Hardware_p->bltcon0 = 0x100;
  Hardware_p->bltcon1 = 0x0;

  switch ( OffScreenBuffer )
  {
    case 0:
      Hardware_p->bltdpt = ( APTR ) &( DBuf[ 0 ][ 40 * 111 ] ); /* address of destination (top left corner) */
      break;

    case 1:
      Hardware_p->bltdpt = ( APTR ) &( DBuf[ 1 ][ 40 * 111 ] ); /* address of destination (top left corner) */
      break;
  } /* switch */

  Hardware_p->bltdmod = 0; /* mod bytes for destination */
  Hardware_p->bltsize = ( 48 << 6 ) + 20; /* UWORD size */

  return;
}






/*
  - 4 pixels sine scroller. The routine can handle up to 1 pixel sine scroller.
*/
function void SineScroll( UBYTE OffScreenBuffer )
{
  UWORD Mask; /* 0x8000, 0x4000, 0x2000, 0x1000, 0x800, 0x400, 0x200, 0x100,
                 0x80, 0x40, 0x20, 0x10, 0x8, 0x4, 0x2, 0x1 */
  UBYTE Source, Slice, SinePos;
  UWORD SineValue;
  static UBYTE SinePtr0 = 0; /* this is to use a different sine value each time */
  static UBYTE SinePtr1 = 0; /* this is to use a different sine value each time */



  switch ( OffScreenBuffer )
  {
    case 0:
      SinePos = SinePtr0++;
      if ( SinePtr0 >= 124 )
      {
        SinePtr0 = 0;
      } /* if */
      break;

    case 1:
      SinePos = SinePtr1++;
      if ( SinePtr1 >= 124 )
      {
        SinePtr1 = 0;
      } /* if */
      break;
  } /* switch */



  /* for all the words / chars of the screen */
  for ( Source = 0; Source < 20; Source++ )
  {
    Mask = 0xf000;

    /* for all the slices of N pixel each */
    for ( Slice = 0; Slice < 4; Slice++ )
    {
      /* generate a column */

      SineValue = SineTab[ SinePos++ ];
      if ( SinePos >= 124 )
      {
        SinePos = 0;
      } /* if */

      WaitBlitter();

      /* A = buffer, C = screen, D = screen, D = A OR C */
      Hardware_p->bltcon0 = 0xbfa;
      Hardware_p->bltcon1 = 0x0;

      Hardware_p->bltafwm = 0xffff;
      Hardware_p->bltalwm = Mask;

      switch ( OffScreenBuffer )
      {
        case 0:
          Hardware_p->bltapt = ( APTR ) &( DBuf[ 1 ][ 30720 + ( Source * 2 ) ] ); /* address of source (top left corner) */
          Hardware_p->bltcpt = ( APTR ) &( DBuf[ 0 ][ SineValue + ( Source * 2 ) ] ); /* address of source (top left corner) */
          Hardware_p->bltdpt = ( APTR ) &( DBuf[ 0 ][ SineValue + ( Source * 2 ) ] ); /* address of destination (top left corner) */
          break;

        case 1:
          Hardware_p->bltapt = ( APTR ) &( DBuf[ 0 ][ 30720 + ( Source * 2 ) ] ); /* address of source (top left corner) */
          Hardware_p->bltcpt = ( APTR ) &( DBuf[ 1 ][ SineValue + ( Source * 2 ) ] ); /* address of source (top left corner) */
          Hardware_p->bltdpt = ( APTR ) &( DBuf[ 1 ][ SineValue + ( Source * 2 ) ] ); /* address of destination (top left corner) */
          break;
      } /* switch */

      Hardware_p->bltamod = 42 - 2; /* mod bytes for source */
      Hardware_p->bltcmod = 40 - 2; /* mod bytes for source */
      Hardware_p->bltdmod = 40 - 2; /* mod bytes for destination */
      Hardware_p->bltsize = ( 16 << 6 ) + 1; /* UWORD size */

      Mask >>= 4;
    } /* for */
  } /* for */

  return;
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
  for ( I = 0, VSTART = 44 + 77; I < ( ( STARS * LAYERS ) * 4 ); I += 4, VSTART += 2 )
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

    if ( HSTART > 240 )
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






/* Amiga rules, EOF */
