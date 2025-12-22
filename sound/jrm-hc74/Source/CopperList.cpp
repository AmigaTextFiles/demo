#include <proto/exec.h>
#include <exec/memory.h>
#include "Copperlist.h"
#include "Palette.h"
#include "AmigaHardware.h"
#include "Sprite.h"
#include "Bitmap.h"

CopperList::CopperList() :
    data_(0),
    length(0),
    owner(false)
{
}

CopperList::CopperList(uint32_t* data, uint32_t length, bool takeOwnership) :
    data_(data),
    length(length),
    owner(takeOwnership)
{
    if (length > 0) {
        data_[0] = copperWait(16, 0);
        data_[length - 1] = copperWait(255, 254);
    }
}

CopperList::~CopperList()
{
    if (owner) {
        FreeMem(data_, length << 2);
    }
}

uint32_t* CopperList::data() const
{
    return data_;
}

CopperList* CopperList::allocate(uint32_t length)
{
    uint32_t* data = (uint32_t*)AllocMem(length << 2, MEMF_CHIP | MEMF_CLEAR);
    return data ? new CopperList(data, length, true) : 0;
}

#ifndef ASSEMBLER
void CopperList::showSprite(uint32_t listIndex, uint16_t spriteNumber, const Sprite& sprite)
{
    uint32_t spriteData = (uint32_t)sprite.data();
    data_[listIndex++] = copperMove(spr1pth + (spriteNumber << 2), (uint16_t)(spriteData >> 16));
    data_[listIndex] = copperMove(spr1ptl + (spriteNumber << 2), (uint16_t)spriteData);
}

void CopperList::showBitmap(uint32_t listIndex, const Bitmap& bitmap, uint16_t firstBitplane, uint16_t bitplaneNumberDelta, int16_t xOffset, int16_t yOffset, uint16_t bitplaneCount)
{
    uint32_t bitplane = (uint32_t)bitmap.data;
    if (xOffset) {
        bitplane += xOffset >> 3;
    }
    if (yOffset) {
        bitplane += yOffset * bitmap.rowSizeInBytes;
    }
    if (bitplaneCount == 0) {
        bitplaneCount = bitmap.bitplanes;
    }
    uint16_t bitplanePointerRegister = bpl1pth + ((firstBitplane - 1) << 2);
    for (uint16_t i = 0; i < bitplaneCount; i++, bitplanePointerRegister += (bitplaneNumberDelta << 2)) {
        data_[listIndex++] = copperMove(bitplanePointerRegister, (uint16_t)(bitplane >> 16));
        data_[listIndex++] = copperMove(bitplanePointerRegister + 2, (uint16_t)bitplane);
        bitplane += bitmap.interleaved ? bitmap.widthInBytes : bitmap.bitplaneSizeInBytes;
    }
}
#endif
