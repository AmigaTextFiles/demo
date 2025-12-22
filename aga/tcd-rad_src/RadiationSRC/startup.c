#include <clib/intuition_protos.h>
#include <clib/graphics_protos.h>
#include <clib/exec_protos.h>
#include <clib/asl_protos.h>
#include <stdlib.h>
#include <stdio.h>
#include "startup.h"

struct Library *ExecBase=NULL;
struct Library *IntuitionBase=NULL;
struct Library *GfxBase=NULL;
struct Library *AslBase=NULL;
struct Library *DosBase=NULL;
struct Library *MEDPlayerBase=NULL;

struct Screen *demoscreen=NULL;
struct Window *demowindow=NULL;
struct RastPort *demorport=NULL;

struct ScreenBuffer *screenbuffers[2];
struct MsgPort *screenbufferports[2];
int screennr=0;

ULONG initialpal[]={ 4L<<16+0,  0x00000000,0x00000000,0x00000000,
										  0x00000000,0x00000000,0x00000000,
										  0x00000000,0x00000000,0x00000000,
										  0x00000000,0x00000000,0x00000000, 0 };

UWORD emptypointer[] = {
  0x0000, 0x0000, /* reserved, must be NULL */
  0x0000, 0x0000,    /* 1 row of image data */
  0x0000, 0x0000  /* reserved, must be NULL */
};
																			 
void message(char *inputmess)
{
	struct EasyStruct messy=
	{
		sizeof(struct EasyStruct),
		NULL,
		"What's this all about?",
		inputmess,
		"Acknowledged!"
	};
	EasyRequest(NULL,&messy,NULL);
}

void shutdown(char *mess)
{
	if(mess) message(mess); // If we've got something to say...Let's say it!

	if(GfxBase) WaitBlit(); // We'd better wait wait for the blit to finish!

	/* Vänta tills dubbelbuffringen är färdig... */
	if(screenbufferports[0])
		while(!GetMsg(screenbufferports[0]))
			WaitPort(screenbufferports[0]);
	if(screenbufferports[1])
		while(!GetMsg(screenbufferports[1]))
			WaitPort(screenbufferports[1]);

	/* Lämna tillbaks resurser */
	if(screenbufferports[0])
		DeleteMsgPort(screenbufferports[0]);
	if(screenbufferports[1])
		DeleteMsgPort(screenbufferports[1]);
	if(screenbuffers[0])
		FreeScreenBuffer(demoscreen, screenbuffers[0]);
	if(screenbuffers[1])
		FreeScreenBuffer(demoscreen, screenbuffers[1]);

	if(demowindow) CloseWindow(demowindow); // I guess we don't need our window anymore...
	if(demoscreen) CloseScreen(demoscreen); // ...and neither do we need our screen anymore!
	if(music)
		if(MEDPlayerBase)
		{
			//if(nm_music) nmstopsong();
			CloseLibrary(MEDPlayerBase);
		}
	if(AslBase) CloseLibrary(AslBase);
	if(GfxBase) CloseLibrary(GfxBase);
	if(ExecBase) CloseLibrary(ExecBase);
	if(IntuitionBase) CloseLibrary(IntuitionBase);
	if(DosBase) CloseLibrary(DosBase);
	exit(0);
}

void startup(void)
{
	screenbuffers[0]=NULL; screenbuffers[1]=NULL;
	screenbufferports[0]=NULL; screenbufferports[1]=NULL;

	if(!(ExecBase=OpenLibrary("exec.library",39L)))
		shutdown("Could not open exec.library V39 or later\n");

	if(!(IntuitionBase=OpenLibrary("intuition.library", 39L)))
		shutdown("Could not open intution.library V39 or later\n");

	if(!(GfxBase=OpenLibrary("graphics.library",39L)))
		shutdown("Could not open graphics.library V39 or later\n");

	if(!(AslBase=OpenLibrary("libs:asl.library",39L)))
		shutdown("Could not open asl.library V39 or later\n");

	if(!(DosBase=OpenLibrary("dos.library",39L)))
		shutdown("Could not open dos.library V39 or later\n");

	if(music)
	{
		if(!(MEDPlayerBase = OpenLibrary("data/medplayer.library",0L)))
			shutdown("Cant open music library\n");
	}

	SetTaskPri(FindTask(0), 127); // Set The Priority...

	if(!(demoscreen=OpenScreenTags(NULL,
			SA_Colors32, initialpal,
			SA_DisplayID, 135168,
			SA_Quiet, TRUE, // No gadgets...
//         SA_Interleaved, TRUE,
			SA_Width, screenwidth,
			SA_Height, screenheight,
			SA_Depth, pixeldepth,
			SA_PubName, "DemoScreen",
			SA_Type, CUSTOMSCREEN,
			SA_Draggable, FALSE,
			TAG_END)))
				shutdown("Screen could not be be opened.\nCheck if you have enough chipmem!");
 
	if(!(screenbuffers[0] = AllocScreenBuffer(demoscreen, NULL, SB_SCREEN_BITMAP)))
		shutdown("Unable to allocate ScreenBuffers");
	if(!(screenbuffers[1] = AllocScreenBuffer(demoscreen, NULL, NULL)))
		shutdown("Unable to allocate ScreenBuffers");
	if(!(screenbufferports[0] = CreateMsgPort()))
		shutdown("Unable to create messageport");
	if(!(screenbufferports[1] = CreateMsgPort()))
		shutdown("Unable to create messageport");
	screenbuffers[0]->sb_DBufInfo->dbi_SafeMessage.mn_ReplyPort = screenbufferports[0];
	screenbuffers[1]->sb_DBufInfo->dbi_SafeMessage.mn_ReplyPort = screenbufferports[0];
	screenbuffers[0]->sb_DBufInfo->dbi_DispMessage.mn_ReplyPort = screenbufferports[1];
	screenbuffers[1]->sb_DBufInfo->dbi_DispMessage.mn_ReplyPort = screenbufferports[1];

	if(!(demowindow=OpenWindowTags(NULL,
			WA_Left,0, WA_Top,0,
			WA_Width, screenwidth, WA_Height, screenheight,
			WA_CustomScreen,demoscreen,
			WA_Flags, WFLG_BACKDROP,
//         WA_IDCMP, IDCMP_RAWKEY,
			WA_Borderless,TRUE,
			WA_RMBTrap,TRUE,
			WA_Activate, TRUE,
			TAG_DONE)))
				shutdown("demo window could not be opened!");

	demorport=demowindow->RPort;

	SetPointer(demowindow, emptypointer, 1, 16, 0, 0);
	ChangeScreenBuffer(demoscreen, screenbuffers[screennr]); // Start Double Buffring!
}
