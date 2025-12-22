
#ifndef INIT_GLOBAL_H
#define INIT_GLOBAL_H

#include <dos/dosextens.h>
#include <devices/timer.h>

#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/graphics.h>
#include <proto/intuition.h>
#include <proto/cybergraphics.h>

#ifndef LIBAPI
#define LIBAPI
#endif

#define ARG_TEMPLATE "FROM/M/A,SE=SONGEND/S,L=LOOP/S,V=VOLUME/N,F=FREQ/N,S=STEREO/S,HIQ/S,NOLED/S"
enum { ARG_FROM, ARG_SONGEND, ARG_LOOP, ARG_VOLUME, ARG_FREQ, ARG_STEREO, ARG_HIQ, ARG_NOLED, ARG_NUM };

typedef struct
{
	struct ExecBase *SysBase;
	struct DosLibrary *DOSBase;
	struct Library *IntuitionBase;
	struct Library *GfxBase;

	struct Device *TimerBase;
	struct MsgPort *timeport;
	struct timerequest *timereq;
	
	struct Message *wbmsg;
	struct Process *self;
	
	LONG *args;

} global;

LIBAPI BOOL InitGlobal(global *g);
LIBAPI void ExitGlobal(global *g);

//#define SysBase g->SysBase
#define DOSBase g->DOSBase
#define IntuitionBase g->IntuitionBase
#define GfxBase g->GfxBase
#define CyberGfxBase g->CyberGfxBase
#define TimerBase g->TimerBase

#endif
