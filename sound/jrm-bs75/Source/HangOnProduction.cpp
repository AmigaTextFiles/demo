#include <proto/exec.h>
#include <exec/execbase.h>
#include <exec/memory.h>
#include "HangOnProduction.h"

__far extern uint8_t module[];
__chip extern uint8_t sample[];

static const char version[] = "$VER:JRm-bS75 1.1 (2020-03-05) (C)2020 dA JoRMaS";

HangOnProduction::HangOnProduction() :
    script_(parts, 2)
{
    parts[0].position = 0;
    parts[0].part = &gamePart;
    parts[1].position = 22 * 64 + 1;
    parts[1].part = &quit;
    chipMemory = AllocMem(GAME_CHIP_MEMORY, MEMF_CHIP | MEMF_CLEAR);
    script_.setChipMemory(chipMemory);
}

HangOnProduction::~HangOnProduction()
{
    if (chipMemory) {
        FreeMem(chipMemory, GAME_CHIP_MEMORY);
    }
}

uint8_t* HangOnProduction::songData() const
{
    return module;
}

uint8_t* HangOnProduction::sampleData() const
{
    return sample;
}

Script* HangOnProduction::script() const
{
    return (Script*)&script_;
}

bool HangOnProduction::isRunnable() const
{
    return chipMemory != 0;
}
