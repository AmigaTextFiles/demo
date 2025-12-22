;  ------------------------------------------------------------------------

;   * Subject: [stella] First attempt at Atari 2600 programming
;   * From: Tennessee Carmel-Veilleux <veilleux@ameth.org>
;   * Date: Mon, 15 Jun 1998 07:34:27 -0400

;  ------------------------------------------------------------------------

; See original message post for details
; http://www.biglist.com/lists/stella/archives/9806/msg00069.html

;--------------------------------------
; My first attempt at writing atari code
; Modification of Erik Mooney's color stripes example
; Mods : -Plays a continuous stream of sound
;        -When you move the joystick, the color of the background
;         is equal to the joystick position bits
;---------------------------------------

;How to Draw a Playfield II, by Erik Mooney (emooney@stevens-tech.edu)
;Heavily indebted to Nick S. Bensema's "How to Draw a Playfield" (thanks!)
;I removed most of Nick's comments.. refer to the original for more
;complete documentation.

        processor 6502
        include vcs.h

    org $F000           ;"processor 6502" was moved into vcs2600.h

Score0  = $80    ;RAM locations
Score1  = $81
Sndfrq  = $82 ;Sound frequency
Oldtim  = $83 ;OLD intim
Framecount = $84 ;Frame count

Joystick0  = $90

Start

    SEI  ; Disable interrupts, if there are any.
    CLD  ; Clear BCD math bit.
    LDX  #$FF
    TXS  ; Set stack to top of RAM.

    LDA #0  ;Zero everything except VSYNC.
B1  STA 0,X
    DEX
    BNE B1

    STA Framecount
; At this point in the code we would set up things like the data
; direction registers for the joysticks and such.

    JSR  GameInit

MainLoop
    JSR  VerticalBlank ;Execute the vertical blank.
    JSR  CheckSwitches ;Check console switches.
    JSR  GameCalc      ;Do calculations during Vblank
    JSR  DrawScreen    ;Draw the screen
    JSR  OverScan      ;Do more calculations during overscan
    JMP  MainLoop      ;Continue forever.

VerticalBlank          ;Beginning of the frame - at the end of overscan.
    LDA  #2            ;VBLANK was set at the beginning of overscan.
    STA  WSYNC
    STA  WSYNC
    STA  WSYNC
    STA  VSYNC ;Begin vertical sync.
    STA  WSYNC ; First line of VSYNC
    STA  WSYNC ; Second line of VSYNC.

; Atari says we have to have 37 scanlines of VBLANK time.  Since
; each scanline uses 76 cycles, that makes 37*76=2888 cycles.
; We must also subtract the five cycles it will take to set the
; timer, and the three cycles it will take to STA WSYNC to the next
; line.  Plus the checking loop is only accurate to six cycles, making
; a total of fourteen cycles we have to waste.  2888-14=2876.
;
; We almost always use TIM64T for this, since the math just won't
; work out with the other intervals.  2880/64=44.something.  It
; doesn't matter what that something is, we have to round DOWN.

    LDA #44        ;Set timer to activate during the last line of VBLANK.
    STA TIM64T
;
; Now we can end the VSYNC period.
;
    LDA #0
    STA  WSYNC ; Third line of VSYNC.
    STA  VSYNC ; Writing zero to VSYNC ends vertical sync period.
    RTS

CheckSwitches
    LDA #0          ;Clear collision latches
    STA CXCLR       ;In a real game, we'd probably check the collision
                    ;registers before clearing them.
    LDA SWCHA       ;Read joystick 0
    STA Joystick0   ;Store for later use
    RTS

GameCalc
    LDA #0
    STA COLUBK  ;Background will be black.

    LDA Joystick0  ;Load the joystick switches
    AND #$F0    ;Only care about top four bits, which is joystick 0
    CMP #$F0    ;If top four=1111, stick centered, don't change
                ;---------------------
                ; The AND $F0 is also very useful at getting only the color
                ; high nibble needed by the COLUBK register
    BEQ NoStick ; If no stick movement, branch
    ; LDA #$88  ;
    STA COLUBK  ; Otherwise use the reminescent value in A to set background
                ;---------------------
NoStick

    LDA #$55    ;Alternate pixels: 01010101 = $55
    STA PF0
    STA PF2     ;Store alternating bit pattern to the playfield registers
    ASL         ;Because PF1 displays in the opposite bit order from PF0
    STA PF1     ;and PF2, we need 10101010 instead of 01010101.
    LDA #1
;    STA CTRLPF  ;Let's reflect the playfield just cause we feel like it =)
    RTS

;To refresh your memory:
;    PF0  |     PF1       |      PF2
;  4 5 6 7|7 6 5 4 3 2 1 0|0 1 2 3 4 5 6 7
;This pattern is the left half of the screen; it's then either repeated
;or reflected depending on bit 0 of CTRLPF.  For a playfield that doesn't
;repeat or reflect, you'd have to alter the playfield registers in the
;middle of each scanline.

DrawScreen
    LDA INTIM
    BNE DrawScreen ;Loops until the timer is done - that means we're
                   ;somewhere in the last line of vertical blank.
    STA WSYNC      ;End the current scanline - the last line of VBLANK.
    STA VBLANK     ;End the VBLANK period.  The TIA will display stuff
                   ;starting with the next scanline.  We do have 23 cycles
                   ;of horizontal blank before it displays anything.

    ;--My sound routine---
    INC Framecount
    LDX Framecount

    PHA ; Save old TIMer state
    TXA ; Transfer line value in A
    AND #$1F ; Get a 0-31 (5 bits) value for divider from y line
    STA AUDF0 ; Set frequency divider
    AND #$0F ; Get a 0-15 (4 bits) value for volume from y line
    STA AUDV0 ; Set audio volume
    LDA #$04 ; Pur 4 into A
    STA AUDC0 ; Set audio control to 0 (divide by 1)
    PLA ; Load old timer into A

    ;-------------------

    LDY #0       ;We're going to use Y to count scanlines.

;Everything is already set, so let's just count scanlines.
;We're at the beginning of WBLANK of the first TV line right here.
ScanLoop

    ;------------------
    ; ***** Problem here... If you comment out the previoud block
    ; of sound code, and use this one instead, the machine is rendered
    ; Extremely slow. Anybody would know why ?
    ;------------------
    ;STY Sndfrq ; Story Y line value in Sndfrq
    ;LDX Sndfrq ; load y line value in X

    ;STA Oldtim ; Save old TIMer state
    ;TXA ; Transfer line value in A
    ;AND #$1F ; Get a 0-31 (5 bits) value for divider from y line
    ;STA AUDF0 ; Set frequency divider
    ;AND #$0F ; Get a 0-15 (4 bits) value for volume from y line
    ;STA AUDV0 ; Set audio volume
    ;LDA #$04 ; Pur 4 into A
    ;STA AUDC0 ; Set audio control to 0 (divide by 1)
    ;LDA Oldtim ; Load old timer into A
    ;-------------------

    STY COLUPF     ;Keep changing the playfield color every line for some
                   ;neat-looking stripes.

NoChange
    STA WSYNC      ;Wait for end of scanline
    INY

    BNE ScanLoop   ;Count scanlines.
    RTS

OverScan        ;We've got 30 scanlines to kill.
    LDX #30     ;In a real game, we'd probably be doing calculations here,
KillLines       ;possibly using the timer again to tell us when overscan
    STA WSYNC   ;is done instead of counting the scanlines.
    DEX
    BNE KillLines
    RTS

GameInit    ;Usually called to start a new game.. we're not using it yet.
    LDA #0  ;Just example code to show what could be done here.
    STA Score0
    STA Score1
    RTS

;Starting positions for PC
    org $FFFC
    .word Start
    .word Start