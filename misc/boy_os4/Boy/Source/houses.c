
#include <stdlib.h>
#include <math.h>
#include <SDL_opengl.h>
#include "gl_render.h"
#include "houses.h"
#include "mp3.h"

SCENE house;

void houses_init(void)
{
    int x,z;

    load_scene(&house,"houses.obj");
    glNewList(LIST_HOUSES,GL_COMPILE);
    render_scene(&house,RENDER_NORMAL+RENDER_NOLIGHTS);
    glEndList();
}

void houses(int tid,int eff)
{
    int n,i,x,z,he;
    double d;

    glEnable(GL_DEPTH_TEST);
    for(n=0;n<3;n++)
    {
        glLoadIdentity();
        d=tid/2000.0;
        glRotatef(40-sin(d)*10,1,0,0);
        glRotatef(sin(tid/3000.0)*25.0,0,1,0.2);
        glTranslatef(0,-6.5+sin(d)*5.0,fmod(tid/100.0,17)-n*17);
        glCallList(LIST_HOUSES);

        if(eff)
        {
            glLineWidth(2);
            glColor3f(0.8,0.08,0.08);

            glBegin(GL_LINE_STRIP);
            for(i=0;i<mp3_floatvals;i+=4)
                glVertex3f(mp3_floatbuf[i]*0.8,0.6+sin(M_PI*2.0*i/mp3_floatvals)/2.0,-8.5+17.0*i/mp3_floatvals);
            glEnd();

            glBegin(GL_LINE_STRIP);
            for(i=0;i<mp3_floatvals;i+=4)
                glVertex3f(-8.5+17.0*i/mp3_floatvals,mp3_floatbuf[i]*0.8+1.0,0.5);
            glEnd();
        }
    }

    glDisable(GL_DEPTH_TEST);
}
