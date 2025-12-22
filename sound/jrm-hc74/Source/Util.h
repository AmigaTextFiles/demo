#ifndef _UTIL_H
#define _UTIL_H

#define ASSEMBLER

#if __cplusplus < 201103L
typedef char int8_t;
typedef short int16_t;
typedef long int32_t;
typedef unsigned char uint8_t;
typedef unsigned short uint16_t;
typedef unsigned long uint32_t;
typedef unsigned char bool;
#define true 1
#define false 0
#endif

#define MIN(a, b) (((a) < (b)) ? (a) : (b))
#define MAX(a, b) (((a) > (b)) ? (a) : (b))

class Util {
public:
    static int16_t sin[1024 + 256];
    static int16_t* cos;
    __asm static uint32_t sqrt(register __d1 uint32_t x);
    __asm static int32_t ungzip(register __a0 void* input, register __a1 void* output);
};

struct Point2D {
    Point2D();
    Point2D(int16_t x, int16_t y);
    int16_t x, y;
};

struct Rect {
    Rect();
    Rect(const Point2D& topLeft, const Point2D& bottomRight);
#ifdef ASSEMBLER
    __asm void update();
    __asm void unite(register __a1 const Rect& rectangle);
#else
    void update();
    void unite(const Rect& rectangle);
#endif
    Point2D topLeft;
    Point2D bottomRight;
    uint16_t width;
    uint16_t height;
    Point2D center;
    bool isEmpty;
    bool isNull;
};

struct Polygon {
    Polygon();
    Polygon(uint16_t size);
    ~Polygon();
    void setPoint(uint16_t index, const Point2D& point);
    Rect boundingRect() const;
    Point2D* points;
    uint16_t size;
};

#endif
