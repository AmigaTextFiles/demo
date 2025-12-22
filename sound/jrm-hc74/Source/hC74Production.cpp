#include <proto/exec.h>
#include <exec/execbase.h>
#include <exec/memory.h>
#include "hC74Production.h"

extern uint8_t __far module[];
extern uint8_t __chip sample[];

static const char version[] = "$VER:JRm-hC74 1.2 (2021-04-10) (C)2019-2021 dA JoRMaS";

#define MAX_REQUIRED_CHIPMEM (2 * 42 * 256 * 4 + 42 * 256 * 4 + 42 * 256 * 4 + 64 * 512 * 4 + 42 * 4 + 4)

hC74Production::hC74Production() :
    script_(parts, 2)
{
    parts[0].position = 0;
    parts[0].part = &mainPart;
    parts[1].position = 4671;
    parts[1].part = &quit;
    chipMemory = AllocMem(MAX_REQUIRED_CHIPMEM, MEMF_CHIP | MEMF_CLEAR);
    script_.setChipMemory((void*)(((uint32_t)chipMemory + 4) & 0xfffffff8));
}

hC74Production::~hC74Production()
{
    if (chipMemory) {
        FreeMem(chipMemory, MAX_REQUIRED_CHIPMEM);
    }
}

uint8_t* hC74Production::songData() const
{
    return module;
}

uint8_t* hC74Production::sampleData() const
{
    return sample;
}

Script* hC74Production::script() const
{
    return (Script*)&script_;
}

bool hC74Production::isRunnable() const
{
    return chipMemory != 0;
}
