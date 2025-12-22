;/* Realtime Ray Tracer
lc -b1 -ccit -v -D RRT.c
quit
*/

#include "rrt.h"

/***** Declarations for CBACK *****/
long _BackGroundIO = 0;
long _stack = 10000;
char *_procname = "RRT";
long _priority = 50;

int CXBRK(void) { return(0); }		/* Disable Lattice CTRL-C handling */
int chkabort(void) { return(0); }	    /* really */

/*****  Libraries and HardWare  *****/
struct IntuitionBase *IntuitionBase=NULL;
struct GfxBase       *GfxBase=NULL;
extern struct Custom __far custom;

/*****  Graphics Data  *****/
extern unsigned char far BM0[40000];
extern unsigned char far BM1[32000];

unsigned char *BMraw[2]={&BM0[0],&BM1[0]};

char FastRead[8000];
char *RStartPlane;
ULONG output;

extern unsigned char far SILVERFOX[1];
extern unsigned char far ImageDataBall[1];
extern ULONG far ReflectPlane[62];

struct UCopList   usercopper;

/****
struct BitMap
  { UWORD BytesPerRow, Rows;
    UBYTE Flags, Depth;
    UWORD   pad;
    PLANEPTR Planes[8]; }
****/
struct BitMap BMap[] =
{{ 40, 200, 0, 5, 0, &BM0[0], &BM0[8000], &BM0[16000], &BM0[24000],
   &BM0[32000], NULL, NULL, NULL },
 { 40, 200, 0, 5, 0, &BM1[0], &BM1[8000], &BM1[16000], &BM1[24000],
   &BM0[32000], NULL, NULL, NULL },
 { 40, 200, 0, 5, 0, &BM1[0], &BM1[0], &BM1[0], &BM1[0],
   &BM1[0], NULL, NULL, NULL },
 { 40, 200, 0, 1, 0, &BM0[32000], NULL, NULL, NULL, NULL, NULL, NULL, NULL }
};

struct RasInfo  *DB_rinfo = NULL;
struct ViewPort *vport = NULL;
USHORT CurrentFront = 0;
USHORT NextFront = 1;

struct NewScreen NewScreenStructure = {
	0,0,	/* screen XY origin relative to View */
	320,200,	/* screen width and height */
	5,	/* screen depth (number of bitplanes) */
	0,1,	/* detail and block pens */
	SPRITES,	/* display modes for this screen */
	CUSTOMSCREEN|CUSTOMBITMAP,	/* screen type */
	NULL,	/* pointer to default screen font */
	NULL,	/* screen title */
	NULL,	/* first in list of custom screen gadgets */
	&BMap[0]	/* pointer to custom BitMap structure */
};

struct Screen *MyScreen=NULL;

struct NewWindow NewWindowStructure1 = {
	0,0,	/* window XY origin relative to TopLeft of screen */
	320,200,	/* window width and height */
	0,1,	/* detail and block pens */
	0,	/* IDCMP flags */
	/* other window flags */
	SIMPLE_REFRESH|BORDERLESS|RMBTRAP|NOCAREREFRESH|BACKDROP|ACTIVATE,
	NULL,	/* first gadget in gadget list */
	NULL,	/* custom CHECKMARK imagery */
	NULL,	/* window title */
	NULL,	/* custom screen pointer */
	NULL,	/* custom bitmap */
	1,1,	/* minimum width and height */
	-1,-1,	/* maximum width and height */
	CUSTOMSCREEN	/* destination screen type */
};

struct Window *MyWindow=NULL;

UWORD ColorPalettes[][32] =
{
  { 0x000,0x000,0x000,0x000,0x000,0x000,0x000,0x000,
    0x000,0x000,0x000,0x000,0x000,0x000,0x000,0x000,
    0x000,0x000,0x000,0x000,0x000,0x000,0x000,0x000,
    0x000,0x000,0x000,0x000,0x000,0x000,0x000,0x000 },
  { 0x000,0xFFF,0xFEF,0xEDF,0xDCF,0xDBF,0xCAF,0xC9F, /* SilverFox Colors */
    0xB8F,0xB6F,0xA5F,0xA4F,0x93F,0x92F,0x81F,0x80F,
    0xF00,0xFFF,0xFEF,0xEDF,0xDCF,0xDBF,0xCAF,0xC9F,
    0xB8F,0xB6F,0xA5F,0xA4F,0x93F,0x92F,0x81F,0x80F },
  { /* Reflect Colors */
    0x0F0,0xF00,0xD00,0xB00,0x900,0x800,0x600,0x400,
    0x0F0,0xAAF,0x99D,0x88B,0x779,0x668,0x556,0x444,
    0x03A,0x03A,0x03A,0x03A,0x03A,0x03A,0x03A,0x03A,
    0x03A,0x03A,0x03A,0x03A,0x03A,0x03A,0x03A,0x03A
 }
};

short Xarray[31][32];

BLIT_PARMS BP={NULL};
BLIT_PARMS BP_SCAN={NULL};
BLIT_PARMS BP_CLEAR={NULL};

extern ULONG far NOMOUSE[];

/* * * * * * * * * * * EXTERNAL ROUTINES * * * * * * * * * */
VOID __regargs UnPackByteRun(UBYTE *from, UBYTE *to);
VOID __regargs ComputeInterColor(UWORD *from, UWORD *to, UWORD step);
VOID __regargs WaitFRAMES(UWORD frames);
VOID __regargs FTB(UBYTE *a0);
VOID __regargs SLAM_BLITTER(BLIT_PARMS *a0);

VOID __regargs ReadPoint(long int sX_d0, long int sY_d1);

/***************  Beginning of code  ***************/

VOID __regargs SetView(USHORT which)
{
  CurrentFront=which;
  NextFront=1-CurrentFront;

  DB_rinfo->BitMap = &BMap[which];
//  WaitBOVP(vport); ScrollVPort(vport);
  MakeScreen(MyScreen); RethinkDisplay();
}

VOID CleanUp()
{
  if (DB_rinfo!=NULL)
    { vport->UCopIns = NULL; SetView(0); WaitFRAMES(2); RemakeDisplay(); }
  if (MyWindow!=NULL)
    CloseWindow(MyWindow);
  if (MyScreen!=NULL)
    { FreeCopList(usercopper.CopList);
      CloseScreen(MyScreen); }
  if (IntuitionBase!=NULL)
    CloseLibrary((struct Library *)IntuitionBase);
  if (GfxBase!=NULL)
    CloseLibrary((struct Library *)GfxBase);
  LED_ON;  ON_SPRITE
  exit(0);
}

VOID GridZAP(short from,short to,short amount)
{
  BLIT_PARMS *myblit=&BP_SCAN;

  myblit->bpt=(USHORT *)(&BM1[from*40]);
  myblit->dpt=(USHORT *)(&BM0[to*40]);
  myblit->size=BLTSIZE(20,amount);
  SLAM_BLITTER(myblit);
}


VOID InitStuff()
{
  register USHORT loop;
  struct RastPort *RPort;

  LED_OFF;

/**** Open Libraries ****/
  if (
    ((GfxBase=(struct GfxBase *)OpenLibrary("graphics.library",0))==NULL) ||
    ((IntuitionBase=(struct IntuitionBase *)OpenLibrary("intuition.library",0))==NULL)
     )
    { CleanUp(); }

  if ((MyScreen=(struct Screen *) OpenScreen(&NewScreenStructure))==NULL)
    CleanUp();
  vport = &(MyScreen->ViewPort);
  LoadRGB4(vport,ColorPalettes[0],32);

/*****  Set Up CopperList *****/
  CINIT(&usercopper,200)
  CWait(&usercopper,37,0); CBump(&usercopper);
  for(loop=1;loop!=32;loop++)
    {
      CMove(&usercopper,(long)&custom.color[loop],ColorPalettes[2][loop]);
      CBump(&usercopper);
    }
  CWait(&usercopper,161,0); CBump(&usercopper);
  for(loop=1;loop!=32;loop++)
    {
      CMove(&usercopper,(long)&custom.color[loop],ColorPalettes[1][loop]);
      CBump(&usercopper);
    }
  CEND(&usercopper)

/***** WINDOW OPEN *****/

  NewWindowStructure1.Screen = MyScreen;
  if ((MyWindow=(struct Window *) OpenWindow(&NewWindowStructure1))==NULL)
    CleanUp();

  ShowTitle(MyScreen,FALSE);
  SetPointer(MyWindow,(short*)&NOMOUSE[0],1,16,0,0);
  WaitFRAMES(1);

/*** Set Up the intuition data for using BM1 as double buffer to BM0 ***/
  DB_rinfo = vport->RasInfo;

/*** Show the SilverFox Logo  ***/
  UnPackByteRun(SILVERFOX,BM0);
  for(loop=1; loop<=16; loop++)
    { WaitFRAMES(3); ComputeInterColor(ColorPalettes[0],ColorPalettes[1],loop); }
  BltBitMap(&BMap[0],0,0,&BMap[1],0,0,320,200,192,15,0);
  for(loop=1; loop!=107; loop++)
    { WaitFRAMES(1); GridZAP(loop,1,loop); }
  for(loop=1; loop!=36; loop++)
    { WaitFRAMES(2);
      GridZAP(loop+107,loop,107);
      GridZAP(177-loop,177-loop,20); }


  vport->UCopIns = &usercopper; WaitFRAMES(2); RemakeDisplay();
  RPort=MyWindow->RPort;
  SetAPen(RPort,16);
  for(loop=0;loop!=10;loop++)
    {
      Move(RPort,53+loop,50);
      Draw(RPort,53+loop,150);
      Move(RPort,155+loop,50);
      Draw(RPort,155+loop,150);
      Move(RPort,257+loop,50);
      Draw(RPort,257+loop,150);
      Move(RPort,0,95+loop);
      Draw(RPort,319,95+loop);
    }

  BltBitMap(&BMap[1],0,0,&BMap[2],0,0,320,200,0xE0,15,0);
  BltBitMap(&BMap[2],2,0,&BMap[3],2,40,316,107,0x60,1,0);
  BltClear(BM1,8000,0);
  BltBitMap(&BMap[0],0,0,&BMap[2],0,0,320,200,0xE0,31,0);
  BltBitMap(&BMap[2],0,0,&BMap[3],0,0,320,200,0xC0,1,0);
  BltBitMap(&BMap[0],0,0,&BMap[1],0,0,320,200,0xC0,15,0);

  RStartPlane=FastRead; /* For ReadPoint */
  memcpy(FastRead,&BM0[32000],8000);
}

VOID __regargs DrawBall(USHORT x, USHORT y, USHORT whichBMAP)
{
  register BLIT_PARMS *myblit=&BP;
  USHORT xshift;

  xshift=(x&15); y*=40; x>>=4; x<<=1; y+=x;

  myblit->con0=(ABC|ABNC|ANBC|ANBNC)|(DEST|SRCA)|(xshift<<ASHIFTSHIFT);
  myblit->apt=(USHORT *)(ImageDataBall);
  myblit->dpt=(USHORT *)(&(BMraw[whichBMAP][y]));

  SLAM_BLITTER(myblit);
}

VOID InitBP()
{
  register BLIT_PARMS *myblit=&BP;

  myblit->dmod=40-6;
  myblit->amod=4-6;
  myblit->afwm=0xFFFF;
  myblit->adda=124;
  myblit->addcd=8000;
  myblit->size=BLTSIZE(3,31);
  myblit->planes=4;

  myblit=&BP_SCAN;

  myblit->bmod=-40;
  myblit->con0=(ABC|ABNC|NABC|NABNC)|(DEST|SRCB);
  myblit->addb=8000;
  myblit->addcd=8000;
  myblit->planes=4;

  myblit=&BP_CLEAR;

  myblit->bmod=0;
  myblit->con0=(DEST);
  myblit->addcd=8000;
  myblit->planes=1;
  myblit->size=BLTSIZE(20,31+3*4);
}

VOID DoDemo()
{
  register short xx,yy;
  short x,y,xdir,ydir,xxx,yyy;
  ULONG *place;

  x=160; y=45;
  xdir=-1; ydir=1;

  while((CurrentFront!=0)||(! LEFTMOUSE))
    {
      x+=xdir; if((x<10)||(x>278)) xdir=-xdir;
      y+=ydir; if((y<40)||(y>123)) ydir=-ydir;
      place=&ReflectPlane[0];
      BP_CLEAR.dpt=(WORD *)&BMraw[NextFront][(y-6)*40];
      for(yy=0;yy!=31;yy++)
        {
          if((yy&7)==0) SLAM_BLITTER(&BP_CLEAR);
          output=0;
          for(xx=0;xx!=31;xx++)
            {
              xxx=Xarray[yy][xx]+x;
              if((xxx>0)&&(xxx<319))
                {
                  yyy=Xarray[xx][yy]+y;
                  if ((yyy>0)&&(yyy<199)) ReadPoint(xxx,yyy);
                }
              output+=output;
            }
            *(place++)=output;
        }
      DrawBall(x,y,NextFront);
      SetView(NextFront);
    }
}

VOID CalculateMap()
{
  short  y,y1,x,x1;
  long   x2;
  double r;

  for(y=0; y<31; y++)
    {
      y1=y-15;
      for(x=0; x<32; x++)
        {
          x1=x-15;
          x2=(256-(y1*y1)-(x1*x1));
          if (x2>0)
            {
              r=32.0/sqrt((double)x2);
              r*=((double)x1);
              r+=15.5;
              x2=(short)r;
              Xarray[y][x]=x2;
            }
          else
            {
              Xarray[y][x]=9999;
            }
        }
    }
}

VOID Finish()
{
  short loop;
  struct RastPort *rport;

  rport=MyWindow->RPort;
  SetAPen(rport,0);
  for(loop=0;loop!=65;loop++)
    {
      Move(rport,loop,36+loop);
      Draw(rport,319-loop,36+loop);
      Draw(rport,319-loop,163-loop);
      Draw(rport,loop,163-loop);
      Draw(rport,loop,36+loop);
    }
  vport->UCopIns = NULL; SetView(0); WaitFRAMES(2); RemakeDisplay();
  for(loop=1; loop<=16; loop++)
    { WaitFRAMES(3); ComputeInterColor(ColorPalettes[1],ColorPalettes[0],loop); }

}

main()
{
  InitBP();
  CalculateMap();
  InitStuff();
  DoDemo();
  Finish();
  CleanUp();
}

