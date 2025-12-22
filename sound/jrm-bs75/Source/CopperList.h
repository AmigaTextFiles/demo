#ifndef _COPPERLIST_H
#define _COPPERLIST_H

#include "Util.h"

#define copperWait(y, x) (((y) << 24) | ((x) << 16) | 0x0001fffe)
#define copperMove(register, data) ((register << 16) | (uint16_t)(data))

class Sprite;
class Bitmap;

class CopperList {
public:
    CopperList();
    CopperList(uint32_t* data, uint32_t length = 0, bool takeOwnership = false);
    virtual ~CopperList();

    __inline uint32_t* data() const;

#ifdef ASSEMBLER
    __asm void showSprite(register __d0 uint32_t listIndex, register __d1 uint16_t spriteNumber, register __a1 const Sprite& sprite);
    __asm void showBitmap(register __d0 uint32_t listIndex, register __a1 const Bitmap& bitmap, register __d1 uint16_t firstBitplane = 1, register __d2 uint16_t bitplaneNumberDelta = 1, register __d3 int16_t xOffset = 0, register __d4 int16_t yOffset = 0, register __d5 uint16_t bitplaneCount = 0);
#else
    void showSprite(uint32_t listIndex, uint16_t spriteNumber, const Sprite& sprite);
    void showBitmap(uint32_t listIndex, const Bitmap& bitmap, uint16_t firstBitplane = 1, uint16_t bitplaneNumberDelta = 1, int16_t xOffset = 0, int16_t yOffset = 0, uint16_t bitplaneCount = 0);
#endif

    static CopperList* allocate(uint32_t length);

protected:
    uint32_t* data_;
    uint32_t length;
    bool owner;
};

#endif
