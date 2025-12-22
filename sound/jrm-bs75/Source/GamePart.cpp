/*
 * TODO
 *
 * - fix viewport size problems on A600/68020
 */
#include <string.h>
#include <graphics/display.h>
#include "GamePart.h"
#include "Sprite.h"
#include "Bitmap.h"
#include "AmigaHardware.h"
#include "Util.h"
#include "ModulePlayer.h"

#define Z_MIN 1536
#define Z_MAX 40000
#define ROADSIDE_OBJECT_DISTANCE ((Z_MAX - Z_MIN) / 4)
#define BIKE_DISTANCE Z_MAX
#define BIKE_SPRITE_STANCE_DELAY_SAME_DIRECTION 4
#define BIKE_SPRITE_STANCE_DELAY_OTHER_DIRECTION 12
#define ZDELTA_MAX 808

static const uint16_t bikeSpriteColors[] = { 0xaba, 0x08f, 0xf30, 0xfff, 0x00a, 0xc00, 0xddd, 0xf90, 0xaba, 0x444, 0x222, 0x888, 0x800, 0xf30 };

__far extern uint32_t scoreboard[];
__far extern uint8_t font[];
__far extern uint32_t road[];
__chip extern uint16_t horizonBack[];
__chip extern uint16_t horizonFront[];
__chip extern uint8_t leftBobBundle[];
__chip extern uint8_t rightBobBundle[];
__chip extern uint8_t treeBobBundle[];
__chip extern uint8_t bikeGreenMiddleMiddleBobBundle[];
__chip extern uint8_t bikeGreenLeft1MiddleBobBundle[];
__chip extern uint8_t bikeGreenLeft2MiddleBobBundle[];
__chip extern uint8_t bikeGreenLeft3MiddleBobBundle[];
__chip extern uint8_t bikeGreenRight1MiddleBobBundle[];
__chip extern uint8_t bikeGreenRight2MiddleBobBundle[];
__chip extern uint8_t bikeGreenRight3MiddleBobBundle[];
__chip extern uint8_t bikeRedMiddleMiddleBobBundle[];
__chip extern uint8_t bikeRedLeft1MiddleBobBundle[];
__chip extern uint8_t bikeRedLeft2MiddleBobBundle[];
__chip extern uint8_t bikeRedLeft3MiddleBobBundle[];
__chip extern uint8_t bikeRedRight1MiddleBobBundle[];
__chip extern uint8_t bikeRedRight2MiddleBobBundle[];
__chip extern uint8_t bikeRedRight3MiddleBobBundle[];
__chip extern uint8_t bikeYellowMiddleMiddleBobBundle[];
__chip extern uint8_t bikeYellowLeft1MiddleBobBundle[];
__chip extern uint8_t bikeYellowLeft2MiddleBobBundle[];
__chip extern uint8_t bikeYellowLeft3MiddleBobBundle[];
__chip extern uint8_t bikeYellowRight1MiddleBobBundle[];
__chip extern uint8_t bikeYellowRight2MiddleBobBundle[];
__chip extern uint8_t bikeYellowRight3MiddleBobBundle[];
__chip extern uint8_t bikeBlueMiddleMiddleBobBundle[];
__chip extern uint8_t bikeBlueLeft1MiddleBobBundle[];
__chip extern uint8_t bikeBlueLeft2MiddleBobBundle[];
__chip extern uint8_t bikeBlueLeft3MiddleBobBundle[];
__chip extern uint8_t bikeBlueRight1MiddleBobBundle[];
__chip extern uint8_t bikeBlueRight2MiddleBobBundle[];
__chip extern uint8_t bikeBlueRight3MiddleBobBundle[];
__chip extern uint16_t bikePlayerMiddleSprite01[];
__chip extern uint16_t bikePlayerMiddleSprite23[];
__chip extern uint16_t bikePlayerMiddleSprite45[];
__chip extern uint16_t bikePlayerMiddleSprite67[];
__chip extern uint16_t bikePlayerLeft1Sprite01[];
__chip extern uint16_t bikePlayerLeft1Sprite23[];
__chip extern uint16_t bikePlayerLeft1Sprite45[];
__chip extern uint16_t bikePlayerLeft1Sprite67[];
__chip extern uint16_t bikePlayerLeft2Sprite01[];
__chip extern uint16_t bikePlayerLeft2Sprite23[];
__chip extern uint16_t bikePlayerLeft2Sprite45[];
__chip extern uint16_t bikePlayerLeft2Sprite67[];
__chip extern uint16_t bikePlayerLeft3Sprite01[];
__chip extern uint16_t bikePlayerLeft3Sprite23[];
__chip extern uint16_t bikePlayerLeft3Sprite45[];
__chip extern uint16_t bikePlayerLeft3Sprite67[];
__chip extern uint16_t bikePlayerRight1Sprite01[];
__chip extern uint16_t bikePlayerRight1Sprite23[];
__chip extern uint16_t bikePlayerRight1Sprite45[];
__chip extern uint16_t bikePlayerRight1Sprite67[];
__chip extern uint16_t bikePlayerRight2Sprite01[];
__chip extern uint16_t bikePlayerRight2Sprite23[];
__chip extern uint16_t bikePlayerRight2Sprite45[];
__chip extern uint16_t bikePlayerRight2Sprite67[];
__chip extern uint16_t bikePlayerRight3Sprite01[];
__chip extern uint16_t bikePlayerRight3Sprite23[];
__chip extern uint16_t bikePlayerRight3Sprite45[];
__chip extern uint16_t bikePlayerRight3Sprite67[];

char* topScoreText = " 1000000";
char* scoreText = "       0";
const char* stageText = "STAGE 75";
const char* speedKMText = "SPEED    KM";
char* speedText = "  0";
char* scrollText = "DA JORMAS PRESENTS BONUS STAGE 75   CODE BY VESURI   SEGA AM2 GRAPHICS AND MUSIC CONVERTED BY VESURI   THIS PROOF OF CONCEPT FOR ARCADE PERFECTNESS ON THE AMIGA WAS INSPIRED BY THE VARIOUS NOT SO STELLAR AMIGA PORTS FROM BACK IN THE DAY. 50 FPS WOULD INDEED HAVE BEEN POSSIBLE ON THE ORIGINAL HARDWARE... BUT ONLY BARELY. THE MEMORY BUS IS A MAJOR BOTTLENECK ON SYSTEMS WITH NO REAL FAST MEMORY. THE AMOUNT OF CHIP MEMORY WOULD ALSO HAVE REQUIRED SOME AGGRESSIVE STREAMING OF ASSETS FROM DISK AND THE ORIGINAL CHIPSET DUAL PLAYFIELD MODE FALLS JUST A BIT SHORT ON THE NUMBER OF AVAILABLE COLORS. THE A1200 WOULD BE PERFECT FOR AN ACCURATE PORT THOUGH. PERHAPS A PROJECT FOR SOME OTHER CRAZY MF... DA JORMAS SIGNING OFF.";

struct BobHeader {
    uint32_t offset;
    uint16_t width;
    uint16_t height;
};

struct BobBundleHeader {
    uint16_t bitmapCount;
    uint16_t bitplaneCount;
    BobHeader bobHeaders;
};

GamePart::BitmapObject::BitmapObject(uint8_t* bobBundle, uint8_t* maskData) :
    bitmaps(0),
    masks(0),
    bitmapCount(0),
    maskOwner(maskData ? true : false)
{
    BobBundleHeader* bobBundleHeader = (BobBundleHeader*)bobBundle;
    bitmapCount = bobBundleHeader->bitmapCount;
    bitmaps = new Bitmap*[bitmapCount];
    if (maskData) {
        masks = new Bitmap*[bitmapCount];
    }

    BobHeader* bobHeaders = &bobBundleHeader->bobHeaders;
    uint8_t* bitmapData = bobBundle + 4 + 8 * bobBundleHeader->bitmapCount;
    for (uint16_t i = 0; i < bitmapCount; i++) {
        uint16_t width = bobHeaders[i].width;
        uint16_t height = bobHeaders[i].height;
        uint32_t offset = bobHeaders[i].offset;
        uint16_t dataWidth = (width + 31) & 0xfff0;

        bitmaps[i] = new Bitmap(bitmapData + offset, width, height, bobBundleHeader->bitplaneCount, true, false, dataWidth);
        if (maskData) {
            masks[i] = Bitmap::generateMask(*bitmaps[i], maskData, false);
            maskData += (dataWidth >> 3) * height * bobBundleHeader->bitplaneCount;
        }
    }
}

GamePart::BitmapObject::BitmapObject(uint16_t bitmapCount, Bitmap** bitmaps, Bitmap** masks) :
    bitmaps(bitmaps),
    masks(masks),
    bitmapCount(bitmapCount),
    maskOwner(true)
{
}

GamePart::BitmapObject::~BitmapObject()
{
    for (uint16_t i = 0; i < bitmapCount; i++) {
        delete bitmaps[i];
        if (maskOwner) {
            delete masks[i];
        }
    }
    delete[] bitmaps;
    if (maskOwner) {
        delete[] masks;
    }
}

uint32_t GamePart::BitmapObject::totalMasksSize() const
{
    uint32_t masksSize = 0;
    for (uint16_t i = 0; i < bitmapCount; i++) {
        masksSize += masks[i]->dataSize();
    }
    return masksSize;
}

GamePart::Object::Object() :
    x(0),
    z(0),
    anchorRight(false),
    isBike(false)
{
}

GamePart::BikeSprite::BikeSprite(uint16_t* data01, uint16_t* data23, uint16_t* data45, uint16_t* data67) :
    sprite0(data01, 72),
    sprite1(data01 + 72 * 2 + 4, 72, true),
    sprite2(data23, 72),
    sprite3(data23 + 72 * 2 + 4, 72, true),
    sprite4(data45, 72),
    sprite5(data45 + 72 * 2 + 4, 72, true),
    sprite6(data67, 72),
    sprite7(data67 + 72 * 2 + 4, 72, true)
{
}

GamePart::GamePart() :
    roadLineZ(new uint16_t[ROAD_HEIGHT]),
    roadLineScale(new int16_t*[ROAD_HEIGHT]),
    roadGeometry(new int16_t[512]),
    roadAngle(0),
    xPosition(0),
    zPosition(0),
    zDelta(0),
    horizonBackX(512),
    horizonFrontX(1024),
    bottomRoadX(0),
    bikeSpriteStance(0),
    bikeSpriteStanceDelay(0),
    score(0),
    topScore(1000000),
    scrollerXOffset(0),
    scoreboardBitmap(0),
    horizonBackBitmap(0),
    horizonFrontBitmap(0),
    horizonFrontMask(0),
    renderTargetObjectsBitmap(0),
    renderTargetCopperList(0),
    previousBoundingRect(0),
    distanceToPreviousRoadsideObject(0),
    distanceToPreviousBike(0),
    bikeToSpawn(0),
    frameReady(false),
    bikeSpriteRight3(bikePlayerRight3Sprite01, bikePlayerRight3Sprite23, bikePlayerRight3Sprite45, bikePlayerRight3Sprite67),
    bikeSpriteRight2(bikePlayerRight2Sprite01, bikePlayerRight2Sprite23, bikePlayerRight2Sprite45, bikePlayerRight2Sprite67),
    bikeSpriteRight1(bikePlayerRight1Sprite01, bikePlayerRight1Sprite23, bikePlayerRight1Sprite45, bikePlayerRight1Sprite67),
    bikeSpriteMiddle(bikePlayerMiddleSprite01, bikePlayerMiddleSprite23, bikePlayerMiddleSprite45, bikePlayerMiddleSprite67),
    bikeSpriteLeft1(bikePlayerLeft1Sprite01, bikePlayerLeft1Sprite23, bikePlayerLeft1Sprite45, bikePlayerLeft1Sprite67),
    bikeSpriteLeft2(bikePlayerLeft2Sprite01, bikePlayerLeft2Sprite23, bikePlayerLeft2Sprite45, bikePlayerLeft2Sprite67),
    bikeSpriteLeft3(bikePlayerLeft3Sprite01, bikePlayerLeft3Sprite23, bikePlayerLeft3Sprite45, bikePlayerLeft3Sprite67),
    currentBikeSprite(&bikeSpriteMiddle),
    scrollerBitmap(0),
    headerBitmap(0),
    objectsBitmap1(0),
    objectsBitmap2(0),
    roadBitmap(0),
    horizonParallaxBitmap(0),
    left(0),
    right(0),
    tree(0),
    bikeGreenMiddleMiddle(0),
    bikeGreenLeft1Middle(0),
    bikeGreenLeft2Middle(0),
    bikeGreenLeft3Middle(0),
    bikeGreenRight1Middle(0),
    bikeGreenRight2Middle(0),
    bikeGreenRight3Middle(0),
    bikeRedMiddleMiddle(0),
    bikeRedLeft1Middle(0),
    bikeRedLeft2Middle(0),
    bikeRedLeft3Middle(0),
    bikeRedRight1Middle(0),
    bikeRedRight2Middle(0),
    bikeRedRight3Middle(0),
    bikeYellowMiddleMiddle(0),
    bikeYellowLeft1Middle(0),
    bikeYellowLeft2Middle(0),
    bikeYellowLeft3Middle(0),
    bikeYellowRight1Middle(0),
    bikeYellowRight2Middle(0),
    bikeYellowRight3Middle(0),
    bikeBlueMiddleMiddle(0),
    bikeBlueLeft1Middle(0),
    bikeBlueLeft2Middle(0),
    bikeBlueLeft3Middle(0),
    bikeBlueRight1Middle(0),
    bikeBlueRight2Middle(0),
    bikeBlueRight3Middle(0),
    previousBoundingRect1(Point2D(0, 0), Point2D(OBJECTS_WIDTH - 1, OBJECTS_HEIGHT - 1)),
    previousBoundingRect2(Point2D(0, 0), Point2D(OBJECTS_WIDTH - 1, OBJECTS_HEIGHT - 1)),
    copperList1(roadLineZ, roadLineScale),
    copperList2(roadLineZ, roadLineScale),
    bikeSpritePosition(275, 183),
    bikeSpritePalette(bikeSpriteColors, 14),
    roadLineScaleValues(new int16_t[ROAD_HEIGHT * 1024])
{
    for (uint16_t i = 0; i < ROAD_HEIGHT; i++) {
        roadLineScale[i] = roadLineScaleValues + (i * 1024);
    }

    for (i = 0; i < 512; i++) {
        roadGeometry[i] = 0;   
    }

    calculateRoadLineTables();

    setBikeSpritePosition(bikeSpriteMiddle);
    setBikeSpritePosition(bikeSpriteLeft1);
    setBikeSpritePosition(bikeSpriteLeft2);
    setBikeSpritePosition(bikeSpriteLeft3);
    setBikeSpritePosition(bikeSpriteRight1);
    setBikeSpritePosition(bikeSpriteRight2);
    setBikeSpritePosition(bikeSpriteRight3);
}

GamePart::~GamePart()
{
    delete scrollerBitmap;
    delete headerBitmap;
    delete objectsBitmap1;
    delete objectsBitmap2;
    delete roadBitmap;
    delete horizonParallaxBitmap;
    delete left;
    delete right;
    delete tree;
    delete bikeGreenMiddleMiddle;
    delete bikeGreenLeft1Middle;
    delete bikeGreenLeft2Middle;
    delete bikeGreenLeft3Middle;
    delete bikeGreenRight1Middle;
    delete bikeGreenRight2Middle;
    delete bikeGreenRight3Middle;
    delete bikeRedMiddleMiddle;
    delete bikeRedLeft1Middle;
    delete bikeRedLeft2Middle;
    delete bikeRedLeft3Middle;
    delete bikeRedRight1Middle;
    delete bikeRedRight2Middle;
    delete bikeRedRight3Middle;
    delete bikeYellowMiddleMiddle;
    delete bikeYellowLeft1Middle;
    delete bikeYellowLeft2Middle;
    delete bikeYellowLeft3Middle;
    delete bikeYellowRight1Middle;
    delete bikeYellowRight2Middle;
    delete bikeYellowRight3Middle;
    delete bikeBlueMiddleMiddle;
    delete bikeBlueLeft1Middle;
    delete bikeBlueLeft2Middle;
    delete bikeBlueLeft3Middle;
    delete bikeBlueRight1Middle;
    delete bikeBlueRight2Middle;
    delete bikeBlueRight3Middle;
    delete scoreboardBitmap;
    delete horizonBackBitmap;
    delete horizonFrontBitmap;
    delete horizonFrontMask;
    delete[] roadGeometry;
    delete[] roadLineZ;
    delete[] roadLineScale;
    delete[] roadLineScaleValues;
}

void GamePart::initialize()
{
    uint8_t* bitmapData = (uint8_t*)chipMemory;
    scrollerBitmap = new Bitmap(bitmapData, SCROLLER_WIDTH, SCROLLER_HEIGHT, SCROLLER_BITPLANES, true);
    bitmapData += SCROLLER_BITPLANES * SCROLLER_BITPLANE_SIZE;
    headerBitmap = new Bitmap(bitmapData, HEADER_WIDTH, HEADER_HEIGHT, HEADER_BITPLANES, true);
    bitmapData += HEADER_BITPLANES * HEADER_BITPLANE_SIZE;
    objectsBitmap1 = new Bitmap(bitmapData, OBJECTS_WIDTH, OBJECTS_HEIGHT, OBJECTS_BITPLANES, true);
    bitmapData += OBJECTS_BITPLANES * OBJECTS_BITPLANE_SIZE;
    objectsBitmap2 = new Bitmap(bitmapData, OBJECTS_WIDTH, OBJECTS_HEIGHT, OBJECTS_BITPLANES, true);
    bitmapData += OBJECTS_BITPLANES * OBJECTS_BITPLANE_SIZE;
    roadBitmap = new Bitmap(bitmapData, ROAD_WIDTH, ROAD_HEIGHT, ROAD_BITPLANES, true);
    bitmapData += ROAD_BITPLANES * ROAD_BITPLANE_SIZE;
    horizonParallaxBitmap = new Bitmap(bitmapData, HORIZON_PARALLAX_WIDTH, HORIZON_PARALLAX_HEIGHT, HORIZON_BITPLANES, true);
    bitmapData += HORIZON_BITPLANES * HORIZON_PARALLAX_BITPLANE_SIZE;
    left = new BitmapObject(leftBobBundle, bitmapData);
    bitmapData += left->totalMasksSize();
    right = new BitmapObject(rightBobBundle, bitmapData);
    bitmapData += right->totalMasksSize();
    tree = new BitmapObject(treeBobBundle, bitmapData);
    bitmapData += tree->totalMasksSize();
    bikeGreenMiddleMiddle = new BitmapObject(bikeGreenMiddleMiddleBobBundle, bitmapData);
    bitmapData += bikeGreenMiddleMiddle->totalMasksSize();
    bikeGreenLeft1Middle = new BitmapObject(bikeGreenLeft1MiddleBobBundle, bitmapData);
    bitmapData += bikeGreenLeft1Middle->totalMasksSize();
    bikeGreenLeft2Middle = new BitmapObject(bikeGreenLeft2MiddleBobBundle, bitmapData);
    bitmapData += bikeGreenLeft2Middle->totalMasksSize();
    bikeGreenLeft3Middle = new BitmapObject(bikeGreenLeft3MiddleBobBundle, bitmapData);
    bitmapData += bikeGreenLeft3Middle->totalMasksSize();
    bikeGreenRight1Middle = new BitmapObject(bikeGreenRight1MiddleBobBundle, bitmapData);
    bitmapData += bikeGreenRight1Middle->totalMasksSize();
    bikeGreenRight2Middle = new BitmapObject(bikeGreenRight2MiddleBobBundle, bitmapData);
    bitmapData += bikeGreenRight2Middle->totalMasksSize();
    bikeGreenRight3Middle = new BitmapObject(bikeGreenRight3MiddleBobBundle, bitmapData);
    bitmapData += bikeGreenRight3Middle->totalMasksSize();
    bikeRedMiddleMiddle = new BitmapObject(bikeRedMiddleMiddleBobBundle);
    bikeRedLeft1Middle = new BitmapObject(bikeRedLeft1MiddleBobBundle);
    bikeRedLeft2Middle = new BitmapObject(bikeRedLeft2MiddleBobBundle);
    bikeRedLeft3Middle = new BitmapObject(bikeRedLeft3MiddleBobBundle);
    bikeRedRight1Middle = new BitmapObject(bikeRedRight1MiddleBobBundle);
    bikeRedRight2Middle = new BitmapObject(bikeRedRight2MiddleBobBundle);
    bikeRedRight3Middle = new BitmapObject(bikeRedRight3MiddleBobBundle);
    bikeYellowMiddleMiddle = new BitmapObject(bikeYellowMiddleMiddleBobBundle);
    bikeYellowLeft1Middle = new BitmapObject(bikeYellowLeft1MiddleBobBundle);
    bikeYellowLeft2Middle = new BitmapObject(bikeYellowLeft2MiddleBobBundle);
    bikeYellowLeft3Middle = new BitmapObject(bikeYellowLeft3MiddleBobBundle);
    bikeYellowRight1Middle = new BitmapObject(bikeYellowRight1MiddleBobBundle);
    bikeYellowRight2Middle = new BitmapObject(bikeYellowRight2MiddleBobBundle);
    bikeYellowRight3Middle = new BitmapObject(bikeYellowRight3MiddleBobBundle);
    bikeBlueMiddleMiddle = new BitmapObject(bikeBlueMiddleMiddleBobBundle);
    bikeBlueLeft1Middle = new BitmapObject(bikeBlueLeft1MiddleBobBundle);
    bikeBlueLeft2Middle = new BitmapObject(bikeBlueLeft2MiddleBobBundle);
    bikeBlueLeft3Middle = new BitmapObject(bikeBlueLeft3MiddleBobBundle);
    bikeBlueRight1Middle = new BitmapObject(bikeBlueRight1MiddleBobBundle);
    bikeBlueRight2Middle = new BitmapObject(bikeBlueRight2MiddleBobBundle);
    bikeBlueRight3Middle = new BitmapObject(bikeBlueRight3MiddleBobBundle);
    bikeRedMiddleMiddle->masks = bikeGreenMiddleMiddle->masks;
    bikeRedLeft1Middle->masks = bikeGreenLeft1Middle->masks;
    bikeRedLeft2Middle->masks = bikeGreenLeft2Middle->masks;
    bikeRedLeft3Middle->masks = bikeGreenLeft3Middle->masks;
    bikeRedRight1Middle->masks = bikeGreenRight1Middle->masks;
    bikeRedRight2Middle->masks = bikeGreenRight2Middle->masks;
    bikeRedRight3Middle->masks = bikeGreenRight3Middle->masks;
    bikeYellowMiddleMiddle->masks = bikeGreenMiddleMiddle->masks;
    bikeYellowLeft1Middle->masks = bikeGreenLeft1Middle->masks;
    bikeYellowLeft2Middle->masks = bikeGreenLeft2Middle->masks;
    bikeYellowLeft3Middle->masks = bikeGreenLeft3Middle->masks;
    bikeYellowRight1Middle->masks = bikeGreenRight1Middle->masks;
    bikeYellowRight2Middle->masks = bikeGreenRight2Middle->masks;
    bikeYellowRight3Middle->masks = bikeGreenRight3Middle->masks;
    bikeBlueMiddleMiddle->masks = bikeGreenMiddleMiddle->masks;
    bikeBlueLeft1Middle->masks = bikeGreenLeft1Middle->masks;
    bikeBlueLeft2Middle->masks = bikeGreenLeft2Middle->masks;
    bikeBlueLeft3Middle->masks = bikeGreenLeft3Middle->masks;
    bikeBlueRight1Middle->masks = bikeGreenRight1Middle->masks;
    bikeBlueRight2Middle->masks = bikeGreenRight2Middle->masks;
    bikeBlueRight3Middle->masks = bikeGreenRight3Middle->masks;
    scoreboardBitmap = new Bitmap(scoreboard, SCOREBOARD_WIDTH, SCOREBOARD_HEIGHT, SCOREBOARD_BITPLANES, true);
    horizonBackBitmap = new Bitmap(horizonBack, HORIZON_BACK_WIDTH, HORIZON_BACK_HEIGHT, HORIZON_BITPLANES, true);
    horizonFrontBitmap = new Bitmap(horizonFront, HORIZON_FRONT_WIDTH, HORIZON_FRONT_HEIGHT, HORIZON_BITPLANES, true);
    horizonFrontMask = Bitmap::generateMask(*horizonFrontBitmap, bitmapData, false);
    renderTargetObjectsBitmap = objectsBitmap2;
    renderTargetCopperList = &copperList2;
    previousBoundingRect = &previousBoundingRect2;
    copperList1.showScroller(*scrollerBitmap);
    copperList2.showScroller(*scrollerBitmap);
    copperList1.showHeader(*headerBitmap);
    copperList2.showHeader(*headerBitmap);
    copperList1.showHorizonBack(*horizonBackBitmap, horizonBackX);
    copperList2.showHorizonBack(*horizonBackBitmap, horizonBackX);
    copperList1.showObjects(*objectsBitmap1);
    copperList2.showObjects(*objectsBitmap2);
    copperList1.showHorizonParallax(*horizonParallaxBitmap);
    copperList2.showHorizonParallax(*horizonParallaxBitmap);
    copperList1.showRoad(*roadBitmap, xPosition, zPosition, roadGeometry, bottomRoadX);
    copperList2.showRoad(*roadBitmap, xPosition, zPosition, roadGeometry, bottomRoadX);
    showCurrentBikeSprite();
    AmigaHardware::setCopperList(copperList1);
    AmigaHardware::setPlayfield(SCREEN_WIDTH, SCREEN_HEIGHT, SCREEN_BITPLANES, true, false, false, true, false, 144);
    AmigaHardware::setSpritesEnabled(true);
    AmigaHardware::setPalette(17, bikeSpritePalette);
    *ddfstrtPointer = (uint16_t)(0x88 - (SCREEN_WIDTH >> 2));
    *bplcon2Pointer = 0x0024;

    scoreboardBitmap->blittable = false;
    headerBitmap->copy(*scoreboardBitmap, 0, 3);

    uint32_t* source = road;
    uint32_t* dest = (uint32_t*)roadBitmap->data;
    for (uint16_t i = 0; i < ROAD_BITPLANES * ROAD_HEIGHT; i++) {
        *dest++ = 0;
        *dest++ = 0;
        *dest++ = 0;
        *dest++ = 0;
        *dest++ = 0;
        *dest++ = 0;
        *dest++ = 0;
        *dest++ = 0;
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
        *dest++ = 0;
        *dest++ = 0;
        *dest++ = 0;
        *dest++ = 0;
        *dest++ = 0;
        *dest++ = 0;
        *dest++ = 0;
        *dest++ = 0;
    }

    writeText(topScoreText, 40, 5, 4);
    writeText(scoreText, 224, 5, 6);
    writeText(stageText, 8, 21, 1);
    writeText(speedKMText, 184, 21, 5);
    writeText(speedText, 232, 21, 1);

    generateScrollerBitmap();
}

bool GamePart::main()
{
    // Don't render before the previous frame has been shown
    if (!frameReady) {
        renderFrame();

        frameReady = true;
    }

    return false;
}

bool GamePart::vbi()
{
    bool frameDisplayed = frameReady;

    if (frameDisplayed) {
        displayFrame();

        frameReady = false;
    }

    updateScroller();

    return frameDisplayed;
}

void GamePart::generateScrollerBitmap()
{
    if (strlen(scrollText) >= (SCROLLER_WIDTH - SCREEN_FETCH_WIDTH) >> 3) {
        scrollText[(SCROLLER_WIDTH - SCREEN_FETCH_WIDTH) >> 3] = 0;
    }

    uint16_t bytesPerRow = scrollerBitmap->rowSizeInBytes;
    uint8_t* bitmapPosition = (uint8_t*)scrollerBitmap->data + (SCREEN_FETCH_WIDTH >> 3);
    char *scrollCharacter = scrollText;
    while(true) {
        char character = *scrollCharacter++;
        if (!character) {
            break;
        }
        uint16_t fontOffset = (character - ' ') << 4;
        uint8_t* source = font + fontOffset;
        uint8_t* dest = bitmapPosition++;
        for (uint16_t i = 0; i < 8; i++, source += 2, dest += bytesPerRow) {
            *dest = *source;
        }
    }
}

void GamePart::showCurrentBikeSprite()
{
    copperList1.showSprites(currentBikeSprite->sprite0, currentBikeSprite->sprite1, currentBikeSprite->sprite2, currentBikeSprite->sprite3, currentBikeSprite->sprite4, currentBikeSprite->sprite5, currentBikeSprite->sprite6, currentBikeSprite->sprite7);
    copperList2.showSprites(currentBikeSprite->sprite0, currentBikeSprite->sprite1, currentBikeSprite->sprite2, currentBikeSprite->sprite3, currentBikeSprite->sprite4, currentBikeSprite->sprite5, currentBikeSprite->sprite6, currentBikeSprite->sprite7);
}

void GamePart::setBikeSpritePosition(BikeSprite& bikeSprite)
{
    uint16_t x = bikeSpritePosition.x;
    uint16_t y = bikeSpritePosition.y;
    bikeSprite.sprite0.setX(x);
    bikeSprite.sprite1.setX(x);
    bikeSprite.sprite2.setX(x + 16);
    bikeSprite.sprite3.setX(x + 16);
    bikeSprite.sprite4.setX(x + 32);
    bikeSprite.sprite5.setX(x + 32);
    bikeSprite.sprite6.setX(x + 48);
    bikeSprite.sprite7.setX(x + 48);
    bikeSprite.sprite0.setY(y);
    bikeSprite.sprite1.setY(y);
    bikeSprite.sprite2.setY(y);
    bikeSprite.sprite3.setY(y);
    bikeSprite.sprite4.setY(y);
    bikeSprite.sprite5.setY(y);
    bikeSprite.sprite6.setY(y);
    bikeSprite.sprite7.setY(y);
}

void GamePart::spawnBikes()
{
    // Spawn a bike if there's enough distance to the previous one
    distanceToPreviousBike += zDelta;
    if (distanceToPreviousBike >= BIKE_DISTANCE) {
        distanceToPreviousBike -= BIKE_DISTANCE;

        // Find an unused object
        for (uint16_t i = 0; i < MAX_OBJECTS; i++) {
            if (objects[i].z < Z_MIN) {
                switch (bikeToSpawn) {
                case 0:
                    objects[i].bitmapObjects[0] = bikeGreenMiddleMiddle;
                    objects[i].bitmapObjects[1] = bikeGreenLeft1Middle;
                    objects[i].bitmapObjects[2] = bikeGreenLeft2Middle;
                    objects[i].bitmapObjects[3] = bikeGreenLeft3Middle;
                    objects[i].x = -160;
                    objects[i].anchorRight = false;
                    break;
                case 5:
                    objects[i].bitmapObjects[0] = bikeGreenMiddleMiddle;
                    objects[i].bitmapObjects[1] = bikeGreenRight1Middle;
                    objects[i].bitmapObjects[2] = bikeGreenRight2Middle;
                    objects[i].bitmapObjects[3] = bikeGreenRight3Middle;
                    objects[i].x = 160;
                    objects[i].anchorRight = true;
                    break;
                case 4:
                    objects[i].bitmapObjects[0] = bikeRedMiddleMiddle;
                    objects[i].bitmapObjects[1] = bikeRedLeft1Middle;
                    objects[i].bitmapObjects[2] = bikeRedLeft2Middle;
                    objects[i].bitmapObjects[3] = bikeRedLeft3Middle;
                    objects[i].x = -160;
                    objects[i].anchorRight = false;
                    break;
                case 1:
                    objects[i].bitmapObjects[0] = bikeRedMiddleMiddle;
                    objects[i].bitmapObjects[1] = bikeRedRight1Middle;
                    objects[i].bitmapObjects[2] = bikeRedRight2Middle;
                    objects[i].bitmapObjects[3] = bikeRedRight3Middle;
                    objects[i].x = 160;
                    objects[i].anchorRight = true;
                    break;
                case 2:
                    objects[i].bitmapObjects[0] = bikeYellowMiddleMiddle;
                    objects[i].bitmapObjects[1] = bikeYellowLeft1Middle;
                    objects[i].bitmapObjects[2] = bikeYellowLeft2Middle;
                    objects[i].bitmapObjects[3] = bikeYellowLeft3Middle;
                    objects[i].x = -160;
                    objects[i].anchorRight = false;
                    break;
                case 7:
                    objects[i].bitmapObjects[0] = bikeYellowMiddleMiddle;
                    objects[i].bitmapObjects[1] = bikeYellowRight1Middle;
                    objects[i].bitmapObjects[2] = bikeYellowRight2Middle;
                    objects[i].bitmapObjects[3] = bikeYellowRight3Middle;
                    objects[i].x = 160;
                    objects[i].anchorRight = true;
                    break;
                case 6:
                    objects[i].bitmapObjects[0] = bikeBlueMiddleMiddle;
                    objects[i].bitmapObjects[1] = bikeBlueLeft1Middle;
                    objects[i].bitmapObjects[2] = bikeBlueLeft2Middle;
                    objects[i].bitmapObjects[3] = bikeBlueLeft3Middle;
                    objects[i].x = -160;
                    objects[i].anchorRight = false;
                    break;
                case 3:
                    objects[i].bitmapObjects[0] = bikeBlueMiddleMiddle;
                    objects[i].bitmapObjects[1] = bikeBlueRight1Middle;
                    objects[i].bitmapObjects[2] = bikeBlueRight2Middle;
                    objects[i].bitmapObjects[3] = bikeBlueRight3Middle;
                    objects[i].x = 160;
                    objects[i].anchorRight = true;
                    break;
                default:
                    break;
                }
                objects[i].z = Z_MAX;
                objects[i].isBike = true;
                bikeToSpawn = (uint16_t)((bikeToSpawn + 1) & 7);
                break;
            }
        }
    }
}

#ifndef ASSEMBLER
void GamePart::renderFrame()
{
    // Render the parallax scrolling horizon ASAP since it's not double buffered
    horizonParallaxBitmap->copy(*horizonBackBitmap, 16, 0, horizonBackX, HORIZON_BACK_HEIGHT - HORIZON_PARALLAX_HEIGHT, HORIZON_PARALLAX_WIDTH - 16, HORIZON_PARALLAX_HEIGHT);
    horizonParallaxBitmap->copyWithMask(*horizonFrontBitmap, *horizonFrontMask, 16, 0, horizonFrontX, 0, horizonFrontX, 0, HORIZON_PARALLAX_WIDTH - 16, HORIZON_PARALLAX_HEIGHT);

    int16_t roadDelta = updateRoadGeometry();
    int16_t bottomRoadXDelta = updateCamera();

    clearRenderTargetObjectsBitmap();

    updateBikeSpriteStance(bottomRoadXDelta);

    BikeSprite* oldBikeSprite = currentBikeSprite;
    currentBikeSprite = bikeSpriteForStance(bikeSpriteStance);
    if (currentBikeSprite != oldBikeSprite) {
        showCurrentBikeSprite();
    }

    animateBikeTire();
    moveObjectsTowardsCamera();

    // Render objects and add them to the bounding rectangle
    for (uint16_t i = 0; i < MAX_OBJECTS; i++) {
        objects[i].isRendered = false;
    }
    for (i = 0; i < MAX_OBJECTS; i++) {
        GamePart::Object* object = furthestNonRenderedObject();
        if (object) {
            Point2D objectPos = projectObjectPosition(object);

            BitmapObject* bitmapObject = bitmapObjectForObject(object, objectPos.x);

            // Find the bitmap closest to the expected size (scaled from the full sized last bitmap)
            uint16_t expectedWidth = roadLineScale[objectPos.y][bitmapObject->bitmaps[bitmapObject->bitmapCount - 1]->width];
            uint16_t bitmapIndex = bitmapIndexForWidth(bitmapObject, expectedWidth);

            ROArgs roArgs = {
                bitmapObject->bitmaps[bitmapIndex], bitmapObject->masks[bitmapIndex], object
            };
            renderObject(roArgs, objectPos);
        }
    }

    renderTargetCopperList->showRoad(*roadBitmap, xPosition, zPosition, roadGeometry, bottomRoadX);
    spawnRoadSideObjects(roadDelta);

    if (zDelta < ZDELTA_MAX) {
        zDelta++;
        updateSpeedText();
        writeText(speedText, 232, 21, 1);
    } else {
        spawnBikes();
    }

    updateScore();

    while (AmigaHardware::hasQueuedBlits || AmigaHardware::isBlitterBusy());
}

void GamePart::displayFrame()
{
    renderTargetCopperList->showHorizonBack(*horizonBackBitmap, horizonBackX);
    renderTargetCopperList->showObjects(*renderTargetObjectsBitmap);
    AmigaHardware::setCopperList(*renderTargetCopperList, true);

    renderTargetObjectsBitmap = renderTargetObjectsBitmap == objectsBitmap1 ? objectsBitmap2 : objectsBitmap1;
    renderTargetCopperList = renderTargetCopperList == &copperList1 ? &copperList2 : &copperList1;
    previousBoundingRect = previousBoundingRect == &previousBoundingRect1 ? &previousBoundingRect2 : &previousBoundingRect1;
}

int16_t GamePart::updateRoadGeometry()
{
    // Render as many indices of road geometry as the camera will move forward
    uint16_t start = zPosition >> 7;
    uint16_t end = (zPosition + zDelta) >> 7;
    int16_t roadDelta = 0;
    for (uint16_t i = start; i < end; i++) {
        int16_t roadSin = Util::sin[roadAngle++ & 1023];
        roadGeometry[i & 511] = (int16_t)(roadSin >> 9);
        roadDelta = (int16_t)(Util::sin[roadAngle & 1023] - roadSin);
    }
    return roadDelta;
}

void GamePart::moveObjectsTowardsCamera()
{
    for (uint16_t i = 0; i < MAX_OBJECTS; i++) {
        if (objects[i].z >= Z_MIN) {
            objects[i].z -= objects[i].isBike ? 350 : zDelta;
        }
    }
}

void GamePart::animateBikeTire()
{
    AmigaHardware::setColor(31, bikeSpriteColors[(zPosition & 1023) < 512 ? 0 : 11]);
    AmigaHardware::setColor(28, bikeSpriteColors[(zPosition & 1023) < 512 ? 11 : 0]);
}

GamePart::Object* GamePart::furthestNonRenderedObject()
{
    // Find the furthest non-rendered object
    uint16_t furthestZ = Z_MIN - 1;
    uint16_t furthestIndex = 0;
    for (uint16_t i = 0; i < MAX_OBJECTS; i++) {
        if (!objects[i].isRendered && objects[i].z > furthestZ) {
            furthestIndex = i;
            furthestZ = objects[i].z;
        }
    }

    return furthestZ >= Z_MIN ? &objects[furthestIndex] : 0;
}

void GamePart::updateBikeSpriteStance(int16_t bottomRoadXDelta)
{
    uint16_t maxDelay = 0;

    if (bikeSpriteStance < 0) {
        if (bottomRoadXDelta < bikeSpriteStance) {
            maxDelay = BIKE_SPRITE_STANCE_DELAY_SAME_DIRECTION;
        } else if (bottomRoadXDelta > bikeSpriteStance) {
            maxDelay = BIKE_SPRITE_STANCE_DELAY_OTHER_DIRECTION;
        }
    } else if (bikeSpriteStance > 0) {
        if (bottomRoadXDelta > bikeSpriteStance) {
            maxDelay = BIKE_SPRITE_STANCE_DELAY_SAME_DIRECTION;
        } else if (bottomRoadXDelta < bikeSpriteStance) {
            maxDelay = BIKE_SPRITE_STANCE_DELAY_OTHER_DIRECTION;
        }
    } else if (bottomRoadXDelta != bikeSpriteStance) {
        maxDelay = BIKE_SPRITE_STANCE_DELAY_OTHER_DIRECTION;
    }

    if (maxDelay != 0) {
        bikeSpriteStanceDelay++;

        if (bikeSpriteStanceDelay >= maxDelay) {
            if (maxDelay == BIKE_SPRITE_STANCE_DELAY_SAME_DIRECTION) {
                bikeSpriteStance = bottomRoadXDelta;
            } else {
                if (bottomRoadXDelta > bikeSpriteStance) {
                    bikeSpriteStance++;
                } else {
                    bikeSpriteStance--;
                }
            }
            bikeSpriteStanceDelay = 0;
        }
    }
}

GamePart::BikeSprite* GamePart::bikeSpriteForStance(int32_t bikeSpriteStance)
{
    if (bikeSpriteStance < -2) {
        return &bikeSpriteRight3;
    } else if (bikeSpriteStance < -1) {
        return &bikeSpriteRight2;
    } else if (bikeSpriteStance < 0) {
        return &bikeSpriteRight1;
    } else if (bikeSpriteStance == 0) {
        return &bikeSpriteMiddle;
    } else if (bikeSpriteStance <= 1) {
        return &bikeSpriteLeft1;
    } else if (bikeSpriteStance <= 2) {
        return &bikeSpriteLeft2;
    } else {
        return &bikeSpriteLeft3;
    }
}

GamePart::BitmapObject* GamePart::bitmapObjectForObject(Object* object, int16_t objectX)
{
    if (object->isBike) {
        uint16_t deltaFromPlayer = objectX >= 0 ? objectX : -objectX;
        if (deltaFromPlayer < 30) {
            return object->bitmapObjects[0];
        } else if (deltaFromPlayer < 60) {
            return object->bitmapObjects[1];
        } else if (deltaFromPlayer < 90) {
            return object->bitmapObjects[2];
        } else {
            return object->bitmapObjects[3];
        }
    } else {
        return object->bitmapObjects[0];
    }
}

uint16_t GamePart::bitmapIndexForWidth(BitmapObject* bitmapObject, uint16_t expectedWidth)
{
    for (uint16_t bitmapIndex = 0; bitmapObject->bitmaps[bitmapIndex]->width < expectedWidth && bitmapIndex < bitmapObject->bitmapCount - 1; bitmapIndex++);
    if (bitmapIndex > 0 && (bitmapObject->bitmaps[bitmapIndex]->width - expectedWidth) > (expectedWidth - bitmapObject->bitmaps[bitmapIndex - 1]->width)) {
        bitmapIndex--;
    }
    return bitmapIndex;
}

Point2D GamePart::projectObjectPosition(Object* object)
{
    int16_t unscaledX = (int16_t)(object->x - xPosition);
    int16_t objectX = Z_MIN * unscaledX / object->z - (roadGeometry[((object->z + zPosition) >> 7) & 511] - bottomRoadX);
    int16_t objectY = Z_MIN * 224 * ROAD_HEIGHT / 218 / object->z - 3;
    return Point2D(objectX, objectY);
}

void GamePart::renderObject(const ROArgs& args, const Point2D& objectPos)
{
    Object* object = args.object;
    Bitmap* bitmap = args.bitmap;
    Bitmap* mask = args.mask;

    object->isRendered = true;

    // Calculate object screen position
    int16_t x1 = SCREEN_WIDTH / 2 + objectPos.x;
    int16_t y1 = OBJECTS_SKY_HEIGHT + objectPos.y - bitmap->height;
    if (object->anchorRight) {
        x1 -= bitmap->width;
    }
    int16_t x2 = x1 + bitmap->width;
    int16_t y2 = y1 + bitmap->height;

    // Clip the object
    if (x1 > -bitmap->width && x1 < OBJECTS_WIDTH && y1 < OBJECTS_HEIGHT) {
        uint16_t sourceX = 0;
        uint16_t sourceY = 0;
        if (x1 < 0) {
            sourceX -= x1;
            x1 = 0;
        } else if (x2 > OBJECTS_WIDTH) {
            x2 = OBJECTS_WIDTH;
        }
        if (y1 < 0) {
            sourceY -= y1;
            y1 = 0;
        } else if (y2 > OBJECTS_HEIGHT) {
            y2 = OBJECTS_HEIGHT;
        }

        if (x1 < x2 && y1 < y2) {
            // Render on screen if not completely clipped
            renderTargetObjectsBitmap->copyWithMask(*bitmap, *mask, x1, y1, sourceX, sourceY, sourceX, sourceY, x2 - x1, y2 - y1);
            Rect boundingRect(Point2D(x1, y1), Point2D(x2 - 1, y2 - 1));
            previousBoundingRect->unite(boundingRect);
        }
    }
}

void GamePart::updateSpeedText()
{
    uint16_t doubleDelta = (zDelta << 1);
    uint16_t speed = (doubleDelta + doubleDelta + doubleDelta) >> 4;
    uint16_t remaining = speed;
    int8_t value;

    if (speed >= 100) {
        value = 0;
        while (remaining >= 100) {
            value++;
            remaining -= 100;
        }
        speedText[0] = (char)('0' + value);
    } else {
        speedText[0] = ' ';
    }

    if (speed >= 10) {
        value = 0;
        while (remaining >= 10) {
            value++;
            remaining -= 10;
        }
        speedText[1] = (char)('0' + value);
    } else {
        speedText[1] = ' ';
    }

    speedText[2] = (char)('0' + remaining);
}

void GamePart::updateScoreText(char* scoreText, uint32_t score)
{
    uint32_t remaining = score;
    int8_t value;

    if (score >= 10000000) {
        value = 0;
        while (remaining >= 10000000) {
            value++;
            remaining -= 10000000;
        }
        scoreText[0] = (char)('0' + value);
    } else {
        scoreText[0] = ' ';
    }

    if (score >= 1000000) {
        value = 0;
        while (remaining >= 1000000) {
            value++;
            remaining -= 1000000;
        }
        scoreText[1] = (char)('0' + value);
    } else {
        scoreText[1] = ' ';
    }

    if (score >= 100000) {
        value = 0;
        while (remaining >= 100000) {
            value++;
            remaining -= 100000;
        }
        scoreText[2] = (char)('0' + value);
    } else {
        scoreText[2] = ' ';
    }

    if (score >= 10000) {
        value = 0;
        while (remaining >= 10000) {
            value++;
            remaining -= 10000;
        }
        scoreText[3] = (char)('0' + value);
    } else {
        scoreText[3] = ' ';
    }

    if (score >= 1000) {
        value = 0;
        while (remaining >= 1000) {
            value++;
            remaining -= 1000;
        }
        scoreText[4] = (char)('0' + value);
    } else {
        scoreText[4] = ' ';
    }

    if (score >= 100) {
        value = 0;
        while (remaining >= 100) {
            value++;
            remaining -= 100;
        }
        scoreText[5] = (char)('0' + value);
    } else {
        scoreText[5] = ' ';
    }

    if (score >= 10) {
        value = 0;
        while (remaining >= 10) {
            value++;
            remaining -= 10;
        }
        scoreText[6] = (char)('0' + value);
    } else {
        scoreText[6] = ' ';
    }
}

void GamePart::calculateRoadLineTables()
{
    for (uint16_t y = 3; y < ROAD_HEIGHT + 3; y++) {
        uint16_t yIndex = y - 3;
        roadLineZ[yIndex] = (uint16_t)(Z_MIN * 224 * ROAD_HEIGHT / 218 / y);

        for (int16_t x = -512; x < 512; x++) {
            uint16_t xIndex = ((uint16_t)x) & 1023;
            roadLineScale[yIndex][xIndex] = (int16_t)(y * x / ROAD_HEIGHT);
        }
    }
}
void GamePart::writeText(const char* text, uint16_t x, uint16_t y, uint16_t color)
{
    uint16_t bytesPerPlaneRow = headerBitmap->widthInBytes;
    uint16_t bytesPerRow = headerBitmap->rowSizeInBytes;
    uint8_t* destStart = (uint8_t*)headerBitmap->data + y * bytesPerRow + (x >> 3) + 2;

    for (const char* c = text; *c; c++) {
        uint16_t fontOffset = (*c - ' ') << 4;
        uint8_t* dest = destStart++;
        for (uint16_t i = 0; i < 8; i++) {
            uint8_t fontBitplane1 = font[fontOffset++];
            uint8_t fontBitplane2 = font[fontOffset++];
            uint8_t bitplane1 = (color & 1) ? fontBitplane1 : 0;
            uint8_t bitplane2 = (color & 2) ? (fontBitplane1 | fontBitplane2) : fontBitplane2;
            uint8_t bitplane3 = (color & 4) ? fontBitplane1 : 0;
            *dest = bitplane1;
            dest += bytesPerPlaneRow;
            *dest = bitplane2;
            dest += bytesPerPlaneRow;
            *dest = bitplane3;
            dest += bytesPerPlaneRow;
        }
    }
}

void GamePart::updateScroller()
{
    scrollerXOffset++;
    copperList1.setScrollerXOffset(scrollerXOffset);
    copperList2.setScrollerXOffset(scrollerXOffset);
}

int16_t GamePart::updateCamera()
{
    // Move the camera forward
    zPosition += zDelta;

    // Keep track of the road geometry at the bottom of the screen
    int16_t oldBottomRoadX = bottomRoadX;
    uint16_t bottomZ = roadLineZ[ROAD_HEIGHT - 1] + zPosition;
    bottomRoadX = roadGeometry[bottomZ >> 7];

    // Move the player based on the delta of the road geometry at the bottom of the screen during camera movement
    int16_t bottomRoadXDelta = bottomRoadX - oldBottomRoadX;
    xPosition += bottomRoadXDelta;
    horizonBackX -= bottomRoadXDelta;
    horizonFrontX -= bottomRoadXDelta << 1;

    return bottomRoadXDelta;
}

void GamePart::clearRenderTargetObjectsBitmap()
{
    if (!previousBoundingRect->isEmpty) {
        // Copy the background over the previously modified area of the bitmap
        uint16_t rectX = previousBoundingRect->topLeft.x & 0xfff0;
        uint16_t rectY = previousBoundingRect->topLeft.y;
        uint16_t rectWidth = ((previousBoundingRect->bottomRight.x + 16) & 0xfff0) - rectX;
        uint16_t rectHeight = previousBoundingRect->height;
        renderTargetObjectsBitmap->clear(rectX, rectY, rectWidth, rectHeight);

        // Clear the bounding rectangle
        *previousBoundingRect = Rect();
    }
}

void GamePart::updateScore()
{
    score += zDelta;
    updateScoreText(scoreText, score);
    writeText(scoreText, 224, 5, 6);

    if (score > topScore) {
        topScore = score;
        updateScoreText(topScoreText, topScore);
        writeText(topScoreText, 40, 5, 4);
    }
}

void GamePart::spawnRoadSideObjects(int16_t roadDelta)
{
    // Spawn a roadside object if there's enough distance to the previous one
    distanceToPreviousRoadsideObject += zDelta;
    if (distanceToPreviousRoadsideObject >= ROADSIDE_OBJECT_DISTANCE) {
        distanceToPreviousRoadsideObject -= ROADSIDE_OBJECT_DISTANCE;

        // Find an unused object
        for (uint16_t i = 0; i < MAX_OBJECTS; i++) {
            if (objects[i].z < Z_MIN) {
                if (roadDelta > -100 && roadDelta < 100) {
                    objects[i].bitmapObjects[0] = tree;
                } else {
                    objects[i].bitmapObjects[0] = roadDelta > 0 ? left : right;
                }
                objects[i].x = (int16_t)(roadDelta > 0 ? 224 : -224);
                objects[i].z = Z_MAX;
                objects[i].anchorRight = (bool)(roadDelta > 0 ? false : true);
                objects[i].isBike = false;
                break;
            }
        }
    }
}
#endif
