/* minimal Mesa GL toolkit wrapper */

#include <proto/tinygl.h>

typedef struct {
	int sizeX, sizeY, data;
} TK_RGBImageRec;

int tkRGBMap[0];

#define TK_ESCAPE	27
#define TK_SPACE	' '
#define TK_0		'0'
#define TK_1		'1'
#define TK_2		'2'
#define TK_3		'3'
#define TK_4		'4'
#define TK_5		'5'
#define TK_6		'6'
#define TK_7		'7'
#define TK_8		'8'
#define TK_9		'9'
#define TK_A		'A'
#define TK_D		'D'
#define TK_F		'F'
#define TK_G		'G'
#define TK_H		'H'
#define TK_J		'J'
#define TK_K		'K'
#define TK_Q		'Q'
#define TK_S		'S'
#define TK_T		'T'
#define TK_L		'L'
#define TK_W		'W'
#define TK_X		'X'
#define TK_Y		'Y'
#define TK_Z		'Z'
#define TK_a		'a'
#define TK_c		'c'
#define TK_d		'd'
#define TK_e		'e'
#define TK_f		'f'
#define TK_g		'g'
#define TK_h		'h'
#define TK_j		'j'
#define TK_k		'k'
#define TK_r		'r'
#define TK_s		's'
#define TK_t		't'
#define TK_l		'l'
#define TK_m		'm'
#define TK_n		'n'
#define TK_o		'o'
#define TK_p		'p'
#define TK_q		'q'
#define TK_u		'u'
#define TK_v		'v'
#define TK_w		'w'
#define TK_x		'x'
#define TK_y		'y'
#define TK_z		'z'
#define TK_LEFT		-GLUT_KEY_LEFT
#define TK_UP		-GLUT_KEY_UP
#define TK_RIGHT	-GLUT_KEY_RIGHT
#define TK_DOWN		-GLUT_KEY_DOWN
#define TK_LEFTBUTTON	GLUT_LEFT_BUTTON
#define TK_MIDDLEBUTTON	GLUT_MIDDLE_BUTTON
#define TK_RIGHTBUTTON	GLUT_RIGHT_BUTTON

#define TK_YELLOW	0
#define TK_RED		0
#define TK_BLACK	0
#define TK_WHITE	0
#define TK_GREEN	0
#define TK_BLUE		0
#define TK_STENCIL	0
#define TK_DIRECT	0
#define TK_INDIRECT	0
#define TK_RGB		GLUT_RGB
#define TK_INDEX	GLUT_INDEX
#define TK_SINGLE	GLUT_SINGLE
#define TK_DOUBLE	GLUT_DOUBLE
#define TK_DEPTH	GLUT_DEPTH
#define TK_SETCOLOR(x,y)
#define TK_ACCUM	0
#define TK_OVERLAY	0

#define tkSwapBuffers	glutSwapBuffers
#define tkQuit()	exit(1)/*QuitTinyGL*/
#define tkInitPosition(x1,y1,x2,y2) {glutInit(&argc,argv);glutInitWindowPosition(x1,x2);glutInitWindowSize(x2,y2);}
#define tkInitDisplayMode(x) glutInitDisplayMode(x)
#define tkInitWindow	glutCreateWindow
#define tkExposeFunc
#define tkReshapeFunc	glutReshapeFunc
#define tkKeyDownFunc	/*glutKeyboardFunc*/
#define tkDisplayFunc	glutDisplayFunc
#define tkExec		glutMainLoop
#define tkGetColorMapSize() 0
#define tkSetOneColor
#define tkIdleFunc	glutIdleFunc
#define tkSetGreyRamp()	0
#define tkSetFogRamp
#define tkGetMouseLoc
#define tkMouseDownFunc	glutMouseFunc
#define tkSetWindowLevel
#define tkCreateStrokeFont
#define tkCreateOutlineFont
#define tkCreateFilledFont
#define tkCreateBitmapFont
#define tkDrawStr
#define tkNewCursor
#define tkSetCursor
#define tkWireSphere
#define tkSolidSphere
#define tkWireCube
#define tkSolidCube
#define tkWireBox
#define tkSolidBox
#define tkWireTorus
#define tkSolidTorus
#define tkWireCylinder
#define tkSolidCylinder
#define tkWireCone
#define tkSolidCone
#define tkRGBImageLoad

/* other missing functions */

#define GL_TEXTURE_3D_EXT 0
#define GL_TEXTURE_WRAP_R_EXT 0
#define GLU_SAMPLING_TOLERANCE 0
#define GLU_DISPLAY_MODE 0
#define GLU_OUTLINE_PATCH 0
#define GLU_NURBS_ERROR13 0
#define CALLBACK

#define glTexImage3DEXT(...)
#define glClearAccum
#define glAccum
#define glBlendEquationEXT
#define glIndexf
#define glMaterialiv
#define glTexCoord3fv(x) 0
#define glPixelMapfv
#define glClearIndex
#define glRasterPos3i
#define glFeedbackBuffer
#define glEvalCoord1d glEvalCoord1f
#define glEvalCoord2d glEvalCoord2f
#define glIndexMask
#define glTexGeniv

#define gluNewNurbsRenderer() 0
#define gluNurbsCallback
#define gluNurbsProperty
#define gluEndSurface
#define gluBeginSurface
#define gluNurbsSurface
#define gluBuild2DMipmaps
#define gluNewQuadric() 0
#define gluQuadricCallback
#define gluQuadricDrawStyle
#define gluQuadricNormals
#define gluQuadricOrientation
#define gluQuadricTexture
#define gluCylinder
#define gluSphere
#define gluPartialDisk
#define gluDisk
#define gluScaleImage

#define sleep
