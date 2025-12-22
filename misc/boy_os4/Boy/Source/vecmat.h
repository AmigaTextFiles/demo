/*
    Assorted vector and matrix operations

    9.8.2005: The first version
*/

#ifndef VECMAT_H
#define VECMAT_H

#define MAXDIM 4 /* Used for some temp array sizes */

#include <math.h>

void vm_cpy(int dim,double *src,double *dest);
#define vm_copy3(a,b) vm_cpy(3,a,b)
#define vm_cpy3(a,b) vm_cpy(3,a,b)

/* For add and sub the result gets stored in a */
void vm_add(int dim,double *a,double *b);
#define vm_add3(a,b) vm_add(3,a,b);

void vm_sub(int dim,double *a,double *b);
#define vm_sub3(a,b) vm_sub(3,a,b);

void vm_zero(int dim,double *a);
#define vm_zero3(a) vm_zero(3,a)

void vm_mul(int dim,double *a,double multiplier);
#define vm_mul3(a,b) vm_mul(3,a,b);

double vm_dotprod(int dim,double *a,double *b);
#define vm_dotprod3(a,b) vm_dotprod(3,a,b)

void vm_crossprod3(double *a,double *b,double *result);

double vm_length(int dim,double *a);
#define vm_length3(a) vm_length(3,a)

void vm_normalize(int dim,double *a);
#define vm_normalize3(a) vm_normalize(3,a)

void vm_neg(int dim,double *a);
#define vm_neg3(a) vm_neg(3,a)

#endif
