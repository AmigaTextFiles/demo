#include <exec/types.h>
#include <clib/exec_protos.h>
#include <graphics/view.h>
#include <intuition/intuition.h>
#include <intuition/screens.h>
#include <stdio.h>
#define NO_PRAGMAS 1
#include "pd:ifflib/iff.h"

#pragma libcall IFFBase OpenIFF 1e 801
#pragma libcall IFFBase CloseIFF 24 901
#pragma libcall IFFBase FindChunk 2a 902
#pragma libcall IFFBase GetBMHD 30 901
#pragma libcall IFFBase GetColorTab 36 8902
#pragma libcall IFFBase DecodePic 3c 8902
#pragma libcall IFFBase SaveBitMap 42 a9804
/*#pragma libcall IFFBase SaveClip 48 210a9808*/
#pragma libcall IFFBase IFFError 4e 0
#pragma libcall IFFBase GetViewModes 54 901
#pragma libcall IFFBase NewOpenIFF 5a 802
#pragma libcall IFFBase ModifyFrame 60 8902

struct Library *GfxBase,*IntuitionBase,*IFFBase;
struct BitMap *mybitmap;
ULONG *infile;

void Fail(char *msg)
{
	if (msg) printf("%s\n",msg);
	if (mybitmap) FreeBitMap(mybitmap);
	if (GfxBase) CloseLibrary(GfxBase);
	if (infile) CloseIFF(infile);
	if (IFFBase) CloseLibrary(IFFBase);
	exit(0);
}


struct Library *openlib(char *name,ULONG version)
{
	struct Library *t1;
	t1=OpenLibrary(name,version);
	if (! t1)
	{
		printf("error- needs %s version %d\n",name,version);
		Fail(0l);
	}
	else return(t1);
}




ULONG lcolortab[2+256*3];

struct RastPort myrp;

main(argc,argv)
int argc;
char **argv;
{
	GfxBase=openlib("graphics.library",39);
	IFFBase=openlib("iff.library",0);
	if (argc==2)
	{
		if (infile=OpenIFF(argv[1]))
		{
			ULONG scrwidth,scrheight,scrdepth;
			ULONG i,j;
			struct IFFL_BMHD *bmhd;
			if(!(bmhd=GetBMHD(infile))) Fail("BitMapHeader not found");
			InitRastPort(&myrp);

			scrwidth = bmhd->w;
			scrheight = bmhd->h;
			scrdepth = bmhd->nPlanes;
			mybitmap=AllocBitMap(scrwidth,scrheight,scrdepth,BMF_CLEAR,0l);
			if (! mybitmap) Fail("no bitmap");
			if(!DecodePic(infile,mybitmap)) Fail("Can't decode picture");
			myrp.BitMap=mybitmap;
			for(i=0;i<scrwidth;i++)
			{
				for(j=0;j<scrheight;j++)
				{
					outb(ReadPixel(&myrp,i,j));
				}
			}

			Fail(0);
		}
	}
}

int curout=0;

outb(c)
{
	if (! curout) printf("\n\tdc.b\t"); else printf(",");
	printf("$%02x",c);
	curout++;
	if (curout==15) curout=0;
}
