/********  General Declarations and Setup For ZNYK ********/

/*****************        INCLUDES      *****************/

#include  <exec/types.h>
#include  <exec/memory.h>
#include  <exec/nodes.h>
#include  <exec/lists.h>
#include  <exec/interrupts.h>
#include  <exec/ports.h>
#include  <exec/libraries.h>
#include  <exec/io.h>
#include  <exec/tasks.h>
#include  <exec/devices.h>
#include  <devices/audio.h>
#include  <graphics/gfx.h>
#include  <graphics/gfxbase.h>
#include  <graphics/gfxmacros.h>
#include  <graphics/rastport.h>
#include  <graphics/copper.h>
#include  <graphics/view.h>
#include  <graphics/text.h>
#include  <hardware/custom.h>
#include  <hardware/dmabits.h>
#include  <hardware/intbits.h>
#include  <hardware/blit.h>
#include  <intuition/intuition.h>
#include  <intuition/intuitionbase.h>
#include  <intuition/preferences.h>
#include  <stdlib.h>
#include  <stdio.h>
#include  <mod_dos.h>
#include  <string.h>
#include  <math.h>
#include  <time.h>
#include  <proto/exec.h>
#include  <proto/graphics.h>
#include  <proto/intuition.h>

/*****************        DEFINES       *****************/
#define LEFTMOUSE ((*((UBYTE *) 0xbfe001) & 0x40)==0)
#define JOY_TRIG ((*((UBYTE *) 0xbfe001) & 0x80)==0)
#define LED_OFF  (*((UBYTE *) 0xbfe001) |= 2)
#define LED_ON   (*((UBYTE *) 0xbfe001) &= 253)

/*****************         TYPES        *****************/

/*** y=rows, x=words ***/
#define BLTSIZE(x,y) (((y)<<HSIZEBITS)+x)
typedef struct {
/*** For MultiPlane Blits ***/
                 USHORT planes;              // 0
/*** 96  (0x60) ***/
                 SHORT  cmod,bmod,amod,dmod; // 2,4,6,8
/*** 112 (0x70) ***/
                 USHORT cdat,bdat,adat;      // 10,12,14
/*** 64  (0x40) ***/
                 USHORT con0, con1;          // 16,18
                 USHORT afwm,alwm;           // 20,22
                 USHORT *cpt,*bpt,*apt,*dpt; // 24,28,32,36 changed every call
                 USHORT size;                // 40
/*** For MultiPlane Blits ***/
                 SHORT  adda,addb,addcd;     // 42,44,46
               } BLIT_PARMS;

