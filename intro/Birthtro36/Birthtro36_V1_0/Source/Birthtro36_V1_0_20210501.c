/*
  Birthtro36.c V1.0 20210501
  (c) 2021   Massimiliano Scarano   mscarano@libero.it
  Support my projects for Amiga with a PayPal donation thanks.
  PayPal donate to mscarano@libero.it

  Coded by Massimiliano "AlienTech" Scarano for the Amiga demo group VOID.



  This intro shows how to make direct programming of the Commodore Amiga
  hardware using a mix of C and Assembly.
  It is designed like in the late 80s / early 90s.
  The Player Playroutine P6112 assembled with PhxAss V4.40.
  Compiled with SAS/C 6.58 and Includes release 40.13 (AmigaOS 3.1).
  Source code supplied for educational purpose only.



  It should work on any PAL Amiga, with a Motorola 68000 cpu and OCS chipset,
  and whatever OS (Kickstart + Workbench) version.
  Tested OK:
  - Amiga Forever 2013 (WinUAE, cycle exact emulation)
  -@@@ Amiga Forever 7 (WinUAE, cycle exact emulation)



  Version history:
  - V1.0 20210501, first public release



  Notes:
  - The intro should run at constant full frame rate (50 Hz),
    the screen is updated every frame.
  - Commodore Includes 40.13 were distributed with SAS/C 6.51.
  - RAW gfx format consists of all rows of the 1st bitplane, followed by all
    rows of the 2nd bitplane and so on.
  - Build with:
    > phxass p61.s
    > sc link Birthtro36_V1_?_YYYYMMDD.c p61.o

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

#define BITPLANE320x256   ( ( 320 * 256 ) / 8 ) /* size in bytes */
#define SCRATCHAREA336x16 ( ( 336 *  16 ) / 8 ) /* size in bytes */

/* define the blank padding space above the (expanded) scroll buffer, not visible on screen */
/* the same concept applies below the scroll buffer */
#define PADDINGH 0 /* minimum number of rows necessary (above the scroll buffer) to clear the background */
#define PADDINGAREA ( PADDINGH * 1 * 46 ) /* size in bytes */

/* define the blank padding space above the expanded scroll buffer, visible on screen */
#define PADDINGBPLAREA ( PADDINGH * 1 * 44 ) /* size in bytes */

#define STARS   8 /* number of stars for each parallax layer */
#define LAYERS  3 /* number of parallax layers */



const BYTE ID[] = "$VER: Birthtro36 V1.0 - 20210501 by   Massimiliano Scarano   mscarano@libero.it\n";



const UBYTE MsgText[] =
"VOID PROUDLY PRESENTS AN INTRO FOR AMIGA OCS CALLED > BIRTHTRO 36 <, LMB TO EXIT.\
 THIS INTRO IS DESIGNED LIKE IN THE LATE 80S AND IT IS TO CELEBRATE 36 YEARS OF AMIGA, 1985 - TODAY.\
 DEDICATED TO JOE DECUIR, ONE OF THE ORIGINAL DESIGNERS, HI AND THANKS.\
   CREDITS GO TO:\
   DESIGN, CODE: ALIENTECH / VOID\
   MUSIC LIGHTFORCE REMIX: DALEZY (ORIGINAL BY ROB HUBBARD)\
   P6112 MUSIC PLAYER ROUTINE: PHOTON AND OTHERS\
   TRON FONT: RINKYDINKELECTRONICS.COM\
   BOING BALL: CHAOSS  \
 GOLDEN GREETINGS: PCHELKA777, BLUE UNICORN, VINSOFT, INVENT.\
 LOVE TO ALL MEMBERS OF VOID AND TO OUR FRIENDS IN THE DEMOSCENE (HI POUET.NET).\
 PRODUCTION V1.0 20210501.\
 KEEP THE BALL ROLLING ;-)\
 NOW TEXT RESTARTS ... CIAO ... ... ... ...   ";



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
  BPLCON0, 0x2200, /* 2 bitplanes = 4 colors, Lowres 320x256 */

  /* BPLPOINTERS */
  BPL0PTH, 0x0000, BPL0PTL, 0x0000,
  BPL1PTH, 0x0000, BPL1PTL, 0x0000,
  BPL2PTH, 0x0000, BPL2PTL, 0x0000,
  BPL3PTH, 0x0000, BPL3PTL, 0x0000,
  BPL4PTH, 0x0000, BPL4PTL, 0x0000,

  /* PaletteRGB4 generated by PPaint 7.1 */
  COLOR00, 0x0000, COLOR01, 0x0444, COLOR02, 0x0C11, COLOR03, 0x0CCC,
  COLOR04, 0x0000, COLOR05, 0x0000, COLOR06, 0x0000, COLOR07, 0x0000,
  COLOR08, 0x0000, COLOR09, 0x0000, COLOR10, 0x0000, COLOR11, 0x0000,
  COLOR12, 0x0000, COLOR13, 0x0000, COLOR14, 0x0000, COLOR15, 0x0000,
  COLOR16, 0x0000, COLOR17, 0x0fff, COLOR18, 0x0999, COLOR19, 0x0555,
  COLOR20, 0x0000, COLOR21, 0x0000, COLOR22, 0x0000, COLOR23, 0x0000,
  COLOR24, 0x0000, COLOR25, 0x0000, COLOR26, 0x0000, COLOR27, 0x0000,
  COLOR28, 0x0000, COLOR29, 0x0000, COLOR30, 0x0000, COLOR31, 0x0000,

  /*@@@ WAIT special effects here ... */

  /* vertical color gradient */
  0x2c01, 0xfffe, COLOR00, 0x0008, /* 1st line of display window */
  0x2d01, 0xfffe, COLOR00, 0x0007,
  0x2e01, 0xfffe, COLOR00, 0x0006,
  0x2f01, 0xfffe, COLOR00, 0x0005,
  0x3001, 0xfffe, COLOR00, 0x0004,
  0x3101, 0xfffe, COLOR00, 0x0003,
  0x3201, 0xfffe, COLOR00, 0x0002,
  0x3301, 0xfffe, COLOR00, 0x0001,

  0x3401, 0xfffe, COLOR00, 0x0000,

  /* color of 36 */
  0x7001, 0xfffe, COLOR01, 0x0F90,
  0x7301, 0xfffe, COLOR01, 0x0F90,
  0x7401, 0xfffe, COLOR01, 0x0fb0,
  0x7701, 0xfffe, COLOR01, 0x0fb0,

  0x7801, 0xfffe, COLOR01, 0x0444,

  /* color of BIRTHTRO */
  0x7f01, 0xfffe, COLOR01, 0x0D00,
  0x8201, 0xfffe, COLOR01, 0x0D00,
  0x8301, 0xfffe, COLOR01, 0x0F80,
  0x8601, 0xfffe, COLOR01, 0x0F80,

  0x8701, 0xfffe, COLOR01, 0x0444,

  /* color of the bounce scroller */
  0xa701, 0xfffe, COLOR01, 0x061f,
  0xab01, 0xfffe, COLOR01, 0x061f,
  0xac01, 0xfffe, COLOR01, 0x0c1f,
  0xb001, 0xfffe, COLOR01, 0x0c1f,

  0xb101, 0xfffe, COLOR01, 0x0444,

  0xffdf, 0xfffe, COLOR00, 0x0000, /* line 255, we need to wait for last possible horizontal position in line */

  /* color of VOID */
  0x1001, 0xfffe, COLOR01, 0x061f,
  0x1301, 0xfffe, COLOR01, 0x061f,
  0x1401, 0xfffe, COLOR01, 0x0c1f,
  0x1701, 0xfffe, COLOR01, 0x0c1f,

  0x1801, 0xfffe, COLOR01, 0x0444,

  /* vertical color gradient */
  0x2401, 0xfffe, COLOR00, 0x0001, /* last 8 visible lines */
  0x2501, 0xfffe, COLOR00, 0x0002,
  0x2601, 0xfffe, COLOR00, 0x0003,
  0x2701, 0xfffe, COLOR00, 0x0004,
  0x2801, 0xfffe, COLOR00, 0x0005,
  0x2901, 0xfffe, COLOR00, 0x0006,
  0x2a01, 0xfffe, COLOR00, 0x0007,
  0x2b01, 0xfffe, COLOR00, 0x0008, /* last visible line */

  0x2c01, 0xfffe, COLOR00, 0x0000,

  0xffff, 0xfffe /* end */
};



/*
  - Values of the vertical positions of the bounce scrolltext.
  - From line 111 to line 143.
  - Values already multiplied by 40 for bitplane address.
*/
const UWORD SineTab[] = /* 124 */
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
  reused ( STARS * LAYERS ) times from VSTART=4c to VSTART=104.

  Each star consists of 14 words:
  word 1: hi byte VSTART (Y), low byte HSTART (X)
  word 2: hi byte VSTOP, low byte control
  word 3: image data line, bitplane 0
  word 4: image data line, bitplane 1
  ...
*/
UWORD chip Stars[] = /* ( ( STARS * LAYERS ) * 14 ) + 2 */
{
  /* each row is a sprite star */
  0x4c50, 0x5200, 0x2000, 0x0000, 0x3000, 0x0000, 0x7c00, 0x0000, 0xf800, 0x0000, 0x3000, 0x0000, 0x1000, 0x0000,
  0x5450, 0x5a00, 0x0000, 0x2000, 0x0000, 0x3000, 0x0000, 0x7c00, 0x0000, 0xf800, 0x0000, 0x3000, 0x0000, 0x1000,
  0x5c50, 0x6200, 0x2000, 0x2000, 0x3000, 0x3000, 0x7c00, 0x7c00, 0xf800, 0xf800, 0x3000, 0x3000, 0x1000, 0x1000,
  0x6450, 0x6a00, 0x2000, 0x0000, 0x3000, 0x0000, 0x7c00, 0x0000, 0xf800, 0x0000, 0x3000, 0x0000, 0x1000, 0x0000,
  0x6c50, 0x7200, 0x0000, 0x2000, 0x0000, 0x3000, 0x0000, 0x7c00, 0x0000, 0xf800, 0x0000, 0x3000, 0x0000, 0x1000,
  0x7450, 0x7a00, 0x2000, 0x2000, 0x3000, 0x3000, 0x7c00, 0x7c00, 0xf800, 0xf800, 0x3000, 0x3000, 0x1000, 0x1000,
  0x7c50, 0x8200, 0x2000, 0x0000, 0x3000, 0x0000, 0x7c00, 0x0000, 0xf800, 0x0000, 0x3000, 0x0000, 0x1000, 0x0000,
  0x8450, 0x8a00, 0x0000, 0x2000, 0x0000, 0x3000, 0x0000, 0x7c00, 0x0000, 0xf800, 0x0000, 0x3000, 0x0000, 0x1000,

  0x8c50, 0x9200, 0x2000, 0x2000, 0x3000, 0x3000, 0x7c00, 0x7c00, 0xf800, 0xf800, 0x3000, 0x3000, 0x1000, 0x1000,
  0x9450, 0x9a00, 0x2000, 0x0000, 0x3000, 0x0000, 0x7c00, 0x0000, 0xf800, 0x0000, 0x3000, 0x0000, 0x1000, 0x0000,
  0x9c50, 0xa200, 0x0000, 0x2000, 0x0000, 0x3000, 0x0000, 0x7c00, 0x0000, 0xf800, 0x0000, 0x3000, 0x0000, 0x1000,
  0xa450, 0xaa00, 0x2000, 0x2000, 0x3000, 0x3000, 0x7c00, 0x7c00, 0xf800, 0xf800, 0x3000, 0x3000, 0x1000, 0x1000,
  0xac50, 0xb200, 0x2000, 0x0000, 0x3000, 0x0000, 0x7c00, 0x0000, 0xf800, 0x0000, 0x3000, 0x0000, 0x1000, 0x0000,
  0xb450, 0xba00, 0x0000, 0x2000, 0x0000, 0x3000, 0x0000, 0x7c00, 0x0000, 0xf800, 0x0000, 0x3000, 0x0000, 0x1000,
  0xbc50, 0xc200, 0x2000, 0x2000, 0x3000, 0x3000, 0x7c00, 0x7c00, 0xf800, 0xf800, 0x3000, 0x3000, 0x1000, 0x1000,
  0xc450, 0xca00, 0x2000, 0x0000, 0x3000, 0x0000, 0x7c00, 0x0000, 0xf800, 0x0000, 0x3000, 0x0000, 0x1000, 0x0000,

  0xcc50, 0xd200, 0x0000, 0x2000, 0x0000, 0x3000, 0x0000, 0x7c00, 0x0000, 0xf800, 0x0000, 0x3000, 0x0000, 0x1000,
  0xd450, 0xda00, 0x2000, 0x2000, 0x3000, 0x3000, 0x7c00, 0x7c00, 0xf800, 0xf800, 0x3000, 0x3000, 0x1000, 0x1000,
  0xdc50, 0xe200, 0x2000, 0x0000, 0x3000, 0x0000, 0x7c00, 0x0000, 0xf800, 0x0000, 0x3000, 0x0000, 0x1000, 0x0000,
  0xe450, 0xea00, 0x0000, 0x2000, 0x0000, 0x3000, 0x0000, 0x7c00, 0x0000, 0xf800, 0x0000, 0x3000, 0x0000, 0x1000,
  0xec50, 0xf200, 0x2000, 0x2000, 0x3000, 0x3000, 0x7c00, 0x7c00, 0xf800, 0xf800, 0x3000, 0x3000, 0x1000, 0x1000,
  0xf450, 0xfa00, 0x2000, 0x0000, 0x3000, 0x0000, 0x7c00, 0x0000, 0xf800, 0x0000, 0x3000, 0x0000, 0x1000, 0x0000,
  0xfc50, 0x0202, 0x0000, 0x2000, 0x0000, 0x3000, 0x0000, 0x7c00, 0x0000, 0xf800, 0x0000, 0x3000, 0x0000, 0x1000,
  0x0450, 0x0a06, 0x2000, 0x2000, 0x3000, 0x3000, 0x7c00, 0x7c00, 0xf800, 0xf800, 0x3000, 0x3000, 0x1000, 0x1000,

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

UBYTE* Bob_p;
LONG BobSize;



void TakeSystem( void );
void RestoreSystem( void );
void WaitVB( void );
BOOL CheckLMBDown( void );
void ScrollText( UBYTE OffScreenBuffer );
UBYTE* ReadFile( BYTE* FileName_p, LONG* FileSize_p, ULONG MemType );
void PrintChar( UBYTE OffScreenBuffer, UBYTE CurrChar );
void Scroll( UBYTE OffScreenBuffer );
void WaitBlitter( void );
void PrintSysInfo( void );
void PrintCredits( void );
void BounceScroll( UBYTE OffScreenBuffer );
void RenderBBall( UBYTE OffScreenBuffer );
void InitStars( void );
void UpdateStars( UBYTE Layer );
void FadeStars( UBYTE Layer );



/*
*/
function int main( int argc, char* argv[] )
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
  if ( ( Pic_p = ReadFile( "DemoData/Logo320x256x4.raw", &PicSize, MEMF_CLEAR ) ) == NULL )
  {
    fprintf( stderr, "%s\n", "ReadFile() failed, image not loaded" );
    exit( EXIT_FAILURE );
  } /* if */

  /* load bitmap font */
  /* !"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ   59 chars */
  if ( ( Font_p = ReadFile( "DemoData/Font944x16x2.raw", &FontSize, MEMF_CHIP | MEMF_CLEAR ) ) == NULL )
  {
    fprintf( stderr, "%s\n", "ReadFile() failed, font not loaded" );
    exit( EXIT_FAILURE );
  } /* if */

  /* load module */
  if ( ( Mod_p = ReadFile( "DemoData/P61.lightforce_remix", &ModSize, MEMF_CHIP | MEMF_CLEAR ) ) == NULL )
  {
    fprintf( stderr, "%s\n", "ReadFile() failed, music not loaded" );
    exit( EXIT_FAILURE );
  } /* if */

  /* load bob */
  if ( ( Bob_p = ReadFile( "DemoData/Bob640x64x4.raw", &BobSize, MEMF_CHIP | MEMF_CLEAR ) ) == NULL )
  {
    fprintf( stderr, "%s\n", "ReadFile() failed, bob not loaded" );
    exit( EXIT_FAILURE );
  } /* if */

/*
printf( "<%d>\n", BobSize );
*/

  /* allocate the chip memory for bitplanes */
  for ( K = 0; K < 2; K++ )
  {
    if ( ( DBuf[ K ] = ( UBYTE* ) AllocMem( ( BITPLANE320x256 * 2 ) + SCRATCHAREA336x16 + ( PADDINGAREA * 2 ), MEMF_CHIP | MEMF_CLEAR ) ) == NULL )
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

  /* store the sprite pointer in the copper list */
  CopperList[ 1 ] = HIWORD( Stars );
  CopperList[ 3 ] = LOWORD( Stars );

  InitStars();

  PrintSysInfo(); /* No PS5 found ;) */

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

    P61_Music();

    ScrollText( ScreenBuffer ^ 1 );

    RenderBBall( ScreenBuffer ^ 1 );

    UpdateStars( 0 );   FadeStars( 0 );

    FramesCounter0 += 1;
    switch ( FramesCounter0 )
    {
      case 2:
        UpdateStars( 1 );   FadeStars( 1 );
        FramesCounter0 = 0;
        break;
    } /* switch */

    FramesCounter1 += 1;
    switch ( FramesCounter1 )
    {
      case 4:
        UpdateStars( 2 );   FadeStars( 2 );
        FramesCounter1 = 0;
        break;
    } /* switch */

    ScreenBuffer = ScreenBuffer ^ 1;

    switch ( ScreenBuffer )
    {
      case 0:
        /* store the bitplane pointers in the copper list */
        CopperList[ 51 ] = HIWORD( DBuf[ 0 ] );
        CopperList[ 53 ] = LOWORD( DBuf[ 0 ] );

        CopperList[ 55 ] = HIWORD( DBuf[ 0 ] + BITPLANE320x256 );
        CopperList[ 57 ] = LOWORD( DBuf[ 0 ] + BITPLANE320x256 );
        break;

      case 1:
        /* store the bitplane pointers in the copper list */
        CopperList[ 51 ] = HIWORD( DBuf[ 1 ] );
        CopperList[ 53 ] = LOWORD( DBuf[ 1 ] );

        CopperList[ 55 ] = HIWORD( DBuf[ 1 ] + BITPLANE320x256 );
        CopperList[ 57 ] = LOWORD( DBuf[ 1 ] + BITPLANE320x256 );
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
      FreeMem( DBuf[ K ], ( BITPLANE320x256 * 2 ) + SCRATCHAREA336x16 + ( PADDINGAREA * 2 ) );
    } /* if */
  } /* for */

  if ( Bob_p )
  {
    FreeMem( Bob_p, BobSize );
  } /* if */

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



  if ( ScrolledPixels == 0 )
  {
    CurrChar = MsgText[ CurrPos++ ];

    if ( CurrChar == '\0' )
    {
      CurrPos = 0;
      CurrChar = MsgText[ CurrPos++ ];
    } /* if */

    PrintChar( OffScreenBuffer, CurrChar );   ScrolledPixels += 4;

  } /* if */

  Scroll( OffScreenBuffer );   BounceScroll( OffScreenBuffer );

  if ( ++ScrolledPixels >= 12 )
  {
    ScrolledPixels = 0;
  } /* if */

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

Line  0 20480 ... 20521
Line  1 20522 ... 20563
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
Line 14 21068 ... 21109
Line 15 21110 ... 21151

*/
function void PrintChar( UBYTE OffScreenBuffer, UBYTE CurrChar )
{
  WaitBlitter();

  /* copy from channel A to channel D, with 4 pixels shift to left, descending mode */
  Hardware_p->bltcon0 = 0x49f0;
  Hardware_p->bltcon1 = 0x2;

  Hardware_p->bltafwm = 0xffff;
  Hardware_p->bltalwm = 0xffff;

  Hardware_p->bltapt = ( APTR ) &( Font_p[ ( CurrChar - 32 ) + ( CurrChar - 32 ) + 1770 ] ); /* address of source (right bottom corner of font char) */

  /* Destination = ( Line * BitplaneLengthBytes ) + BitplaneVisibleBytes */
  Hardware_p->bltdpt = ( APTR ) &( DBuf[ OffScreenBuffer ][ 21150 + PADDINGAREA ] ); /* address of destination (fixed right bottom corner in the bitplane) */

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

  /* copy from channel A to channel D, with 1 pixel shift to left, descending mode */
  Hardware_p->bltcon0 = 0x19f0; /*@@@ 0x29f0, 0010 1001 1111 0000 */
  Hardware_p->bltcon1 = 0x2;

  Hardware_p->bltafwm = 0xffff; /* whole */
  Hardware_p->bltalwm = 0x7fff; /* cancel left most bit */

  /* Source and Destination = ( Line * BitplaneLengthBytes ) + BitplaneVisibleBytes */
  /* source and destination are equal */
  Hardware_p->bltapt = ( APTR ) &( DBuf[ OffScreenBuffer ][ 21150 + PADDINGAREA ] ); /* address of source (bitplane) */
  Hardware_p->bltdpt = ( APTR ) &( DBuf[ OffScreenBuffer ^ 1 ][ 21150 + PADDINGAREA ] ); /* address of destination (bitplane) */

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
    fprintf( stdout, "%s\n", "CPU: 68060 / 68LC060 / 68EC060" );
  } /* if */
  else if ( SysBase_p->AttnFlags & AFF_68040 )
  {
    if ( SysBase_p->AttnFlags & AFF_FPU40 )
    {
      fprintf( stdout, "%s\n", "CPU: 68040" );
      fprintf( stdout, "%s\n", "FPU: 68040" );
    } /* if */
    else
    {
      fprintf( stdout, "%s\n", "CPU: 68LC040 / 68EC040" );
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
  fprintf( stdout, "%s\n", "Music Lightforce remix: Dalezy (original by Rob Hubbard)" );
  fprintf( stdout, "%s\n", "P6112 music player routine: Photon and others" );
  fprintf( stdout, "%s\n", "TRON font: rinkydinkelectronics.com" );
  fprintf( stdout, "%s\n", "Boing Ball: chaosS" );

  fprintf( stdout, "\n%s\n", "Please support my projects for Amiga with a PayPal donation to mscarano@libero.it thanks" );

  return;
}






/*
  - Bounce scroller.
    Possible optimizations for speed:
    * speed up the re-sets of the Blitter registers, by storing the values to poke in the cpu (done)
    * expanding the scroll buffer so that the blank padding space above and below would clear the background, to avoid a slow full-screen clear (done)
    *
*/
function void BounceScroll( UBYTE OffScreenBuffer )
{
  register UBYTE SinePos;
  register UWORD SineValue;
  static UBYTE SinePtr0 = 0; /* this is to use a different sine value each time */
  static UBYTE SinePtr1 = 0; /* this is to use a different sine value each time */

  register UBYTE* DBuf0_p = DBuf[ 0 ];
  register UBYTE* DBuf1_p = DBuf[ 1 ];

  register UWORD ExtraBlitSize = ( ( PADDINGH + 16 + PADDINGH ) << 6 ) + 20; /* UWORD size */



  if ( OffScreenBuffer == 0 )
  {
    SinePos = SinePtr0++;
    if ( SinePtr0 >= 124 )
    {
      SinePtr0 = 0;
    } /* if */

    /* for all the words / chars of the screen */

    SineValue = SineTab[ 115 ]; /* always use a fixed value, no bounce */

    WaitBlitter();

    /* copy operation */
    /* copy from channel A to channel D, no shifts, ascending mode */
    Hardware_p->bltcon0 = 0x9f0;
    Hardware_p->bltcon1 = 0x0;

    Hardware_p->bltafwm = 0xffff;
    Hardware_p->bltalwm = 0xffff;

    /* source is the expanded scroll buffer so that the blank padding space above and below would clear the background */
    Hardware_p->bltapt = ( APTR ) &( DBuf1_p[ 20480 ] ); /* address of source (top left corner) */
    Hardware_p->bltdpt = ( APTR ) &( DBuf0_p[ SineValue - PADDINGBPLAREA ] ); /* address of destination (top left corner) */

    Hardware_p->bltamod = 2; /* mod bytes for source */
    Hardware_p->bltdmod = 0; /* mod bytes for destination */
    Hardware_p->bltsize = ExtraBlitSize; /* UWORD size */

  } /* if */
  else if ( OffScreenBuffer == 1 )
  {
    SinePos = SinePtr1++;
    if ( SinePtr1 >= 124 )
    {
      SinePtr1 = 0;
    } /* if */

    /* for all the words / chars of the screen */

    SineValue = SineTab[ 115 ]; /* always use a fixed value, no bounce */

    WaitBlitter();

    /* copy operation */
    /* copy from channel A to channel D, no shifts, ascending mode */
    Hardware_p->bltcon0 = 0x9f0;
    Hardware_p->bltcon1 = 0x0;

    Hardware_p->bltafwm = 0xffff;
    Hardware_p->bltalwm = 0xffff;

    /* source is the expanded scroll buffer so that the blank padding space above and below would clear the background */
    Hardware_p->bltapt = ( APTR ) &( DBuf0_p[ 20480 ] ); /* address of source (top left corner) */
    Hardware_p->bltdpt = ( APTR ) &( DBuf1_p[ SineValue - PADDINGBPLAREA ] ); /* address of destination (top left corner) */

    Hardware_p->bltamod = 2; /* mod bytes for source */
    Hardware_p->bltdmod = 0; /* mod bytes for destination */
    Hardware_p->bltsize = ExtraBlitSize; /* UWORD size */

  } /* else if */

  return;
}






/*
  - One frame of the Boing Ball animation has to be shown for 5 frames in PAL.
  - Place bob at X=128, Y=1.
*/
function void RenderBBall( UBYTE OffScreenBuffer )
{
  static UBYTE AnimFrame = 0;
  static UBYTE FramesCounter = 0;



  /* plane 0 */

  WaitBlitter();

  /* copy from channel A to channel D, with 15 pixels shift to right, ascending mode */
  Hardware_p->bltcon0 = 0xf9f0;
  Hardware_p->bltcon1 = 0x0;

  Hardware_p->bltafwm = 0xffff;
  Hardware_p->bltalwm = 0xffff;

  Hardware_p->bltapt = ( APTR ) &( Bob_p[ 0 + ( AnimFrame * 10 ) ] ); /* address of source (top left corner) */

  /* Destination = ( Line * BitplaneLengthBytes ) + BitplaneVisibleBytes */
  Hardware_p->bltdpt = ( APTR ) &( DBuf[ OffScreenBuffer ][ 14 ] ); /* address of destination (fixed top left corner in the bitplane) */

  Hardware_p->bltamod = 80 - 10; /* mod = bytes to skip for source */
  Hardware_p->bltdmod = 40 - 10; /* mod = bytes to skip for destination */
  Hardware_p->bltsize = ( 64 << 6 ) + 5; /* UWORD rectangle size (h = 64 lines, w = 4 word), starts blit */



  /* plane 1 */

  WaitBlitter();

  /* copy from channel A to channel D, with 15 pixels shift to right, ascending mode */
  Hardware_p->bltcon0 = 0xf9f0;
  Hardware_p->bltcon1 = 0x0;

  Hardware_p->bltafwm = 0xffff;
  Hardware_p->bltalwm = 0xffff;

  Hardware_p->bltapt = ( APTR ) &( Bob_p[ 5120 + ( AnimFrame * 10 ) ] ); /* address of source (top left corner) */

  /* Destination = ( Line * BitplaneLengthBytes ) + BitplaneVisibleBytes */
  Hardware_p->bltdpt = ( APTR ) &( DBuf[ OffScreenBuffer ][ 10240 + 14 ] ); /* address of destination (fixed top left corner in the bitplane) */

  Hardware_p->bltamod = 80 - 10; /* mod = bytes to skip for source */
  Hardware_p->bltdmod = 40 - 10; /* mod = bytes to skip for destination */
  Hardware_p->bltsize = ( 64 << 6 ) + 5; /* UWORD rectangle size (h = 64 lines, w = 4 word), starts blit */



  if ( ++FramesCounter >= 5 )
  {
    FramesCounter = 0;
    if ( ++AnimFrame >= 8 )
    {
      AnimFrame = 0;
    } /* if */
  } /* if */

  return;
}






/*
  - Init random X of each star.
*/
function void InitStars( void )
{
  UWORD I;
  FLOAT X;
  UBYTE HSTART;



  srand( time( NULL ) );
  for ( I = 0; I < ( ( STARS * LAYERS ) * 14 ); I += 14 )
  {
    X = rand() / ( FLOAT ) RAND_MAX;
    HSTART = ( UBYTE ) ( X * 152 );
    HSTART += 64;

    Stars[ I + 0 ] |= HSTART;

/*
printf( "<%d>, %f, %0x, %0x\n", I, X, Stars[ I + 0 ], Stars[ I + 1 ] );
*/

  } /* for */

  return;
}






/*
  - Some hardcoded constants used.
*/
function void UpdateStars( UBYTE Layer )
{
  UWORD I;
  UBYTE HSTART;
  UBYTE VHBITS;
  static const UWORD EndLoop = ( STARS * LAYERS ) * 14;



  switch ( Layer )
  {
    case 0: /* front most */
      I = 0;
      break;

    case 1:
      I = 14;
      break;

    case 2:
      I = 28;
      break;
  } /* switch */



  for ( ; I < EndLoop; I += 42 )
  {
    HSTART = ( UBYTE ) ( Stars[ I + 0 ] & 0x00ff );
    VHBITS = ( UBYTE ) ( Stars[ I + 1 ] & 0x0001 );

    if ( HSTART >= 232 ) /* right border hit, HSTART = 232 */
    {
      HSTART = 48;
      VHBITS = 0;
    } /* if */
    else
    {
      VHBITS = VHBITS ^ 1;

      if ( VHBITS == 0 )
      {
        HSTART += 1;
      } /* if */
    } /* else */

    Stars[ I + 0 ] &= 0xff00;
    Stars[ I + 0 ] |= HSTART;
    Stars[ I + 1 ] &= 0xfffe;
    Stars[ I + 1 ] |= VHBITS;

  } /* for */



  return;
}






/*
  - Fade out, fade in.
*/
function void FadeStars( UBYTE Layer )
{
  static const UWORD FadeValues[] = { 0x0fff, 0x0eee, 0x0ddd, 0x0ccc, 0x0bbb, 0x0aaa, 0x0999, 0x0888,
                                      0x0777, 0x0666, 0x0555, 0x0444, 0x0333, 0x0222, 0x0111, 0x0000,
                                      0x0000, 0x0111, 0x0222, 0x0333, 0x0444, 0x0555, 0x0666, 0x0777,
                                      0x0888, 0x0999, 0x0aaa, 0x0bbb, 0x0ccc, 0x0ddd, 0x0eee, 0x0fff };
  static UBYTE Indexes[] = { 0, 6, 10 };



  switch ( Layer )
  {
    case 0: /* front most */
      CopperList[ 105 ] = FadeValues[ Indexes[ Layer ] ];
      if ( ++( Indexes[ Layer ] ) >= 32 )
      {
        Indexes[ Layer ] = 0;
      } /* if */
      break;

    case 1:
      CopperList[ 107 ] = FadeValues[ Indexes[ Layer ] ];
      if ( ++( Indexes[ Layer ] ) >= 26 )
      {
        Indexes[ Layer ] = 6;
      } /* if */
      break;

    case 2:
      CopperList[ 109 ] = FadeValues[ Indexes[ Layer ] ];
      if ( ++( Indexes[ Layer ] ) >= 22 )
      {
        Indexes[ Layer ] = 10;
      } /* if */
      break;
  } /* switch */

  return;
}






/* Amiga rules, EOF */
