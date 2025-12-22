/* This program loads a module, and plays it. Uses medplayer.library! */
#include <exec/types.h>
#include <libraries/dos.h>
#include <proto/exec.h>
#include <proto/dos.h>
#include <stdio.h>
#include "libproto.h"
#include "proplayer.h"
#include "sound.h"
#include "startup.h"

struct MMD0 *sng=NULL;
int musicmod=1;

void playsong(char *songname)
{
	long count,midi = 0;

	sng = LoadModule(songname);
	if(!sng) shutdown("Panic: Can't load music!");     

	for(count = 0; count < 63; count++)
	if(sng->song->sample[count].midich) midi = 1;
	if(GetPlayer(midi))
	{
		message("Resource allocation failed.\n");
		stopsong(); return;
	}
	PlayModule(sng);
	musicmod=1;
}

void stopsong(void)
{
	FreePlayer();
	if(sng) UnLoadModule(sng);
	musicmod=0;
}
