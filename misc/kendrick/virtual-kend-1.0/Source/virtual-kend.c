/*
  virtual-kend.c
  
  by Bill Kendrick
  bill@newbreedsoftware.com
  http://www.newbreedsoftware.com/virtual-kend/

  June 3, 2002 - June 3, 2002
*/

#define VER_VERSION "1.0"


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <SDL.h>
#include <SDL_image.h>


#ifndef DATA_PREFIX
#define DATA_PREFIX "data/"
#endif

#define WIDTH 240
#define HEIGHT 320
#define FPS 60

enum {
  IMG_KEND1,
  IMG_KEND2,
  IMG_TITLE,
  IMG_BILL,
  IMG_BUBBLE,
  IMG_THINK_LINUX,
  IMG_THINK_GAMES,
  IMG_THINK_ATARI,
  IMG_THINK_LUGOD,
  IMG_THINK_PHP,
  IMG_THINK_ZAURUS,
  IMG_THINK_CHOCOLATE,
  IMG_THINK_MELISSA,
  IMG_THINK_MALCOLM,
  IMG_THINK_EBONY,
  NUM_IMAGES
};

const char * image_fnames[NUM_IMAGES] = {
  DATA_PREFIX "images/kend1.bmp",
  DATA_PREFIX "images/kend2.bmp",
  DATA_PREFIX "images/title.bmp",
  DATA_PREFIX "images/bill.bmp",
  DATA_PREFIX "images/bubble.bmp",
  DATA_PREFIX "images/linux.bmp",
  DATA_PREFIX "images/games.bmp",
  DATA_PREFIX "images/atari.bmp",
  DATA_PREFIX "images/lugod.bmp",
  DATA_PREFIX "images/php.bmp",
  DATA_PREFIX "images/zaurus.bmp",
  DATA_PREFIX "images/chocolate.bmp",
  DATA_PREFIX "images/melissa.bmp",
  DATA_PREFIX "images/malcolm.bmp",
  DATA_PREFIX "images/ebony.bmp"
};


/* Globals: */

SDL_Surface * screen, * images[NUM_IMAGES];


/* Local function prototypes: */

int title(void);
int game(void);
void finish(void);
void setup(int argc, char * argv[]);
SDL_Surface * set_vid_mode(unsigned flags);
SDL_Surface * load_img(const char * fname);


/* --- MAIN --- */

int main(int argc, char * argv[])
{
  int done;


  setup(argc, argv);
  

  /* Main app loop! */
  
  do
  {
    done = title();

    if (!done)
    {
      done = game();
    }
  }
  while (!done);


  finish();

  return(0);
}


/* Title screen: */

int title(void)
{
  int done, quit, img, flip;
  SDL_Rect dest;
  SDL_Event event;
  SDLKey key;
  Uint32 now_time, last_time;

  
  /* Draw screen: */
    
  SDL_BlitSurface(images[IMG_KEND1], NULL, screen, NULL);
  img = 0;
  flip = 1;
    
    

  done = 0;
  quit = 0;

  do
  {
    last_time = SDL_GetTicks();
    

    /* Handle events: */

    while (SDL_PollEvent(&event) > 0)
    {
      if (event.type == SDL_QUIT)
      {
	done = 1;
	quit = 1;
      }
      else if (event.type == SDL_KEYDOWN)
      {
        key = event.key.keysym.sym;

	if (key == SDLK_SPACE || key == SDLK_RETURN)
        {
	  done = 1;
	}
	else if (key == SDLK_ESCAPE)
	{
	  done = 1;
	  quit = 1;
	}
      }
      else if (event.type == SDL_MOUSEBUTTONDOWN)
	{
	  done = 1;
	}
    }


    /* Flip img: */
    
    if ((rand() % 100) == 0)
    {
      img = !img;
      SDL_BlitSurface(images[IMG_KEND1 + img], NULL, screen, NULL);
      flip = 1;
    }


    if (flip)
    {
      flip = 0;
      
      dest.x = (WIDTH - (images[IMG_TITLE]->w)) / 2;
      dest.y = HEIGHT - (images[IMG_TITLE]->h) - 20;
      dest.w = images[IMG_TITLE]->w;
      dest.h = images[IMG_TITLE]->h;

      SDL_BlitSurface(images[IMG_TITLE], NULL, screen, &dest);

      SDL_Flip(screen);
    }



    /* Flush and pause! */

    now_time = SDL_GetTicks();
    
    if (now_time < last_time + (1000 / FPS))
      {
	SDL_Delay(last_time + 1000 / FPS - now_time);
      }
  }
  while (!done);

  return(quit);
}



/* --- GAME --- */

int game(void)
{
  int done, quit, counter, thinking, about, i;
  SDL_Event event;
  SDLKey key;
  SDL_Rect src, dest;
  Uint32 now_time, last_time;
 

  done = 0;
  quit = 0;
  counter = 0;

  SDL_FillRect(screen, NULL, SDL_MapRGB(screen->format, 0xFF, 0xFF, 0xFF));

  dest.x = (WIDTH - (images[IMG_BILL]->w)) / 2;
  dest.y = HEIGHT - (images[IMG_BILL]->h);
  dest.w = images[IMG_BILL]->w;
  dest.h = images[IMG_BILL]->h;

  SDL_BlitSurface(images[IMG_BILL], NULL, screen, &dest);
  
  SDL_Flip(screen);


  thinking = 0;
  about = 0;


  do
  {
    last_time = SDL_GetTicks();
    

    /* Handle events: */

    while (SDL_PollEvent(&event) > 0)
    {
      if (event.type == SDL_QUIT)
      {
	done = 1;
	quit = 1;
      }
      else if (event.type == SDL_KEYDOWN)
      {
        key = event.key.keysym.sym;

	if (key == SDLK_ESCAPE)
	{
	  done = 1;
	}
      }
    }


    if (thinking)
    {
      thinking++;

      if (thinking < (images[IMG_BUBBLE]->h))
      {
        thinking++;

        dest.x = 0;
        dest.y = (images[IMG_BUBBLE]->h) - thinking;
        dest.w = WIDTH;
        dest.h = thinking;


        SDL_BlitSurface(images[IMG_BUBBLE], &dest, screen, &dest);
        SDL_Flip(screen);
      }
      else if (thinking < (images[IMG_BUBBLE]->h) + 64)
      {
	for (i = (thinking % 4);
	     i < images[IMG_THINK_LINUX + about] -> h;
	     i = i + 2)
	{
          dest.x = 130 + (rand() % 10);
	  dest.y = i + 17;

	  src.x = 0;
	  src.y = i;
	  src.w = images[IMG_THINK_LINUX + about] -> w;
	  src.h = 1;

	  SDL_BlitSurface(images[IMG_THINK_LINUX + about], &src,
			  screen, &dest);
	}
	SDL_Flip(screen);
      }
      else if (thinking == (images[IMG_BUBBLE]->h) + 64)
      {
        SDL_BlitSurface(images[IMG_BUBBLE], NULL, screen, NULL);

	dest.x = 130;
	dest.y = 17;
	SDL_BlitSurface(images[IMG_THINK_LINUX + about], NULL,
			screen, &dest);
	SDL_Flip(screen);
      }
      else if (thinking >= (images[IMG_BUBBLE]->h) + 128)
      {
	thinking = 0;

	dest.x = 0;
	dest.y = 0;
	dest.w = WIDTH;
	dest.h = images[IMG_BUBBLE]->h;

	SDL_FillRect(screen, &dest, SDL_MapRGB(screen->format,
				               0xFF, 0xFF, 0xFF));
	SDL_Flip(screen);
      }
    }
    else
    {
      if (rand() % 10)
      {
	thinking = 1;

	/* about = (rand() % (NUM_IMAGES - IMG_THINK_LINUX)); */
	about++;

	if (about >= NUM_IMAGES - IMG_THINK_LINUX)
	  about = 0;
      }
    }


    /* Flush and pause! */

    now_time = SDL_GetTicks();
    
    if (now_time < last_time + (1000 / FPS))
      {
	SDL_Delay(last_time + 1000 / FPS - now_time);
      }
  }
  while (!done);

  return(quit);
}


void finish(void)
{
  SDL_Quit();
}


void setup(int argc, char * argv[])
{
  int i;
  
  
  /* Seed random number generator: */

  srand(SDL_GetTicks());
  
  
  /* Init SDL video: */
  
  if (SDL_Init(SDL_INIT_VIDEO) < 0)
    {
      fprintf(stderr,
              "\nError: I could not initialize video!\n"
              "The Simple DirectMedia error that occured was:\n"
              "%s\n\n", SDL_GetError());
      exit(1);
    }
  
  
  /* Open window: */
  
  screen = set_vid_mode(SDL_HWSURFACE);
      
  if (screen == NULL)
    {
      fprintf(stderr,
            "\nError: I could not set up video for "
            "%dx%d mode.\n"
            "The Simple DirectMedia error that occured was:\n"
            "%s\n\n", WIDTH, HEIGHT, SDL_GetError());
      exit(1);
    }
  
  
  
  /* Load background image: */

  for (i = 0; i < NUM_IMAGES; i++)
  {
    images[i] = load_img(image_fnames[i]);
  }
  
  SDL_SetColorKey(images[IMG_TITLE], (SDL_SRCCOLORKEY | SDL_RLEACCEL),
                  SDL_MapRGB(images[IMG_TITLE] -> format, 0xFF, 0xFF, 0xFF));


  SDL_WM_SetCaption("Virtual Bill Kendrick", "Virtual-Kend");
}


/* Set video mode: */
/* Contributed to "Defendguin" by Mattias Engdegard <f91-men@nada.kth.se> */

SDL_Surface * set_vid_mode(unsigned flags)
{
  /* Prefer 16bpp, but also prefer native modes to emulated 16bpp. */
  
  int depth;
  
  depth = SDL_VideoModeOK(WIDTH, HEIGHT, 16, flags);
  return depth ? SDL_SetVideoMode(WIDTH, HEIGHT, depth, flags) : NULL;
}


SDL_Surface * load_img(const char * fname)
{
  SDL_Surface * tmp, * out;

  tmp = SDL_LoadBMP(fname);
  
  if (tmp == NULL)
    {
      fprintf(stderr,
	      "\nError: I could not open the image:\n%s\n"
	      "The Simple DirectMedia error that occured was:\n"
	      "%s\n\n", fname, SDL_GetError());
      exit(1);
    }
  
  out = SDL_DisplayFormat(tmp);
  if (out == NULL)
    {
      fprintf(stderr,
	      "\nError: I couldn't convert the image:\n%s\n"
	      "to the display format!\n"
	      "The Simple DirectMedia error that occured was:\n"
	      "%s\n\n", fname, SDL_GetError());
      exit(1);
    }
  
  SDL_FreeSurface(tmp);

  return(out);
}
