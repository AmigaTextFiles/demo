
#include <math.h>
#ifdef UGLY_GL_HEADERS
#include <GL.h>
#else
#include <GL/gl.h>
#include <GL/glut.h>
#endif

extern GLint gl_names[];

void kukat1(double tid,GLint tegsture)
{
    int n,i;
    double  pleis,jea=tid*50.0;

    glTranslatef(0,0,-12);
    glColor4f(1,1,1,0.5);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_COLOR,GL_ONE);
    glBindTexture(GL_TEXTURE_2D,tegsture);
    for(n=0;n<3;n++)
    {
        for(i=0;i<12;i++,jea+=10)
        {
            glPushMatrix();
            pleis=fmod(100000.0+i*3.0-tid*2.0+n*5,14.0)-7.0;
            glTranslatef(fmod(i+n*7.0,12.0)-6.0,pleis,0);
            glRotatef((i&1)?jea:-jea,0,0,1);

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
        glTranslatef(0,0,4.0);
    }
    glDisable(GL_BLEND);
}

void kukat2(double tid,GLint tegsture)
{
    int n;

    glEnable(GL_BLEND);
    glColor4f(1,1,1,0.8);
    glBlendFunc(GL_SRC_COLOR,GL_ONE);
    glPushMatrix();
    glBindTexture(GL_TEXTURE_2D,tegsture);
    glTranslatef(0,0,-10);

    for(n=0;n<10;n++)
    {
        glPushMatrix();
        glTranslatef(5,fmod(n*2+tid*2,20)-10,0);
        glRotatef(sin(tid+n)*240.0+n*10.0,0,0,1);
        glScalef(1+sin(tid+n*3)/3,1+sin(tid+n*3)/3,1);
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

    glPopMatrix();
    glDisable(GL_BLEND);
}

void kukat3(double tid,GLint tegsture)
{
    int n,i;

    glEnable(GL_BLEND);
    glColor4f(1,1,1,0.8);
    glBlendFunc(GL_SRC_COLOR,GL_ONE);
    glPushMatrix();
    glBindTexture(GL_TEXTURE_2D,tegsture);
    glTranslatef(0,0,-60);
    glRotatef(tid*20,0,0,1);

    for(n=0;n<6;n++)
    {
        glRotatef(sin(n/2+tid*2)*20.0,0,0,1);
        for(i=0;i<10;i++)
        {
            glPushMatrix();
            glRotatef(360.0*i/10.0,0,0,1);
            glTranslatef(2,0,fmod(n*10+tid*10,60));
            glScalef(0.5,0.5,1);
            glRotatef(sin(tid+n)*180,0,0,1);
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
    }

    glPopMatrix();
    glDisable(GL_BLEND);
}
