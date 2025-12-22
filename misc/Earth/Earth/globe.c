//===============================================================
// Picture on Sphere Mapper.			(C) DEC 1993 L.Vanhelsuwe
// -------------------------
// History
// -------
// Sat Dec 11:	started this file
// Fri Dec 24:	improved loop to avoid writing out vertices with identical xyz
//===============================================================

//#include	<m68881.h>
#include	<math.h>
#include	<stdio.h>
#include	<strings.h>

#include	<exec/types.h>
#include	<intuition/intuition.h>

#include	<proto/exec.h>
#include	<proto/dos.h>
#include	<proto/intuition.h>
#include	<proto/graphics.h>

#define		BALLRAD			150

#define		SCREEN_WIDTH	320
#define		SCREEN_HEIGHT	256
#define		IM_WIDTH		320
#define		IM_HEIGHT		200

struct NewScreen ns = {0,0,SCREEN_WIDTH,SCREEN_HEIGHT,2,
						0,1,0,0,
						NULL,"World Map Sphere Mapper",NULL,NULL};
struct Screen *myscreen;

struct IntuitionBase *IntuitionBase;
struct GfxBase *GfxBase;

struct RastPort *rp;

void	load_picture( char * filename);

//=====================================================
main() {

LONG fh1;
char outstr[256];

float	xnorm, ynorm;
int		sx,sy, x,y,z, ox,oy,oz;

	IntuitionBase	= (void*) OpenLibrary("intuition.library",0);
	GfxBase			= (void*) OpenLibrary("graphics.library",0);
	myscreen		= (void*) OpenScreen(&ns);
	rp				= &myscreen->RastPort;

	load_picture("GLOBE.raw");

	fh1 = Open("RAM:3D.Globe", MODE_NEWFILE);

	ox = oy = oz = PI;

	// Sample entire 2-D picture for non-background pixels and convert all
	// those into mapped 3-D pixels

	for (sy=0; sy < IM_HEIGHT; sy++) {
		for (sx=0; sx < IM_WIDTH; sx++) {		//	printf("(%d,%d) = ", sx, sy);

			if (ReadPixel(rp,sx,sy)) {			// transform all non-background

				xnorm = 2*PI*((float)sx)/IM_WIDTH;			// normalize to 
				ynorm = PI/2 - (PI*((float)sy)/IM_HEIGHT);	// spherical range

//				printf("(%3.2f,%3.2f)\n", xnorm, ynorm);

				x = (int) (0.5+ BALLRAD*sin(xnorm)*cos(ynorm));
				y = (int) (0.5+ BALLRAD*sin(ynorm));
				z = (int) (0.5+ BALLRAD*cos(xnorm)*cos(ynorm));

				if (x != ox || y != oy || z != oz) {
					sprintf(outstr,"	DC.W	%d,%d,%d\n", x,y,z);
//					 printf(		"	DC.W	%d,%d,%d", x,y,z);
					Write(fh1, outstr, strlen(outstr));

					ox = x; oy = y; oz = z;
				}
			}
			WritePixel(rp,sx,sy);			// erase pixel as progress feedback
		}
	}

	Close(fh1);								// close generated file.

	Execute("C:COPY RAM:3D.Globe 3d:WORLDS", NULL, NULL);
	Execute("C:DELETE RAM:3D.globe", NULL, NULL);

	CloseScreen(myscreen);
}
//=====================================================
//=====================================================
void load_picture(char * filename) {
LONG fh1;

	fh1 = Open(filename, MODE_OLDFILE);
	Read(fh1, myscreen->BitMap.Planes[0], IM_WIDTH/8*IM_HEIGHT);
	Close(fh1);
}
