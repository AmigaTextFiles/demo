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

extern BOOL initobject;

extern WORD pcount;
extern WORD vcount;

extern UWORD frametoggle;

extern long GfxBase;

/******************************************************************************/

positioninit(c)
struct Coordinate *c;
{
    c->x = 0;
    c->y = 0;
    c->z = 0;
}

matrixinit(um)
struct UV *um;
{
    um->uv11 = 0x4000;
    um->uv12 = 0;
    um->uv13 = 0;
    um->uv21 = 0;
    um->uv22 = 0x4000;
    um->uv23 = 0;
    um->uv31 = 0;
    um->uv32 = 0;
    um->uv33 = 0x4000;
}

objectinit(view,screen,window,objectinfo,object)
struct View *view;
struct Screen *screen;
struct Window *window;
struct Objectinfo *objectinfo;
struct Object *object;
{
   WORD *nextcolor;
   struct Coordinate **nextn;
   struct Coordinate **nextp;
   int error = FALSE;

   /* initialize */

   objectinfo->subobjectinfo = NULL;
   objectinfo->objectmatrix = object->umatrix;
   objectinfo->objectposition = object->position;
   objectinfo->objectnumpoints = object->pointcount;
   objectinfo->objectpoints = object->pointstart;
   objectinfo->objectnumnormals = object->normalcount;
   objectinfo->objectnormals = object->normalstart;
   objectinfo->objectnumpolys = object->polycount;
   objectinfo->objectpolys = object->polystart;
   objectinfo->objectprocedure = object->procedure;

    if ((objectinfo->displaymatrix= (struct UV *)AllocMem(sizeof(struct UV), MEMF_PUBLIC|MEMF_CLEAR)) == NULL)
   {
#ifdef DEBUG
       printf("initobject: can't allocate objectinfo->displaymatrix...\n");
#endif
       return(FALSE);
   }

    if ((objectinfo->displayposition= (struct UV *)AllocMem(sizeof(struct Coordinate), MEMF_PUBLIC|MEMF_CLEAR)) == NULL)
   {
#ifdef DEBUG
       printf("initobject: can't allocate objectinfo->displayposition...\n");
#endif
       return(FALSE);
   }

   if (objectinfo->objectnumpoints)

   if ((objectinfo->objectbufpoints = (struct Coordinate *)AllocMem(objectinfo->objectnumpoints * sizeof(struct Coordinate), MEMF_PUBLIC|MEMF_CLEAR)) == NULL)
   {
#ifdef DEBUG
       printf("initobject: can't allocate objectinfo->objectbufpoints...\n");
#endif
       objectinfo->objectbufpointsize = 0;
       return(FALSE);
   }
   else
   {
       objectinfo->objectbufpointsize = objectinfo->objectnumpoints * sizeof(struct Coordinate);
   }

   if (objectinfo->objectnumnormals)

   if ((objectinfo->objectbufnormals = (struct Coordinate *)AllocMem(objectinfo->objectnumnormals * sizeof(struct Coordinate), MEMF_PUBLIC|MEMF_CLEAR)) == NULL)
   {
#ifdef DEBUG
       printf("initobject: can't allocate objectinfo->objectbufnormals ...\n");
#endif
       objectinfo->objectbufnormalsize = 0;
       return(FALSE);
   }
   else
   {
       objectinfo->objectbufnormalsize = objectinfo->objectnumnormals * sizeof(struct Coordinate);
   }

   /* traverse the polygon list and initialize buffers for color, poff lists */

   for(pcount = 0; pcount < objectinfo->objectnumpolys; pcount++)
   {
       struct Polygon **np;

       np = (objectinfo->objectpolys+pcount);

       vcount += (*np)->vertexcount;
   }

   if( (objectinfo->pptrbuf = (APTR)AllocMem((sizeof(APTR)*(vcount+1)),MEMF_PUBLIC|MEMF_CLEAR)) == NULL)
   {
#ifdef DEBUGDRAW
       printf("draw: can't allocate objectinfo->pptrbuf...\n");
#endif
         objectinfo->pptrbufsize = 0;
       return(FALSE);
   }
   else
   {
         objectinfo->pptrbufsize = sizeof(APTR)*(vcount+1);
   }

   if( (objectinfo->nptrbuf = (APTR)AllocMem((sizeof(APTR)*(objectinfo->objectnumpolys+1)),MEMF_PUBLIC|MEMF_CLEAR)) == NULL)
   {
#ifdef DEBUGDRAW
       printf("draw: can't allocate objectinfo->nptrbuf...\n");
#endif
         objectinfo->nptrbufsize = 0;
       return(FALSE);
   }
   else
   {
         objectinfo->nptrbufsize = sizeof(APTR)*(objectinfo->objectnumpolys+1);
   }

   if( (objectinfo->colorbuf = (APTR)AllocMem((sizeof(WORD)*(objectinfo->objectnumpolys+1)),MEMF_PUBLIC|MEMF_CLEAR)) == NULL)
   {
#ifdef DEBUGDRAW
       printf("draw: can't allocate objectinfo->colorbuf...\n");
#endif
         objectinfo->colorbufsize = 0;
       return(FALSE);
   }
   else
   {
         objectinfo->colorbufsize = sizeof(WORD)*(objectinfo->objectnumpolys+1);
   }


   /* intialize buffer pointers */

   nextcolor = objectinfo->colorbuf;
   nextn = objectinfo->nptrbuf;
   nextp = objectinfo->pptrbuf;

   for(pcount = 0; pcount < objectinfo->objectnumpolys; pcount++)
   {
       struct Polygon **np;
       WORD vc;
       struct Coordinate **v;
       struct Coordinate *n;
       long noff;
       WORD color;

#ifdef DEBUG
       printf("poly %lx: \n",pcount);
#endif
       np = (objectinfo->objectpolys+pcount);

#ifdef DEBUG
       printf("np = %lx\n",np);
#endif
       v = (*np)->vertexstart;
       n = (*np)->normalvector;
       noff = n - (*(objectinfo->objectnormals));
       color = (*np)->polycolor;

#ifdef DEBUG
       printf("v = %lx\n", v);
       printf("vertexcount = %lx\n",(*np)->vertexcount);
       printf("n = %lx\n", n);
#endif

       *nextcolor++ = color;
       *nextn++ = (struct Coordinate *)(objectinfo->objectbufnormals+noff);

#ifdef DEBUGDRAW
       printf("poly %lx: color = %lx\n",pcount,color);
#endif

#ifdef DEBUGDRAW
       printf("(objectinfo->objectbufnormals+noff)->x = %lx\n",(objectinfo->objectbufnormals+color)->x);
       printf("(objectinfo->objectbufnormals+noff)->y = %lx\n",(objectinfo->objectbufnormals+color)->y);
       printf("(objectinfo->objectbufnormals+noff)->z = %lx\n",(objectinfo->objectbufnormals+color)->z);
#endif

            for(vc = 0; vc < (*np)->vertexcount; vc++)
       {
      long poff;
#ifdef DEBUG
      printf("v = %lx\n", v);
      printf("vc = %lx\n",vc);
      printf("v+vc = %lx\n",v+vc);
      printf("(*(v+vc)) = %lx\n",(*(v+vc)));
#endif
      poff = (*(v+vc)) - (*(objectinfo->objectpoints));
      /* poff = (long)(*(v+vc)); */
      *nextp++ = (struct Coordinate *)(objectinfo->objectbufpoints+poff);

#ifdef DEBUGDRAW
      printf("vertex %lx : poff = %lx\n",vc,poff);
#endif

#ifdef DEBUGDRAW
      printf("(objectinfo->objectbufpoints+poff)->x = %lx\n",(objectinfo->objectbufpoints+poff)->x);
      printf("(objectinfo->objectbufpoints+poff)->y = %lx\n",(objectinfo->objectbufpoints+poff)->y);
      printf("(objectinfo->objectbufpoints+poff)->z = %lx\n",(objectinfo->objectbufpoints+poff)->z);
#endif
       }

   }

   /* terminate pointer buffer arrays with a null pointer */

   *nextcolor = 0;   
   *nextn = 0;   
   *nextp = 0;   

   /* allocate subobjectinfo structures dependent on this object */

   {
       struct Object *ob;

       /* for all the objects in this objectsegment */

       for (ob = object->subobject ; ob; ob = ob->nextobject)
       {
      struct Objectinfo *thisubobjectinfo;

#ifdef ODEBUG
      printf("objectinit: allocate objectinfo for subobject(%lx) ",ob);
#endif

      /* allocate an objectinfo structure for the current object */

      if ((thisubobjectinfo = (struct Objectinfo *)AllocMem(sizeof(struct Objectinfo),MEMF_PUBLIC|MEMF_CLEAR)) == NULL) 
      {
          return(error); 
      }

#ifdef ODEBUG
      printf("= %lx\n",thisubobjectinfo);
#endif
      /* initialize the buffers for the current 3d subobject */

      if(!objectinit(view,screen,window,thisubobjectinfo,ob))
      {
         return(error);
      }

      /* make this objectinfo last on the subobjectinfo list */
      {
          struct Objectinfo **soipp;

          soipp =  &objectinfo->subobjectinfo;
          while (*soipp)
          {
         soipp = &((*soipp)->nextobjectinfo);
          }
          *soipp = thisubobjectinfo;
           thisubobjectinfo->nextobjectinfo = NULL;
      }

       }

   }

#ifdef ODEBUG
    printf("objectinit: &objectinfo->subobjectinfo = %lx\n",&objectinfo->subobjectinfo );
    {
   struct Objectinfo *soip;

   printf("    SUBOBJECTINFO LIST     \n");
   printf("_________________________\n");

   for (soip = objectinfo->subobjectinfo; soip; soip = soip->nextobjectinfo)
          printf("    subobjectinfo(%lx)\n",soip);

   printf("_________________________\n");
    }
#endif

        return(TRUE);
}
