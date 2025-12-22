/*
    Assorted vector and matrix operations

    9.8.2005: The first version
*/

#include "vecmat.h"
#include <string.h>

void vm_cpy(int dim,double *src,double *dest)
{
    memcpy(dest,src,dim*sizeof(double));
}

void vm_add(int dim,double *a,double *b)
{
    int     n;
    for(n=0;n<dim;n++)
        a[n]+=b[n];
}

void vm_sub(int dim,double *a,double *b)
{
    int     n;
    for(n=0;n<dim;n++)
        a[n]-=b[n];
}

void vm_zero(int dim,double *a)
{
    int     n;
    for(n=0;n<dim;n++)
        a[n]=0.0;
}

void vm_mul(int dim,double *a,double multiplier)
{
    int     n;
    for(n=0;n<dim;n++)
        a[n]*=multiplier;
}

double vm_dotprod(int dim,double *a,double *b)
{
    double   sum=0;
    int     n;

    for(n=0;n<dim;n++)
        sum+=a[n]*b[n];

    return(sum);
}

void vm_crossprod3(double *a,double *b,double *result)
{
    result[0]=a[1]*b[2]-a[2]*b[1];
    result[1]=a[2]*b[0]-a[0]*b[2];
    result[2]=a[0]*b[1]-a[1]*b[0];
}

double vm_length(int dim,double *a)
{
    double   sum=0;
    int     n;

    for(n=0;n<dim;n++)
        sum+=a[n]*a[n];

    return(sqrt(sum));
}

void vm_normalize(int dim,double *a)
{
    double   len=vm_length(dim,a);
    int     n;

    for(n=0;n<dim;n++)
        a[n]/=len;
}

void vm_neg(int dim,double *a)
{
    int     n;
    for(n=0;n<dim;n++)
        a[n]=-a[n];
}
