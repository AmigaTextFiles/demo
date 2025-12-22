/*
    fit-039: Boy
*/

#include <math.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include <SDL.h>
#include <SDL_opengl.h>

#include "wavefront.h"
#include "gl_render.h"
#include "cgm.h"
#include "cgm_gl.h"
#include "writer.h"
#include "stripe.h"
#include "stiks.h"
#include "houses.h"
#include "mp3.h"

#ifndef XS
#define XS 640
#define YS 480
#endif

#define WORM_STEPS 20
#define CIRCLE_STEPS 40
#define ARROWS 30
#define BUTTDIST 3
#define BUTTS 7

// Never do display lists like this
#define LIST_BLOMS 1
#define LIST_MARQ 2
#define LIST_DRAW 3
#define LIST_BUTT 5
#define LIST_ROZ 6
#define LIST_CHAIN 10

void gridi(double phase);
void rendertext(int xs,int ys);

int bg_beat[]=    {0,      48,     64,     96,       128, -1};
float bg_rgb[][3]={{1,1,1},{0,0,0},{1,1,1},{0.8,0,0},{1,1,1}};

int main(int argc,char *argv[])
{
    int n,i,quit=0,start,tid,tid2,beat=0,beat2=0,pbeat=-1,
        s_listen=-1,s_ganz=-1,s_arch=-1,s_stripe=-1,s_seagal=-1,
        s_f1=-1,s_f2=-1,s_f3=-1,
        sang=0,eang=0;
    double d,d2,th,x,y,mx=0,my=0;
    char charz[100];
    SDL_Event e;
    int     xs=XS,ys=YS,fs=SDL_FULLSCREEN,fsaa=0,sound=1,
            text=0,pink=0; // All sorts of demo parameters
    float   br=1,bg=1,bb=1;
    
    SCENE   graf,bloms,clown,butt,arrow,listen,gun,pointer,curve,
            butter,mask,lod,chain,seagal,seagalw;
    OBJ     *o;
    CGM     *marq,*roz,*bond,*barbie;

    /* Parse the command line */
    for(n=1;n<argc;n++)
    {
        if(!strcmp(argv[n],"-nofsaa"))
            fsaa=0;
        if(!strcmp(argv[n],"-nosound"))
            sound=0;
        if(!strcmp(argv[n],"-w"))
            fs=0;
        if(!strcmp(argv[n],"-text"))
            text=1;
        if(!strcmp(argv[n],"-pink"))
            pink=1;
        if(!strcmp(argv[n],"-res"))
        {
            if(n>=argc-2)
            {
                puts("Give the resolution too plz.");
                return(EXIT_FAILURE);
            }
            xs=atoi(argv[n+1]);
            ys=atoi(argv[n+2]);
            n+=2;
        }
    }
    /* For Mac, prod_window */
    if(argv[0][strlen(argv[0])-1]=='w')
        fs=0;

    // Load tune
    if(sound)
    {
        mp3_init();
        if(pink)
        {
            if(mp3_load("data/carrot_porn.mp3"))
            {
                puts("Get http://ftp.kameli.net/pub/fit/boy/carrot_porn.mp3");
                puts("and place it in the data directory.");
                return(EXIT_FAILURE);
            }
        }
        else
            if(mp3_load("data/boy_carrot_v4.mp3"))
                return(EXIT_FAILURE);
    }

    SDL_Init(SDL_INIT_VIDEO+SDL_INIT_TIMER);
    SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER,1);
    SDL_GL_SetAttribute(SDL_GL_SWAP_CONTROL,1);
    if(fsaa)
    {
        SDL_GL_SetAttribute(SDL_GL_MULTISAMPLEBUFFERS,1);
        SDL_GL_SetAttribute(SDL_GL_MULTISAMPLESAMPLES,4);
    }
    SDL_SetVideoMode(xs,ys,32,SDL_OPENGL+fs);
    SDL_WM_SetCaption("fit-039: Boy",0);
    SDL_ShowCursor(0);

    // Load and set up 3D objs
    set_path("data/");
    load_scene(&graf,"ganz_graf.obj");
    render_scene(&graf,RENDER_NORMAL+RENDER_NOLIGHTS+RENDER_COMPILE);
    load_scene(&clown,"clown.obj");
    load_scene(&arrow,"arrow.obj");
    load_scene(&listen,"listenup.obj");

    if(pink)
        load_scene(&gun,"heart2.obj");
    else
        load_scene(&gun,"revolveri.obj");

    load_scene(&pointer,"pointer.obj");
    load_scene(&curve,"curve.obj");
    render_scene(&curve,RENDER_NORMAL+RENDER_NOLIGHTS+RENDER_COMPILE);
    load_scene(&seagal,"seagal.obj");
    load_scene(&seagalw,"seagalw.obj");
    render_scene(&seagal,RENDER_NORMAL+RENDER_NOLIGHTS+RENDER_COMPILE);
    render_scene(&seagalw,RENDER_NORMAL+RENDER_NOLIGHTS+RENDER_COMPILE);

    load_scene(&butter,"butterlod.obj");
    load_scene(&mask,"buttermask.obj");
    load_scene(&lod,"butterlod.obj");
    render_scene(&butter,RENDER_NORMAL+RENDER_NOLIGHTS+RENDER_COMPILE);
    render_scene(&lod,RENDER_NORMAL+RENDER_NOLIGHTS+RENDER_COMPILE);

    if(pink)
        load_scene(&bloms,"heart.obj");
    else
        load_scene(&bloms,"blomstedt.obj");
    glNewList(LIST_BLOMS,GL_COMPILE);
    render_scene(&bloms,RENDER_NORMAL+RENDER_NOLIGHTS);
    glEndList();

    if(pink)
        load_scene(&butt,"taulu_heart.obj");
    else
        load_scene(&butt,"taulu.obj");
    glNewList(LIST_BUTT,GL_COMPILE);
    render_scene(&butt,RENDER_NORMAL+RENDER_NOLIGHTS);
    glEndList();

    load_scene(&chain,"chain.obj");
    glNewList(LIST_CHAIN,GL_COMPILE);
    render_scene(&chain,RENDER_NORMAL+RENDER_NOLIGHTS);
    glEndList();

    writer_init("font.obj");
    stripe_init();
    stiks_init(pink);
    houses_init();

    // Load and set up 2D cgms
    marq=cgm_load("data/marq.cgm");
    glNewList(LIST_MARQ,GL_COMPILE);
    cgm_render(marq);
    glEndList();

    roz=cgm_load("data/roz.cgm");
    glNewList(LIST_ROZ,GL_COMPILE);
    cgm_render(roz);
    glEndList();

    bond=cgm_load("data/bondi.cgm");
    barbie=cgm_load("data/barbie.cgm");

    if(sound)
        mp3_play();
    
    start=SDL_GetTicks();
    while(!quit)
    {
        tid=SDL_GetTicks()-start;

        if(sound)
            beat2=mp3_pos()/10584;
        else
            beat2=tid*441/105840;
        beat=beat2/2; // 125 BPM

        // Common GL setup for each frame
        for(n=0;bg_beat[n]!=-1;n++)
            if(beat>=bg_beat[n])
            {
                br=bg_rgb[n][0];
                bg=bg_rgb[n][1];
                bb=bg_rgb[n][2];
            }
        glClearColor(br,bg,bb,0);
        glClear(GL_COLOR_BUFFER_BIT+GL_DEPTH_BUFFER_BIT);

        glMatrixMode(GL_PROJECTION);
        glLoadIdentity();
        if((beat==48) || (beat>=60 && beat<64) || (beat==64) || (beat==96)
           || (beat==224) || (beat==192) || (beat==240) || (beat==288)
           || (beat==160))
        {
            d=sin(tid/10.0)/2000.0;
            glFrustum(-1.33/10.0+d,1.33/10.0+d, -1/10.0,1/10.0, 2/10.0,1000.0);
        }
        else
            glFrustum(-1.33/10.0,1.33/10.0, -1/10.0,1/10.0, 2/10.0,1000.0);

        glMatrixMode(GL_MODELVIEW);
        glDisable(GL_DEPTH_TEST);
        glDisable(GL_CULL_FACE);
        glShadeModel(GL_FLAT);
        glLoadIdentity();

        /* Sample curve */
        if((beat<48) || (beat>=224 && beat<256) || (beat>=160 && beat<224) || (beat>=128 && beat<160))
        {
            glDisable(GL_CULL_FACE);
            glLoadIdentity();
            if(beat>=160 && beat<224)
            {
                glTranslatef(0,18.5,-37);
                glColor3f(0.3,0.3,1.0);
            }
            else
            {
                glTranslatef(0,-3.9,-37);
                glColor3f(0.85,0.85,0.85);
            }
            glBegin(GL_QUAD_STRIP);
            for(n=0;n<mp3_floatvals/2;n+=4)
            {
                glVertex2f(-30+120.0*n/mp3_floatvals,-fabs(mp3_floatbuf[n]*7.0)-0.3);
                glVertex2f(-30+120.0*n/mp3_floatvals,+fabs(mp3_floatbuf[n]*7.0)+0.3);
            }
            glEnd();
        }

        // Stooges
        if(beat<32)
            for(n=0;n<3;n++)
            {
                glLoadIdentity();
    
                d=sin(tid/300.0)*25.5;
                if(d>25) d=25;
                if(d<-25) d=-25;
                d+=25;
    
                if((int)((tid/300.0+0.5*M_PI)/(2*M_PI))%3!=n)
                    d=0;
    
                find_object(&clown,"rhand")->rot=d;
                find_object(&clown,"lhand")->rot=-d;
                find_object(&clown,"rfoot")->rot=d;
                find_object(&clown,"lfoot")->rot=-d;
    
                switch(n)
                {
                    case 0: glTranslatef(-1.3,-0.6,0.3); break;
                    case 1: glTranslatef(0,0,-1); break;
                    case 2: glTranslatef(3,0.8,-4); break;
                }
                glTranslatef(0,-d/5000+0.2,-2.9);
                glRotatef(sin(tid/2000.0+n*90)*30+((n==1)?180:0),0,1,0);
                render_scene(&clown,RENDER_NORMAL+RENDER_NOLIGHTS);
            }

        // Listen up
        if(beat>=31 && beat<48)
        {
            if(s_listen==-1)
                s_listen=tid;
            tid2=tid-s_listen;

            glEnable(GL_DEPTH_TEST);
            glLoadIdentity();
            glTranslatef(0,0,-4.3);
            for(n=10;n<=20;n++)
            {
                // Slam each letter to screen from 10 to 20
                d=n*30-tid2/6.0-100;
    
                // Wiggle if onscreen
                if(d<0)
                    d=((n&1)?-1:1)*sin((tid2/6.0-n*30+100)/30.0)*2.0;
                if(d>180)
                    d=180;
    
                sprintf(charz,"%d",n);
                find_object(&listen,charz)->rot=d;
            }
            render_scene(&listen,RENDER_NORMAL+RENDER_NOLIGHTS);
            glDisable(GL_DEPTH_TEST);
        }

        // Rings
        if(beat>=48 && beat<64)
            for(n=0;n<14;n++)
            {
                glColor3f(1,1,1);
                glLoadIdentity();
                glTranslatef(4,-2,-11);
                glTranslatef(sin(n*2-tid/200.0)/7.0,cos(n-tid/203.0)/7.0,0);
    
                glBegin(GL_QUAD_STRIP);
                d=n;
                d2=n+1.01;
                for(i=0;i<=CIRCLE_STEPS;i++)
                {
                    th=2*M_PI*i/CIRCLE_STEPS+tid/500.0;
                    if(n&1)
                        th+=tid/1000.0;
                    glVertex2f(cos(th)*d2,sin(th)*d2);
                    glVertex2f(cos(th)*d,sin(th)*d);
                }
                glEnd();
            }

        // Blomstedt
        if(beat>=48 && beat<64)
        {
            for(n=0;n<12;n++)
            {
                glLoadIdentity();
                glTranslatef(0,0,-4.8);
                glTranslatef(sin(n/2.0+tid/1000.0)*2.5,cos(n*2.1+tid/501.0)*0.5,cos(n*1.5+tid/200.0)*0.2);
                glRotatef(tid/14.0+n*20,1,0,0);
                glRotatef(tid/21.0+n*40,0,0,1);
                glCallList(LIST_BLOMS);
            }
        }

        // My name is Bond, James Bond
        if(beat>=48 && beat<64)
            for(n=0;n<(beat-48)/2;n++)
            {
                if(beat2&1 || n>6)
                    continue;

                glLoadIdentity();
                glTranslatef(4-n*1.0,-2.5+n/2.05,-7+n);
                cgm_render(bond);
            }

        // Marianne
        if(beat>=64 && beat<96)
        {
            for(n=0;n<20;n++)
            {
                glLoadIdentity();
                //glRotatef(tid/100.0,0,0,1);
                glTranslatef(-2.2+(n*5%4)/10.0, n/6.6-0.8, -2.4);
    
                if(n&1)
                    glColor3f(1,1,1);
                else
                    glColor3f(0.8,0,0);
    
                glBegin(GL_QUAD_STRIP);
                for(i=0;i<WORM_STEPS;i++)
                {
                    d=sin(n/2.0-(tid/400.0)+i/1000.0)*0.2;
                    th=sin(i*M_PI/WORM_STEPS)*0.8+0.005;
                    glVertex2f(4.0*i/(float)WORM_STEPS,d-th);
                    glVertex2f(4.0*i/(float)WORM_STEPS,d+th/3);
                }
                glEnd();
            }
        }

        // Ganz graf
        if(beat>=64 && beat<96)
        {
            if(s_ganz==-1)
                s_ganz=tid;
            tid2=tid-s_ganz;

            d=tid2*((beat/4&1)?1:-1);
            find_object(&graf,"ryhma1")->rot=d/5.0;
            find_object(&graf,"ryhma2")->rot=-d/6.0;
            find_object(&graf,"ryhma3")->rot=d/7.0;
            find_object(&graf,"ryhma4")->rot=-d/15.0;
            find_object(&graf,"ryhma5")->rot=sin(d/400.0)*5.0-d/5.0;
    
            for(n=0;n<5;n++)
            {
                glLoadIdentity();
                glTranslatef(n*3-6,n%2*3-2,-14+tid2/2500.0+(beat/4&1)*4);
                glRotatef(30,1,0,-0.1);
                glRotatef(tid2/100.0+n*90,0,1,0);
                render_scene(&graf,RENDER_NORMAL+RENDER_NOLIGHTS);
            }
            glDisable(GL_CULL_FACE);
        }

        // Some sort of tree
        if(beat>=96 && beat<128)
        {
            glLoadIdentity();
            glTranslatef(0,0,-2.5);
            stiks(tid,beat);
        }

        // Grid
        if(beat>=96 && beat<128)
        {
            glLoadIdentity();
            glRotatef(-tid/70.0,0,0.1,1);
            glTranslatef(0,0,-5+sin(tid/400.0)*2.0);
            glColor3f(0.8,0,0);
            gridi(tid%1000/1000.0);
        }

        // Stripe
        if(beat>=128 && beat<160)
        {
            if(s_stripe==-1)
                s_stripe=tid;
            tid2=tid-s_stripe;

            if(pbeat!=beat)
            {
                srand(beat);
                stripe_init();
                pbeat=beat;
            }

            glLoadIdentity();
            glTranslatef(-0.7,0,-3.5);
            glRotatef(-tid2/7.0,0,1,0.2);
            //glRotatef(-tid2/40.0,0,0,1);
            stripe(tid2);
        }

        // Chains
        if(beat>=128 && beat<160)
            for(i=0;i<3;i++)
                for(n=0;n<12;n++)
                {
                    glLoadIdentity();
                    glTranslatef(2.5+sin(i*2)*1.2,n-6+fmod(tid/1000.0,2),-8+i*2);
                    glRotatef(i*20+(n&1)*90+tid/200.0,0,1,0);
                    glCallList(LIST_CHAIN);
                }

        // Archery
        if(beat>=160 && beat<224)
        {
            if(s_arch==-1)
                s_arch=tid;
            tid2=tid-s_arch;

            for(n=0;n<BUTTS;n++)
            {
                glLoadIdentity();
                glTranslatef(-1.5,0,-3);
                glRotatef(40+tid2/2000.0, 0,1,0);
                glEnable(GL_DEPTH_TEST);
    
                glTranslatef(n*BUTTDIST,0,0);
                glCallList(LIST_BUTT);
            }
            glLineWidth(1);
            glColor3f(0,0,0);
            for(n=0;n<10;n++)
            {
                glBegin(GL_LINES);
                glVertex3f(-1000,-1,n/2.0-2);
                glVertex3f(1000,-1,n/2.0-2);
                glEnd();
            }
            for(n=0;n<ARROWS;n++)
            {
                d=tid2/1000.0-n;
                if(d<0) d=0;
                if(d>1) d=1;
                
                glPushMatrix();
                x=sin(n*1.2)*0.6-(n*3%BUTTS)*BUTTDIST;
                d2=d-0.5;
                d2=-d2*d2+0.25;
                y=cos(n)*0.7;
    
                glTranslatef(x, y+d2*8, 50-d*50);
    
                // Arrow shaking
                d2=0;
                if(fmod(tid2/1000.0,1)<0.1 && tid2/1000==n+1)
                    d2=rand()%100/200.0-0.25;
    
                glRotatef(-16*(d-0.5)+d2,1,0,0);
                render_scene(&arrow,RENDER_NORMAL+RENDER_NOLIGHTS);
                glPopMatrix();
            }
            glDisable(GL_DEPTH_TEST);
            glDisable(GL_CULL_FACE);
        }

        // Curvy arrows
        if(beat>=224 && beat<256)
        {
            for(n=0;n<7;n++)
            {
                glLoadIdentity();
                glTranslatef(n*0.6-1.87,-0.1,-1.37+n*0.1);
                glRotatef(n*4,0,0,1);
                d=tid/12.0-180.0+sin(n*2.5)*180.0;
                //if(d<0)
                    //d=0;
                //if(d>210)
                    //d=210;
                glRotatef(d,1,0,0);
                o=find_object(&curve,"arr1");
                render_object(&curve,o,RENDER_NORMAL+RENDER_NOLIGHTS);
                glDisable(GL_CULL_FACE);
            }
        }

        // Revolver
        if(beat>=224 && beat<256)
        {
            glLoadIdentity();
            glTranslatef(0,-0.1,-3.5);
            if(beat<240)
                glRotatef(tid/5.0,0,1,0);
            else
                glRotatef(-tid/5.0,0,1,0);

            if(beat<254 || tid/120&1)
                render_scene(&gun,RENDER_NORMAL+RENDER_NOLIGHTS);
            else
                render_scene(&gun,RENDER_WIRE+RENDER_NOLIGHTS);

            /*d=tid/100.0;
            find_object(&gun,"hammer")->rot=0; // min -50
            find_object(&gun,"trigga")->rot=0; // max 30
            o=find_object(&gun,"bullet");
            glTranslatef(-fmod(tid/100.0,5),0,0);*/
        }

        // City ride
        if(beat>=256 && beat<320)
            houses(tid,(beat<288)?0:1);

        // Steven Seagals
        if(beat>=320 && beat<384)
        {
            if(s_seagal==-1)
                s_seagal=tid;
            tid2=tid-s_seagal;

            glDisable(GL_DEPTH_TEST);

            // "Moon"
            if(!pink)
                for(n=0;n<2;n++)
                {
                    d2=3.0/4.0*M_PI-tid2/20000.0;
                    glLoadIdentity();
                    glTranslatef(n*0.25+cos(d2)*15,-10.5+sin(d2)*15,-12);
                    glColor3f(n,n,n);
                    glBegin(GL_POLYGON);
    
                    d2=1-n/7.0;
                    for(d=0;d<=M_PI*2;d+=0.1)
                        glVertex2f(cos(d)*d2,sin(d)*d2);
                    glEnd();
                }
            else
            {
                glLoadIdentity();
                glTranslatef(0,0,-0.2-tid2/16000.0);
                cgm_render(barbie);
            }

            for(i=0;i<2;i++)
            {
                srand(0);
                for(n=0;n<20;n++)
                {
                    glLoadIdentity();
                    glRotatef(25,0,1,0);
        
                    d=sin(tid/90.0+n);
                    if(!i)
                        glTranslatef(-fmod(tid/70.0+rand()%40,40)+35,
                                     rand()%16-8+d/20.0,
                                     -19+rand()%16-i*20);
                    else
                        glTranslatef(-fmod(tid/110.0+rand()%80,80)+70,
                                     rand()%16-8+d/20.0,
                                     -19+rand()%16-i*20);
                    glRotatef(sin(tid/1000.0+n)*40,1,0,0);
                    glRotatef(sin(tid/5000.0+n)*5,0,0,1);
        
                    find_object(&seagalw,"right")->rot=
                    find_object(&seagalw,"left")->rot=
                    find_object(&seagal,"right")->rot=
                    find_object(&seagal,"left")->rot=d*30+10;
    
                    if(!i)
                        render_scene(&seagal,RENDER_NORMAL+RENDER_NOLIGHTS);
                    else
                        render_scene(&seagalw,RENDER_NORMAL+RENDER_NOLIGHTS);
                }
            }
        }

        // Some sucky lines more
        if(beat>=320 && beat<384)
        {
            glColor3f(0,0,0);
            glLoadIdentity();
            glLineWidth(2);
            for(n=0;n<10;n++)
            {
                d=-3.8-n/4.3;
                glBegin(GL_POLYGON);
                  glVertex3f(-10,d,-10);
                  glVertex3f(10,d,-10);
                  glVertex3f(10,d+(0.02+n/27.0),-10);
                  glVertex3f(-10,d+(0.02+n/27.0),-10);
                glEnd();
            }
        }

        // Credit faces
        if(beat>=336 && beat<348)
            for(n=0;n<(beat-336);n++)
            {
                if(beat2&1 || n>=6)
                    continue;

                glLoadIdentity();
                glTranslatef(4.3-n*1.1,-3.0+n/2.05,-8+n);
                glCallList(LIST_MARQ);
            }
        if(beat>=356 && beat<368)
            for(n=0;n<(beat-356);n++)
            {
                if(beat2&1 || n>=6)
                    continue;

                glLoadIdentity();
                glTranslatef(4.3-n*1.1,-3.0+n/2.05,-8+n);
                glCallList(LIST_ROZ);
            }

        // Pointing arrows
        /*glLoadIdentity();
        glTranslatef(mx,my,-10);
        glRotatef(tid/10.0,0,0,1);
        for(n=0;n<4;n++)
        {
            glPushMatrix();
            glRotatef(90*n,0,0,1);
            glTranslatef(0,-0.4+sin(tid/100.0)/3.0,0);
            render_scene(&pointer,RENDER_CARTOON);
            glPopMatrix();
            glDisable(GL_CULL_FACE);
            glDisable(GL_DEPTH_TEST);
        }*/

        // Butterflies
        if(beat>=384)
        {
            glDisable(GL_DEPTH_TEST);
            for(i=0;i<3;i++)
            {
                d=-10*(3-i)+fmod(tid/300.0,10);
                if(d>0)
                    continue;
                for(n=0;n<6;n++)
                {
                    glLoadIdentity();
                    glRotatef(sin(d/10.0+n/7.0)*10,1,0.5,0);
    
                    if(n==0)
                        glTranslatef(-0.3,0,d);
                    else
                        glTranslatef(sin(n*1.4)*2.1,cos(n*1.4)*2.1,d+n*1.1);
                    glRotatef(sin(tid/2000.0+n)*50+sin(d/4.0)*40,0,0.3,1);
                    glRotatef(-n*5+sin(d/10.0)*30.0,1,0,0);
    
                    d2=sin(tid/100.0+n);
                    glTranslatef(0,0,-d2*0.05);
    
                    find_object(&lod,"right")->rot=
                    find_object(&lod,"left")->rot=
                    find_object(&mask,"right")->rot=
                    find_object(&mask,"left")->rot=
                    find_object(&butter,"right")->rot=
                    find_object(&butter,"left")->rot=d2*30.0+20;
        
                    if(n==0 && i)
                        render_scene(&mask,RENDER_NORMAL+RENDER_NOLIGHTS);
                    if(i!=2)
                        render_scene(&lod,RENDER_NORMAL+RENDER_NOLIGHTS);
                    else
                        render_scene(&butter,RENDER_NORMAL+RENDER_NOLIGHTS);
                }
            }
        }

        // Writer
        writers_update(tid,beat2,pink);

        /* Fades */
        if((beat<5) || (beat>=28 && beat<32) || (beat>=384 && beat<392)
           || (beat>492))
        {
            glLoadIdentity();
            glEnable(GL_BLEND);
            glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
            if(beat<5)
            {
                d=1-tid/2000.0;
                if(d<0) d=0;
                glColor4f(0,0,0,d);
            }
            if(beat>=28 && beat<32)
            {
                if(s_f1==-1)
                    s_f1=tid;
                d=(tid-s_f1)/1000.0;
                glColor4f(1,1,1,d);
            }
            if(beat>492)
            {
                if(s_f2==-1)
                    s_f2=tid;
                d=(tid-s_f2)/5000.0;
                glColor4f(0,0,0,d);
            }
            if(beat>=384 && beat<392)
            {
                if(s_f3==-1)
                    s_f3=tid;
                d=1-(tid-s_f3)/3000.0;
                if(d<0) d=0;
                glColor4f(1,1,1,d);
            }

            glBegin(GL_POLYGON);
            glVertex3f(-10,-10,-1);
            glVertex3f(10,-10,-1);
            glVertex3f(10,10,-1);
            glVertex3f(-10,10,-1);
            glEnd();
            glDisable(GL_BLEND);
        }

        if(pink)
        {
            glLoadIdentity();
            glEnable(GL_BLEND);
            glBlendFunc(GL_ZERO,GL_SRC_COLOR);
            glColor3f(1,0.6,0.8);

            glBegin(GL_POLYGON);
            glVertex3f(-10,-10,-1);
            glVertex3f(10,-10,-1);
            glVertex3f(10,10,-1);
            glVertex3f(-10,10,-1);
            glEnd();

            glDisable(GL_BLEND);
        }

        // Round the edges
        glDisable(GL_CULL_FACE);
        glMatrixMode(GL_PROJECTION);
        glLoadIdentity();
        glFrustum(-1.33/10.0,1.33/10.0, -1/10.0,1/10.0, 2/10.0,1000.0);
        glMatrixMode(GL_MODELVIEW);
        glColor3f(0,0,0);
        for(n=0;n<4;n++)
        {
            d=0.02;
            d2=0.08;
            glLoadIdentity();
            switch(n)
            {
                case 0: sang=20; eang=40; glTranslatef(-1.33+d,1-d,-2); break;
                case 1: sang=40; eang=60; glTranslatef(-1.33+d,-1+d,-2); break;
                case 2: sang=0; eang=20; glTranslatef(1.33-d,1-d,-2); break;
                case 3: sang=60; eang=80; glTranslatef(1.33-d,-1+d,-2); break;
            }
            glBegin(GL_TRIANGLE_STRIP);
            for(i=sang;i<eang;i++)
            {
                glVertex2f(cos(i*M_PI*2.0/80.0)*d,sin(i*M_PI*2.0/80.0)*d);
                glVertex2f(cos(i*M_PI*2.0/80.0)*d2,sin(i*M_PI*2.0/80.0)*d2);
            }
            glEnd();
        }

        SDL_GL_SwapBuffers();
        if(text)
            rendertext(xs,ys);

        while(SDL_PollEvent(&e)>0)
        {
            if(e.type==SDL_QUIT)
                quit=1;
            if(e.type==SDL_KEYDOWN)
                if(e.key.keysym.sym==SDLK_ESCAPE)
                    quit=1;

            if(e.type==SDL_MOUSEMOTION)
            {
                mx=(e.motion.x-XS/2)/70.0;
                my=-(e.motion.y-YS/2)/70.0;
            }
        }
        if(beat>=510)
            quit=1;
    }

    if(sound)
        mp3_stop();
    SDL_Quit();
    if(text) // Clean text screen
    {
        printf("%c[2J",0x1b);
        printf("%c[H",0x1b);
        printf("%c[0m",0x1b);
    }
    return(EXIT_SUCCESS);
}

#define GRIDS 15
#define GRIDSZ 1.0
#define GRIDDIV 4

/* Recursively divide the grid */
void split(float x1,float y1, float x2,float y2, int depth)
{
    float   mx,my;

    if(depth>GRIDDIV)
        return;

    if(rand()%3!=0)
    {
        mx=(x1+x2)*0.5;
        my=(y1+y2)*0.5;

        if(depth<GRIDDIV-3)
            glBegin(GL_LINES);
        glVertex2f(mx,y2);
        glVertex2f(mx,y1);

        glVertex2f(x1,my);
        glVertex2f(x2,my);

        split(x1,my, mx,y2, depth+1);
        split(x1,y1, mx,my, depth+1);
        split(mx,my, x2,y2, depth+1);
        split(mx,y1, mx,my, depth+1);

        if(depth<GRIDDIV-3)
            glEnd();
    }
}

void gridi(double phase)
{
    int x,y;

    glLineWidth(2);
    srand(1);

    for(y=0;y<GRIDS;y++)
        for(x=0;x<GRIDS;x++)
        {
            glPushMatrix();
            glTranslatef(x-GRIDS/2.0,y-GRIDS/2.0,0);
            glBegin(GL_LINE_STRIP);
            glVertex2f(0,GRIDSZ);
            glVertex2f(GRIDSZ,GRIDSZ);
            glVertex2f(GRIDSZ,0);
            glEnd();
        
            split(0,0,GRIDSZ,GRIDSZ,0);
            glPopMatrix();
        }

    glLineWidth(1);
}

void rendertext(int xs,int ys)
{
    static unsigned char *buf=NULL;
    char lookup[]=" .,-:;0@";
    int x,y,prev=-1,i,c;

    if(buf==NULL)
        buf=malloc(xs*ys*4);
    glReadPixels(0,0,xs,ys,GL_RGBA,GL_UNSIGNED_BYTE,buf);

    // Works only for Unix-like terminals. Feel free to improve.
    printf("%c[H",0x1b);

    prev=-1;
    for(y=0;y<ys;y++)
    {
        for(x=0;x<xs;x++)
        {
            i=(ys-1-y)*xs*4+x*4;
            c=(buf[i]*3+buf[i+1]*5+buf[i+2]*2)/10;

            if(c<128)
            {
                if(prev!=0)
                {
                    printf("%c[0m",0x1b);
                    prev=0;
                }
                putchar(lookup[c/16]);
            }
            else
            {
                if(prev!=1)
                {
                    printf("%c[7m",0x1b);
                    prev=1;
                }
                putchar(lookup[7-(c-128)/16]);
            }
        }
        if(y!=ys-1)
            printf("\n");
    }

    fflush(stdout);
}
