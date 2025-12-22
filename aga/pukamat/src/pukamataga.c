#include <proto/dos.h>
#include <proto/exec.h>
#include <proto/intuition.h>
#include <proto/graphics.h>
#include <proto/mathtrans.h>
#include <proto/mathffp.h>

#include <exec/memory.h>
#include <intuition/screens.h>
#include <graphics/modeid.h>
#include <graphics/videocontrol.h>

#include <stdlib.h>

#include "pukamat.h"
#include "c2p/c2p_kalms.h"

#define PI 3.14159265358979323846

#define CHUNKYWIDTH 160
#define CHUNKYHEIGHT 128
#define CHEIGHT 128

#define SCREENWIDTH 320
#define SCREENHEIGHT 128

#define PIXELS 50

struct Screen *Screeni;

struct IntuitionBase *IntuitionBase;
struct GfxBase *GfxBase;
struct Library *MathBase;
struct Library *MathTransBase;

PLANEPTR rasteri;
struct BitMap renderbm;

UWORD quickpens[] = {(UWORD)~0};

struct TagItem vcTags[] =
{
	{ VTAG_BORDERBLANK_SET, TRUE },
	{ VC_IntermediateCLUpdate, FALSE },
	{ TAG_DONE, NULL },
};

ULONG colortable[256*3+2];

UBYTE *framebuffer;
UBYTE *framebuffer2;
UBYTE *framebuffer3;
UBYTE *fp,*fp2,*fp3;

UBYTE *envmap;

ULONG  lightx, lighty;

#define xlight 100+100;
#define ylight 80+80;

UBYTE k1=0,k2=0;

ULONG K=1;
float Z=1.0;

float sintable[512];
float costable[512];

void main(void)
{
	ULONG x,y,t=0,b=0,a,i,depth,c=0x00ffffff;

	if (IntuitionBase=(struct IntuitionBase *)OpenLibrary( "intuition.library", 39)) {
	if (GfxBase=(struct GfxBase *)OpenLibrary( "graphics.library", 40)) {

	if (MathBase=OpenLibrary( "mathffp.library", 0)) {
	if (MathTransBase=OpenLibrary( "mathtrans.library", 0)) {

	if (framebuffer=(UBYTE *) AllocMem(CHUNKYWIDTH*(CHEIGHT+2),MEMF_PUBLIC|MEMF_CLEAR)) {
	if (framebuffer2=(UBYTE *) AllocMem(CHUNKYWIDTH*(CHEIGHT+2),MEMF_PUBLIC|MEMF_CLEAR)) {
	if (framebuffer3=(UBYTE *) AllocMem(CHUNKYWIDTH*(CHEIGHT+2),MEMF_PUBLIC|MEMF_CLEAR)) {

	fp=framebuffer+CHUNKYWIDTH, fp2=framebuffer2+CHUNKYWIDTH, fp3=framebuffer3+CHUNKYWIDTH;

	if (envmap=(UBYTE *)AllocMem(256*256,MEMF_PUBLIC|MEMF_CLEAR)) {

	if (rasteri=(PLANEPTR)AllocRaster(SCREENWIDTH, 8*SCREENHEIGHT)) {

	InitBitMap( &renderbm, 8, SCREENWIDTH, SCREENHEIGHT );
	for (depth = 0; depth < 8; ++depth)
		renderbm.Planes[depth] = rasteri + depth * RASSIZE(SCREENWIDTH, SCREENHEIGHT);

	colortable[0]=256l<<16+0;

	for (i=1; i<3*128; i+=3)
	{
		colortable[i]=c;
		colortable[i+1]=0x00ffffff;
		colortable[i+2]=0x00ffffff;
		colortable[i+3*128]=0xffffffff;
		colortable[i+3*128+1]=c;
		colortable[i+3*128+2]=0x00ffffff;
		c+=0x02000000;
	}
	colortable[256*3+1]=0;

	c2p2x1_8_c5_030_init(CHUNKYWIDTH,CHUNKYHEIGHT,0,0,SCREENWIDTH/8,(LONG)renderbm.BytesPerRow);

	if (Screeni = (struct Screen *) OpenScreenTags(NULL,
                                                 SA_Width, SCREENWIDTH,
	                                               SA_Height, SCREENHEIGHT,
	                                               SA_Depth, 8,
	                                               SA_DisplayID, PAL_MONITOR_ID|LORESSDBL_KEY,
	                                               SA_Type, CUSTOMSCREEN|CUSTOMBITMAP|SCREENQUIET,
	                                               SA_BitMap, &renderbm,
	                                               SA_Colors32, colortable,
                                                 SA_ShowTitle, FALSE,
                                                 SA_Quiet, TRUE,
                                                 SA_MinimizeISG, TRUE,
	                                               SA_VideoControl, vcTags,
                                                 SA_Pens, quickpens,
	                                               TAG_DONE)) {
	for (y=0;y<256;++y)
	{
		for (x=0;x<256;++x)
		{
		  float nX=(float)(x-128)/128;
		  float nY=(float)(y-128)/128;
		  float nZ=(float)(1-SPSqrt((nX*nX + nY*nY)));
		  if (nZ<0) nZ=0;
			envmap[y*256+x] = (UBYTE)(nZ*255);
		}
	}

	for (i=0; i<512; ++i)
	{
		float b = (float)(((2.0*PI)*i)/512);
		sintable[i]=(float)(65536*SPSin(b));
		costable[i]=(float)(65536*SPCos(b));
	}

	while (!MouseButton()) 
	{

		struct DateStamp *ds;

		ds=DateStamp(ds);
		a=ds->ds_Tick/25;
		if ((a-b)!=0) {++t; b=a;}

		srand((unsigned int)a);

		pisteet((USHORT *)framebuffer3);

		if (t<20)
		{
			Move(&Screeni->RastPort,SCREENWIDTH-226,SCREENHEIGHT/2-6);
			Text(&Screeni->RastPort,"Pukamat by Tundrah",18);			
		}

		else if (t<40)
		{
			fire(framebuffer3);
			c2p2x1_8_c5_030(framebuffer3,renderbm.Planes[0]);
		}
		else if (t<60)
		{
			fire(framebuffer3);
			rotzoom(fp2,framebuffer3,-0.02,1);
			c2p2x1_8_c5_030(fp2,renderbm.Planes[0]);
		}
		else if (t<80)
		{
			fire(framebuffer3);
			rotzoom(fp2,framebuffer3,0.02,1);
			c2p2x1_8_c5_030(fp2,renderbm.Planes[0]);
		}
		else if (t<120)
		{
			fire(framebuffer3);
	 		bump(fp2,fp3);
			c2p2x1_8_c5_030(fp2,renderbm.Planes[0]);
			Z=1.0; K=1;
		}
		else if (t<140)
		{
			fire(framebuffer3);
	 		bump(fp2,fp3);
			rotzoom(fp,fp2,0.01,1);
			c2p2x1_8_c5_030(fp,renderbm.Planes[0]);
		}
		else if (t<160)
		{
			fire(framebuffer3);
	 		bump(fp2,fp3);
			rotzoom(fp,fp2,-0.011,1);
			c2p2x1_8_c5_030(fp,renderbm.Planes[0]);
		}
		else if (t<180)
		{
			fire(framebuffer3);
			rotzoom(fp2,framebuffer3,-0.02,1);
	 		bump(fp,fp2);
			c2p2x1_8_c5_030(fp,renderbm.Planes[0]);
		}
		else if (t<200)
		{
			fire(framebuffer3);
			rotzoom(fp2,framebuffer3,0.02,1);
	 		bump(fp,fp2);
			c2p2x1_8_c5_030(fp,renderbm.Planes[0]);
		}
		else if (t<220)
		{
			Z=1.0;
			fire(framebuffer3);
			rotzoom(fp2,framebuffer3,0.00,1);
	 		bump(fp,fp2);
			c2p2x1_8_c5_030(fp,renderbm.Planes[0]);
		}
		else
		{
			fire(framebuffer3);
			rotzoom(fp2,framebuffer3,0.00,1);
	 		bump(fp,fp2);
			c2p2x1_8_c5_030(fp,renderbm.Planes[0]);
			Move(&Screeni->RastPort,SCREENWIDTH-190,SCREENHEIGHT/2-6);
			Text(&Screeni->RastPort,"THE END",7);			
		}
	}
	CloseScreen(Screeni);
	}
	FreeRaster(rasteri, SCREENWIDTH, SCREENHEIGHT*8);
	}
	FreeMem(envmap,256*256);
	}
	FreeMem(framebuffer3,CHUNKYWIDTH*(CHEIGHT+2));	
	}
	FreeMem(framebuffer2,CHUNKYWIDTH*(CHEIGHT+2));	
	}
	FreeMem(framebuffer,CHUNKYWIDTH*(CHEIGHT+2));
	}
	CloseLibrary(MathTransBase);
	}
	CloseLibrary(MathBase);
	}
	CloseLibrary((struct Library *)GfxBase);
	}
	CloseLibrary((struct Library *)IntuitionBase);
	}
}

void fire(UBYTE *p)
{
	ULONG i;

	for (i=0; i<(CHUNKYWIDTH*CHEIGHT); i+=CHUNKYWIDTH)
	{
		ULONG j,k;

		for (j=0; j<CHUNKYWIDTH; ++j)
		{
			k=i+j;
			p[k]=(p[k] + p[k+CHUNKYWIDTH+1] + p[k+2*CHUNKYWIDTH] + p[k+CHUNKYWIDTH-1])>>2;
		}
	}
}

void bump(UBYTE *p1,UBYTE *p2)
{
	ULONG y;

	lightx = (((LONG)(sintable[k1<<1])) >> 10) + xlight;
	lighty = (((LONG)(costable[k2<<1])) >> 11) + ylight;

	for (y=0; y<(CHUNKYWIDTH*CHEIGHT); y+=CHUNKYWIDTH)
	{
		ULONG x;
		for (x=0; x<CHUNKYWIDTH; ++x)
		{
			ULONG k=y+x;

			int nX1=p2[k+1] - p2[k-1] + lightx-x;
			int nY1=p2[k+CHUNKYWIDTH] - p2[k-CHUNKYWIDTH] + lighty-(y>>8);

			if (nX1<0 || nX1>255) nX1=0;
			if (nY1<0 || nY1>255) nY1=0;

			p1[k] = envmap[(nY1<<8)+nX1];
		}
	}
	k1++;
	k2+=2;
}

void rotzoom(UBYTE *p1, UBYTE *p2, float Zp, LONG Kp)
{
	LONG s,c,ds=0,dx,dy,dc=0;
	ULONG i;

	s = (LONG) (Z * sintable[K]);
  c = (LONG) (Z * costable[K]);

	for (i=0; i<(CHUNKYWIDTH*CHEIGHT); i+=CHUNKYWIDTH)
	{
		ULONG j;

		dx = ds;
		dy = dc;

		ds -= s;
		dc += c;

		for (j=0; j<(CHUNKYWIDTH); ++j)
		{
			p1[i+j]=p2[(((dy>>16) & 0x007f)*160) + ((dx>>16) % 160)];

			dx += c;
			dy += s;
		}
	}

	Z += Zp; 
	K = (K+Kp) & 0x000001ff;
}

void pisteet(USHORT *p1)
{
	ULONG i,r,s;

	for (i=0; i<PIXELS; ++i)
	{
		USHORT *p=p1;
		r = rand() % (CHUNKYWIDTH/2);
		s = rand() % (CHEIGHT-1);
			
		p+=(CHUNKYWIDTH/2)*s+r;
		*p=0xffff;
		p+=(CHUNKYWIDTH/2);
		*p=0xffff;
	}
}
