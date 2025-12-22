#include <stdlib.h>
#include <mgl/gl.h>
#include <string.h>
#include <math.h>
#include <stdio.h>

#define M_PI 3.14159265

GLint width=1024; GLint height=768;
//GLfloat ang_x = 0.0, ang_y = 90, ang_z = 180;
GLfloat fov = 45.0;
GLfloat alpha;
GLfloat rtri;


void DoFrame(void)
{

  // setup GL.
    glClear(GL_COLOR_BUFFER_BIT);  // clear screen

    glMatrixMode(GL_PROJECTION);   // начинаем работать с параметрами камеры
    glLoadIdentity();              // Делаем матрицу  (и очищаем матрицу Projection)

    gluPerspective(fov,   // поле зрения в 45 градусов
                  (GLfloat)width / (GLfloat)height, // вычисляем поле зрения по X учитывая размеры окна
                  0.1,     // передний план от нас на расстоянии 1.0
                  100.0);  // задний план на расстоянии 100. Все, что дальше - отсекается.

    glMatrixMode(GL_MODELVIEW); // делаем активной на последок матрицу объектов
    glLoadIdentity();           // и очистим ее (матрица MODELVIEW) (также еденичная)


  // start to draw

    glTranslatef(-1.5f,0.0f,-6.0f);         // Move left 1.5 units and into the screen 6.0
   // glRotatef(rtri,0.5f,1.5f,1.0f);

    glBegin(GL_TRIANGLES);
        glColor4f(1.0,0.0,0.0,alpha);
        glVertex3f(1.1,1.9,1.0);
        glColor4f(0.0,1.0,0.0,alpha);
        glVertex3f(1.1,1.1,1.0);
        glColor4f(0.0,0.0,1.0,alpha);
        glVertex3f(1.7,1.5,1.0);
    glEnd();

 
   rtri += 0.8f;

   alpha+=0.005f;
   

   mglSwitchDisplay();  // to make currently frame visibly. + if, mglEnableSync in ON (by default) it is a vblank
}






void keys(char c)
{

    switch (c)
    {
        case 0x1b:
            mglExit();
            break;
        case '+':
            if (fov < 180.0)
                fov += 5.0;
            break;
        case '-':
            if (fov > 0)
                fov -= 5.0;
            break;
    }

}

int main()
{
 
    MGLInit();
    mglCreateContext(0,0,width,height); // offx,offy,w,h. offx and offy currently ignored. set to 0.

   glEnable(GL_BLEND);
   glBlendFunc(GL_SRC_ALPHA,GL_SRC_COLOR);//ONE_MINUS_SRC_ALPHA);
  //  glShadeModel(GL_FLAT);

    glClearColor(0.0, 0.0, 0.0, 0.0);   // set screen with black color
    
    mglLockMode(MGL_LOCK_SMART); // locking. maybe manual, but safe/best way automatic locking. (smart)
    mglIdleFunc(DoFrame);        // pointer to function which called every frame
    mglKeyFunc(keys);            // pointer to KeyHandler. Vanilla keys as arguments.


    mglMainLoop();               // library-provided main loop (as in glut).
                                 // do it loop, while do not recieve mglExit().
    mglDeleteContext();          // delete context
    MGLTerm();                   // term (must be last func in app!)
    return 0;
}

