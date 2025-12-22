
#include "stiks.h"
#include <math.h>
#include <SDL_opengl.h>
#include <stdlib.h>

#define MAXLEVEL 5
#define SPLIT 2

/* Do NOT do lists like this */
#define LIST_BALL 7
#define LIST_STAR 8

void stiks_init(int pink)
{
    int i;
    double  d;

    glNewList(LIST_BALL,GL_COMPILE);
    glColor3f(0,0,0);
    glBegin(GL_TRIANGLE_FAN);
    glVertex3f(0,0,0.01);
    d=0.2;
    for(i=0;i<21;i++)
        glVertex3f(cos(i*M_PI/10)*d,sin(i*M_PI/10)*d,0.01);
    glEnd();
    glEndList();

    glNewList(LIST_STAR,GL_COMPILE);
    glColor3f(1,1,1);
    glBegin(GL_QUAD_STRIP);
    if(pink)
        for(i=0;i<91;i++)
        {
            glVertex3f(0,0,0.01);
            d=fabs(sin(i/(9/M_PI)))/6.0+0.3;
            glVertex3f(cos(i*M_PI/45)*d,sin(i*M_PI/45)*d,0);
        }
    else
        for(i=0;i<31;i++)
        {
            glVertex3f(0,0,0.01);
            if(i&1)
                d=0.5;
            else
                d=0.3;
            glVertex3f(cos(i*M_PI/15)*d,sin(i*M_PI/15)*d,0);
        }
    glEnd();
    glEndList();
}

void transform(double *x,double *y,double *z,int tid)
{
    double d,tx,tz;

    d=tid/1200.0;
    tx=cos(d)*(*x)+sin(d)*(*z);
    tz=cos(d)*(*z)-sin(d)*(*x);
    *x=tx;
    *z=tz;
    *y+=sin(tz*2)/4.0+sin(tx*2)/4.0;
}

void rekursio(int run,int level,double px,double py,double pz,int tid)
{
    int n;
    double  x,y,z,d,d2,dy,dx,tx,ty,tz;
    double  dex,dey,dez,lx,ly,lz;

    x=px;y=py;z=pz;
    x+=(rand()%4-1.5)/2.0;
    y+=(rand()%4-1.5)/1.5;
    z+=(rand()%4-1.5)/2.0;
    tx=x; ty=y; tz=z;
    d2=tid/800.0*((level&1)?-1:1);

    transform(&x,&y,&z,tid);
    transform(&px,&py,&pz,tid);

    if(run==0)
    {
        glPushMatrix();
        glTranslatef(px,py,pz);
        glRotatef(d2*80,0,0,1);
        glCallList(LIST_STAR);
        glPopMatrix();
    }

    if(run==1)
    {
        glPushMatrix();
        glTranslatef(px,py,pz);
        glCallList(LIST_BALL);
        glPopMatrix();

        if(level!=MAXLEVEL)
        {
            glColor3f(0,0,0);
            dx=px-x;
            dy=py-y;
            if(dx==0 && dy==0)
                goto nogo;
    
            d=dx;
            dx=-dy;
            dy=d;
            d=sqrt(dx*dx+dy*dy);
            dx=dx/d*0.05;
            dy=dy/d*0.05;
    
            /*glBegin(GL_QUADS);
            glVertex3f(x-dx,y-dy,z);
            glVertex3f(x+dx,y+dy,z);
            glVertex3f(px+dx,py+dy,pz);
            glVertex3f(px-dx,py-dy,pz);
            glEnd();*/
            
            dex=(px-x)/20.0;
            dey=(py-y)/20.0;
            dez=(pz-z)/20.0;

            d=1.8+sin(tid/1000.0+level)/2.0;
            lx=dex*d;
            ly=dey*d;
            lz=dez*d;

            d=fmod(tid/100.0,2);
            x+=dex*d;y+=dey*d;z+=dez*d;

            for(n=0;n<10;n++)
            {
                glBegin(GL_QUADS);
                glVertex3f(x-dx,y-dy,z);
                glVertex3f(x+dx,y+dy,z);
                glVertex3f(x+lx+dx,y+ly+dy,z+lz);
                glVertex3f(x+lx-dx,y+ly-dy,z+lz);
                glEnd();
                x+=dex*2;y+=dey*2;z+=dez*2;
            }
    
            nogo:;
        }
    }

    if(level!=MAXLEVEL)
        for(n=0;n<SPLIT;n++)
            rekursio(run,level+1,tx,ty,tz,tid);
}

void stiks(int tid,int seed)
{
    srand(seed);
    glDisable(GL_CULL_FACE);
    rekursio(0,0, 0.1,0,0, tid);
    srand(seed);
    rekursio(1,0, 0.1,0,0, tid);
    //glEnable(GL_CULL_FACE);
}
