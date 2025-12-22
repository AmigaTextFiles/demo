#define UP 0
#define DOWN 1
#define OFF 0
#define ON 1

#define LEFT 32 

#define NTSC_TOP 4
#define PAL_TOP 0

#define WIDTH 256

#define NTSC_HEIGHT 192
#define PAL_HEIGHT 256

#define TMPWIDTH 512
#define TMPHEIGHT 512

#define NTSC_MAXHINOLACE 200
#define PAL_MAXHINOLACE 256

#define NTSC_MAXHILACE 400
#define PAL_MAXHILACE 512

#define N_BIT_PLANES 3
#define MAXNUMCOLORS 32
#define MAXNUMARGS 16

#define SINA 0x0400
#define COSA 0x3FE0
#define SINB 0x0100
#define COSB 0x3FFE

#define NULLPROC 0
#define ADDVECT   1
#define SUBVECT 2
#define ROLL 3
#define PITCH 4
#define YAW 5
#define TRANSPOSE 6

struct UV 
{
    WORD uv11;
    WORD uv12;
    WORD uv13;
    WORD uv21;
    WORD uv22;
    WORD uv23;
    WORD uv31;
    WORD uv32;
    WORD uv33;
};

struct Coordinate
{
    WORD x;
    WORD y;
    WORD z;
};

struct Polygon
{
    WORD vertexcount;
    struct Coordinate *(*vertexstart)[];
    struct Coordinate *normalvector;
    WORD polycolor;
};

struct Object
{
    struct Object *nextobject;
    struct Object *subobject;
    struct UV *umatrix;
    struct Coordinate *position;
    WORD pointcount;
    struct Coordinate *(*pointstart)[];
    WORD normalcount;
    struct Coordinate *(*normalstart)[];
    WORD polycount;
    struct Polygon *(*polystart)[];
    APTR procedure;
};

struct Objectinfo {
    struct Objectinfo *nextobjectinfo;
    struct Objectinfo *subobjectinfo;
    struct UV *objectmatrix;
    struct Coordinate *objectposition;
    WORD objectnumpoints;
    struct Coordinate **objectpoints;
    WORD objectnumnormals;
    struct Coordinate **objectnormals;
    WORD objectnumpolys;
    struct Polygon **objectpolys;
    struct UV *displaymatrix;
    struct Coordinate *displayposition;
    WORD objectbufpointsize;
    struct Coordinate *objectbufpoints;
    WORD objectbufnormalsize;
    struct Coordinate *objectbufnormals;
    WORD pptrbufsize;
    struct Coordinate *pptrbuf;
    WORD nptrbufsize;
    struct Coordinate *nptrbuf;
    WORD colorbufsize;
    struct WORD *colorbuf;
    APTR objectprocedure;
};

