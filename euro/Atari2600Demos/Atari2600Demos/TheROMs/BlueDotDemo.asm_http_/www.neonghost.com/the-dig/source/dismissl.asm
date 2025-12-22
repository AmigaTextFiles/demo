;  ------------------------------------------------------------------------
;   * Subject: [stella] Distella --> DAsm problem
;   * From: Ruffin Bailey <rufbo@bellsouth.net>
;   * Date: Fri, 21 Aug 98 13:55:03 -0000
;  ------------------------------------------------------------------------

; See original message post for details
;   http://www.biglist.com/lists/stella/archives/9808/msg00065.html


; Disassembly of missile.bin aka How to move a missile around your screen.
; Disassembled Sat Aug 15 11:32:54 1998
; Using DiStella v2.0 on a Mac, no less!
;
; Command Line: distella -pafs missile.bin
;

      processor 6502
VSYNC   =  $00
VBLANK  =  $01
WSYNC   =  $02
COLUP0  =  $06
COLUP1  =  $07
COLUPF  =  $08
COLUBK  =  $09
CTRLPF  =  $0A
PF0     =  $0D
PF1     =  $0E
GRP0    =  $1B
GRP1    =  $1C
ENAM0   =  $1D
ENAM1   =  $1E
ENABL   =  $1F
HMM0    =  $22
HMOVE   =  $2A
CXCLR   =  $2C
SWCHA   =  $0280
INTIM   =  $0284
TIM64T  =  $0296

       ORG $F000

START:
       SEI            ;2
       CLD            ;2
       LDA    #$20    ;2
       STA    $80     ;3
       LDX    #$FF    ;2
       TXS            ;2
       LDA    #$00    ;2
LF00B: STA    VSYNC,X ;4
       DEX            ;2
       BNE    LF00B   ;2
       JSR    LF0D8   ;6
LF013: JSR    LF025   ;6
       JSR    LF03F   ;6
       JSR    LF044   ;6
       JSR    LF07D   ;6
       JSR    LF0D0   ;6
       JMP    LF013   ;3
LF025: LDX    #$00    ;2
       LDA    #$02    ;2
       STA    WSYNC   ;3
       STA    WSYNC   ;3
       STA    WSYNC   ;3
       STA    VSYNC   ;3
       STA    WSYNC   ;3
       STA    WSYNC   ;3
       LDA    #$2C    ;2
       STA    TIM64T  ;4
       STA    WSYNC   ;3
       STA    VSYNC   ;3
       RTS            ;6

LF03F: LDA    #$00    ;2
       STA    COLUBK  ;3
       RTS            ;6

LF044: LDA    #$88    ;2  setting up the colors
       STA    COLUP0  ;3  P0 is blue
       LDA    #$36    ;2
       STA    COLUPF  ;3  PF redish (won't see that here, though)
       LDA    #$D8    ;2
       STA    COLUP1  ;3  P1 yellow (Sir Not Pictured in this film)
       LDA    #$00    ;2
       STA    COLUBK  ;3  BK black
       LDA    #$00    ;2
       STA    CTRLPF  ;3
       LDA    #$00    ;2
       STA    HMM0    ;3
       LDA    SWCHA   ;4  SWCHA dissection
       BMI    LF065   ;2  Player 0       | Player 1
       LDY    #$F0    ;2  ===============|===============
       STY    HMM0    ;3  D7  D6  D5  D4 | D3  D2  D1  D0
LF065: ROL            ;2  rt  lt  dn  up | rt  lt  dn  up
       BMI    LF06C   ;2
       LDY    #$10    ;2  I'm using BMI to read D7 of SWCHA
       STY    HMM0    ;3  (which has been read into the accumulator)
LF06C: ROL            ;2  Then rolling the byte to the left and reading the
       BMI    LF073   ;2  next bit (D6,5,4...) with BMI since the next
       INC    $80     ;5  bit would now be D7.
       INC    $80     ;5
LF073: ROL            ;2  $80 holds the scan line that the missile
       BMI    LF07A   ;2  will appear on, and since I'm counting up from 1
       DEC    $80     ;5  in the screen drawing loop, I decrease $80 to move
       DEC    $80     ;5  the missile up and increase $80 to go down.
LF07A: STA    CXCLR   ;3
       RTS            ;6  I assume the HMM0 commands are self-explanatory!  ;)

LF07D: LDA    INTIM   ;4  Here's the screen draw routine.
       BNE    LF07D   ;2
       STA    WSYNC   ;3
       STA    VBLANK  ;3
       LDA    #$02    ;2
       STA    CTRLPF  ;3
       LDX    #$01    ;2
       STA    HMOVE   ;3 DON'T FORGET TO HIT HMOVE!! or the object won't move
LF08E: STA    WSYNC   ;3 horizontally.  I might have forgotten that for a while...
       INX            ;2 causing nearly unbearable psychological pain.
       BEQ    LF0B7   ;2
       CPX    $80     ;3
       BEQ    LF09A   ;2
       JMP    LF08E   ;3
LF09A: LDA    #$02    ;2
       STA    ENAM0   ;3 Turn the missile on by putting %00000010 into
       STA    WSYNC   ;3 ENAM0
       INX            ;2
       CPX    #$C1    ;2
       BEQ    LF0B7   ;2
       STA    WSYNC   ;3
       INX            ;2
       CPX    #$C1    ;2
       BEQ    LF0B7   ;2
       LDA    #$00    ;2
       STA    ENAM0   ;3 Turn it off by putting zero into ENAM0.  Here, the missile
       STA    WSYNC   ;3 is two scans tall.  Cute little bugger.
LF0B2: INX            ;2
       CPX    #$C1    ;2
       BNE    LF0B2   ;2
LF0B7: LDA    #$02    ;2
       STA    WSYNC   ;3
       STA    VBLANK  ;3
       LDY    #$00    ;2
       STY    PF0     ;3
       STY    PF1     ;3
       STY    PF1     ;3
       STY    GRP0    ;3
       STY    GRP1    ;3
       STY    ENAM0   ;3
       STY    ENAM1   ;3
       STY    ENABL   ;3
       RTS            ;6

LF0D0: LDX    #$1E    ;2
LF0D2: STA    WSYNC   ;3
       DEX            ;2
       BNE    LF0D2   ;2
       RTS            ;6

LF0D8: LDA    #$00    ;2
       STA    $90     ;3
       RTS            ;6

        org $FFFC
        .word START
        .word START