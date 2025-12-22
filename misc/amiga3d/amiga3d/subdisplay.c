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
#include <libraries/dos.h>
#include "threed.h"

#define FIXEDILLUMINATION

extern UBYTE title[] ;

extern struct Custom custom;
 
extern struct TmpRas tmpras;

extern struct BitMap bitmap0;
extern struct BitMap bitmap1;

extern struct RastPort r[2];
extern struct RastPort *rp[2];

extern struct RasInfo ri[2];
extern struct RasInfo *rip[2];

extern struct RasInfo *irip;

extern WORD pcount ;
extern WORD vcount ;

extern UWORD frametoggle ;

extern BPTR objectsegment ;

extern struct Object *Amiga ;

extern long GfxBase;
extern long DosBase;

extern int (*subroutines[])();

/******************************************************************************/

subdisplayuniverse(view,screen,window,cameraobjectinfo,objectinfo,subobjectinfo)
struct View *view;
struct Screen *screen;
struct Window *window;
struct Objectinfo *cameraobjectinfo;
struct Objectinfo *objectinfo;
struct Objectinfo *subobjectinfo;
{
    int argc = 0;
    char *argv[MAXNUMARGS];
    struct Objectinfo *thisobjectinfo; 

/* set up parameter passing information for this display */

    argv[0] = &thisobjectinfo;
    argv[1] = subroutines;

    argc = 2;

/* PROCESS ALL THE OBJECTS IN THE LIST POINTED TO BY OBJECTINFO */

    thisobjectinfo = subobjectinfo;

    while(thisobjectinfo)
    {
   int thisobjecterror = FALSE;

   /* process this object */

   if(thisobjectinfo->objectprocedure)
   {
       int (*function)();

       /* call the object's procedure */

#ifdef ODEBUG
       printf("do3d: object(%lx) procedure = %lx\n",
          thisobjectinfo,thisobjectinfo->objectprocedure);
#endif
       function = thisobjectinfo->objectprocedure;
       thisobjecterror = (*function)(argc,argv);

   }

   /* concatenate this submatrix with the next higher level display matrix */

        {
       struct UV uv;

       uv = *thisobjectinfo->objectmatrix;

       transpose(&uv);

       cat(thisobjectinfo->displaymatrix,&uv,objectinfo->displaymatrix);

       transpose(thisobjectinfo->displaymatrix);

   }

      
   /* convert this object's position to the next higher lever display frame-of-reference */

   matrix(thisobjectinfo->displayposition,thisobjectinfo->objectposition,
      objectinfo->displaymatrix);

   /* then determine this subobjects's universal reference position */
   
   addvect(thisobjectinfo->displayposition,objectinfo->displayposition,
      thisobjectinfo->displayposition);

   /* process any subobjects dependent on this object before displaying it */

   {
       struct Objectinfo *nextsubobjectinfo;

       nextsubobjectinfo = thisobjectinfo->subobjectinfo;

       while(nextsubobjectinfo)
       {
      /* subdisplay each next subobject */

      subdisplayuniverse(view,screen,window,cameraobjectinfo,thisobjectinfo,nextsubobjectinfo);

      nextsubobjectinfo = nextsubobjectinfo->nextobjectinfo;

       }

   }

   {
       
       struct Coordinate centerpoint;

       /* concatenate this object's matrix with the camera matrix for display through camera viewpoint */
 
       {
      struct UV uv1, uv2;

      subvect(cameraobjectinfo->objectposition,thisobjectinfo->displayposition,&centerpoint);

      uv1 = *thisobjectinfo->displaymatrix;

      uv2 = *cameraobjectinfo->objectmatrix;

      transpose(&uv1);

      /*transpose(&uv2);*/

      cat(thisobjectinfo->displaymatrix,&uv2,&uv1);

      /*transpose(thisobjectinfo->displaymatrix);*/
      
      matrix(&centerpoint,&centerpoint,cameraobjectinfo->objectmatrix);


       }
       
       if ( (centerpoint.z > 0)
          &&
          (( (centerpoint.z) - ( (centerpoint.x < 0) ? -centerpoint.x : centerpoint.x )) > 0)
          &&
          (( (centerpoint.z) - ( (centerpoint.y < 0) ? -centerpoint.y : centerpoint.y )) > 0) )
       {


      /* rotate the 3d normals*/

#ifdef DEBUG
      printf("do3d: rotate the 3d normals\n");
#endif

      rotate(thisobjectinfo->displaymatrix,thisobjectinfo->objectnumnormals,
         thisobjectinfo->objectnormals,thisobjectinfo->objectbufnormals);

      /* rotate, translate, and perspect the 3d points */

      dopoints(thisobjectinfo->displaymatrix,&centerpoint,
         thisobjectinfo->objectnumpoints,thisobjectinfo->objectpoints,
         thisobjectinfo->objectbufpoints);

       }
       else
       {
      
      /* this object out of 45 degree frustrum */

           thisobjectinfo = thisobjectinfo->nextobjectinfo;

           /* so process the next object */

           continue;
       }

   }

    /* draw the polygons by traversing the polygon list */

    {
   WORD polycount = 0;
   WORD *nextcolor;
   struct Coordinate **nextn;
   struct Coordinate **nextp;
   struct Coordinate *lastn = 0;
   WORD endflag = FALSE;

   /* intialize buffer pointers */

   nextcolor = thisobjectinfo->colorbuf;
   nextn = thisobjectinfo->nptrbuf;
   nextp = thisobjectinfo->pptrbuf;

   for(polycount = 0; polycount < thisobjectinfo->objectnumpolys; polycount++)
   {
       struct Polygon **np;
       WORD vc;
       struct Coordinate **v;
       struct Coordinate *n;
       struct Coordinate *c0;
       struct Coordinate *c1;
       struct Coordinate *c2;
       WORD bright;
       WORD firstx, firsty;

#ifdef DEBUG
       printf("poly %lx: \n",polycount);
#endif
       np = (thisobjectinfo->objectpolys+polycount);

#ifdef DEBUG
       printf("np = %lx\n",np);
#endif

#ifdef DEBUG
       printf("vertexcount = %lx\n",(*np)->vertexcount);
#endif

#ifdef DRAWDEBUG
       printf("poly %lx: color = %lx\n",polycount,*nextcolor);
#endif

       /* backface removal */

       /* first, simple clip */
       if (((*nextn)->z) > 0) 
       {
      nextcolor++;
      nextn++;
      nextp = (nextp+((*np)->vertexcount));
      continue;
       }
       
       /* now, test z component of dynamically computed polygon normal */
       
       c0 = (struct Coordinate *)(*(nextp));
       c1 = (struct Coordinate *)(*(nextp+1));
       c2 = (struct Coordinate *)(*(nextp+2));

       /* if polygon's normal faces away from the screen, or is perpendicular, ignore it */

#ifdef DRAWDEBUG
       printf("c0->x = %lx c0->y = %lx\n",c0->x,c0->y); 
       printf("c1->x = %lx c1->y = %lx\n",c1->x,c1->y); 
       printf("c2->x = %lx c2->y = %lx\n",c2->x,c2->y); 
#endif

       /* fine clipping */

       if (((smuls(((c1->x)-(c0->x)),((c2->y)-(c1->y))))-(smuls(((c2->x)-(c1->x)),((c1->y)-(c0->y))))) >= 0)
       {
      nextcolor++;
      nextn++;
      nextp = (nextp+((*np)->vertexcount));
      continue;
       }

       /* illumination */

#ifndef FIXEDILLUMINATION

       bright = (((-(((*nextn)->x+(*nextn)->y))>>1)+(0x4000))>>11);
#else

       bright = (WORD)*nextcolor;
#endif
       /* ceiling */

       bright = (bright > 0xF)?0xF:bright;

#ifdef DRAWDEBUG
       printf("poly %lx: bright = %lx\n",polycount,bright);
#endif

            for(vc = 0; vc < (*np)->vertexcount; vc++)
       {
      WORD x,y;
#ifdef DRAWDEBUG
      printf("vertex %lx : (thisobjectinfo->objectbufpoints+poff) = %lx\n",vc,*nextp);
#endif

#ifdef DRAWDEBUG
      printf("(thisobjectinfo->objectbufpoints+poff)->x = %lx\n",(*nextp)->x);
      printf("(thisobjectinfo->objectbufpoints+poff)->y = %lx\n",(*nextp)->y);
      printf("(thisobjectinfo->objectbufpoints+poff)->z = %lx\n",(*nextp)->z);
#endif

      /* draw stuff in */

#ifdef DRAWDEBUG
      printf("SetAPen = bright\n");
#endif
      SetAPen(rp[frametoggle ^ 0x0001],bright);

      if(vc == 0)
      {

          /* open this polygon */
#ifdef DRAWDEBUG
          printf("call areamove...\n");
#endif
          x = (((*nextp)->x)+(TMPWIDTH>>1));
          y = (((*nextp)->y)+(TMPHEIGHT>>1));

          if (x<0) x = 0;
          if (y<0) y = 0;
          if (x>TMPWIDTH-1) x = TMPWIDTH-1;
          if (y>TMPHEIGHT-1) y = TMPHEIGHT-1;

          x -= ( ( TMPWIDTH  - (window->RPort->BitMap->BytesPerRow<<3) ) >> 1 );
          y -= ( ( TMPHEIGHT - (window->RPort->BitMap->Rows) ) >> 1 );

          firstx = x;
          firsty = y;

          /* move into the raster that we're NOT subdisplaying */

#ifndef FIXEDILLUMINATION
          if( (lastn != *nextn) && (endflag) )
          {
              AreaEnd(rp[frametoggle ^ 0x0001]);
         endflag = FALSE;
          }
#endif

          AreaMove(rp[frametoggle ^ 0x0001],x,y);

      }
      else
      {

          /* continue this polygon */
#ifdef DRAWDEBUG
          printf("call areadraw...\n");
#endif
          x = (((*nextp)->x)+(TMPWIDTH>>1));
          y = (((*nextp)->y)+(TMPHEIGHT>>1));

          if (x<0) x = 0;
          if (y<0) y = 0;
          if (x>TMPWIDTH-1) x = TMPWIDTH-1;
          if (y>TMPHEIGHT-1) y = TMPHEIGHT-1;

          x -= ( ( TMPWIDTH  - (window->RPort->BitMap->BytesPerRow<<3) ) >> 1 );
          y -= ( ( TMPHEIGHT - (window->RPort->BitMap->Rows) ) >> 1 );

          /* draw into the raster that we're NOT subdisplaying */

          AreaDraw(rp[frametoggle ^ 0x0001],x,y);

      }

      /* increment the nextp pointer */

      nextp++;

        }

       /* close this polygon */

#ifdef DRAWDEBUG
       printf("call areaend...\n");
#endif
       /* end raster that we're NOT subdisplaying (or continue collecting polygons) */

       /* last polygon subdisplayed is this one */

       lastn = *nextn;

#ifndef FIXEDILLUMINATION
       if(lastn  == *(nextn+1))
       {
      /* last polygon subdisplayed has same normal as next polygon to be subdisplayed */

#ifdef DRAWDEBUG
      printf("last poly subdisplayed has same normal as next polygon to be subdisplayed...draw\n");
#endif
      /* draw, but do not terminate this polygon in this sequence */

      /* note : need graphics 28.5 or greater to do following trick ! */

      AreaDraw(rp[frametoggle ^ 0x0001],firstx,firsty);
      endflag = TRUE;

      /* if graphics 28.4 or less  do this standard thing */

      /* AreaEnd(rp[frametoggle ^ 0x0001]); */
      /* endflag = FALSE; */
       }
       else
       {
      /* last polygon subdisplayed has different normal from next polygon to be subdisplayed */

#ifdef DRAWDEBUG
      printf("last poly subdisplayed has deffernt normal from next polygon to be subdisplayed...end\n");
#endif
      /* terminate this polygon sequence */

      AreaEnd(rp[frametoggle ^ 0x0001]);
      endflag = FALSE;

       }
#else
       {
      /* terminate this polygon sequence */

      AreaEnd(rp[frametoggle ^ 0x0001]);
      endflag = FALSE;

       }
#endif

       /* increment nextcolor, nextn pointers */

       nextcolor++;
       nextn++;
       
   }

   if(endflag)
   {
       /* terminate series of "same normal" polygons after polyloop exit */

#ifdef DRAWDEBUG
       printf("close last polygon in series...\n");
#endif
       AreaEnd(rp[frametoggle ^ 0x0001]);
   }
   
    }

    thisobjectinfo = thisobjectinfo->nextobjectinfo;

    } /* end while (thisobject) */

}


