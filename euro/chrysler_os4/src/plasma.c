#include <math.h>

#ifdef AMIGA
#define M_PI 3.1415927
#endif

// size of the screen
#define AW 320
#define AH 192

// color
#define COLORS 256

int sin_table[256];

void init_plasma() {
    int y;
    for (y=0; y<256; y++)
	sin_table[y]=sin(y*17*M_PI/256)*31+cos(y*14*M_PI/256)*31+63;
}

void plasma(unsigned char * buffer, int vbl) {
    int x,y,a2,a,a3;
    int first=1;
    int p1,p2;
    int op1,op2;
    unsigned char c;
    unsigned char * dst;
#ifndef AMIGA
    if (first) {
        init_plasma();
        first=0;
    }
#endif
    a=(sin(vbl*0.01*2)*205+205)*2;
    a2=(sin(vbl*0.025*2)*114+114)*2;
    a3=(sin(vbl*0.025*2)*11+11)*2;

    p1=(vbl*2) << 8;
    p2=vbl << 8;
    dst=buffer;
    for (y=0; y<(AH/2); y++) {
	op1=p1;
        op2=p2;
	for (x=0; x<160; x++) {
            c=sin_table[(p1 >> 8) & 0xFF]+
		sin_table[(p2 >> 8) & 0xFF];
	    *dst++=c;
            *(dst+319)=c;
	    *dst++=c;
            *(dst+319)=c;
	    p1+=a3;
            p2+=a;
	}
	p1=op1;
	p2=op2;

	p1+=256*2;
	p2+=a2;
        dst+=320;
    }

}
