#include <exec/types.h>

#include <intuition/intuition.h>
#include <intuition/screens.h>
#include <utility/tagitem.h>

#include <proto/exec.h>
#include <proto/intuition.h>
#include <proto/graphics.h>
#include <proto/dos.h>

#include <string.h>
#include <stdlib.h>

#define TBITPLANES	(6)
#define TCOLORS		(1<<TBITPLANES)

static long __oslibversion = 39;

static void errorexit(void);
static void cyclecolorspec(ULONG *, WORD, UWORD, UWORD, UWORD);
static void bouncecolor(UWORD *, WORD *);

void main(int argc, char ** argv)
{
	struct Screen	* screen;
	struct Window	* window;

	static ULONG			colorspec[1+TCOLORS*3+1];	// Guaranteed to be zero?
	static WORD				areabuffer[10];
	static struct AreaInfo	areainfo;
	static struct TmpRas	tmpras;
	PLANEPTR				raster;

	WORD		i;
	WORD		xstep,
				ystep;

	screen = OpenScreenTags(NULL,
//		SA_DisplayID,	PAL_MONITOR_ID|HIRESLACE_KEY,
//		SA_Width,		640, //1280,
//		SA_Height,		256, //400,
		SA_Depth,		TBITPLANES,
		SA_Title,		"AGATunnel",
		SA_Type,		CUSTOMSCREEN,
//		SA_AutoScroll,	FALSE,
//		SA_Pens,		&penspec,
//		SA_SysFont,		0,
//		SA_Overscan,	OSCAN_TEXT,
//		SA_,	,
//		SA_,	,
		SA_LikeWorkbench, TRUE,
//		SA_ShowTitle, FALSE,
		TAG_END);

	if(screen == NULL)
		errorexit();

	window = OpenWindowTags(NULL,
		WA_Left, 0,
		WA_Top, 0,
		WA_Width, screen->Width,
		WA_Height, screen->Height,
		WA_Title, NULL,
		WA_CustomScreen, screen,
		WA_Borderless, FALSE,
		WA_DragBar, FALSE,
		WA_Activate, TRUE,
		WA_SmartRefresh, TRUE,
		WA_Backdrop, FALSE,
		WA_NoCareRefresh, TRUE,
//		WA_,,
//		WA_,,
//		WA_,,
//		WA_,,
		TAG_END);

	if(window==NULL)
	{	CloseScreen(screen);
		errorexit();
	}

	InitArea(&areainfo, areabuffer, 10*2/5);
	window->RPort->AreaInfo = &areainfo;

	raster = AllocRaster(window->Width*2, window->Height*2);
	InitTmpRas(&tmpras, raster, RASSIZE(window->Width*2, window->Height*2));
	window->RPort->TmpRas = &tmpras;

/*
 ****************************************************
 */
	xstep = (window->Width-50)/2/TCOLORS;
	ystep = (window->Height-50)/2/TCOLORS;
	for(i=TCOLORS-1; i>0; i--)
	{	SetAPen(window->RPort, (ULONG)(TCOLORS - i));
/*		AreaEllipse(window->RPort, window->Width/2 , window->Height/2,
					((window->Width-20)*i)/2/TCOLORS,
					((window->Height-20)*i)/2/TCOLORS);
*/
		AreaEllipse(window->RPort, window->Width/2 , window->Height/2,
					(((window->Width*4)/3)*i)/2/TCOLORS,
					(((window->Height*4)/3)*i)/2/TCOLORS);

		AreaEnd(window->RPort);
	}

	{
		UWORD	red,
				green,
				blue;
		WORD	rspeed,
				gspeed,
				bspeed;

		colorspec[0] = TCOLORS<<16 | 0;
		srand(141);
		red = green = blue = 0;
		rspeed = 950; //((UWORD)rand())&0x00ff - 128;
		gspeed = 901; //((UWORD)rand())&0x00ff - 128;
		bspeed = 863; //((UWORD)rand())&0x00ff - 128;

		while(TRUE)
		{	cyclecolorspec(&colorspec[1], TCOLORS, red, green, blue);
			WaitTOF();
			LoadRGB32(&screen->ViewPort, colorspec);

			bouncecolor(&red, &rspeed);
			bouncecolor(&green, &gspeed);
			bouncecolor(&blue, &bspeed);

			if((SetSignal(0, SIGBREAKF_CTRL_C) & SIGBREAKF_CTRL_C) != 0)
				break;
			// Delay(1);
		}
	}

	FreeRaster(raster, window->Width, window->Height);
	CloseWindow(window);
	CloseScreen(screen);
	exit(0);
}

static void errorexit(void)
{
	static char message[] = "Some fatal error - panic!\n";

	Write(Output(), message, sizeof(message));
	exit(20);
}

static void cyclecolorspec(ULONG * table, WORD tablesize, UWORD r, UWORD g, UWORD b)
{
	WORD	i;

	for(i=0; i<tablesize-1; i++)
	{	table[i*3] = table[(i+1)*3];
		table[i*3+1] = table[(i+1)*3+1];
		table[i*3+2] = table[(i+1)*3+2];
	}

	table[(tablesize-1)*3] = r<<16;
	table[(tablesize-1)*3 + 1] = g<<16;
	table[(tablesize-1)*3 + 2] = b<<16;
}

static void bouncecolor(UWORD * col, WORD * speed)
{
	LONG	tmp;

	tmp = (*col)+(*speed);
	if(tmp > 65000)
	{	tmp = 65000;
		(*speed) = -(*speed);
	}
	if(tmp<0)
	{	tmp = 0;
		(*speed) = -(*speed);
	}

	(*col) = (UWORD)tmp;
}
