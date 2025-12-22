
#include "catmull-rom.h"
#include "stripe.h"
#include "wavefront.h"
#include "vecmat.h"
#include <stdlib.h>
#include <SDL_opengl.h>
#include <math.h>

#define PTS 50
#define PTS2 1000

static float s[PTS][3],s2[PTS][3];
static float h[PTS2][3],h2[PTS2][3];
static SCENE head;

/* Test whether a 2D point p lies inside a triangle defined by v1, v2 and v3.
   Can be used for 3D case as well after projection */
int in2d(double *v1,double *v2,double *v3,double *p)
{
    double   normal[2];
    double   tmp[2];

    vm_cpy(2,v2,tmp); vm_sub(2,tmp,v1);
    normal[0]=-tmp[1]; normal[1]=tmp[0];
    vm_cpy(2,p,tmp); vm_sub(2,tmp,v1);
    if(vm_dotprod(2,tmp,normal)<=0)
        return(0);

    vm_cpy(2,v3,tmp); vm_sub(2,tmp,v2);
    normal[0]=-tmp[1]; normal[1]=tmp[0];
    vm_cpy(2,p,tmp); vm_sub(2,tmp,v2);
    if(vm_dotprod(2,tmp,normal)<=0)
        return(0);

    vm_cpy(2,v1,tmp); vm_sub(2,tmp,v3);
    normal[0]=-tmp[1]; normal[1]=tmp[0];
    vm_cpy(2,p,tmp); vm_sub(2,tmp,v3);
    if(vm_dotprod(2,tmp,normal)<=0)
        return(0);

    return(1);
}

/* Intersection of ray going throug p1 and p2 with plane defined by
   v1, v2 and v3. Returns 0 upon no intersection, otherwise isect
   contains the point of intersection. */
int intersect(double *v1,double *v2,double *v3,double *p1,double *p2,double *isect)
{
    double   u=0,n,d,
            tmp[3],tmp2[3],
            r1[2],r2[2],r3[3],i[3],
            normal[3],absn[3];

    int     j;

    vm_cpy3(v1,tmp);
    vm_cpy3(v3,tmp2);
    vm_sub3(tmp,v2);
    vm_sub3(tmp2,v2);
    vm_crossprod3(tmp2,tmp,normal);

    vm_cpy3(p2,tmp);
    vm_sub3(tmp,p1);
    vm_cpy3(v1,tmp2);
    vm_sub3(tmp2,p1);

    d=vm_dotprod3(normal,tmp);
    if(fabs(d)<=0.0001)
        return(0);

    n=vm_dotprod3(normal,tmp2);
    u=n/d;
    if(u<0)
        return(0);

    vm_cpy3(p2,tmp);
    vm_sub3(tmp,p1);
    vm_mul3(tmp,u);
    vm_add3(tmp,p1);
    vm_cpy3(tmp,isect);

    /* Select the plane we're projecting to */
    for(j=0;j<3;j++)
        absn[j]=fabs(normal[j]);

    if(absn[2]>absn[0] && absn[2]>absn[1]) // Z
    {
        r1[0]=v1[0]; r1[1]=v1[1];
        r2[0]=v2[0]; r2[1]=v2[1];
        r3[0]=v3[0]; r3[1]=v3[1];
        i[0]=isect[0]; i[1]=isect[1];

        if(normal[2]>0) {
            if(in2d(r1,r2,r3,i))
                return(1);
        }
        else {
            if(in2d(r1,r3,r2,i))
                return(1);
        }
    }

    if(absn[0]>absn[1] && absn[0]>absn[2]) // X
    {
        r1[0]=v1[1]; r1[1]=v1[2];
        r2[0]=v2[1]; r2[1]=v2[2];
        r3[0]=v3[1]; r3[1]=v3[2];
        i[0]=isect[1]; i[1]=isect[2];

        if(normal[0]>0) {
            if(in2d(r1,r2,r3,i))
                return(1);
        }
        else {
            if(in2d(r1,r3,r2,i))
                return(1);
        }
    }

    r1[0]=v1[2]; r1[1]=v1[0]; // Y
    r2[0]=v2[2]; r2[1]=v2[0];
    r3[0]=v3[2]; r3[1]=v3[0];
    i[0]=isect[2]; i[1]=isect[0];

    if(normal[1]>0) {
        if(in2d(r1,r2,r3,i))
            return(1);
    }
    else {
        if(in2d(r1,r3,r2,i))
            return(1);
    }

    return(0);
}

/* Find surface depth for a point */
double surface(SCENE *s,double x,double y,double z)
{
    OBJ *o;
    PART *p;
    FACE *f;
    double  p1[3],p2[3],v[3][3],i[3],r=0,t;
    int n;

    p1[0]=0; p2[0]=x;
    p1[1]=   p2[1]=y;
    p1[2]=0; p2[2]=z;

    o=s->objects;
    while(o)
    {
        p=o->parts;
        while(p)
        {
            f=p->faces;
            while(f)
            {
                for(n=0;n<3;n++)
                {
                    v[n][0]=s->v[f->index[n]*3];
                    v[n][1]=s->v[f->index[n]*3+1];
                    v[n][2]=s->v[f->index[n]*3+2];
                }
                if(v[0][1]>y && v[1][1]>y && v[2][1]>y)
                    goto neekst;
                if(v[0][1]<y && v[1][1]<y && v[2][1]<y)
                    goto neekst;

                if(intersect(v[0],v[1],v[2],p1,p2,i))
                {
                    t=sqrt(i[0]*i[0]+i[2]*i[2]);
                    if(t>r)
                        r=t;
                }

                neekst:
                f=f->next;
            }
            p=p->next;
        }
        o=o->next;
    }

    return(r);
}

void stripe_init(void)
{
    int n;
    double  d,r,r2,e,t;
    float   prev[3]={0,0,0};
    static int  firstinit=1;

    for(n=0;n<PTS;n++)
    {
        r=0.7;
        s[n][0]=sin(rand()%10+n)*r;
        s[n][1]=cos(n*1.3)*r+0.3;
        s[n][2]=sin(n*1.7+rand()%20)*r;

        s2[n][0]=s[n][0]+0;
        s2[n][1]=s[n][1]+0.2;
        s2[n][2]=s[n][2]-0.1;

        prev[0]=s[n][0];
        prev[1]=s[n][1];
        prev[2]=s[n][2];
    }

    // Calculate curve for the head
    if(firstinit)
    {
        firstinit=0;
        load_scene(&head,"larvi.obj");
    
        d=0;
        for(n=0;n<PTS2;n++)
        {
            e=1.8-n*3.8/PTS2;
            e+=sin(d*1.6+e*2.0)*0.03;
    
            r=surface(&head,sin(d)*4,e,cos(d)*4);
            r2=surface(&head,sin(d)*4,e+0.15,cos(d)*4);
    
            h[n][0]=sin(d)*r;
            h[n][1]=e;
            h[n][2]=cos(d)*r;
    
            h2[n][0]=sin(d)*r2;
            h2[n][1]=e+0.15;
            h2[n][2]=cos(d)*r2;
    
            d+=32*M_PI/PTS2;
        }
    }
}

void stripe(int tid)
{
    double  d,w,ws=0;
    float   f[3],f2[3],t;
    int n,i,j;

    d=tid/15.0;
    if(d>1000.0)
        d=1000.0;
    if(d<0)
        d=0;

    glDisable(GL_CULL_FACE);
    glEnable(GL_DEPTH_TEST);

    // Brain
    glPushMatrix();
    glRotatef(tid/100.0,0,1,0);
    for(i=0;i<9;i++)
    {
        if(i&1)
        {
            glColor3f(0.8,0,0);
            w=0.2;
        }
        else
        {
            glColor3f(1,1,1);
            w=0.05;
        }

        glBegin(GL_QUAD_STRIP);
        for(n=0;n<d;n++)
        {
            catmull_rom(n/1000.0,PTS,s,f);
            catmull_rom(n/1000.0,PTS,s2,f2);
            for(j=0;j<3;j++)
            {
                t=f2[j]-f[j];
                f2[j]=f[j]+t*(ws+w);
                f[j]+=t*ws;
            }
            glVertex3fv(f);
            glVertex3fv(f2);
        }
        glEnd();
        ws+=w;
    }
    glPopMatrix();

    // Head
    ws=0;
    for(i=0;i<9;i++)
    {
        if(i&1)
        {
            glColor3f(0,0,0);
            w=0.2;
        }
        else
        {
            glColor3f(1,1,1);
            w=0.05;
        }

        glBegin(GL_QUAD_STRIP);
        for(n=0;n<d;n++)
        {
            catmull_rom(n/1000.0,PTS2,h,f);
            catmull_rom(n/1000.0,PTS2,h2,f2);
            for(j=0;j<3;j++)
            {
                t=f2[j]-f[j];
                f2[j]=f[j]+t*(ws+w);
                f[j]+=t*ws;
            }
            glVertex3fv(f);
            glVertex3fv(f2);
        }
        glEnd();
        ws+=w;
    }

    glDisable(GL_DEPTH_TEST);
}
