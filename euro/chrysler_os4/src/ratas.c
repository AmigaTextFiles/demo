
#include <math.h>
#include "ratas.h"

#ifndef M_PI
#define M_PI 3.1415192
#endif

#define XS 320
#define YS 192

unsigned char mask[64*64];
extern unsigned char *ratas;

void ratas_osa(char *buf,int phase,int rot)
{
    double  d,d2,vuoro;
    int n;

    vuoro=cos(phase/20.0)*300/(1.0+phase/2.0);

    dratas(buf,160,96+vuoro,rot/50.0);
    for(n=0;n<5;n++)
    {
        if(phase<(n+1)*25)
            continue;
        vuoro=-cos((phase-(n+1)*25)/20.0)*600/(1.0+(phase-(n+1)*25)/2.0);

        d=n*M_PI*2.0/5;
        d2=-d;
        dratas(buf,160+cos(d)*60,96+sin(d)*60+vuoro,
               -d2-rot/50.0+2.0*M_PI/40);
    }

    for(n=0;n<5;n++)
    {
        if(phase<(n+6)*25)
            continue;
        vuoro=cos((phase-(n+6)*25)/20.0)*600/(1.0+(phase-(n+6)*25)/2.0);

        d=n*M_PI*2.0/5;
        d2=-d;
        dratas(buf,160+cos(d)*120,96+sin(d)*120+vuoro,
               d2+rot/50.0+2.0*M_PI/40);
    }
}

void ratas_init(void)
{
    int x,y,dx,dy;

    for(y=0;y<64;y++)
        for(x=0;x<64;x++)
        {
            dx=x-32;
            dy=y-32;
            if(dx*dx+dy*dy>32*32)
                mask[y*64+x]=0;
            else
                mask[y*64+x]=1;
        }
}

void dratas(unsigned char *buf,int x,int y,double kul)
{
    int     px,py,i,tx,ty,dx,dy,ind,juu=0,
            sx,sy,sdx,sdy;
    float   a[3],b[3];

    a[0]=128+180.0*sin(kul-M_PI/2.0);
    a[1]=128+180.0*sin(kul);
    a[2]=256-a[0];
    b[0]=128+180.0*cos(kul-M_PI/2.0);
    b[1]=128+180.0*cos(kul);
    b[2]=256-b[0];

    sx=b[1]*65536;
    sy=a[1]*65536;
    sdx=(b[2]-b[1])/64.0*65535;
    sdy=(a[2]-a[1])/64.0*65535;

    dx=(b[0]-b[1])/64.0*65536;
    dy=(a[0]-a[1])/64.0*65536;

    for(py=y-32;py<y+32;py++,sx+=sdx,sy+=sdy)
    {
        if(py<0 || py>=YS)
        {
            juu+=64;
            continue;
        }

        i=py*XS+x-32;
        tx=sx;
        ty=sy;
    
        for(px=x-32;px<x+32;px++,i++)
        {
            if(mask[juu++])
            {
                ind=((ty>>16)<<8)+(tx>>16);
                if(ratas[ind])
                    buf[i]|=ratas[ind];
            }
            tx+=dx;
            ty+=dy;
        }
    }
}
