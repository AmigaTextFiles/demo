
#include "global.h"

#include <exec/memory.h>
#include <devices/timer.h>
#include <dos/dosextens.h>

LIBAPI void ExitGlobal(global *g)
{
	if (TimerBase) CloseDevice((struct IORequest *) g->timereq);
	if (g->timereq) DeleteIORequest((struct IORequest *) g->timereq);
	if (g->timeport) DeleteMsgPort(g->timeport);

	CloseLibrary((struct Library *) IntuitionBase);
	CloseLibrary((struct Library *) GfxBase);
	CloseLibrary((struct Library *) DOSBase);
	
	if (g->wbmsg)
	{
		Forbid();
		ReplyMsg(g->wbmsg);
	}
}

LIBAPI BOOL InitGlobal(global *g)
{
	//SysBase = *(struct ExecBase **) 4L;
	DOSBase = (struct DosLibrary *) OpenLibrary("dos.library", 36);

	if (!DOSBase) return FALSE;

	g->self = (struct Process *) FindTask(NULL);
	if (!g->self->pr_CLI)
	{
		WaitPort(&g->self->pr_MsgPort);
		g->wbmsg = GetMsg(&g->self->pr_MsgPort);
	}
	else
	{
		g->wbmsg = NULL;
	}
	
	GfxBase = OpenLibrary("graphics.library", 39);
	IntuitionBase = OpenLibrary("intuition.library", 0);

	TimerBase = NULL;
	g->timereq = NULL;
	g->timeport = CreateMsgPort();
	if (g->timeport)
	{
		g->timereq = (struct timerequest *) CreateIORequest(g->timeport, sizeof(struct timerequest));
		if (g->timereq)
		{
			if (OpenDevice("timer.device", UNIT_MICROHZ, (struct IORequest *) g->timereq, 0) == 0)
			{
				TimerBase = g->timereq->tr_node.io_Device;
			}
		}
	}
	
	if (DOSBase && GfxBase && IntuitionBase && TimerBase) return TRUE;

	ExitGlobal(g);
	return FALSE;
}

