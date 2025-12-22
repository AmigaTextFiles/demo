#ifndef _MCUBES_H
#define _MCUBES_H

#define WSIZEX 16
#define WSIZEY 16
#define WSIZEZ 16


#define MAXKOLMIOT 15
#define KORJATTU 256

void setMCX(float x);
void setMCY(float y);
void setMCZ(float z);
void mc_init();
void mc_update(float time);
void drawCube(float corner[],float x,float y,float z);
void mc_drawCubes(float time);
void vert01(float corner[],float x,float y,float z,float raja);
void vert03(float corner[],float x,float y,float z,float raja);
void vert04(float corner[],float x,float y,float z,float raja);
void vert12(float corner[],float x,float y,float z,float raja);
void vert15(float corner[],float x,float y,float z,float raja);
void vert23(float corner[],float x,float y,float z,float raja);
void vert26(float corner[],float x,float y,float z,float raja);
void vert37(float corner[],float x,float y,float z,float raja);
void vert45(float corner[],float x,float y,float z,float raja);
void vert47(float corner[],float x,float y,float z,float raja);
void vert56(float corner[],float x,float y,float z,float raja);
void vert67(float corner[],float x,float y,float z,float raja);
void drawEdgeVert(int edge,float cube[],float x,float y,float z,float raja);
void drawSpaceOutlines();
void drawSpacePoints();
void mc_drawBoxes(float time);


#endif
