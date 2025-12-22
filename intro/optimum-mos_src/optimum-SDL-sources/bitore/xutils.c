/*
 *  Copyright (C) 1999 Optimum
 *
 *  This program is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU General Public License
 *  as published by the Free Software Foundation; either version 2
 *  of the License, or (at your option) any later version.
 *  
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *  
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 */

#include "xutils.h"

#ifdef X11
#include <X11/extensions/xf86dga.h>
int dga_flags;
char *dga_addr;
int dga_linewidth;  /* Pixel */
int dga_banksize;   /* Byte  */
int dga_memsize;    /* KByte */
int dga_width;      /* Pixel */
int dga_height;     /* Pixel */
#else
SDL_Surface *screen;
#endif

unsigned char *buffer;
int depth;
int width, height;

int init_x (int X, int Y,
	    int W, int H, int bpp,
	    const char *Name) {

  int factor;

#ifdef X11

  dis = XOpenDisplay  (NULL);
  if (dis == NULL)
    {
      fprintf (stderr, "Error :\n");
      fprintf (stderr, "  Can't open display\n");
      exit (1);
    }

  screen = DefaultScreen (dis);
  depth  = DefaultDepth  (dis, screen);
  width  = DisplayWidth  (dis, screen);
  height = DisplayHeight (dis, screen);
  factor = (depth+7)/8;
  
  winRoot                   = DefaultRootWindow (dis);
  winAttr.border_pixel      = BlackPixel (dis, screen);
  winAttr.background_pixel  = BlackPixel (dis, screen);
  winAttr.override_redirect = True;
  winMask                   = CWBackPixel | CWBorderPixel | CWOverrideRedirect;
  
  win = XCreateWindow (dis, winRoot, 0, 0,  width, height, 0, depth,
		       InputOutput, CopyFromParent, winMask, &winAttr);

  XSelectInput (dis, win, KeyPressMask);

  winHint.flags                           = PPosition | PMinSize | PMaxSize ;
  winHint.x                               = 0;
  winHint.y                               = 0;
  winHint.max_width  = winHint.min_width  = W;
  winHint.max_height = winHint.min_height = H;
  XSetWMNormalHints (dis, win, &winHint);

  XMapRaised (dis, win);
  XFlush (dis);

  XGrabKeyboard (dis, win, True, GrabModeAsync, 
		 GrabModeAsync, CurrentTime); 

  /* DGA */

  XF86DGAQueryDirectVideo (dis, screen, &dga_flags);
  if (!(dga_flags&XF86DGADirectPresent)) {
    printf ("DGA not available\n");
    exit (1);
  }
  
  XF86DGAGetVideo (dis, screen,
		   &dga_addr, &dga_linewidth, &dga_banksize, &dga_memsize);
  XF86DGAGetViewPortSize (dis, screen, &dga_width, &dga_height);
  XF86DGADirectVideo (dis, screen,
		      XF86DGADirectGraphics|XF86DGADirectKeyb);
  
  memset (dga_addr, 0, dga_width*dga_height*factor);
  
  buffer = (unsigned char *) calloc (W*H, factor);

#else

  int i;

  if ( SDL_Init(SDL_INIT_VIDEO) < 0 )
    {
      fprintf ( stderr , "Erreur :\n" );
      fprintf ( stderr , "  Impossible de se connecter au Display\n");
      exit (1);
    }

  screen = SDL_SetVideoMode(W, H, bpp, SDL_HWSURFACE|SDL_FULLSCREEN);
  if ( screen == NULL )
    {
      fprintf ( stderr , "Erreur :\n" );
      fprintf ( stderr , "  Impossible de se connecter au Display\n");
      exit (1);
    }

  SDL_WM_SetCaption ( Name, Name );

  factor = screen->format->BytesPerPixel;
  depth = screen->format->BitsPerPixel;
  width = screen->w;
  height = screen->h;
  buffer = (unsigned char *) calloc (W*H, factor);

  for ( i=SDL_NOEVENT; i<SDL_NUMEVENTS; ++i )
    if ( (i != SDL_KEYDOWN) && (i != SDL_QUIT) )
      SDL_EventState(i, SDL_IGNORE);

#endif

  return depth;
}


int event_x () {

#ifdef X11
  XEvent XEv;

  return ( ! XCheckWindowEvent ( dis , win , KeyPressMask , &XEv ) ); 
#else
  return ( ! SDL_PollEvent(NULL) );
#endif

}


void close_x () {

#ifdef X11
  XDestroyWindow (dis, win);
  XCloseDisplay  (dis);     
#else
  SDL_Quit();
#endif

};
