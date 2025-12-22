#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>
#include <proto/intuition.h>
#include <proto/gadtools.h>
#include <proto/graphics.h>
#include <proto/exec.h>
#include <proto/dos.h>
#include <dos/dos.h>
#include <exec/types.h>
#include <exec/memory.h>
#include <exec/libraries.h>
#include <datatypes/datatypes.h>
#include <datatypes/datatypesclass.h>
#include <datatypes/pictureclass.h>
#include <graphics/gfx.h>
#include <intuition/intuition.h>
#include <intuition/pointerclass.h>
#include <intuition/gadgetclass.h>
#include <libraries/gadtools.h>
#include <clib/intuition_protos.h>
#include <clib/gadtools_protos.h>
#include <clib/graphics_protos.h>
#include <clib/exec_protos.h>
#include <clib/alib_protos.h>
#include <clib/datatypes_protos.h>
#include <clib/dos_protos.h>
#include <pragmas/datatypes_pragmas.h>
#include <pragmas/dos_pragmas.h>
#include <pragmas/exec_pragmas.h>
#include <pragmas/graphics_pragmas.h>
#include <pragmas/intuition_pragmas.h>
#include "pt/play.h"

#include <stdio.h>
struct Screen         *Scr = NULL;
struct IntuitionBase	*IntuitionBase;
struct GfxBase		*GfxBase;
struct Library		*GadToolsBase;
APTR                   VisualInfo = NULL;
struct RastPort *rp;
float a=0;

#define Y0 50
#define Y1 100
#define Y2 150
#define Y3 200

void draw()
{
	Move(rp, 160, Y0);
	Draw(rp, 160+(int)(100*sin(a)),Y1);
	Move(rp, 160, Y0);
	Draw(rp, 160+(int)(100*sin(a+2.0943)),Y1);
	Move(rp, 160, Y0);
	Draw(rp, 160+(int)(100*sin(a+4.1887)),Y1);
	
	Move(rp, 160, Y3);
	Draw(rp, 160+(int)(100*sin(a+1.0471)),Y2);
	Move(rp, 160, Y3);
	Draw(rp, 160+(int)(100*sin(a+2.0943+1.0471)),Y2);
	Move(rp, 160, Y3);
	Draw(rp, 160+(int)(100*sin(a+4.1887+1.0471)),Y2);

	Move(rp, 160+(int)(100*sin(a)),Y1);
	Draw(rp, 160+(int)(100*sin(a+1.0471)),Y2);
	Draw(rp, 160+(int)(100*sin(a+2.0943)),Y1);
	Draw(rp, 160+(int)(100*sin(a+2.0943+1.0471)),Y2);
	Draw(rp, 160+(int)(100*sin(a+4.1887)),Y1);
	Draw(rp, 160+(int)(100*sin(a+4.1887+1.0471)),Y2);
	Draw(rp, 160+(int)(100*sin(a)),Y1);
}

int main()
{
int i;
IntuitionBase	= (struct IntuitionBase *)OpenLibrary("intuition.library", 37);
GfxBase		= (struct GfxBase *)OpenLibrary("graphics.library", 37);
GadToolsBase	= OpenLibrary("gadtools.library", 37);
if ( ! ( Scr = OpenScreenTags( NULL, SA_Left,	0,
				SA_Top,		0,
				SA_Width,	320,
				SA_Height,	256,
				SA_Depth,	8,
				SA_Type,	CUSTOMSCREEN,
				SA_DisplayID,	PAL_MONITOR_ID,
				SA_Interleaved,	FALSE,
				SA_ShowTitle,	FALSE,
				SA_Behind,	FALSE,
				SA_Title,	"Rouflaquette",
				TAG_DONE ))) return( 1L );

VisualInfo = GetVisualInfo( Scr, TAG_DONE );

rp = &Scr->RastPort;
play_init("Mod.daz");
for(i=0;i<30000;i++)
{
	SetAPen(rp, 1);
	draw();
	WaitTOF();
	WaitTOF();
	WaitTOF();
	SetAPen(rp, 0);
	draw();
	a=a+0.02;
}
play_end();
if(VisualInfo)
	{
	FreeVisualInfo( VisualInfo );
	VisualInfo = NULL;
	}
if(Scr)	{
	CloseScreen( Scr );
	Scr = NULL;
	}

/*
	char nom[200];
	printf("Hello Amiga\n");
	printf("Comment t'appele tu ?\n");
	scanf("%s", nom);
	printf("Bonjour moniseur %s\n", nom);
	*/
	
}