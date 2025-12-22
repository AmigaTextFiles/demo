/* 
 
   NULL 
 
   g_null.c 
 
   28.1.1998 
 
   graphics main 
 
*/ 
 
 
#include    "g_main.h" 
#include "m_main.h"
#include <clib/rtgmaster_protos.h>
#include <rtgmaster/rtgmaster.h>
#include <rtgmaster/rtgsublibs.h>
#include <clib/exec_protos.h>
#include <rtgmaster/rtgCGX.h>
#include <stdio.h>
#include <utility/tagitem.h>
#include <exec/libraries.h>
#include <clib/cybergraphics_protos.h>
#include <cybergraphics/cybergraphics.h>
#include <stdlib.h>

int format;

struct RtgScreen *RtgScreen;
struct ScreenReq *sr;
struct Library *RTGMasterBase;
struct Library *UtilityBase;
struct Library *CyberGfxBase;
struct TagItem rtag[] = {
    smr_MinWidth,       320,
    smr_MinHeight,      200,
    smr_MaxWidth,       320,
    smr_MaxHeight,      256,
    smr_ChunkySupport,  BGRA32|ABGR32|ARGB32|RGBA32|RGB24|BGR24,
    smr_PlanarSupport,  0,
    smr_Buffers,2,
    smr_Workbench,1,
    TAG_DONE,           NULL
};

struct TagItem gtag[] = {
    grd_BytesPerRow,    0,
    grd_Width,          0,
    grd_Height,         0,
    grd_Depth,          0,
    grd_PixelLayout,    0,
    grd_ColorSpace,     0,
    grd_PlaneSize,      0,
    grd_BusSystem,      0,
    TAG_DONE,           0
};

struct TagItem tacks[] = {
    rtg_Buffers,1,
    rtg_Workbench,0,
    TAG_DONE,0
};

unsigned long *FrameBufferAdr=0;

int wb=0;
char *mybuffer;

static cFile *border;

int borderflag=0;


void    g_freebitmap (cbitmap *b)
{
  if (b->pal) m_free ((char *)b->pal);
  if (b->data) m_free (b->data);
}
 
void    g_init(void) {  // Init Display (open screen etc.) 
    RTGMasterBase = (struct Library *)OpenLibrary((STRPTR)"rtgmaster.library", 34);
    if (!RTGMasterBase)
    {
     printf("rtgmaster.library could not be opened!\n");
     exit(0);
    }
    sr = PPCRtgScreenModeReq(rtag);
    if (sr==NULL)
    {
     printf("Screenmode-Requester could not be opened!\n");
     if (RTGMasterBase) CloseLibrary(RTGMasterBase);
     exit(0);
    }
    if (sr->Flags&sq_WORKBENCH)
    {
     wb=1;
     tacks[1].ti_Data=512;
     mybuffer=(char *)malloc(320*200*4);
     CyberGfxBase=OpenLibrary("cybergraphics.library",0);
     printf("Workbench used!\n");
    }
    RtgScreen = PPCOpenRtgScreen(sr, tacks);
    if (!RtgScreen)
    {
     printf("RtgScreen could not be opened!\n");
     if (sr) PPCFreeRtgScreenModeReq(sr);
     if (RTGMasterBase) CloseLibrary(RTGMasterBase);
     exit(0);
    }

    PPCGetRtgScreenData(RtgScreen, gtag);
    FrameBufferAdr=PPCLockRtgScreen(RtgScreen);
    border=m_loadfile("gfx/border.chk");

if ((gtag[4].ti_Data==grd_TRUECOL24)&&(gtag[5].ti_Data==grd_RGB)) format=RGB24;
else if ((gtag[4].ti_Data==grd_TRUECOL24)&&(gtag[5].ti_Data==grd_BGR)) format=BGR24;
else if ((gtag[4].ti_Data==grd_TRUECOL32)&&(gtag[5].ti_Data==grd_RGB)) format=RGBA32;
else if ((gtag[4].ti_Data==grd_TRUECOL32)&&(gtag[5].ti_Data==grd_BGR)) format=BGRA32;
else if ((gtag[4].ti_Data==grd_TRUECOL32B)&&(gtag[5].ti_Data==grd_RGB)) format=ARGB32;
else if ((gtag[4].ti_Data==grd_TRUECOL32B)&&(gtag[5].ti_Data==grd_BGR)) format=ABGR32;
else
{
 printf("This is impossible to happen!!!\n");
 if (RtgScreen) PPCCloseRtgScreen(RtgScreen);
 if (sr) PPCFreeRtgScreenModeReq(sr);
 if (RTGMasterBase) CloseLibrary(RTGMasterBase);
 if (CyberGfxBase) CloseLibrary(CyberGfxBase);
}

printf("Color Format: ");
if (format == RGB24) printf("RGB24\n");
else if (format == BGR24) printf("BGR24\n");
else if (format == RGBA32) printf("RGBA32\n");
else if (format == BGRA32) printf("BGRA32\n");
else if (format == ARGB32) printf("ARGB32\n");
else if (format == ABGR32) printf("ABGR32\n");

} 
 
void    g_shutdown(void) {   // Shutdown display (close screen..) 
if (RtgScreen) PPCCloseRtgScreen(RtgScreen);
if (sr) PPCFreeRtgScreenModeReq(sr);
if (RTGMasterBase) CloseLibrary(RTGMasterBase);
if (wb)
{
 if (mybuffer) free(mybuffer);
}
} 
 
void    g_update (rgb18 *buf) 
{ 
  long x,y; 
  unsigned char *pic = (unsigned char *) FrameBufferAdr; 
  char *tmp;
  char *p;
  if (wb) {pic=(unsigned char *) mybuffer;format=ARGB32;}
  tmp=(char *)pic;
  p=(char *) border->data;
  switch (format)
  {
   case BGRA32:
    if (!borderflag)
    {
     for (x=0;x<320*200;x++)
      {
       *tmp++=p[3];
       *tmp++=p[2];
       *tmp++=p[1];
       tmp++;
       p+=4;
      }
      borderflag=-1;
    }

    pic+=(3*36*320);
    for ( y=0;y<128;y++)
    {
     for (x=0;x<160;x++)
     {
      *pic++ = buf[0].b<<2;
      *pic++ = buf[0].g<<2;
      *pic++ = buf[0].r<<2;
      pic++;
      *pic++ = ((unsigned long)buf[0].b+buf[1].b)<<1;
      *pic++ = ((unsigned long)buf[0].g+buf[1].g)<<1;
      *pic++ = ((unsigned long)buf[0].r+buf[1].r)<<1;
      pic++;
      buf++;
     }
    }
    break;
   case ABGR32:
    if (!borderflag)
    {
     for (x=0;x<320*200;x++)
      {
       tmp++;
       *tmp++=p[3];
       *tmp++=p[2];
       *tmp++=p[1];
       p+=4;
      }
      borderflag=-1;
    }

    pic+=(3*36*320);
    for ( y=0;y<128;y++)
    {
     for (x=0;x<160;x++)
     {
      pic++;
      *pic++ = buf[0].b<<2;
      *pic++ = buf[0].g<<2;
      *pic++ = buf[0].r<<2;
      pic++;
      *pic++ = ((unsigned long)buf[0].b+buf[1].b)<<1;
      *pic++ = ((unsigned long)buf[0].g+buf[1].g)<<1;
      *pic++ = ((unsigned long)buf[0].r+buf[1].r)<<1;
      buf++;
     }
    }
    break;
   case ARGB32:
    if (!borderflag)
    {
     for (x=0;x<320*200;x++)
      {
       tmp++;
       *tmp++=p[1];
       *tmp++=p[2];
       *tmp++=p[3];
       p+=4;
      }
      borderflag=-1;
    }

    pic+=(3*36*320);
    for ( y=0;y<128;y++)
    {
     for (x=0;x<160;x++)
     {
      pic++;
      *pic++ = buf[0].r<<2;
      *pic++ = buf[0].g<<2;
      *pic++ = buf[0].b<<2;
      pic++;
      *pic++ = ((unsigned long)buf[0].r+buf[1].r)<<1;
      *pic++ = ((unsigned long)buf[0].g+buf[1].g)<<1;
      *pic++ = ((unsigned long)buf[0].b+buf[1].b)<<1;
      buf++;
     }
    }
    break;
   case RGBA32:
    if (!borderflag)
    {
     for (x=0;x<320*200;x++)
      {
       *tmp++=p[1];
       *tmp++=p[2];
       *tmp++=p[3];
       tmp++;
       p+=4;
      }
      borderflag=-1;
    }

    pic+=(3*36*320);
    for ( y=0;y<128;y++)
    {
     for (x=0;x<160;x++)
     {
      *pic++ = buf[0].r<<2;
      *pic++ = buf[0].g<<2;
      *pic++ = buf[0].b<<2;
      pic++;
      *pic++ = ((unsigned long)buf[0].r+buf[1].r)<<1;
      *pic++ = ((unsigned long)buf[0].g+buf[1].g)<<1;
      *pic++ = ((unsigned long)buf[0].b+buf[1].b)<<1;
      pic++;
      buf++;
     }
    }
    break;
   case RGB24:
    if (!borderflag)
    {
     for (x=0;x<320*200;x++)
      {
       *tmp++=p[1];
       *tmp++=p[2];
       *tmp++=p[3];
       p+=4;
      }
      borderflag=-1;
    }

    pic+=(3*36*320);
    for ( y=0;y<128;y++)
    {
     for (x=0;x<160;x++)
     {
      *pic++ = buf[0].r<<2;
      *pic++ = buf[0].g<<2;
      *pic++ = buf[0].b<<2;
      *pic++ = ((unsigned long)buf[0].r+buf[1].r)<<1;
      *pic++ = ((unsigned long)buf[0].g+buf[1].g)<<1;
      *pic++ = ((unsigned long)buf[0].b+buf[1].b)<<1;
      buf++;
     }
    }
    break;
   case BGR24:
    if (!borderflag)
    {
     for (x=0;x<320*200;x++)
      {
       *tmp++=p[3];
       *tmp++=p[2];
       *tmp++=p[1];
       p+=4;
      }
      borderflag=-1;
    }

    pic+=(3*36*320);
    for ( y=0;y<128;y++)
    {
     for (x=0;x<160;x++)
     {
      *pic++ = buf[0].b<<2;
      *pic++ = buf[0].g<<2;
      *pic++ = buf[0].r<<2;
      *pic++ = ((unsigned long)buf[0].b+buf[1].b)<<1;
      *pic++ = ((unsigned long)buf[0].g+buf[1].g)<<1;
      *pic++ = ((unsigned long)buf[0].r+buf[1].r)<<1;
      buf++;
     }
    }
    break;
  }
  if (wb)
  {
   struct Window *win=((struct RtgScreenCGX *)RtgScreen)->MyWindow;
   if ((format==RGB24)||(format==BGR24))
   WritePixelArray(mybuffer,0,0,320*3,win->RPort,0,0,320,200,RECTFMT_ARGB);
   else
   WritePixelArray(mybuffer,0,0,320*4,win->RPort,0,0,320,200,RECTFMT_ARGB);
  }
 }


