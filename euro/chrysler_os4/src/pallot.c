#include <math.h>
#include <stdlib.h>
#include <stdio.h>

#ifndef M_PI
#define M_PI 3.1415927
#endif

// size of the screen
#define AW 320
#define AH 192

// color
#define COLORS 256

#define CHAR_SIZE 8
#define NOF_BALLS 16
#define NOF_SMOOTH 16

unsigned char balls[16*16*16*16];

#define BX (AW/CHAR_SIZE)
#define BY (AH/CHAR_SIZE)

unsigned char ball_scr[BX*BY];

#include "kirjaimet2.h"

void generate_balls();
void ball_to_scr();

void init_pallot() {
    generate_balls();
}

void kirjain(unsigned char * buffer, int kirjain, int opacity, int zoom, int yd) {
    int sx,sy,osx;
    int x,y,yp;
    sy=(12 << 8)-12*zoom;
    sx=(18 << 8)-18*zoom-4*256;

    for (y=0; y<24; y++) {
        yp=(y+yd) % 24;
	osx=sx;
	for (x=0; x<40; x++) {
	    if ((sy>=0) && (sy<24*256) && (sx>=0) && (sx<32*256)) {
		buffer[yp*40+x]+=((kirjaimet2.pixel_data[((sy & 0xFF00)+(sx >> 8)+kirjain*32)*3] >> 4)*opacity) >> 8;
		if (buffer[yp*40+x]>15)
                    buffer[yp*40+x]=15;
	    }

	    //	    buffer[y*40+x]=kirjaimet2.pixel_data[(y*256+x)*3] >> 4;
            sx+=zoom;
	}
	sx=osx;
        sy+=zoom;
    }

}

void pallot(unsigned char * buffer, int vbl,int sx, int sy, int ra, int spd) {
    int x,y;
    int xx,yy,a;
    int yp;
    int p1,pos1,l1;
#define FADE 384
    memset(&ball_scr[0],0,BX*BY);

    for (y=0; y<(24/sy); y++)
	for (x=0; x<(40/sx); x++) {
            a=rand() % ra;

	    for (xx=0; xx<sx; xx++)
		for (yy=0; yy<sy; yy++) {
		    ball_scr[(y*sy+yy)*40+(x*sx+xx)]=a;
		}
	}

    //    yp=sin(vbl*0.1)*12+12;
    yp=0;
    p1=1023-(vbl*spd+256) % 1023;
    l1=((vbl*spd+256)/1024+1) % 8;

    pos1=sin(p1*4.0*M_PI/1024)*156+202;

    if (pos1>0) {
	if (p1<FADE)
	    kirjain(&ball_scr[0],l1,(256*p1/FADE),pos1,yp);
	else if (p1>(1023-FADE))
	    kirjain(&ball_scr[0],l1,(1023-p1)*256/FADE,pos1,yp);
	else
	    kirjain(&ball_scr[0],l1,255,pos1,yp);
    }
    p1=1023-(vbl*spd) % 1023;
    l1=(vbl*spd)/1024 % 8;

    pos1=sin(p1*4.0*M_PI/1024)*156+202;

    if (pos1>0) {
	if (p1<FADE)
	    kirjain(&ball_scr[0],l1,(256*p1/FADE),pos1,yp);
	else if (p1>(1023-FADE))
	    kirjain(&ball_scr[0],l1,(1023-p1)*256/FADE,pos1,yp);
	else
	    kirjain(&ball_scr[0],l1,255,pos1,yp);
    }


    /*
    for (y=0; y<BY; y++)
	for (x=0; x<32; x++) {
	    a1=kirjaimet2.pixel_data[(y*256+x+(vbl/v % nof_kirjaimet)*32)*3]/16;
	    a2=kirjaimet2.pixel_data[(y*256+x+((vbl/v+1) % nof_kirjaimet)*32)*3]/16;
	    ff=(float)(vbl % v)/v;
	    ball_scr[y*BX+x]=(int)(a2*ff+(1.0-ff)*a1);
	}
      */
    ball_to_scr(buffer);
}


void ball_to_scr(unsigned char * buffer) {
    int x,y,a1,a2,yy;
    int * dst;
    unsigned char * src;
    int c;
    int * ip;
    dst=(int *)buffer;
    src=&ball_scr[0];

    for (y=0; y<BY; y++) {
	for (x=0; x<BX; x++) {
	    c=*(src++);
	    a1=c & 0xF0;
	    a2=c & 0x0F;
	    ip=(int *)balls+(((a1 << 6)+(a2 << 6)) >> 2);
	    for (yy=0; yy<8; yy++) {
		*(dst++)=*(ip++);
		*(dst++)=*(ip++);
		dst+=(312/4);
	    }
	    dst-=8*(320/4)-2;
	}

	dst+=8*(320/4)-320/4;

    }
    /*
    for (y=0; y<BY; y++)
	for (x=0; x<BX; x++) {
	    a1=ball_scr[y*BX+x]/16;
            a2=ball_scr[y*BX+x] % 16;

	    for (yy=0; yy<CHAR_SIZE; yy++)
                for (xx=0; xx<CHAR_SIZE; xx++)
		    buffer[(y*CHAR_SIZE+yy)*AW+(x*CHAR_SIZE+xx)]=
			balls[a1*NOF_BALLS*CHAR_SIZE*CHAR_SIZE+a2*CHAR_SIZE*CHAR_SIZE+yy*CHAR_SIZE+xx];
	}
*/
}

void generate_balls() {
    int x,y,n,a,s;
    float r;
    float je;
    for (s=0; s<NOF_SMOOTH; s++) {
	for (n=0; n<NOF_BALLS; n++) {
	    for (y=0; y<CHAR_SIZE; y++) {
		for (x=0; x<CHAR_SIZE; x++) {
		    r=sqrt((y-CHAR_SIZE/2)*(y-CHAR_SIZE/2)+
			   (x-CHAR_SIZE/2)*(x-CHAR_SIZE/2));

                    je=1.1+s*0.1;
		    a=(float)(je-r/(CHAR_SIZE/2)-je*(float)(NOF_BALLS-n)/NOF_BALLS)*COLORS*(2.0);

		    if (a<0)
			a=0;
		    if (a>COLORS-1)
			a=COLORS-1;
		    balls[s*NOF_BALLS*CHAR_SIZE*CHAR_SIZE+n*CHAR_SIZE*CHAR_SIZE+y*CHAR_SIZE+x]=a;
		}
	    }
	}
    }
}
