#ifndef _HC74PRODUCTION_H
#define _HC74PRODUCTION_H

#include "Production.h"
#include "Script.h"
#include "MainPart.h"

class hC74Production : public Production {
public:
    hC74Production();
    virtual ~hC74Production();

    virtual uint8_t* songData() const;
    virtual uint8_t* sampleData() const;
    virtual Script* script() const;
    virtual bool isRunnable() const;

private:
    enum Sample {
        SampleBassDrum = 2
    };

    struct ScriptPart parts[2];
    Script script_;
    MainPart mainPart;
    Part quit;
    void* chipMemory;
};

#endif
