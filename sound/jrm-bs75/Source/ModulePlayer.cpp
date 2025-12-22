#include "ModulePlayer.h"
#include "TrackerPackerReplayV3.1.h"

ModulePlayer::ModulePlayer(uint8_t* songData, uint8_t* sampleData)
{
    tp_data = songData;
    tp_samples = sampleData;
    tp_line = 0;
}

void ModulePlayer::setVBR(uint32_t vbr)
{
    tp_vbr = vbr;
}

void ModulePlayer::start()
{
    tp_init();
}

void ModulePlayer::stop()
{
    tp_end();
}

uint16_t ModulePlayer::position() const
{
    return tp_line;
}

bool ModulePlayer::isSampleTriggered(uint8_t sample, bool clear)
{
    bool triggered = tp_triggered[sample];
    if (clear) {
        tp_triggered[sample] = false;
    }
    return triggered;
}
