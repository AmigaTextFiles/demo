#include <exec/types.h>
#include <exec/memory.h>
#include "threed.h"

extern struct Object Camera1;
extern struct UV camera1matrix;
extern struct Coordinate camera1position;

extern int camera1procedure();

struct Object Camera1 =
{
    NULL,
    NULL,
    &camera1matrix,
    &camera1position,
    0,NULL,
    0,NULL,
    0,NULL,
    NULL
};

struct UV camera1matrix =
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

struct Coordinate camera1position =
{
    0,
    0,
    0
};
