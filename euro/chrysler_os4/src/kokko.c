#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>

#ifdef AMIGA
#define M_PI 3.1415927
#endif

// size of the screen
#define AW 320
#define AH 192

// color
#define COLORS 256

#define F 0.9

static unsigned char old_screen[AW*AH];
unsigned char kerto_taulu1[256*256];
unsigned char kerto_taulu2[256*256];
unsigned char kerto_taulu3[256*256];
int kertaa_320[256];

void zoom(char * dest, char * src, int w, int h, int zoox, int zooy, int rotate);

void init_filter() {
    int x,y,a;

    for (y=0; y<256; y++)
	for (x=0; x<256; x++) {
	    a=50*x/100+50*y/100;
	    if (a>255)
                a=255;
	    kerto_taulu2[y*256+x]=a;

	    a=20*x/100+90*y/100;
	    if (a>255)
                a=255;
	    kerto_taulu1[y*256+x]=a;

	    a=10*x/100+90*y/100;
	    if (a>255)
                a=255;
	    kerto_taulu3[y*256+x]=a;
	}

    for (y=0; y<256; y++)
	kertaa_320[y]=320*y;

}

void filter_kokko(unsigned char * buffer, int vbl, int distance, int angle, int mode) {
    int x,y,a,a2;
    static int first=1;
    unsigned char * src, * dst;
    char * k;

    if (first) {
#ifndef AMIGA
	init_filter();
#endif
	memset(old_screen,0,sizeof(old_screen));
	first=0;

    }

    if (mode==0) {
        k=kerto_taulu1;
    } else if (mode==1) {
        k=kerto_taulu2;
    } else {
        k=kerto_taulu3;
    }


    dst=buffer;
    src=old_screen;

    for (y=0; y<AH; y++)
	for (x=0; x<AW; x++) {
	    *dst=k[((*src) << 8) + (*dst)];
	    dst++;
            src++;
	}

    zoom(old_screen,buffer,AW,AH,distance,distance,angle);

    /*
    for (y=0; y<AH; y++)
	for (x=0; x<AW; x++) {
	    a=buffer[y*AW+x];
	    a2=(a-24*7)*16;
	    if (a2>255)
		a2=255;
	    if (a2<0)
                a2=0;
	    buffer[y*AW+x]=a2;
	    }
            */
}



void zoom(char * dest, char * src, int w, int h, int zoox, int zooy, int rotate) {
#define EI 64
    int x,y;
    int ky;
    int sx1,sy1,sx2,sy2;
    int dx1,dy1,dx2,dy2;
    unsigned char * dst;

    dx2=cos(rotate*2*M_PI/360)*zoox;
    dy2=-sin(rotate*2*M_PI/360)*zooy;

    dx1=sin(rotate*2*M_PI/360)*zoox;
    dy1=cos(rotate*2*M_PI/360)*zooy;

    sy1=(120 << 8)-160*dy2;
    sy1-=120*dy1;
    sx1=(160 << 8)-160*dx2;
    sx1-=120*dx1;

    dst=dest;

    for (y=0; y<h; y++) {
	sx2=sx1;
        sy2=sy1;
	for (x=0; x<w; x++) {
	    if ((sy2>0) && (sy2<(192*256)))
		*dst=src[kertaa_320[sy2 >> 8]+(sx2 >> 8)];
            dst++;
	    sx2+=dx2;
            sy2+=dy2;
	}
	sy1+=dy1;
        sx1+=dx1;
    }

    /*
    for (y=96-EI; y<96+EI; y++)
	for (x=160-EI; x<160+EI; x++)
	dst[y*320+x]=src[y*320+x];
        */

}
