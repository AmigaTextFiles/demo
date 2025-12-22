/*
    Catmull-Rom splines, interface
    Thanks to Robert Dunlop for the explanation

    - Marq
*/

#ifndef CATMULL_ROM_H
#define CATMULL_ROM_H

#define CM_DEPTH 3
typedef float CM_TYPE;

/* pos=[0..1], p[points][CM_DEPTH]=coordinates, d=value at that point */
void catmull_rom(CM_TYPE pos,int points,CM_TYPE p[][CM_DEPTH],CM_TYPE *d);

#endif
