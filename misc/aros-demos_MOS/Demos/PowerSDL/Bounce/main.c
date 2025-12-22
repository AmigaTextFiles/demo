/*
 * $Id: main.c,v 1.9 2003/08/02 08:20:45 bryan Exp bryan $
 *
 * $Log: main.c,v $
 * Revision 1.9  2003/08/02 08:20:45  bryan
 * removal of dead objects from list, fadeout, kill
 *
 * Revision 1.8  2003/08/01 02:58:54  bryan
 * multiple balls, better physics
 *
 * Revision 1.7  2003/07/28 19:56:43  bryan
 * added code to drop ball from mouse pointer location
 *
 * Revision 1.6  2003/07/28 04:29:43  bryan
 * added funcs for falling and bouncing. still choppy at peak of bell curve.
 *
 * Revision 1.5  2003/07/25 21:58:53  bryan
 * added & removed temp page flip routines.
 * didn't work out. still can't define truly separate video areas and
 * flip between them.
 *
 * Revision 1.4  2003/07/25 05:09:26  bryan
 * initialize 'ball' object
 *
 * Revision 1.3  2003/07/25 04:30:28  bryan
 * Fullscreen option
 *
 * Revision 1.2  2003/07/25 04:07:18  bryan
 * Init routines
 *
 * Revision 1.1  2003/07/25 02:16:53  bryan
 * Initial revision
 *
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <SDL/SDL.h>
#include "globals.h"

void ballaction (BALLp ball) {
  if (ball->next != NULL)
    ballaction (ball->next);
  if (ball->action != NULL) {
    ball->action (ball);
    //    fprintf (stderr, "assign action\n");
  }
  else
    return;
  return;
}
void bounce (BALLp ball) {
  ball->accel = ball->velocity * .033;
  ball->y -= ball->accel;
  if (ball->velocity < gforce) {
    ball->action = fall;
  }
  else
    ball->velocity -= ball->accel;
  return;
}
int count (BALLp ball) {
  int num = 1;
  if (ball->next != NULL)
    num += count (ball->next);
  return num;
}
void initbounce (BALLp ball) {
  ball->velocity /= 1.2;
  ball->action = bounce;
  return;
}
void initfall (BALLp ball) {
  //  fprintf (stderr, "initfall\n");
  ball->velocity = gforce - ball->upforce;
  ball->action = fall;
  //  fprintf (stderr, "end initfall.\n");
  return;
}
void fadeout (BALLp ball) {
  if (ball->fadecount < 300) {
    if (ball->fadecount % 2 == 0)
      ball->gfx = NULL;
    else
      ball->gfx = ballbmp;
    ++ball->fadecount;
  }
  else
    ball->action = killball;
}
void fall (BALLp ball) {
  //  fprintf (stderr, "fall\n");
  ball->accel = ball->velocity * .033;
  ball->y += ball->accel;
  if ((ball->y + ball->gfx->h) >= screen->h) {
    ball->y = screen->h - ball->gfx->h;
    if (ball->accel > 0) {
      ball->action = initbounce;
    }
    else {
      //      ball->action = killball;
      ball->action = fadeout;
    }
  }
  else
    ball->velocity += ball->accel;
  return;
}
void killball (BALLp ball) {
  if (ball->next != NULL) {
    ball->prev->next = ball->next;
    ball->next->prev = ball->prev;
  }
  else
    ball->prev->next = NULL;
  free (ball);
  return;
}
void newball (BALLp ball) {
  int count = 1;
  while (ball->next != NULL) {
    ++count;
    ball = ball->next;
  }
  ball->next = malloc (sizeof(BALL));
  ball->next->prev = ball;
  ball->next->next = NULL;
  ball->next->action = initfall;
  ball->next->accel = 0;
  ball->next->fadecount = 0;
  ball->next->velocity = 0;
  ball->next->upforce = 0;
  SDL_GetMouseState (&ball->next->x, &ball->next->y);
  //  fprintf (stderr, "x: %3d  y: %3d      ", ball->next->x, ball->next->y);
  ball->next->gfx = ballbmp;
  SDL_SetColorKey (ball->next->gfx, SDL_SRCCOLORKEY, 0);
  //  fprintf (stderr, "new ball: %d\n", count);
}
void paletteswitch (BALLp ball) {
  if (useps == TRUE) {
    ++c;
    if (c > 223)
      ++c;
    color[1].r = c;
    color[1].b = c - 16;
    color[1].g = c - 32;
    SDL_SetColors (ball->gfx, color, 0, 2);
    return;
  }
}
void render (BALLp ball) {
  SDL_FillRect (screen, NULL, 0);
  if (usebg == TRUE)
    SDL_BlitSurface (bg, NULL, screen, NULL);
  renderballs (ball);
  SDL_Flip (screen);
  return;
}
void renderballs (BALLp ball) {
  if (ball->next != NULL)
    renderballs (ball->next);
  if (ball->gfx != NULL) {
    dest.x = ball->x; dest.y = ball->y;
    //    fprintf (stderr, "x: %3d  y: %3d      ", ball->x, ball->y);
    if (useps == TRUE)
      paletteswitch (ball);
    SDL_BlitSurface (ball->gfx, NULL, screen, &dest);
  }
  else
    return;
  return;
}

// begin main

int main (int argc, char **argv)
{
  unsigned char doexit = FALSE;
  int video_init_flags = SDL_HWSURFACE | SDL_DOUBLEBUF;
  BALLp ball;
  int num;
  //unsigned char loop;
  //int mx, my;

  //SDL initialization
  if ((SDL_Init(SDL_INIT_VIDEO))<0) {
    fprintf (stderr, "%s: %s.\n", argv[0], SDL_GetError());
  }
  if ((argc > 1) && (argv[1][1] == 'f'))
    video_init_flags |= SDL_FULLSCREEN;
//  atexit (SDL_Quit);
  screen = SDL_SetVideoMode (320, 240, 8, video_init_flags);
  SDL_Delay (700);

  bg = SDL_LoadBMP ("gfx/cam.bmp");
  ballbmp = SDL_LoadBMP ("gfx/ball.bmp");
  //init object ball
  ball = malloc (sizeof(BALL));
  ball->next = NULL;
  ball->prev = NULL;
  ball->action = NULL;
  ball->gfx = NULL;
  ball->x = 0;
  ball->y = 0;
  //SDL_BlitSurface(ball->gfx, NULL, screen, NULL);
  //SDL_Flip(screen);
 
  //event loop
  while (!doexit) {
    SDL_PollEvent (&event);
    switch (event.type) {
    case SDL_KEYDOWN:
      switch (event.key.keysym.sym) {
      case SDLK_q:
	doexit = TRUE;
	break;
      case SDLK_ESCAPE:
	doexit = TRUE;
	break;
      case SDLK_b:
	usebg = !usebg; //toggle background on/off
	event.type = 0;
	break;
      case SDLK_p:
	useps = !useps;
	event.type = 0;
	break;
      case SDL_QUIT:
	doexit = TRUE;
	break;
      case SDLK_c:
	num = count (ball) -1;
	event.type = 0;
	fprintf (stderr, "Number of ball objects: %d\n", num);
	break;
      default:
	break;
      }
      break;
    case SDL_MOUSEBUTTONDOWN:
     {
       newball (ball);
       event.type = 0;
     }
     break;
    }
    ballaction (ball);
    render (ball);
  }
  return 1;
}
