
#include "video.h"
#include "kokko.h"
#include "mosaic.h"
#include "maf.h"
#include "plasma.h"
#include "pallot.h"
#include "ratas.h"
#include "cool_mzx/cool_mzx.h"

#include <SDL/SDL.h>

#include <stdio.h>
#include <string.h>
#include <math.h>

unsigned char buf[320*256],buf2[320*256];
unsigned char *displaybuf=buf;

extern char *musakki,*chrysler;

void stripes_osa(unsigned char *,int);
int readall(void);

/* Jos haluat eri triggereille eri maksimiarvot niin kirjoita
    lis‰‰ n‰it‰ MAX-definej‰. Ni. */
#define TRIG_MAX 50
#define TRIG_BONGG 80
#define TRIG_BD 15

static int trig_bongg, trig_bd, trig_sd, trig_kilaus, trig_rautaputki,
       trig_isopamaus, trig_sound1, trig_sound2, trig_isku,
       trig_loppuisku, trig_loppu, trig_melu, trig_puhe, trig_tehostus,
       trig_suvanto, trig_electric; 

#ifndef TRUE8BIT
static unsigned lockup[256];
#endif

void burnpalette(SDL_Surface *s,int kerroin, int nollakohta)
{
   int i,c;
   static SDL_Color pal[256];
   
   for (i=0; i<256; i++) {
        
         c=i*kerroin-nollakohta;
         if (c>255)
                 c=255;
         if (c<0)
                 c=0;
#ifdef TRUE8BIT
         pal[i].r=c;
         pal[i].g=c;
         pal[i].b=c;
#else
        lockup[i]=(c<<16)+(c<<8)+c;
#endif
   }

#ifdef TRUE8BIT
   SDL_SetPalette(s,SDL_LOGPAL,pal,0,256);
#endif
}
 
int main(int argc,char **argv)
{
    int modpos,pt_songpos,pt_patternpos,quit=0,frame=0,n,i;
    int video_trig,vbl,vbl2,origtick;

    int t1=0;
    int t2=0;
    int t3=0;
    int t4=0;
    int t5=0;
    int angle;
    int alkutikki,tikki,tikki2,first=1;
    int dt=0,dt2=0;
    int ovbl=0;

    SDL_Event e;
    SDL_Surface *s;
#ifdef TRUE8BIT
    char *screen;
#else
    unsigned *screen;
#endif
//  Fullscreen is broken with os4's SDL.   Varthall
//    int flags=SDL_HWSURFACE+SDL_DOUBLEBUF+SDL_FULLSCREEN;
    int flags=SDL_HWSURFACE+SDL_DOUBLEBUF;

/*    if(argc==2)
        if(!strcmp(argv[1],"-w"))
            flags-=SDL_FULLSCREEN;
    if(argv[0][strlen(argv[0])-1]=='w')
        flags-=SDL_FULLSCREEN;
*/
    if(readall()!=0)
    {
        printf("Problem loading datas\n");
        return(0);
    }
    init_filter();
    init_maf();
    init_plasma();
    init_pallot();
    mosaic_init(40);
    ratas_init();
    SDL_Init(SDL_INIT_VIDEO|SDL_INIT_AUDIO);
    mzx_init();
    mzx_get(musakki);

#ifdef TRUE8BIT
    s=SDL_SetVideoMode(640,480,8,flags);
#else
    s=SDL_SetVideoMode(640,480,32,flags);
#endif
    if(s==NULL)
    {
		fprintf(stderr,"Problem opening screen/window: %s\n", SDL_GetError());
		exit(1);
	}
    SDL_WM_SetCaption("Chrysler by Fit & Bandwagon",NULL);
    SDL_ShowCursor(0);
    screen=s->pixels;
#ifdef TRUE8BIT
    memset(s->pixels,0,640*480);
#else
    memset(s->pixels,0,640*480*4);
#endif
    burnpalette(s,1,0),

    mzx_start(50);
    while(mzx_position()<0 || mzx_position()>100) // Skip bug...
        ;

    origtick=SDL_GetTicks();
    vbl2=0;

    /* The main loop */
    while(!quit)
    {
        while(SDL_PollEvent(&e)>0)
        {
            if(e.type==SDL_MOUSEBUTTONDOWN)
                quit=1;
            if(e.type==SDL_KEYDOWN)
                if(e.key.keysym.sym==SDLK_ESCAPE)
                    quit=1;
        }

        vbl=(SDL_GetTicks()-origtick)/20;
        if(vbl<=vbl2+1)
            goto toofast;
        vbl2=vbl;

        modpos=mzx_position();
        pt_songpos=modpos/100;;
        pt_patternpos=modpos%100;

        dt=(vbl-ovbl)*30/50;
        ovbl=vbl;
        displaybuf=buf;
        
        if (modpos<400) {
                         
	    if (modpos<348) {
		draw_video(buf,vbl*30/50,1,1,0,dt);
		horiz_maf(buf,buf2,0,0,0,0,320,192,320,192,
			  sin(vbl*0.03)*25+25+10);
	    }
	    else {
		draw_video(buf,vbl*30/50,3,1,0,dt);
		horiz_maf(buf,buf2,0,0,0,0,320,192,320,192,
			  10);
	    }
                  
                /*
		horiz_maf(buf,buf2,0,0,0,0,320,192,320,192,
		trig_bongg*2+10);
		*/


                displaybuf=buf2;
              
                if ((modpos==200) && (!t1)) {
                        t1=1;
                        burnpalette(s,16,1920);
                }
            
        } else if (modpos<600) {
            
                if (!t2) {
                        burnpalette(s,1,0);
                        t2=1;   
                }
                if ((pt_patternpos % 16==0) && (pt_patternpos<48))
                        video_trig=1;
                else
                        video_trig=0;
                        
                draw_video(buf,vbl*30/50,0,1,video_trig,dt);
                horiz_maf(buf,buf2, 0,0,0,0, 320,192, 320,192, 5);

                if (modpos<548) {
                    
                        displaybuf=buf2;
                } else {
                     filter_kokko(buf2,vbl,244,1,0);                    
                        displaybuf=buf2;
                }
        } else if (modpos<800) {
            
                if ((pt_patternpos % 4==0) && (t3==0) && (pt_patternpos<56)) {
                        video_trig=2;
                        t3=1;
                } else {
                        video_trig=0;       
                }
                
                if (pt_patternpos % 4!=0)
                        t3=0;
                                
                draw_video(buf,vbl*30/50,2,1,video_trig,dt);
                if (modpos<700) {
                        displaybuf=buf;  
                } else {
                        mosaic(buf,buf2);      
                        displaybuf=buf2;
                }
       } else if (modpos<1200) {
        
              if (t4==0) {
                t4=1;
                burnpalette(s,16,1920);
              }
              plasma(buf,vbl);
              angle=sin(vbl*0.04)*6;
              filter_kokko(buf,vbl,244-trig_melu-trig_bd*3,angle,2);         
              displaybuf=buf;
              
              if (modpos>1000)
                  stripes_osa(buf,vbl);
 
              if (modpos>=1148) {
                  horiz_maf(buf,buf2, 0,0,0,0, 320,192, 320,192, 15);  
                  displaybuf=buf2;
              }
      } else  if (modpos < 1400) {
              if (t5==0) {
                t5=1;
                burnpalette(s,1,0);
              }
              
              if (modpos<1300) {
                pallot(buf,vbl,1,1+trig_sd,(pt_patternpos % 4)*2+2,8);
                displaybuf=buf;
              } else {
                pallot(buf,vbl,1,1+trig_sd,(pt_patternpos % 4)*2+2,8+((pt_patternpos/16) % 4));
                
                if (modpos>=1348) 
                    filter_kokko(buf,vbl,244,0,2);

                displaybuf=buf;
              } 

      } else if (modpos<1600) {

        
                dt2=dt;
                
                if (modpos<1500) {
                        if ((pt_patternpos>=16) && (pt_patternpos<40))
                                dt2=dt;
                        else
                                dt2=0;                        
                } else {
                        if (((pt_patternpos>=0) && (pt_patternpos<8)) ||
                            ((pt_patternpos>=16) && (pt_patternpos<24)) ||
                            ((pt_patternpos>=32) && (pt_patternpos<40)) ||
                            ((pt_patternpos>=48) && (pt_patternpos<56)))
                                dt2=dt;
                        else
                                dt2=0;
                }
                draw_video(buf,vbl*30/50,5,1,0,dt2);
                
                horiz_maf(buf,buf2,0,0,0,0,320,192,320,192,
                sin(vbl*0.1)*8+9);
                displaybuf=buf2;               
                alkutikki=tikki=vbl;
      } else if (modpos<2000) {
                memset(buf,0,320*192);
                
                if(first && modpos>=1648)
                {
                    first=0;
                    alkutikki+=50*3;
                }
                
                if(modpos%100/32%2==0)
                {
                    ratas_osa(buf,vbl-alkutikki,vbl-tikki);
                    tikki2=vbl*2-tikki;
                }
                else
                {
                    ratas_osa(buf,vbl-alkutikki,tikki2-vbl);
                    tikki=vbl-(tikki2-vbl);
                }
                 
                if (modpos>1800) {
                   filter_kokko(buf,vbl,244-(pt_patternpos % 8),1,0);
                   displaybuf=buf;
                } else {
                   displaybuf=buf;                
                }
      } else if (modpos<2400) {
                if (pt_patternpos % 64<32) {
                   draw_video(buf,vbl*30/50,6,1,video_trig,dt);
                } else {
                   draw_video(buf,vbl*30/50,4,1,video_trig,dt);
                }  

                   filter_kokko(buf,vbl,244,0,0);
             
                if (modpos>=2200) {
                        mosaic(buf,buf2);      
                        displaybuf=buf2;
                } else {
                        displaybuf=buf;   
                }    
      } else if (modpos<2548) {
              // CHRYSLER    
                memcpy(buf,chrysler,320*192);
                displaybuf=buf;
      } else {
                quit=1; 
      }  

        frame++;
        toofast:
        SDL_LockSurface(s);
        for(n=0;n<192;n++)
        {
#ifdef TRUE8BIT
            unsigned char *p=&screen[(n+24)*640*2];
            for(i=0;i<320;i++,p+=2)
                *p=*(p+1)=displaybuf[n*320+i];
            for(i=0;i<320;i++,p+=2)
                *p=*(p+1)=*(p-640)>>1;
#else
            unsigned *p=&screen[(n+24)*640*2];
            for(i=0;i<320;i++,p+=2)
                *p=*(p+1)=lockup[displaybuf[n*320+i]];
            for(i=0;i<320;i++,p+=2)
                *p=*(p+1)=(*(p-640)>>1)&0x7f7f7f;
#endif
        }
        SDL_UnlockSurface(s);

        // For plain buffer:
        //memcpy(&screen[24*320],displaybuf,320*192);
        SDL_Flip(s);

        //if(frame%20==0 && vbl)
        //    printf("fps: %f\n",frame*50.0/vbl);
		SDL_Delay(50);
    }

    SDL_Quit();
    return(0);
}
