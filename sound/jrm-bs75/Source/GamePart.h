#ifndef _GAMEPART_H
#define _GAMEPART_H

#include "Part.h"
#include "GameCopperlist.h"
#include "Sprite.h"
#include "Palette.h"

#define SCREEN_WIDTH 320
#define SCREEN_HEIGHT 224
#define SCREEN_BITPLANES 6
#define SCREEN_FETCH_WIDTH (SCREEN_WIDTH + 16)
#define SCROLLER_WIDTH 8192
#define SCROLLER_HEIGHT 8
#define SCROLLER_BITPLANE_SIZE (SCROLLER_WIDTH / 8 * SCROLLER_HEIGHT)
#define SCROLLER_BITPLANES 1
#define HEADER_WIDTH SCREEN_FETCH_WIDTH
#define HEADER_HEIGHT 29
#define HEADER_BITPLANE_SIZE (HEADER_WIDTH / 8 * HEADER_HEIGHT)
#define HEADER_BITPLANES 3
#define ROAD_WIDTH 1024
#define ROAD_HEIGHT 96
#define ROAD_BITPLANE_SIZE (ROAD_WIDTH / 8 * ROAD_HEIGHT)
#define ROAD_BITPLANES 3
#define SKY_HEIGHT (SCREEN_HEIGHT - ROAD_HEIGHT)
#define SCOREBOARD_WIDTH SCREEN_WIDTH
#define SCOREBOARD_HEIGHT 12
#define SCOREBOARD_BITPLANES 3
#define OBJECTS_WIDTH SCREEN_WIDTH
#define OBJECTS_HEIGHT (SCREEN_HEIGHT - HEADER_HEIGHT)
#define OBJECTS_BITPLANE_SIZE (OBJECTS_WIDTH / 8 * OBJECTS_HEIGHT)
#define OBJECTS_BITPLANES 3
#define OBJECTS_SKY_HEIGHT (OBJECTS_HEIGHT - ROAD_HEIGHT)
#define HORIZON_BACK_WIDTH 2048
#define HORIZON_BACK_HEIGHT 64
#define HORIZON_BACK_Y (OBJECTS_SKY_HEIGHT - HORIZON_BACK_HEIGHT)
#define HORIZON_FRONT_WIDTH 2048
#define HORIZON_FRONT_HEIGHT 16
#define HORIZON_FRONT_BITPLANE_SIZE (HORIZON_FRONT_WIDTH / 8 * HORIZON_FRONT_HEIGHT)
#define HORIZON_PARALLAX_WIDTH (SCREEN_WIDTH + 16)
#define HORIZON_PARALLAX_HEIGHT HORIZON_FRONT_HEIGHT
#define HORIZON_PARALLAX_BITPLANE_SIZE (HORIZON_PARALLAX_WIDTH / 8 * HORIZON_PARALLAX_HEIGHT)
#define HORIZON_BITPLANES 3
#define GAME_CHIP_MEMORY (SCROLLER_BITPLANES * SCROLLER_BITPLANE_SIZE + HEADER_BITPLANES * HEADER_BITPLANE_SIZE + 2 * OBJECTS_BITPLANES * OBJECTS_BITPLANE_SIZE + ROAD_BITPLANES * ROAD_BITPLANE_SIZE + HORIZON_BITPLANES * HORIZON_PARALLAX_BITPLANE_SIZE + 19194 + 19194 + 13542 + 4416 + 4416 + 4146 + 5184 + 4416 + 4146 + 5184 + HORIZON_BITPLANES * HORIZON_FRONT_BITPLANE_SIZE)
#define MAX_OBJECTS 6

class Bitmap;

class GamePart : public Part {
public:
    GamePart();
    virtual ~GamePart();

    virtual void initialize();
    virtual bool main();
    virtual bool vbi();

private:
    struct BitmapObject {
        BitmapObject(uint8_t* bobBundle, uint8_t* maskData = 0);
        BitmapObject(uint16_t bitmapCount, Bitmap** bitmaps, Bitmap** masks);
        ~BitmapObject();
        __inline uint32_t totalMasksSize() const;

        Bitmap** bitmaps;
        Bitmap** masks;
        uint16_t bitmapCount;
        bool maskOwner;
    };

    struct Object {
        Object();
        BitmapObject* bitmapObjects[4];
        int16_t x;
        uint16_t z;
        bool anchorRight;
        bool isBike;
        bool isRendered;
    };

    struct BikeSprite {
        BikeSprite(uint16_t* data01, uint16_t* data23, uint16_t* data45, uint16_t* data67);
        Sprite sprite0;
        Sprite sprite1;
        Sprite sprite2;
        Sprite sprite3;
        Sprite sprite4;
        Sprite sprite5;
        Sprite sprite6;
        Sprite sprite7;
    };

    struct ROArgs {
        Bitmap* bitmap;
        Bitmap* mask;
        Object* object;
    };

    void generateScrollerBitmap();
    void setBikeSpritePosition(BikeSprite& bikeSprite);
    void showCurrentBikeSprite();
    void spawnBikes();

#ifdef ASSEMBLER
    __asm void renderFrame();
    __asm void displayFrame();
    __asm void calculateRoadLineTables();
    __asm int16_t updateRoadGeometry();
    __asm void moveObjectsTowardsCamera();
    __asm void animateBikeTire();
    __asm Object* furthestNonRenderedObject();
    __asm void updateBikeSpriteStance(register __d0 int16_t bottomRoadXDelta);
    __asm BikeSprite* bikeSpriteForStance(register __d0 int32_t bikeSpriteStance);
    __asm static BitmapObject* bitmapObjectForObject(register __a1 Object* object, register __d0 int16_t objectX);
    __asm static uint16_t bitmapIndexForWidth(register __a1 BitmapObject* bitmapObject, register __d0 uint16_t expectedWidth);
    __asm Point2D projectObjectPosition(register __a1 Object* object);
    __asm void renderObject(register __a3 const ROArgs& roArgs, register __a4 const Point2D& objectPos);
    __asm void updateSpeedText();
    __asm void updateScoreText(register __a1 char* scoreText, register __d0 uint32_t score);
    __asm void writeText(register __a1 const char* text, register __d0 uint16_t x, register __d1 uint16_t y, register __d2 uint16_t color);
    __asm void updateScroller();
    __asm int16_t updateCamera();
    __asm void clearRenderTargetObjectsBitmap();
    __asm void updateScore();
    __asm void spawnRoadSideObjects(register __d0 int16_t roadDelta);
#else
    void renderFrame();
    void displayFrame();
    void calculateRoadLineTables();
    int16_t updateRoadGeometry();
    void moveObjectsTowardsCamera();
    void animateBikeTire();
    Object* furthestNonRenderedObject();
    void updateBikeSpriteStance(int16_t bottomRoadXDelta);
    BikeSprite* bikeSpriteForStance(int32_t bikeSpriteStance);
    static BitmapObject* bitmapObjectForObject(Object* object, int16_t objectX);
    static uint16_t bitmapIndexForWidth(BitmapObject* bitmapObject, uint16_t expectedWidth);
    Point2D projectObjectPosition(Object* object);
    void renderObject(const ROArgs& roArgs, const Point2D& objectPos);
    void updateSpeedText();
    void updateScoreText(char* scoreText, uint32_t score);
    void writeText(const char* text, uint16_t x, uint16_t y, uint16_t color);
    void updateScroller();
    int16_t updateCamera();
    void clearRenderTargetObjectsBitmap();
    void updateScore();
    void spawnRoadSideObjects(int16_t roadDelta);
#endif

    uint16_t* roadLineZ;
    int16_t** roadLineScale;
    int16_t* roadGeometry;
    uint16_t roadAngle;
    int16_t xPosition;
    uint16_t zPosition;
    uint16_t zDelta;
    uint16_t horizonBackX;
    uint16_t horizonFrontX;
    int16_t bottomRoadX;
    int16_t bikeSpriteStance;
    uint16_t bikeSpriteStanceDelay;
    uint32_t score;
    uint32_t topScore;
    uint16_t scrollerXOffset;
    Bitmap* scoreboardBitmap;
    Bitmap* horizonBackBitmap;
    Bitmap* horizonFrontBitmap;
    Bitmap* horizonFrontMask;
    Bitmap* renderTargetObjectsBitmap;
    GameCopperList* renderTargetCopperList;
    Rect* previousBoundingRect;
    uint16_t distanceToPreviousRoadsideObject;
    uint16_t distanceToPreviousBike;
    uint16_t bikeToSpawn;
    bool frameReady;
    bool padding;
    Object objects[MAX_OBJECTS];
    BikeSprite bikeSpriteRight3;
    BikeSprite bikeSpriteRight2;
    BikeSprite bikeSpriteRight1;
    BikeSprite bikeSpriteMiddle;
    BikeSprite bikeSpriteLeft1;
    BikeSprite bikeSpriteLeft2;
    BikeSprite bikeSpriteLeft3;
    BikeSprite* currentBikeSprite;
    Bitmap* scrollerBitmap;
    Bitmap* headerBitmap;
    Bitmap* objectsBitmap1;
    Bitmap* objectsBitmap2;
    Bitmap* roadBitmap;
    Bitmap* horizonParallaxBitmap;
    BitmapObject* left;
    BitmapObject* right;
    BitmapObject* tree;
    BitmapObject* bikeGreenMiddleMiddle;
    BitmapObject* bikeGreenLeft1Middle;
    BitmapObject* bikeGreenLeft2Middle;
    BitmapObject* bikeGreenLeft3Middle;
    BitmapObject* bikeGreenRight1Middle;
    BitmapObject* bikeGreenRight2Middle;
    BitmapObject* bikeGreenRight3Middle;
    BitmapObject* bikeRedMiddleMiddle;
    BitmapObject* bikeRedLeft1Middle;
    BitmapObject* bikeRedLeft2Middle;
    BitmapObject* bikeRedLeft3Middle;
    BitmapObject* bikeRedRight1Middle;
    BitmapObject* bikeRedRight2Middle;
    BitmapObject* bikeRedRight3Middle;
    BitmapObject* bikeYellowMiddleMiddle;
    BitmapObject* bikeYellowLeft1Middle;
    BitmapObject* bikeYellowLeft2Middle;
    BitmapObject* bikeYellowLeft3Middle;
    BitmapObject* bikeYellowRight1Middle;
    BitmapObject* bikeYellowRight2Middle;
    BitmapObject* bikeYellowRight3Middle;
    BitmapObject* bikeBlueMiddleMiddle;
    BitmapObject* bikeBlueLeft1Middle;
    BitmapObject* bikeBlueLeft2Middle;
    BitmapObject* bikeBlueLeft3Middle;
    BitmapObject* bikeBlueRight1Middle;
    BitmapObject* bikeBlueRight2Middle;
    BitmapObject* bikeBlueRight3Middle;
    Rect previousBoundingRect1;
    Rect previousBoundingRect2;
    GameCopperList copperList1;
    GameCopperList copperList2;
    Point2D bikeSpritePosition;
    Palette bikeSpritePalette;
    int16_t* roadLineScaleValues;
};

#endif
