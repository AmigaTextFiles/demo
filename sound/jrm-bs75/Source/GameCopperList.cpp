#define ECS_SPECIFIC 
#include <proto/exec.h>
#include <exec/memory.h>
#include <hardware/custom.h>
#include <graphics/display.h>
#include "GameCopperList.h"
#include "AmigaHardware.h"
#include "GamePart.h"
#include "Bitmap.h"

#define INDEX_WAIT_ABOVE_SCREEN 0
#define INDEX_SET_SPRITES (INDEX_WAIT_ABOVE_SCREEN + 1)
#define INDEX_SET_HORIZON_BACK_BITPLANES (INDEX_SET_SPRITES + 16)
#define INDEX_SET_SCROLLER_BITPLANE (INDEX_SET_HORIZON_BACK_BITPLANES + 6)
#define INDEX_SET_ABOVE_SCROLLER_MODULO (INDEX_SET_SCROLLER_BITPLANE + 2)
#define INDEX_SET_SCROLLER_SHIFT (INDEX_SET_ABOVE_SCROLLER_MODULO + 1)
#define INDEX_ENABLE_SINGLE_BITPLANE (INDEX_SET_SCROLLER_SHIFT + 1)
#define INDEX_SET_PALETTE (INDEX_ENABLE_SINGLE_BITPLANE + 1)
#define INDEX_WAIT_SCROLLER_TOP (INDEX_SET_PALETTE + 15)
#define INDEX_SET_SCROLLER_TOP_MODULO (INDEX_WAIT_SCROLLER_TOP + 1)
#define INDEX_WAIT_SCROLLER (INDEX_SET_SCROLLER_TOP_MODULO + 1)
#define INDEX_SET_SCROLLER_MODULO (INDEX_WAIT_SCROLLER + 1)
#define INDEX_WAIT_HEADER (INDEX_SET_SCROLLER_MODULO + 1)
#define INDEX_SET_HEADER_BITPLANES (INDEX_WAIT_HEADER + 1)
#define INDEX_SET_HEADER_MODULO (INDEX_SET_HEADER_BITPLANES + 6)
#define INDEX_SET_HEADER_SHIFT (INDEX_SET_HEADER_MODULO + 2)
#define INDEX_ENABLE_SINGLE_PLAYFIELD (INDEX_SET_HEADER_SHIFT + 1)
#define INDEX_WAIT_OBJECTS (INDEX_ENABLE_SINGLE_PLAYFIELD + 1)
#define INDEX_SET_OBJECTS_BITPLANES_SKY (INDEX_WAIT_OBJECTS + 1)
#define INDEX_SET_SKY_MODULO (INDEX_SET_OBJECTS_BITPLANES_SKY + 6)
#define INDEX_WAIT_HORIZON_BACK (INDEX_SET_SKY_MODULO + 2)
#define INDEX_SET_OBJECTS_BITPLANES_HORIZON (INDEX_WAIT_HORIZON_BACK + 1)
#define INDEX_SET_HORIZON_BACK_BITPLANE (INDEX_SET_OBJECTS_BITPLANES_HORIZON + 6)
#define INDEX_SET_HORIZON_BACK_MODULO (INDEX_SET_HORIZON_BACK_BITPLANE + 2)
#define INDEX_SET_HORIZON_BACK_SHIFT (INDEX_SET_HORIZON_BACK_MODULO + 1)
#define INDEX_ENABLE_DUAL_PLAYFIELD (INDEX_SET_HORIZON_BACK_SHIFT + 1)
#define INDEX_WAIT_HORIZON_PARALLAX (INDEX_ENABLE_DUAL_PLAYFIELD + 1)
#define INDEX_SET_HORIZON_PARALLAX_BITPLANES (INDEX_WAIT_HORIZON_PARALLAX + 1)
#define INDEX_SET_HORIZON_PARALLAX_MODULO (INDEX_SET_HORIZON_PARALLAX_BITPLANES + 6)
#define INDEX_SET_HORIZON_PARALLAX_SHIFT (INDEX_SET_HORIZON_PARALLAX_MODULO + 1)
#define INDEX_WAIT_ROAD (INDEX_SET_HORIZON_PARALLAX_SHIFT + 1)
#define INDEX_SET_ROAD_BITPLANES (INDEX_WAIT_ROAD + 1)
#define INDEX_ROAD (INDEX_SET_ROAD_BITPLANES + 6)
#define ROAD_ROW_LENGTH 7
#define INDEX_WAIT_FOREVER (INDEX_ROAD + ROAD_HEIGHT * ROAD_ROW_LENGTH)
#define LIST_LENGTH (INDEX_WAIT_FOREVER + 1)

static const uint16_t skyColors[] = { 0x00f, 0xfff, 0x000, 0xf00, 0xff0, 0x0f0, 0xf0f, 0x0ff };
static const uint16_t horizonColors[] = { 0x00f, 0xbcf, 0x89c, 0x7f9, 0x4b9, 0x069, 0xfff, 0xf00 };
static const uint16_t objectsColors[] = { 0x00f, 0xfff, 0x000, 0xaaa, 0xf00, 0xff0, 0x0f0, 0x00f };
static const uint16_t roadColors[] = { 0x0d9, 0x666, 0xfff, 0xfff, 0xfff, 0x566, 0xb00, 0x566 };

GameCopperList::GameCopperList(uint16_t* roadLineZ, int16_t** roadLineScale) : CopperList((uint32_t*)AllocMem(LIST_LENGTH << 2, MEMF_CHIP | MEMF_CLEAR), LIST_LENGTH, true),
    roadLineZ(roadLineZ),
    roadLineScale(roadLineScale)
{
    uint32_t* palette = data_ + INDEX_SET_PALETTE;
    for (uint16_t color = 0; color < 8; color++) {
        *palette++ = copperMove(color00 + color + color, objectsColors[color]);
    }
    for (color = 1; color < 8; color++) {
        *palette++ = copperMove(color08 + color + color, horizonColors[color]);
    }

    *(data_ + INDEX_SET_ABOVE_SCROLLER_MODULO) = copperMove(bpl1mod, (-SCREEN_FETCH_WIDTH) >> 3);
    *(data_ + INDEX_SET_SCROLLER_SHIFT) = copperMove(bplcon1, 0);
    *(data_ + INDEX_ENABLE_SINGLE_BITPLANE) = copperMove(bplcon0, (SCROLLER_BITPLANES << PLNCNTSHFT) | USE_BPLCON3);
    *(data_ + INDEX_WAIT_SCROLLER_TOP) = copperWait(34, 240);
    *(data_ + INDEX_SET_SCROLLER_TOP_MODULO) = copperMove(bpl1mod, (SCROLLER_WIDTH - SCREEN_FETCH_WIDTH) >> 3);
    *(data_ + INDEX_WAIT_SCROLLER) = copperWait(35, 240);
    *(data_ + INDEX_SET_SCROLLER_MODULO) = copperMove(bpl1mod, (SCROLLER_WIDTH - SCREEN_FETCH_WIDTH) >> 3);
    *(data_ + INDEX_WAIT_HEADER) = copperWait(42, 240);
    *(data_ + INDEX_SET_HEADER_MODULO) = copperMove(bpl1mod, (HEADER_BITPLANES * HEADER_WIDTH - HEADER_WIDTH) >> 3);
    *(data_ + INDEX_SET_HEADER_MODULO + 1) = copperMove(bpl2mod, (HEADER_BITPLANES * HEADER_WIDTH - HEADER_WIDTH) >> 3);
    *(data_ + INDEX_SET_HEADER_SHIFT) = copperMove(bplcon1, 0);
    *(data_ + INDEX_ENABLE_SINGLE_PLAYFIELD) = copperMove(bplcon0, (HEADER_BITPLANES << PLNCNTSHFT) | USE_BPLCON3);
    *(data_ + INDEX_WAIT_OBJECTS) = copperWait(71, 240);
    *(data_ + INDEX_SET_SKY_MODULO) = copperMove(bpl1mod, (OBJECTS_BITPLANES * OBJECTS_WIDTH - SCREEN_FETCH_WIDTH) >> 3);
    *(data_ + INDEX_SET_SKY_MODULO + 1) = copperMove(bpl2mod, (OBJECTS_BITPLANES * OBJECTS_WIDTH - SCREEN_FETCH_WIDTH) >> 3);
    *(data_ + INDEX_WAIT_HORIZON_BACK) = copperWait(95, 240);
    *(data_ + INDEX_SET_HORIZON_BACK_MODULO) = copperMove(bpl2mod, (HORIZON_BITPLANES * HORIZON_BACK_WIDTH - SCREEN_FETCH_WIDTH) >> 3);
    *(data_ + INDEX_SET_HORIZON_BACK_SHIFT) = copperMove(bplcon1, 0);
    *(data_ + INDEX_ENABLE_DUAL_PLAYFIELD) = copperMove(bplcon0, (SCREEN_BITPLANES << PLNCNTSHFT) | DBLPF | USE_BPLCON3);
    *(data_ + INDEX_WAIT_HORIZON_PARALLAX) = copperWait(143, 240);
    *(data_ + INDEX_SET_HORIZON_PARALLAX_MODULO) = copperMove(bpl2mod, (HORIZON_BITPLANES * HORIZON_PARALLAX_WIDTH - SCREEN_FETCH_WIDTH) >> 3);
    *(data_ + INDEX_SET_HORIZON_PARALLAX_SHIFT) = copperMove(bplcon1, 0);
    *(data_ + INDEX_WAIT_ROAD) = copperWait(159, 240);
    uint32_t* road = data_ + INDEX_ROAD;
    for (uint16_t y = 159; y < 255; y++) {
        *road++ = copperWait(y, 240);
        *road++ = copperMove(bplcon1, 0);
        *road++ = copperMove(color00, roadColors[0]);
        *road++ = copperMove(color09, roadColors[1]);
        *road++ = copperMove(color10, roadColors[2]);
        *road++ = copperMove(color11, roadColors[3]);
        *road++ = copperMove(bpl2mod, ((ROAD_BITPLANES * ROAD_WIDTH - SCREEN_FETCH_WIDTH) >> 3));
    }

    *(data_ + INDEX_ROAD) = copperMove(color12, roadColors[4]);
    *(data_ + INDEX_ROAD + 0 * ROAD_ROW_LENGTH + 2) = copperMove(color00, 0x089);
    *(data_ + INDEX_ROAD + 1 * ROAD_ROW_LENGTH + 2) = copperMove(color00, 0x099);
    *(data_ + INDEX_ROAD + 2 * ROAD_ROW_LENGTH + 2) = copperMove(color00, 0x099);
    *(data_ + INDEX_ROAD + 3 * ROAD_ROW_LENGTH + 2) = copperMove(color00, 0x0a9);
    *(data_ + INDEX_ROAD + 4 * ROAD_ROW_LENGTH + 2) = copperMove(color00, 0x0a9);
    *(data_ + INDEX_ROAD + 5 * ROAD_ROW_LENGTH + 2) = copperMove(color00, 0x0a9);
    *(data_ + INDEX_ROAD + 6 * ROAD_ROW_LENGTH + 2) = copperMove(color00, 0x0b9);
    *(data_ + INDEX_ROAD + 7 * ROAD_ROW_LENGTH + 2) = copperMove(color00, 0x0b9);
    *(data_ + INDEX_ROAD + 8 * ROAD_ROW_LENGTH + 2) = copperMove(color00, 0x0c9);
    *(data_ + INDEX_ROAD + 9 * ROAD_ROW_LENGTH + 2) = copperMove(color00, 0x0c9);

    writeCopperlist();
}

void GameCopperList::showScroller(const Bitmap& bitmap)
{
    showBitmap(INDEX_SET_SCROLLER_BITPLANE, bitmap);
}

void GameCopperList::showHeader(const Bitmap& bitmap)
{
    showBitmap(INDEX_SET_HEADER_BITPLANES, bitmap, 1, 1, -16);
}

void GameCopperList::showHorizonBack(const Bitmap& bitmap, int16_t xOffset)
{
    *(data_ + INDEX_SET_HORIZON_BACK_SHIFT) = copperMove(bplcon1, ((-xOffset + 15) & 15) << 4);
    showBitmap(INDEX_SET_HORIZON_BACK_BITPLANES, bitmap, 2, 2, xOffset);
    showBitmap(INDEX_SET_HORIZON_BACK_BITPLANE, bitmap, 2, 2, xOffset, 0, 1);
}

void GameCopperList::showObjects(const Bitmap& bitmap)
{
    showBitmap(INDEX_SET_OBJECTS_BITPLANES_SKY, bitmap, 1, 1, (OBJECTS_WIDTH - SCREEN_FETCH_WIDTH));
    showBitmap(INDEX_SET_OBJECTS_BITPLANES_HORIZON, bitmap, 1, 2, (OBJECTS_WIDTH - SCREEN_FETCH_WIDTH), HORIZON_BACK_Y);
}

void GameCopperList::showHorizonParallax(const Bitmap& bitmap)
{
    showBitmap(INDEX_SET_HORIZON_PARALLAX_BITPLANES, bitmap, 2, 2, 0);
}

void GameCopperList::showRoad(const Bitmap& bitmap, int16_t xPosition, uint16_t zPosition, int16_t* roadGeometry, int16_t bottomRoadX)
{
    uint16_t z = roadLineZ[0] + zPosition;
    int16_t dx = roadLineScale[0][((uint16_t)(-xPosition)) & 1023] - (roadGeometry[z >> 7] - bottomRoadX);

    showBitmap(INDEX_SET_ROAD_BITPLANES, bitmap, 2, 2, ((ROAD_WIDTH - SCREEN_WIDTH) >> 1) - (dx == 0 ? dx : (dx - 15)) - 16);

    writeCopperlist(xPosition, zPosition, roadGeometry, bottomRoadX);
}

void GameCopperList::showSprites(const Sprite& sprite0, const Sprite& sprite1, const Sprite& sprite2, const Sprite& sprite3, const Sprite& sprite4, const Sprite& sprite5, const Sprite& sprite6, const Sprite& sprite7)
{
    showSprite(INDEX_SET_SPRITES + 0, 0, sprite0);
    showSprite(INDEX_SET_SPRITES + 2, 1, sprite1);
    showSprite(INDEX_SET_SPRITES + 4, 2, sprite2);
    showSprite(INDEX_SET_SPRITES + 6, 3, sprite3);
    showSprite(INDEX_SET_SPRITES + 8, 4, sprite4);
    showSprite(INDEX_SET_SPRITES + 10, 5, sprite5);
    showSprite(INDEX_SET_SPRITES + 12, 6, sprite6);
    showSprite(INDEX_SET_SPRITES + 14, 7, sprite7);
}

void GameCopperList::setScrollerXOffset(uint16_t xOffset)
{
    *(data_ + INDEX_SET_SCROLLER_TOP_MODULO) = copperMove(bpl1mod, (SCROLLER_WIDTH - SCREEN_FETCH_WIDTH + xOffset) >> 3);
    *(data_ + INDEX_SET_SCROLLER_SHIFT) = copperMove(bplcon1, ((~xOffset) & 15));
}

#ifndef ASSEMBLER
void GameCopperList::writeCopperlist(int16_t xPosition, uint16_t zPosition, int16_t* roadGeometry, int16_t bottomRoadX)
{
    uint32_t* road = data_ + INDEX_ROAD + 1;

    uint16_t z = roadLineZ[0] + zPosition;
    int16_t dx = roadLineScale[0][((uint16_t)(-xPosition)) & 1023] - (roadGeometry[z >> 7] - bottomRoadX);
    int16_t dxBytes = (dx >> 3) & 0xfffe;
    *road++ = copperMove(bplcon1, (dx & 15) << 4);
    road++;           // color00
    *road++ = copperMove(color09, roadColors[(z & 512) < 256 ? 1 : 5]);
    *road++ = copperMove(color10, roadColors[(z & 256) < 128 ? 2 : 6]);
    *road++ = copperMove(color11, roadColors[(z & 512) < 256 ? 3 : 7]);
    for (uint16_t y = 1; y < ROAD_HEIGHT; y++) {
        int16_t oldDxBytes = dxBytes;
        z = (uint16_t)(roadLineZ[y] + zPosition);
        dx = (int16_t)(roadLineScale[y][((uint16_t)(-xPosition)) & 1023] - (roadGeometry[z >> 7] - bottomRoadX));
        dxBytes = (int16_t)((dx >> 3) & 0xfffe);
        *road++ = copperMove(bpl2mod, ((ROAD_BITPLANES * ROAD_WIDTH - SCREEN_WIDTH) >> 3) - (dxBytes - oldDxBytes) - 2);
        road++;// copperWait
        *road++ = copperMove(bplcon1, (dx & 15) << 4);
        road++;           // color00
        *road++ = copperMove(color09, roadColors[(z & 512) < 256 ? 1 : 5]);
        *road++ = copperMove(color10, roadColors[(z & 256) < 128 ? 2 : 6]);
        *road++ = copperMove(color11, roadColors[(z & 512) < 256 ? 3 : 7]);
    }
    *road++ = copperMove(bpl2mod, ((ROAD_BITPLANES * ROAD_WIDTH - SCREEN_WIDTH) >> 3) - 2);
}
#endif
