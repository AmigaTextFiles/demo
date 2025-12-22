;---------------------------------------------------------------------------

;   * Subject: [stella] Colour Display Programme
;   * From: crackers@hwcn.org
;   * Date: Tue, 16 Sep 1997 19:27:01 -0400 (EDT)

;---------------------------------------------------------------------------

; a simple programme that let's you cycle through the colour pallet, one at 
; a time and gives you a binary representation of what colour you are on with the
; PF2 register.

; Maybe someone can use this programme to actually assign some RGB values
; to the 2600's pallet.
; ----------------------------------------------------------------------------

        processor 6502

VSYNC   =       $00
VBLANK  =       $01
WSYNC   =       $02
COLUPF  =       $08
COLUBK  =       $09
PF0     =       $0D
PF1     =       $0E
PF2     =       $0F
CXCLR   =       $2C
SWCHA   =       $280
INTIM   =       $284
TIM64T  =       $296
COLOUR  =       $80     ;the value for the colour
DELAY   =       $81     ;the value for the joystick delay

        org  $F000

start   SEI
        CLD
        LDX  #$FF
        TXS
        LDA  #$00

zero    STA  $00,X      ;looks familiar, right?
        DEX             ;typical zeroing routine
        BNE  zero
        sta  COLUBK
        sta  PF0
        sta  PF1
        sta  PF2
        sta  COLUPF

main    JSR  vertb      ;main loop
        JSR  draw
        JSR  oscan
        JMP  main

vertb   LDX  #$00       ;vertical blank, We all know what this is about
        LDA  #$02
        STA  WSYNC
        STA  WSYNC
        STA  WSYNC
        STA  VSYNC
        STA  WSYNC
        STA  WSYNC
        LDA  #$2C
        STA  TIM64T
        LDA  #$00
        STA  CXCLR
        STA  WSYNC
        STA  VSYNC
        RTS

draw    LDA  INTIM
        BNE  draw
        sta  WSYNC
        sta  VBLANK
        ldx  #$C0       ;192 scanlines
        lda  COLOUR     ;loads the colour
        sta  COLUBK     ;into the playfield background
        sta  PF1        ;also displays a binary representation to PF1
        lda  #$0F
        sta  PF2        ;just to help the binary number look clear.

doit    STA  WSYNC      ;not much going on here, just repeat the
        dex             ;same scanline 192 times
        beq  done
        jmp  doit

done    rts

oscan   jsr  joy        ;go check the joystick
        LDX  #$1E

waste   STA  WSYNC      ;no game logic so let's blow the overscan
        DEX
        BNE  waste
        RTS

joy     lda  SWCHA      ;check the joystick ports
        cmp  #$7F       ;see if it's moved right (joystick 1)
        beq  right
        cmp  #$BF       ;see if it's moved left  (joystick 1)
        beq  left
        rts

right   inc  DELAY      ;our joystick delay timer is increased
        lda  DELAY
        cmp  #$1E       ;check to see if we've had enough delay (30 frames)
        bpl  clrup      ;yep. Let's increase the colour
        rts

left    inc  DELAY      ;joystick timer increased
        lda  DELAY
        cmp  #$1E       ;30 frames yet?
        bpl  clrdwn     ;yep, decrease colour
        rts

clrup   lda  COLOUR
        cmp  #$FE       ;check to see if we've hit the maximum colour
        bne  upit       ;nope, then let's increase it
        lda  #$00
        sta  DELAY      ;reset joystick delay timer
        rts

upit    inc  COLOUR     ;okay... this is sloppy, but it works
        inc  COLOUR     ;increases the colour value to next setting
        lda  #$00
        sta  DELAY      ;reset joystick delay
        rts

clrdwn  lda  COLOUR
        cmp  #$00       ;see if we've hit minimum colour
        bne  dwnit      ;nope, then let's decrease it
        lda  #$00
        sta  DELAY      ;reset the joystick delay
        rts

dwnit   dec  COLOUR     ;yeah, I know, not exactly eligant, but
        dec  COLOUR     ;it increases the colour value to next setting
        lda  #$00
        sta  DELAY      ;reset joystick delay
        rts

        org $FFFC
        .word start
        .word start
