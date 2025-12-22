#include <clib/intuition_protos.h>
#include <clib/graphics_protos.h>
#include <clib/dos_protos.h>
#include <clib/exec_protos.h>
#include <exec/memory.h>
#include <exec/types.h>
#include <stdio.h>
#include "picture.h"
#include "startup.h"

struct BitMap *bitmap1=NULL;

void deinitchunky(int width, int height, UBYTE **chunkyptr)
{
	if(*chunkyptr) FreeMem(*chunkyptr, width*height);
}

UBYTE *initchunky(int width, int height)
{
	UBYTE *chunkytemp=NULL;
	chunkytemp=AllocMem(width*height, MEMF_FAST);
	return chunkytemp;
}

void deinitbitmap(void)
{
	if(bitmap1) FreeBitMap(bitmap1);
}

void initbitmap(void)
{
	if(!(bitmap1=AllocBitMap(picwidth, picheight, pixeldepth,
		BMF_CLEAR, NULL))) shutdown("Not Enough Memory For GFX!");
}

int loadchunkypic(char filename[], void *dest, int picwidth, int picheight)
{
	BPTR filestream=NULL;

	if(filestream = Open(filename, MODE_OLDFILE))
	{
		if(filestream)
			if(! (Read(filestream, dest, picwidth*picheight)==(picwidth*picheight)) )
			{
				Close(filestream);
				return 0;
			}
		Close(filestream);
		return 1;
	}
	else return 0;
}

int loadtable(char filename[], UBYTE dest[], int tabwidth, int tabheight)
{
	BPTR filestream=NULL;

	if(filestream = Open(filename, MODE_OLDFILE))
	{
		if(filestream)
			if(! (Read(filestream, dest, tabwidth*tabheight*2)==(tabwidth*tabheight*2)) )
			{
				Close(filestream);
				return 0;
			}
		Close(filestream);
		return 1;
	}
	else return 0;
}

int loadbmap(char filename[], struct BitMap *dest, int width, int height)
{
	BPTR filestream=NULL;
	int current;

	if(filestream = Open(filename, MODE_OLDFILE))
	{
		if(filestream)
		{
			for(current=0;current<pixeldepth;current++)
			{
				Seek(filestream, current*((width*height)/8), OFFSET_BEGINNING);
				if(!(Read(filestream, dest->Planes[current], (width*height)/8)==(width*height)/8))
				{
					Close(filestream);
					return 0;
				}
			}
		}
		Close(filestream);
		return 1;
	}
	else return 0;
}

int loadilbmap(char filename[], struct BitMap *dest, int width, int height)
{
	BPTR filestream=NULL;

	if(filestream = Open(filename, MODE_OLDFILE))
	{
		if(filestream)
		{
			Seek(filestream, 0, OFFSET_BEGINNING);
			if(!(Read(filestream, dest->Planes[0], (width*height*pixeldepth)/8)==(width*height*pixeldepth)/8))
			{
				Close(filestream);
				return 0;
			}
		}
		Close(filestream);
		return 1;
	}
	else return 0;
}

