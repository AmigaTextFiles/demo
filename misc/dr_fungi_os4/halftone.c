
#ifdef UGLY_GL_HEADERS
#include <GL.h>
#else
#include <GL/gl.h>
#include <GL/glut.h>
#endif
#include <math.h>

#define MAARA 20

void halftone(double tid,double th,GLint texture)
{
    int x,y;
    double kale;

    glBindTexture(GL_TEXTURE_2D,texture);
    glEnable(GL_ALPHA_TEST);
    glEnable(GL_TEXTURE_2D);
    glAlphaFunc(GL_GREATER,0.5);
    glPushMatrix();
    for(y=0;y<MAARA;y++)
        for(x=0;x<MAARA;x++)
        {
            glPushMatrix();
            glTranslatef((x-MAARA/2)/5.0,(y-MAARA/2)/5.0,0);
            kale=th+0.1+sin(x/2.0+y/2.0+tid*2.0)/30.0+cos(tid+y)/30.0;
            if(kale<0.0)
                kale=0.0;
            glScalef(kale,kale,0);
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
            glPopMatrix();
        }
    glDisable(GL_ALPHA_TEST);
    glPopMatrix();
}
