/*
  LiquidMIG.c V1.0 20170517
  (c) 2017   Massimiliano Scarano   mscarano@libero.it
  Support my projects for Amiga with a PayPal donation thanks.
  PayPal donate to mscarano@libero.it



  This demo shows how to make direct programming of the Commodore Amiga hardware using C language.
  It is designed like in the early 90s.
  It consists of the following "old-school" effects:
  - color cycling animation (cpu and copper)
  - color gradients (copper)
  - font text scroll (blitter)
  - ambient sounds (paula)
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



  Notes:
  - My Minimig configuration:
    Bootloader   BYQ100413
    FPGA core    FYQ100818
    ARM Firmware AYQ100818
  - The demo should run at constant full frame rate (50 Hz),
    the screen is updated every frame.
  - Commodore Includes 40.13 were distributed with SAS/C 6.51.
  - RAW gfx format consists of all rows of the 1st bitplane, followed by all rows of the 2nd bitplane and so on.

*/



/*
  Special internal note:
  - Minimig demo makes use of a wider bitplane, altough it doesn' t affect the demo functioning it is
    unnecessary and it consumes more memory than actually needed.
    It has been left there while experimenting with BPL1MOD.

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

#define BITPLANE336x256 ( 10240 + ( 2 * 256 ) ) /* size in bytes */



const BYTE ID[] = "$VER: LiquidMig V1.0 - 20170517 by   Massimiliano Scarano   mscarano@libero.it\n";



const UBYTE MsgText[] =
"ALIENTECH PROUDLY PRESENTS A DEMO CALLED LIQUIDMIG, LEFT MOUSE BUTTON TO EXIT.\
 DEMO V1.0 RELEASED 17-MAY-2017.\
 DEMO WRITTEN IN C LANGUAGE WITH DIRECT PROGRAMMING OF THE COMMODORE AMIGA HARDWARE.\
 DEMO NAME INSPIRED BY LIQUIDPAD FOR IPAD.\
 THIS PRODUCTION IS A TRIBUTE TO THE WONDERFUL GRAPHICS OF INVENT.\
 HI MATE, READY FOR A MENACE REMAKE FOR THE C= A500 OCS 1 MB?\
 CREDITS:\
 DESIGN, CODE: ALIENTECH\
 IMAGE: INVENT\
 FONT: WWW.RINKYDINELECTRONICS.COM\
 SOUNDS: SEP800.MINE.NU\
 GREETINGS: MY WIFE AND DAUGHTER, INVENT, VINSOFT, ASZU,\
 ALL THE AMIGANS MET AT THE RETRO RARITY C= DAY 23-APR-2017 AT VIGAMUS IN ROME.\
 PLEASE SUPPORT MY PROJECTS FOR AMIGA WITH A PAYPAL DONATION TO MSCARANO@LIBERO.IT THANKS.\
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
  /* the bitplane is 42 bytes wide but only 40 are visible thus the mod is 42 - 40 */
  BPL1MOD, 0x0002, /* jump number of bytes in memory in order to read the next line of bitplane data, odd planes */
  BPL2MOD, 0x0002, /* jump number of bytes in memory in order to read the next line of bitplane data, even planes */

  /* define colors and resolution */
  BPLCON0, 0x5200, /* 5 bitplanes = 32 colors, Lowres 320x256 */

  /* BPLPOINTERS */
  BPL0PTH, 0x0000, BPL0PTL, 0x0000,
  BPL1PTH, 0x0000, BPL1PTL, 0x0000,
  BPL2PTH, 0x0000, BPL2PTL, 0x0000,
  BPL3PTH, 0x0000, BPL3PTL, 0x0000,
  BPL4PTH, 0x0000, BPL4PTL, 0x0000,

  /* palette generated by KEFCON IFF-Converter V1.35
  COLOR00, 0x0000, COLOR01, 0x0110, COLOR02, 0x0222, COLOR03, 0x0340,
  COLOR04, 0x0462, COLOR05, 0x0683, COLOR06, 0x05bc, COLOR07, 0x07dd,
  COLOR08, 0x0afe, COLOR09, 0x0343, COLOR10, 0x0555, COLOR11, 0x0676,
  COLOR12, 0x0898, COLOR13, 0x06dc, COLOR14, 0x04ac, COLOR15, 0x0288,
  COLOR16, 0x0065, COLOR17, 0x0054, COLOR18, 0x0144, COLOR19, 0x0376,
  COLOR20, 0x05a9, COLOR21, 0x08fd, COLOR22, 0x0011, COLOR23, 0x0022,
  COLOR24, 0x0033, COLOR25, 0x0144, COLOR26, 0x0366, COLOR27, 0x0488,
  COLOR28, 0x06aa, COLOR29, 0x0010, COLOR30, 0x0afa, COLOR31, 0x0fc0,
  */

  /* PaletteRGB4 generated by PPaint 7.1 */
  COLOR00, 0x0000, COLOR01, 0x0120, COLOR02, 0x0232, COLOR03, 0x0341,
  COLOR04, 0x0462, COLOR05, 0x0684, COLOR06, 0x05BC, COLOR07, 0x07CD,
  COLOR08, 0x0AEE, COLOR09, 0x0443, COLOR10, 0x0555, COLOR11, 0x0776,
  COLOR12, 0x0898, COLOR13, 0x06CC, COLOR14, 0x04AB, COLOR15, 0x0288,
  COLOR16, 0x0065, COLOR17, 0x0155, COLOR18, 0x0244, COLOR19, 0x0376,
  COLOR20, 0x05A9, COLOR21, 0x08FD, COLOR22, 0x0011, COLOR23, 0x0022,
  COLOR24, 0x0033, COLOR25, 0x0155, COLOR26, 0x0366, COLOR27, 0x0488,
  COLOR28, 0x06AA, COLOR29, 0x0110, COLOR30, 0x0AFA, COLOR31, 0x0FC0,

  /* @@@ WAIT special effects here ... */

  /* 0x2c01, 0xff00, COLOR01, 0x0f00, * 1st line of display window */

  0xffdf, 0xfffe, COLOR00, 0x0000, /* line 255 */

  /* vertical gradient, COLOR01 changed every 2 lines */
  0x1d01, 0xfffe, COLOR01, 0x00aa, /* last 16 visible lines */
  0x1f01, 0xfffe, COLOR01, 0x0099,
  0x2101, 0xfffe, COLOR01, 0x0088,
  0x2301, 0xfffe, COLOR01, 0x0077,
  0x2501, 0xfffe, COLOR01, 0x0066,
  0x2701, 0xfffe, COLOR01, 0x0060,
  0x2901, 0xfffe, COLOR01, 0x0070,
  0x2b01, 0xfffe, COLOR01, 0x0fff, /* last visible line */

  0x2c01, 0xfffe, COLOR01, 0x0120,

  0xffff, 0xfffe /* end */
};



struct GfxBase* GfxBase_p;
struct DosLibrary* DOSBase_p;

struct Custom* Hardware_p;
struct View* OldView_p;
UWORD OldDmacon, OldIntena, OldIntreq, OldAdkcon;

UBYTE* DBuf[ 2 ]; /* double buffer, screen buffer 0, screen buffer 1 */

UBYTE* Pic_p;
LONG PicSize; /* ( 10240 + ( 2 * 256 ) ) * 5 = 53760 bytes */

UBYTE* Font_p;
LONG FontSize;

UBYTE* Sample0_p;
LONG Sample0Size;

UBYTE* Sample1_p;
LONG Sample1Size;



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
void CycleColors( void );
void PlaySample( UBYTE Channel, UBYTE* Sample_p, LONG SampleSize, UWORD SampleRate, UWORD SampleVolume );



/*
*/
function main()
{
  UBYTE K;
  UBYTE ScreenBuffer;
  UBYTE FramesCounter;



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
  if ( ( Pic_p = ReadFile( "DemoData/Image336x256x32_v6b.raw", &PicSize, MEMF_CLEAR ) ) == NULL )
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

  /* load sample */
  if ( ( Sample0_p = ReadFile( "DemoData/Smallwaterfall.8000.raw", &Sample0Size, MEMF_CHIP | MEMF_CLEAR ) ) == NULL )
  {
    fprintf( stderr, "%s\n", "ReadFile() failed, sample 0 not loaded" );
    exit( EXIT_FAILURE );
  } /* if */

  /* load sample */
  if ( ( Sample1_p = ReadFile( "DemoData/Waterflow.11030.raw", &Sample1Size, MEMF_CHIP | MEMF_CLEAR ) ) == NULL )
  {
    fprintf( stderr, "%s\n", "ReadFile() failed, sample 1 not loaded" );
    exit( EXIT_FAILURE );
  } /* if */

  /* allocate the chip memory for bitplanes */
  for ( K = 0; K < 2; K++ )
  {
    if ( ( DBuf[ K ] = ( UBYTE* ) AllocMem( BITPLANE336x256 * 5, MEMF_CHIP | MEMF_CLEAR ) ) == NULL )
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
  CopperList[ 51 ] = HIWORD( DBuf[ 1 ] + ( BITPLANE336x256 * 0 ) );
  CopperList[ 53 ] = LOWORD( DBuf[ 1 ] + ( BITPLANE336x256 * 0 ) );

  CopperList[ 55 ] = HIWORD( DBuf[ 1 ] + ( BITPLANE336x256 * 1 ) );
  CopperList[ 57 ] = LOWORD( DBuf[ 1 ] + ( BITPLANE336x256 * 1 ) );

  CopperList[ 59 ] = HIWORD( DBuf[ 1 ] + ( BITPLANE336x256 * 2 ) );
  CopperList[ 61 ] = LOWORD( DBuf[ 1 ] + ( BITPLANE336x256 * 2 ) );

  CopperList[ 63 ] = HIWORD( DBuf[ 1 ] + ( BITPLANE336x256 * 3 ) );
  CopperList[ 65 ] = LOWORD( DBuf[ 1 ] + ( BITPLANE336x256 * 3 ) );

  CopperList[ 67 ] = HIWORD( DBuf[ 1 ] + ( BITPLANE336x256 * 4 ) );
  CopperList[ 69 ] = LOWORD( DBuf[ 1 ] + ( BITPLANE336x256 * 4 ) );

  PrintSysInfo(); /* No PS4 found ;) */

  TakeSystem();
  PlaySample( 0, Sample0_p, Sample0Size, 8000, 64 );
  PlaySample( 1, Sample1_p, Sample1Size, 11030, 64 );



  ScreenBuffer = 1;
  FramesCounter = 0;

  /* main loop */
  /* it should run at constant full frame rate (50 Hz) */
  do
  {
    WaitVB(); /* scan line 300 ? */

    /*@@@ demo effects here @@@*/

    ScrollText( ScreenBuffer ^ 1 );

    FramesCounter += 1;
    switch ( FramesCounter )
    {
      case 10: /* 4 */
        CycleColors();
        FramesCounter = 0;
        break;
    } /* switch */

    ScreenBuffer = ScreenBuffer ^ 1;

    switch ( ScreenBuffer )
    {
      case 0:
        /* store the bitplane pointers in the copper list */
        CopperList[ 51 ] = HIWORD( DBuf[ 0 ] + ( BITPLANE336x256 * 0 ) );
        CopperList[ 53 ] = LOWORD( DBuf[ 0 ] + ( BITPLANE336x256 * 0 ) );

        CopperList[ 55 ] = HIWORD( DBuf[ 0 ] + ( BITPLANE336x256 * 1 ) );
        CopperList[ 57 ] = LOWORD( DBuf[ 0 ] + ( BITPLANE336x256 * 1 ) );

        CopperList[ 59 ] = HIWORD( DBuf[ 0 ] + ( BITPLANE336x256 * 2 ) );
        CopperList[ 61 ] = LOWORD( DBuf[ 0 ] + ( BITPLANE336x256 * 2 ) );

        CopperList[ 63 ] = HIWORD( DBuf[ 0 ] + ( BITPLANE336x256 * 3 ) );
        CopperList[ 65 ] = LOWORD( DBuf[ 0 ] + ( BITPLANE336x256 * 3 ) );

        CopperList[ 67 ] = HIWORD( DBuf[ 0 ] + ( BITPLANE336x256 * 4 ) );
        CopperList[ 69 ] = LOWORD( DBuf[ 0 ] + ( BITPLANE336x256 * 4 ) );
        break;

      case 1:
        /* store the bitplane pointers in the copper list */
        CopperList[ 51 ] = HIWORD( DBuf[ 1 ] + ( BITPLANE336x256 * 0 ) );
        CopperList[ 53 ] = LOWORD( DBuf[ 1 ] + ( BITPLANE336x256 * 0 ) );

        CopperList[ 55 ] = HIWORD( DBuf[ 1 ] + ( BITPLANE336x256 * 1 ) );
        CopperList[ 57 ] = LOWORD( DBuf[ 1 ] + ( BITPLANE336x256 * 1 ) );

        CopperList[ 59 ] = HIWORD( DBuf[ 1 ] + ( BITPLANE336x256 * 2 ) );
        CopperList[ 61 ] = LOWORD( DBuf[ 1 ] + ( BITPLANE336x256 * 2 ) );

        CopperList[ 63 ] = HIWORD( DBuf[ 1 ] + ( BITPLANE336x256 * 3 ) );
        CopperList[ 65 ] = LOWORD( DBuf[ 1 ] + ( BITPLANE336x256 * 3 ) );

        CopperList[ 67 ] = HIWORD( DBuf[ 1 ] + ( BITPLANE336x256 * 4 ) );
        CopperList[ 69 ] = LOWORD( DBuf[ 1 ] + ( BITPLANE336x256 * 4 ) );
        break;
    } /* switch */

  } while ( ! CheckLMBDown() ); /* LMB ? */ /* do */



  RestoreSystem();

  PrintCredits();

  for ( K = 0; K < 2; K++ )
  {
    if ( DBuf[ K ] )
    {
      FreeMem( DBuf[ K ], BITPLANE336x256 * 5 );
    } /* if */
  } /* for */

  if ( Sample1_p )
  {
    FreeMem( Sample1_p, Sample1Size );
  } /* if */

  if ( Sample0_p )
  {
    FreeMem( Sample0_p, Sample0Size );
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
  Hardware_p->intena = 0x7fff; /* INTENASET 1100000000100000 +
                                            1100000000000000 */

/*
10) Turn on DMA and interrupts you require
*/
  Hardware_p->dmacon = 0x83c0; /* DMASET 1000001111100000 +
                                         1000001111000000 */



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
  - While in Minimig demo the cpu was used for the 8x8 font text scroller,
    this time the blitter is used for this 16x16 font text scroller.
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

      Scroll( 0 );

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

      Scroll( 1 );

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

Line 240 10080 ... 10121
Line 241 10122 ... 10163
Line 242 ...
Line 243 ...
Line 244 ...
Line 245 ...
Line 246 ...
Line 247 ...
Line 248 ...
Line 249 ...
Line 250 ...
Line 251 ...
Line 252 ...
Line 253 ...
Line 254 10668 ... 10709
Line 255 10710 ... 10751

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
      Hardware_p->bltdpt = ( APTR ) &( DBuf[ 0 ][ 10120 ] ); /* address of destination (fixed top left corner in the bitplane) */
      break;

    case 1:
      Hardware_p->bltdpt = ( APTR ) &( DBuf[ 1 ][ 10120 ] ); /* address of destination (fixed top left corner in the bitplane) */
      break;
  } /* switch */

  Hardware_p->bltamod = 118 - 2; /* mod = bytes to skip for source */
  Hardware_p->bltdmod = 42 - 2; /* mod = bytes to skip for destination */
  Hardware_p->bltsize = ( 16 << 6 ) + 1; /* UWORD rectangle size (h = 16 lines, w = 1 word), starts blit */

  return;
}






/*
  - Each call scrolls the text 1 pixel to left.
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
      Hardware_p->bltapt = ( APTR ) &( DBuf[ 0 ][ 10750 ] ); /* address of source (bitplane) */
      Hardware_p->bltdpt = ( APTR ) &( DBuf[ 0 ][ 10750 ] ); /* address of destination (bitplane) */
      break;

    case 1:
      /* source and destination are equal */
      Hardware_p->bltapt = ( APTR ) &( DBuf[ 1 ][ 10750 ] ); /* address of source (bitplane) */
      Hardware_p->bltdpt = ( APTR ) &( DBuf[ 1 ][ 10750 ] ); /* address of destination (bitplane) */
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
  - Makes a copy of the scroll area.
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
      Hardware_p->bltapt = ( APTR ) &( DBuf[ 1 ][ 10080 ] ); /* address of source (top left corner) */
      Hardware_p->bltdpt = ( APTR ) &( DBuf[ 0 ][ 10080 ] ); /* address of destination (top left corner) */
      break;

    case 1:
      Hardware_p->bltapt = ( APTR ) &( DBuf[ 0 ][ 10080 ] ); /* address of source (top left corner) */
      Hardware_p->bltdpt = ( APTR ) &( DBuf[ 1 ][ 10080 ] ); /* address of destination (top left corner) */
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
  fprintf( stdout, "%s\n", "Image: Invent   Kevin Saunders   kfs1971@gmail.com" );
  fprintf( stdout, "%s\n", "Font: courtesy of www.rinkydinkelectronics.com" );
  fprintf( stdout, "%s\n", "Sounds: sep800.mine.nu" );

  return;
}






/*
  - Cycles colors COLOR13-COLOR21, 9 colors in total.
*/
function void CycleColors( void )
{
/*
  COLOR00, 0x0000, COLOR01, 0x0110, COLOR02, 0x0222, COLOR03, 0x0340,
  COLOR04, 0x0462, COLOR05, 0x0683, COLOR06, 0x05bc, COLOR07, 0x07dd,
  COLOR08, 0x0afe, COLOR09, 0x0343, COLOR10, 0x0555, COLOR11, 0x0676,
  COLOR12, 0x0898, COLOR13, 0x06dc, COLOR14, 0x04ac, COLOR15, 0x0288,
  COLOR16, 0x0065, COLOR17, 0x0054, COLOR18, 0x0144, COLOR19, 0x0376,
  COLOR20, 0x05a9, COLOR21, 0x08fd, COLOR22, 0x0011, COLOR23, 0x0022,
  COLOR24, 0x0033, COLOR25, 0x0144, COLOR26, 0x0366, COLOR27, 0x0488,
  COLOR28, 0x06aa, COLOR29, 0x0010, COLOR30, 0x0afa, COLOR31, 0x0fc0,
*/
/*
012345
123450
234501
345012
450123
501234
012345
*/
  UBYTE I;
  UWORD Temp;



  Temp = CopperList[ 113 ];
  CopperList[ 113 ] = CopperList[ 97 ];
  for ( I = 97; I <= 109; I += 2 )
  {
    CopperList[ I ] = CopperList[ I + 2 ];
  } /* for */
  CopperList[ 111 ] = Temp;

  return;
}






/*
The Amiga has four channels with independent sample rates,
so there are no such thing as a common rate for all channels,
and there are no mixing going on.

                     AMIGA AUDIO CHANNELS
     Channel 3    Channel 2    Channel 1    Channel 0
      (right)       (left)      (left)       (right)

*/
/*
  - Plays a sample looping it.
*/
function void PlaySample( UBYTE Channel, UBYTE* Sample_p, LONG SampleSize, UWORD SampleRate, UWORD SampleVolume )
{
#define AMIGA_PAL_DMA_CLOCK 3546895 /* Hz unit */

  /*@@@ bset	#1,$bfe001		; Spegne il filtro passa-basso */

  Hardware_p->aud[ Channel ].ac_ptr = ( UWORD* ) Sample_p; /* ptr to start of waveform data */
  Hardware_p->aud[ Channel ].ac_len = ( UWORD ) ( SampleSize / 2 ); /* length of waveform in words */
  Hardware_p->aud[ Channel ].ac_per = ( UWORD ) ( AMIGA_PAL_DMA_CLOCK / SampleRate ); /* sample period */
  Hardware_p->aud[ Channel ].ac_vol = ( UWORD ) SampleVolume; /* volume */

  /* start audio channel */
  switch ( Channel )
  {
    case 0:
      Hardware_p->dmacon |= 0x8001;
      break;

    case 1:
      Hardware_p->dmacon |= 0x8002;
      break;

    case 2:
      Hardware_p->dmacon |= 0x8004;
      break;

    case 3:
      Hardware_p->dmacon |= 0x8008;
      break;
  } /* switch */

  return;

#undef AMIGA_PAL_DMA_CLOCK
}






/* Amiga rules, EOF */
