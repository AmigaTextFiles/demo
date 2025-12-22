#ifdef UGLY_GL_HEADERS
#include <GL.h>
#else
#include <GL/gl.h>
#include <GL/glut.h>
#endif
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "tolppa.h"

#define TOLPPAKORKEUS 60

static float rotatet[TOLPPAKORKEUS];
static float yscale=0.5f;
static float xscale=5.0f;
static float zscale=5.0f;
static int kulmia=4;

void t_init() {
    int i;
    for(i=0; i<TOLPPAKORKEUS; i++) {
        rotatet[i]=0.0f;
    }
}
void t_update(float time) {
    int i;
    static float ff=0.0f;
    static float ff2=0.0f;
    ff+=0.003f;
    ff2+=0.005f;
    ff=time;
    ff2=time*1.05f;
    for(i=0; i<TOLPPAKORKEUS; i++) {
        rotatet[i]=(float)i*0.05f+ff+sin(ff2)+cos((float)(i)*0.2f+2.0f*sin(ff+sin(ff2)));
    }

}
void t_draw(float time) {
    int i,j;
    float r,r2;
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    glTranslatef(-3,-15,-20);


    for(i=0; i<TOLPPAKORKEUS-1; i++) {
	for(j=0; j<kulmia; j++) {
            glColor4f((float)i/TOLPPAKORKEUS,((float)i/TOLPPAKORKEUS)-((float)j/kulmia),(float)j/kulmia,1);
	    glBegin(GL_QUADS);
            r =((float)j/(float)kulmia)*3.141f*2.0f;//*3.1415926f*2.0f/360.0f;;
	    r2=(((float)j+1)/(float)kulmia)*3.141f*2.0f;//*3.1415926f*2.0f/360.0f;;
	    glVertex3f(xscale*sin(rotatet[i]+r)+sin(time+(float)i/5.0f),
		       i*yscale,
		       zscale*cos(rotatet[i]+r));
	    glVertex3f(xscale*sin(rotatet[i]+r2)+sin(time+(float)i/5.0f),
		       i*yscale,
		       zscale*cos(rotatet[i]+r2));
	    glVertex3f(xscale*sin(rotatet[i+1]+r2)+sin(time+(float)(i+1)/5.0f),
		       (i+1)*yscale,
		       zscale*cos(rotatet[i+1]+r2));
	    glVertex3f(xscale*sin(rotatet[i+1]+r)+sin(time+(float)(i+1)/5.0f),
		       (i+1)*yscale,
		       zscale*cos(rotatet[i+1]+r));
	    glEnd();
	    glColor4f(0,0,0,1);
            glLineWidth(2.0f);
            glBegin(GL_LINES);
	    glVertex3f((xscale+0.001f)*sin(rotatet[i]+r)+sin(time+(float)i/5.0f),
		       i*(yscale),
		       (zscale+0.001f)*cos(rotatet[i]+r)+0.01f);
	    glVertex3f((xscale+0.001f)*sin(rotatet[i+1]+r)+sin(time+(float)(i+1)/5.0f),
		       (i+1)*(yscale),
		       (zscale+0.001f)*cos(rotatet[i+1]+r)+0.01f);
	    glVertex3f((xscale+0.001f)*sin(rotatet[i]+r2)+sin(time+(float)i/5.0f),
		       i*(yscale),
		       (zscale+0.001f)*cos(rotatet[i]+r2)+0.01f);
	    glVertex3f((xscale+0.001f)*sin(rotatet[i+1]+r2)+sin(time+(float)(i+1)/5.0f),
		       (i+1)*(yscale),
		       (zscale+0.001f)*cos(rotatet[i+1]+r2)+0.01f);
	    glEnd();
	}

    }

}
