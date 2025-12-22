#ifdef UGLY_GL_HEADERS
#include <GL.h>
#else
#include <GL/gl.h>
#include <GL/glut.h>
#endif
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "mcubes.h"
#include "mcubetable.h"


static float space[WSIZEX][WSIZEY][WSIZEZ];
float RAJA=0.5f; /* raja mita isompi on nii on sisalla */
float MCX=1.0f;    /* cuben x,y,z koot */
float MCY=1.0f;
float MCZ=1.0f;

GLfloat light_diffuse[] = {1.0, 0.0, 1.0, 1.0};  /* Red diffuse light. */
GLfloat light_diffuse2[] = {0.0, 1.0, 1.0, 1.0};  /* Red diffuse light. */
GLfloat light_position[] = {1.0, 1.0,-100.0, 0.0};  /* Infinite light location. */
GLfloat light_position2[] = {-1.0, -1.0,+100.0, 0.0};  /* Infinite light location. */

void setMCX(float x){
    MCX = x;
}
void setMCY(float y){
    MCY = y;
}
void setMCZ(float z){
    MCZ = z;
}

void mc_init() {

    int i,j,k;
    for(i=0; i<WSIZEX; i++) {
	for(j=0; j<WSIZEY; j++) {
	    for(k=0; k<WSIZEZ; k++) {
		space[i][j][k]=0.0f;
	    }
	}
    }


}
void mc_update(float time) {
    static float xx=0.0f;
    static float yy=0.0f;
    static float zz=0.0f;
    static float tt=0.0f;
    static float xx2=0.0f;
    static float yy2=0.0f;
    static float zz2=0.0f;
    static float tt2=0.0f;
    static float xx3=0.0f;
    static float yy3=0.0f;
    static float zz3=0.0f;
    static float tt3=0.0f;
    int i,j,k;
    float et,et2,et3;
    tt=time;
    tt2=time;
    tt3=time;
//    tt+=0.005f;
    RAJA=0.4f*sin(tt)+0.5f;
    RAJA=0.5f;
    xx=sin(tt)*4+(WSIZEX/2);
    yy=sin(tt*3)*2+cos(tt)*2+(WSIZEY/2);
    zz=sin(tt*4)*2-cos(tt*2)*2+(WSIZEZ/2);
//    tt2+=0.005f;
    xx2=sin(tt2*2)*5+(WSIZEX/2);
    yy2=sin(tt2*7)*2+cos(tt2*3)*2+(WSIZEY/2);
    zz2=sin(tt2*6)*2-cos(tt2*1)*2+(WSIZEZ/2);
//    tt3+=0.005f;
    xx3=sin(tt3*3)*4+(WSIZEX/2);
    yy3=sin(tt3*7)*2+cos(tt3*3)*2+(WSIZEY/2);
    zz3=sin(tt3*6)*2-cos(tt3*5)*2+(WSIZEZ/2);



    RAJA=0.6;
    RAJA=0.03f*sin(time*10)+0.5f;
    RAJA=0.1f;
    for(i=0; i<WSIZEX; i++) {
	for(j=0; j<WSIZEY; j++) {
	    for(k=0; k<WSIZEZ; k++) {
		et=((i-xx)*(i-xx)+(j-yy)*(j-yy)+(k-zz)*(k-zz))/30.0f;
//		if(et>10.0f) et=10.0f;
		et=1.1f-et;
		if(et<0.0f) et=0.0f;
                if(et>1.0f) et=1.0f;
		et2=((i-xx2)*(i-xx2)+(j-yy2)*(j-yy2)+(k-zz2)*(k-zz2))/30.0f;
//		if(et2>10.0f) et2=10.0f;
		et2=1.1f-et2;
		if(et2<0.0f) et2=0.0f;
                if(et2>1.0f) et2=1.0f;
		et3=((i-xx3)*(i-xx3)+(j-yy3)*(j-yy3)+(k-zz3)*(k-zz3))/30.0f;
/*		if(i==8&&j==8&&k==8) {
		    fprintf(stdout,"ennen:%g ",et3);
		}*/
//		if(et3>10.0f) et3=10.0f;
		et3=1.1f-et3;
		if(et3<0.0f) et3=0.0f;
                if(et3>1.0f) et3=1.0f;
/*		if(i==8&&j==8&&k==8) {
		    fprintf(stdout,"jalkee:%g ",et3);
		}*/

		et=(et3+et2+et)*0.1f;
                if(et>1.0f) et=1.0f;
                if(et<0.0f) et=0.0f;
/*		space[i][j][k]=(et3+et2+et)*0.1f;
		if(space[i][j][k]>1.0f) {
		    space[i][j][k]=1.0f;
		}
		if(space[i][j][k]<0.0f) {
		    space[i][j][k]=0.0f;
		}
		if(i==8&&j==8&&k==8) {
		    fprintf(stdout,"space:%g \n",space[i][j][k]);
		}
		*/

                space[i][j][k]=et*10.f;
/*		if(i==8&&j==8&&k==8) {
		    fprintf(stdout,"space:%g , %g\n",space[i][j][k],et);
		}*/

	    }
	}
     }


}


void drawCube(float corner[],float x,float y,float z) {

    int ulkona=0;
    int i;
    ulkona=0;
    for(i=0; i<8; i++) {
	if(corner[i]>RAJA) ulkona |= (1<<i);
    }
    for(i=0; i<MAXKOLMIOT;i++) {
	if(mc_table[ulkona][i]>=0) {
	    glColor4f(1.0f-((float)y+(WSIZEY/2))/WSIZEY,((float)y+(WSIZEY/2))/WSIZEY,1.0f,1.0f);
	    drawEdgeVert(mc_table[ulkona][i],corner,x,y,z,RAJA);
	} else {
	    i=MAXKOLMIOT;
	}
    }
//    glNormal3f( ((float)(rand()%256))/256.0f,((float)(rand()%256))/256.0f,((float)(rand()%256))/256.0f);
}

void mc_drawCubes(float time)
{
    float cube[8];
    int i,j,k;
    float rott=time;
    static float scale=0.0f;
    scale=time;
//    glLoadIdentity();
//    glTranslatef(0.0,0.0,-4);

    glRotatef( rott*13, 1.0, 0.0, 0.0);
    glRotatef( rott*17, 0.0, 1.0, 0.0);
    glRotatef( rott*15, 0.0, 0.0, 1.0);/**/

    glBegin(GL_TRIANGLES);
    for(i=0; i<WSIZEX-1; i++) {
	for(j=0; j<WSIZEY-1; j++) {
	    for(k=0; k<WSIZEZ-1; k++) {
		cube[0]=space[i  ][j  ][k  ];
		cube[1]=space[i+1][j  ][k  ];
		cube[2]=space[i+1][j+1][k  ];
		cube[3]=space[i  ][j+1][k  ];
		cube[4]=space[i  ][j  ][k+1];
		cube[5]=space[i+1][j  ][k+1];
		cube[6]=space[i+1][j+1][k+1];
		cube[7]=space[i  ][j+1][k+1];
		glColor3f(1.0f-((float)j)/WSIZEY,((float)j)/WSIZEY,1.0f);
//		glColor3f(((float)i)/WSIZEX,((float)j)/WSIZEY,((float)k)/WSIZEZ);
		drawCube(cube,i-(WSIZEX/2),j-(WSIZEY/2),k-(WSIZEZ/2));
	    }
	}
    }
    glEnd();
    glScalef(1.0f+sin(scale)*0.7f,1.0f+sin(scale)*0.7f,1.0f+sin(scale)*0.7f);
    glBegin(GL_TRIANGLES);
    for(i=0; i<WSIZEX-1; i++) {
	for(j=0; j<WSIZEY-1; j++) {
	    for(k=0; k<WSIZEZ-1; k++) {
		cube[0]=space[i  ][j  ][k  ];
		cube[1]=space[i+1][j  ][k  ];
		cube[2]=space[i+1][j+1][k  ];
		cube[3]=space[i  ][j+1][k  ];
		cube[4]=space[i  ][j  ][k+1];
		cube[5]=space[i+1][j  ][k+1];
		cube[6]=space[i+1][j+1][k+1];
		cube[7]=space[i  ][j+1][k+1];
		glColor3f(1.0f-((float)j)/WSIZEY,((float)j)/WSIZEY,1.0f);
//		glColor3f(((float)i)/WSIZEX,((float)j)/WSIZEY,((float)k)/WSIZEZ);
		drawCube(cube,i-(WSIZEX/2),j-(WSIZEY/2),k-(WSIZEZ/2));
	    }
	}
    }
    glEnd();


}

void drawBox(float size,float x,float y, float z) {

    if(size>1.0f) size=1.0f;
    size=size/2.0f;
    if(size>0.0f) {
        glEnable(GL_LIGHTING);

	glBegin(GL_QUADS);
	glNormal3f(0,0,-1);
	glVertex3f(x*MCX-size*MCX,y*MCY-size*MCY,z*MCZ-size*MCZ);
	glVertex3f(x*MCX+size*MCX,y*MCY-size*MCY,z*MCZ-size*MCZ);
	glVertex3f(x*MCX+size*MCX,y*MCY+size*MCY,z*MCZ-size*MCZ);
	glVertex3f(x*MCX-size*MCX,y*MCY+size*MCY,z*MCZ-size*MCZ);

	glNormal3f(0,0,-1);
	glVertex3f(x*MCX-size*MCX,y*MCY-size*MCY,z*MCZ+size*MCZ);
	glVertex3f(x*MCX-size*MCX,y*MCY+size*MCY,z*MCZ+size*MCZ);
	glVertex3f(x*MCX+size*MCX,y*MCY+size*MCY,z*MCZ+size*MCZ);
	glVertex3f(x*MCX+size*MCX,y*MCY-size*MCY,z*MCZ+size*MCZ);

	glNormal3f(-1,0,0);
	glVertex3f(x*MCX-size*MCX,y*MCY-size*MCY,z*MCZ+size*MCZ);
	glVertex3f(x*MCX-size*MCX,y*MCY+size*MCY,z*MCZ+size*MCZ);
	glVertex3f(x*MCX-size*MCX,y*MCY+size*MCY,z*MCZ-size*MCZ);
	glVertex3f(x*MCX-size*MCX,y*MCY-size*MCY,z*MCZ-size*MCZ);

	glNormal3f(1,0,0);
	glVertex3f(x*MCX+size*MCX,y*MCY+size*MCY,z*MCZ+size*MCZ);
	glVertex3f(x*MCX+size*MCX,y*MCY-size*MCY,z*MCZ+size*MCZ);
	glVertex3f(x*MCX+size*MCX,y*MCY-size*MCY,z*MCZ-size*MCZ);
	glVertex3f(x*MCX+size*MCX,y*MCY+size*MCY,z*MCZ-size*MCZ);

	glNormal3f(0,-1,0);
	glVertex3f(x*MCX-size*MCX,y*MCY-size*MCY,z*MCZ-size*MCZ);
	glVertex3f(x*MCX-size*MCX,y*MCY-size*MCY,z*MCZ+size*MCZ);
	glVertex3f(x*MCX+size*MCX,y*MCY-size*MCY,z*MCZ+size*MCZ);
	glVertex3f(x*MCX+size*MCX,y*MCY-size*MCY,z*MCZ-size*MCZ);

	glNormal3f(0,1,0);
	glVertex3f(x*MCX-size*MCX,y*MCY+size*MCY,z*MCZ+size*MCZ);
	glVertex3f(x*MCX-size*MCX,y*MCY+size*MCY,z*MCZ-size*MCZ);
	glVertex3f(x*MCX+size*MCX,y*MCY+size*MCY,z*MCZ-size*MCZ);
	glVertex3f(x*MCX+size*MCX,y*MCY+size*MCY,z*MCZ+size*MCZ);
	glEnd();

	size=size+0.00001f;
        glDisable(GL_LIGHTING);
	glColor4f(0,0,0,1);
        glLineWidth(2.0f);
	glBegin(GL_LINE_STRIP);
	glNormal3f(0,0,-1);
	glVertex3f(x*MCX-size*MCX,y*MCY-size*MCY,z*MCZ-size*MCZ);
	glVertex3f(x*MCX+size*MCX,y*MCY-size*MCY,z*MCZ-size*MCZ);
	glVertex3f(x*MCX+size*MCX,y*MCY+size*MCY,z*MCZ-size*MCZ);
	glVertex3f(x*MCX-size*MCX,y*MCY+size*MCY,z*MCZ-size*MCZ);

	glVertex3f(x*MCX-size*MCX,y*MCY-size*MCY,z*MCZ-size*MCZ);
        glEnd();
	glBegin(GL_LINE_STRIP);

	glNormal3f(0,0,-1);
	glVertex3f(x*MCX-size*MCX,y*MCY-size*MCY,z*MCZ+size*MCZ);
	glVertex3f(x*MCX-size*MCX,y*MCY+size*MCY,z*MCZ+size*MCZ);
	glVertex3f(x*MCX+size*MCX,y*MCY+size*MCY,z*MCZ+size*MCZ);
	glVertex3f(x*MCX+size*MCX,y*MCY-size*MCY,z*MCZ+size*MCZ);

	glVertex3f(x*MCX-size*MCX,y*MCY-size*MCY,z*MCZ+size*MCZ);
        glEnd();
	glBegin(GL_LINES);

	glNormal3f(-1,0,0);
	glVertex3f(x*MCX-size*MCX,y*MCY+size*MCY,z*MCZ-size*MCZ);
	glVertex3f(x*MCX-size*MCX,y*MCY+size*MCY,z*MCZ+size*MCZ);
	glVertex3f(x*MCX-size*MCX,y*MCY-size*MCY,z*MCZ+size*MCZ);
	glVertex3f(x*MCX-size*MCX,y*MCY-size*MCY,z*MCZ-size*MCZ);

	glVertex3f(x*MCX-size*MCX,y*MCY-size*MCY,z*MCZ+size*MCZ);
	glEnd();
	glBegin(GL_LINES);

	glNormal3f(1,0,0);
	glVertex3f(x*MCX+size*MCX,y*MCY+size*MCY,z*MCZ+size*MCZ);
	glVertex3f(x*MCX+size*MCX,y*MCY+size*MCY,z*MCZ-size*MCZ);
	glVertex3f(x*MCX+size*MCX,y*MCY-size*MCY,z*MCZ-size*MCZ);
	glVertex3f(x*MCX+size*MCX,y*MCY-size*MCY,z*MCZ+size*MCZ);

	glVertex3f(x*MCX+size*MCX,y*MCY+size*MCY,z*MCZ+size*MCZ);
	glEnd();

    }

}

void mc_drawBoxes(float time) {


    int i,j,k;
    float rott=time;
    static float scale=0.0f;
    scale=time;

    /* Enable a single OpenGL light. */
    glLightfv(GL_LIGHT0, GL_DIFFUSE, light_diffuse);
    glLightfv(GL_LIGHT0, GL_POSITION, light_position);
    glEnable(GL_LIGHT0);
    glLightfv(GL_LIGHT1, GL_DIFFUSE, light_diffuse2);
    glLightfv(GL_LIGHT1, GL_POSITION, light_position2);
    glEnable(GL_LIGHT1);
    glEnable(GL_LIGHTING);
    glEnable(GL_DEPTH_TEST);
//    glLoadIdentity();
//    glTranslatef(0.0,0.0,2);

    glRotatef( rott*13, 1.0, 0.0, 0.0);
    glRotatef( rott*17, 0.0, 1.0, 0.0);
    glRotatef( rott*15, 0.0, 0.0, 1.0);/**/

    glBegin(GL_TRIANGLES);
    for(i=0; i<WSIZEX; i++) {
	for(j=0; j<WSIZEY; j++) {
	    for(k=0; k<WSIZEZ; k++) {
		glColor3f(1.0f-((float)i/WSIZEX),((float)j)/WSIZEY,1.0f-((float)k/WSIZEZ));
		drawBox(space[i][j][k]-0.8f,(i-(WSIZEX/2)),(j-(WSIZEY/2)),(k-(WSIZEZ/2)));

	    }
	}
    }
    glEnd();
    glDisable(GL_LIGHTING);

}



void vert01(float corner[],float x,float y,float z,float raja) {
    glVertex3f(x*MCX+MCX/(corner[1]-corner[0])*(raja-corner[0]),y*MCY,z*MCZ);
}
void vert03(float corner[],float x,float y,float z,float raja) {
    glVertex3f(x*MCX,y*MCY+MCY/(corner[3]-corner[0])*(raja-corner[0]),z*MCZ);
}
void vert04(float corner[],float x,float y,float z,float raja) {
    glVertex3f(x*MCX,y*MCY,z*MCZ+MCZ/(corner[4]-corner[0])*(raja-corner[0]));
}
void vert12(float corner[],float x,float y,float z,float raja) {
    glVertex3f(x*MCX+MCX,y*MCY+MCY/(corner[2]-corner[1])*(raja-corner[1]),z*MCZ);
}
void vert15(float corner[],float x,float y,float z,float raja) {
    glVertex3f(x*MCX+MCX,y*MCY,z*MCZ+MCZ/(corner[5]-corner[1])*(raja-corner[1]));
}
void vert23(float corner[],float x,float y,float z,float raja) {
    glVertex3f(x*MCX+MCX/(corner[2]-corner[3])*(raja-corner[3]),y*MCY+MCY,z*MCZ);
}
void vert26(float corner[],float x,float y,float z,float raja) {
    glVertex3f(x*MCX+MCX,y*MCY+MCY,z*MCZ+MCZ/(corner[6]-corner[2])*(raja-corner[2]));
}
void vert37(float corner[],float x,float y,float z,float raja) {
    glVertex3f(x*MCX,y*MCY+MCY,z*MCZ+MCZ/(corner[7]-corner[3])*(raja-corner[3]));
}
void vert45(float corner[],float x,float y,float z,float raja) {
    glVertex3f(x*MCX+MCX/(corner[5]-corner[4])*(raja-corner[4]),y*MCY,z*MCZ+MCZ);
}
void vert47(float corner[],float x,float y,float z,float raja) {
    glVertex3f(x*MCX,y*MCY+MCY/(corner[7]-corner[4])*(raja-corner[4]),z*MCZ+MCZ);
}
void vert56(float corner[],float x,float y,float z,float raja) {
    glVertex3f(x*MCX+MCX,y*MCY+MCY/(corner[6]-corner[5])*(raja-corner[5]),z*MCZ+MCZ);
}
void vert67(float corner[],float x,float y,float z,float raja) {
    glVertex3f(x*MCX+MCX/(corner[6]-corner[7])*(raja-corner[7]),y*MCY+MCY,z*MCZ+MCZ);
}


void drawEdgeVert(int edge,float cube[],float x,float y,float z,float raja) {
    switch(edge) {
    case 0:
	vert01(cube,x,y,z,raja);
	break;
    case 1:
	vert12(cube,x,y,z,raja);
	break;
    case 2:
	vert23(cube,x,y,z,raja);
	break;
    case 3:
	vert03(cube,x,y,z,raja);
	break;
    case 4:
	vert45(cube,x,y,z,raja);
	break;
    case 5:
	vert56(cube,x,y,z,raja);
	break;
    case 6:
	vert67(cube,x,y,z,raja);
	break;
    case 7:
	vert47(cube,x,y,z,raja);
	break;
    case 8:
	vert04(cube,x,y,z,raja);
	break;
    case 9:
	vert15(cube,x,y,z,raja);
	break;
    case 10:
	vert26(cube,x,y,z,raja);
	break;
    case 11:
	vert37(cube,x,y,z,raja);
	break;

    }
}


void drawSpaceOutlines() {
    glColor3f(1.0f,1.0f,1.0f);
    glBegin(GL_LINES);
    glVertex3f(-(WSIZEX/2)*MCX,-(WSIZEY/2)*MCY,-(WSIZEZ/2)*MCZ);
    glVertex3f((-(WSIZEX/2)+(WSIZEX-1))*MCX,-(WSIZEY/2)*MCY,-(WSIZEZ/2)*MCZ);

    glVertex3f(-(WSIZEX/2),-(WSIZEY/2)+(WSIZEY-1),-(WSIZEZ/2));
    glVertex3f(-(WSIZEX/2)+(WSIZEX-1),-(WSIZEY/2)+(WSIZEY-1),-(WSIZEZ/2));

    glVertex3f(-(WSIZEX/2),-(WSIZEY/2)+(WSIZEY-1),-(WSIZEZ/2)+(WSIZEZ-1));
    glVertex3f(-(WSIZEX/2)+(WSIZEX-1),-(WSIZEY/2)+(WSIZEY-1),-(WSIZEZ/2)+(WSIZEZ-1));

    glVertex3f(-(WSIZEX/2),-(WSIZEY/2),-(WSIZEZ/2)+(WSIZEZ-1));
    glVertex3f(-(WSIZEX/2)+(WSIZEX-1),-(WSIZEY/2),-(WSIZEZ/2)+(WSIZEZ-1));

    glVertex3f(-(WSIZEX/2),-(WSIZEY/2),-(WSIZEZ/2));
    glVertex3f(-(WSIZEX/2),-(WSIZEY/2)+(WSIZEY-1),-(WSIZEZ/2));

    glVertex3f(-(WSIZEX/2)+(WSIZEX-1),-(WSIZEY/2),-(WSIZEZ/2));
    glVertex3f(-(WSIZEX/2)+(WSIZEX-1),-(WSIZEY/2)+(WSIZEY-1),-(WSIZEZ/2));

    glVertex3f(-(WSIZEX/2)+(WSIZEX-1),-(WSIZEY/2),-(WSIZEZ/2)+(WSIZEZ-1));
    glVertex3f(-(WSIZEX/2)+(WSIZEX-1),-(WSIZEY/2)+(WSIZEY-1),-(WSIZEZ/2)+(WSIZEZ-1));

    glVertex3f(-(WSIZEX/2),-(WSIZEY/2),-(WSIZEZ/2)+(WSIZEZ-1));
    glVertex3f(-(WSIZEX/2),-(WSIZEY/2)+(WSIZEY-1),-(WSIZEZ/2)+(WSIZEZ-1));

    glVertex3f(-(WSIZEX/2),-(WSIZEY/2),-(WSIZEZ/2));
    glVertex3f(-(WSIZEX/2),-(WSIZEY/2),-(WSIZEZ/2)+(WSIZEZ-1));

    glVertex3f(-(WSIZEX/2)+(WSIZEX-1),-(WSIZEY/2),-(WSIZEZ/2));
    glVertex3f(-(WSIZEX/2)+(WSIZEX-1),-(WSIZEY/2),-(WSIZEZ/2)+(WSIZEZ-1));

    glVertex3f(-(WSIZEX/2)+(WSIZEX-1),-(WSIZEY/2)+(WSIZEY-1),-(WSIZEZ/2));
    glVertex3f(-(WSIZEX/2)+(WSIZEX-1),-(WSIZEY/2)+(WSIZEY-1),-(WSIZEZ/2)+(WSIZEZ-1));

    glVertex3f(-(WSIZEX/2),-(WSIZEY/2)+(WSIZEY-1),-(WSIZEZ/2));
    glVertex3f(-(WSIZEX/2),-(WSIZEY/2)+(WSIZEY-1),-(WSIZEZ/2)+(WSIZEZ-1));
    glEnd();
}

void drawSpacePoints() {
    int x,y,z;
    glColor3f(1.0f,1.0f,1.0f);
    glBegin(GL_POINTS);
    for(x=0; x<WSIZEX; x++) {
	for(y=0; y<WSIZEY; y++) {
	    for(z=0; z<WSIZEZ; z++) {
		glVertex3f((x-(WSIZEX/2))*MCX,(y-(WSIZEY/2))*MCY,(z-(WSIZEZ/2))*MCZ);
	    }
	}
    }
    glEnd();
}
