#ifdef DEBUG
#include <stdio.h>
#endif
#include <proto/exec.h>
#include <proto/graphics.h>
#include <exec/execbase.h>
#include <graphics/gfxbase.h>
#include <hardware/dmabits.h>
#include <hardware/intbits.h>
#include "ProductionRunner.h"
#include "Production.h"
#include "Palette.h"
#include "AmigaHardware.h"

extern struct ExecBase* SysBase;

__chip uint32_t ProductionRunner::emptyCopperList = 0xfffffffe;

ProductionRunner::ProductionRunner(const Production& production) :
    modulePlayer(production.songData(), production.sampleData()),
    copperList(&emptyCopperList, 1, false),
    script(production.script()),
    part(0),
    vbiCount(0),
    frameCount(0),
    vbr(0),
    level3AutoVectorPointer((AutoVector*)0x6c),
    level6AutoVectorPointer((AutoVector*)0x78),
    gfxBase(0),
    oldActiView(0),
    oldLevel3AutoVector(0),
    oldLevel6AutoVector(0),
    oldEnabledDMAChannels(0),
    oldEnabledInterrupts(0),
    oldCIABControlRegisterA(0),
    oldCIABControlRegisterB(0),
    quit(true)
{
    if (!production.isRunnable()) {
        return;
    }

    Palette::initialize();

    script->setModulePlayer(&modulePlayer);

    // Open libraries
    gfxBase = (struct GfxBase*)OpenLibrary((uint8_t*)"graphics.library", 39);
    if (gfxBase) {
        AmigaHardware::hasAGAChipSet = (bool)((gfxBase->ChipRevBits0 & GFXF_AA_LISA) ? true : false);
    } else {
        gfxBase = (struct GfxBase*)OpenLibrary((uint8_t*)"graphics.library", 0);
    }
    if (!gfxBase) {
        return;
    }

    // Disable multitasking
    Forbid();

    // Disable DMA and interrupts for now
    oldEnabledDMAChannels = AmigaHardware::enabledDMAChannels();
    oldEnabledInterrupts = AmigaHardware::enabledInterrupts();
    AmigaHardware::setDMAChannels(DMAF_ALL, false);
    AmigaHardware::setInterrupts(INTF_ALL, false);
    AmigaHardware::clearInterruptRequests(INTF_ALL);
    AmigaHardware::setBlitterNasty(false);

    // Get Vector Base Register
    if (SysBase->AttnFlags) {
        vbr = (uint32_t)AmigaHardware::getVBR();
        level3AutoVectorPointer = (AutoVector*)(vbr + 0x6c);
        level6AutoVectorPointer = (AutoVector*)(vbr + 0x78);
        modulePlayer.setVBR(vbr);
    }

    // Store old values
    oldActiView = gfxBase->ActiView;
    oldCopperList = CopperList((uint32_t*)gfxBase->copinit);
    oldLevel3AutoVector = *level3AutoVectorPointer;
    oldLevel6AutoVector = *level6AutoVectorPointer;
    oldCIABControlRegisterA = *ciabcraPointer;
    oldCIABControlRegisterB = *ciabcrbPointer;
    LoadView(0);
    WaitTOF();
    WaitTOF();

    // Clear sprites
    uint32_t* spriteData = (uint32_t*)spr1dataPointer;
    for (uint16_t i = 0; i < 8; i++) {
        *spriteData++ = 0;
    }

    // Set up interrupts and copperlist
    installLevel3Interrupt(level3AutoVectorPointer);
    AmigaHardware::setCopperList(copperList);

    // Initialize first part
    part = script->part(modulePlayer.position());

    // Start the module player
    modulePlayer.start();

    // Enable interrupts and DMA
    AmigaHardware::setDMAChannels(DMAF_COPPER | DMAF_RASTER | DMAF_BLITTER, true);
    AmigaHardware::setInterrupts(INTF_INTEN | INTF_BLIT | INTF_VERTB, true);
    AmigaHardware::clearInterruptRequests(INTF_BLIT | INTF_VERTB);

    quit = false;
}

ProductionRunner::~ProductionRunner()
{
    if (gfxBase) {
        // Disable interrupts and DMA
        AmigaHardware::setInterrupts(INTF_ALL, false);
        AmigaHardware::clearInterruptRequests(INTF_BLIT | INTF_VERTB);
        AmigaHardware::setDMAChannels(DMAF_COPPER, false);

        // Stop the module player
        modulePlayer.stop();

        // Restore old values
        *ciabcraPointer = oldCIABControlRegisterA;
        *ciabcrbPointer = oldCIABControlRegisterB;
        AmigaHardware::setCopperList(oldCopperList, true);
        AmigaHardware::setDMAChannels(DMAF_COPPER, true);
        *level3AutoVectorPointer = oldLevel3AutoVector;
        *level6AutoVectorPointer = oldLevel6AutoVector;
        AmigaHardware::setDMAChannels(oldEnabledDMAChannels, true);
        AmigaHardware::setInterrupts(oldEnabledInterrupts | INTF_INTEN, true);
        LoadView(oldActiView);
        WaitTOF();
        WaitTOF();

        // Enable multitasking
        Permit();

        CloseLibrary((struct Library*)gfxBase);
    }

#ifdef DEBUG
    if (vbiCount > 0) {
        printf("Average frame rate %d\n", 50 * frameCount / vbiCount);
    }
#endif
}

void ProductionRunner::run()
{
    while (!quit) {
        part = script->part(modulePlayer.position());
        quit |= part->main();
    }
    while (AmigaHardware::hasQueuedBlits || AmigaHardware::isBlitterBusy());
}

void ProductionRunner::verticalBlankInterrupt()
{
    if (AmigaHardware::isLeftMouseButtonPressed()) {
        quit = true;
    }

    if (!quit && part) {
        vbiCount++;

        if (part->vbi()) {
            frameCount++;
        }
    }
}

void ProductionRunner::blitterInterrupt()
{
    AmigaHardware::processBlitterQueue();
}
