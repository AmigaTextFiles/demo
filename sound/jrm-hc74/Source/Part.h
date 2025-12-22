#ifndef _PART_H
#define _PART_H

#include "Util.h"

class ModulePlayer;

class Part {
public:
    Part();
    virtual ~Part();

    void setChipMemory(void* chipMemory);
    void setModulePlayer(ModulePlayer* modulePlayer);
    virtual void initialize();

    // Returns true if the production should exit, false otherwise
    virtual bool main();

    // Returns true if a frame was displayed on screen, false otherwise
    virtual bool vbi();

protected:
    void* chipMemory;
    ModulePlayer* modulePlayer;
};

#endif
