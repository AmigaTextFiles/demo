#include <math.h>
#include <stdlib.h>
#include <limits.h>
#include <graphics/display.h>
#include "MainPart.h"
#include "CopperList.h"
#include "Sprite.h"
#include "Bitmap.h"
#include "AmigaHardware.h"
#include "Util.h"
#include "ModulePlayer.h"

#define BITPLANE_WIDTH 320
#define BITPLANE_HEIGHT 256
#define BITPLANE_SIZE (BITPLANE_WIDTH * BITPLANE_HEIGHT / 8)
#define BITPLANE_COUNT 4
#define SPHERE_WIDTH 512
#define SPHERE_HEIGHT 512
#define MODEL_DISTANCE 295
#define MODEL_MAX_DELTA_X 64
#define MODEL_MAX_DELTA_Y 32
#define SPRITE_MAX_DELTA 64

enum Sample {
    SampleBuzz = 4,
    SampleBassDrum = 5,
    SampleAmen1 = 8,
    SampleAmen2 = 9,
    SampleDrumLoop = 10
};

struct Coordinate {
    Coordinate();
    Coordinate(int16_t x, int16_t y, int16_t z);
    int16_t x, y, z, x_y;
};

Coordinate::Coordinate() :
    x(0),
    y(0),
    z(0),
    x_y(0)
{
}

Coordinate::Coordinate(int16_t x, int16_t y, int16_t z) :
    x(x),
    y(y),
    z(z),
    x_y(x * y)
{
}

struct RotatedCoordinate {
    RotatedCoordinate();
    RotatedCoordinate(int16_t x, int16_t y, int16_t z);
    int16_t x, y, z;
};

RotatedCoordinate::RotatedCoordinate() :
    x(0),
    y(0),
    z(0)
{
}

RotatedCoordinate::RotatedCoordinate(int16_t x, int16_t y, int16_t z) :
    x(x),
    y(y),
    z(z)
{
}

struct Face {
    uint16_t vertices;
    uint16_t *vertexOffsets;
};

struct Model {
    uint16_t numCoordinates;
    uint16_t numFaces;
    Coordinate* coordinates;
    Face* faces;
};

struct FaceData {
    Face* face;
    int16_t nx, ny, nz, nx_y;
    int16_t rnx, rny, rnz;
    int16_t z;
    bool visible;
};

Coordinate cubeCoordinates[] = {
    Coordinate(-25, -25, -25),
    Coordinate( 25, -25, -25),
    Coordinate( 25,  25, -25),
    Coordinate(-25,  25, -25),
    Coordinate(-25, -25,  25),
    Coordinate( 25, -25,  25),
    Coordinate( 25,  25,  25),
    Coordinate(-25,  25,  25)
};

uint16_t cubeFace1VertexOffsets[] = { 0, 1, 2, 3 };
uint16_t cubeFace2VertexOffsets[] = { 4, 7, 6, 5 };
uint16_t cubeFace3VertexOffsets[] = { 0, 4, 5, 1 };
uint16_t cubeFace4VertexOffsets[] = { 2, 6, 7, 3 };
uint16_t cubeFace5VertexOffsets[] = { 0, 3, 7, 4 };
uint16_t cubeFace6VertexOffsets[] = { 1, 5, 6, 2 };

Face cubeFaces[] = {
    { 4, cubeFace1VertexOffsets },
    { 4, cubeFace2VertexOffsets },
    { 4, cubeFace3VertexOffsets },
    { 4, cubeFace4VertexOffsets },
    { 4, cubeFace5VertexOffsets },
    { 4, cubeFace6VertexOffsets }
};

Model cubeModel = {
    8,
    6,
    cubeCoordinates,
    cubeFaces
};

Coordinate tetrahexahedronCoordinates[] = {
    Coordinate(-25, -25, -25),
    Coordinate( 25, -25, -25),
    Coordinate( 25,  25, -25),
    Coordinate(-25,  25, -25),
    Coordinate(-25, -25,  25),
    Coordinate( 25, -25,  25),
    Coordinate( 25,  25,  25),
    Coordinate(-25,  25,  25),
    Coordinate(  0,   0, -40),
    Coordinate(  0,   0,  40),
    Coordinate(  0, -40,   0),
    Coordinate(  0,  40,   0),
    Coordinate(-40,   0,   0),
    Coordinate( 40,   0,   0)
};

uint16_t tetrahexahedronFace01VertexOffsets[] = { 0, 1, 8 };
uint16_t tetrahexahedronFace02VertexOffsets[] = { 1, 2, 8 };
uint16_t tetrahexahedronFace03VertexOffsets[] = { 2, 3, 8 };
uint16_t tetrahexahedronFace04VertexOffsets[] = { 3, 0, 8 };
uint16_t tetrahexahedronFace05VertexOffsets[] = { 4, 9, 5 };
uint16_t tetrahexahedronFace06VertexOffsets[] = { 5, 9, 6 };
uint16_t tetrahexahedronFace07VertexOffsets[] = { 6, 9, 7 };
uint16_t tetrahexahedronFace08VertexOffsets[] = { 7, 9, 4 };
uint16_t tetrahexahedronFace09VertexOffsets[] = { 0, 4, 10 };
uint16_t tetrahexahedronFace10VertexOffsets[] = { 4, 5, 10 };
uint16_t tetrahexahedronFace11VertexOffsets[] = { 5, 1, 10 };
uint16_t tetrahexahedronFace12VertexOffsets[] = { 1, 0, 10 };
uint16_t tetrahexahedronFace13VertexOffsets[] = { 3, 11, 7 };
uint16_t tetrahexahedronFace14VertexOffsets[] = { 7, 11, 6 };
uint16_t tetrahexahedronFace15VertexOffsets[] = { 6, 11, 2 };
uint16_t tetrahexahedronFace16VertexOffsets[] = { 2, 11, 3 };
uint16_t tetrahexahedronFace17VertexOffsets[] = { 0, 12, 4 };
uint16_t tetrahexahedronFace18VertexOffsets[] = { 4, 12, 7 };
uint16_t tetrahexahedronFace19VertexOffsets[] = { 7, 12, 3 };
uint16_t tetrahexahedronFace20VertexOffsets[] = { 3, 12, 0 };
uint16_t tetrahexahedronFace21VertexOffsets[] = { 1, 5, 13 };
uint16_t tetrahexahedronFace22VertexOffsets[] = { 5, 6, 13 };
uint16_t tetrahexahedronFace23VertexOffsets[] = { 6, 2, 13 };
uint16_t tetrahexahedronFace24VertexOffsets[] = { 2, 1, 13 };

Face tetrahexahedronFaces[] = {
    { 3, tetrahexahedronFace01VertexOffsets },
    { 3, tetrahexahedronFace02VertexOffsets },
    { 3, tetrahexahedronFace03VertexOffsets },
    { 3, tetrahexahedronFace04VertexOffsets },
    { 3, tetrahexahedronFace05VertexOffsets },
    { 3, tetrahexahedronFace06VertexOffsets },
    { 3, tetrahexahedronFace07VertexOffsets },
    { 3, tetrahexahedronFace08VertexOffsets },
    { 3, tetrahexahedronFace09VertexOffsets },
    { 3, tetrahexahedronFace10VertexOffsets },
    { 3, tetrahexahedronFace11VertexOffsets },
    { 3, tetrahexahedronFace12VertexOffsets },
    { 3, tetrahexahedronFace13VertexOffsets },
    { 3, tetrahexahedronFace14VertexOffsets },
    { 3, tetrahexahedronFace15VertexOffsets },
    { 3, tetrahexahedronFace16VertexOffsets },
    { 3, tetrahexahedronFace17VertexOffsets },
    { 3, tetrahexahedronFace18VertexOffsets },
    { 3, tetrahexahedronFace19VertexOffsets },
    { 3, tetrahexahedronFace20VertexOffsets },
    { 3, tetrahexahedronFace21VertexOffsets },
    { 3, tetrahexahedronFace22VertexOffsets },
    { 3, tetrahexahedronFace23VertexOffsets },
    { 3, tetrahexahedronFace24VertexOffsets }
};

Model tetrahexahedronModel = {
    14,
    24,
    tetrahexahedronCoordinates,
    tetrahexahedronFaces
};

Coordinate diamondCoordinates[] = {
    Coordinate(-40, -17,   0),
    Coordinate(-17, -40,   0),
    Coordinate( 17, -40,   0),
    Coordinate( 40, -17,   0),
    Coordinate( 40,  17,   0),
    Coordinate( 17,  40,   0),
    Coordinate(-17,  40,   0),
    Coordinate(-40,  17,   0),
    Coordinate(  0,   0, -25),
    Coordinate(  0,   0,  25)
};

uint16_t diamondFace01VertexOffsets[] = { 0, 1, 8 };
uint16_t diamondFace02VertexOffsets[] = { 1, 2, 8 };
uint16_t diamondFace03VertexOffsets[] = { 2, 3, 8 };
uint16_t diamondFace04VertexOffsets[] = { 3, 4, 8 };
uint16_t diamondFace05VertexOffsets[] = { 4, 5, 8 };
uint16_t diamondFace06VertexOffsets[] = { 5, 6, 8 };
uint16_t diamondFace07VertexOffsets[] = { 6, 7, 8 };
uint16_t diamondFace08VertexOffsets[] = { 7, 0, 8 };
uint16_t diamondFace09VertexOffsets[] = { 1, 0, 9 };
uint16_t diamondFace10VertexOffsets[] = { 2, 1, 9 };
uint16_t diamondFace11VertexOffsets[] = { 3, 2, 9 };
uint16_t diamondFace12VertexOffsets[] = { 4, 3, 9 };
uint16_t diamondFace13VertexOffsets[] = { 5, 4, 9 };
uint16_t diamondFace14VertexOffsets[] = { 6, 5, 9 };
uint16_t diamondFace15VertexOffsets[] = { 7, 6, 9 };
uint16_t diamondFace16VertexOffsets[] = { 0, 7, 9 };

Face diamondFaces[] = {
    { 3, diamondFace01VertexOffsets },
    { 3, diamondFace02VertexOffsets },
    { 3, diamondFace03VertexOffsets },
    { 3, diamondFace04VertexOffsets },
    { 3, diamondFace05VertexOffsets },
    { 3, diamondFace06VertexOffsets },
    { 3, diamondFace07VertexOffsets },
    { 3, diamondFace08VertexOffsets },
    { 3, diamondFace09VertexOffsets },
    { 3, diamondFace10VertexOffsets },
    { 3, diamondFace11VertexOffsets },
    { 3, diamondFace12VertexOffsets },
    { 3, diamondFace13VertexOffsets },
    { 3, diamondFace14VertexOffsets },
    { 3, diamondFace15VertexOffsets },
    { 3, diamondFace16VertexOffsets }
};

Model diamondModel = {
    10,
    16,
    diamondCoordinates,
    diamondFaces
};

static const uint16_t baseColors[] = { 0x000, 0x111, 0x222, 0x333, 0x444, 0x555, 0x666, 0x777, 0x888, 0x999, 0xaaa, 0xbbb, 0xccc, 0xddd, 0xeee, 0xfff };
static const uint16_t spriteColors[] = { 0xfff, 0x000, 0xfff };

extern uint8_t __far sphere[];
extern uint8_t __far background[];
extern uint8_t __far canalSphere[];
extern uint8_t __far canalBackground[];
extern uint8_t __far font[];

const char* MainPart::pages[] = {
    {
        "\n\n\n----------------\n\n"
        "dA JoRMaS\n"
        "presents\n\n"
        "Happy Carva #74\n\n"
        "----------------\n\n"
        "Credits:\n"
        "--------\n\n"
        "Hardcode\n"
        "--------\n"
        "Vesuri\n\n"
        "Hardcore\n"
        "--------\n"
        "Naks\n\n"
        "Hardbore\n"
        "--------\n"
        "Vesuri\n\n"
        "----------------"
    },
    {
        "----------------\n\n"
        "Kicked off with\n"
        "a light sourced\n"
        "cube seen in\n"
        "quite a few\n"
        "dA JoRMaS\n"
        "productions\n"
        "already\n\n"
        "----------------\n\n"
        "Somewhat boring?\n"
        "Agreed!\n\n"
        "----------------\n\n"
        "Let's add some\n"
        "colour to it\n"
        "while the 1995\n"
        "hardcore mayhem\n"
        "gets up to speed\n\n"
        "----------------\n\n"
        "It's an another\n"
        "OCS showcase:\n"
        "No C2P, just Cxx\n\n"
        "----------------"
    },
    {
        "How about some\n"
        "12bit color\n"
        "environment\n"
        "mapping?\n"
        "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
        "Probably a\n"
        "world first\n"
        "on the\n"
        "Amiga 500"
    },
    {
        "This is\n"
        "a purely\n"
        "synthetic\n"
        "diamond\n"
        "\n\n\n\n\n"
        "so shiny        \n\n\n\n"
        "     wow\n\n\n\n"
        "such HAM      \n\n\n\n"
        "      very Amiga\n"
        "\n\n\n\n"
        "Reflecting the\n"
        "surroundings\n"
        "like a perfect\n"
        "mirror"
    },
    {
        "24\n"
        "faces\n"
        "of\n"
        "boredom\n"
        "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
        "Let's try some\n"
        "other variations\n"
        "of the same same\n"
        "but different"
    },
    {
        "Next up in line\n"
        "we have some\n"
        "semitransparent\n"
        "gouraud vectors\n"
        "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
        "How about that?\n"
        "Perhaps there's\n"
        "still room for\n"
        "something more?"
    },
    {
        "Well of course..\n"
        "Translucency\n"
        "also needs to\n"
        "be thrown in\n"
        "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
        "Another step in\n"
        "the 25 year long\n"
        "history of\n"
        "dA JoRMaS"
    },
    {
        "\n\n\n\n\n\n\n\n\n\n\n\n"
        "$\n\n"
        "Translucent\n"
        "gouraud\n"
        "glenz\n\n"
        "$"
    },
    {
        "----------------\n\n"
        "dA JoRMaS\n\n"
        "Exploring\n"
        "the mysteries\n"
        "of the canals\n"
        "since 1994\n\n"
        "----------------\n\n"
        "No need for a\n"
        "compo to release\n"
        "cool stuff\n\n"
        "----------------\n\n"
        "With some design\n"
        "this thing might\n"
        "have done pretty\n"
        "well though\n\n"
        "----------------\n\n"
        "Now enjoy it all\n"
        "over again with\n"
        "no unnecessary\n"
        "distractions\n\n"
        "----------------"
    },
    {
        ""
    },
    0
};

typedef void (*SubPartInitializer)(MainPart*);

struct SubPart {
    uint16_t songPosition;
    SubPartInitializer subPartInitializer;
};

void MainPart::enableHAM(MainPart* part)
{
    if (AmigaHardware::hasAGAChipSet) {
        // Use normal 6 bitplane HAM on AGA, resetting the bitplane 5 and 6 pointers on every line
        *bplcon0Pointer = (uint16_t)((6 << PLNCNTSHFT) + HOLDNMODIFY + 1);
    } else {
        // Use 4 bitplane HAM DMA trick on OCS/ECS (planes 5 and 6 only use dat register contents)
        *bplcon0Pointer = (uint16_t)((7 << PLNCNTSHFT) + HOLDNMODIFY + 1);
    }

    part->ham = true;
}

void MainPart::disableHAM(MainPart* part)
{
    *bplcon0Pointer = (uint16_t)((BITPLANE_COUNT << PLNCNTSHFT) + 1);

    part->ham = false;
}

void MainPart::clearBackground(MainPart* part)
{
    uint32_t* dest = (uint32_t*)part->backgroundBitmap->data;
    for (uint16_t i = 0; i < BITPLANE_HEIGHT; i++) {
        *dest++ = 0;
        *dest++ = 0;
        *dest++ = 0;
        *dest++ = 0;
        *dest++ = 0;
        *dest++ = 0;
        *dest++ = 0;
        *dest++ = 0;
        *dest++ = 0;
        *dest++ = 0;
        *dest++ = 0;
        *dest++ = 0;
        *dest++ = 0;
        *dest++ = 0;
        *dest++ = 0;
        *dest++ = 0;
        *dest++ = 0;
        *dest++ = 0;
        *dest++ = 0;
        *dest++ = 0;
        *dest++ = 0;
        *dest++ = 0;
        *dest++ = 0;
        *dest++ = 0;
        *dest++ = 0;
        *dest++ = 0;
        *dest++ = 0;
        *dest++ = 0;
        *dest++ = 0;
        *dest++ = 0;
        *dest++ = 0;
        *dest++ = 0;
        *dest++ = 0;
        *dest++ = 0;
        *dest++ = 0;
        *dest++ = 0;
        *dest++ = 0;
        *dest++ = 0;
        *dest++ = 0;
        *dest++ = 0;
    }

    part->previousBoundingRect1 = Rect(Point2D(0, 0), Point2D(BITPLANE_WIDTH - 1, BITPLANE_HEIGHT - 1));
    part->previousBoundingRect2 = Rect(Point2D(0, 0), Point2D(BITPLANE_WIDTH - 1, BITPLANE_HEIGHT - 1));
}

void MainPart::copyBackground(MainPart* part)
{
    uint32_t* source = (uint32_t*)background;
    uint32_t* dest = (uint32_t*)part->backgroundBitmap->data;
    for (uint16_t i = 0; i < BITPLANE_HEIGHT; i++) {
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
    }

    part->previousBoundingRect1 = Rect(Point2D(0, 0), Point2D(BITPLANE_WIDTH - 1, BITPLANE_HEIGHT - 1));
    part->previousBoundingRect2 = Rect(Point2D(0, 0), Point2D(BITPLANE_WIDTH - 1, BITPLANE_HEIGHT - 1));
}

void MainPart::copySphere(MainPart* part)
{
    uint32_t* source = (uint32_t*)sphere;
    uint32_t* dest = (uint32_t*)part->textureBitmap->data;
    for (uint16_t i = 0; i < SPHERE_HEIGHT; i++) {
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
    }
}

void MainPart::copyCanalBackground(MainPart* part)
{
    uint32_t* source = (uint32_t*)canalBackground;
    uint32_t* dest = (uint32_t*)part->backgroundBitmap->data;
    for (uint16_t i = 0; i < BITPLANE_HEIGHT; i++) {
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
    }

    part->previousBoundingRect1 = Rect(Point2D(0, 0), Point2D(BITPLANE_WIDTH - 1, BITPLANE_HEIGHT - 1));
    part->previousBoundingRect2 = Rect(Point2D(0, 0), Point2D(BITPLANE_WIDTH - 1, BITPLANE_HEIGHT - 1));
}

void MainPart::copyCanalSphere(MainPart* part)
{
    uint32_t* source = (uint32_t*)canalSphere;
    uint32_t* dest = (uint32_t*)part->textureBitmap->data;
    for (uint16_t i = 0; i < SPHERE_HEIGHT; i++) {
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
        *dest++ = *source++;
    }
}

void MainPart::enableMirror(MainPart* part)
{
    part->mirror = true;
}

void MainPart::disableMirror(MainPart* part)
{
    part->mirror = false;
}

void MainPart::enableGlenz(MainPart* part)
{
    part->glenz = true;
}

void MainPart::disableGlenz(MainPart* part)
{
    part->glenz = false;
}

void MainPart::enableTranslucent(MainPart* part)
{
    part->translucent = true;
    part->moveModel = false;

    part->centerX = BITPLANE_WIDTH / 2;
    part->centerY = BITPLANE_HEIGHT / 2;
}

void MainPart::disableTranslucent(MainPart* part)
{
    part->translucent = false;
}

void MainPart::setCubeModel(MainPart* part)
{
    part->setModel(&cubeModel);

    part->angleXDelta = 2;
    part->angleYDelta = 3;
    part->angleZDelta = 4;
}

void MainPart::setDiamondModel(MainPart* part)
{
    part->setModel(&diamondModel);

    part->angleXDelta = 1;
    part->angleYDelta = 2;
    part->angleZDelta = 3;
}

void MainPart::setTetrahexahedronModel(MainPart* part)
{
    part->setModel(&tetrahexahedronModel);

    part->angleXDelta = 3;
    part->angleYDelta = -2;
    part->angleZDelta = 1;
}

void MainPart::setClearPage(MainPart* part)
{
    part->clearPage = true;
}

void MainPart::resetRGBDistance(MainPart* part)
{
    part->rgbDistance = 0;
}

const SubPart MainPart::subParts[] = {
    {
        4 * 64 - 8,
        setClearPage
    },
    {
        4 * 64,
        enableHAM
    },
    {
        6 * 64,
        copyBackground
    },
    {
        10 * 64 - 8,
        setClearPage
    },
    {
        10 * 64,
        copyCanalBackground
    },
    {
        10 * 64,
        copyCanalSphere
    },
    {
        10 * 64,
        enableMirror
    },
    {
        14 * 64 - 8,
        setClearPage
    },
    {
        14 * 64,
        setDiamondModel
    },
    {
        18 * 64 - 8,
        setClearPage
    },
    {
        18 * 64,
        setTetrahexahedronModel
    },
    {
        22 * 64 - 8,
        setClearPage
    },
    {
        22 * 64,
        setCubeModel
    },
    {
        22 * 64,
        clearBackground
    },
    {
        22 * 64,
        copySphere
    },
    {
        22 * 64,
        disableMirror
    },
    {
        22 * 64,
        enableGlenz
    },
    {
        26 * 64 - 8,
        setClearPage
    },
    {
        26 * 64,
        copyBackground
    },
    {
        26 * 64,
        enableTranslucent
    },
    {
        30 * 64 - 8,
        setClearPage
    },
    {
        30 * 64,
        setTetrahexahedronModel
    },
    {
        32 * 64 - 8,
        setClearPage
    },
    {
        32 * 64,
        copyCanalBackground
    },
    {
        32 * 64,
        copyCanalSphere
    },
    {
        32 * 64,
        enableMirror
    },
    {
        32 * 64,
        disableGlenz
    },
    {
        32 * 64,
        disableTranslucent
    },
    {
        36 * 64 - 8,
        setClearPage
    },

    {
        36 * 64,
        setCubeModel
    },
    {
        36 * 64,
        clearBackground
    },
    {
        36 * 64,
        copySphere
    },
    {
        36 * 64,
        disableHAM
    },
    {
        36 * 64,
        disableMirror
    },
    {
        40 * 64,
        resetRGBDistance
    },
    {
        40 * 64,
        enableHAM
    },
    {
        42 * 64,
        copyBackground
    },
    {
        44 * 64,
        copyCanalBackground
    },
    {
        44 * 64,
        copyCanalSphere
    },
    {
        44 * 64,
        enableMirror
    },
    {
        48 * 64,
        setDiamondModel
    },
    {
        52 * 64,
        setTetrahexahedronModel
    },
    {
        56 * 64,
        setCubeModel
    },
    {
        56 * 64,
        clearBackground
    },
    {
        56 * 64,
        copySphere
    },
    {
        56 * 64,
        disableMirror
    },
    {
        56 * 64,
        enableGlenz
    },
    {
        60 * 64,
        copyBackground
    },
    {
        60 * 64,
        enableTranslucent
    },
    {
        64 * 64,
        setTetrahexahedronModel
    },
    {
        68 * 64,
        copyCanalBackground
    },
    {
        68 * 64,
        copyCanalSphere
    },
    {
        68 * 64,
        enableMirror
    },
    {
        68 * 64,
        disableGlenz
    },
    {
        68 * 64,
        disableTranslucent
    },
    {
        SHRT_MAX,
        0
    }
};

MainPart::MainPart() :
    model(0),
    faces(0),
    rotatedCoordinates(0),
    angleX(0),
    angleY(0),
    angleZ(0),
    distance(MODEL_DISTANCE),
    centerX(BITPLANE_WIDTH / 2),
    centerY(BITPLANE_HEIGHT / 2),
    rgbDistance(0),
    rgbAngle(0),
    angleXDelta(1),
    angleYDelta(2),
    angleZDelta(3),
    subPart(subParts),
    distanceMultiplyTable(new int8_t[128 << 7]),
    copperList(CopperList::allocate(30 + 3 * (BITPLANE_HEIGHT - 1) + 1)),
    emptySprite(Sprite::allocate(0)),
    displayBitmap1(0),
    displayBitmap2(0),
    currentDisplayBitmap(0),
    maskBitmap(0),
    maskBitmapR(0),
    maskBitmapG(0),
    maskBitmapB(0),
    backgroundBitmap(0),
    textureBitmap(0),
    hamBitmap(0),
    basePalette(baseColors, 16),
    spritePalette(spriteColors, 3),
    previousBoundingRect1(Point2D(0, 0), Point2D(BITPLANE_WIDTH - 1, BITPLANE_HEIGHT - 1)),
    previousBoundingRect2(Point2D(0, 0), Point2D(BITPLANE_WIDTH - 1, BITPLANE_HEIGHT - 1)),
    previousBoundingRect(0),
    ham(false),
    mirror(false),
    glenz(false),
    translucent(false),
    moveModel(false),
    padding(false),
    frameReady(false),
    mathsReady(false),
    pageIndex(-1),
    input(0),
    outputLine(0),
    outputCharacter(0),
    clearLine(0),
    spriteDelta(0),
    clearPage(false)
{
    int8_t* multipliedValue = distanceMultiplyTable;
    for (uint16_t distance = 1; distance <= 128; distance++) {
        for (int16_t value = -64; value < 64; value++) {
            *multipliedValue++ = (int8_t)((distance * value) >> 7);
        }
    }

    for (uint16_t sprite = 0; sprite < 8; sprite++) {
        sprites[sprite] = Sprite::allocate(256);
        sprites[sprite]->setY(40);
    }

    setModel(&cubeModel);
    nextPage();
}

MainPart::~MainPart()
{
    delete [] faces;
    delete [] rotatedCoordinates;
    delete [] distanceMultiplyTable;
    delete copperList;
    for (uint16_t sprite = 0; sprite < 8; sprite++) {
        delete sprites[sprite];
    }
    delete emptySprite;
    delete displayBitmap1;
    delete displayBitmap2;
    delete maskBitmap;
    delete maskBitmapR;
    delete maskBitmapG;
    delete maskBitmapB;
    delete backgroundBitmap;
    delete textureBitmap;
    delete hamBitmap;
}

void MainPart::initialize()
{
    uint8_t* bitmapData = (uint8_t*)chipMemory;
    displayBitmap1 = new Bitmap(bitmapData, BITPLANE_WIDTH, BITPLANE_HEIGHT, BITPLANE_COUNT, true);
    displayBitmap2 = new Bitmap(bitmapData + BITPLANE_SIZE * BITPLANE_COUNT, BITPLANE_WIDTH, BITPLANE_HEIGHT, BITPLANE_COUNT, true);
    maskBitmap = new Bitmap(bitmapData + 2 * BITPLANE_SIZE * BITPLANE_COUNT, BITPLANE_WIDTH, BITPLANE_HEIGHT, 1, true);
    maskBitmapR = new Bitmap(bitmapData + 2 * BITPLANE_SIZE * BITPLANE_COUNT + BITPLANE_SIZE, BITPLANE_WIDTH, BITPLANE_HEIGHT, 1, true);
    maskBitmapG = new Bitmap(bitmapData + 2 * BITPLANE_SIZE * BITPLANE_COUNT + BITPLANE_SIZE * 2, BITPLANE_WIDTH, BITPLANE_HEIGHT, 1, true);
    maskBitmapB = new Bitmap(bitmapData + 2 * BITPLANE_SIZE * BITPLANE_COUNT + BITPLANE_SIZE * 3, BITPLANE_WIDTH, BITPLANE_HEIGHT, 1, true);
    backgroundBitmap = new Bitmap(bitmapData + 2 * BITPLANE_SIZE * BITPLANE_COUNT + BITPLANE_SIZE * 4, BITPLANE_WIDTH, BITPLANE_HEIGHT, BITPLANE_COUNT, true);
    textureBitmap = new Bitmap(bitmapData + 2 * BITPLANE_SIZE * BITPLANE_COUNT + BITPLANE_SIZE * 8, SPHERE_WIDTH, SPHERE_HEIGHT, BITPLANE_COUNT, true);
    hamBitmap = new Bitmap(bitmapData + 2 * BITPLANE_SIZE * BITPLANE_COUNT + BITPLANE_SIZE * 8 + (SPHERE_WIDTH / 8) * SPHERE_HEIGHT * BITPLANE_COUNT, BITPLANE_WIDTH, 1, 2, true);
    currentDisplayBitmap = displayBitmap2;
    previousBoundingRect = &previousBoundingRect2;
    copperList->showBitmap(1, *currentDisplayBitmap);
    AmigaHardware::setCopperList(*copperList);
    AmigaHardware::setPlayfield(BITPLANE_WIDTH, BITPLANE_HEIGHT, BITPLANE_COUNT, true);

    uint32_t* copperData = copperList->data();
    uint16_t spriteIndex;
    if (AmigaHardware::hasAGAChipSet) {
        // Use normal 6 bitplane HAM on AGA, resetting the bitplane 5 and 6 pointers on every line
        uint32_t hamBitplane5 = (uint32_t)hamBitmap->data;
        uint32_t hamBitplane6 = hamBitplane5 + (BITPLANE_WIDTH >> 3);
        for (uint16_t i = 1, listIndex = 29, y = (0xa9 - BITPLANE_HEIGHT / 2); i < BITPLANE_HEIGHT; i++, y = (uint16_t)((y + 1) & 255)) {
            if (y == 0) {
                copperData[listIndex++] = copperWait(255, 212);
            }
            copperData[listIndex++] = copperWait(y, 0);
            copperData[listIndex++] = copperMove(bpl5ptl, (uint16_t)hamBitplane5);
            copperData[listIndex++] = copperMove(bpl6ptl, (uint16_t)hamBitplane6);
        }

        uint16_t* hamData5 = (uint16_t*)hamBitplane5;
        uint16_t* hamData6 = (uint16_t*)hamBitplane6;
        for (i = 0; i < (BITPLANE_WIDTH >> 4); i++) {
            *hamData5++ = 0x7777;
            *hamData6++ = 0xdddd;
        }

        copperList->showBitmap(9, *hamBitmap, 5);
        spriteIndex = 13;
    } else {
        // Use 4 bitplane HAM DMA trick on OCS/ECS (planes 5 and 6 only use dat register contents)
        *bpl5datPointer = 0x7777;
        *bpl6datPointer = 0xdddd;

        copperData[25] = copperWait(255, 254);
        spriteIndex = 9;
    }

    for (uint16_t sprite = 0; sprite < 8; sprite++) {
        copperList->showSprite(spriteIndex + sprite + sprite, sprite, *sprites[sprite]);
    }

    copySphere(this);

    AmigaHardware::setPalette(0, basePalette);
    AmigaHardware::setPalette(17, spritePalette);
    AmigaHardware::setPalette(21, spritePalette);
    AmigaHardware::setPalette(25, spritePalette);
    AmigaHardware::setPalette(29, spritePalette);
    AmigaHardware::setSpritesEnabled(true);
}

bool MainPart::main()
{
    if (!mathsReady) {
        rotateFaces();

        // Sort the faces, furthest away ones first
        // qsort(faces, model->numFaces, sizeof(FaceData), sortFaces);

        mathsReady = true;
    }

    // Don't render before the previous frame has been shown
    if (frameReady) {
        return false;
    }

    uint16_t songPosition = modulePlayer->position();

    while (songPosition >= subPart->songPosition) {
        subPart->subPartInitializer(this);
        subPart++;
    }

    if (!previousBoundingRect->isEmpty) {
        // Copy the background over the previously modified area of the bitmap
        uint16_t rectX = previousBoundingRect->topLeft.x & 0xfff0;
        uint16_t rectY = previousBoundingRect->topLeft.y;
        uint16_t rectWidth = ((previousBoundingRect->bottomRight.x + 16) & 0xfff0) - rectX;
        uint16_t rectHeight = previousBoundingRect->height;
        currentDisplayBitmap->copy(*backgroundBitmap, rectX, rectY, rectX, rectY, rectWidth, rectHeight);

        // Clear the bounding rectangle
        *previousBoundingRect = Rect();
    }

    // Draw faces
    for (uint16_t face = 0; face < model->numFaces; face++) {
        FaceData* faceData = faces + face;
        
        if (glenz || faceData->visible) {
            Polygon polygon(faceData->face->vertices);
            for (uint16_t vertex = 0; vertex < faceData->face->vertices; vertex++) {
                uint16_t vertexOffset = faceData->face->vertexOffsets[vertex];
                polygon.setPoint(vertex, Point2D(rotatedCoordinates[vertexOffset].x, rotatedCoordinates[vertexOffset].y));
            }

            // Expand the frame's bounding rectangle with the polygon's bounding rectangle
            Rect rect = polygon.boundingRect();
            previousBoundingRect->unite(rect);

            uint16_t rectX = rect.topLeft.x;
            uint16_t rectY = rect.topLeft.y;
            uint16_t rectWidth = rect.width;
            uint16_t rectHeight = rect.height;

            // Clear one extra word from the right since it may get used in the mask
            maskBitmap->clear(rectX, rectY, rectWidth + 16, rectHeight);

            // Draw the polygon to a mask
            drawPolygon(polygon, maskBitmap, 1, true);

            // Fill the mask
            maskBitmap->fill(rectX, rectY, rectWidth, rectHeight);

            uint16_t textureCenterX = (textureBitmap->width - rectWidth) >> 1;
            uint16_t textureCenterY = (textureBitmap->height - rectHeight) >> 1;
            // Rotated normals can be used as texture offsets since they have been normalized to a suitable length
            if (!ham) {
                uint16_t textureX = textureCenterX + (faceData->rnx >> 1);
                uint16_t textureY = textureCenterY + (faceData->rny >> 1);

                currentDisplayBitmap->copyWithMask(*textureBitmap, *maskBitmap, rectX, rectY, textureX, textureY, rectX, rectY, rectWidth, rectHeight);
            } else if (mirror) {
                uint16_t textureX = (uint16_t)((MIN(MAX(textureCenterX + faceData->rnx, 0), textureBitmap->width - rectWidth) & 0xfffc) + (rectX & 3));
                uint16_t textureY = MIN(MAX(textureCenterY + faceData->rny, 0), textureBitmap->height - rectHeight);

                currentDisplayBitmap->copyWithMask(*textureBitmap, *maskBitmap, rectX, rectY, textureX, textureY, rectX, rectY, rectWidth, rectHeight);
            } else {
                int8_t* multipliedValues = distanceMultiplyTable + (rgbDistance & 0x3f80) + 64;
                uint16_t angleR = rgbAngle;
                uint16_t angleG = (rgbAngle + 341) & 1023;
                uint16_t angleB = (rgbAngle + 683) & 1023;
                int16_t xOffsetR = multipliedValues[(Util::cos[angleR] >> 9)];
                int16_t xOffsetG = multipliedValues[(Util::cos[angleG] >> 9)];
                int16_t xOffsetB = multipliedValues[(Util::cos[angleB] >> 9)];
                int16_t yOffsetR = multipliedValues[(Util::sin[angleR] >> 9)];
                int16_t yOffsetG = multipliedValues[(Util::sin[angleG] >> 9)];
                int16_t yOffsetB = multipliedValues[(Util::sin[angleB] >> 9)];
                int16_t xOffsetNormal = faceData->rnx >> 1;
                int16_t yOffsetNormal = faceData->rny >> 1;
                xOffsetR = (int16_t)(MIN(MAX(xOffsetR + xOffsetNormal, -128), 128));
                xOffsetG = (int16_t)(MIN(MAX(xOffsetG + xOffsetNormal, -128), 128));
                xOffsetB = (int16_t)(MIN(MAX(xOffsetB + xOffsetNormal, -128), 128));
                yOffsetR = (int16_t)(MIN(MAX(yOffsetR + yOffsetNormal, -128), 128));
                yOffsetG = (int16_t)(MIN(MAX(yOffsetG + yOffsetNormal, -128), 128));
                yOffsetB = (int16_t)(MIN(MAX(yOffsetB + yOffsetNormal, -128), 128));
                uint16_t textureXR = textureCenterX + xOffsetR;
                uint16_t textureXG = textureCenterX + xOffsetG;
                uint16_t textureXB = textureCenterX + xOffsetB;
                uint16_t textureYR = textureCenterY + yOffsetR;
                uint16_t textureYG = textureCenterY + yOffsetG;
                uint16_t textureYB = textureCenterY + yOffsetB;

                // Copy one extra word from the right to make sure it gets cleared
                uint16_t copyWidth = rectWidth + 16;

                if (glenz) {
                    if (faceData->visible) {
                        if (translucent) {
                            maskBitmapR->copy(*maskBitmap, rectX, rectY, rectX, rectY, copyWidth, rectHeight, 0x8888);

                            currentDisplayBitmap->copyWithMask(*textureBitmap, *maskBitmapR, rectX, rectY, textureXR, textureYR, rectX, rectY, rectWidth, rectHeight);
                        } else {
                            maskBitmapG->copy(*maskBitmap, rectX, rectY, rectX, rectY, copyWidth, rectHeight, 0x5555);

                            currentDisplayBitmap->copyWithMask(*textureBitmap, *maskBitmapG, rectX, rectY, textureXG, textureYG, rectX, rectY, rectWidth, rectHeight);
                        }
                    } else {
                        if (!translucent) {
                            maskBitmapR->copy(*maskBitmap, rectX, rectY, rectX, rectY, copyWidth, rectHeight, 0x8888);

                            currentDisplayBitmap->copyWithMask(*textureBitmap, *maskBitmapR, rectX, rectY, textureXR, textureYR, rectX, rectY, rectWidth, rectHeight);
                        }

                        maskBitmapB->copy(*maskBitmap, rectX, rectY, rectX, rectY, copyWidth, rectHeight, 0x2222);

                        currentDisplayBitmap->copyWithMask(*textureBitmap, *maskBitmapB, rectX, rectY, textureXB, textureYB, rectX, rectY, rectWidth, rectHeight);
                    }
                } else {
                    maskBitmapR->copy(*maskBitmap, rectX, rectY, rectX, rectY, copyWidth, rectHeight, 0x8888);
                    if (!translucent) {
                        maskBitmapG->copy(*maskBitmap, rectX, rectY, rectX, rectY, copyWidth, rectHeight, 0x5555);
                    }
                    maskBitmapB->copy(*maskBitmap, rectX, rectY, rectX, rectY, copyWidth, rectHeight, 0x2222);

                    currentDisplayBitmap->copyWithMask(*textureBitmap, *maskBitmapR, rectX, rectY, textureXR, textureYR, rectX, rectY, rectWidth, rectHeight);
                    if (!translucent) {
                        currentDisplayBitmap->copyWithMask(*textureBitmap, *maskBitmapG, rectX, rectY, textureXG, textureYG, rectX, rectY, rectWidth, rectHeight);
                    }
                    currentDisplayBitmap->copyWithMask(*textureBitmap, *maskBitmapB, rectX, rectY, textureXB, textureYB, rectX, rectY, rectWidth, rectHeight);
                }
            }
        }
    }

    while (AmigaHardware::hasQueuedBlits || AmigaHardware::isBlitterBusy());

    frameReady = true;
    mathsReady = false;

    return false;
}

bool MainPart::vbi()
{
    bool frameDisplayed = frameReady;

    if (frameDisplayed) {
        copperList->showBitmap(1, *currentDisplayBitmap);
        currentDisplayBitmap = currentDisplayBitmap == displayBitmap1 ? displayBitmap2 : displayBitmap1;
        previousBoundingRect = previousBoundingRect == &previousBoundingRect1 ? &previousBoundingRect2 : &previousBoundingRect1;

        frameReady = false;
    }

    angleX += angleXDelta;
    angleY += angleYDelta;
    angleZ += angleZDelta;
    angleX &= 1023;
    angleY &= 1023;
    angleZ &= 1023;

    if (ham && !mirror) {
        if (rgbDistance < (127 << 7)) {
            rgbDistance += 16;
        }

        rgbAngle++;
        rgbAngle &= 1023;
    }

    bool bassDrumTriggered = modulePlayer->isSampleTriggered(SampleBassDrum) || modulePlayer->isSampleTriggered(SampleDrumLoop);
    if (bassDrumTriggered) {
        spriteDelta = SPRITE_MAX_DELTA;
    }

    bool amenTriggered = modulePlayer->isSampleTriggered(SampleAmen1) || modulePlayer->isSampleTriggered(SampleAmen2);
    if (moveModel && (bassDrumTriggered || amenTriggered)) {
        centerX += 53;
        centerY += 23;

        if (centerX > BITPLANE_WIDTH / 2 + MODEL_MAX_DELTA_X) {
            centerX -= MODEL_MAX_DELTA_X + MODEL_MAX_DELTA_X;
        }
        if (centerY > BITPLANE_HEIGHT / 2 + MODEL_MAX_DELTA_Y) {
            centerY -= MODEL_MAX_DELTA_Y + MODEL_MAX_DELTA_Y;
        }
    }

    if (spriteDelta) {
        spriteDelta = (int16_t)((-spriteDelta - spriteDelta - spriteDelta) >> 2);
        setSpritePositions();
    }

    if (clearPage) {
        // Clear text
        if (clearLine < 32) {
            for (uint16_t sprite = 0; sprite < 8; sprite++) {
                uint32_t* output = (uint32_t*)(sprites[sprite]->data() + 2 + (clearLine << 4));
                *output++ = 0;
                *output++ = 0;
                *output++ = 0;
                *output++ = 0;
                *output++ = 0;
                *output++ = 0;
                *output++ = 0;
                *output++ = 0;
            }
            clearLine++;
        } else {
            // Prepare for next page
            clearPage = false;
            nextPage();
        }
    } else {
        // Write text
        nextCharacter();
    }

    return frameDisplayed;
}

void MainPart::drawPolygon(const Polygon& polygon, Bitmap* bitmap, uint16_t color, bool fillMode)
{
    for (uint16_t i = 0; i < polygon.size;) {
        Point2D p1 = polygon.points[i++];
        Point2D p2 = polygon.points[i < polygon.size ? i : 0];
        bitmap->line(p1.x, p1.y, p2.x, p2.y, color, fillMode);
    }
}

void MainPart::setModel(Model* model)
{
    this->model = model;
    moveModel = (bool)(model != &tetrahexahedronModel);

    centerX = BITPLANE_WIDTH / 2;
    centerY = BITPLANE_HEIGHT / 2;
    
    delete [] faces;
    delete [] rotatedCoordinates;
    faces = new FaceData[model->numFaces];
    rotatedCoordinates = new RotatedCoordinate[model->numCoordinates];

    Coordinate* c = model->coordinates;
    for (int faceIndex = 0; faceIndex < model->numFaces; faceIndex++) {
        Face* face = model->faces + faceIndex;
        FaceData* faceData = faces + faceIndex;
        faceData->face = face;
        
        // Calculate face normal
        Coordinate* c1 = c + face->vertexOffsets[0];
        Coordinate* c2 = c + face->vertexOffsets[1];
        Coordinate* c3 = c + face->vertexOffsets[2];
        int16_t x1 = c1->x;
        int16_t y1 = c1->y;
        int16_t z1 = c1->z;
        int16_t x2 = c2->x;
        int16_t y2 = c2->y;
        int16_t z2 = c2->z;
        int16_t x3 = c3->x;
        int16_t y3 = c3->y;
        int16_t z3 = c3->z;
        faceData->nx = (int16_t)(y1 * (z2 - z3) + y2 * (z3 - z1) + y3 * (z1 - z2));
        faceData->ny = (int16_t)(z1 * (x2 - x3) + z2 * (x3 - x1) + z3 * (x1 - x2));
        faceData->nz = (int16_t)(x1 * (y2 - y3) + x2 * (y3 - y1) + x3 * (y1 - y2));
        faceData->nx_y = (int16_t)(faceData->nx * faceData->ny);

        // Normalize vector to 256
        int32_t length = Util::sqrt(faceData->nx * faceData->nx + faceData->ny * faceData->ny + faceData->nz * faceData->nz);
        faceData->nx = (int16_t)((faceData->nx << 8) / length);
        faceData->ny = (int16_t)((faceData->ny << 8) / length);
        faceData->nz = (int16_t)((faceData->nz << 8) / length);
   }
}

#ifndef ASSEMBLER
void MainPart::rotateFaces()
{
    // Precalculate sin*cos constants; range +-0x3fff
    int16_t xx = (Util::cos[angleX] * Util::cos[angleY]) >> 16;
    int16_t xy = (Util::sin[angleX] * Util::cos[angleY]) >> 16;
    int16_t xz = Util::sin[angleY] >> 1;
    int16_t yx = ((Util::sin[angleX] * Util::cos[angleZ]) >> 16) + ((((Util::cos[angleX] * Util::sin[angleY]) >> 15) * Util::sin[angleZ]) >> 16);
    int16_t yy = -((Util::cos[angleX] * Util::cos[angleZ]) >> 16) + ((((Util::sin[angleX] * Util::sin[angleY]) >> 15) * Util::sin[angleZ]) >> 16);
    int16_t yz = -((Util::cos[angleY] * Util::sin[angleZ]) >> 16);
    int16_t zx = ((Util::sin[angleX] * Util::sin[angleZ]) >> 16) - ((((Util::cos[angleX] * Util::sin[angleY]) >> 15) * Util::cos[angleZ]) >> 16);
    int16_t zy = -((Util::cos[angleX] * Util::sin[angleZ]) >> 16) - ((((Util::sin[angleX] * Util::sin[angleY]) >> 15) * Util::cos[angleZ]) >> 16);
    int16_t zz = (Util::cos[angleY] * Util::cos[angleZ]) >> 16;
    int32_t xx_xy = xx * xy;
    int32_t yx_yy = yx * yy;
    int32_t zx_zy = zx * zy;

    // Rotate coordinates
    for (uint16_t coordinate = 0; coordinate < model->numCoordinates; coordinate++) {
        int16_t x = model->coordinates[coordinate].x;
        int16_t y = model->coordinates[coordinate].y;
        int16_t z = model->coordinates[coordinate].z;
        int16_t x_y = model->coordinates[coordinate].x_y;
        int32_t nx = (xx + y) * (xy + x) + z * xz - (xx_xy + x_y);
        int32_t ny = (yx + y) * (yy + x) + z * yz - (yx_yy + x_y);
        int32_t nz = (zx + y) * (zy + x) + z * zz - (zx_zy + x_y);

        // Projection
        int16_t pz = (nz >> 13) - distance;
        rotatedCoordinates[coordinate].x = (int16_t)((nx >> 5) / pz + centerX);
        rotatedCoordinates[coordinate].y = (int16_t)((ny >> 5) / pz + centerY);
        rotatedCoordinates[coordinate].z = (int16_t)(nz >> 13);
    }

    for (uint16_t face = 0; face < model->numFaces; face++) {
        // Rotate face normals
        FaceData* faceData = faces + face;
        int16_t x = faceData->nx;
        int16_t y = faceData->ny;
        int16_t z = faceData->nz;
        int16_t x_y = faceData->nx_y;
        faceData->rnx = (int16_t)(((xx + y) * (xy + x) + z * xz - (xx_xy + x_y)) >> 14);
        faceData->rny = (int16_t)(((yx + y) * (yy + x) + z * yz - (yx_yy + x_y)) >> 14);
        faceData->rnz = (int16_t)(((zx + y) * (zy + x) + z * zz - (zx_zy + x_y)) >> 14);

        // Calculate visibility
        uint16_t v1 = faceData->face->vertexOffsets[0];
        uint16_t v2 = faceData->face->vertexOffsets[1];
        uint16_t v3 = faceData->face->vertexOffsets[2];
        int16_t rx1 = rotatedCoordinates[v1].x;
        int16_t ry1 = rotatedCoordinates[v1].y;
        int16_t rx2 = rotatedCoordinates[v2].x;
        int16_t ry2 = rotatedCoordinates[v2].y;
        int16_t rx3 = rotatedCoordinates[v3].x;
        int16_t ry3 = rotatedCoordinates[v3].y;
        faceData->visible = (bool)((rx1 * ry2 - ry1 * rx2 + ry1 * rx3 - rx1 * ry3 + rx2 * ry3 - rx3 * ry2) > 0 ? true : false);

        // Calculate center Z coordinate
        faceData->z = 0;
        for (uint16_t vertex = 0; vertex < faceData->face->vertices; vertex++) {
            uint16_t vertexOffset = faceData->face->vertexOffsets[vertex];
            faceData->z += rotatedCoordinates[vertexOffset].z;
        }

        // As long as all faces have the same amount of vertices the sum is enough
        // faceData->z /= faceData->face->vertices;
    }
}
#endif

__stdargs int MainPart::sortFaces(const void* face1, const void* face2)
{
    FaceData* faceData1 = (FaceData*)face1;
    FaceData* faceData2 = (FaceData*)face2;
 
    if (faceData1->z < faceData2->z) {
        return 1;
    } else if (faceData1->z > faceData2->z) {
        return -1;
    } else {
        return 0;
    }
}

void MainPart::setSpritePositions()
{
    for (uint16_t sprite = 0, spriteX = 224 + spriteDelta; sprite < 8; sprite++, spriteX += 16) {
        sprites[sprite]->setX(spriteX);
    }
}

void MainPart::nextPage()
{
    const char* page = pages[++pageIndex];
    if (!page) {
        pageIndex = 0;
        page = pages[pageIndex];
    }
    input = page;
    outputLine = 0;
    clearLine = 0;

    nextLine();
    setSpritePositions();
}

void MainPart::nextLine()
{
    for (const char* character = input; *character != '\n' && *character != 0; character++);
    uint32_t lineLength = (character - input - 1);
    outputCharacter = (16 - lineLength) >> 1;
    outputLine++;
}

void MainPart::nextCharacter()
{
    char character = *input++;
    switch (character) {
    case 0:
        // End of page: do nothing
        input--;
        break;
    case '\n':
        // Line feed: advance to next line
        nextLine();
        break;
    default: {
        // Write a character
        uint16_t fontOffset = (character - ' ') << 3;
        uint8_t* output = (uint8_t*)(sprites[outputCharacter >> 1]->data() + 2 + (outputLine << 4)) + (outputCharacter & 1);
        for (uint16_t yOffset = 0; yOffset < 32; yOffset += 4) {
            output[yOffset] = font[fontOffset];
            output[yOffset + 6] = font[fontOffset++];
        }
        outputCharacter++;
        break;
        }
    }
}
