;---------------------------------------------------------------------------

;   * Subject: [stella] MultiSpriteDemo update (source+binary)
;   * From: Piero Cavina <p.cavina@mo.nettuno.it>
;   * Date: Thu, 3 Apr 1997 21:15:00 +0200 (METDST)

;---------------------------------------------------------------------------

; Here's my latest demo debugged and updated. I've put comments in the most
; interesting parts of the code.
; I'm going to write a new game based on this code, so please ask before using
; this for yours...

; PCMSD11.ASM
; Atari 2600 MultiSprite Demo 1.1
; (c)1987 Piero Cavina
; NTSC version

      processor 6502
VSYNC   =  $00
VBLANK  =  $01
WSYNC   =  $02
NUSIZ0  =  $04
NUSIZ1  =  $05
COLUP0  =  $06
COLUP1  =  $07
COLUPF  =  $08
COLUBK  =  $09
REFP0   =  $0B
PF0     =  $0D
PF1     =  $0E
PF2     =  $0F
RESP0   =  $10
RESP1   =  $11
RESM1   =  $13
RESBL   =  $14
AUDC0   =  $15
AUDF0   =  $17
AUDV0   =  $19
GRP0    =  $1B
GRP1    =  $1C
ENABL   =  $1F
HMP0    =  $20
HMP1    =  $21
HMM1    =  $23
HMBL    =  $24
HMOVE   =  $2A
HMCLR   =  $2B
CXCLR   =  $2C
SWCHA   =  $0280
SWACNT  =  $0281
SWCHB   =  $0282
SWBCNT  =  $0283
INTIM   =  $0284
TIM64T  =  $0296
CXPPMM  =  $7

NUMGRP    =  11
GRPHEIGHT =  7
XMIN      =  8
XMAX      =  150

GRPCOUNT  =  $80
TEMP      =  GRPCOUNT+1
FC_XPOS   =  TEMP+4
XPOS      =  FC_XPOS+NUMGRP
XMOT      =  XPOS+NUMGRP
GRPY      =  XMOT+NUMGRP
PLYPOS    =  GRPY+1
NXTGRPY   =  PLYPOS+1
PLYMOT    =  NXTGRPY+1
PLXPOS    =  PLYMOT+1
FC_PLXPOS =  PLXPOS+1
PLXMOT    =  FC_PLXPOS+1
COLL      =  PLXMOT+1
NOCC      =  COLL+NUMGRP
FRAMEC    =  NOCC+1
PLGRD     =  FRAMEC+1
PLOFF     =  PLGRD+1

       ORG $F000

START:
       SEI
       CLD
       LDX    #$28
       LDA    #$00
LF006: STA    NUSIZ0,X
       DEX
       BPL    LF006
       LDX    #$FF
LF00D: STA    VSYNC,X
       DEX
       BMI    LF00D
       LDX    #$FF
       TXS
       STA    SWBCNT
       STA    SWACNT

       LDA    #$FF
       STA    COLUP0

; Initialize objects positions and motion

       LDX    #NUMGRP-1
INILP:
       TXA
       ASL
       ASL
       ASL
       CLC
       ADC    #10
       STA    XPOS,X
       TXA
       LSR
       CLC
       ADC    #1
       STA    XMOT,X
       DEX
       BPL    INILP

; Player initialization

       LDA    #40
       STA    PLXPOS
       LDA    #1
       STA    PLXMOT
       LDA    #10
       STA    PLYPOS
       LDA    #1
       STA    PLYMOT

; Here's 'game logic'. Don't waste too much time on that, as it's just
; standard 6502 programming. Go to "kernel" for more interesting things...

MAIN:  INC    FRAMEC            ; Count frames...
       LDX    #0                ; Do Vsync, start Vblank...
       LDA    #$02
       STA    WSYNC
       STA    VSYNC
       STA    WSYNC
       STA    WSYNC
       STA    WSYNC
       STX    VSYNC
       STA    WSYNC
       STA    VBLANK

       LDA    #$2C
       STA    TIM64T

; Move objects horizontally, handle collisions

       LDX    #NUMGRP-1
MOVLP: LDA    XPOS,X
       CLC
       ADC    XMOT,X
       STA    XPOS,X
       CMP    #XMIN
       BCC    SWPX0
       CMP    #XMAX
       BCS    SWAPX
       JMP    OKMV
SWPX0: LDA    #XMIN
       SEC
       SBC    XPOS,X
       CLC
       ADC    #XMIN
       STA    XPOS,X
SWAPX: LDA    XMOT,X
       EOR    #$FF
       CLC
       ADC    #1
       STA    XMOT,X
OKMV:  LDA    XPOS,X
       JSR    CNV
       STA    FC_XPOS,X

       LDA    NOCC
       BNE    NOCL

       LDA    COLL,X
       BPL    NOCL1

       LDA    XMOT,X
       EOR    PLXMOT
       BMI    DOSW
       LDA    XMOT,X
       STA    PLXMOT
       JMP    NOTSW

DOSW:  LDA    PLXMOT
       EOR    #$FF
       CLC
       ADC    #1
       STA    PLXMOT


NOTSW: LDA    #64
       STA    NOCC
NOCL:  DEC    NOCC
NOCL1: LDA    #0
       STA    COLL,X
       DEX
       BPL    MOVLP

; Player0 vertical motion

       LDA    PLYPOS
       CLC
       ADC    PLYMOT
       STA    PLYPOS
       CMP    #6
       BCC    SWAPPLYM
       CMP    #[[1+GRPHEIGHT]*NUMGRP]-12
       BCS    SWAPPLYM
       JMP    OKPLYM
SWAPPLYM:
       LDA    PLYMOT
       EOR    #$FF
       CLC
       ADC    #1
       STA    PLYMOT

; Player0 horizontal motion

OKPLYM:
       LDA    PLXPOS
       CLC
       ADC    PLXMOT
       STA    PLXPOS
       CMP    #25
       BCS    OKX0
       LDA    #25
       STA    PLXPOS
       JMP    SWAPPLXM
OKX0:  CMP    #154
       BCC    OKPLXM
       LDA    #154
       STA    PLXPOS
SWAPPLXM:
       LDA    PLXMOT
       EOR    #$FF
       CLC
       ADC    #1
       STA    PLXMOT
OKPLXM:

       LDA    PLXPOS            ; Convert Player0 X position
       JSR    CNV               ; to FC format.
       STA    FC_PLXPOS

       STA    WSYNC             ; Prepare to position Player0
       STA    HMP0              ; remember, we're still doing Vblank now
       AND    #$0F
       TAY
PLPSL: DEY
       BPL    PLPSL
       STA    RESP0
       STA    WSYNC
       STA    HMOVE

       LDA    #0
       STA    GRPCOUNT          ; Initialize group counter
       STA    GRPY              ; First line of first group
       LDA    #GRPHEIGHT+1
       STA    NXTGRPY           ; First line of next (second) group
       LDA    PLYPOS
       STA    PLGRD

LF20C: LDA    INTIM             ; Finish Vblank
       BNE    LF20C
       STA    WSYNC
       STA    VBLANK
       STA    HMCLR

; We're going to draw #NUMGRP groups, each made of:
; 2 scanlines for Player1 positioning with Player0, plus
; #GRPHEIGHT*2 scanlines with Player1 and Player0.

KERNEL:
       LDA    PLGRD             ; Distance between Player0<->top of group
       CMP    #GRPHEIGHT+1      ; Is Player0 inside current group?
       BCC    DOPL              ; Yes, we'll draw it...
       LDX    #0                ; No, draw instead a
       BEQ    GOPL              ; blank sprite.
DOPL:  LDA    NXTGRPY           ; We must draw Player0, and we'll start
       SEC                      ; from the (NXTGRPY-PLYPOS)th byte.
       SBC    PLYPOS
       TAX                      ; Put the index to the first byte into X
GOPL:  STX    PLOFF             ; and remember it.

       LDY    GRPCOUNT          ; Store any collision between Player0 and
       LDA    CXPPMM            ; Player1 happened while drawing the
       ORA    COLL,Y            ; last group.
       STA    COLL,Y

       LDA    FC_XPOS,Y         ; Get Player1 position
       LDY    PLPTN,X           ; Get Player0 pattern

       LDX    #0
       STA    WSYNC             ; Start with a new scanline.
       STY    GRP0              ; Set Player0 pattern
       STX    GRP1              ; Blank Player1 pattern to avoid 'bleeding'
       STA    HMP1              ; Prepare Player1 fine motion
       AND    #$0F              ; Prepare Player1 coarse positioning
       TAY
POSLP: DEY                      ; Waste time
       BPL    POSLP
       STA    RESP1             ; Position Player1

       STA    WSYNC             ; Wait for next scanline
       STA    HMOVE             ; Apply fine motion

; Now prepare various things for the next group

       LDA    NXTGRPY           ; Updade this group and next group
       STA    GRPY              ; top line numbers
       CLC
       ADC    #GRPHEIGHT+1
       STA    NXTGRPY

       LDA    PLYPOS            ; Find out which 'slice'
       SEC                      ; of Player0 we'll have to draw.
       SBC    GRPY              ; We need the distance of Player0
       BPL    DPOS              ; from the top of the group.
       EOR    #$FF              ;
       CLC
       ADC    #1                ; A = ABS(PLYPOS-GRPY)
DPOS:  STA    PLGRD             ;

       LDX    PLOFF             ; Pointer to the next byte of Player0
       INX                      ; pattern. Use X while drawing the group

       LDA    #0                ; Clear collisions
       STA    CXCLR

       LDY    #GRPHEIGHT-1      ; Initialize line counter (going backwards)
GRPLP:
       TYA                      ; Find the shade of Player1 color
       ASL                      ; to be used in the next line
       ORA    #$40
       STA    TEMP              ; ...and remember it.

       LDA    #$51
       STA    WSYNC             ; Wait for a new line
       STA    COLUBK            ; Set background color
       LDA    PLPTN,X
       STA    GRP0              ; Set Player0 shape
       LDA    GRPPTN,Y
       STA    GRP1              ; Set Player1 shape
       LDA    TEMP
       STA    COLUP1            ; Set Player1 color

       STA    WSYNC             ; Wait for a new scanline

       INX                      ; Update the index to next byte of Player0
       DEY                      ; Decrement line counter
       BPL    GRPLP             ; Go on with this group if needed

       INC    GRPCOUNT          ; Increment current group number
       LDA    GRPCOUNT          ;
       CMP    #NUMGRP           ; Is there another group to do?
       BCS    OUTKERNEL         ; No, exit
       JMP    KERNEL            ; Yes, go back. (Using JMP because a branch
                                ; would be out of range).

OUTKERNEL:
       STA    WSYNC             ; Finish current scanline
       LDA    #0                ; Avoid bleeding of Player1
       STA    GRP1
       LDA    #$C0              ; How many scanlines are missing...?
       SEC
       SBC    #[1+GRPHEIGHT]*2*NUMGRP+2  ; It's clear, isn't it?
       TAY
FILLER:
       STA    WSYNC
       DEY
       BNE    FILLER            ; draw them.

       LDA    #$02              ; Overscan
       STA    WSYNC
       STA    VBLANK
       LDA    #$1D
       TAY
LF305: STA    WSYNC
       DEY
       BNE    LF305
       JMP    MAIN              ; Go back for another frame

GRPPTN: .byte %00111100         ;  Pattern for Player1
        .byte %01111110
        .byte %11111111
        .byte %11111111
        .byte %11111111
        .byte %01111110
        .byte %00111100

PLPTN:  .BYTE $00               ; Pattern for Player0. Please note
        .BYTE $00               ; the leading and trailing 0's
        .BYTE $00
        .BYTE $00
        .BYTE $00
        .BYTE $00
        .BYTE $00
        .BYTE $00
        .BYTE $00
        .BYTE %01111110
        .BYTE %11111111
        .BYTE %11111111
        .BYTE %11111111
        .BYTE %11111111
        .BYTE %11111111
        .BYTE %01111110
        .BYTE $00
        .BYTE $00
        .BYTE $00
        .BYTE $00
        .BYTE $00
        .BYTE $00
        .BYTE $00

; Straight from "Air sea battle", here's the routine
; to convert from standard X positions to FC positions.
; Could a good man explain me how it works?

CNV:   STA    TEMP+1
       BPL    LF34B
       CMP    #$9E
       BCC    LF34B
       LDA    #$00
       STA    TEMP+1
LF34B: LSR
       LSR
       LSR
       LSR
       TAY
       LDA    TEMP+1
       AND    #$0F
       STY    TEMP+1
       CLC
       ADC    TEMP+1
       CMP    #$0F
       BCC    LF360
       SBC    #$0F
       INY
LF360: CMP    #$08
       EOR    #$0F
       BCS    LF369
       ADC    #$01
       DEY
LF369: INY
       ASL
       ASL
       ASL
       ASL
       STA    TEMP+1
       TYA
       ORA    TEMP+1
       RTS

       ORG $FFFA

   .byte $00,$F0,$00,$F0,$00,$F0
