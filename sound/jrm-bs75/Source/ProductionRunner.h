#ifndef _PRODUCTIONRUNNER_H
#define _PRODUCTIONRUNNER_H

#include "Util.h"
#include "ModulePlayer.h"
#include "CopperList.h"
#include "Script.h"

typedef __asm void (*AutoVector)(void);

class Part;
class Production;

class ProductionRunner {
public:
    ProductionRunner(const Production& production);
    ~ProductionRunner();
    
    void run();
    __saveds void verticalBlankInterrupt();
    __saveds void blitterInterrupt();

private:
    __asm void installLevel3Interrupt(register __a1 AutoVector* autoVector);
    __chip static uint32_t emptyCopperList;
    ModulePlayer modulePlayer;
    CopperList copperList;
    Script* script;
    Part* part;
    uint16_t vbiCount;
    uint16_t frameCount;
    uint32_t vbr;
    AutoVector* level3AutoVectorPointer;
    AutoVector* level6AutoVectorPointer;
    struct GfxBase* gfxBase;
    struct View* oldActiView;
    CopperList oldCopperList;
    AutoVector oldLevel3AutoVector;
    AutoVector oldLevel6AutoVector;
    uint16_t oldEnabledDMAChannels;
    uint16_t oldEnabledInterrupts;
    uint8_t oldCIABControlRegisterA;
    uint8_t oldCIABControlRegisterB;
    bool quit;
};

#endif
