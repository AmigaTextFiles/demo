/**********************************************************************
	
  Texture mapping with OpenGL

  June, 13th, 2000

  This tutorial was written by Philipp Crocoll
  Contact: 
	philipp.crocoll@web.de
	www.codecolony.de

  Every comment would be appreciated.

  If you want to use parts of any code of mine:
	let me know and
	use it!

***********************************************************************
ESC: exit

CAMERA movement:
w : forwards
s : backwards
a : turn left
d : turn right
x : turn up
y : turn down
v : strafe right
c : strafe left
r : move up
f : move down
b : switch between BfC and drawing the frontfaces wired
***********************************************************************/

#include <GL/glut.h>
#include <GL/glaux.h>		//Used for loading the textures
#include <windows.h>
#include "camera.h"
#include "textures.h"


CCamera Camera;

GLfloat YRotated = 0.0;

COGLTexture Tex1, Tex2;

void InitTextures(void)
{
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);

	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST_MIPMAP_NEAREST);

	Tex1.LoadFromFile("tex1.bmp");
	Tex2.LoadFromFile("tex2.bmp");

	glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);

}

void DrawCube(void)
{
	//Draws a cube with two shaded, two one-colored and two textured faces
	glBegin(GL_QUADS);
		glColor3f(1.0,0.0,0.0);
	  //front:
		glVertex3f(-0.5,-0.5,0.5);
		glVertex3f(-0.5,0.5,0.5);
		glVertex3f(0.5,0.5,0.5);
		glVertex3f(0.5,-0.5,0.5);

	  //back:
		glColor3f(0.0,0.0,1.0);
		glVertex3f(-0.5,-0.5,-0.5);
		glVertex3f(0.5,-0.5,-0.5);
		glVertex3f(0.5,0.5,-0.5);
		glVertex3f(-0.5,0.5,-0.5);

	  //top:
		glColor3f(0.0,0.6,1.0);
		glVertex3f(-0.5,0.5,-0.5);
		glVertex3f(0.5,0.5,-0.5	);
		glColor3f(1.0,0.6,1.0);
		glVertex3f(0.5,0.5,0.5);
		glVertex3f(-0.5,0.5,0.5);

	  //bottom:
		glColor3f(0.0,0.6,0.0);
		glVertex3f(-0.5,-0.5,-0.5);
		glColor3f(0.6,0.6,0.6);
		glVertex3f(-0.5,-0.5,0.5);
		glColor3f(1.0,1.0,0.3);
		glVertex3f(0.5,-0.5,0.5);
		glColor3f(0.0,1.0,0.0);
		glVertex3f(0.5,-0.5,-0.5);
	glEnd();
	glEnable(GL_TEXTURE_2D);

	Tex1.SetActive();
	glBegin(GL_QUADS);
	  //left:
		glTexCoord2f(1.0,0.0);
		glVertex3f(-0.5,-0.5,-0.5);
		glTexCoord2f(1.0,1.0);
		glVertex3f(-0.5,0.5,-0.5);
		glTexCoord2f(0.0,1.0);
		glVertex3f(-0.5,0.5,0.5);
		glTexCoord2f(0.0,0.0);
		glVertex3f(-0.5,-0.5,0.5);
	glEnd();
	  //right:
	Tex2.SetActive();
	glBegin(GL_QUADS);
		glTexCoord2f(0.0,0.0);
		glVertex3f(0.5,-0.5,-0.5);
		glTexCoord2f(1.0,0.0);
		glVertex3f(0.5,-0.5,0.5);
		glTexCoord2f(1.0,1.0);
		glVertex3f(0.5,0.5,0.5);
		glTexCoord2f(0.0,1.0);
		glVertex3f(0.5,0.5,-0.5);
	glEnd();
	glDisable(GL_TEXTURE_2D);


}

void reshape(int x, int y)
{
	if (y == 0 || x == 0) return; 
	
	glMatrixMode(GL_PROJECTION);  
	glLoadIdentity();
	gluPerspective(40.0,(GLdouble)x/(GLdouble)y,0.5,20.0);

	glMatrixMode(GL_MODELVIEW);
	glViewport(0,0,x,y);
}

void Display(void)
{
	glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
	glLoadIdentity();
	Camera.Render();
	glRotatef(YRotated,0.0,1.0,0.0);		
	DrawCube();

	glFlush();  
	glutSwapBuffers();

}
void KeyDown(unsigned char key, int x, int y)
{
	switch (key) 
	{
	case 27:		//ESC
		PostQuitMessage(0);
		break;
	case 'a':		
		Camera.RotateY(5.0);
		Display();
		break;
	case 'd':		
		Camera.RotateY(-5.0);
		Display();
		break;
	case 'w':		
		Camera.MoveForwards( -0.1 ) ;
		Display();
		break;
	case 's':		
		Camera.MoveForwards( 0.1 ) ;
		Display();
		break;
	case 'x':		
		Camera.RotateX(5.0);
		Display();
		break;
	case 'y':		
		Camera.RotateX(-5.0);
		Display();
		break;
	case 'c':		
		Camera.StrafeRight(-0.1);
		Display();
		break;
	case 'v':		
		Camera.StrafeRight(0.1);
		Display();
		break;
	case 'r':
		Camera.Move(F3dVector(0.0,0.1,0.0));
		Display();
		break;
	case 'f':
		Camera.Move(F3dVector(0.0,-0.1,0.0));
		Display();
		break;
	case 'b': 
		if (glIsEnabled(GL_CULL_FACE) == GL_TRUE)
		{
			glDisable(GL_CULL_FACE);
			glPolygonMode(GL_FRONT, GL_LINE);
			glPolygonMode(GL_BACK, GL_FILL);
		}
		else
		{
			glEnable(GL_CULL_FACE);
			glPolygonMode(GL_FRONT, GL_FILL);
		}
		Display();
		break;
	}
}

void Idle(void)
{
	YRotated += 0.4;
	Display();
}

int main(int argc, char **argv)
{
	glutInit(&argc, argv);
	glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB | GLUT_DEPTH);
	glutInitWindowSize(300,300);
	glutCreateWindow("Textures and BfC");
	glFrontFace(GL_CW);  //Clockwise is front in "DrawCube()"
	glCullFace(GL_BACK);
	glEnable(GL_CULL_FACE);
	glEnable(GL_DEPTH_TEST);
	Camera.Move( F3dVector(0.0, 0.0, 3.0 ));
	Camera.MoveForwards( 1.0 );
	InitTextures();
	glutDisplayFunc(Display);
	glutReshapeFunc(reshape);
	glutKeyboardFunc(KeyDown);
	glutIdleFunc(Idle);
	glutMainLoop();
	return 0;             
}
