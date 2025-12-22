#ifndef _SCRIPT_H
#define _SCRIPT_H

#include "Util.h"
#include "Part.h"

class ModulePlayer;

struct ScriptPart {
    int16_t position;
    Part* part;
};

class Script {
public:
    Script(const ScriptPart* parts, uint16_t length);
    Part* part(uint16_t position);
    void setChipMemory(void* chipMemory);
    void setModulePlayer(ModulePlayer* modulePlayer);

private:
    const ScriptPart* parts;
    uint16_t length;
    int16_t partIndex;
};

#endif
