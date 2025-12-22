;---------------------------------------------------------------------------

;   * Subject: [stella] Christmas program
;   * From: Piero Cavina <p.cavina@mo.nettuno.it>
;   * Date: Thu, 25 Dec 1997 23:28:47 +0100
;   * Reply-To: stella@biglist.com

;---------------------------------------------------------------------------

; chrdem01.asm

; Piero Cavina's "it's Christmas and I can't leave my 2600 alone demo v 0.1"
; 25/12/1997

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
CTRLPF  =  $0A
REFP0   =  $0B
REFP1   =  $0C
PF0     =  $0D
PF1     =  $0E
PF2     =  $0F
RESP0   =  $10
RESP1   =  $11
RESM0   =  $12
RESM1   =  $13
RESBL   =  $14
AUDC0   =  $15
AUDF0   =  $17
AUDV0   =  $19
AUDC1   =  $16
AUDF1   =  $18
AUDV1   =  $1A
GRP0    =  $1B
GRP1    =  $1C
ENAM0   =  $1D
ENAM1   =  $1E
ENABL   =  $1F
HMP0    =  $20
HMP1    =  $21
HMM0    =  $22
HMM1    =  $23
HMBL    =  $24
RESMP0  =  $28
RESMP1  =  $29
HMOVE   =  $2A
HMCLR   =  $2B
CXCLR   =  $2C
CXM0P   =  $30
CXP1FB  =  $33
SWCHA   =  $0280
SWACNT  =  $0281
SWCHB   =  $0282
SWBCNT  =  $0283
INTIM   =  $0284
TIM8T   =  $0295
TIM64T  =  $0296
CXPPMM  =  $7
INPT0   =  $8
INPT3   =  $A
INPT4   =  $3C

COUNT   =  $80

       ORG    $F000

       CLD
       LDX    #$FF
       TXS
       INX
       TXA
LPC:   STA    VSYNC,X
       INX
       BNE    LPC

       STA    SWBCNT
       STA    SWACNT

MAIN:
       LDX    #0
       LDA    #$02
       STA    WSYNC
       STA    WSYNC
       STA    WSYNC
       STA    VSYNC
       STA    WSYNC
       STA    WSYNC
       STA    WSYNC
       STX    VSYNC

; -------------------------

       LDA    #$35
       STA    TIM64T

; -------------------------

       STA    WSYNC
       LDX    #7
LPP:
       DEX
       BPL    LPP
       STA    RESM1
       STA    RESM0

; -------------------------

; Finisici il tempo di Vblank

LF20C: LDA    INTIM
       BNE    LF20C
       STA    WSYNC
       STA    VBLANK
       STA    HMCLR

; -------------------------

; Kernel
       LDA    #$FF
       STA    ENAM1
       STA    ENAM0
       INC    COUNT

; try to uncomment these lines..
;       LDA    COUNT
;       STA    NUSIZ0
;       STA    NUSIZ1

       LDX    #191
LK:
       TXA
       ADC    COUNT
       ASL
       ASL
       STA    HMM1
       EOR    #$FF
       STA    HMM0
       STA    COLUP1
       STA    COLUP0
       STA    WSYNC

       STA    HMOVE
       DEX
       BNE    LK

; -------------------------

       STX    ENAM1
       STX    ENAM0

       STA    WSYNC
       LDA    #$02
       STA    WSYNC
       STA    VBLANK

; -------------------------

       LDA    #$2A
       STA    TIM64T

; ------------------------

OVRS:
       LDA    INTIM
       BNE    OVRS
       JMP    MAIN

     ORG $FFFC

   .byte $00,$F0,$00,$F0
