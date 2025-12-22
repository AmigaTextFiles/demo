#ifndef _GAMECOPPERLIST_H
#define _GAMECOPPERLIST_H

#include "Copperlist.h"

class Bitmap;
class Sprite;

class GameCopperList : public CopperList {
public:
    GameCopperList(uint16_t* roadLineZ, int16_t** roadLineScale);

    void showScroller(const Bitmap& bitmap);
    void showHeader(const Bitmap& bitmap);
    void showHorizonBack(const Bitmap& bitmap, int16_t xOffset);
    void showObjects(const Bitmap& bitmap);
    void showHorizonParallax(const Bitmap& bitmap);
    void showRoad(const Bitmap& bitmap, int16_t xPosition, uint16_t zPosition, int16_t* roadGeometry, int16_t bottomRoadX);
    void showSprites(const Sprite& sprite0, const Sprite& sprite1, const Sprite& sprite2, const Sprite& sprite3, const Sprite& sprite4, const Sprite& sprite5, const Sprite& sprite6, const Sprite& sprite7);
    void setScrollerXOffset(uint16_t xOffset);

private:
#ifdef ASSEMBLER
    __asm void writeCopperlist(register __d0 int16_t xPosition = 0, register __d1 uint16_t zPosition = 0, register __a1 int16_t* roadGeometry = 0, register __a2 int16_t bottomRoadX = 0);
#else
    void writeCopperlist(int16_t xPosition = 0, uint16_t zPosition = 0, int16_t* roadGeometry = 0, int16_t bottomRoadX = 0);
#endif

    uint16_t* roadLineZ;
    int16_t** roadLineScale;
};

#endif
