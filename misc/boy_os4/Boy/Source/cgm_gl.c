
#include <stdlib.h>
#include "cgm_gl.h"
#include <SDL_opengl.h>

#define RGB(x) (x>>16)/255.0,((x>>8)&0xff)/255.0,(x&0xff)/255.0

void cgm_clearcolor(CGM *c)
{
    glClearColor(RGB(c->back),0);
}

void cgm_render(CGM *c)
{
    int     n;
    ELEMENT *ele;

    ele=c->head;
    while(ele!=NULL)
    {
        if(ele->types&CGM_POLYGON)
        {
            glColor3f(RGB(c->pal[ele->color]));
            glBegin(GL_TRIANGLES);
            for(n=0;n<ele->tris*3;n++)
            {
                glVertex2f(ele->trisv[n*2]/65536.0,
                           ele->trisv[n*2+1]/65536.0);
            }
            glEnd();
        }
        if(ele->types&CGM_POLYLINE)
        {
            glLineWidth(ele->linewidth);
            glColor3f(RGB(c->pal[ele->linecolor]));
            glBegin(GL_LINE_STRIP);
            for(n=0;n<ele->points;n++)
            {
                glVertex2f(ele->pointsv[n*2]/65536.0,
                           ele->pointsv[n*2+1]/65536.0);
            }
            glEnd();
        }

        ele=ele->next;
    }
}
