#ifndef _MAINPART_H
#define _MAINPART_H

#include "Part.h"
#include "Palette.h"

class CopperList;
class Sprite;
class Bitmap;

struct RotatedCoordinate;
struct Model;
struct FaceData;
struct SubPart;

class MainPart : public Part {
public:
    MainPart();
    virtual ~MainPart();

    virtual void initialize();
    virtual bool main();
    virtual bool vbi();

private:
    static __stdargs int sortFaces(const void* face1, const void* face2);
    static void enableHAM(MainPart* part);
    static void disableHAM(MainPart* part);
    static void clearBackground(MainPart* part);
    static void copyBackground(MainPart* part);
    static void copySphere(MainPart* part);
    static void copyCanalBackground(MainPart* part);
    static void copyCanalSphere(MainPart* part);
    static void enableMirror(MainPart* part);
    static void disableMirror(MainPart* part);
    static void enableGlenz(MainPart* part);
    static void disableGlenz(MainPart* part);
    static void enableTranslucent(MainPart* part);
    static void disableTranslucent(MainPart* part);
    static void setCubeModel(MainPart* part);
    static void setDiamondModel(MainPart* part);
    static void setTetrahexahedronModel(MainPart* part);
    static void setClearPage(MainPart* part);
    static void resetRGBDistance(MainPart* part);
    static const char* pages[];
    static const SubPart subParts[];

    void setModel(Model* model);
    void drawPolygon(const Polygon& polygon, Bitmap* bitmap, uint16_t color = 1, bool fillMode = false);
#ifdef ASSEMBLER
    __asm void rotateFaces();
#else
    void rotateFaces();
#endif

    void setSpritePositions();
    void nextPage();
    void nextLine();
    void nextCharacter();

    // Positioned in the beginning of the class (offset 0) to avoid modifications to the assembler part
    Model* model;
    FaceData* faces;
    RotatedCoordinate* rotatedCoordinates;
    uint16_t angleX;
    uint16_t angleY;
    uint16_t angleZ;
    uint16_t distance;
    uint16_t centerX;
    uint16_t centerY;
    uint16_t rgbDistance;
    uint16_t rgbAngle;
    int16_t angleXDelta;
    int16_t angleYDelta;
    int16_t angleZDelta;

    int8_t* distanceMultiplyTable;
    const SubPart* subPart;
    CopperList* copperList;
    Sprite* sprites[8];
    Sprite* emptySprite;
    Bitmap* displayBitmap1;
    Bitmap* displayBitmap2;
    Bitmap* currentDisplayBitmap;
    Bitmap* firstPlanesBitmap1;
    Bitmap* firstPlanesBitmap2;
    Bitmap* currentFirstPlanesBitmap;
    Bitmap* maskBitmap;
    Bitmap* maskBitmapR;
    Bitmap* maskBitmapG;
    Bitmap* maskBitmapB;
    Bitmap* backgroundBitmap;
    Bitmap* textureBitmap;
    Bitmap* hamBitmap;
    Palette basePalette;
    Palette spritePalette;
    Rect previousBoundingRect1;
    Rect previousBoundingRect2;
    Rect* previousBoundingRect;
    bool ham;
    bool mirror;
    bool glenz;
    bool translucent;
    bool moveModel;
    bool padding;
    bool frameReady;
    bool mathsReady;

    int16_t pageIndex;
    const char* input;
    uint32_t outputLine;
    uint32_t outputCharacter;
    uint16_t clearLine;
    int16_t spriteDelta;
    bool clearPage;
};

#endif
