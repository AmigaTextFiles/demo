#include "Part.h"

Part::Part() :
    chipMemory(0),
    modulePlayer(0)
{
}

Part::~Part()
{
}

void Part::setChipMemory(void* chipMemory)
{
    this->chipMemory = chipMemory;
}

void Part::setModulePlayer(ModulePlayer* modulePlayer)
{
    this->modulePlayer = modulePlayer;
}

void Part::initialize()
{
}

bool Part::main()
{
    return true;
}

bool Part::vbi()
{
    return true;
}
