/************************************************************************
 * Sparks.c -- One of those graphics dazzlers which are so easy to do on
 *            the Amiga.  Aside from that, I think it is a fairly decent
 *            example of how to do simple things - menus, for example,
 *            using Intuition.  Hope ya'all enjoy it.
 *
 *            Copyright (c) 1985 by Scott Ballantyne
 *            Mainly so I can say give it away, distribute it, post it
 *            on other nets, etc.
 ************************************************************************/

#include <exec/types.h> /* Not all of these are used -- I include them */
#include <exec/nodes.h> /* 'cause I'm sick of compiler warnings.       */
#include <exec/lists.h>
#include <exec/exec.h>
#include <exec/execbase.h>
#include <exec/ports.h>
#include <exec/devices.h>
#include <exec/memory.h>
#include <hardware/blit.h>
#include <graphics/copper.h>
#include <graphics/regions.h>
#include <graphics/rastport.h>
#include <graphics/gfxbase.h>
#include <graphics/gfxmacros.h>
#include <graphics/gels.h>
#include <intuition/intuition.h>

struct IntuitionBase *IntuitionBase = NULL;
struct GfxBase *GfxBase = NULL;


#define MAXX   640

struct NewScreen MyScreen =
{ 0,0,MAXX,200,4,0,1,HIRES, CUSTOMSCREEN, NULL, "Sparks!", 0,0,};

   struct NewWindow DrawWindow = {
      0,0,MAXX,200,
      0,1,
      MENUPICK,
      BORDERLESS | BACKDROP | ACTIVATE,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      0,0,0,0,
      CUSTOMSCREEN,
   };

struct Screen *Screen = NULL;
struct Window *Backdrop = NULL;
struct RastPort *DrawRP;
struct ViewPort *DrawVP;
struct IntuiMessage  *message;

struct MenuItem OnlyMenuItems[3];
struct IntuiText OnlyMenuText[3];
struct Menu OnlyMenu[1];

#define MAXLINES  125
#define ERASE     0
main()
{
   int lx1[MAXLINES], lx2[MAXLINES], x1, x2;
   UBYTE ly1[MAXLINES], ly2[MAXLINES], y1, y2;
   UBYTE  cl;
   BYTE color;
   int deltax1, deltay1, deltax2, deltay2;
   ULONG class;
   USHORT code, ItemNum;

   for(x1 = 0; x1 < MAXLINES; x1++)
      lx1[x1] = ly1[x1] = lx2[x1] = ly2[x1] = 0;

   color = 2;

   x1 = x2 = 160;
   y1 = y2 = 100;
   cl = 0;
   selectdelta(&deltax1, &deltay1, &deltax2, &deltay2);

   if (!(IntuitionBase = (struct IntuitionBase *)OpenLibrary("intuition.library",0)))
         exit(1);

   if(!(GfxBase = (struct GfxBase *)OpenLibrary("graphics.library",0))) {
      cleanitup();
      exit(2);
   }

   if(!(Screen = (struct Screen *)OpenScreen(&MyScreen))) {
      cleanitup();
      exit(3);
   }

   DrawWindow.Screen = Screen;

   if(!(Backdrop = (struct Window *)OpenWindow(&DrawWindow))) {
      cleanitup();
      exit(4);
   }


   DrawRP = Backdrop->RPort;     /* Draw into backdrop window */
   DrawVP = &Screen->ViewPort;   /* Set colors in Screens VP  */
   setcolors();

   initmenuitems();
   initmenu();
   SetMenuStrip(Backdrop, &OnlyMenu[0]);

   FOREVER {
      while(message = (struct IntuiMessage *)GetMsg(Backdrop->UserPort)) {
         class = message->Class;
         code = message->Code;
         ReplyMsg(message);

         if (class == MENUPICK && code != MENUNULL) {
            ItemNum = ITEMNUM( code );
            switch (ItemNum) {
               case 0:
                  ShowTitle(Screen, FALSE);
                  break;
               case 1:
                  ShowTitle(Screen, TRUE);
                  break;
               case 2:
                  ClearMenuStrip(Backdrop);
                  cleanitup();
                  exit(0);
            }
         }
      }

      draw(lx1[cl], ly1[cl], lx2[cl], ly2[cl], ERASE);
      if (RangeRand(6) == 0)
         color = RangeRand(16);
      if (RangeRand(6) == 0)
         selectdelta(&deltax1, &deltay1, &deltax2, &deltay2);
      adjust_x(&x1, &deltax1);
      adjust_y(&y1, &deltay1);
      adjust_x(&x2, &deltax2);
      adjust_y(&y2, &deltay2);
      draw(x1, y1, x2, y2, color);
      lx1[cl] = x1;
      lx2[cl] = x2;
      ly1[cl] = y1;
      ly2[cl] = y2;
      if (++cl >= MAXLINES)
         cl = 0;
   }
}

cleanitup()    /* release allocated resources */
{
   if (Backdrop)
      CloseWindow(Backdrop);
   if (Screen)
      CloseScreen(Screen);
   if (GfxBase)
      CloseLibrary(GfxBase);
   if (IntuitionBase)
      CloseLibrary(IntuitionBase);
}

adjust_x(x, deltax)  /* make new xcor - if out of range adjust */
int *x, *deltax;
{
   int junk;

   junk = *x + *deltax;
   if (junk < 1 | junk >= MAXX) {
      junk = *x;
      *deltax *= -1;
   }
   *x = junk;
}

adjust_y(y, deltay)
UBYTE  *y;
int  *deltay;
{
   int junk;

   junk = *y + *deltay;
   if (junk < 1 | junk > 199) {
      junk = *y;
      *deltay *= -1;
   }
   *y = junk;
}

selectdelta(dx1, dy1, dx2, dy2)
int *dx1, *dy1, *dx2, *dy2;
{
   *dx1 = 2 * (RangeRand(7) - 3);
   *dy1 = 2 * (RangeRand(7) - 3);
   *dx2 = 2 * (RangeRand(7) - 3);
   *dy2 = 2 * (RangeRand(7) - 3);
}

draw(x1, y1, x2, y2, color)
int x1, x2;
UBYTE y1, y2;
BYTE color;
{
   SetAPen(DrawRP, color);
   SetDrMd(DrawRP, JAM1);
   Move(DrawRP, x1, y1);
   Draw(DrawRP, x2, y2);
}

setcolors()
{
   SetRGB4(DrawVP, 0, 0, 0, 0);
   SetRGB4(DrawVP, 1, 3, 5, 10);
   SetRGB4(DrawVP, 2, 15, 15, 15);
   SetRGB4(DrawVP, 3, 15, 6, 0);
   SetRGB4(DrawVP, 4, 14, 3, 0);
   SetRGB4(DrawVP, 5, 15, 11, 0);
   SetRGB4(DrawVP, 6, 15, 15, 2);
   SetRGB4(DrawVP, 7, 11, 15, 0);
   SetRGB4(DrawVP, 8, 5, 13, 0);
   SetRGB4(DrawVP, 9, 0, 0, 15);
   SetRGB4(DrawVP, 10, 3, 6, 15);
   SetRGB4(DrawVP, 11, 7, 7, 15);
   SetRGB4(DrawVP, 12, 12, 0, 14);
   SetRGB4(DrawVP, 13, 15, 2, 14);
   SetRGB4(DrawVP, 15, 13, 11, 8);
}

initmenuitems()
{
   short n;

   for(n = 0; n < 3; n++) {  /* One struct for each item */
      OnlyMenuItems[n].NextItem = &OnlyMenuItems[n + 1]; /* next item */
      OnlyMenuItems[n].LeftEdge = 0;
      OnlyMenuItems[n].TopEdge = 10 * n;
      OnlyMenuItems[n].Width = 112;
      OnlyMenuItems[n].Height = 10;
      OnlyMenuItems[n].Flags = ITEMTEXT | ITEMENABLED | HIGHCOMP;
      OnlyMenuItems[n].MutualExclude = 0;
      OnlyMenuItems[n].ItemFill = (APTR)&OnlyMenuText[n];
      OnlyMenuItems[n].SelectFill = NULL;
      OnlyMenuItems[n].Command = 0;
      OnlyMenuItems[n].SubItem = NULL;
      OnlyMenuItems[n].NextSelect = 0;

      OnlyMenuText[n].FrontPen = 0;
      OnlyMenuText[n].BackPen = 1;
      OnlyMenuText[n].DrawMode = JAM2;
      OnlyMenuText[n].LeftEdge = 0;
      OnlyMenuText[n].TopEdge = 1;
      OnlyMenuText[n].ITextFont = NULL;
      OnlyMenuText[n].NextText = NULL;
   }
   OnlyMenuItems[2].NextItem = NULL; /* Last item */

   OnlyMenuText[0].IText = (UBYTE *)"Hide Title Bar";
   OnlyMenuText[1].IText = (UBYTE *)"Show Title Bar";
   OnlyMenuText[2].IText = (UBYTE *)"QUIT!";
}
initmenu()
{
   OnlyMenu[0].NextMenu = NULL;                 /* No more menus */
   OnlyMenu[0].LeftEdge = 0;
   OnlyMenu[0].TopEdge = 0;
   OnlyMenu[0].Width = 85;
   OnlyMenu[0].Height = 10;
   OnlyMenu[0].Flags = MENUENABLED;             /* All items selectable */
   OnlyMenu[0].MenuName = "Actions";
   OnlyMenu[0].FirstItem = &OnlyMenuItems[0];   /* Pointer to first item */
}
