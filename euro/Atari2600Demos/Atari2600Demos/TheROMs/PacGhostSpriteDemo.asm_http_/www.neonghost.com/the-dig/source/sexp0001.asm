;  ------------------------------------------------------------------------

;   * Subject: [stella] Arrrg, Arrrg, and Double Arrrg!!!
;   * From: Chris Cracknell <crackers@hwcn.org>
;  * Date: Wed, 15 Apr 1998 01:15:10 -0400 (EDT)

;  ------------------------------------------------------------------------

; Here's what the programme is supposed to do...

; Dark grey background.
; Blue Stickman at top of the screen moving back and forth.
; Red Ghost under him moving in the opposite directions.

; That's it, no fancy multisprite stuff.

; Here's what I'm getting on a real 2600.

; Three copies of each sprite spread out vertically across the screen
; and black lines dividing the screen into 3rds.

; The sprites all do what I want them to, it's just that there's too damn
; many of them. And I don't know where these black lines are coming from.

; The image is very stable and the VBLANK and OVERSCAN are just knabbed from
; some other programmes of mine that work like a charm.

; I can't see anything in the screen kernal that could possibly cause this odd
; behaviour so either my 2600 or supercharger have gone wonky on me, or
; there's some really odd bug I just can't see. Here's the source code.
; Now it's a little speghetti right now because I was just sort of doing
; "stream of consciousness programming"...

; --SEXP0001.ASM---------------------------------------------------------------

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

vertb   LDX  #$00       ;vertical blank, We all know what this is about
        LDA  #$02
        STA  WSYNC
        STA  WSYNC
        STA  WSYNC      ;I don't see anything any different here from
        STA  VSYNC      ;any other VBLANK routine I've done.
        STA  WSYNC
        STA  WSYNC
        LDA  #$2C
        STA  TIM64T
        LDA  #$00
        STA  WSYNC
        STA  VSYNC
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
        bpl  blow
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

; Tiy would think if it were some sort of missed bit sync problem the picture
; wouldn't be stable at all. I'm totally boggled here. All my other homebrews
; still work okay.

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
