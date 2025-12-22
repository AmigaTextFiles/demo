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

extern struct Objectinfo *objectinfo ;
extern struct Objectinfo *firstobjectinfo ;
extern struct Objectinfo *cameraobjectinfo ;

extern BPTR objectsegment ;

extern struct Object *Amiga ;

extern struct UV *cameramatrix ;
extern struct Coordinate *cameraposition ;

extern long GfxBase;
extern long DosBase;

int nullproc();
int addvect();
int subvect();
int roll();
int pitch();
int yaw();
int transpose();

int (*subroutines[])() = 
{
    nullproc,
    addvect,
    subvect,
    roll,
    pitch,
    yaw,
    transpose,
};


/*****************************************************************************/

nullproc()
{
    return(FALSE);
}

WORD mul3d(a,b)
WORD a,b;
{
LONG c;

    c = a * b;
    c += 0x2000;
    c >>= 14;

    return((WORD)c);
}

roll(bm,sine,cosine)
struct UV *bm;
WORD sine;
WORD cosine;
{
    struct UV tmp;

    tmp.uv11 = (WORD)(mul3d(bm->uv11,cosine)+mul3d(bm->uv21,sine));
    tmp.uv21 = (WORD)(mul3d(-bm->uv11,sine)+mul3d(bm->uv21,cosine));
    tmp.uv12 = (WORD)(mul3d(bm->uv12,cosine)+mul3d(bm->uv22,sine));
    tmp.uv22 = (WORD)(mul3d(-bm->uv12,sine)+mul3d(bm->uv22,cosine));
    tmp.uv13 = (WORD)(mul3d(bm->uv13,cosine)+mul3d(bm->uv23,sine));
    tmp.uv23 = (WORD)(mul3d(-bm->uv13,sine)+mul3d(bm->uv23,cosine));

    bm->uv11 = tmp.uv11;
    bm->uv21 = tmp.uv21;
    bm->uv12 = tmp.uv12;
    bm->uv22 = tmp.uv22;
    bm->uv13 = tmp.uv13;
    bm->uv23 = tmp.uv23;

}

yaw(bm,sine,cosine)
struct UV *bm;
WORD sine;
WORD cosine;
{
    struct UV tmp;

    tmp.uv11 = (WORD)(mul3d(bm->uv11,cosine)+mul3d(bm->uv31,sine));
    tmp.uv31 = (WORD)(mul3d(-bm->uv11,sine)+mul3d(bm->uv31,cosine));
    tmp.uv12 = (WORD)(mul3d(bm->uv12,cosine)+mul3d(bm->uv32,sine));
    tmp.uv32 = (WORD)(mul3d(-bm->uv12,sine)+mul3d(bm->uv32,cosine));
    tmp.uv13 = (WORD)(mul3d(bm->uv13,cosine)+mul3d(bm->uv33,sine));
    tmp.uv33 = (WORD)(mul3d(-bm->uv13,sine)+mul3d(bm->uv33,cosine));

    bm->uv11 = tmp.uv11;
    bm->uv31 = tmp.uv31;
    bm->uv12 = tmp.uv12;
    bm->uv32 = tmp.uv32;
    bm->uv13 = tmp.uv13;
    bm->uv33 = tmp.uv33;

}

pitch(bm,sine,cosine)
struct UV *bm;
WORD sine;
WORD cosine;
{
    struct UV tmp;

    tmp.uv21 = (WORD)(mul3d(bm->uv21,cosine)-mul3d(bm->uv31,sine));
    tmp.uv31 = (WORD)(mul3d(bm->uv21,sine)+mul3d(bm->uv31,cosine));
    tmp.uv22 = (WORD)(mul3d(bm->uv22,cosine)-mul3d(bm->uv32,sine));
    tmp.uv32 = (WORD)(mul3d(bm->uv22,sine)+mul3d(bm->uv32,cosine));
    tmp.uv23 = (WORD)(mul3d(bm->uv23,cosine)-mul3d(bm->uv33,sine));
    tmp.uv33 = (WORD)(mul3d(bm->uv23,sine)+mul3d(bm->uv33,cosine));

    bm->uv21 = tmp.uv21;
    bm->uv31 = tmp.uv31;
    bm->uv22 = tmp.uv22;
    bm->uv32 = tmp.uv32;
    bm->uv23 = tmp.uv23;
    bm->uv33 = tmp.uv33;

}

transform(dest)
struct Coordinate *dest;
{
    LONG zinv = 0x00400000;

    dest->z = (dest->z<64) ? 64 : dest->z ;

    /* dest->x = (WORD)( ((long)dest->x << 8) / dest->z ); */ 
    /* dest->y = (WORD)( ((long)dest->y << 8) / dest->z ); */

    /* new algorithm - figure inverse of z and multiply */

    zinv /= dest->z;

     dest->x = mul3d(dest->x,(WORD)zinv); 
     dest->y = mul3d(dest->y,(WORD)zinv); 


#ifdef DEBUG
    printf("transform: dest->x = %lx\n",dest->x);
    printf("transform: dest->y = %lx\n",dest->y);
    printf("transform: dest->z = %lx\n",dest->z);
#endif

}

perspect(objectnumpoints,objectbufpoints)
WORD objectnumpoints;
struct Coordinate objectbufpoints[];
{
    WORD pointcount = 0;
    struct Coordinate *nextpoint;

    for(pointcount = 0; pointcount < objectnumpoints; pointcount++)
    {
#ifdef DEBUG
   printf("perspect: pointcount = %lx\n",pointcount);
#endif
   transform(&objectbufpoints[pointcount]);
    }
}

subvect(bp,src,dest)
struct Coordinate *bp;
struct Coordinate *src;
struct Coordinate *dest;
{

#ifdef DEBUG
    printf("subvect: src->x = %lx\n",src->x);
    printf("subvect: src->y = %lx\n",src->y);
    printf("subvect: src->z = %lx\n",src->z);
#endif

    dest->x = (WORD)(src->x - bp->x);
    dest->y = (WORD)(src->y - bp->y);
    dest->z = (WORD)(src->z - bp->z);

#ifdef DEBUG
    printf("subvect: dest->x = %lx\n",dest->x);
    printf("subvect: dest->y = %lx\n",dest->y);
    printf("subvect: dest->z = %lx\n",dest->z);
#endif

}

addvect(bp,src,dest)
struct Coordinate *bp;
struct Coordinate *src;
struct Coordinate *dest;
{

#ifdef DEBUG
    printf("addvect: src->x = %lx\n",src->x);
    printf("addvect: src->y = %lx\n",src->y);
    printf("addvect: src->z = %lx\n",src->z);
    printf("addvect: bp->x = %lx\n",bp->x);
    printf("addvect: bp->y = %lx\n",bp->y);
    printf("addvect: bp->z = %lx\n",bp->z);
#endif

    dest->x = (WORD)(src->x + bp->x);
    dest->y = (WORD)(src->y + bp->y);
    dest->z = (WORD)(src->z + bp->z);

#ifdef DEBUG
    printf("addvect: dest->x = %lx\n",dest->x);
    printf("addvect: dest->y = %lx\n",dest->y);
    printf("addvect: dest->z = %lx\n",dest->z);
#endif

}

translate(bp,objectnumpoints,objectbufpoints)
struct Coordinate *bp;
WORD objectnumpoints;
struct Coordinate objectbufpoints[];
{
    WORD pointcount = 0;

    for(pointcount = 0; pointcount < objectnumpoints; pointcount++)
    {
#ifdef DEBUG
   printf("translate: pointcount = %lx\n",pointcount);
#endif
   addvect(bp,&objectbufpoints[pointcount],&objectbufpoints[pointcount]);
    }
}

transpose(bm)
struct UV *bm;
{
    WORD tmp;

    tmp = bm->uv12; bm->uv12 = bm->uv21; bm->uv21 = tmp;
    tmp = bm->uv13; bm->uv13 = bm->uv31; bm->uv31 = tmp;
    tmp = bm->uv23; bm->uv23 = bm->uv32; bm->uv32 = tmp;
}

cat(dest,src1,src2)
struct UV *dest;
struct UV *src1;
struct UV *src2;
{
   matrix(&dest->uv11,&src1->uv11,src2);
   matrix(&dest->uv21,&src1->uv21,src2);
   matrix(&dest->uv31,&src1->uv31,src2);
}

matrix(dest,src,bm)
struct Coordinate *dest;
struct Coordinate *src;
struct UV *bm;
{

#ifdef DEBUG
    printf("matrix: src->x = %lx\n",src->x);
    printf("matrix: src->y = %lx\n",src->y);
    printf("matrix: src->z = %lx\n",src->z);
#endif

    dest->x = (WORD)(mul3d(src->x,bm->uv11)+mul3d(src->y,bm->uv12)+mul3d(src->z,bm->uv13));
    dest->y = (WORD)(mul3d(src->x,bm->uv21)+mul3d(src->y,bm->uv22)+mul3d(src->z,bm->uv23));
    dest->z = (WORD)(mul3d(src->x,bm->uv31)+mul3d(src->y,bm->uv32)+mul3d(src->z,bm->uv33));

#ifdef DEBUG
    printf("matrix: dest->x = %lx\n",dest->x);
    printf("matrix: dest->y = %lx\n",dest->y);
    printf("matrix: dest->z = %lx\n",dest->z);
#endif

}

rotate(bm,objectnumpoints,pointstart,objectbufpoints)
struct UV *bm;
WORD objectnumpoints;
struct Coordinate *pointstart[];
struct Coordinate objectbufpoints[];
{
    WORD pointcount = 0;

    for(pointcount = 0; pointcount < objectnumpoints; pointcount++)
    {
#ifdef DEBUG
   printf("rotate: pointcount = %lx\n",pointcount);
#endif
   matrix(&objectbufpoints[pointcount],pointstart[pointcount],bm);
    }
}

copynormals(objectnumpoints,pointstart,objectbufpoints)
WORD objectnumpoints;
struct Coordinate *pointstart[];
struct Coordinate objectbufpoints[];
{
    WORD pointcount = 0;

    for(pointcount = 0; pointcount < objectnumpoints; pointcount++)
    {
#ifdef DEBUG
   printf("copynormals: pointcount = %lx\n",pointcount);
#endif
   objectbufpoints[pointcount] = *(pointstart[pointcount]);
    }

}

camera(bm,bp,objectnumpoints,srcbufpoints,destbufpoints)
struct UV *bm;
struct Coordinate *bp;
WORD objectnumpoints;
struct Coordinate srcbufpoints[];
struct Coordinate destbufpoints[];
{
    WORD pointcount = 0;

    for(pointcount = 0; pointcount < objectnumpoints; pointcount++)
    {
#ifdef DEBUG
   printf("camera: pointcount = %lx\n",pointcount);
#endif
   subvect(bp,&destbufpoints[pointcount],&srcbufpoints[pointcount]);
   matrix(&destbufpoints[pointcount],&srcbufpoints[pointcount],bm);
   transform(&destbufpoints[pointcount]);
    }
}

notransformdopoints(bm,bp,objectnumpoints,pointstart,objectbufpoints)
struct UV *bm;
struct Coordinate *bp;
WORD objectnumpoints;
struct Coordinate *pointstart[];
struct Coordinate objectbufpoints[];
{
    WORD pointcount = 0;

    for(pointcount = 0; pointcount < objectnumpoints; pointcount++)
    {
#ifdef DEBUG
   printf("notransformdopoints: pointcount = %lx\n",pointcount);
#endif
   matrix(&objectbufpoints[pointcount],pointstart[pointcount],bm);
   addvect(bp,&objectbufpoints[pointcount],&objectbufpoints[pointcount]);
    }
}

dopoints(bm,bp,objectnumpoints,pointstart,objectbufpoints)
struct UV *bm;
struct Coordinate *bp;
WORD objectnumpoints;
struct Coordinate *pointstart[];
struct Coordinate objectbufpoints[];
{
    WORD pointcount = 0;

    for(pointcount = 0; pointcount < objectnumpoints; pointcount++)
    {
#ifdef DEBUG
   printf("dopoints: pointcount = %lx\n",pointcount);
#endif
   matrix(&objectbufpoints[pointcount],pointstart[pointcount],bm);
   addvect(bp,&objectbufpoints[pointcount],&objectbufpoints[pointcount]);
   transform(&objectbufpoints[pointcount]);
    }
}

