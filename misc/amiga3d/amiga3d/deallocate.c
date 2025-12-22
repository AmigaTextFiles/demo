#include <exec/types.h>
#include <exec/nodes.h>
#include <exec/lists.h>
#include <exec/memory.h>
#include <hardware/blit.h>
#include <hardware/custom.h>
#include <graphics/gfx.h>
#include <graphics/clip.h>
#include <graphics/rastport.h>
#include <graphics/view.h>
#include <graphics/text.h>
#include <graphics/gfxmacros.h>

#include <graphics/layers.h>
#include <intuition/intuition.h>
#include "threed.h"

/* #define DEBUG */
/* #define ODEBUG */
/* #define DEBUGDRAW */
/* #define TICKDEBUG */
/* #define TICKPRINT */
#define FIXEDILLUMINATION
#define CYCLECOLORS

#ifndef FIXEDILLUMINATION

extern UWORD colorpalette[];

#else

extern UWORD colorpalette[];

#endif

extern UBYTE title[];

extern struct Custom custom;
 
extern struct TmpRas tmpras;

extern struct BitMap bitmap0;
extern struct BitMap bitmap1;

extern struct RastPort r[];
extern struct RastPort *rp[];

extern struct RasInfo ri[];
extern struct RasInfo *rip[];

extern struct RasInfo *irip;

extern WORD pcount;
extern WORD vcount;

extern UWORD frametoggle;

extern long GfxBase;

/******************************************************************************/

objectdeallocate(view,screen,window,objectinfo)
struct View *view;
struct Screen *screen;
struct Window *window;
struct Objectinfo *objectinfo;
{


   if (objectinfo->displaymatrix)
     FreeMem(objectinfo->displaymatrix,sizeof(struct UV));

   if (objectinfo->displayposition)
     FreeMem(objectinfo->displayposition,sizeof(struct Coordinate));

   if ((objectinfo->objectbufpoints) && (objectinfo->objectbufpointsize))
     FreeMem(objectinfo->objectbufpoints,objectinfo->objectbufpointsize);

   if ((objectinfo->objectbufnormals) && (objectinfo->objectbufnormalsize))
     FreeMem(objectinfo->objectbufnormals,objectinfo->objectbufnormalsize);

   /* deallocate buffers for pptr, ntpr, color lists */

   if ((objectinfo->pptrbuf) && (objectinfo->pptrbufsize))
     FreeMem(objectinfo->pptrbuf,objectinfo->pptrbufsize);

   if ((objectinfo->nptrbuf) && (objectinfo->nptrbufsize))
     FreeMem(objectinfo->nptrbuf,objectinfo->nptrbufsize);

   if ((objectinfo->colorbuf) && (objectinfo->colorbufsize))
     FreeMem(objectinfo->colorbuf,objectinfo->colorbufsize);

   /* deallocate all subobjects dependent on this object */

   while( objectinfo->subobjectinfo )
   {
       struct Objectinfo *soip;

       /* delink the first subobjectinfo from the objectinfo list */

       soip = objectinfo->subobjectinfo;

       objectinfo->subobjectinfo = objectinfo->subobjectinfo->nextobjectinfo;

       /* deallocate the buffers dependent on the current subobjectinfo */

#ifdef ODEBUG
       printf("    deallocate subobjectinfo(%lx)\n",soip);
#endif

       objectdeallocate(view,screen,window,soip);

       /* deallocate this subobjectinfo structure itself */

       FreeMem(soip,sizeof(struct Objectinfo));
   }

}
