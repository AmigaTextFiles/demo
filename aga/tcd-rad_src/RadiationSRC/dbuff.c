#include <clib/intuition_protos.h>
#include <clib/exec_protos.h>
#include "startup.h"

void dbuffwaitdraw(void)
{
	while(!GetMsg(screenbufferports[0]))
		WaitPort(screenbufferports[0]);
}

void dbuffdispnew(void)
{
	while(!GetMsg(screenbufferports[1]))
		WaitPort(screenbufferports[1]);
	ChangeScreenBuffer(demoscreen, screenbuffers[screennr]);  // Byt aktiv BitMap i skärmen
	screennr = 1 - screennr;
}

