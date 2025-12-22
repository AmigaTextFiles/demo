
#include <math.h>
#include <stdio.h>
#include <string.h>
#include <SDL/SDL.h>
#include <SDL/SDL_main.h>
#ifdef UGLY_GL_HEADERS
#include <GL.h>
#else
#include <GL/gl.h>
#include <GL/glut.h>
#endif

#include "cool_mzx/cool_mzx.h"
#include "mcubes.h"
#include "tolppa.h"

#define XS 1024
#define YS 768
#define TEXTURES 8

void kukat1(double,GLint);
void kukat2(double,GLint);
void kukat3(double,GLint);
void halftone(double,double,GLint);
void piraali(double);

unsigned char *loadJPG(char *path,int *width,int *height);

int init(void);
void alku(double d,GLint);
void tausta(double d);
double get_time(void);

GLint   gl_names[TEXTURES];
static char moruuli[300000];

int main(int argc,char *argv[])
{
    int quit=0,n,flags=SDL_OPENGL|SDL_HWSURFACE|SDL_FULLSCREEN|SDL_DOUBLEBUF;
    SDL_Event   e;
    double  mp=0,oldtimer=0.0,oldtimer2=0.0,oldtimer3=0.0,d;

    if(argc==2 && !strcmp(argv[1],"-w"))
        flags-=SDL_FULLSCREEN;

    SDL_Init(SDL_INIT_VIDEO);
    SDL_SetVideoMode(XS,YS,32,flags);
    SDL_ShowCursor(0);
   
    /* Skip the music dialog in init */
    ungetc('\n',stdin);
    ungetc('2',stdin);
    if(!init())
        return(1);

    glClearColor(0,0,0,0);
    glEnable(GL_TEXTURE_2D);

    mzx_start(50);
    while(mzx_position()<0 || mzx_position()>100) // Skip bug...
        ;
    get_time(); /* Start the timer */
    while(!quit)
    {
        mp=mzx_position();
        glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
        glMatrixMode(GL_PROJECTION);
        glLoadIdentity();
        glFrustum(-1.33,1.33, -1,1, 3,1000.0);
        glMatrixMode(GL_MODELVIEW);
        glLoadIdentity();
        glTranslatef(0,0,-3);

        if(mp>1860)
        {
            if(oldtimer==0.0)
                oldtimer=get_time();
            d=get_time()-oldtimer;
            d=1.0/(1+d*d*15);
            glViewport(XS/2-XS/2.0*d,YS/2-YS/2.0*d,XS*d,YS*d);
        }

        if(mp<400)
        {
            piraali(get_time());
            alku(get_time(),gl_names[5]);
        }

        if(mp>=900 && mp<1100)
        {
            glPushMatrix();
            glRotatef(45,0,0,1);
            glColor3f(0.6,0.0,0.8);
            halftone(get_time(),sin(get_time())/13.0-0.05,gl_names[TEXTURES-1]);
            glColor3f(1,1,1);
            glPopMatrix();

            glPushMatrix();
            glTranslatef(0,0,-28);
            glDisable(GL_TEXTURE_2D);
            glEnable(GL_DEPTH_TEST);
            mc_update(get_time()/3);
            mc_drawCubes(get_time()*2);
            glEnable(GL_TEXTURE_2D);
            glDisable(GL_DEPTH_TEST);
            glPopMatrix();
            kukat2(get_time(),gl_names[4]);
        }

        if(mp>=1300 && mp<1500)
        {
            glColor3f(0.6,0,0.6);
            halftone(get_time(),sin(get_time())/10.0,gl_names[TEXTURES-1]);
            glPushMatrix();
            glDisable(GL_TEXTURE_2D);
            glEnable(GL_DEPTH_TEST);
            t_update(get_time());
            glTranslatef(-3,0,0);
            t_draw(get_time()*2);
            glDisable(GL_DEPTH_TEST);
            glEnable(GL_TEXTURE_2D);
            glPopMatrix();
            glColor3f(0.7,0,0.7);
            halftone(get_time(),sin(get_time())/20.0-0.1,gl_names[TEXTURES-1]);
            kukat1(get_time(),gl_names[2]);
        }

        if(mp>=1500)
        {
            piraali(get_time());
            if(mp>=1600)
                glClear(GL_DEPTH_BUFFER_BIT);
    
            glPushMatrix();
            glTranslatef(0,0,-12);
            glDisable(GL_TEXTURE_2D);
            glEnable(GL_DEPTH_TEST);
            mc_update(get_time()/7.0);
            mc_drawBoxes(get_time()*2.0);
            glEnable(GL_TEXTURE_2D);
            glDisable(GL_DEPTH_TEST);
            glPopMatrix();

            kukat2(10000-get_time(),gl_names[4]);
        }

        tausta(get_time());

        if(mp>=700 && mp<900)
        {
            kukat1(get_time(),gl_names[2]);
            glRotatef(sin(get_time())*20,0,1,0);
            glRotatef(cos(get_time())*5,1,0,0);
            kukat3(get_time(),gl_names[2]);
        }
        if(mp>=900 && mp<1100)
            kukat2(get_time(),gl_names[4]);
        if(mp>=1100 && mp<1300)
        {
            if(oldtimer3==0.0)
                oldtimer3=get_time();
            d=get_time()-oldtimer3;
            alku(d*1.5,gl_names[6]);

            glRotatef(sin(get_time())*20,0,1,0);
            glRotatef(cos(get_time())*5,1,0,0);
            kukat3(get_time(),gl_names[4]);
        }

        if(mp>=600 && mp<700)
        {
            if(oldtimer2==0.0)
                oldtimer2=get_time();
            d=get_time()-oldtimer2;
            glColor3f(0,0,0);
            halftone(get_time(),d/3.0-0.5,gl_names[TEXTURES-1]);
        }

        if(mzx_position()>1920)
            quit++;

        SDL_GL_SwapBuffers();
        while(SDL_PollEvent(&e)>0)
            if(e.type==SDL_MOUSEBUTTONDOWN || e.type==SDL_QUIT)
                quit++;
    }

    SDL_Quit();
    return(0);
}

init()
{
    double  dx,dy;
    int x,y,n,i;
    GLenum  tyyppo;
    unsigned char   *data,tmp;
    static unsigned char    ympara[256*256*4];
    char    *pix[]={"data/funkka.jpg","data/funker.jpg","data/70skugga.jpg",
                    "data/fungiite.jpg","data/tahti.jpg","data/tekstit.jpg",
                    "data/miehet.jpg"};
    FILE    *fp;

    glGenTextures(TEXTURES,gl_names);
    glPixelStorei(GL_UNPACK_ALIGNMENT,1);
    
    for(n=0;n<TEXTURES;n++)
    {
        if(n!=TEXTURES-1)
        {
            data=loadJPG(pix[n],&x,&y);
            tyyppo=GL_RGB;
        }
        else
        {
            for(y=0;y<256;y++)
                for(x=0;x<256;x++)
                {
                    dx=x-128;
                    dy=y-128;
                    tmp=sqrt(dx*dx+dy*dy);
                    if(tmp<120)
                        tmp=255;
                    else
                        tmp=0;
                    ympara[y*256*4+x*4]=ympara[y*256*4+x*4+1]=
                    ympara[y*256*4+x*4+2]=0xff;
                    ympara[y*256*4+x*4+3]=tmp;
                }

            data=ympara;
            x=256;
            y=256;
            tyyppo=GL_RGBA;
        }
        glBindTexture(GL_TEXTURE_2D,gl_names[n]);
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_REPEAT);

        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);

        glTexImage2D(GL_TEXTURE_2D,0,tyyppo,x,y,0,tyyppo,GL_UNSIGNED_BYTE,data);
    }

    /* Here's little something that tries to prevent an odd ATI/SDL/OSX bug */
    for(n=0;n<TEXTURES;n++)
    {
        glEnable(GL_TEXTURE_2D);
        glBindTexture(GL_TEXTURE_2D,gl_names[n]);
        glBegin(GL_POLYGON);
            glTexCoord2f(0,1);
            glVertex2f(-1,-1);
            glTexCoord2f(1,1);  
            glVertex2f(1,-1);
            glTexCoord2f(1,0);
            glVertex2f(1,1);
            glTexCoord2f(0,0);
            glVertex2f(-1,1);
        glEnd();
    }

    fp=fopen("data/funkyfit.mod","rb");
    if(fp==NULL)
        return(0);
    fread(moruuli,1,300000,fp);
    fclose(fp);
    mzx_init();
    mzx_get(moruuli);

    mc_init();
    t_init();

    return(1);
}

void alku(double tid,GLint tegsture)
{
    int n;
    double  tc1,tc2,tmp,d;

    glEnable(GL_BLEND);
    glEnable(GL_TEXTURE_2D);
    glBlendFunc(GL_ONE,GL_ONE);
    glPushMatrix();
    glBindTexture(GL_TEXTURE_2D,tegsture);
    tmp=-10+get_time()/2.0;
    glTranslatef(0,0.7,0);
    for(n=0;n<4;n++)
    {
        glPushMatrix();
        tc1=n/4.0;
        tc2=(n+1)/4.0;
        if(tid/4>=n)
        {
            d=tid/4-(double)n;
            glTranslatef(0,cos(d*10.0)*(20.0/(20.0*(0.5+d)*(0.5+d))),0);
            glBegin(GL_POLYGON);
                glTexCoord2f(0,tc2);
                glVertex2f(-1,-0.25);
                glTexCoord2f(1,tc2);
                glVertex2f(1,-0.25);
                glTexCoord2f(1,tc1);
                glVertex2f(1,0.25);
                glTexCoord2f(0,tc1);
                glVertex2f(-1,0.25);
            glEnd();
        }

        glPopMatrix();
        glTranslatef(0,-0.48,0);
    }
    glDisable(GL_BLEND);
    glPopMatrix();
}

void tausta(double d)
{
    double  tmp,kerri=0.8;
    static double   efektsi=0,kukkane=0,suunta=1;
    int     n,pos=mzx_position()/100,mp=mzx_position();
    static int  uvat=0,
            kuvapaikat[20]=
            {-1,-1,-1,-1, 3,3,3,0, 0,-1,-1,1, 1,-1,-1,-1, -1,-1,-1,-1},
            torvi[]=
            {100,200,232,300,332,400,416,432,448,500,512,524,600,800,816,832,
             848,900,916,932,948,1000,1016,1032,1048,1300,1316,1332,1348,
             1400,1416,1432,1448,1600,1616,1632,1648,1700,1716,1732,1748,
             1800,1816,1832,1848,-1},
            isku[]=
            {400,407,409,416,427, 432,439,441,448,
             500,507,509,516,527,
             700,716,732,748, 800,816,832,848,
             900,916,932,948, 1000,1016,1032,1048,
             1100,1116,1132,1148, 1200,1216,1232,1248,
             1300,1316,1332,1348, 1400,1416,1432,1448,
             1500,1516,1532,1548, 1600,1616,1632,1748,
             1700,1716,1732,1748, 1800,1816,1832,1848, -1};

    if(pos<0 || pos>19)
        return;

    glPushMatrix();
    glEnable(GL_TEXTURE_2D);

    for(n=0;isku[n]!=-1;n++)
    {
        if(mp==isku[n])
        {
            efektsi=get_time();
            suunta=-suunta;
        }
    }

    for(n=0;torvi[n]!=-1;n++)
    {
        if(mp==torvi[n] && kukkane<=0)
        {
            kukkane=get_time();
            uvat=1-uvat;
        }
    }

    if(efektsi>0)
    {
        kerri=1;
        tmp=get_time()-efektsi;
        if(tmp>0.2)
        {
            glScalef(1.33,1.33,0);
            efektsi=0;
        }
        else
        {
            tmp-=0.1;
            tmp*=tmp;
            tmp=0.01-tmp;
            tmp*=15.0;
            glRotatef(5.0*suunta*tmp,0,0,1);
            glScalef(1.33+tmp,1.33+tmp,0);
        }
    }
    else
        glScalef(1.33,1.33,0);

    if(kuvapaikat[pos]!=-1)
    {
        glBindTexture(GL_TEXTURE_2D,gl_names[kuvapaikat[pos]]);
        glColor3f(kerri,kerri,kerri);
        glBegin(GL_POLYGON);
            glTexCoord2f(0,1);
            glVertex2f(-1,-1);
            glTexCoord2f(1,1);
            glVertex2f(1,-1);
            glTexCoord2f(1,0);
            glVertex2f(1,1);
            glTexCoord2f(0,0);
            glVertex2f(-1,1);
        glEnd();
    }
    glPopMatrix();

    if(kukkane>0)
    {
        glBindTexture(GL_TEXTURE_2D,gl_names[(uvat)?4:2]);
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_COLOR,GL_ONE);
        glPushMatrix();
        glColor3f(1,1,1);
        tmp=get_time()-kukkane;
        if(tmp>0.6)
        {
            glScalef(0,0,0);
            kukkane=0;
        }
        else
        {
            tmp-=0.3;
            tmp*=tmp;
            tmp=0.09-tmp;
            tmp*=20.0;
            glRotatef(140.0*(get_time()-kukkane),0,0,1);
            glScalef(tmp,tmp,0);
        }
        glBegin(GL_POLYGON);
            glTexCoord2f(0,1);
            glVertex2f(-1,-1);
            glTexCoord2f(1,1);
            glVertex2f(1,-1);
            glTexCoord2f(1,0);
            glVertex2f(1,1);
            glTexCoord2f(0,0);
            glVertex2f(-1,1);
        glEnd();

        glDisable(GL_BLEND);
        glPopMatrix();
    }
    glColor3f(1,1,1);
}

#define ASK 30.0
#define PAXUUS 0.2
#define LEVEYS 0.2
void piraali(double tid)
{
    double  d,dp,r=0,dx,dy,phase;
    int     n;

    glPushMatrix();
    glTranslatef(0,0,-2);
    glRotatef(sin(tid)*20,0,1,0);
    glRotatef(cos(tid*2),1,0,0);
    glDisable(GL_CULL_FACE);
    glEnable(GL_DEPTH_TEST);
    glDisable(GL_TEXTURE_2D);

    for(phase=0;phase<5;phase++)
    {
        glPushMatrix();
        if(phase==0)
            glColor3f(0.8,0,0.8);
        if(phase==1 || phase==2)
            glColor3f(0.6,0,0.6);
        if(phase==3 || phase==4)
        {
            glDisable(GL_DEPTH_TEST);
            glLineWidth(2.0);
            glColor3f(0,0,0);
        }
        for(n=0,r=0;n<10;n++,r+=2*LEVEYS)
        {
            dx=cos(tid*4+n/2.0)*LEVEYS*2.0;
            dy=sin(tid*4+n/2.0)*LEVEYS*2.0;
            if(phase<3)
                glBegin(GL_TRIANGLE_STRIP);
            else
                glBegin(GL_LINE_STRIP);
            for(d=0;d<=2.0*M_PI+0.2;d+=M_PI*2.0/(double)ASK)
            {
                dp=d+M_PI*2.0/ASK;
                if(phase==0)
                {
                    glVertex3f(sin(d)*r+dx,cos(d)*r+dy,PAXUUS);
                    glVertex3f(sin(d)*(r+LEVEYS)+dx,cos(d)*(r+LEVEYS)+dy,PAXUUS);
                }
                if(phase==1)
                {
                    glVertex3f(sin(d)*r+dx,cos(d)*r+dy,-PAXUUS);
                    glVertex3f(sin(d)*r+dx,cos(d)*r+dy,PAXUUS);
                }
                if(phase==2)
                {
                    glVertex3f(sin(d)*(r+LEVEYS)+dx,cos(d)*(r+LEVEYS)+dy,-PAXUUS);
                    glVertex3f(sin(d)*(r+LEVEYS)+dx,cos(d)*(r+LEVEYS)+dy,PAXUUS);
                }
                if(phase==3)
                    glVertex3f(sin(d)*(r+LEVEYS)+dx,cos(d)*(r+LEVEYS)+dy,PAXUUS);
                if(phase==4)
                    glVertex3f(sin(d)*r+dx,cos(d)*r+dy,PAXUUS);
            }
            glEnd();
        }
        glPopMatrix();
    }
    
    glDisable(GL_DEPTH_TEST);
    glPopMatrix();
    glColor3f(1,1,1);
}

double get_time(void)
{
    static int tiksi=-1,tid;
    
    if(tiksi==-1)
        tiksi=SDL_GetTicks();
    tid=SDL_GetTicks()-tiksi;

    return(((double)tid)/1000.0);
}
