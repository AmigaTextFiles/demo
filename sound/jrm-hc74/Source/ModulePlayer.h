#ifndef _MODULEPLAYER_H
#define _MODULEPLAYER_H

#include "Util.h"

class ModulePlayer {
public:
    ModulePlayer(uint8_t* songData, uint8_t* sampleData);

    void setVBR(uint32_t vbr);
    void start();
    void stop();
    __inline uint16_t position() const;
    bool isSampleTriggered(uint8_t sample, bool clear = true);
};

#endif
