
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define LEV 	6       // 2^...
#define KOR 	47
#define N 	5

static void stripes_install(unsigned char *buf, unsigned char *stripe, int xoff, int yoff, int r1, int r2, int p);

extern unsigned *kooste;
// static unsigned char kostea[7*64*47];

static int plaset[5]={1,2,4,5,6};

/*void stripes_init()
{
    FILE *f;
    int n;

    f=fopen("kooste.raw", "rb");

    fread(kostea,7*64*47,1,f);
    
    for(n=0; n<7*64*47; n++)
        kooste[n]=kostea[n]*0x01010101;
}*/

void stripes_osa(unsigned char *pbuf, int n)
{
    static int p=0, r1=1,r2=1;
    static tmp=0;

    p++;
    if(p == 48)
    {
        r1=rand()%5;
        r2=rand()%7;
    }
    else if(p > 47+rand()%2000)
        p=0;

    tmp=n;

    stripes_install(pbuf, kooste, tmp, 140+30*sin(2*3.1415*n/400), r1, r2, p);
}

void stripes_install(unsigned char *buf, unsigned char *stripe, int xoff, int yoff, int r1, int r2, int p)
{
    int i,j,k, xx,xxx,xx2, t;

    yoff *= 320;

    if(p == 47)
    {
        plaset[r1]=r2;
    }

    for(i=0; i<N; i++)
    {
        xx=plaset[i] << LEV;
        xxx=((i<<LEV)+xoff)%320;

        if(!p || p>=47 || i!=r1)
        {
            if(xxx < (N-1)*(1<<LEV))
                for(j=k=0; j<KOR; j++,k+=320)
                {
                    memcpy(buf+xxx+yoff+k,stripe+xx+j*448,1<<(LEV));
                }
            else
                for(j=k=0; j<KOR; j++,k+=320)
                {
                    t=N*(1<<LEV)-xxx;
                    memcpy(buf+xxx+yoff+k,stripe+xx+j*448,t);
                    memcpy(buf+yoff+k,stripe+xx+j*448+t,((1<<LEV)-t));
                }
        }
        else
        {
            xx2=(r2<<LEV)+(47-p)*448;

            if(xxx < (N-1)*(1<<LEV))
                for(j=k=0; j<KOR; j++,k+=320)
                {
                    if(j >= p)
                        memcpy(buf+xxx+yoff+k,stripe+xx+(j-p)*448,1<<(LEV));
                    else
                        memcpy(buf+xxx+yoff+k,stripe+xx2+j*448,1<<(LEV));
                }
            else
                for(j=k=0; j<KOR; j++,k+=320)
                {
                    t=N*(1<<LEV)-xxx;

                    if(j >= p)
                    {
                        memcpy(buf+xxx+yoff+k,stripe+xx+(j-p)*448,t);
                        memcpy(buf+yoff+k,stripe+xx+(j-p)*448+t,((1<<LEV)-t));
                    }
                    else
                    {
                        memcpy(buf+xxx+yoff+k,stripe+xx2+j*448,t);
                        memcpy(buf+yoff+k,stripe+xx2+j*448+t,((1<<LEV)-t));
                    }
                }
        }
    }
}

/* EOS */
