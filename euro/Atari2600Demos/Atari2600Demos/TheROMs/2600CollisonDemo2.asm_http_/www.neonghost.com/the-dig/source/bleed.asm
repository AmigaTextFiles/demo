;  ------------------------------------------------------------------------

;   * Subject: [stella] New 2600 programmer's first attempt
;   * From: "Scott Huggins" <shuggins@leopardinc.com>
;   * Date: Tue, 15 Feb 2000 23:59:54 -0600

;  ------------------------------------------------------------------------

; After reading the Stella manual (several times) and other demo source code,
; I've tried to position a sprite (player 0) on scanline 95.  I'm not sure
; about the horizontal positioning of the Sprite, but I've written to RESP0
; in the VBLANK routine.

; Basically, the purpose of this demo is to draw a bunch of vertical lines
; for the playfield and position my sprite and that's about it.  It was
; borrowed from a post by Erik Mooney.  My sprite is a goofy looking space
; ship that I made.  I tried it out by re-placing the player 0 (the TANK) in
; the source of combat with it and compiling it.

; Anyway, I'm getting an error where my coments indicate. Look for "<=".
; This indicates my error. All I'm trying to do is load the X register (?)

; ----------code----------------

; [include vcs.h etc, etc, etc.....]

scanctr = $91   ; variable used to count scanlines (looking for scanline 95)
                ; the Y registerwill be used to count scanlines from 191 -
0.  This
                ; variable (scanctr)
                ; will count from 0 - 191.  When Y meets scanctr, then we are at
                ; scanline 95 and it's time to draw our sprite.

;  *** usual initialize
Start

    SEI  ; Disable interrupts, if there are any.
    CLD  ; Clear BCD math bit.
    LDX  #$FF
    TXS  ; Set stack to top of RAM.

    LDA #0  ;Zero everything except VSYNC.
B1  STA 0,X
    DEX
    BNE B1

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
    BEQ NoStick
    LDA #$88    ;otherwise, make the background medium blue
    STA COLUBK
NoStick

    LDA #$55    ;Alternate pixels: 01010101 = $55
    STA PF0
    STA PF2     ;Store alternating bit pattern to the playfield registers
    ASL         ;Because PF1 displays in the opposite bit order from PF0
    STA PF1     ;and PF2, we need 10101010 instead of 01010101.
    LDA #1
    STA CTRLPF  ;Let's reflect the playfield just cause we feel like it
    STA RESP0   ; SCOTT
    RTS

DrawScreen
    LDA INTIM
    BNE DrawScreen ;Loops until the timer is done - that means we're
                   ;somewhere in the last line of vertical blank.
    STA WSYNC      ;End the current scanline - the last line of VBLANK.
    STA VBLANK     ;End the VBLANK period.  The TIA will display stuff
                   ;starting with the next scanline.  We do have 23 cycles
                   ;of horizontal blank before it displays anything.

    LDY #192       ;We're going to use Y to count scanlines.

;Everything is already set, so let's just count scanlines.
;We're at the beginning of WBLANK of the first TV line right here.
ScanLoop
    STY COLUPF     ;Keep changing the playfield color every line for some
                   ;neat-looking stripes.
    STA WSYNC      ;Wait for end of scanline
    INC scanctr    ; increment our scanline ctr
    DEY
    LDA Y
    CMP #$91         ; compare the Y register to value in memory location $91
    BEQ drawSprite   ; get rid of this if things start breaking
    BNE ScanLoop     ;Count scanlines.
    RTS

drawSprite    ;  I'm trying to load the 8 bytes of sprite data at end of file
        LDX #08   ; <=  I GET A SYNTAX ERROR HERE!!!   Al I'm trying to do is load the X register with hex value 8
cont  STA WSYNC
         LDA Sprite,X
         STA GP0
         DEX
         BNE cont
         RTS

OverScan        ;We've got 30 scanlines to kill.
    LDX #30     ;In a real game, we'd probably be doing calculations

Sprite
     .byte   %11111000   ; this is a goofy looking ship
     .byte   %00100110
     .byte   %11111111
     .byte   %00111110
     .byte   %11100100
     .byte   %00101000
     .byte   %11111000
     .byte   %00000000

; Starting positions for PC
    org $FFFC
    .word Start
    .word Start

;  ------------------------------------------------------------------------
