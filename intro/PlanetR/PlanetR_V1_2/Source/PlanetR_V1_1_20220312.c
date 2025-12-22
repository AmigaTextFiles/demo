/*
  PlanetR.c V1.1 20220312
  (c) 2022   Massimiliano Scarano   mscarano@libero.it
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
  - V1.1 20220312, first public release



  Notes:
  - The intro should run at constant full frame rate (50 Hz),
    the screen is updated every frame.
  - Commodore Includes 40.13 were distributed with SAS/C 6.51.
  - RAW gfx format consists of all rows of the 1st bitplane, followed by all
    rows of the 2nd bitplane and so on.
  - Build with:
    > phxass p61.s
    > sc link PlanetR_V1_?_YYYYMMDD.c p61.o

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

#define BPL1PTH 0xe0
#define BPL1PTL 0xe2
#define BPL2PTH 0xe4
#define BPL2PTL 0xe6
#define BPL3PTH 0xe8
#define BPL3PTL 0xea
#define BPL4PTH 0xec
#define BPL4PTL 0xee
#define BPL5PTH 0xf0
#define BPL5PTL 0xf2
#define BPL6PTH 0xf4
#define BPL6PTL 0xf6

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

/* 2 screens A and B laid side by side, each screen is 368 pixels wide of which 352 are displayed, 320 + 32 for overscan + 16 for hw scroll */
#define BITPLANE736x192 ( ( ( 368 * 192 ) / 8 ) * 2 ) /* size in bytes */
#define BITPLANE352x32 ( ( 352 * 32 ) / 8 ) /* size in bytes */



const BYTE ID[] = "$VER: PlanetR V1.1 - 20220312 by   Massimiliano Scarano   mscarano@libero.it\n";



const UBYTE MsgText[] =
"THE VISITORS OF VOID PROUDLY PRESENT PLANET R AN INVITATION INTRO TO REVISION 2022 APRIL 15-18, LMB TO EXIT.\
 REVISION IS THE MOST IMPORTANT PLANET IN THE DEMOSCENE GALAXY AND IT IS VISITED BY OVER 30 ALIEN BREEDS EACH YEAR.\
 COMPETITIONS, SEMINARS, MUSIC AND SPECIAL EVENTS.\
 2022.REVISION-PARTY.NET\
   CREDITS:\
   CODE, LOGO: ALIENTECH / VOID\
   GRAPHICS: ASSETS OF THE GAME MENACE\
   MUSIC: JOHN STRINGER\
   P6112 MUSIC PLAYER ROUTINE: PHOTON AND OTHERS\
   FONT: RAM JAM  \
 COSMIC LOVE TO: PCHELKA777, BLUE UNICORN, VINSOFT, INVENT.\
 EXTRATERRESTRIAL GREETINGS TO: ALL MEMBERS OF VOID * NUKLEUS * NAH-KOLOR * EPHIDRENA * MOODS PLATEAU *\
 DESIRE * EXEC * PLANET JAZZ * REBELS * TEK * THE GANG * WANTED TEAM.\
 PRODUCTION V1.1 20220312.\
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
  /* Lowres 352 x 224 pixels with overscan */
  DIWSTRT, 0x1f78, /* top-left corner of the display window */
  DIWSTOP, 0xffc6, /* bottom-right corner of the display window */
  DDFSTRT, 0x0028, /* bitplane data fetch wait times (in cycles) from the start of the row */
  DDFSTOP, 0x00d8, /* bitplane data fetch wait times (in cycles) from the stop of the row */
  BPLCON1, 0x00ff, /* horizontal scroll, sets both playfield scroll values to 15,
                      as we want to scroll left we have to actually decrement the hardware scroll value,
                      incrementing it will scroll us right */
  BPLCON2, 0x0040, /* playfield 2 displayed over playfield 1 */
  /* the bitplane is 46 bytes wide */
  BPL1MOD, 0x002e, /* jump number of bytes in memory in order to read the next line of bitplane data, odd planes */
  BPL2MOD, 0x002e, /* jump number of bytes in memory in order to read the next line of bitplane data, even planes */

  /* define colors and resolution */
  BPLCON0, 0x6600, /* 6 planes with dual playfield mode activated */

  /* BPLPOINTERS */
  /* playfield 1 (back) */
  BPL1PTH, 0x0000, BPL1PTL, 0x0000,
  BPL3PTH, 0x0000, BPL3PTL, 0x0000,
  BPL5PTH, 0x0000, BPL5PTL, 0x0000,
  /* playfield 2 (front) */
  BPL2PTH, 0x0000, BPL2PTL, 0x0000,
  BPL4PTH, 0x0000, BPL4PTL, 0x0000,
  BPL6PTH, 0x0000, BPL6PTL, 0x0000,

  /* PaletteRGB4 generated by PPaint 7.1 */
  /* palette of playfield 1, colors 0-7 */
  COLOR00, 0x0332, COLOR01, 0x0055, COLOR02, 0x0543, COLOR03, 0x0000,
  COLOR04, 0x0F90, COLOR05, 0x0F90, COLOR06, 0x0F90, COLOR07, 0x0000,
  /* palette of playfield 2, colors 8-15 */
  COLOR08, 0x0000, COLOR09, 0x0F55, COLOR10, 0x0B05, COLOR11, 0x0700,
  COLOR12, 0x08A7, COLOR13, 0x0182, COLOR14, 0x0065, COLOR15, 0x0055,
  /* --- */
  COLOR16, 0x0000, COLOR17, 0x0000, COLOR18, 0x0000, COLOR19, 0x0000,
  COLOR20, 0x0000, COLOR21, 0x0000, COLOR22, 0x0000, COLOR23, 0x0000,
  COLOR24, 0x0000, COLOR25, 0x0000, COLOR26, 0x0000, COLOR27, 0x0000,
  COLOR28, 0x0000, COLOR29, 0x0000, COLOR30, 0x0000, COLOR31, 0x0000,

  /*@@@ WAIT special effects here ... */

  0x0a01, 0xfffe,

  /* After 192 lines have been displayed a copper change occurs which switches the display to a 16 colour one
     in which the logo is displayed.
     The logo is 352 x 32 pixels and it is implemented as a separate virtual screen. */

  0xdedf, 0xfffe,
  BPLCON1, 0x0000,
  BPLCON0, 0x4200,
  DDFSTRT, 0x0030,
  BPL1PTH, 0x0000, BPL1PTL, 0x0000,
  BPL2PTH, 0x0000, BPL2PTL, 0x0000,
  BPL3PTH, 0x0000, BPL3PTL, 0x0000,
  BPL4PTH, 0x0000, BPL4PTL, 0x0000,
  /* color 08-14 not used */
  COLOR00, 0x0000, COLOR01, 0x0FD4, COLOR02, 0x0FC3, COLOR03, 0x0DA2,
  COLOR04, 0x0C81, COLOR05, 0x0A60, COLOR06, 0x0941, COLOR07, 0x0830,
  COLOR08, 0x0000, COLOR09, 0x0000, COLOR10, 0x0000, COLOR11, 0x0000,
  COLOR12, 0x0000, COLOR13, 0x0000, COLOR14, 0x0000, COLOR15, 0x0F00,
  BPL1MOD, 0x0000,
  BPL2MOD, 0x0000,

  0xffdf, 0xfffe, /* line 255, we need to wait for last possible horizontal position in line */

  0xffff, 0xfffe /* end */
};



/* Map of background tiles. Each tile number is stored in 4 bits. */
const UBYTE BackgroundTable[] = /* 144 */
{
  0x01, 0x23, 0x01, 0x23, 0x01, 0x23, 0x01, 0x23, 0x01, 0x23, 0x01, 0x23,
  0x45, 0x67, 0x45, 0x67, 0x45, 0x67, 0x45, 0x67, 0x45, 0x67, 0x45, 0x67,
  0x89, 0xAB, 0x89, 0xAB, 0x89, 0xAB, 0x89, 0xAB, 0x89, 0xAB, 0x89, 0xAB,
  0x01, 0x23, 0x01, 0x23, 0x01, 0x23, 0x01, 0x23, 0x01, 0x23, 0x01, 0x23,
  0x45, 0x67, 0x45, 0x67, 0x45, 0x67, 0x45, 0x67, 0x45, 0x67, 0x45, 0x67,
  0x89, 0xAB, 0x89, 0xAB, 0x89, 0xAB, 0x89, 0xAB, 0x89, 0xAB, 0x89, 0xAB,
  0x01, 0x23, 0x01, 0x23, 0x01, 0x23, 0x01, 0x23, 0x01, 0x23, 0x01, 0x23,
  0x45, 0x67, 0x45, 0x67, 0x45, 0x67, 0x45, 0x67, 0x45, 0x67, 0x45, 0x67,
  0x89, 0xAB, 0x89, 0xAB, 0x89, 0xAB, 0x89, 0xAB, 0x89, 0xAB, 0x89, 0xAB,
  0x01, 0x23, 0x01, 0x23, 0x01, 0x23, 0x01, 0x23, 0x01, 0x23, 0x01, 0x23,
  0x45, 0x67, 0x45, 0x67, 0x45, 0x67, 0x45, 0x67, 0x45, 0x67, 0x45, 0x67,
  0x89, 0xAB, 0x89, 0xAB, 0x89, 0xAB, 0x89, 0xAB, 0x89, 0xAB, 0x89, 0xAB
};



const UWORD Backgrounds[ 12 ][ 2 ][ 16 ] =
{
  /* tile 16 x 16 pixels, 2 bitplanes */
  /* 1st bitplane */
  { { 0x1430, 0x0C30, 0x0C10, 0x0413, 0x8403, 0x4442, 0x2142, 0x3120,
      0x3110, 0x2810, 0x141C, 0x1417, 0x140B, 0x0C71, 0x0A00, 0xDC08 },
  /* 2nd bitplane */
    { 0x8A08, 0x9208, 0x0229, 0x8208, 0x4244, 0x2221, 0x12A1, 0x0891,
      0x0888, 0x148A, 0x0A03, 0x2A48, 0x8A44, 0x9208, 0x8524, 0x2204 } },

  { { 0x0210, 0x0230, 0x1118, 0x0118, 0x8128, 0x414C, 0x314C, 0x10CA,
      0x1005, 0x1013, 0x5103, 0x31C3, 0x5023, 0xD011, 0x3018, 0x6304 },
    { 0x0129, 0x0908, 0x0884, 0x0884, 0x4294, 0x22A2, 0x08A2, 0x0825,
      0x0842, 0x0908, 0x2880, 0xC824, 0x2890, 0x2808, 0x0904, 0x1092 } },

  { { 0x0300, 0x4220, 0x0461, 0x0451, 0x0850, 0x08C8, 0x38C8, 0x1848,
      0x0848, 0x0848, 0x0848, 0x08C8, 0x0148, 0x1050, 0xE060, 0x4041 },
    { 0x2084, 0x2110, 0x2210, 0x0228, 0x0429, 0x1424, 0x0424, 0x0424,
      0x8424, 0x8424, 0x8424, 0x8424, 0x80A4, 0x8828, 0x1011, 0x2420 } },

  { { 0x1430, 0x0C08, 0x0800, 0x0413, 0x8083, 0x4442, 0x2242, 0x2120,
      0x2110, 0x2810, 0x040C, 0x1487, 0x104B, 0x0C71, 0x0A10, 0xD908 },
    { 0x8A08, 0x9000, 0x042D, 0x8008, 0x4244, 0x2221, 0x1121, 0x0091,
      0x0888, 0x048A, 0x0A03, 0x2240, 0x8220, 0x9208, 0x8124, 0x2004 } },

  { { 0x7028, 0x6218, 0x8218, 0xC208, 0xC210, 0xC210, 0x6420, 0x2420,
      0x4820, 0x4820, 0x8843, 0x0882, 0x108C, 0x2118, 0x2220, 0x4421 },
    { 0x0914, 0x1104, 0x4104, 0x2504, 0x2508, 0x2508, 0x9250, 0x1250,
      0x2450, 0x2410, 0x4420, 0x8441, 0x0840, 0x1080, 0x1110, 0xA210 } },

  { { 0xC60C, 0xC60A, 0x4609, 0x2209, 0xA201, 0xA223, 0x9011, 0x901F,
      0x900C, 0x8C18, 0x0620, 0x060F, 0x0213, 0x0404, 0x1405, 0x1419 },
    { 0x2102, 0x2105, 0x2104, 0x5104, 0x5124, 0x5110, 0x4908, 0x4900,
      0x4902, 0x4204, 0x8912, 0x0900, 0x2508, 0x0212, 0x4A02, 0xEA04 } },

  { { 0x0080, 0x0100, 0x0110, 0x0918, 0x0A14, 0x0A33, 0x8A31, 0x0621,
      0x0220, 0x8204, 0x8204, 0x860D, 0x860A, 0x8A0C, 0x0108, 0x0101 },
    { 0x4940, 0x0888, 0x8888, 0x8484, 0x852A, 0x8508, 0x4508, 0x8110,
      0x4911, 0x4902, 0x490A, 0x4102, 0x4905, 0x4502, 0x8084, 0x9088 } },

  { { 0x7028, 0x4318, 0x8298, 0xC248, 0x8250, 0xC210, 0x6120, 0x20A0,
      0x5820, 0x4820, 0x8813, 0x188A, 0x108C, 0x2100, 0x2220, 0x4421 },
    { 0x0914, 0x1004, 0x4144, 0x2504, 0x4528, 0x2528, 0x9290, 0x1010,
      0x2010, 0x2410, 0x4428, 0x8405, 0x0842, 0x1080, 0x1100, 0xA210 } },

  { { 0x8820, 0x0440, 0x0204, 0x1202, 0x8221, 0x8220, 0x8300, 0x8410,
      0xC080, 0x0180, 0x20C0, 0x6040, 0x7060, 0x31A1, 0x2820, 0x2820 },
    { 0x4410, 0x8A24, 0x0122, 0x8921, 0x4910, 0x4110, 0x4090, 0x4208,
      0x2448, 0x8048, 0x1020, 0x1220, 0x0910, 0x0850, 0x9492, 0x1412 } },

  { { 0xCE02, 0x4A02, 0x5402, 0x0442, 0x0844, 0x9048, 0xE148, 0x4150,
      0x23A0, 0x31C4, 0x3185, 0x3842, 0x2820, 0x11A0, 0x23A0, 0x6322 },
    { 0x0101, 0x2501, 0x2A01, 0x9221, 0x9422, 0x68A4, 0x10A4, 0xA0A8,
      0x1050, 0x0822, 0x0842, 0x04A1, 0x1412, 0x8850, 0x5051, 0x1091 } },

  { { 0x3100, 0x11C0, 0x10C1, 0x10E1, 0x4862, 0x8850, 0x9850, 0x88F0,
      0xE830, 0x7031, 0x0028, 0x8248, 0x4088, 0x4018, 0x2018, 0x3018 },
    { 0x0881, 0x0821, 0x0820, 0x0810, 0x2411, 0x5429, 0x44A9, 0x4408,
      0x0408, 0x0808, 0x8114, 0x4124, 0x2144, 0x2104, 0x1224, 0x0844 } },

  { { 0xC820, 0x4440, 0x2204, 0x1002, 0x8225, 0x8224, 0x8308, 0x8418,
      0xC980, 0x1188, 0x20C4, 0x6040, 0x6260, 0x2121, 0x2820, 0x2820 },
    { 0x0410, 0xAA24, 0x1122, 0x8921, 0x4912, 0x0110, 0x4094, 0x4380,
      0x2448, 0x8844, 0x1020, 0x1220, 0x0110, 0x0850, 0x9492, 0x1412 } }
};



struct GfxBase* GfxBase_p;
struct DosLibrary* DOSBase_p;

struct Custom* Hardware_p;
struct View* OldView_p;
UWORD OldDmacon, OldIntena, OldIntreq, OldAdkcon;

/* video memory, no double buffer at the moment */
UBYTE* VMem;

UBYTE* Map_p;
LONG MapSize;

UBYTE* Graphics_p;
LONG GraphicsSize;

UBYTE* Logo_p;
LONG LogoSize;

UBYTE* Font_p;
LONG FontSize;

UBYTE* Mod_p;
LONG ModSize;



void TakeSystem( void );
void RestoreSystem( void );
void WaitVB( void );
BOOL CheckLMBDown( void );
UBYTE* ReadFile( BYTE* FileName_p, LONG* FileSize_p, ULONG MemType );
void WaitBlitter( void );
void PrintSysInfo( void );
void PrintCredits( void );
void DrawBackgroundCpu( void );
void ScrollBackground( void );
void HwScrollBackgroundLeft( void );
void ScrollForeground( void );
void HwScrollForegroundLeft( void );
void DrawStripCpu( UBYTE Tiles[ 12 ], UBYTE Col );
void DrawCharsCpu( const UBYTE Chars[ 2 ], UBYTE Col );



/*
*/
function int main( int argc, char* argv[] )
{
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

  /* load map of foreground tiles, allocate the best available cleared memory */
  if ( ( Map_p = ReadFile( "DemoData/map.dat", &MapSize, MEMF_CLEAR ) ) == NULL )
  {
    fprintf( stderr, "%s\n", "ReadFile() failed, map of foreground tiles not loaded" );
    exit( EXIT_FAILURE );
  } /* if */

  /* load bitmap foreground graphics */
  if ( ( Graphics_p = ReadFile( "DemoData/foregrounds.dat", &GraphicsSize, MEMF_CLEAR ) ) == NULL )
  {
    fprintf( stderr, "%s\n", "ReadFile() failed, foreground graphics not loaded" );
    exit( EXIT_FAILURE );
  } /* if */

  /* load bitmap picture */
  if ( ( Logo_p = ReadFile( "DemoData/Logo352x32x16.raw", &LogoSize, MEMF_CHIP | MEMF_CLEAR ) ) == NULL )
  {
    fprintf( stderr, "%s\n", "ReadFile() failed, image not loaded" );
    exit( EXIT_FAILURE );
  } /* if */

  /* load bitmap font */
  /* !"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ   59 chars */
  if ( ( Font_p = ReadFile( "DemoData/Metal.fnt", &FontSize, MEMF_CLEAR ) ) == NULL )
  {
    fprintf( stderr, "%s\n", "ReadFile() failed, font not loaded" );
    exit( EXIT_FAILURE );
  } /* if */

  /* load module */
  if ( ( Mod_p = ReadFile( "DemoData/P61.denaris (remix)", &ModSize, MEMF_CHIP | MEMF_CLEAR ) ) == NULL )
  {
    fprintf( stderr, "%s\n", "ReadFile() failed, music not loaded" );
    exit( EXIT_FAILURE );
  } /* if */

/*
printf( "<%d>\n", BobSize );
*/

  /* allocate the chip memory for bitplanes */

  if ( ( VMem = ( UBYTE* ) AllocMem( BITPLANE736x192 * 6, MEMF_CHIP | MEMF_CLEAR ) ) == NULL )
  {
    fprintf( stderr, "%s\n", "AllocMem() failed" );
    exit( EXIT_FAILURE );
  } /* if */



  DrawBackgroundCpu();



  /* set up a pointer to the hardware registers */
  Hardware_p = ( struct Custom* ) 0xdff000;

  /* store the bitplane pointers in the copper list */

  /* playfield 1 (back) */
  CopperList[ 51 ] = HIWORD( VMem + ( BITPLANE736x192 * 0 ) );
  CopperList[ 53 ] = LOWORD( VMem + ( BITPLANE736x192 * 0 ) );
  CopperList[ 55 ] = HIWORD( VMem + ( BITPLANE736x192 * 2 ) );
  CopperList[ 57 ] = LOWORD( VMem + ( BITPLANE736x192 * 2 ) );
  CopperList[ 59 ] = HIWORD( VMem + ( BITPLANE736x192 * 4 ) );
  CopperList[ 61 ] = LOWORD( VMem + ( BITPLANE736x192 * 4 ) );
  /* playfield 2 (front) */
  CopperList[ 63 ] = HIWORD( VMem + ( BITPLANE736x192 * 1 ) );
  CopperList[ 65 ] = LOWORD( VMem + ( BITPLANE736x192 * 1 ) );
  CopperList[ 67 ] = HIWORD( VMem + ( BITPLANE736x192 * 3 ) );
  CopperList[ 69 ] = LOWORD( VMem + ( BITPLANE736x192 * 3 ) );
  CopperList[ 71 ] = HIWORD( VMem + ( BITPLANE736x192 * 5 ) );
  CopperList[ 73 ] = LOWORD( VMem + ( BITPLANE736x192 * 5 ) );

  /* logo */
  CopperList[ 149 ] = HIWORD( Logo_p + ( BITPLANE352x32 * 0 ) );
  CopperList[ 151 ] = LOWORD( Logo_p + ( BITPLANE352x32 * 0 ) );
  CopperList[ 153 ] = HIWORD( Logo_p + ( BITPLANE352x32 * 1 ) );
  CopperList[ 155 ] = LOWORD( Logo_p + ( BITPLANE352x32 * 1 ) );
  CopperList[ 157 ] = HIWORD( Logo_p + ( BITPLANE352x32 * 2 ) );
  CopperList[ 159 ] = LOWORD( Logo_p + ( BITPLANE352x32 * 2 ) );
  CopperList[ 161 ] = HIWORD( Logo_p + ( BITPLANE352x32 * 3 ) );
  CopperList[ 163 ] = LOWORD( Logo_p + ( BITPLANE352x32 * 3 ) );

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

    HwScrollForegroundLeft();

    FramesCounter0 += 1;
    switch ( FramesCounter0 )
    {
      case 2:
        HwScrollBackgroundLeft();
        FramesCounter0 = 0;
        break;
    } /* switch */

    FramesCounter1 += 1;
    switch ( FramesCounter1 )
    {
      case 4:
        FramesCounter1 = 0;
        break;
    } /* switch */

    ScreenBuffer = ScreenBuffer ^ 1;

    switch ( ScreenBuffer )
    {
      case 0:
        break;

      case 1:
        break;
    } /* switch */

    P61_Music();

  } while ( ! CheckLMBDown() ); /* LMB ? */ /* do */



  P61_End();

  RestoreSystem();

  PrintCredits();

  if ( VMem )
  {
    FreeMem( VMem, BITPLANE736x192 * 6 );
  } /* if */

  if ( Mod_p )
  {
    FreeMem( Mod_p, ModSize );
  } /* if */

  if ( Font_p )
  {
    FreeMem( Font_p, FontSize );
  } /* if */

  if ( Logo_p )
  {
    FreeMem( Logo_p, LogoSize );
  } /* if */

  if ( Graphics_p )
  {
    FreeMem( Graphics_p, GraphicsSize );
  } /* if */

  if ( Map_p )
  {
    FreeMem( Map_p, MapSize );
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
  Hardware_p->dmacon = 0x8380; /* DMASET 1000001111000000 +
                                         1000001110000000 */



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
  fprintf( stdout, "%s\n", "Intro by VOID 2022" );

  return;
}






/*
  - At start the background screens A and B are both built identically using the cpu.
*/
function void DrawBackgroundCpu( void )
{
  UBYTE Row, Col;
  UBYTE Y, X;
  UBYTE Tile;
  UWORD ( * Dest ) [ 23 * 2 ]; /* sizeof *Dest = 92 bytes */
  UBYTE I;



  /* build planes of screens A and B */

  Row = 0;
  for ( Y = 0; Y < 12; Y++ ) /* 12 tiles per column */
  {
    Col = 0;
    for ( X = 0; X < 12; X++ ) /* 23 tiles per row */
    {
      Tile = BackgroundTable[ X + ( Y * 12 ) ] >> 4;

      /* write to plane 1 of screen A and B */
      Dest = ( UWORD ( * ) [ 23 * 2 ] ) VMem;
      for ( I = 0; I < 16; I++ )
      {
        Dest[ Row + I ][ Col ] = Backgrounds[ Tile ][ 0 ][ I ];
        Dest[ Row + I ][ Col + 23 ] = Backgrounds[ Tile ][ 0 ][ I ];
      } /* for */

      /* write to plane 2 of screen A and B */
      Dest = ( UWORD ( * ) [ 23 * 2 ] ) ( VMem + ( BITPLANE736x192 * 2 ) );
      for ( I = 0; I < 16; I++ )
      {
        Dest[ Row + I ][ Col ] = Backgrounds[ Tile ][ 1 ][ I ];
        Dest[ Row + I ][ Col + 23 ] = Backgrounds[ Tile ][ 1 ][ I ];
      } /* for */

      Col++;

      if ( X < 11 )
      {
        Tile = BackgroundTable[ X + ( Y * 12 ) ] & 15;

        /* write to plane 1 of screen A and B */
        Dest = ( UWORD ( * ) [ 23 * 2 ] ) VMem;
        for ( I = 0; I < 16; I++ )
        {
          Dest[ Row + I ][ Col ] = Backgrounds[ Tile ][ 0 ][ I ];
          Dest[ Row + I ][ Col + 23 ] = Backgrounds[ Tile ][ 0 ][ I ];
        } /* for */

        /* write to plane 2 of screen A and B */
        Dest = ( UWORD ( * ) [ 23 * 2 ] ) ( VMem + ( BITPLANE736x192 * 2 ) );
        for ( I = 0; I < 16; I++ )
        {
          Dest[ Row + I ][ Col ] = Backgrounds[ Tile ][ 1 ][ I ];
          Dest[ Row + I ][ Col + 23 ] = Backgrounds[ Tile ][ 1 ][ I ];
        } /* for */

        Col++;

      } /* if */
    } /* for */
    Row += 16;
  } /* for */

  return;
}






/*
  - The background is a simple wrap scroll where whatever gets scrolled off on the left reappears again on the right.
*/
function void ScrollBackground( void )
{
  HwScrollBackgroundLeft();

  return;
}






/*
  - Hardware scroll the display.
*/
function void HwScrollBackgroundLeft( void )
{
  static BYTE Scroll = 15; /* pixels to scroll */
  static UBYTE Count = 0; /* screen position in words */
  static UWORD Pos = 0; /* text position */
  UBYTE* Plane1;
  UBYTE* Plane3;
  UBYTE* Plane5;



  /* scroll 1 pixel to the left */
  Scroll--;

  /* if we have scrolled 16 pixels reset initial values */

  if ( Scroll < 0 )
  {
    Plane1 = VMem + ( BITPLANE736x192 * 0 );
    Plane3 = VMem + ( BITPLANE736x192 * 2 );
    Plane5 = VMem + ( BITPLANE736x192 * 4 );

    Scroll = 15;

    Count++;

    if ( Count == 23 )
    {
      Count = 0;
    } /* if */
    else
    {
      Plane1 += Count + Count;
      Plane3 += Count + Count;
      Plane5 += Count + Count;
    } /* else */

    /* playfield 1 (back) */
    CopperList[ 51 ] = HIWORD( Plane1 );
    CopperList[ 53 ] = LOWORD( Plane1 );
    CopperList[ 55 ] = HIWORD( Plane3 );
    CopperList[ 57 ] = LOWORD( Plane3 );
    CopperList[ 59 ] = HIWORD( Plane5 );
    CopperList[ 61 ] = LOWORD( Plane5 );
  } /* if */

  /* store the new scroll value into the copper list */
  CopperList[ 41 ] &= 0x00f0;
  CopperList[ 41 ] |= Scroll;

  if ( Scroll == 14 )
  {
    DrawCharsCpu( &( MsgText[ Pos ] ), 46 + Count + Count );
  } /* if */
  else if ( Scroll == 0 )
  {
    DrawCharsCpu( &( MsgText[ Pos ] ), Count + Count );
    Pos += 1;
    if ( MsgText[ Pos ] == '\0' )
    {
      Pos = 0;
    } /* if */
    else
    {
      Pos += 1;
      if ( MsgText[ Pos ] == '\0' )
      {
        Pos = 0;
      } /* if */
    } /* else */
  } /* else if */

  return;
}






/*
  - The foreground area is made up from a map.
*/
function void ScrollForeground( void )
{
  HwScrollForegroundLeft();

  return;
}






/*
  - Hardware scroll the display.
*/
function void HwScrollForegroundLeft( void )
{
  static BYTE Scroll = 15; /* pixels to scroll */
  static UBYTE Count = 0; /* screen position in words */
  static UWORD Pos = 0; /* map position */
  UBYTE* Plane2;
  UBYTE* Plane4;
  UBYTE* Plane6;



  /* scroll 1 pixel to the left */
  Scroll--;

  /* if we have scrolled 16 pixels reset initial values */

  if ( Scroll < 0 )
  {
    Plane2 = VMem + ( BITPLANE736x192 * 1 );
    Plane4 = VMem + ( BITPLANE736x192 * 3 );
    Plane6 = VMem + ( BITPLANE736x192 * 5 );

    Scroll = 15;

    Count++;

    if ( Count == 23 )
    {
      Count = 0;
    } /* if */
    else
    {
      Plane2 += Count + Count;
      Plane4 += Count + Count;
      Plane6 += Count + Count;
    } /* else */

    /* playfield 2 (front) */
    CopperList[ 63 ] = HIWORD( Plane2 );
    CopperList[ 65 ] = LOWORD( Plane2 );
    CopperList[ 67 ] = HIWORD( Plane4 );
    CopperList[ 69 ] = LOWORD( Plane4 );
    CopperList[ 71 ] = HIWORD( Plane6 );
    CopperList[ 73 ] = LOWORD( Plane6 );
  } /* if */

  /* store the new scroll value into the copper list */
  CopperList[ 41 ] &= 0x000f;
  CopperList[ 41 ] |= ( Scroll << 4 );

  if ( Scroll == 14 )
  {
    /* init, draw a column to the right */
    DrawStripCpu( &( Map_p[ Pos ] ), 23 + Count );
  } /* if */
  else if ( Scroll == 0 )
  {
    /* draw a column to the left, increment map position */
    DrawStripCpu( &( Map_p[ Pos ] ), Count );
    Pos += 12;
    if ( Map_p[ Pos ] == 255 ) /* 255 means end of level */
    {
      Pos = 0;
    } /* if */
  } /* else if */

  return;
}






/*
  - Draw a strip (16 x 192 pixels) just to the right or to the left of where we are displaying.
*/
function void DrawStripCpu( UBYTE Tiles[ 12 ], UBYTE Col )
{
  UWORD ( * DestPlane2 ) [ 46 ]; /* sizeof *DestPlane2 = 92 bytes */
  UWORD ( * DestPlane4 ) [ 46 ]; /* sizeof *DestPlane4 = 92 bytes */
  UWORD ( * DestPlane6 ) [ 46 ]; /* sizeof *DestPlane6 = 92 bytes */
  UWORD ( * Src ) [ 3 ][ 16 ]; /* sizeof *Src = 96 bytes */
  UBYTE Row;
  register UBYTE I;
  UBYTE Tile;
  register UBYTE J;



  DestPlane2 = ( UWORD ( * ) [ 46 ] ) ( VMem + ( BITPLANE736x192 * 1 ) );
  DestPlane4 = ( UWORD ( * ) [ 46 ] ) ( VMem + ( BITPLANE736x192 * 3 ) );
  DestPlane6 = ( UWORD ( * ) [ 46 ] ) ( VMem + ( BITPLANE736x192 * 5 ) );

  Src = ( UWORD ( * ) [ 3 ][ 16 ] ) Graphics_p;

  Row = 0;
  for ( I = 0; I < 12; I++ )
  {
    Tile = Tiles[ I ];

    /* write to planes of screen A and B */

    for ( J = 0; J < 16; J++ )
    {
      DestPlane2[ Row + J ][ Col ] = Src[ Tile ][ 0 ][ J ];
      DestPlane4[ Row + J ][ Col ] = Src[ Tile ][ 1 ][ J ];
      DestPlane6[ Row + J ][ Col ] = Src[ Tile ][ 2 ][ J ];
    } /* for */

    Row += 16;

  } /* for */

  return;
}






/*
  - Draw 2 chars (each char is 8 x 8 pixels) just to the right or to the left of where we are displaying.
*/
function void DrawCharsCpu( const UBYTE Chars[ 2 ], UBYTE Col )
{
  UBYTE ( * DestPlane5 ) [ 92 ]; /* sizeof *DestPlane5 = 92 bytes */
  UBYTE CurrChar;
  UWORD Pos; /* font position */
  register UBYTE I;



  DestPlane5 = ( UBYTE ( * ) [ 92 ] ) ( VMem + ( BITPLANE736x192 * 4 ) );

  if ( Chars[ 0 ] == '\0' )
  {
    return;
  } /* if */
  CurrChar = Chars[ 0 ];
  Pos = ( ( CurrChar - 32 ) << 3 ); /* * 8 */
  for ( I = 0; I < 8; I++ )
  {
    DestPlane5[ 96 + I ][ Col ] = Font_p[ Pos + I ];
  } /* for */

  if ( Chars[ 1 ] == '\0' )
  {
    return;
  } /* if */
  CurrChar = Chars[ 1 ];
  Pos = ( ( CurrChar - 32 ) << 3 ); /* * 8 */
  for ( I = 0; I < 8; I++ )
  {
    DestPlane5[ 96 + I ][ Col + 1 ] = Font_p[ Pos + I ];
  } /* for */

  return;
}






/* Amiga rules, EOF */
