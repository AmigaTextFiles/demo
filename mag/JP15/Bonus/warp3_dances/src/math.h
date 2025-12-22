
// dizaster (das pestonos) math


typedef struct{
    float x,y,z;
    float sx,sy;
}vertex;


float   rot_x[4][4],rot_y[4][4],rot_z[4][4];

float   Transform_m[4][4]=
{
{1,0,0,0},
{0,1,0,0},
{0,0,1,0},
{0,0,0,1}
};



void project (vertex *v)
{

  int fFOV=width;

  v->sx = width /2 + v->x * fFOV / (v->z + fFOV);
  v->sy = height/2 - v->y * fFOV / (v->z + fFOV);

}


void BuildRotateX(float AngleX)
{
    float sine = (float)sin(AngleX);
    float cosine = (float)cos(AngleX);

    rot_x[0][0] = 1.0;
    rot_x[1][1] = cosine;
    rot_x[1][2] = sine;
    rot_x[2][1] = -sine;
    rot_x[2][2] = cosine;
    rot_x[3][3] = 1.0;
}




void BuildRotateY(float AngleY)
{
    float sine = (float)sin(AngleY);
    float cosine = (float)cos(AngleY);

    rot_y[0][0] = cosine;
    rot_y[0][2] = -sine;
    rot_y[1][1] = 1.0;
    rot_y[2][0] = sine;
    rot_y[2][2] = cosine;
    rot_y[3][3] = 1.0;
}





void BuildRotateZ(float AngleZ)
{
    float sine = (float)sin(AngleZ);
    float cosine = (float)cos(AngleZ);

    rot_z[0][0] = cosine;
    rot_z[0][1] = -sine;
    rot_z[1][0] = sine;
    rot_z[1][1] = cosine;
    rot_z[2][2] = 1.0;
    rot_z[3][3] = 1.0;
}


void MulMatrix4x4(float *a,float *b,float *c)
{
    float t[16];
    int i,j;

    for (i=0;i<4*4;i+=4)
        for (j=0;j<4;j++){
            t[i+j] = a[i]*b[j]+a[i+1]*b[j+4]+a[i+2]*b[j+8]+a[i+3]*b[j+12];
        }


    for (i=0;i<4*4;i++)
         c[i]=t[i];
}



void BuildTransMatrix(float x_angle,float y_angle,float z_angle)
{
    BuildRotateX(x_angle);
    BuildRotateY(y_angle);
    BuildRotateZ(z_angle);

    MulMatrix4x4(&Transform_m[0][0],&rot_x[0][0],&Transform_m[0][0]);
    MulMatrix4x4(&Transform_m[0][0],&rot_y[0][0],&Transform_m[0][0]);
    MulMatrix4x4(&Transform_m[0][0],&rot_z[0][0],&Transform_m[0][0]);
}



// a - out
// b - in
void TransformPoint(vertex *a, vertex *b)
{

    a->x=b->x*Transform_m[0][0]+b->y*Transform_m[1][0]+b->z*Transform_m[2][0]+1*Transform_m[3][0];
    a->y=b->x*Transform_m[0][1]+b->y*Transform_m[1][1]+b->z*Transform_m[2][1]+1*Transform_m[3][1];
    a->z=b->x*Transform_m[0][2]+b->y*Transform_m[1][2]+b->z*Transform_m[2][2]+1*Transform_m[3][2];
}

