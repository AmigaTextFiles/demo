/*
 * $Id: globals.h,v 1.8 2003/08/02 08:20:27 bryan Exp bryan $
 *
 * $Log: globals.h,v $
 * Revision 1.8  2003/08/02 08:20:27  bryan
 * *** empty log message ***
 *
 * Revision 1.7  2003/08/01 02:59:48  bryan
 * more functions to support object list
 *
 * Revision 1.6  2003/07/28 04:30:43  bryan
 * func defs, BALLp ball as global, constants gforce & struct ball
 * elast, velocity, & upforce (<-still unused...)
 *
 * Revision 1.5  2003/07/25 22:01:23  bryan
 * added SDL_Rect struct var for specifying coodinates of SDL_BlitSurface
 *
 * Revision 1.4  2003/07/25 05:10:15  bryan
 * type fix line 35 'glx' --> 'gfx'
 *
 * Revision 1.3  2003/07/25 05:02:34  bryan
 * Ball object definition
 *
 * Revision 1.2  2003/07/25 04:08:02  bryan
 * boolean definitions, SDL surface & event global
 *
 * Revision 1.1  2003/07/25 03:52:13  bryan
 * Initial revision
 *
 */

#include <SDL/SDL.h>

#ifndef TRUE
#define TRUE 1
#endif
#ifndef FALSE
#define FALSE 0
#endif

typedef struct ball BALL;
typedef BALL *BALLp;

typedef void ACTION (BALLp);
typedef ACTION *ACTIONp;

SDL_Surface *screen, *bg, *ballbmp;
SDL_Event event;
SDL_Rect src, dest;
SDL_Color color[255];

int gforce = 32;
unsigned char usebg = FALSE;
unsigned char useps = FALSE;
unsigned char c = 32;

struct ball {
  BALLp prev;
  BALLp next;
  SDL_Surface *gfx;
  int x, y;
  unsigned int velocity, mass, accel, elast;
  int upforce;
  int fadecount;
  ACTIONp action;
};

//functions
void ballaction (BALLp);
void bounce (BALLp);
int  count (BALLp);
void fall (BALLp);
void fadeout (BALLp);
void initbounce (BALLp);
void initfall (BALLp);
void killball (BALLp);
void newball (BALLp);
void paletteswitch (BALLp);
void render (BALLp);
void renderballs (BALLp);
