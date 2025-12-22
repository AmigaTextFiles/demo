#include <exec/types.h>
#include <clib/exec_protos.h>
#include <graphics/view.h>
#include <stdio.h>
#include <dos/dos.h>
#include <math.h>
#define NO_PRAGMAS 1
#include "iff.h"

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

struct Library *IFFBase,*GfxBase;
ULONG *infile;

void Fail(char *msg)
{
	if (msg) printf("%s\n",msg);
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



int curout=0;

outb(c)
{
	if (! curout) printf("\n\tdc.b\t"); else printf(",");
	printf("$%02x",c);
	curout++;
	if (curout==15) curout=0;
}

struct Colormap *mycm;

ULONG r[256],g[256],b[256];

#define AVG(x,y) (((x/2)+(y/2)))

main(argc,argv)
int argc;
char **argv;
{
	IFFBase=openlib("iff.library",0);
	GfxBase=openlib("graphics.library",39);
	if (argc==2)
	{

		if (infile=OpenIFF(argv[1]))
		{
			ULONG *form,*chunk;
			ULONG count;
			UBYTE *ptr;
			ULONG i;
			mycm=GetColorMap(256l);
			chunk=FindChunk(infile,ID_CMAP);
			if (! chunk) Fail("no color table");
			chunk++;
			count=(*(chunk++))/3;
			ptr=chunk;
			if (count>256) count=256;
			for(i=0;i<count;i++)
			{
				r[i]=*(ptr++)<<24;
				g[i]=*(ptr++)<<24;
				b[i]=*(ptr++)<<24;
				SetRGB32CM(mycm,i,r[i],g[i],b[i]);
			}

			printf("; mix table for palette\n");
			for(i=0;i<65536;i++)
			{
				int found;
				int x=(i>>8);
				int y=(i & 0xff);
				found=FindColor(mycm,AVG(r[x],r[y]),AVG(g[x],g[y]),AVG(b[x],b[y]),255);
				if (found==x) found=y;
				outb(found);
			}

			Fail(0);
		}
	} else Fail("can't open file");
}
