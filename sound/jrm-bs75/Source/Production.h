#ifndef _PRODUCTION_H
#define _PRODUCTION_H

#include "Util.h"

class Script;

class Production {
public:
    virtual uint8_t* songData() const = 0;
    virtual uint8_t* sampleData() const = 0;
    virtual Script* script() const = 0;
    virtual bool isRunnable() const { return false; };
};

#endif
