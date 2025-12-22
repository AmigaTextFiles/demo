// source taken from minigl yahoo group

#include <stdlib.h>
#include <mgl/gl.h>
#include <string.h>

#include <math.h>
#ifndef M_PI
#define M_PI 3.14159265
#endif
#include <stdio.h>

GLint width=640; GLint height=480;
GLfloat ang_x = 0.0, ang_y = 90, ang_z = 180;
GLfloat fov = 45.0;

typedef struct
{
    GLfloat x,y,z,u,v;
} MyVertex;


GLubyte *LoadPPM(char *name, GLint *w, GLint *h)
{
    int i;
    unsigned long x,y;
    FILE *f;
    GLubyte *where;

    f = fopen(name, "r");

    if (!f)
    {
        *w = 0; *h=0;
        return NULL;
    }
    #ifndef __STORMC__
    i = fscanf(f, "P6\n%ld %ld\n255\n",&x, &y);
    #else
    i = fscanf(f, "P6\n%ld\n%ld\n255\n", &x, &y);
    #endif

    if (i!= 2)
    {
        printf("Error scanning PPM header\n");
        fclose(f);
        *w = 0; *h = 0;
        return NULL;
    }

    *w = x;
    *h = y;

    where = malloc(x*y*3);
    if (!where)
    {
        printf("Error out of Memory\n");
        fclose(f);
        *w = 0; *h = 0;
        return NULL;
    }

    i = fread(where, 1, x*y*3, f);
    fclose(f);

    if (i != x*y*3)
    {
        printf("Error while reading file\n");
        free(where);
        *w = 0; *h = 0;
        return NULL;
    }

    return where;
}


BOOL TexInit(char *name, int num)
{
    GLubyte *tmap;
    GLint x,y;

    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    glPixelStorei(GL_PACK_ALIGNMENT, 1);

    if (!name)
    {
        return FALSE;
    }
    else
    {
        tmap = LoadPPM(name, &x, &y);
    }

    if (!tmap)
        return FALSE;

    glBindTexture(GL_TEXTURE_2D, num);
    glTexImage2D(GL_TEXTURE_2D, 0, 3,
        x,y, 0, GL_RGB, GL_UNSIGNED_BYTE, tmap);
    free(tmap);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

    glEnable(GL_TEXTURE_2D);

    return TRUE;
}

static void DrawBox(GLint tex1)
{
    glBindTexture(GL_TEXTURE_2D, tex1);
    glBegin(GL_QUADS);

        glTexCoord2f(0.0, 0.0);
        glVertex3f( 1.0,  1.0,  1.0);
        glTexCoord2f(1.0, 0.0);
        glVertex3f(-1.0,  1.0,  1.0);
        glTexCoord2f(1.0, 1.0);
        glVertex3f(-1.0,  1.0, -1.0);
        glTexCoord2f(0.0, 1.0);
        glVertex3f( 1.0,  1.0, -1.0);

        glTexCoord2f(0.0, 0.0);
        glVertex3f( 1.0, -1.0,  1.0);
        glTexCoord2f(1.0, 0.0);
        glVertex3f( 1.0,  1.0,  1.0);
        glTexCoord2f(1.0, 1.0);
        glVertex3f( 1.0,  1.0, -1.0);
        glTexCoord2f(0.0, 1.0);
        glVertex3f( 1.0, -1.0, -1.0);
        
        glTexCoord2f(0.0, 0.0);
        glVertex3f(-1.0, -1.0,  1.0);
        glTexCoord2f(1.0, 0.0);
        glVertex3f( 1.0, -1.0,  1.0);
        glTexCoord2f(1.0, 1.0);
        glVertex3f( 1.0, -1.0, -1.0);
        glTexCoord2f(0.0, 1.0);
        glVertex3f(-1.0, -1.0, -1.0);

        glTexCoord2f(0.0, 0.0);
        glVertex3f(-1.0,  1.0,  1.0);
        glTexCoord2f(1.0, 0.0);
        glVertex3f(-1.0, -1.0,  1.0);
        glTexCoord2f(1.0, 1.0);
        glVertex3f(-1.0, -1.0, -1.0);
        glTexCoord2f(0.0, 1.0);
        glVertex3f(-1.0,  1.0, -1.0);
        
        glTexCoord2f(0.0, 0.0);
        glVertex3f( 1.0,  1.0,  1.0);
        glTexCoord2f(1.0, 0.0);
        glVertex3f( 1.0, -1.0,  1.0);
        glTexCoord2f(1.0, 1.0);
        glVertex3f(-1.0, -1.0,  1.0);
        glTexCoord2f(0.0, 1.0);
        glVertex3f(-1.0,  1.0,  1.0);

        glTexCoord2f(0.0, 0.0);
        glVertex3f( 1.0,  1.0, -1.0);
        glTexCoord2f(1.0, 0.0);
        glVertex3f(-1.0,  1.0, -1.0);
        glTexCoord2f(1.0, 1.0);
        glVertex3f(-1.0, -1.0, -1.0);
        glTexCoord2f(0.0, 1.0);
        glVertex3f( 1.0, -1.0, -1.0);

    glEnd();


}


void reshape(int w, int h)
{
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluPerspective(fov, (GLfloat)width/height, 1.0, 100.0);

    glMatrixMode(GL_MODELVIEW);
    glViewport(0, 0, w, h);
}

void DoFrame(void)
{
    glClear(GL_COLOR_BUFFER_BIT);

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluPerspective(fov, (GLfloat)width/height, 1.0, 100.0);

    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();

    glTranslatef(0.0, 0.0, -5.0);
    glRotatef(ang_x, 1.0, 0.0, 0.0);
    glRotatef(ang_y, 0.0, 1.0, 0.0);
    glRotatef(ang_z, 0.0, 0.0, 1.0);        

    DrawBox(1);

    ang_x += 1.0;
    ang_y += 1.5;
    ang_z += 2.0;

    mglSwitchDisplay();
}


void keys(char c)
{

    switch (c)
    {
        case 0x1b:
            mglExit();
            break;
        case '+':
            if (fov < 165.0)
                fov += 5.0;
            break;
        case '-':
            if (fov > 30)
                fov -= 5.0;
            break;
    }

}

int main(int argc, char *argv[])
{
    int i;
    char *filename = "texture.ppm";

    for (i=1; i<argc; i++)
    {
        if (0 == strcmp(argv[i], "-width"))
        {
            i++;
            width = atoi(argv[i]);
        }
        if (0 == strcmp(argv[i], "-height"))
        {
            i++;
            height = atoi(argv[i]);
        }
        if (0 == strcmp(argv[i], "-window"))
        {
            mglChooseWindowMode(GL_TRUE);
        }
        if (0 == strcmp(argv[i], "-texture"))
        {
            i++;
            filename = argv[i];
        }
    }

    mglChooseVertexBufferSize(1000);
    mglChooseNumberOfBuffers(3);
    MGLInit();
    mglCreateContext(0,0,width,height);
 //   mglEnableSync(GL_FALSE);

    glClearColor(0.0, 0.0, 0.0, 0.0);
 //   reshape(width, height);
    glDisable(GL_CULL_FACE); 
    glDisable(GL_DEPTH_TEST);
    glClearDepth(1.0);
    glDepthFunc(GL_LEQUAL);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);


    if (TexInit(filename, 1))
    {
        glClearColor(0.0, 0.0, 0.0, 1.0);
        glColor3f(1.0, 1.0, 1.0);

        glHint(MGL_W_ONE_HINT, GL_FASTEST);
        
        reshape(width, height);
        
        mglLockMode(MGL_LOCK_SMART);
        mglIdleFunc(DoFrame);
        mglKeyFunc(keys);
        mglMainLoop();
    }
    else
    {
        printf("Can't load textures\n");
    }

    mglDeleteContext();
    MGLTerm();
    return 0;
}

