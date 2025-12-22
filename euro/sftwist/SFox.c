;/*  SFTWIST -- C demo by SilverFox
SC DATA=NEAR COMNEST NMINC NOSTKCHK OPTIMIZE OPTTIME SFox.c
;SC DATA=NEAR COMNEST NMINC NOSTKCHK DEBUG=FULL SFox.c
quit
*/

/*
 *  This code is written by Adisak Pochanayon of SilverFox
 *  SoftWare.  It will run on any Amiga with at least 1 MB
 *  of memory although a 68020+ processor is highly
 *  recommended.
 *
 *  Freely Distributable as the entire archive only!!!
 *
 *  Copyright 1993 Adisak Pochanayon.
 */

#include <proto/exec.h>
#include <proto/intuition.h>
#include <proto/graphics.h>
#include <proto/layers.h>

#include <exec/memory.h>
#include <exec/execbase.h>

#include <stdlib.h>
#include <string.h>

/*** MED MUSIC ***/
//#include <med/modplayer/modplayer.h>
#include "modplayer.h"
#include "iff.h"

extern struct MMD0 far MEDSONG;

void __chkabort(void) {}	/* Disable SAS CTRL-C handling */

/***** Declarations for CBACK *****/
long __BackGroundIO = 0;
long __stack = 10000;
char *__procname = "TWIST by SilverFox";
long __priority = 8;

/*****  Libraries  *****/
struct IntuitionBase *IntuitionBase=NULL;
struct GfxBase       *GfxBase=NULL;
struct Library       *LayersBase=NULL;
struct Library       *IFFBase=NULL;

extern unsigned char far BM0[32000];
extern unsigned char SILVERFOX[1];

/****
struct BitMap
  { UWORD BytesPerRow, Rows;
    UBYTE Flags, Depth;
    UWORD   pad;
    PLANEPTR Planes[8]; }
****/
struct BitMap BMap =
{ 40, 200, 0, 4, 0, &BM0[16000], &BM0[8000], &BM0[24000],
  &BM0[0], NULL, NULL, NULL, NULL };

struct BitMap LineMap =
{ 40, 200, 0, 1, 0, &BM0[24000], NULL, NULL, NULL, NULL, NULL, NULL, NULL };

struct BitMap LoadMap =
{ 40, 200, 0, 1, 0, &BM0[0], NULL, NULL, NULL, NULL, NULL, NULL, NULL };

struct Layer_Info *LI=NULL;
struct Layer *layer=NULL;

struct NewScreen NewScreenStructure = {
	0,0,	/* screen XY origin relative to View */
	320,200,	/* screen width and height */
	4,	/* screen depth (number of bitplanes) */
	0,1,	/* detail and block pens */
	SPRITES,	/* display modes for this screen */
	SCREENQUIET|CUSTOMSCREEN|CUSTOMBITMAP,	/* screen type */
	NULL,	/* pointer to default screen font */
	NULL,	/* screen title */
	NULL,	/* first in list of custom screen gadgets */
	&BMap	/* pointer to custom BitMap structure */
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
	(UWORD)-1,(UWORD)-1,	/* maximum width and height */
	CUSTOMSCREEN	/* destination screen type */
};

struct Window *MyWindow=NULL;

extern ULONG far NOMOUSE[];

UBYTE *MASSIVE_STORAGE[80];
UBYTE DOLINE[320];
UBYTE direction[200];

struct RastPort *rp1;

char *funfile=NULL;

WORD SquiggleArray[200+320+320];

WORD ColorPalette[16] = { 0x000,0x558,0x88B,0xFFF };

WORD SUPER[48]=
{ 0x00F,0x10E,0X20D,0X30C,0X40B,0X50A,0X609,0X708,
  0X807,0X906,0XA05,0XB04,0XC03,0XD02,0XE01,0XF00,
  0XF00,0XE10,0XD20,0XC30,0XB40,0XA50,0X960,0X870,
  0X780,0X690,0X5A0,0X4B0,0X3C0,0X2D0,0x1E0,0x0F0,
  0X0F0,0X0E1,0X0D2,0X0C3,0X0B4,0X0A5,0X096,0X087,
  0X078,0X069,0X05A,0X04B,0X03C,0X02D,0X01E,0X00F };

VOID __regargs GoLine(WORD line_d0);
VOID __regargs UnPackSLZ(UBYTE *from_a0, UBYTE *to_a1);
VOID __regargs BresenFold(UBYTE *from_a0, UBYTE *to_a1);
VOID __regargs ReverseIt(UBYTE *from_a0, UBYTE *to_a1);

VOID __regargs StarOffsets(ULONG mod_d0);
VOID ComputeStarField(void);
VOID DisplayStarField(void);
extern PLANEPTR far Plane1ptr;
extern PLANEPTR far Plane2ptr;

/***************  Beginning of code  ***************/

VOID CleanUp(void)
{
  WORD loop;

  if (MyWindow!=NULL)
    CloseWindow(MyWindow);
  if (MyScreen!=NULL)
    CloseScreen(MyScreen);
  if (layer)
    DeleteLayer((long)LI,layer);
  if (LI)
    DisposeLayerInfo(LI);
  if (IFFBase!=NULL)
    CloseLibrary(IFFBase);
  if (LayersBase!=NULL)
    CloseLibrary(LayersBase);
  if (IntuitionBase!=NULL)
    CloseLibrary((struct Library *)IntuitionBase);
  if (GfxBase!=NULL)
    CloseLibrary((struct Library *)GfxBase);
  for(loop=0; loop!=80; loop++)
    {
      if (MASSIVE_STORAGE[loop])
        FreeMem(MASSIVE_STORAGE[loop],8000);
    }
  exit(0);
}

VOID InitStuff(void)
{
  WORD loop;
  IFFL_HANDLE iff;

/**** Get Memory Chunk ****/
  for(loop=0; loop!=200; loop++)
    direction[loop]=0;
  for(loop=0; loop!=80; loop++)
    MASSIVE_STORAGE[loop]=NULL;
  for(loop=0; loop!=80; loop++)
    {
      if ((MASSIVE_STORAGE[loop]=AllocMem(8000,MEMF_PUBLIC|MEMF_CLEAR))==NULL)
        CleanUp();
    }

/**** Open Libraries ****/
  if (
    ((GfxBase=(struct GfxBase *)OpenLibrary("graphics.library",0))==NULL) ||
    ((IntuitionBase=(struct IntuitionBase *)OpenLibrary("intuition.library",0))==NULL) ||
    ((LayersBase=OpenLibrary("layers.library",0))==NULL)  ||
    ((IFFBase = OpenLibrary(IFFNAME, IFFVERSION))==NULL)
     )
    { CleanUp(); }

/**** Funky Self Layers Stuff ****/
  if ((LI=NewLayerInfo())==NULL)
    CleanUp();
  if ((layer=CreateUpfrontLayer(LI,&LineMap,0,0,319,199,LAYERSIMPLE,NULL))==NULL)
    CleanUp();
  rp1=layer->rp; SetDrMd(rp1,COMPLEMENT); SetAPen(rp1,1);

/***** SCREEN OPEN *****/
  if ((MyScreen=(struct Screen *) OpenScreen(&NewScreenStructure))==NULL)
    CleanUp();
  LoadRGB4(&MyScreen->ViewPort,ColorPalette,16);

/***** WINDOW OPEN *****/

  NewWindowStructure1.Screen = MyScreen;
  if ((MyWindow=(struct Window *) OpenWindow(&NewWindowStructure1))==NULL)
    CleanUp();

  SetPointer(MyWindow,(short*)&NOMOUSE[0],1,16,0,0);
  SetRast(MyWindow->RPort,0);

/*** Show the SilverFox Logo -- BEGIN DEMO  ***/
  Plane1ptr=&BM0[16000];
  Plane2ptr=&BM0[8000];
  StarOffsets(40);

  WaitTOF(); WaitTOF();
  loop=1;
  if(funfile)
    {
      if(iff = IFFL_OpenIFF(funfile, IFFL_MODE_READ) )
        {
          if(IFFL_DecodePic(iff,&LoadMap))
            {
              loop=0;
            }
        }
    }
  if(loop)
    {
      UnPackSLZ(SILVERFOX,BM0);
    }
}

VOID MakeSquiggle(void)
{
  WORD loop;
  for(loop=640; loop!=(320+320+200); loop++)
    {
      SquiggleArray[loop]=79;      
    }
  for(loop=0; loop!=80; loop++)
    {
      SquiggleArray[loop]    =79-loop;
      SquiggleArray[loop+80] =loop;
      SquiggleArray[loop+160]=79-loop;
      SquiggleArray[loop+240]=loop;
      SquiggleArray[loop+320]=79-loop;
      SquiggleArray[loop+400]=loop;
      SquiggleArray[loop+480]=79-loop;
      SquiggleArray[loop+560]=loop;
    }
}

LONG main( int argc, char **argv )
{
  WORD Activated,loop2,count,thecolor1=0,thecolor2=24;
  UBYTE *to,*mydir;
  WORD *Squigs;

  WORD dirx1=+4,diry1=-3;
  WORD dirx2=+3,diry2=-2;
  WORD currentx1=160, currenty1=50;
  WORD currentx2=160, currenty2=50;
  WORD history=0;
  WORD hy1[8]={300,300,300,300,300,300,300,300};
  WORD hy2[8]={300,300,300,300,300,300,300,300};
  WORD hx1[8]={400,400,400,400,400,400,400,400};
  WORD hx2[8]={400,400,400,400,400,400,400,400};

  WORD FASTCPU;

  FASTCPU = (*((struct ExecBase **)(4L)))->AttnFlags;
  if(FASTCPU&AFF_68030) FASTCPU=TRUE; else FASTCPU=FALSE;
  if (argc==2) funfile=argv[1];

  InitStuff();
  MakeSquiggle();
  RelocModule(&MEDSONG);
  InitPlayer();
  PlayModule(&MEDSONG);
  count=640; Activated=FALSE; loop2=0;
  while(GetMsg(MyWindow->UserPort)==0)
    {
      if(Activated)
        {
          to=&BM0[0];
          Squigs=&SquiggleArray[count];
          if((--count)==0)
            {
              count+=320;
            }
          mydir=&direction[0];
          for(loop2=0; loop2<(200*40); loop2+=40)
            {
              if(*mydir)
                ReverseIt(&MASSIVE_STORAGE[*Squigs][loop2],to);
              else
                BresenFold(&MASSIVE_STORAGE[*Squigs][loop2],to);
              if((Squigs[0]==0)&&(Squigs[1]==0))
                *mydir=*mydir^1;
              mydir++;
              to += 40;
              Squigs+=1;
            }
          ComputeStarField();
          if (FASTCPU) WaitTOF();
          DisplayStarField();
        }
      else
        {
          GoLine(loop2);
          if((loop2+=40)==(200*40)) Activated=TRUE;
        }
      Move(rp1,hx1[history],hy1[history]);
      Draw(rp1,hx2[history],hy2[history]);
      hx1[history]=(currentx1+=dirx1);
      hy1[history]=(currenty1+=diry1);
      hx2[history]=(currentx2+=dirx2);
      hy2[history]=(currenty2+=diry2);
      if((currentx1<10)||(currentx1>310)) dirx1=-dirx1;
      if((currentx2<10)||(currentx2>310)) dirx2=-dirx2;
      if((currenty1<10)||(currenty1>190)) diry1=-diry1;
      if((currenty2<10)||(currenty2>190)) diry2=-diry2;
      Move(rp1,currentx1,currenty1);
      Draw(rp1,currentx2,currenty2);
      history++; history&=7;
      thecolor1++; if (thecolor1==48) thecolor1=0;
      if(((thecolor1)&3)==0)
        {
          thecolor2++; if (thecolor2==48) thecolor2=0;
        }
      ColorPalette[4]=ColorPalette[5]=ColorPalette[6]=
        ColorPalette[7]=SUPER[thecolor1];
      ColorPalette[8]=ColorPalette[9]=ColorPalette[10]=
        ColorPalette[11]=ColorPalette[12]=ColorPalette[13]=
        ColorPalette[14]=ColorPalette[15]=SUPER[thecolor2];
      LoadRGB4(&MyScreen->ViewPort,ColorPalette,16);
    }
  RemPlayer();
  CleanUp();
}

