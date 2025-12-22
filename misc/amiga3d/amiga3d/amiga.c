#include <exec/types.h>
#include "threed.h"

extern struct Object Universe;
extern struct UV universematrix;
extern struct Coordinate universeposition;

extern int universeprocedure();

extern struct Object AmigaObject;
extern struct UV amigamatrix;
extern struct Coordinate amigaposition;
extern struct Coordinate *amigapoints[];
extern struct Coordinate *amiganormals[];
extern struct Polygon *amigapolygons[];

extern int amigaprocedure();

struct Object Universe =
{
    NULL,
    &AmigaObject,
    &universematrix,
    &universeposition,
    0,NULL,
    0,NULL,
    0,NULL,
    NULL
};

struct Object *UniverseObject = &Universe;

struct UV universematrix =
{
    0x4000,
    0x0000,
    0x0000,
    0x0000,
    0x4000,
    0x0000,
    0x0000,
    0x0000,
    0x4000
};

struct Coordinate universeposition =
{
    0,
    0,
    0
};

struct Object AmigaObject =
{
    NULL,
    NULL,
    &amigamatrix,
    &amigaposition,
    54,amigapoints,
    8,amiganormals,
    11,amigapolygons,
    amigaprocedure
};


struct UV amigamatrix =
{
    0x4000,
    0x0000,
    0x0000,
    0x0000,
    0x4000,
    0x0000,
    0x0000,
    0x0000,
    0x4000
};


struct Coordinate amigaposition =
{
    0xfff8,
    0xffe8,
    0xfc60
};

struct Coordinate p0 =
{
    0xfef8,
    0xffd0,
    0xffe8
};

struct Coordinate p1 =
{
    0xfef8,
    0x0048,
    0xffe8
};

struct Coordinate p2 =
{
    0x0120,
    0x0048,
    0xffe8
};

struct Coordinate p3 =
{
    0x0120,
    0xffd0,
    0xffe8
};

struct Coordinate p4 =
{
    0xfef8,
    0xffd0,
    0x0018
};

struct Coordinate p5 =
{
    0xfef8,
    0x0048,
    0x0018
};

struct Coordinate p6 =
{
    0x0120,
    0x0048,
    0x0018
};

struct Coordinate p7 =
{
    0x0120,
    0xffd0,
    0x0018
};

struct Coordinate p8 =
{
    0xff40,
    0xffe8,
    0xffc8
};

struct Coordinate p9 =
{
    0xff30,
    0x0000,
    0xffc8
};

struct Coordinate p10 =
{
    0xff08,
    0x0000,
    0xffc8
};

struct Coordinate p11 =
{
    0xff20,
    0x0018,
    0xffc8
};

struct Coordinate p12 =
{
    0xff10,
    0x0030,
    0xffc8
};

struct Coordinate p13 =
{
    0xff30,
    0x0030,
    0xffc8
};

struct Coordinate p14 =
{
    0xff40,
    0x0018,
    0xffc8
};

struct Coordinate p15 =
{
    0xff50,
    0x0030,
    0xffc8
};

struct Coordinate p16 =
{
    0xff70,
    0x0030,
    0xffc8
};

struct Coordinate p17 =
{
    0xff88,
    0xffe8,
    0xffc8
};

struct Coordinate p18 =
{
    0xff88,
    0x0030,
    0xffc8
};

struct Coordinate p19 =
{
    0xffa8,
    0x0030,
    0xffc8
};

struct Coordinate p20 =
{
    0xffa8,
    0x0018,
    0xffc8
};

struct Coordinate p21 =
{
    0xffb8,
    0x0020,
    0xffc8
};

struct Coordinate p22 =
{
    0xffc8,
    0x0018,
    0xffc8
};

struct Coordinate p23 =
{
    0xffc8,
    0x0030,
    0xffc8
};

struct Coordinate p24 =
{
    0xffe8,
    0x0030,
    0xffc8
};

struct Coordinate p25 =
{
    0xffe8,
    0xffe8,
    0xffc8
};

struct Coordinate p26 =
{
    0xffb8,
    0x0000,
    0xffc8
};

struct Coordinate p27 =
{
    0x0000,
    0x0000,
    0xffc8
};

struct Coordinate p28 =
{
    0x0000,
    0x0030,
    0xffc8
};

struct Coordinate p29 =
{
    0x0018,
    0x0030,
    0xffc8
};

struct Coordinate p30 =
{
    0x0018,
    0xffe8,
    0xffc8
};

struct Coordinate p31 =
{
    0x0048,
    0xffe8,
    0xffc8
};

struct Coordinate p32 =
{
    0x0030,
    0x0000,
    0xffc8
};

struct Coordinate p33 =
{
    0x0030,
    0x0018,
    0xffc8
};

struct Coordinate p34 =
{
    0x0048,
    0x0030,
    0xffc8
};

struct Coordinate p35 =
{
    0x0078,
    0x0030,
    0xffc8
};

struct Coordinate p36 =
{
    0x0088,
    0x0018,
    0xffc8
};

struct Coordinate p37 =
{
    0x00a0,
    0x0018,
    0xffc8
};

struct Coordinate p38 =
{
    0x0090,
    0x0008,
    0xffc8
};

struct Coordinate p39 =
{
    0x0068,
    0x0008,
    0xffc8
};

struct Coordinate p40 =
{
    0x0078,
    0x0018,
    0xffc8
};

struct Coordinate p41 =
{
    0x0060,
    0x0018,
    0xffc8
};

struct Coordinate p42 =
{
    0x0048,
    0x0000,
    0xffc8
};

struct Coordinate p43 =
{
    0x0060,
    0x0000,
    0xffc8
};

struct Coordinate p44 =
{
    0x0078,
    0xffe8,
    0xffc8
};

struct Coordinate p45 =
{
    0x00d8,
    0xffe8,
    0xffc8
};

struct Coordinate p46 =
{
    0x00c8,
    0x0000,
    0xffc8
};

struct Coordinate p47 =
{
    0x00a0,
    0x0000,
    0xffc8
};

struct Coordinate p48 =
{
    0x00b8,
    0x0018,
    0xffc8
};

struct Coordinate p49 =
{
    0x00a8,
    0x0030,
    0xffc8
};

struct Coordinate p50 =
{
    0x00c8,
    0x0030,
    0xffc8
};

struct Coordinate p51 =
{
    0x00d8,
    0x0010,
    0xffc8
};

struct Coordinate p52 =
{
    0x00e8,
    0x0030,
    0xffc8
};

struct Coordinate p53 =
{
    0x0108,
    0x0030,
    0xffc8
};

struct Coordinate *amigapoints[54] =
{
    &p0,
    &p1,
    &p2,
    &p3,
    &p4,
    &p5,
    &p6,
    &p7,
    &p8,
    &p9,
    &p10,
    &p11,
    &p12,
    &p13,
    &p14,
    &p15,
    &p16,
    &p17,
    &p18,
    &p19,
    &p20,
    &p21,
    &p22,
    &p23,
    &p24,
    &p25,
    &p26,
    &p27,
    &p28,
    &p29,
    &p30,
    &p31,
    &p32,
    &p33,
    &p34,
    &p35,
    &p36,
    &p37,
    &p38,
    &p39,
    &p40,
    &p41,
    &p42,
    &p43,
    &p44,
    &p45,
    &p46,
    &p47,
    &p48,
    &p49,
    &p50,
    &p51,
    &p52,
    &p53
};

struct Coordinate n0 =
{
    0x0000,
    0x0000,
    0xc000
};

struct Coordinate n1 =
{
    0x4000,
    0x0000,
    0x0000
};

struct Coordinate n2 =
{
    0x0000,
    0x0000,
    0x4000
};

struct Coordinate n3 =
{
    0xc000,
    0x0000,
    0x0000
};

struct Coordinate n4 =
{
    0x0000,
    0xc000,
    0x0000
};

struct Coordinate n5 =
{
    0x0000,
    0x4000,
    0x0000
};

struct Coordinate n6 =
{
    0x0000,
    0x0000,
    0xc000
};

struct Coordinate n7 =
{
    0x0000,
    0x0000,
    0xc000
};

struct Coordinate *amiganormals[8] =
{
    &n0,
    &n1,
    &n2,
    &n3,
    &n4,
    &n5,
    &n6,
    &n7
};

struct Coordinate *v0[4] =
{
    &p0,
    &p1,
    &p2,
    &p3
};

struct Coordinate *v1[4] =
{
    &p3,
    &p2,
    &p6,
    &p7
};

struct Coordinate *v2[4] =
{
    &p7,
    &p6,
    &p5,
    &p4
};

struct Coordinate *v3[4] =
{
    &p4,
    &p5,
    &p1,
    &p0
};

struct Coordinate *v4[4] =
{
    &p4,
    &p0,
    &p3,
    &p7
};

struct Coordinate *v5[4] =
{
    &p2,
    &p1,
    &p5,
    &p6
};

struct Coordinate *v6[9] =
{
    &p9,
    &p10,
    &p11,
    &p12,
    &p13,
    &p14,
    &p15,
    &p16,
    &p8
};

struct Coordinate *v7[10] =
{
    &p17,
    &p18,
    &p19,
    &p20,
    &p21,
    &p22,
    &p23,
    &p24,
    &p25,
    &p26
};

struct Coordinate *v8[4] =
{
    &p27,
    &p28,
    &p29,
    &p30
};

struct Coordinate *v9[14] =
{
    &p31,
    &p32,
    &p33,
    &p34,
    &p35,
    &p36,
    &p37,
    &p38,
    &p39,
    &p40,
    &p41,
    &p42,
    &p43,
    &p44
};

struct Coordinate *v10[9] =
{
    &p46,
    &p47,
    &p48,
    &p49,
    &p50,
    &p51,
    &p52,
    &p53,
    &p45
};

struct Polygon f0 =
{
    4,
    v0,
    &n7,
    7
};

struct Polygon f1 =
{
    4,
    v1,
    &n1,
    1
};

struct Polygon f2 =
{
    4,
    v2,
    &n2,
    2
};

struct Polygon f3 =
{
    4,
    v3,
    &n3,
    3
};

struct Polygon f4 =
{
    4,
    v4,
    &n4,
    4
};

struct Polygon f5 =
{
    4,
    v5,
    &n5,
    5
};

struct Polygon f6 =
{
    9,
    v6,
    &n6,
    6
};

struct Polygon f7 =
{
    10,
    v7,
    &n6,
    6
};

struct Polygon f8 =
{
    4,
    v8,
    &n6,
    6
};

struct Polygon f9 =
{
    14,
    v9,
    &n6,
    6
};

struct Polygon f10 =
{
    9,
    v10,
    &n6,
    6
};

struct Polygon *amigapolygons[11] =
{
    &f0,
    &f1,
    &f2,
    &f3,
    &f4,
    &f5,
    &f6,
    &f7,
    &f8,
    &f9,
    &f10
};

