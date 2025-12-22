/*  Planet.c
 *  Realtime rendered planets using OpenGL
 *
 *  Autor: Norman Walter
 *  Date:  4.2.2006
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <GL/glut.h>

#include <exec/types.h>

#include "bmp.h"
#include "bmp.c"

#include "requesters.h"
#include "requesters.c"

#define ABOUTMSG "Planet\nVersion 1.0\n© 2006 by Norman Walter"

/* Globals */
static GLUquadricObj *Quadric;
static GLuint Sphere;
static GLfloat LightPos[4] = {10.0, 10.0, 10.0, 1.0};

static GLfloat Black[4] = {0.0, 0.0, 0.0, 1.0};
static GLfloat White[4] = {1.0, 1.0, 1.0, 1.0};

static GLfloat Xrot = -66.55, Yrot = -23.45, Zrot = 0.0;
static DZrot = 1.0;

static GLboolean Animate = GL_TRUE;

#define ANIMATE       10
#define POINT_FILTER  20
#define LINEAR_FILTER 30
#define TEXTUREINFO   40
#define ABOUT         50

/* Texture Stuff */

BITMAPINFOHEADER    PlanetInfo;        // texture info header
UBYTE               *PlanetTexture;    // texture data
unsigned int        Planet;            // the  texture object
char                texturefile[255];

static void Idle( void )
{
   /* update animation vars */
   if (Animate)
   {
     Zrot += DZrot;

     if (Zrot > 360.0)
     {
       Zrot -= 360.0;
     }
     glutPostRedisplay();
  }
}


static void Display( void )
{
   glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );

   glLightfv(GL_LIGHT0, GL_POSITION, LightPos);

   glPushMatrix();

   /* draw stuff here */

   glRotatef(Xrot, 1.0, 0.0, 0.0);
   glRotatef(Yrot, 0.0, 1.0, 0.0);
   glRotatef(Zrot, 0.0, 0.0, 1.0);

   /* Typical method: diffuse + specular + texture */
   glEnable(GL_TEXTURE_2D);
   glLightfv(GL_LIGHT0, GL_DIFFUSE, White);  /* enable diffuse */
   glLightfv(GL_LIGHT0, GL_SPECULAR, White);  /* enable specular */
#ifdef GL_VERSION_1_2
   glLightModeli(GL_LIGHT_MODEL_COLOR_CONTROL, GL_SINGLE_COLOR);
#endif

   glCallList(Sphere);

   glPopMatrix();

   glutSwapBuffers();
}


static void Reshape( int width, int height )
{
   glViewport( 0, 0, width, height );
   glMatrixMode( GL_PROJECTION );
   glLoadIdentity();
   glFrustum( -1.0, 1.0, -1.0, 1.0, 5.0, 25.0 );
   glMatrixMode( GL_MODELVIEW );
   glLoadIdentity();
   glTranslatef( 0.0, 0.0, -12.0 );
}


/* Menu function for GLUT menu */
static void ModeMenu(int entry)
{
   switch (entry)
   {
      case ANIMATE:
        Animate = !Animate;
      break;

      case POINT_FILTER:
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
      break;

      case LINEAR_FILTER:
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
      break;

      case TEXTUREINFO:
        TextureInfo("Planet",texturefile,PlanetInfo.biWidth,PlanetInfo.biHeight);
      break;

      case ABOUT:
        MessageBox("Planet",ABOUTMSG);
      break;
   }

   glutPostRedisplay();
}

static void Key( unsigned char key, int x, int y )
{
   switch (key)
   {
      case 27:
         exit(0);
         break;
   }
   glutPostRedisplay();
}


static void SpecialKey( int key, int x, int y )
{
   switch (key)
   {
      case GLUT_KEY_UP:
         break;
      case GLUT_KEY_DOWN:
         break;
      case GLUT_KEY_LEFT:
         break;
      case GLUT_KEY_RIGHT:
         break;
   }
   glutPostRedisplay();
}

static GLboolean LoadTexture(char *filename)
{
   glEnable(GL_TEXTURE_2D);

   // load the Planet texture data
   PlanetTexture = LoadBMP(filename, &PlanetInfo);
   if (!PlanetTexture)
   {
      return GL_FALSE;
   }

   glGenTextures(1, &Planet);

   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
   gluBuild2DMipmaps(GL_TEXTURE_2D, GL_RGB, PlanetInfo.biWidth, PlanetInfo.biHeight, GL_RGB, GL_UNSIGNED_BYTE, PlanetTexture);

   return GL_TRUE;
}

static void Init( void )
{
   /* setup lighting, etc */

   glEnable(GL_LIGHTING);
   glEnable(GL_LIGHT0);
   glLightModeli(GL_LIGHT_MODEL_TWO_SIDE, 0);
   glLightModelfv(GL_LIGHT_MODEL_AMBIENT, Black);

   glMaterialfv(GL_FRONT, GL_DIFFUSE, White);
   glMaterialfv(GL_FRONT, GL_SPECULAR, White);
   glMaterialf(GL_FRONT, GL_SHININESS, 50.0);

   /* Actually, these are set again later */
   glLightfv(GL_LIGHT0, GL_DIFFUSE, White);
   glLightfv(GL_LIGHT0, GL_SPECULAR, White);

   Quadric = gluNewQuadric();
   gluQuadricTexture( Quadric, GL_TRUE );
   glBindTexture(GL_TEXTURE_2D, Planet);

   Sphere= glGenLists(1);
   glNewList( Sphere, GL_COMPILE );
   gluSphere( Quadric, 2.0, 36, 36 );
   glEndList();

   glEnable(GL_DEPTH_TEST);
   glEnable(GL_CULL_FACE);

   if (!LoadTexture(texturefile))
   {
     LoadError("Planet",texturefile);
   }

   glBlendFunc(GL_ONE, GL_ONE);

}


int main( int argc, char *argv[] )
{
   strcpy(texturefile,argv[1]);

   glutInit( &argc, argv );
   glutInitWindowSize( 400, 400 );

   glutInitDisplayMode( GLUT_RGB | GLUT_DOUBLE | GLUT_DEPTH );

   glutCreateWindow(argv[0]);

   Init();

   glutReshapeFunc( Reshape );
   glutKeyboardFunc( Key );
   glutSpecialFunc( SpecialKey );
   glutDisplayFunc( Display );
   glutIdleFunc( Idle );

   /* Create GLUT Menu */
   glutCreateMenu(ModeMenu);
   glutAddMenuEntry("Point Filtered", POINT_FILTER);
   glutAddMenuEntry("Linear Filtered", LINEAR_FILTER);
   glutAddMenuEntry("Toggle Animation", ANIMATE);
   glutAddMenuEntry("Texture Information", TEXTUREINFO);
   glutAddMenuEntry("About", ABOUT);
   glutAttachMenu(GLUT_RIGHT_BUTTON);

   glutMainLoop();

   if (PlanetTexture!=NULL) free(PlanetTexture);

   return 0;
}
