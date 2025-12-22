
#ifndef CGM_H
#define CGM_H

#define CGM_COLORMAX 200    /* Maximum number of distinct colors */

#define CGM_POLYLINE 1
#define CGM_POLYGON  2

typedef struct element_t
{
    int types,
        linewidth,
        color,
        linecolor,
        tris,
        points;

    int *pointsv,
        *trisv;

    struct element_t    *next;

} ELEMENT;

typedef struct cgm_t
{
    long    pal[CGM_COLORMAX],
            colors,
            back;

    ELEMENT *head;

} CGM;

CGM *cgm_load(char *name);

#endif
