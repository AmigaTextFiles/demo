;******************************************************************************
;* 
;* File:     VampireDemo2D.asm
;* Author:   Flype, Apollo-Team 2016-2017
;* Version:  0.6 (2017-08-13)
;* Compiler: vasmm68k_mot_os3
;* 
;******************************************************************************
;* 
;* ESCAPE:   Exit program
;* HELP:     Show/Hide Help
;* F1:       Decrease number of sprites
;* F2:       Increase number of sprites
;* F3:       Reset fighters positions
;* F4:       Show/Hide Logo
;* F5:       Show/Hide Crown
;* F6:       Show/Hide Background
;* F7:       Use AMMX in DrawSprite()
;* MOUSE:    Move the sorceress
;* CURSORS:  Move the crown
;* 
;******************************************************************************
;* 
;* TODO:
;* 
;* . Detect AC68080/AMMX2.
;* . RLE DrawSprite routine.
;* . Be sure All sprites width are dividable by 4.
;* 
;******************************************************************************


USE_AC68080  EQU 1
USE_PUSHPOP  EQU 0


    IFNE USE_AC68080
        MACHINE AC68080
    ELSE
        MACHINE MC68020
    ENDC


;******************************************************************************
;*
;* MACROS
;*
;******************************************************************************


PUSHALL MACRO
    IFNE USE_PUSHPOP  
    movem.l  d2-d7/a2-a6,-(SP)
    ENDC
    ENDM

POPALL MACRO
    IFNE USE_PUSHPOP  
    movem.l  (SP)+,d2-d7/a2-a6
    ENDC
    ENDM

CALLCGX MACRO
    move.l  _CgxBase,a6
    jsr     _LVO\1(a6)
    ENDM

CALLTIMER MACRO
    move.l  _TimerBase,a6
    jsr     _LVO\1(a6)
    ENDM


;******************************************************************************
;*
;* INCLUDES
;*
;******************************************************************************


    INCLUDE devices/timer.i
    INCLUDE devices/timer_lib.i
    INCLUDE dos/dos.i
    INCLUDE dos/dos_lib.i
    INCLUDE exec/types.i
    INCLUDE exec/memory.i
    INCLUDE exec/execbase.i
    INCLUDE exec/exec_lib.i
    INCLUDE hardware/intbits.i
    INCLUDE intuition/screens.i
    INCLUDE intuition/intuitionbase.i
    INCLUDE intuition/intuition_lib.i
    INCLUDE cybergraphics/cybergraphics.i
    INCLUDE cybergraphics/cybergraphics_lib.i


;******************************************************************************
;*
;* PRIVATES
;*
;******************************************************************************


BMPHDR          EQU 138                     ; BMP Header Size
MEM_ALIGN       EQU 32                      ; FrameBuffer Alignment
SAGA_FBADDR     EQU $dff1ec                 ; FrameBuffer Address
SAGA_CLKCNT     EQU $de0008                 ; Clock Cycle Counter

BYTESPERPIX     EQU 2                       ; Bytes Per Pixel
SCREENWIDTH     EQU 960                     ; Screen Width
SCREENHEIGHT    EQU 540                     ; Screen Height
SCREENDEPTH     EQU (BYTESPERPIX*8)         ; 
SCREENSIZE      EQU (SCREENWIDTH*SCREENHEIGHT*BYTESPERPIX)

INTRO_DELAY     EQU 50*10                   ; Intro screen duration (ticks)
OUTRO_DELAY     EQU 50*5                    ; Outro screen duration (ticks)

FONTWIDTH       EQU 32                      ; Font Size
FONTHEIGHT      EQU 25                      ; 

BATWIDTH        EQU 360                     ; Bat Size
BATHEIGHT       EQU 360                     ; 

CROWNWIDTH      EQU 320                     ; Crown Size
CROWNHEIGHT     EQU 149                     ; 

HELPWIDTH       EQU 400                     ; Help Size
HELPHEIGHT      EQU 445                     ; 

MINSPRITE       EQU 1                       ; Minimum number of sprites to display
MAXSPRITE       EQU 22                      ; Maximum number of sprites to display

    RSRESET
SprCount        RS.W 1                      ; Frames Count
SprLeft         RS.L 1                      ; X position
SprTop          RS.L 1                      ; Y position
SprWidth        RS.L 1                      ; Frames Width
SprHeight       RS.L 1                      ; Frames Height
SprStepX        RS.L 1                      ; X move step
SprStepY        RS.L 1                      ; Y move step
SprIndex        RS.W 1                      ; Index of frame
SprSize         RS.L 1                      ; Bytes per frame
SprData         RS.L 1                      ; Frames start address
SprSIZEOF       RS.L 0                      ; SIZEOF


;******************************************************************************
;*
    SECTION S_0,CODE
;*
;******************************************************************************


MAIN:


;------------------------------------------------------------------------------
; INIT PROGRAM
;------------------------------------------------------------------------------


.OpenDOS
    lea      DosName,a1                     ; Open DOS
    move.l   #39,d0                         ; 
    CALLEXEC OpenLibrary                    ; 
    move.l   d0,_DOSBase                    ; Store result
    tst.l    d0                             ; 
    beq      .FreeALL                       ; Exit on error

    IFNE USE_AC68080
    
.OpenAMMX
    bsr      EnableAMMX                     ; Tell Exec that we use AMMX
    bne.s    .OpenIntuition                 ; Continue if all OK
    move.l   #ERR_AC68080,d1                ; Error striing
    CALLDOS  PutStr                         ; Display error message
    beq      .Exit                          ; Exit on error
    
    ENDC

.OpenIntuition
    lea      IntuiName,a1                   ; Open Intuition
    move.l   #39,d0                         ; 
    CALLEXEC OpenLibrary                    ; 
    move.l   d0,_IntuitionBase              ; Store result
    tst.l    d0                             ; 
    beq      .FreeALL                       ; Exit on error

.OpenCGX
    lea      CgxName,a1                     ; Open Cybergraphics
    move.l   #39,d0                         ; 
    CALLEXEC OpenLibrary                    ; 
    move.l   d0,_CgxBase                    ; Store result
    tst.l    d0                             ; 
    beq      .FreeALL                       ; Exit on error

.GetBestMode
    lea      MyBestModeTagItems,a0          ; Get Best ModeID
    CALLCGX  BestCModeIDTagList             ; 
    move.l   d0,ScrModeID                   ; Store result
    cmp.l    #INVALID_ID,d0                 ; 
    beq      .FreeALL                       ; Exit on error

.OpenScreen
    lea      MyNewScreen,a0                 ; NewScreen Struct
    lea      MyNewScreenTagItems,a1         ; TagItems
    move.l   ScrModeID,4(a1)                ; TagItems->SA_DisplayID
    CALLINT  OpenScreenTagList              ; 
    move.l   d0,ScrHandle                   ; Store result
    tst.l    d0                             ; 
    beq      .FreeALL                       ; Exit on error

.OpenWindow
    lea      MyWindowTagItems,a1            ; TagItems
    move.l   ScrHandle,4(a1)                ; TagItems->WA_CustomScreen
    suba.l   a0,a0                          ; 
    CALLINT  OpenWindowTagList              ; 
    move.l   d0,WndHandle                   ; Store result
    tst.l    d0                             ; 
    beq      .FreeALL                       ; Exit on error
    move.l   d0,a0                          ; 
    move.l   wd_UserPort(a0),WndMsgPort     ; Store Window Message Port

.OpenTimer
    lea      TimerName,a0                   ; Open Timer
    lea      TimerIORequest,a1              ; IORequest Struct
    move.l   #UNIT_MICROHZ,d0               ; Unit
    moveq.l  #0,d1                          ; Flags
    CALLEXEC OpenDevice                     ; 
    move.l   d0,TimerResult                 ; Store result
    tst.l    d0                             ; 
    bne      .FreeALL                       ; Exit on error
    lea      TimerIORequest,a1              ; 
    move.l   IO_DEVICE(a1),_TimerBase       ; Store IODevice

.AllocBuffers
    move.l   #(SCREENSIZE*(3+1)),d0         ; Screen Size * 3 Buffers (1 extra)
    add.l    #(MEM_ALIGN-1),d0              ; Size + Alignment
    move.l   d0,MemSize                     ; MemSize
    move.l   #(MEMF_LOCAL!MEMF_FAST),d1     ; MemFlags
    CALLEXEC AllocMem                       ; Allocate memory
    tst.l    d0                             ; Check result
    beq      .FreeALL                       ; Exit on error
    move.l   d0,MemAddr                     ; MemAddr
    add.l    #(MEM_ALIGN-1),d0              ; Align MemAddr
    and.l    #~(MEM_ALIGN-1),d0             ; 
    move.l   d0,FBAddr1                     ; Get FrameBuffer #1
    add.l    #SCREENSIZE,d0                 ; 
    move.l   d0,FBAddr2                     ; Get FrameBuffer #2
    add.l    #SCREENSIZE,d0                 ; 
    move.l   d0,FBAddr3                     ; Get FrameBuffer #3

.AddInterrupt
    moveq.l  #INTB_VERTB,d0                 ; Interrupt Number
    lea      VBLInterruptStruct,a1          ; Interrupt Struct
    CALLEXEC AddIntServer                   ; Exec->AddIntServer(num, interrupt)


;------------------------------------------------------------------------------
; INIT GFX DATA
;------------------------------------------------------------------------------


SPRITESET MACRO
    lea      (\1),a0
    move.l   #\2+BMPHDR,SprData(a0)
    ENDM


    SPRITESET SprSorceressIdle,GfxSorceressIdle

    SPRITESET SprFighter,GfxFighter

    SPRITESET SprAmazon,GfxAmazon
    SPRITESET SprWizard,GfxWizard
    SPRITESET SprElf,GfxElf
    SPRITESET SprDwarf,GfxDwarf
    SPRITESET SprSorceress,GfxSorceress

    SPRITESET SprAmazon2,GfxAmazon
    SPRITESET SprWizard2,GfxWizard
    SPRITESET SprElf2,GfxElf
    SPRITESET SprDwarf2,GfxDwarf
    SPRITESET SprSorceress2,GfxSorceress

    SPRITESET SprAmazon3,GfxAmazon
    SPRITESET SprWizard3,GfxWizard
    SPRITESET SprElf3,GfxElf
    SPRITESET SprDwarf3,GfxDwarf
    SPRITESET SprSorceress3,GfxSorceress

    SPRITESET SprAmazon4,GfxAmazon
    SPRITESET SprWizard4,GfxWizard
    SPRITESET SprElf4,GfxElf
    SPRITESET SprDwarf4,GfxDwarf
    SPRITESET SprSorceress4,GfxSorceress


;------------------------------------------------------------------------------
; INIT MUSIC
;------------------------------------------------------------------------------


    lea      MAINMODULE,a0                  ; Load protracker module
    bsr      _PT_StartPlay                  ; Start playing


;------------------------------------------------------------------------------
; INTRO SCREEN
;------------------------------------------------------------------------------


    move.l   FBAddr1,FBAddr                 ; Current FrameBuffer
    
    moveq.l  #0,d0                          ; XOffset
    moveq.l  #0,d3                          ; Modulus
    move.l   #GfxIntro+BMPHDR,a0            ; Source
    bsr      DrawBackground                 ; Draw Background
    move.l   FBAddr,SAGA_FBADDR             ; Set FrameBuffer

    move.l   #INTRO_DELAY,d1                ; Some ticks
    CALLDOS  Delay                          ; Wait


;------------------------------------------------------------------------------
; MAIN SCREEN
;------------------------------------------------------------------------------


.MainLoop                                   ; Main loop


    move.l   FBAddr1,FBAddr                 ; Current FrameBuffer


.CheckBackground
    tst.l    DisplayBack                    ; 
    bne.s    .RenderBackground              ; 
    bsr      ClearScreen                    ; 
    bra.s    .RenderSprites                 ; 
.RenderBackground
    move.l   XOffset,d0                     ; XOffset
    lsr.l    #4,d0                          ; 
    cmp.w    #(SCREENWIDTH*2),d0            ; Check bound
    bmi.s    .RenderBackground.next         ; 
    clr.l    XOffset                        ; Reset XOffset
    clr.l    d0                             ; 
.RenderBackground.next
    move.l   #GfxBack+BMPHDR,a0             ; Source
    move.l   #SCREENWIDTH*BYTESPERPIX*2,d3  ; Modulus
    bsr      DrawBackground                 ; Draw Background

.RenderSprites
    lea      SpriteList,a2                  ; Load sprite array
    move.l   NumSprite,d4                   ; 
    subq.l   #1,d4                          ; 
.RenderSprites.loop
    addq.w   #4,SprIndex(a2)                ; Increment frame
    move.w   SprIndex(a2),d0                ; 
    cmp.w    SprCount(a2),d0                ; 
    ble.b    .RenderSprites.next            ; Skip
    sub.w    SprCount(a2),d0                ; 
    move.w   d0,SprIndex(a2)                ; 
.RenderSprites.next
    clr.l    d0                             ; 
    move.w   SprIndex(a2),d0                ; Calc frame addr
    lsr.w    #4,d0                          ; 
    mulu.l   SprSize(a2),d0                 ; 
    move.l   SprData(a2),a0                 ; 
    add.l    d0,a0                          ; Source
    move.l   SprLeft(a2),d0                 ; X
    lsr.l    #4,d0                          ; 
    move.l   SprTop(a2),d1                  ; Y
    move.l   SprWidth(a2),d2                ; W
    move.l   SprHeight(a2),d3               ; H
    bsr      DrawSprite                     ; Draw Sprite
    add.l    #SprSIZEOF,a2                  ; Next Sprite 
    dbf      d4,.RenderSprites.loop         ; Continue

.RenderCrown
    tst.l    DisplayCrown                   ; Check if true
    beq.s    .RenderBAT                     ; Else skip
    move.l   #GfxCrown+BMPHDR,a0            ; Source
    move.l   #(SCREENWIDTH-CROWNWIDTH)/2,d0 ; X
    move.l   CrownTopPos,d1                 ; Y
    move.l   #CROWNWIDTH,d2                 ; W
    move.l   #CROWNHEIGHT,d3                ; H
    bsr      DrawSprite                     ; Draw Sprite

.RenderBAT
    tst.l    DisplayBat                     ; Check if true
    beq.s    .RenderHELP                    ; Else skip
    move.l   #GfxBat+$46,a0                 ; Source
    move.l   #(SCREENWIDTH-BATWIDTH)/2,d0   ; X
    move.l   #50,d1                         ; Y
    move.l   #BATWIDTH,d2                   ; W
    move.l   #BATHEIGHT,d3                  ; H
    bsr      DrawSprite                     ; Draw Sprite

.RenderHELP
    tst.l    DisplayHelp                    ; Check if true
    beq.s    .RenderStats                   ; Else skip
    move.l   #GfxHelp+$46,a0                ; Source
    move.l   #(SCREENWIDTH-HELPWIDTH),d0    ; X
    move.l   #10,d1                         ; Y
    move.l   #HELPWIDTH,d2                  ; W
    move.l   #HELPHEIGHT,d3                 ; H
    bsr      DrawSprite                     ; Draw Sprite

.RenderStats
    bsr      DrawStats                      ; Draw Stats

.BusyWait
    tst.w    VBLCounter                     ; Check VBLCounter
    beq.s    .BusyWait                      ; Wait until VBLCounter = 0

.UpdateVBLInt
    move.w   VBLCounter,d7                  ; Read and reset the
    clr.w    VBLCounter                     ; VBL interrupt counter

.UpdateScrolling
    move.l   XStep,d0                       ; Increment Scrolling
    mulu.w   d7,d0                          ; 
    add.l    d0,XOffset                     ; 

.UpdateSprites
    lea      SpriteList,a0                  ; Load Sprite list
    move.l   NumSprite,d0                   ; 
    subq.l   #1,d0                          ; 
.UpdateSprites.loop
    move.l   SprStepX(a0),d1                ; Increment X position
    cmp.l    #(SCREENWIDTH*16),SprLeft(a0)  ; 
    blo.s    .UpdateSprites.incx            ; 
    clr.l    SprLeft(a0)                    ; 
    bra.s    .UpdateSprites.next            ; 
.UpdateSprites.incx
    mulu.w   d7,d1                          ; 
    add.l    d1,SprLeft(a0)                 ; 
.UpdateSprites.next
    add.l    #SprSIZEOF,a0                  ; Next SprList element 
    dbf      d0,.UpdateSprites.loop         ; Continue

.UpdateSorceress
    lea      SprSorceressIdle,a0            ; Load Sprite
    move.l   WndHandle,a1                   ; Load Window
    clr.l    d0                             ; 
    move.w   wd_MouseX(a1),d0               ; Get mx
    clr.l    d1                             ; 
    move.w   wd_MouseY(a1),d1               ; Get my
.UpdateSorceress.clampX
    cmp.l    #SCREENWIDTH-164,d0            ; Clamp mx
    blo.s    .UpdateSorceress.clampY        ; 
    move.l   #SCREENWIDTH-164,d0            ; 
.UpdateSorceress.clampY
    cmp.l    #SCREENHEIGHT-217,d1           ; Clamp my
    blo.s    .UpdateSorceress.set           ; 
    move.l   #SCREENHEIGHT-217,d1           ; 
.UpdateSorceress.set
    lsl.l    #4,d0                          ; 
    move.l   d0,SprLeft(a0)                 ; Set X
    move.l   d1,SprTop(a0)                  ; Set Y

.FirstScreen
    move.l   _IntuitionBase,a0              ; IntuitionBase
    move.l   ib_FirstScreen(a0),a0          ; IntuitionBase->FirstScreen
    cmp.l    ScrHandle,a0                   ; Screen == Mine ?
    bne.s    .ProcessEvents                 ; Skip if not my screen
    
.SwapBuffers
    move.l   FBAddr1,a1                     ; \
    move.l   FBAddr2,a2                     ;  | [a][b][c]
    move.l   FBAddr3,a3                     ; /
    move.l   a2,FBAddr1                     ; \
    move.l   a3,FBAddr2                     ;  | [c][a][b]
    move.l   a1,FBAddr3                     ; /
    move.l   FBAddr,SAGA_FBADDR             ; Set FrameBuffer

.ProcessEvents  
    bsr      ProcessEvents                  ; Process Events
    tst.l    d0                             ; 
    beq      .MainLoop                      ; Until d0 <> 0


;------------------------------------------------------------------------------
; STOP MUSIC
;------------------------------------------------------------------------------


    bsr      _PT_StopPlay                   ; Stop Protracker music


;------------------------------------------------------------------------------
; OUTRO SCREEN
;------------------------------------------------------------------------------


    move.l   FBAddr1,FBAddr                 ; Current FrameBuffer
    
    moveq.l  #0,d0                          ; XOffset
    moveq.l  #0,d3                          ; Modulus
    move.l   #GfxOutro+BMPHDR,a0            ; Source
    bsr      DrawBackground                 ; Draw Background   
    move.l   FBAddr,SAGA_FBADDR             ; Set FrameBuffer
    
    move.l   #OUTRO_DELAY,d1                ; Some ticks
    CALLDOS  Delay                          ; Wait


;------------------------------------------------------------------------------
; EXIT PROGRAM
;------------------------------------------------------------------------------


.RemoveInterrupt
    moveq.l  #INTB_VERTB,d0                 ; Interrupt Number
    lea      VBLInterruptStruct,a1          ; Interrupt Struct
    CALLEXEC RemIntServer                   ; Exec->RemIntServer(num, interrupt)


.FreeALL


.FreeBuffers
    tst.l    MemAddr                        ; Free Memory
    beq.s    .CloseTimer                    ; 
    move.l   MemAddr,a1                     ; 
    move.l   MemSize,d0                     ; 
    CALLEXEC FreeMem                        ; 
.CloseTimer
    tst.l    TimerResult                    ; Close Timer device
    bne.s    .CloseWindow                   ; 
    lea      TimerIORequest,a1              ; 
    CALLEXEC CloseDevice                    ; 
.CloseWindow
    tst.l    WndHandle                      ; Close Window
    beq.s    .CloseScreen                   ; 
    move.l   WndHandle,a0                   ; 
    CALLINT  CloseWindow                    ; 
.CloseScreen
    tst.l    ScrHandle                      ; Close Screen
    beq.s    .CloseCGX                      ; 
    move.l   ScrHandle,a0                   ; 
    CALLINT  CloseScreen                    ; 
.CloseCGX
    tst.l    _CgxBase                       ; Close Cybergraphics
    beq.s    .CloseIntuition                ; 
    move.l   _CgxBase,a1                    ; 
    CALLEXEC CloseLibrary                   ; 
.CloseIntuition
    tst.l    _IntuitionBase                 ; Close Intuition
    beq.s    .CloseDOS                      ; 
    move.l   _IntuitionBase,a1              ; 
    CALLEXEC CloseLibrary                   ; 
.CloseDOS
    tst.l    _DOSBase                       ; Close DOS
    beq.s    .Exit                          ; 
    move.l   _DOSBase,a1                    ; 
    CALLEXEC CloseLibrary                   ; 
.Exit                                       ; 
    moveq.l  #0,d0                          ; Return Code
    rts                                     ; Return to System


;******************************************************************************
;* 
ClearScreen:
;* 
******************************************************************************


    PUSHALL                                 ; Store registers
    move.l   FBAddr,a0                      ; FrameBuffer
    move.l   #(SCREENSIZE/8),d0             ; Iterations
.a  clr.l    (a0)+                          ; Clear 2 pixels
    clr.l    (a0)+                          ; Clear 2 pixels
    subq.l   #1,d0                          ; 
    bne.s    .a                             ; Until d1 = 0
    POPALL                                  ; Restore registers
    rts                                     ; Return


;*****************************************************************************
;* 
DrawBackground:
;* 
;* INPUTS
;* A0.L = Source
;* D0.L = XOffset
;* D3.L = Modulus
;* 
;******************************************************************************


    PUSHALL                                 ; Store registers
    move.l   FBAddr,a1                      ; FrameBuffer
    lsl.l    #1,d0                          ; XOffset * BytesPerPixel
    add.l    d0,a0                          ; Update Source
    move.l   #(SCREENHEIGHT-1),d1           ; Number of loopY
.y  move.l   #(SCREENWIDTH/4)-1,d2          ; Number of loopX
.x  move.l   (a0)+,(a1)+                    ; Copy 2 pixels
    move.l   (a0)+,(a1)+                    ; Copy 2 pixels
    dbf.s    d2,.x                          ; Next x
    add.l    d3,a0                          ; Modulus
    dbf.s    d1,.y                          ; Next y
    POPALL                                  ; Restore registers
    rts                                     ; Return


;******************************************************************************
;* 
DrawSprite:
;* 
;* INPUTS
;* A0.L = Source
;* D0.L = DestX
;* D1.L = DestY
;* D2.L = Width
;* D3.L = Height
;* 
;******************************************************************************


    PUSHALL                                 ; Store registers
    move.l   FBAddr,a1                      ; FrameBuffer
    lsl.l    #1,d0                          ; x * BytesPerPixel
    add.l    d0,a1                          ; Update Dest
    mulu.l   #(SCREENWIDTH*2),d1            ; y * w * BytesPerPixel
    add.l    d1,a1                          ; Update Dest
    move.l   #SCREENWIDTH,d0                ; ( ScrW - SprW ) * BytesPerPixel
    sub.l    d2,d0                          ; 
    lsl.l    #1,d0                          ; 
    move.l   d3,d1                          ; Number of loopY
    subq.l   #1,d1                          ; 
    subq.l   #1,d2                          ; Number of loopX
    lsr.l    #2,d2                          ; loopX / 4

    IFNE USE_AC68080

    tst.l    UseAMMX
    beq.s    .use68k

.useAMMX
    load.w   #%1111100000011111,e0          ; Color mask (Pink R5G6B5)
.y1 move.l   d2,d5                          ; Number of loopX
.x1 load     (a0)+,e6                       ; 
    pcmpeqw  e0,e6,e7                       ; 
    c2p      e7,e7                          ; 
    peor.w   #$ffff,e7,e7                   ; 
    storem   e6,e7,(a1)+                    ; 
    dbf.s    d5,.x1                         ; Next x
    add.l    d0,a1                          ; Update Dest
    dbf.s    d1,.y1                         ; Next y
    POPALL                                  ; Restore registers
    rts                                     ; Return

    ENDC

.use68k
    move.w   #%1111100000011111,d7          ; Color mask (Pink R5G6B5)
.y0 move.l   d2,d5                          ; Number of loopX
.x0 move.w   (a0)+,d6                       ; Read pixel
    cmp.w    d7,d6                          ; Check if transparent
    beq.b    .p1                            ; Skip if transparent
    move.w   d6,(a1)                        ; Copy pixel
.p1 move.w   (a0)+,d6                       ; Read pixel
    cmp.w    d7,d6                          ; Check if transparent
    beq.b    .p2                            ; Skip if transparent
    move.w   d6,2(a1)                       ; Copy pixel
.p2 move.w   (a0)+,d6                       ; Read pixel
    cmp.w    d7,d6                          ; Check if transparent
    beq.b    .p3                            ; Skip if transparent
    move.w   d6,4(a1)                       ; Copy pixel
.p3 move.w   (a0)+,d6                       ; Read pixel
    cmp.w    d7,d6                          ; Check if transparent
    beq.b    .p4                            ; Skip if transparent
    move.w   d6,6(a1)                       ; Copy pixel
.p4 addq.l   #(2*4),a1                      ; Increment dest
    dbf.s    d5,.x0                         ; Next x
    add.l    d0,a1                          ; Update Dest
    dbf.s    d1,.y0                         ; Next y
    POPALL                                  ; Restore registers
    rts                                     ; Return


;******************************************************************************
;*
DrawStats:
;* 
;******************************************************************************


    PUSHALL                                 ; Store registers

    addq.l   #1,FPSCounter1                 ; Increment FPS
    bsr      GetTaskTime                    ; Get time
    cmp.l    #1,d0                          ; Seconds < 1 ?
    blt.s    .n1                            ; Draw or Reset
    move.l   FPSCounter1,d0                 ; Get current FPS
    move.l   d0,FPSCounter2                 ; Save old FPS
    clr.l    FPSCounter1                    ; Reset current FPS
    bsr      ResetTaskTime                  ; Reset time

.n1 move.l   FPSCounter1,d0                 ; Number to draw
    moveq.l  #2,d1                          ; Number of digits
    move.l   #4+(FONTWIDTH*1),d2            ; Destination X
    moveq.l  #4,d3                          ; Destination Y
    bsr      DrawNumber                     ; Draw number

.n2 move.l   FPSCounter2,d0                 ; Number to draw
    moveq.l  #2,d1                          ; Number of digits
    move.l   #SCREENWIDTH-FONTWIDTH-4,d2    ; Destination X
    moveq.l  #4,d3                          ; Destination Y
    bsr      DrawNumber                     ; Draw number

.n3 move.l   NumSprite,d0                   ; Number to draw
    moveq.l  #2,d1                          ; Number of digits
    move.l   #SCREENWIDTH-FONTWIDTH-4,d2    ; Destination X
    move.l   #5+FONTHEIGHT,d3               ; Destination Y
    bsr      DrawNumber                     ; Draw number

.n4 clr.l    d0
    move.l   WndHandle,a0                   ; Load Window
    move.w   wd_MouseX(a0),d0               ; Number to draw
    moveq.l  #3,d1                          ; Number of digits
    move.l   #4+(FONTWIDTH*2),d2            ; Destination X
    move.l   #SCREENHEIGHT-FONTHEIGHT-4,d3  ; Destination Y
    bsr      DrawNumber                     ; Draw number

.n5 clr.l    d0
    move.l   WndHandle,a0                   ; Load Window
    move.w   wd_MouseY(a0),d0               ; Number to draw
    moveq.l  #3,d1                          ; Number of digits
    move.l   #4+(FONTWIDTH*6),d2            ; Destination X
    move.l   #SCREENHEIGHT-FONTHEIGHT-4,d3  ; Destination Y
    bsr      DrawNumber                     ; Draw number

.n6 move.l   UseAMMX,d0                     ; Number to draw
    and.l    #1,d0                          ; 
    moveq.l  #1,d1                          ; Number of digits
    move.l   #SCREENWIDTH-FONTWIDTH-4,d2    ; Destination X
    move.l   #SCREENHEIGHT-FONTHEIGHT-4,d3  ; Destination Y
    bsr      DrawNumber                     ; Draw number

    POPALL                                  ; Restore registers
    rts                                     ; Return    


;******************************************************************************
;*
DrawNumber:
;* 
;* INPUT
;* D0.L = Number to draw
;* D1.L = Number of digits to draw
;* D2.L = Destination X
;* D3.L = Destination Y
;* 
;******************************************************************************


    PUSHALL                                 ; Store registers

    subq.l   #1,d1                          ; Number of digits
.a  clr.l    d4                             ; Reset Digit
    divu.l   #10,d4:d0                      ; Get Digit
    mulu.l   #(FONTWIDTH*FONTHEIGHT*2),d4   ; Digit * FrameSize
    move.l   #GfxFont+BMPHDR,a0             ; Source
    add.l    d4,a0                          ; Source + D1
    
    move.l   d0,a3                          ; Push
    move.l   d1,a4                          ; Push
    move.l   d2,a5                          ; Push
    move.l   d3,a6                          ; Push
    
    move.l   d2,d0                          ; X
    move.l   d3,d1                          ; Y
    move.l   #FONTWIDTH,d2                  ; W
    move.l   #FONTHEIGHT,d3                 ; H
    bsr      DrawSprite                     ; Draw Digit
    
    move.l   a6,d3                          ; Pop
    move.l   a5,d2                          ; Pop
    move.l   a4,d1                          ; Pop
    move.l   a3,d0                          ; Pop
    
    sub.l    #FONTWIDTH,d2                  ; Update Destination X
    dbf.s    d1,.a                          ; Next Digit

    POPALL                                  ; Restore registers
    rts                                     ; Return


;******************************************************************************
;* 
ProcessEvents:
;* 
;* RETURNS
;* D0.L = TRUE (Message) OR FALSE (No message)
;*
;******************************************************************************


    PUSHALL                                 ; Store registers   
    move.l   WndMsgPort,a0                  ; Message Port
    CALLEXEC GetMsg                         ; Exec->GetMsg(port)
    tst.l    d0                             ; Check message
    beq.w    .ok                            ; No message
    move.l   d0,a1                          ; Reply Message
    move.l   im_Class(a1),d5                ; Get message class
    move.w   im_Code(a1),d6                 ; Get message code
    CALLEXEC ReplyMsg                       ; Exec->ReplyMsg(msg)
.buttons
    cmp.l    #IDCMP_MOUSEBUTTONS,d5         ; MOUSEBUTTONS
    bne.s    .rawkeys                       ; 
    cmp.w    #IECODE_LBUTTON,d6             ; LMB
    beq.w    .f1                            ; 
    cmp.w    #IECODE_RBUTTON,d6             ; RMB
    beq.w    .f2                            ; 
    bra.w    .ok                            ; 
.rawkeys
    cmp.l    #IDCMP_RAWKEY,d5               ; RAWKEY
    bne      .ok                            ; 
    cmp.w    #$45,d6                        ; ESC
    beq.w    .stop                          ; 
    cmp.w    #$50,d6                        ; F1
    beq.s    .f1                            ; 
    cmp.w    #$51,d6                        ; F2
    beq.s    .f2                            ; 
    cmp.w    #$52,d6                        ; F3
    beq.w    .f3                            ; 
    cmp.w    #$53,d6                        ; F4
    beq.w    .f4                            ; 
    cmp.w    #$54,d6                        ; F5
    beq.w    .f5                            ; 
    cmp.w    #$55,d6                        ; F6
    beq.w    .f6                            ; 
    cmp.w    #$56,d6                        ; F7
    beq.w    .f7                            ; 
    cmp.w    #$5f,d6                        ; HELP
    beq.w    .help                          ; 
    cmp.w    #CURSORUP,d6                   ; CURSOR TOP
    beq.w    .up                            ; 
    cmp.w    #CURSORDOWN,d6                 ; CURSOR BOTTOM
    beq.w    .down                          ; 
    bra.s    .ok                            ; 
.stop
    moveq.l  #1,d0                          ; STOP = TRUE
    bra.s    .exit                          ; 
.ok
    moveq.l  #0,d0                          ; STOP = FALSE
.exit
    POPALL                                  ; Restore registers
    rts                                     ; Return
.f1
    subq.l   #1,NumSprite                   ; DECREASE SPRITES
    cmp.l    #MINSPRITE,NumSprite           ; 
    bge.s    .ok                            ; 
    move.l   #MINSPRITE,NumSprite           ; 
    bra.s    .ok                            ; 
.f2
    addq.l   #1,NumSprite                   ; INCREASE SPRITES
    cmp.l    #MAXSPRITE,NumSprite           ; 
    ble.s    .ok                            ; 
    move.l   #MAXSPRITE,NumSprite           ; 
    bra.s    .ok                            ; 
.f3
    lea      SpriteList,a0                  ; RESET SPRITES POSITIONS
    move.l   NumSprite,d0                   ; 
    subq.l   #1,d0                          ; 
    clr.l    d1                             ; 
.f3_loop
    add.l    #350,d1                        ; 
    move.l   d1,SprLeft(a0)                 ; 
    add.l    #SprSIZEOF,a0                  ; 
    dbf.s    d0,.f3_loop                    ; 
    bra.w    .ok                            ; 
.f4
    not.l    DisplayBat                     ; ON/OFF BAT
    bra.w    .ok                            ; 
.f5
    not.l    DisplayCrown                   ; ON/OFF CROWN
    bra.w    .ok                            ; 
.f6
    not.l    DisplayBack                    ; ON/OFF BACKGROUND
    bra.w    .ok                            ; 
.f7
    not.l    UseAMMX                        ; ON/OFF AMMX
    bra.w    .ok                            ; 
.help
    not.l    DisplayHelp                    ; ON/OFF HELP
    bra.w    .ok                            ; 
.up
    cmp.l    #4,CrownTopPos                 ; 
    bls.w    .ok                            ; 
    subq.l   #4,CrownTopPos                 ; Y - 4
    bra.w    .ok                            ; 
.down
    cmp.l    #SCREENHEIGHT-CROWNHEIGHT-4,CrownTopPos
    bhi.w    .ok                            ; 
    addq.l   #4,CrownTopPos                 ; Y + 4
    bra.w    .ok                            ; 


;******************************************************************************
;* 
GetTaskTime:
;* 
;* RETURNS
;* D0.L = Seconds
;* D1.L = Microseconds
;* 
;******************************************************************************


    PUSHALL                                 ; Store registers
    lea       TimerVal2,a0                  ; 
    CALLTIMER GetSysTime                    ; 
    lea       TimerVal1,a1                  ; 
    CALLTIMER SubTime                       ; 
    move.l    TV_SECS(a0),d0                ; 
    move.l    TV_MICRO(a0),d1               ; 
    POPALL                                  ; Restore registers
    rts                                     ; Return


;******************************************************************************
;* 
ResetTaskTime:
;*
;******************************************************************************


    PUSHALL                                 ; Store registers
    lea       TimerVal1,a0                  ; 
    CALLTIMER GetSysTime                    ; 
    POPALL                                  ; Restore registers
    rts                                     ; Return


;******************************************************************************
;*
VBLInterruptCode:
;*
;******************************************************************************


    addq.w   #1,VBLCounter                  ; Increment counter
    moveq.l  #0,d0                          ; Return code
    rts                                     ; Return


;******************************************************************************
;*
;* ULONG   EnableAMMX( void )
;* D0
;* 
;* Input:  None
;* Output: TRUE
;* Trash:  D0/D1
;* 
;* Notes:  This function informs Exec the task intends to use AMMX.
;* 
;******************************************************************************


    IFNE USE_AC68080

EnableAMMX:
    moveq.l  #0,d0                          ; FALSE
    move.l   $4.w,a6                        ; SysBase
    move.w   AttnFlags(a6),d1               ; SysBase->AttnFlags
    btst     #10,d1                         ; AttnFlags -> AFB_68080
    beq.s    .exit                          ; Skip if bit cleared
    CALLLIB  _LVODisable                    ; Disable(void)
    CALLLIB  _LVOSuperState                 ; SuperState(void)
    move     SR,d1                          ;   Read SR
    or.w     #$800,d1                       ;   SR -> Bit(11) = 1
    move     d1,SR                          ;   Write SR
    CALLLIB  _LVOUserState                  ; UserState(void)
    CALLLIB  _LVOEnable                     ; Enable(void)
    moveq.l  #1,d0                          ; TRUE
.exit
    rts                                     ; Return

    ENDC


;******************************************************************************
;*
;*  PROTRACKER PLAY ROUTINE
;*
;******************************************************************************


    INCLUDE PTPlay30B.s


;******************************************************************************
;*
    SECTION S_1,DATA
;*
;******************************************************************************


    EVEN
CgxName         CGXNAME                     ; Cybergraphics
DosName         DOSNAME                     ; DOS
IntuiName       INTNAME                     ; Intuition
TimerName       TIMERNAME                   ; Timer.device


;------------------------------------------------------------------------------


    EVEN
_CgxBase        DC.L 0                      ; Cybergraphics
_DOSBase        DC.L 0                      ; DOS
_IntuitionBase  DC.L 0                      ; Intuition
_TimerBase      DC.L 0                      ; Timer (IODevice)


;------------------------------------------------------------------------------


    EVEN
MemSize         DC.L 0                      ; Allocated Memory Address
MemAddr         DC.L 0                      ; Allocated Memory Size

FBAddr          DC.L 0                      ; Current FrameBuffer
FBAddr1         DC.L 0                      ; FrameBuffer #1
FBAddr2         DC.L 0                      ; FrameBuffer #2
FBAddr3         DC.L 0                      ; FrameBuffer #3


;------------------------------------------------------------------------------


XStep           DC.L 8                      ; Scrolling step
XOffset         DC.L 0                      ; Background Scrolling X offset
ScrModeID       DC.L 0                      ; Display ModeID
ScrHandle       DC.L 0                      ; Intuition Screen
WndHandle       DC.L 0                      ; Intuition Window
WndMsgPort      DC.L 0                      ; Intuition Message Port

TimerResult     DC.L 0                      ; OpenDevice Result
TimerVal1       DS.B TV_SIZE                ; TimeVal Struct
TimerVal2       DS.B TV_SIZE                ; TimeVal Struct
TimerIORequest  DS.B IOTV_SIZE              ; TimeVal IORequest Struct

FPSCounter1     DC.L 0                      ; 
FPSCounter2     DC.L 0                      ; 

UseAMMX         DC.L ~0                     ; Use AMMX or not
DisplayBat      DC.L  0                     ; Show/Hide the bat
DisplayBack     DC.L ~0                     ; Show/Hide the background
DisplayCrown    DC.L  0                     ; Show/Hide the crown
DisplayHelp     DC.L ~0                     ; Show/Hide the help
NumSprite       DC.L  7                     ; Number of sprites to display
CrownTopPos     DC.L 50                     ; Initial Y position of the logo


;------------------------------------------------------------------------------


    EVEN
MyNewScreen:                                ; Intuition->OpenScreenTagList()
    DC.W 0                                  ; Left
    DC.W 0                                  ; Top
    DC.W SCREENWIDTH                        ; Width
    DC.W SCREENHEIGHT                       ; Height
    DC.W SCREENDEPTH                        ; Depth
    DC.B 0                                  ; DetailPen
    DC.B 1                                  ; BlockPen
    DC.W 0                                  ; ViewModes
    DC.W SCREENQUIET|CUSTOMSCREEN           ; Types
    DC.L 0                                  ; *Font
    DC.L MyNewScreenTitle                   ; *Title
    DC.L 0                                  ; *Gadgets
    DC.L 0                                  ; *Bitmap

    EVEN
MyNewScreenTagItems:                        ; Intuition->OpenScreenTagList()
    DC.L SA_DisplayID,0                     ; Display ModeID
    DC.L 0,0                                ; TAGEND

    EVEN
MyNewScreenTitle:                           ; Screen Title
    DC.B "Vampire 2D Tech Demo",0           ; 


;------------------------------------------------------------------------------


    EVEN
MyWindowTagItems:                           ; Intuition->OpenWindowTagList()
    DC.L WA_CustomScreen,0                  ; CustomScreen
    DC.L WA_Width,SCREENWIDTH               ; Width
    DC.L WA_Height,SCREENHEIGHT             ; Height
    DC.L WA_Backdrop,-1                     ; Has Backdrop
    DC.L WA_Borderless,-1                   ; Has BorderLess
    DC.L WA_Activate,-1                     ; Has Activate
    DC.L WA_ReportMouse,-1                  ; Has ReportMouse
    DC.L WA_SizeGadget,0                    ; Has SizeGadget
    DC.L WA_DepthGadget,0                   ; Has DepthGadget
    DC.L WA_CloseGadget,0                   ; Has CloseGadget
    DC.L WA_DragBar,0                       ; Has DragBar
    DC.L WA_RMBTrap,-1                      ; Has RMBTrap
    DC.L WA_IDCMP,IDCMP_RAWKEY|IDCMP_MOUSEBUTTONS ; EVENTS
    DC.L 0,0                                ; TAGEND


;------------------------------------------------------------------------------


    EVEN
MyBestModeTagItems:                         ; Cybergraphics->BestCModeIDTagList()
    DC.L CYBRBIDTG_Depth,SCREENDEPTH        ; Depth
    DC.L CYBRBIDTG_NominalWidth,SCREENWIDTH ; Width
    DC.L CYBRBIDTG_NominalHeight,SCREENHEIGHT ; Height
    DC.L 0,0                                ; TAGEND


;------------------------------------------------------------------------------


    EVEN
VBLCounter:
    DC.W 0

    EVEN
VBLInterruptStruct:
    DC.L 0                                  ; Succ
    DC.L 0                                  ; Pred
    DC.B NT_INTERRUPT                       ; Type
    DC.B -60                                ; Prio
    DC.L VBLInterruptName                   ; Name
    DC.L 0                                  ; Data
    DC.L VBLInterruptCode                   ; Code

    EVEN
VBLInterruptName:
    DC.B "VBLCounter",0


;******************************************************************************
;*
    SECTION S_2,DATA
;*
;******************************************************************************


SPRITEDEF MACRO
    DC.w ((\1)-1)*16                        ; Frame Count
    DC.l (\2)                               ; Left
    DC.l (SCREENHEIGHT-(\5)-(\3))           ; Top
    DC.l (\4)                               ; Width
    DC.l (\5)                               ; Height
    DC.l (\6)                               ; StepX
    DC.l (\7)                               ; StepY
    DC.w 0                                  ; Frame Index
    DC.l ((\4)*(\5))*2                      ; Gfx Size (w*h*2)
    DC.l 0                                  ; Gfx Data (pixels)
    ENDM


SpriteList:

SprSorceressIdle  SPRITEDEF 31,00,00,164,217,00,00

SprFighter        SPRITEDEF 36,80,60,176,259,04,04
SprAmazon         SPRITEDEF 12,80,55,152,248,36,36
SprElf            SPRITEDEF 12,80,45,164,240,32,32
SprWizard         SPRITEDEF 12,80,40,144,216,28,28
SprSorceress      SPRITEDEF 12,80,35,184,214,24,24
SprDwarf          SPRITEDEF 14,80,30,212,187,20,20

SprAmazon2        SPRITEDEF 12,80,55,152,248,36,36
SprElf2           SPRITEDEF 12,80,45,164,240,32,32
SprWizard2        SPRITEDEF 12,80,40,144,216,28,28
SprSorceress2     SPRITEDEF 12,80,35,184,214,24,24
SprDwarf2         SPRITEDEF 14,80,30,212,187,20,20

SprAmazon3        SPRITEDEF 12,80,55,152,248,36,36
SprElf3           SPRITEDEF 12,80,45,164,240,32,32
SprWizard3        SPRITEDEF 12,80,40,144,216,28,28
SprSorceress3     SPRITEDEF 12,80,35,184,214,24,24
SprDwarf3         SPRITEDEF 14,80,30,212,187,20,20

SprAmazon4        SPRITEDEF 12,80,55,152,248,36,36
SprElf4           SPRITEDEF 12,80,45,164,240,32,32
SprWizard4        SPRITEDEF 12,80,40,144,216,28,28
SprSorceress4     SPRITEDEF 12,80,35,184,214,24,24
SprDwarf4         SPRITEDEF 14,80,30,212,187,20,20


;------------------------------------------------------------------------------


    CNOP 0,32
GfxBat            INCBIN "gfx/bat_360_BE.bmp"     ; BAT (360*360)
    CNOP 0,32
GfxHelp           INCBIN "gfx/help_400_BE.bmp"    ; HELP (400*445)
    CNOP 0,32
GfxFont           INCBIN "gfx/font-1-BE.bmp"      ; Digits Font
    CNOP 0,32
GfxIntro          INCBIN "gfx/intro-BE.bmp"       ; Intro Screen (960*540)
    CNOP 0,32
GfxOutro          INCBIN "gfx/outro-BE.bmp"       ; Outro Screen (960*540)
    CNOP 0,32
GfxBack           INCBIN "gfx/back-3-BE.bmp"      ; Castle ((960*3)*540)
    CNOP 0,32
GfxCrown          INCBIN "gfx/crown-BE.bmp"       ; Crown (320*149)
    CNOP 0,32
GfxFighter        INCBIN "gfx/walk-1-BE.bmp"      ; Fighter Walk
    CNOP 0,32
GfxAmazon         INCBIN "gfx/walk-2-BE.bmp"      ; Amazon Walk
    CNOP 0,32
GfxWizard         INCBIN "gfx/walk-3-BE.bmp"      ; Wizard Walk
    CNOP 0,32
GfxElf            INCBIN "gfx/walk-4-BE.bmp"      ; Elf Walk
    CNOP 0,32
GfxDwarf          INCBIN "gfx/walk-5-BE.bmp"      ; Dwarf Walk
    CNOP 0,32
GfxSorceress      INCBIN "gfx/walk-6-BE.bmp"      ; Sorceress Walk
    CNOP 0,32
GfxSorceressIdle  INCBIN "gfx/idle-6-BE.bmp"      ; Sorceress Idle


;******************************************************************************
;*
    SECTION S_4,DATA_C
;*
;******************************************************************************


    EVEN
MAINMODULE:
    INCBIN sfx/powermonger.mod


;******************************************************************************
;*
    SECTION S_5,DATA
;*
;******************************************************************************


    EVEN
ERR_AC68080:
    DC.B "Sorry, this demo needs a AC68080 and AMMX V2.",0

    EVEN
VERSTRING:
    DC.B "$VER: VampireDemo2D 0.6h (13-8-2017) APOLLO-Team",10,0,0


;******************************************************************************
;** 
    END
;**
;******************************************************************************




; Amiga Rulez !
