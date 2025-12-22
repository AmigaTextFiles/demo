/*
    Catmull-Rom splines, implementation

    - Marq
*/

#include <math.h>
#include "catmull-rom.h"

void catmull_rom(CM_TYPE pos,int points,CM_TYPE p[][CM_DEPTH],CM_TYPE *d)
{
    CM_TYPE t;
    int     i,n,segments=points-3;

    if(points<4)
        return;

    t=pos*(CM_TYPE)segments;
    i=(int)t;
    t=fmod(t,1);

    if(i+3==points)
    {
        i--;
        t=1.0;
    }

    for(n=0;n<CM_DEPTH;n++)
        d[n]=0.5 * ((2.0*p[i+1][n]) +
                    (-p[i][n] +p[i+2][n])*t +
                    (2.0*p[i][n] -5.0*p[i+1][n] +4.0*p[i+2][n] -p[i+3][n])*t*t +
                    (-p[i][n] +3.0*p[i+1][n] -3.0*p[i+2][n] +p[i+3][n])*t*t*t);
}
