;  ------------------------------------------------------------------------

;     Subject: [stella] Fixed non HMOVE sprite experiment 
;     From: CRACKERS <crackers@hwcn.org> 
;     Date: Wed, 15 Apr 1998 17:22:05 -0400 (EDT) 

;  ------------------------------------------------------------------------

; Dark grey background.
; Blue Stickman at top of the screen moving back and forth.
; Red Ghost under him moving in the opposite directions.

; Fixed the problem with a BNE instead of a BPL. I've also 
; cleaned up the VBLANK routine so hopefully it will now
; run on Eckard's beastie too. 

; --SEXP0002.ASM---------------------------------------------------------------

        processor 6502

VSYNC   =       $00
VBLANK  =       $01
WSYNC   =       $02
;NUSIZ0 =       $04
;NUSIZ1 =       $05
COLUPF  =       $08
COLUBK  =       $09
PF0     =       $0D
PF1     =       $0E
PF2     =       $0F
;SWCHA  =       $280
INTIM   =       $284
TIM64T  =       $296
;CTRLPF =       $0A
COLUP0  =       $06
COLUP1  =       $07
GP0     =       $1B
GP1     =       $1C
;HMOVE  =       $2a
RESP0   =       $10
RESP1   =       $11

;RAM

HPOS1   =       $80
HPOS2   =       $81
SPRITE1 =       $82
SPRITE2 =       $8A
DELAY   =       $92
MTOGGLE =       $93

        org  $F000

start   SEI
        CLD
        LDX  #$FF
        TXS
        LDA  #$00

zero    STA  $00,X      ;looks familiar, right?
        DEX             ;typical zeroing routine
        BNE  zero

        lda  #$96       ;Just setting crap up.
        sta  COLUP0
        lda  #$38
        sta  COLUP1

        lda  #$04
        sta  COLUBK

        lda  #$00       ;starting position for each sprite
        sta  HPOS1
        lda  #$0D
        sta  HPOS2

main    JSR  vertb      ;main loop
        ldy  #$07
        JSR  sprite
        JSR  draw
        JSR  clear
        JMP  main

vertb   LDA  #$02       ;vertical blank    
        STA  VSYNC      ; routine changed per Eckhard Stolberg's suggestions
        STA  WSYNC         
        STA  WSYNC        
        STA  WSYNC
        LDA  #$00        
        STA  VSYNC
        LDA  #$2C
        STA  TIM64T 
        RTS        

sprite  lda  sprt1,y    ;just loading the sprite data into RAM
        sta  SPRITE1,y  ;it'll make it easier when I animate them
        dey
        bpl  sprite

        ldy  #$07
spritb  lda  sprt2,y
        sta  SPRITE2,y
        dey
        bpl  spritb
        rts

draw    LDA  INTIM      ;check to see if it's time to draw a frame
        BNE  draw
        sta  WSYNC
        sta  VBLANK     ;I don't see anything unusual here.
        sta  WSYNC

;insert  display kernal

        LDY  HPOS1      ;pretty darn simple kernal. According to my
pos1    dey             ;math it should be 192 scanlines on the bean
        bpl  pos1
        sta  RESP0
        sta  WSYNC

        ldy  #$07

sl1     lda  SPRITE1,y
        sta  GP0
        sta  WSYNC
        dey
        bpl  sl1
        lda  #$00
        sta  GP0
        sta  WSYNC


        ldy  HPOS2
pos2    dey
        bpl  pos2
        sta  RESP1
        sta  WSYNC

        ldy  #$07

sl2     lda  SPRITE2,y
        sta  GP1
        sta  WSYNC
        dey
        bpl  sl2

        lda  #$00
        sta  GP1
        sta  WSYNC

        ldx  #$ab
blow    sta  WSYNC
        dex
        bne  blow       ; changed bpl to bne per Chris Wilkson's suggestions 
        rts

clear   LDA  #$24       ;set timer for overscan
        STA  TIM64T
        LDA  #$02       ;clear the screen and turn off the video
        STA  WSYNC
        STA  VBLANK
        LDA  #$00
        STA  PF0
        STA  PF1
        STA  PF2
        sta  COLUPF
        sta  COLUBK     ;just my standard clearing routine.

        dec  DELAY
        bpl  oscan
        lda  #$0F
        sta  DELAY
        lda  MTOGGLE
        cmp  #$01
        beq  rightb
        inc  HPOS1
        lda  HPOS1
        cmp  #$0D
        bpl  righta
        jmp  oscan

righta  lda  #$01
        sta  MTOGGLE

rightb  dec HPOS1
        lda HPOS1
        cmp #$02
        bmi lefta
        jmp oscan

lefta   lda #$00
        sta MTOGGLE      ;all that just takes care of the movement

oscan   sec
        lda #$0D
        sbc HPOS1
        sta HPOS2

oscana  lda INTIM        ;ordinary overscan stuff.
        bne oscana
        sta WSYNC
        rts

sprt1   .byte  %01100110    ;sprite data
        .byte  %00100100
        .byte  %00111100
        .byte  %00011000
        .byte  %00011000
        .byte  %11111111
        .byte  %00111100
        .byte  %00111100

sprt2   .byte  %10101010
        .byte  %10101010
        .byte  %11111111
        .byte  %11111111
        .byte  %10111011
        .byte  %10011001
        .byte  %01111110
        .byte  %00111100

        org $FFFC
        .word start
        .word start

; -----------------------------------------------------------------------------

;                                CRACKERS
;                       (What the.... from hell!!!!!)

; Accordionist - Wethifl Musician - Atari 2600 Collector | /\/\
; *NEW CrAB URL* http://www.hwcn.org/~ad329/crab.html ***| \^^/
; Bira Bira Devotee - FES Member - Samurai Pizza Cats Fan| =\/=

;      ______________________________________________
;      «¤»¥«¤»§«¤»¥«¤»§«¤»¥«¤»§«¤»¥«¤»§«¤»¥«¤»§«¤»¥«¤
;      ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
;	Source code unearthed at:
;
;	The Dig! - Stella Archive Excavation
;	http://www.neonghost.com/the-dig/index.html
;      ______________________________________________
;      «¤»¥«¤»§«¤»¥«¤»§«¤»¥«¤»§«¤»¥«¤»§«¤»¥«¤»§«¤»¥«¤
;      ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
