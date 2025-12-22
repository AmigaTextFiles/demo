#define MAXPOINTS 64

#include <exec/types.h>
#include <exec/nodes.h>
#include <exec/lists.h>
#include <graphics/gfx.h>
#include <graphics/gfxbase.h>
#include <graphics/clip.h>
#include <graphics/rastport.h>
#include <graphics/view.h>
#include <graphics/text.h>
#include <graphics/gfxmacros.h>

#include <graphics/layers.h>
#include <intuition/intuition.h>
#include <exec/memory.h>
#include <exec/ports.h>
#include <exec/libraries.h>
#include <exec/interrupts.h>
#include <graphics/copper.h>
#include <hardware/dmabits.h>
#include <hardware/custom.h>
#include <graphics/gfxmacros.h>
 
#include <devices/timer.h>

#include "threed.h"

#define IS_PAL (((struct GfxBase *)GfxBase)->DisplayFlags & PAL)

long TimerBase;
struct timerequest *timerio;
extern struct Custom custom;

/* #define DEBUG */
/* #define TICKDEBUG */

long GfxBase = 0;
long LayersBase = 0;
long IntuitionBase = 0;
long DosBase = 0;

struct  AreaInfo areainfo;
UWORD   areafill[(MAXPOINTS/2)*5];

int gettime()
{
	int ticks;
	DoIO(timerio);
	ticks = timerio->tr_time.tv_secs*60;
	ticks += (timerio->tr_time.tv_micro*60)/1000000;
	return(ticks);
}

inittimer(usrproc,view,screen, window)
int  (*usrproc)();
struct View *view;
struct Screen *screen;
struct Window *window;
{
	int error = FALSE;

	/* allocate a timerequest structure */

	timerio = (APTR)AllocMem(sizeof(struct timerequest),MEMF_CLEAR);

	/* open the timer device */

	TimerBase = OpenDevice("timer.device",UNIT_VBLANK,timerio,0);

	/* initialize stuff to read timer value back */

	timerio->tr_node.io_Command = TR_GETSYSTIME;

	error = (*usrproc)(view,screen,window);

	/* close timer device */

	CloseDevice(timerio);

	/* clean up */

	FreeMem(timerio,sizeof(struct timerequest));

	return(error);
}

timeproc(usrproc,view,screen, window)
int  (*usrproc)();
struct View *view;
struct Screen *screen;
struct Window *window;
{
	int error = FALSE;
	int starttime;

	starttime = gettime();

	error = (*usrproc)(view,screen,window);

	if (!error)
	{
	    return(gettime() - starttime);
	}
	else 
	{
	    return(error);
	}

}

startgfxdos(x,y,height,width,n_bit_planes,usrproc,s,flags,tmpras,sbitmap)
WORD x,y;
UWORD height, width, n_bit_planes;
int (*usrproc)();
UBYTE *s;
ULONG flags;
struct TmpRas *tmpras;
struct BitMap *sbitmap;
{
	struct Screen *screen;
	struct Window *window;
	struct RastPort *w;
	struct View *view;
	short idcmp;
	struct NewWindow nw;
	struct NewScreen ns;
        int error = FALSE;

#ifdef DEBUG
	printf("startgfxdos: opening graphics lib...\n");
#endif
	
	if ( (!GfxBase) && ( (GfxBase = OpenLibrary("graphics.library",0) ) == NULL) )
	{
#ifdef DEBUG
		printf("startgfxdos: can't open graphics lib...\n");
#endif
		return((int)-1);
	}

#ifdef DEBUG
	printf("startgfxdos: opening layers lib...\n");
#endif
	
	if ( (LayersBase = OpenLibrary("layers.library",0)) == NULL)
	{
#ifdef DEBUG
		printf("startgfxdos: can't open layers lib...\n");
#endif
		return((int)-1);
	}

#ifdef DEBUG
	printf("startgfxdos: opening intuition lib...\n");
#endif

	if ( (IntuitionBase = OpenLibrary("intuition.library",0)) == NULL)
	{
#ifdef DEBUG
		printf("startgfxdos: can't open intuition lib...\n");
#endif
		return((int)-1);
	}

	ns.LeftEdge = x;
	ns.TopEdge = 0;
	ns.Width = width;
	ns.Height = ((height>(IS_PAL?PAL_MAXHINOLACE:NTSC_MAXHINOLACE))?(IS_PAL?PAL_MAXHILACE:NTSC_MAXHILACE):(IS_PAL?PAL_MAXHINOLACE:NTSC_MAXHINOLACE));
	ns.Depth = n_bit_planes;
	ns.DetailPen = -1;
	ns.BlockPen = -1;
	ns.ViewModes = ( 0 | ((width > 320)?HIRES:0) | ((height>(IS_PAL?PAL_MAXHINOLACE:NTSC_MAXHINOLACE))?LACE:0) );
	ns.Type = CUSTOMSCREEN;
	ns.Font = NULL;
	ns.DefaultTitle = NULL;
	ns.Gadgets = NULL;

#ifdef DEBUG
	printf("startgfxdos: opening a custom screen...\n");
#endif

	if ( (screen = (struct Screen *)OpenScreen(&ns)) == NULL)
	{
#ifdef DEBUG
	    printf("startgfxdos: can't open a custom screen...\n");
#endif
	    return((int)-1);
	}

        screen->ViewPort.DxOffset = x;

#ifdef DEBUG
	printf("startgfxdos: calling makescreen, rethinkdisplay...\n");
#endif

	MakeScreen(screen);
	RethinkDisplay();

	ShowTitle(screen,FALSE); /* let backdrop window title bars show */

	idcmp = CLOSEWINDOW;

	nw.LeftEdge = 0;
	nw.TopEdge = y;
	nw.Width = width;
	nw.Height = height;
	nw.DetailPen = -1;
	nw.BlockPen = -1;
	nw.IDCMPFlags = idcmp;
	nw.Flags = WINDOWCLOSE|flags;
	nw.FirstGadget = NULL;
	nw.CheckMark = NULL;
	nw.Title = s;
	nw.Screen = screen;
	nw.BitMap = sbitmap;
	nw.MinWidth = width;
	nw.MinHeight = height;
	nw.MaxWidth = width;
	nw.MaxHeight = height;
	nw.Type = CUSTOMSCREEN;

#ifdef DEBUG
	printf("startgfxdos: opening a window in the custom screen...\n");
#endif

	if ( (window = (struct Window *)OpenWindow(&nw)) == NULL )
	{
#ifdef DEBUG
	    printf("startgfxdos: can't open a new window...\n");
#endif
	    return((int)-1);
	}

	if(window->RPort)
	{
#ifdef DEBUG
	    printf("startgfxdos: initialize and link areainfo to this window's rastport...\n");
#endif
	    InitArea(&areainfo,areafill,MAXPOINTS);
	    window->RPort->AreaInfo = &areainfo;
	}
	else
	{
#ifdef DEBUG
	    printf("startgfxdos: null window rastport pointer...\n");
#endif
	    return((int)-1);
	}

#ifdef DEBUG
	printf("startgfxdos: trying to find the view adress...\n");
#endif

	if ( (view = (struct View *)ViewAddress()) == NULL) 
	{
#ifdef DEBUG
	    printf("startgfxdos: can't get view address...\n");
#endif
	    return((int)-1);
	}

	window->RPort->TmpRas = tmpras;

#ifdef DEBUG
	printf("startgfxdos: calling the usrproc routine ...\n");
#endif

#ifdef TICKDEBUG

#ifdef DEBUG
	printf("though the inittimer routine ...\n");
#endif
	error = inittimer(usrproc,view,window->WScreen,window);
#else
	error = (*usrproc)(view,window->WScreen,window);
#endif

#ifdef DEBUG
	printf("startgfxdos: returnted from the usrproc with error = %lx...\n",error);
#endif

#ifdef DEBUG
	printf("startgfxdos: close the window...\n");
#endif
	CloseWindow(window);     

#ifdef DEBUG
	printf("startgfxdos: close the screen...\n");
#endif
	CloseScreen(screen);

	return(error);
}
