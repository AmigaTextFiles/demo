#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>

// size of the screen
#define AW 320
#define AH 192

// color
#define COLORS 256

#define NOF_VIDEOS 7

int nof_frames[NOF_VIDEOS]={
    80,80,40,40,40,40,40
};

int frame[NOF_VIDEOS]={0,0,0,0,0,0,0};
int spd[NOF_VIDEOS]={1,1,1,1,1,1,1};
int dir[NOF_VIDEOS]={1,1,1,1,1,1,1};

extern unsigned char * dd;
extern unsigned char * onnettomuus;
extern unsigned char * na_eka;
extern unsigned char * na_toka;
extern unsigned char * paa;
extern unsigned char * siunaus;
extern unsigned char * ukko;

unsigned char * make_bitti_muunnos();

void draw_video(unsigned char * buffer, int vbl, int no, int loop, int start, int dt) {
    int x,y,xx;

//    static int o_vbl=0;
    static int loaded=0;
    int * ip1, * ip2;

    int * dst;
    int src;

    static unsigned char * bitti_muunnos;
    unsigned char * video;

  //  int dt;

    if (start==1) {
	dir[no]=1;
	//frame[no]-=15;
        frame[no]=0;
	if (frame[no]<0)
            frame[no]=0;
    }

    if (start==3) {
	dir[no]=1;
	frame[no]+=15;
	if (frame[no]>=nof_frames[no])
            frame[no]=nof_frames[no]-1;
    }
    if (start==2) {
        dir[no]*=-1;
    }

//    dt=vbl-o_vbl;
    frame[no]+=dir[no]*spd[no]*dt;

    if (frame[no]<0) {
	dir[no]=+1;
	frame[no]+=2*dir[no]*spd[no]*dt;
    }

    if (frame[no]>=nof_frames[no]) {
        if (loop==0)
	    frame[no]-=nof_frames[no];
	else {

	    dir[no]=-1;
	    frame[no]+=2*dir[no]*spd[no]*dt;
	}
    }

//    o_vbl=vbl;
    if (!bitti_muunnos) {
        bitti_muunnos=make_bitti_muunnos();
    }

    switch (no) {
    case 0:
        video=dd;
	break;
    case 1:
        video=onnettomuus;
        break;
    case 2:
        video=na_eka;
        break;
    case 3:
        video=na_toka;
        break;
    case 4:
        video=paa;
	break;
    case 5:
        video=siunaus;
	break;
    case 6:
        video=ukko;
	break;

    }

    src=frame[no]*40*200;
    dst =buffer;

    for (y=0; y<AH; y++)
	for (x=0; x<(AW/8); x++) {
	    ip1=bitti_muunnos+video[src]*8;
	    *dst++ = *ip1++;
	    *dst++ = *ip1++;
            src++;
	}


}

unsigned char * make_bitti_muunnos() {
    unsigned char * bitti_muunnos;
    int y;

    bitti_muunnos=(char *)malloc(256*8);
    memset(bitti_muunnos,0,256*8);
    for (y=0; y<256; y++) {
	if ((y & 1)!=0)
	    bitti_muunnos[y*8+0]=COLORS-1;
	if ((y & 2)!=0)
	    bitti_muunnos[y*8+1]=COLORS-1;
	if ((y & 4)!=0)
	    bitti_muunnos[y*8+2]=COLORS-1;
	if ((y & 8)!=0)
	    bitti_muunnos[y*8+3]=COLORS-1;
	if ((y & 16)!=0)
	    bitti_muunnos[y*8+4]=COLORS-1;
	if ((y & 32)!=0)
	    bitti_muunnos[y*8+5]=COLORS-1;
	if ((y & 64)!=0)
	    bitti_muunnos[y*8+6]=COLORS-1;
	if ((y & 128)!=0)
	    bitti_muunnos[y*8+7]=COLORS-1;

    }

    return bitti_muunnos;
}
