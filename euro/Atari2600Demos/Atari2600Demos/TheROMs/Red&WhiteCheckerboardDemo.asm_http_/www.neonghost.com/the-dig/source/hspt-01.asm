;  ------------------------------------------------------------------------
;   * Subject: [stella] Ho ho ho #2 (horizontal scrolling playfield thing)
;   * From: Rob <kudla@pobox.com>
;   * Date: Wed, 22 Dec 1999 23:59:46 -0500
;  ------------------------------------------------------------------------

; http://www.biglist.com/lists/stella/archives/199912/msg00005.html


; Horizontally Scrolling Playfield Thing
; Started 22 December 1999
; by Rob Kudla

                processor 6502

; equates from vcs.h since it took me so long to find one that worked

;
; VCS system equates
;
; Vertical blank registers
;
VSYNC   =  $00
VS_Enable = 2
VBLANK  =  $01
VB_Enable      = 2
VB_Disable     = 0
VB_LatchEnable = 64
VB_LatchDisable = 0
VB_DumpPots    = 128
WSYNC   =  $02
RSYNC   =  $03
;
; Size registers for players and missiles
;
NUSIZ0  =  $04
NUSIZ1  =  $05
P_Single      = 0
P_TwoClose    = 1
P_TwoMedium   = 2
P_ThreeClose  = 3
P_TwoFar      = 4
P_Double      = 5
P_ThreeMedium = 6
P_Quad        = 7
M_Single      = $00
M_Double      = $10
M_Quad        = $20
M_Oct         = $40

;
; Color registers
;
COLUP0  =  $06
COLUP1  =  $07
COLUPF  =  $08
COLUBK  =  $09

;
; Playfield Control
;
CTRLPF  =  $0A
PF_Reflect  = $01
PF_Score    = $02
PF_Priority = $04
REFP0   =  $0B
REFP1   =  $0C
P_Reflect = $08
PF0     =  $0D
PF1     =  $0E
PF2     =  $0F
RESP0   =  $10
RESP1   =  $11
AUDC0   =  $15
AUDC1   =  $16
AUDF0   =  $17
AUDF1   =  $18
AUDV0   =  $19
AUDV1   =  $1A  ;duh

;
; Players
;
GRP0    =  $1B
GRP1    =  $1C

;
; Single-bit objects
;
ENAM0   =  $1D
ENAM1   =  $1E
ENABL   =  $1F
M_Enable = 2
HMP0    =  $20
HMP1    =  $21

; Miscellaneous
VDELP0  =  $25
VDEL01  =  $26
VDELP1  =  $26
VDELBL  =  $27
RESMP0  =  $28
RESMP1  =  $29
HMOVE   =  $2A
HMCLR   =  $2B
CXCLR   =  $2C
CXM0P   =  $30
CXM1P   =  $31
CXP0FB  =  $32
CXP1FB  =  $33
CXM0FB  =  $34
CXM1FB  =  $35
CXBLPF  =  $36
CXPPMM  =  $37
INPT0   =  $38
INPT1   =  $39
INPT2   =  $3A
INPT3   =  $3B
INPT4   =  $3C
INPT5   =  $3D

;
; Switch A equates.
;
SWCHA   =  $0280
J0_Right = $80
J0_Left  = $40
J0_Down  = $20
J0_Up    = $10
J1_Right = $08
J1_Left  = $04
J1_Down  = $02
J1_up    = $01
;
; Switch B equates
;
SWCHB   =  $0282
P0_Diff = $80
P1_Diff = $40
Con_Color  = $08
Con_Select = $02
Con_Start  = $01

;
; Timer
;
INTIM   =  $0284
TIM1T   =  $0294
TIM8T   =  $0295
TIM64T  =  $0296
TIM1024T = $0297

; local equates
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CurrentFrame = $80
CurrentPFPtr = $81
PF0Data = $82
PF1Data = $83
PF2Data = $84
PFCarry = $85

; and away we go
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                ORG     $F000

Init2600:
                SEI                             ; Disable interrupts.
                CLD                             ; Clear BCD mode.
                LDX     #$FF
                TXS                             ; Clear the stack.

                LDA     #$00
ClearZeroPage:
                STA     $00,X
                DEX
                BNE     ClearZeroPage           ; clear zero page except for VSYNC

                JSR InitGame

MainLoop:
                JSR NewScreen
                JSR DrawScreen
                JSR Animate
                JSR Overscan
                JMP MainLoop

InitGame:       LDA     #$36      ; a nice shade of red
                STA     COLUPF
                LDA     #$0f
                STA     COLUBK
                LDA     PFData
                STA     PF0Data
                LDA     PFData+1
                STA     PF1Data
                LDA     PFData+2
                STA     PF2Data   ; set up initial playfield
                RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; NewScreen
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

NewScreen:
                LDA     #$02
                STA     WSYNC           ; Wait for horizontal sync
                STA     VBLANK          ; Turn on VBLANK
                STA     VSYNC           ; Turn on VSYNC
                STA     WSYNC           ; Skip 3 lines
                STA     WSYNC
                STA     WSYNC
                LDA     #$00
                STA     VSYNC           ; Turn VSYNC off

                LDA     #$2C            ; 37 lines of VBLANK
                STA     TIM64T          ; 44 * 64 = 2816 (need 2876 cycles of vblank)

                RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Animate
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Animate:
                INC     CurrentFrame    ; general all purpose frame counter

                LDA     CurrentFrame
                AND     #$01
                BNE     EndAnimate      ; only animate every other frame

                LDA     #$00
                STA     PFCarry         ; start assuming we don't carry

                LDA     CurrentFrame
                BMI     DoRotateRight   ; switch directions every 4 seconds or so
DoRotateLeft:
                JSR     RotateLeft
                JMP     EndAnimate
DoRotateRight:
                JSR     RotateRight

EndAnimate:
                RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; RotateLeft
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

RotateLeft:
                LDA     PF0Data
                LSR                     ; rotate PF0 to left
                TAY
                AND     #$08
                BNE     LCarry0          ; did we lose a bit?
                JMP     LNoCarry0        ; if not, skip this next
LCarry0:
                LDA     PFCarry
                ORA     #$01            ; turn on bit 0 of PFCarry
                STA     PFCarry
LNoCarry0:
                TYA
                AND     #$F0
                STA     PF0Data

                LDA     PF1Data
                CLC
                ASL                     ; rotate PF1 to left
                BCS     LCarry1
                JMP     LNoCarry1
LCarry1:
                TAY
                LDA     PFCarry
                ORA     #$02            ; turn on bit 1 of PFCarry
                STA     PFCarry
                TYA
LNoCarry1:
                STA     PF1Data

                LDA     PF2Data
                CLC
                LSR                     ; rotate PF2 to left
                BCS     LCarry2
                JMP     LNoCarry2
LCarry2:
                TAY
                LDA     PFCarry
                ORA     #$04            ; turn on bit 2 of PFCarry
                STA     PFCarry
                TYA
LNoCarry2:
                STA     PF2Data

                LDA     PFCarry
                AND     #$02            ; mask out all but carry bit 1 (from PF1Data)
                ASL
                ASL
                ASL
                ASL
                ASL
                ASL
                ORA     PF0Data         ; add in bits from PF0Data
                STA     PF0Data         ; and put back in PF0Data

                LDA     PFCarry
                AND     #$04            ; mask out all but carry bit 2 (from PF2Data)
                LSR
                LSR
                ORA     PF1Data
                STA     PF1Data         ; put into PF1Data

                LDA     PFCarry
                AND     #$01            ; mask out all but carry bit 0 (from PF0Data)
                ASL
                ASL
                ASL
                ASL
                ASL
                ASL
                ASL
                ORA     PF2Data
                STA     PF2Data         ; put into PF2Data
                RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; RotateRight
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

RotateRight:
                LDA     PF0Data
                CLC
                ASL                     ; rotate PF0 to right
                BCS     RCarry0         ; did we lose a bit?
                JMP     RNoCarry0       ; if not, skip this next
RCarry0:
                TAY
                LDA     PFCarry
                ORA     #$01            ; turn on bit 0 of PFCarry
                STA     PFCarry
                TYA
RNoCarry0:
                AND     #$F0
                STA     PF0Data

                LDA     PF1Data
                CLC
                LSR                     ; rotate PF1 to left
                BCS     RCarry1
                JMP     RNoCarry1
RCarry1:
                TAY
                LDA     PFCarry
                ORA     #$02            ; turn on bit 1 of PFCarry
                STA     PFCarry
                TYA
RNoCarry1:
                STA     PF1Data

                LDA     PF2Data
                CLC
                ASL                     ; rotate PF2 to left
                BCS     RCarry2
                JMP     RNoCarry2
RCarry2:
                TAY
                LDA     PFCarry
                ORA     #$04            ; turn on bit 2 of PFCarry
                STA     PFCarry
                TYA
RNoCarry2:
                STA     PF2Data

                LDA     PFCarry
                AND     #$04            ; mask out all but carry bit 2 (from PF2Data)
                ASL                     ; need to set bit 4 of PF0
                ASL
                ORA     PF0Data         ; add in bits from PF0Data
                STA     PF0Data         ; and put back in PF0Data

                LDA     PFCarry
                AND     #$01            ; mask out all but carry bit 0 (from PF0Data)
                ASL                     ; need to set bit 7 of PF1
                ASL
                ASL
                ASL
                ASL
                ASL
                ASL
                ORA     PF1Data
                STA     PF1Data         ; put into PF1Data

                LDA     PFCarry
                AND     #$02            ; mask out all but carry bit 1 (from PF1Data)
                LSR                     ; need to set bit 0 of PF2
                ORA     PF2Data
                STA     PF2Data         ; put into PF2Data
                RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; DrawScreen
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DrawScreen:

                LDA     INTIM
                BNE     DrawScreen      ; wait till vblank is done
                STA     WSYNC           ; skip rest of current scanline
                STA     VBLANK          ; turn off vblank

                LDA     #$00
                STA     CTRLPF          ; set up playfield (repeat, not reflect)

                LDY     #$BE            ; let's do 190 lines of this

Scanline:
                STA     WSYNC
                LDA     PF0Data
                STA     PF0
                LDA     PF1Data
                STA     PF1
                LDA     PF2Data
                STA     PF2

                ; now that that's out of the way see what else needs to be done
                TYA
                AND     #$1F            ; XOR every 32nd line
                BNE     DontXOR
                LDA     PF0Data
                EOR     #$FF
                AND     #$F0
                STA     PF0Data         ; reverse PF0
                LDA     PF1Data
                EOR     #$FF
                STA     PF1Data         ; reverse PF1
                LDA     PF2Data
                EOR     #$FF
                STA     PF2Data         ; reverse PF2

DontXOR:
                DEY
                BNE     Scanline

                LDA     PF0Data

                LDA     #$02
                STA     WSYNC           ; skip rest of current scanline
                STA     WSYNC           ; and another because we're only doing 190
                STA     VBLANK          ; turn VBLANK back on

                ; always ends up reversed - put back
                LDA     PF0Data
                EOR     #$FF
                AND     #$F0
                STA     PF0Data         ; reverse PF0
                LDA     PF1Data
                EOR     #$FF
                STA     PF1Data         ; reverse PF1
                LDA     PF2Data
                EOR     #$FF
                STA     PF2Data         ; reverse PF2

                RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Overscan
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Overscan:
                LDY     #$1E
SkipLine:       STA     WSYNC
                DEY
                BNE     SkipLine
                RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                ORG     $FF00
PFData:

                .byte $f0,$83,$07 ; we'll get fancier later

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Vectors
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                ORG     $FFFC
Reset           .word   Init2600
IRQ             .word   Init2600

;               END

; kudla@pobox.com ... http://kudla.org/raindog ... Rob

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
