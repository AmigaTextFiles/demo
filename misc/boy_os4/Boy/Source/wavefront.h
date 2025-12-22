
#ifndef WAVEFRONT_H
#define WAVEFRONT_H

#include <math.h>

#define TYPE_OBJECT 1
#define TYPE_PIVOT 2
#define TYPE_POINT 3

#define BIG_NUMBER 100000.0 /* Used for min/max initial values */

typedef struct mtl_type
{
    float   ambient[4],
            diffuse[4],
            specular[4],
            opacity,
            shininess;

    int tnumber,
        tx,ty;

    unsigned char *texture;

    char name[1000],
         tname[1000];

    struct mtl_type *next;
} MTL;

typedef struct face_type
{
    int     num,
            *index,
            *normal,
            *tcoord;

    struct face_type *next;
} FACE;

typedef struct part_type
{
    FACE    *faces;
    MTL     *material;
    int     dlist;

    char    name[1000];

    struct part_type *next;
} PART;

typedef struct obj_type
{
    int     type;

    PART    *parts;

    char    name[1000];

    struct obj_type *next,
                    *pivot;

    float   rot,        /* Parameters for glRotate (used with pivot) */
            x,y,z;
    float   tx,ty,tz;   /* Parameters for glTranslate (pivot) */

    float   bx[2],      /* Bounding box for the object (min,max) pairs */
            by[2],
            bz[2];
} OBJ;

typedef struct scene_type
{
    float   *v,
            *vn,
            *vt;

    int     vs,
            vns,
            vts,
            lighting;

    OBJ     *objects;

    MTL     *materials;
} SCENE;

int load_scene(SCENE *s,char *name);
int get_scene(SCENE *s,char *obj,char *mtl);
void delete_scene(SCENE *s);
void pivot_vectors(SCENE *s,OBJ *o);
OBJ *find_object(SCENE *s,char *name);
unsigned char *load_texture(char *name,int *x,int *y);
void set_path(char *path);

#endif
