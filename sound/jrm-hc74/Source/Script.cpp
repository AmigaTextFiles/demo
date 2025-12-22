#include "Script.h"

Script::Script(const ScriptPart* parts, uint16_t length) :
    parts(parts),
    length(length),
    partIndex(-1)
{
}

Part* Script::part(uint16_t position)
{
    while (position >= parts[partIndex + 1].position && partIndex < (length - 1)) {
        parts[++partIndex].part->initialize();
    }
    return parts[partIndex].part;
}

void Script::setChipMemory(void* chipMemory)
{
    for (uint16_t i = 0; i < length; i++) {
        parts[i].part->setChipMemory(chipMemory);
    }
}

void Script::setModulePlayer(ModulePlayer* modulePlayer)
{
    for (uint16_t i = 0; i < length; i++) {
        parts[i].part->setModulePlayer(modulePlayer);
    }
}
