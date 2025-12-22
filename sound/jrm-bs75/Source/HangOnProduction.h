#ifndef _HANGONPRODUCTION_H
#define _HANGONPRODUCTION_H

#include "Production.h"
#include "Script.h"
#include "GamePart.h"

class HangOnProduction : public Production {
public:
    HangOnProduction();
    virtual ~HangOnProduction();

    virtual uint8_t* songData() const;
    virtual uint8_t* sampleData() const;
    virtual Script* script() const;
    virtual bool isRunnable() const;

private:
    struct ScriptPart parts[2];
    Script script_;
    GamePart gamePart;
    Part quit;
    void* chipMemory;
};

#endif
