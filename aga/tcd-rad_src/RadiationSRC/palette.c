#include <clib/intuition_protos.h>
#include <clib/graphics_protos.h>
#include <clib/dos_protos.h>
#include <exec/types.h>
#include <stdio.h>
#include <stdlib.h>
#include "palette.h"
#include "startup.h"

ULONG newpalette[1+256*3+1]; // Maximum 256 colors!

UBYTE *palette=NULL;

void maketpalette(UBYTE *chgpalette, int level)
{
	int col;
	int lcount;

	for(col=0; col<(128*3); col++) // Copy the lower 128cols to higher 128cols...
		chgpalette[col+(128*3)]=chgpalette[col];

	for(lcount=0; lcount<level; lcount++)
	{
		for(col=128*3; col<(256*3); col++) // Make the higher 128cols "brighter"
		{
			if(chgpalette[col]<255)
				chgpalette[col]++;
		}
	}
}

void fadedownpal(UBYTE *chgpalette, UBYTE *srcpalette, int colors)
{
	int col;
	for(col=0; col<(colors*3); col++)
	{
		if(chgpalette[col]!=srcpalette[col])
			chgpalette[col]--;
	}
}      

void fadeuppal(UBYTE *chgpalette, UBYTE *srcpalette, int colors)
{
	int col;
	for(col=0; col<(colors*3); col++)
	{
		if(chgpalette[col]!=srcpalette[col])
			chgpalette[col]++;
	}
}


void deinitpalette()
{
	if(palette) free(palette);
}

void initpalette(void)
{
	if(!(palette=malloc(palettecolors*3))) shutdown("No mem for palette buffer!");
}

void setpalen(UBYTE colortable[], int colors) // Can handle maximum 256 colors!
{
	int byte, color;

	newpalette[0]=colors<<16+0;

	for(color=0; color<colors; color++)
	{
		for(byte=0; byte<4; byte++)
		{
			newpalette[color*3+1]<<=8;
			newpalette[color*3+1]|=colortable[color*3];
			newpalette[color*3+2]<<=8;
			newpalette[color*3+2]|=colortable[color*3+1];
			newpalette[color*3+3]<<=8;
			newpalette[color*3+3]|=colortable[color*3+2];
		}
	}
	newpalette[colors*3+1]=0x00000000;
	LoadRGB32(&demoscreen->ViewPort, newpalette);
}

int loadpalette(char filename[], UBYTE dest[], int colors)
{
	BPTR filestream=NULL;

	if(filestream = Open(filename, MODE_OLDFILE))
	{
		if(filestream)
			if(! (Read(filestream, dest, colors*3)==(colors*3)) )
			{
				Close(filestream);
				return 0;
			}
		Close(filestream);
		return 1;
	}
	else return 0;
}
