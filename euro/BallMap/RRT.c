;/* Realtime Ray Tracer
lc -b1 -ccit -v -D RRT.c
quit
*/

#include "rrt.h"

/*** MED MUSIC ***/
extern struct MMD0 far MEDSONG;

/***** Declarations for CBACK *****/
long _BackGroundIO = 0;
char *_procname = 0;
long _stack = 10000;
long _priority = 50;

int CXBRK(void) { return(0); }		/* Disable Lattice CTRL-C handling */
int chkabort(void) { return(0); }	    /* really */

/*****  Libraries and HardWare  *****/
struct IntuitionBase *IntuitionBase=NULL;
struct GfxBase       *GfxBase=NULL;
extern struct Custom __far custom;

/*****  Graphics Data  *****/
extern unsigned char far BM0[32000];
extern unsigned char far BM1[32000];

char FastRead[8000];
ULONG output;

extern unsigned char far SILVERFOX[1];
UWORD ImageDataBall[] = {
  0x003F,0xF800,0x00F0,0xFE00,0x03C0,0x3380,0x06CF,0x33C0,
  0x0F00,0xC8E0,0x1B00,0xCCF0,0x3D3C,0xEC78,0x3F3C,0xEC38,
  0x6B3C,0xE63C,0x433C,0xE63C,0x9300,0xE63E,0xB900,0xCC3E,
  0x9CFF,0x8C3E,0x9E7F,0x1C3E,0x8F3C,0x3C1E,0x8F80,0x3C0E,
  0x8FC0,0x3E06,0x87E0,0x3F02,0xC1F8,0x1F82,0xC0FC,0x0FC2,
  0xE07C,0x07C2,0x703C,0x03C0,0x7838,0xF1CC,0x3C31,0xF8C8,
  0x3C33,0x0CF8,0x1E33,0x0CF0,0x0E33,0x0F20,0x0733,0x0B00,
  0x038D,0xFC80,0x00E6,0x6800,0x003E,0x0800,

  0x003F,0xF800,0x00FF,0xFE00,0x0380,0x0F80,0x070F,0x0FC0,
  0x0C7F,0xC7E0,0x1CFF,0xC3F0,0x31C3,0xE3F8,0x33C3,0xE3F8,
  0x73C3,0xE1FC,0x73C3,0xE1FC,0xE3FF,0xE1FE,0xC1FF,0xC3FE,
  0xE0FF,0x83FE,0xE07F,0x03FE,0xF03C,0x03FE,0xF000,0x03FE,
  0xF000,0x01FE,0xF800,0x00FE,0xFE00,0x007E,0xFF00,0x003E,
  0xFF80,0x003E,0x7FC0,0x003C,0x7FC0,0xF03C,0x3FC1,0xF838,
  0x3FC3,0xFC38,0x1FC3,0xFC30,0x0FC3,0xFCE0,0x07C3,0xF8C0,
  0x03F1,0xF380,0x00F8,0x6600,0x003F,0xF800,

  0x003F,0xF800,0x00FF,0xFE00,0x03FF,0xFF80,0x07F0,0xFFC0,
  0x0F80,0x3FE0,0x1F00,0x3FF0,0x3E00,0x1FF8,0x3C00,0x1FF8,
  0x7C00,0x1FFC,0x7C00,0x1FFC,0xFC00,0x1FFE,0xFE00,0x3FFE,
  0xFF00,0x7FFE,0xFF80,0xFFFE,0xFFC3,0xFFFE,0xFFFF,0xFFFE,
  0xFFFF,0xFFFE,0xFFFF,0xFFFE,0xFFFF,0xFFFE,0xFFFF,0xFFFE,
  0xFFFF,0xFFFE,0x7FFF,0xFFFC,0x7FFF,0x0FFC,0x3FFE,0x07F8,
  0x3FFC,0x03F8,0x1FFC,0x03F0,0x0FFC,0x03E0,0x07FC,0x07C0,
  0x03FE,0x0F80,0x00FF,0x9E00,0x003F,0xF800
};

/****
struct BitMap
  { UWORD BytesPerRow, Rows;
    UBYTE Flags, Depth;
    UWORD   pad;
    PLANEPTR Planes[8]; }
****/
struct BitMap BMap[] =
{{ 40, 200, 0, 4, 0, &BM0[0], &BM0[8000], &BM0[16000], &BM0[24000],  NULL, NULL, NULL, NULL },
 { 40, 200, 0, 4, 0, &BM1[0], &BM1[8000], &BM1[16000], &BM1[24000],  NULL, NULL, NULL, NULL },
 { 40, 200, 0, 4, 0, &BM1[0], &BM1[0], &BM1[0], &BM1[0], NULL, NULL, NULL, NULL },
 { 40, 200, 0, 1, 0, &BM0[24000], NULL, NULL, NULL, NULL, NULL, NULL, NULL },
 { 40, 200, 0, 1, 0, &BM0[16000], NULL, NULL, NULL, NULL, NULL, NULL, NULL }
};

struct RasInfo  *DB_rinfo = NULL;
struct ViewPort *vport = NULL;

struct NewScreen NewScreenStructure = {
	0,0,	/* screen XY origin relative to View */
	320,200,	/* screen width and height */
	4,	/* screen depth (number of bitplanes) */
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
	VANILLAKEY,	/* IDCMP flags */
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

struct UCopList   usercopper;

UWORD ColorPalettes[][32] =
{
  { 0x000,0x000,0x000,0x000,0x000,0x000,0x000,0x000,
    0x000,0x000,0x000,0x000,0x000,0x000,0x000,0x000,
    0x000,0x000,0x000,0x000,0x000,0x000,0x000,0x000,
    0x000,0x000,0x000,0x000,0x000,0x000,0x000,0x000 },
  { 0x000,0xFFF,0xFEF,0xEDF,0xDCF,0xDBF,0xCAF,0xC9F, /* SilverFox Colors */
    0xB8F,0xB6F,0xA5F,0xA4F,0x93F,0x92F,0x81F,0x80F,
    0x0F0,0xF00,0xD00,0xB00,0x900,0x800,0x600,0x400, /* Reflect Colors */
    0x0F0,0xAAF,0x99D,0x88B,0x779,0x668,0x556,0x444 },

  { 0x000,0x558,0x88B,0xFFF,0x000,0x558,0x88B,0xFFF, /* Plane and stars */
    0x49F,0x49F,0x49F,0x49F,0x00F,0x00F,0x00F,0x00F }
};

short Xarray[32][32];
short Yarray[32][32];
ULONG Yoffsets[200];

extern ULONG far NOMOUSE[];

extern UWORD chip Sprite2_data[31*2+4];
extern UWORD chip Sprite3_data[31*2+4];
extern UWORD chip Sprite3a_data[31*2+4];
extern UWORD chip Sprite4_data[31*2+4];
extern UWORD chip Sprite5_data[31*2+4];
extern UWORD chip Sprite5a_data[31*2+4];
struct SimpleSprite Sprite2;
struct SimpleSprite Sprite3;
struct SimpleSprite Sprite4;
struct SimpleSprite Sprite5;
short spg2=0,spg3=0,spg4=0,spg5=0;

/* * * * * * * * * * * EXTERNAL ROUTINES * * * * * * * * * */
VOID __regargs UnPackByteRun(UBYTE *from, UBYTE *to);
VOID __regargs ComputeInterColor(UWORD *from, UWORD *to, UWORD step);
VOID __regargs WaitFRAMES(UWORD frames);
VOID __regargs SLAM_BLITTER(BLIT_PARMS *a0);

VOID DoDemo();

VOID __regargs StarOffsets(ULONG mod_d0);
VOID ComputeStarField();
VOID DisplayStarField();
extern PLANEPTR far Plane1ptr;
extern PLANEPTR far Plane2ptr;


/***************  Beginning of code  ***************/

VOID CleanUp()
{
  if (DB_rinfo!=NULL)
    { vport->UCopIns = NULL; RemakeDisplay(); }
  if (MyWindow!=NULL)
    CloseWindow(MyWindow);
  if (spg5==5) FreeSprite(5);
  if (spg4==4) FreeSprite(4);
  if (spg3==3) FreeSprite(3);
  if (spg2==2) FreeSprite(2);
  if (MyScreen!=NULL)
    { FreeCopList(usercopper.CopList);
      CloseScreen(MyScreen); }
  if (IntuitionBase!=NULL)
    CloseLibrary((struct Library *)IntuitionBase);
  if (GfxBase!=NULL)
    CloseLibrary((struct Library *)GfxBase);
  exit(0);
}

VOID __regargs GridZAP(short from,short to,short amount)
{
  BLIT_PARMS myblit;

  myblit.dmod=0;
  myblit.con1=0;
  myblit.bmod=-40;
  myblit.con0=(ABC|ABNC|NABC|NABNC)|(DEST|SRCB);
  myblit.addb=8000;
  myblit.addcd=8000;
  myblit.planes=4;
  myblit.bpt=(USHORT *)(&BM1[from*40]);
  myblit.dpt=(USHORT *)(&BM0[to*40]);
  myblit.size=BLTSIZE(20,amount);
  SLAM_BLITTER(&myblit);
}

VOID __regargs mybbm(struct Bitmap *f,long fy,struct Bitmap *t,long ty,long h,long m,long p)
{ BltBitMap(f,0,fy,t,0,ty,320,h,m,p,0); }

VOID InitStuff()
{
  register USHORT loop;
  struct RastPort *RPort;

/**** Open Libraries ****/
  if (
    ((GfxBase=(struct GfxBase *)OpenLibrary("graphics.library",0))==NULL) ||
    ((IntuitionBase=(struct IntuitionBase *)OpenLibrary("intuition.library",0))==NULL)
     )
    { CleanUp(); }

/***** SCREEN OPEN *****/
  if ((MyScreen=(struct Screen *) OpenScreen(&NewScreenStructure))==NULL)
    CleanUp();
  vport = &(MyScreen->ViewPort);
  vport->SpritePriorities=0;
  LoadRGB4(vport,ColorPalettes[0],32);

/*****  Set Up CopperList *****/
  CINIT(&usercopper,200)
  CWait(&usercopper,37,0); CBump(&usercopper);
  for(loop=1;loop!=16;loop++)
    {
      CMove(&usercopper,(long)&custom.color[loop],ColorPalettes[2][loop]);
      CBump(&usercopper);
    }
  CWait(&usercopper,161,0); CBump(&usercopper);
  for(loop=1;loop!=16;loop++)
    {
      CMove(&usercopper,(long)&custom.color[loop],ColorPalettes[1][loop]);
      CBump(&usercopper);
    }
  CEND(&usercopper)

/**** Get Sprites ****/
  if (
    ((spg2=GetSprite(&Sprite2,2))==-1) ||
    ((spg3=GetSprite(&Sprite3,3))==-1) ||
    ((spg4=GetSprite(&Sprite4,4))==-1) ||
    ((spg5=GetSprite(&Sprite5,5))==-1)
     )
    { CleanUp(); }
  Sprite2.height=Sprite3.height=Sprite4.height=Sprite5.height=31;

  ChangeSprite(vport,&Sprite2,Sprite2_data);
  ChangeSprite(vport,&Sprite3,Sprite3_data);
  ChangeSprite(vport,&Sprite4,Sprite4_data);
  ChangeSprite(vport,&Sprite5,Sprite5_data);
  Sprite3_data[1]|=SPRITE_ATTACHED;
  Sprite5_data[1]|=SPRITE_ATTACHED;
  Sprite3a_data[1]|=SPRITE_ATTACHED;
  Sprite5a_data[1]|=SPRITE_ATTACHED;

/***** WINDOW OPEN *****/

  NewWindowStructure1.Screen = MyScreen;
  if ((MyWindow=(struct Window *) OpenWindow(&NewWindowStructure1))==NULL)
    CleanUp();

  ShowTitle(MyScreen,FALSE);
  SetPointer(MyWindow,(short*)&NOMOUSE[0],1,16,0,0);
  WaitFRAMES(1);
  RemakeDisplay();

/*** Set Up the intuition data for using BM1 as double buffer to BM0 ***/
  DB_rinfo = vport->RasInfo;

/*** Show the SilverFox Logo -- BEGIN DEMO  ***/
  RelocModule(&MEDSONG);
  InitPlayer();
  PlayModule(&MEDSONG);

  UnPackByteRun(SILVERFOX,BM0);
  for(loop=1; loop<=16; loop++)
    { WaitFRAMES(3); ComputeInterColor(ColorPalettes[0],ColorPalettes[1],loop); }
  mybbm(&BMap[0],0,&BMap[1],0,200,192,15);
  for(loop=1; loop!=107; loop++)
    { WaitFRAMES(1); GridZAP(loop,1,loop); }
  for(loop=1; loop!=36; loop++)
    { WaitFRAMES(2);
      GridZAP(loop+107,loop,107);
      GridZAP(177-loop,177-loop,20); }

  vport->UCopIns = &usercopper; RemakeDisplay();
  RPort=MyWindow->RPort;
  SetAPen(RPort,12);
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

  mybbm(&BMap[1],0,&BMap[2],0,200,0xE0,14);
  mybbm(&BMap[2],0,&BMap[0],40,107,0x60,8);
  mybbm(&BMap[3],40,&BMap[4],40,107,0x80,1);
  memset(BM1,0,8000);
  mybbm(&BMap[0],0,&BMap[2],0,200,0xE0,15);
  OwnBlitter(); WaitBlit(); DisownBlitter();
  memcpy(FastRead,BM1,8000);
  mybbm(&BMap[0],0,&BMap[1],0,200,0xC0,15);

  MoveSprite(vport,&Sprite2,100,45);
  MoveSprite(vport,&Sprite4,116,45);
  for(loop=0;loop!=62;loop+=2)
    {
Sprite2_data[2+loop]=ImageDataBall[0+loop];
Sprite2_data[3+loop]=ImageDataBall[31*2+loop];
Sprite3_data[2+loop]=Sprite3a_data[2+loop]=ImageDataBall[31*4+loop];
//Sprite3_data[3+loop]=0;
Sprite4_data[2+loop]=ImageDataBall[1+loop];
Sprite4_data[3+loop]=ImageDataBall[(1+31*2)+loop];
Sprite5_data[2+loop]=Sprite5a_data[2+loop]=ImageDataBall[(1+31*4)+loop];
//Sprite5_data[3+loop]=0;
    }
  StarOffsets(40);
  Plane1ptr=&BM0[46*40+0];
  Plane2ptr=&BM0[46*40+8000];
}

VOID CalculateMap()
{
  short  y1,x,x1;
  long   y,x2;
  double r;

  for(y=0; y<32; y++)
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
              Yarray[x][y]=x2;
            }
          else
            {
              Xarray[y][x]=9999;
              Yarray[x][y]=9999;
            }
        }
    }
  x2=(ULONG)FastRead;;
  for(y=0;y!=200;y++)
    {
      Yoffsets[y]=x2;
      x2+=40;
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
  vport->UCopIns = NULL; RemakeDisplay();
  for(loop=1; loop<=16; loop++)
    { WaitFRAMES(3); ComputeInterColor(ColorPalettes[1],ColorPalettes[0],loop); }
  RemPlayer();
}

main()
{
  CalculateMap();
  InitStuff();
  DoDemo();
  Finish();
  CleanUp();
}

