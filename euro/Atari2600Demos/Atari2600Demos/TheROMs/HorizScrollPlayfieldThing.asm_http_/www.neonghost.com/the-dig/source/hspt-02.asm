;  ------------------------------------------------------------------------
;   * Subject: [stella] What I did on my winter vacation
;   * From: Rob <kudla@pobox.com>
;   * Date: Mon, 03 Jan 2000 01:35:47 -0500
;  ------------------------------------------------------------------------

; http://www.biglist.com/lists/stella/archives/0001/msg00012.html

; Horizontally Scrolling Playfield Thing
; Started 22 December 1999
; by Rob Kudla
; First post 22 December 1999: Implemented simple horizontally scrolling playfield.
; Second post 3 January 2000: Implemented split screen with faked perspective.
;                             Player 1 can steer.  Very bad sync problems.
; http://www.kudla.org/raindog/games

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
PF0Data1 = $86
PF1Data1 = $87
PF2Data1 = $88
PF0Data2 = $89
PF1Data2 = $8a
PF2Data2 = $8b
PFDirection = $8c
RLEPtr = $8d
; RLEPtr+1 = $8e
RLEXORing = $8f
RLEXORing1 = $90
RLEXORing2 = $91
PFDirection1 = $92

CurrentXORData = $BF  ; 40 bytes actually starting at $C0

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
                INC     CurrentFrame    ; general all purpose frame counter

                JSR NewScreen
                JSR DrawScreen
                JSR Overscan ; including joystick and animate routines
                JMP MainLoop

InitGame:       ; used to set playfield colors but we do that in the screen draw now
                LDA     PFData
                STA     PF0Data1
                STA     PF0Data2
                LDA     PFData+1
                STA     PF1Data1
                STA     PF1Data2
                LDA     PFData+2
                STA     PF2Data1   ; set up initial playfield
                STA     PF2Data2   ; set up initial playfield player 2
                LDA     #$00
                STA     RLEPtr
                LDA     #$FF
                STA     RLEPtr+1
;                JSR     GetXORData
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

                LDA     CurrentFrame
                AND     #$01
                BNE     EndAnimate      ; only animate every other frame

                LDA     #$00
                STA     PFCarry         ; start assuming we don't carry

                LDA     PFDirection
                AND     #$80
                BNE     DoRotateLeft   ; joystick right = rotate view left

                LDA     PFDirection
                AND     #$40
                BEQ     EndAnimate
DoRotateRight:
                JSR     RotateRight
                JMP     EndAnimate
DoRotateLeft:
                JSR     RotateLeft

EndAnimate:
;                JSR     GetXORData

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

; first group - player 1 sky

                LDY     #$28            ; let's do 40 lines of this
                LDA     #$8a            ; a nice sky blue
                STA     COLUPF
                STA     COLUBK

Scanline1:
                STA     WSYNC
                DEY
                BNE     Scanline1

; second group - player 1 ground

                LDA     #$a4      ; a nice shade of green
                STA     COLUPF
                LDA     #$be      ; sort of a yellowish green
                STA     COLUBK
                LDY     #$28            ; let's do 40 lines of this

Scanline2:

                ; now that that's out of the way see what else needs to be done
                LDA     PF0Data
                EOR     CurrentXORData-1,Y
                AND     #$F0
                STA     PF0Data         ; reverse PF0 if necessary
                LDA     PF1Data
                EOR     CurrentXORData-1,Y
                STA     PF1Data         ; reverse PF1 if necessary
                LDA     PF2Data
                EOR     CurrentXORData-1,Y
                STA     PF2Data         ; reverse PF2 if necessary

                STA     WSYNC
                LDA     PF0Data
                STA     PF0
                LDA     PF1Data
                STA     PF1
                LDA     PF2Data
                STA     PF2

                DEY
                BNE     Scanline2

; third group - vblank for now
                LDA     #02
                STA     WSYNC
                STA     VBLANK

                ; get player 2 playfield
                LDA PF0Data2
                STA PF0Data
                STA PF0
                LDA PF1Data2
                STA PF1Data
                STA PF1
                LDA PF2Data2
                STA PF2Data
                STA PF2

                LDY     #$20            ; need 32 lines of vblank
Scanline3:
                STA     WSYNC
                DEY
                BNE     Scanline3
                LDA     #$00
                STA     VBLANK

; fourth group - player 2 sky

                LDY     #$28            ; let's do 40 lines of this
                LDA     #$8a            ; a nice sky blue
                STA     COLUPF
                STA     COLUBK

Scanline4:
                STA     WSYNC
                DEY
                BNE     Scanline4

; fifth group - player 2 ground

                LDA     #$a4      ; a nice shade of green
                STA     COLUPF
                LDA     #$be      ; sort of a yellowish green
                STA     COLUBK
                LDY     #$28            ; let's do 40 lines of this

Scanline5:

                ; now that that's out of the way see what else needs to be done
                LDA     PF0Data
                EOR     CurrentXORData-1,Y
                AND     #$F0
                STA     PF0Data         ; reverse PF0 if necessary
                LDA     PF1Data
                EOR     CurrentXORData-1,Y
                STA     PF1Data         ; reverse PF1 if necessary
                LDA     PF2Data
                EOR     CurrentXORData-1,Y
                STA     PF2Data         ; reverse PF2 if necessary

                STA     WSYNC
                LDA     PF0Data
                STA     PF0
                LDA     PF1Data
                STA     PF1
                LDA     PF2Data
                STA     PF2

                DEY
                BNE     Scanline5

; ok, now the real vblank

                LDA     #$02
                STA     WSYNC           ; skip rest of current scanline
                STA     WSYNC           ; and another because we're only doing 190
                STA     VBLANK          ; turn VBLANK back on
                JMP     SkipReverse     ; right now it doesn't end up reversed

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

SkipReverse:
                RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Overscan
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Overscan:

                ; animate player 2 playfield
                LDA CurrentFrame
                BMI Move2Right
                LDA #$80
                JMP SetUpAnimate2
Move2Right:
                LDA #$40
SetUpAnimate2:
                STA PFDirection
                LDA CurrentFrame
                LSR
                LSR
                LSR
                AND #$07
                ORA PFDirection
                STA PFDirection
                LDA PF0Data2
                STA PF0Data
                LDA PF1Data2
                STA PF1Data
                LDA PF2Data2
                STA PF2Data
                LDA RLEXORing2
                STA RLEXORing
                JSR Animate
                LDA PF0Data
                STA PF0Data2
                LDA PF1Data
                STA PF1Data2
                LDA PF2Data
                STA PF2Data2
                LDA RLEXORing
                STA RLEXORing2

                LDA PFDirection1
                AND #$0F
                STA PFDirection

                ; read joystick 1
                LDA SWCHA
                AND #J0_Right
                BNE Move1Left
                LDA #$80
                ORA PFDirection
                STA PFDirection
                JMP CheckVertical1
Move1Left:
                LDA SWCHA
                AND #J0_Left
                BNE CheckVertical1
                LDA #$40
                ORA PFDirection
                STA PFDirection

CheckVertical1:
                LDA CurrentFrame
                AND #$07
                BNE SetUpAnimate1
Move1Up:
                LDA SWCHA
                AND #J0_Up
                BNE Move1Down
                LDA PFDirection
                TAY
                LDA PFDirection
                AND #$F0
                STA PFDirection
                INY
                TYA
                AND #$0F
                ORA PFDirection
                STA PFDirection
                JMP SetUpAnimate1
Move1Down:
                LDA SWCHA
                AND #J0_Down
                BNE SetUpAnimate1
                LDA PFDirection
                TAY
                LDA PFDirection
                AND #$F0
                STA PFDirection
                DEY
                TYA
                AND #$0F
                ORA PFDirection
                STA PFDirection

SetUpAnimate1:
                ; animate player 1 playfield
;                LDA CurrentFrame
;                EOR #$FF
;                STA PFDirection
                LDA PF0Data1
                STA PF0Data
                LDA PF1Data1
                STA PF1Data
                LDA PF2Data1
                STA PF2Data
                LDA RLEXORing1
                STA RLEXORing
                JSR     GetRLEData
                JSR Animate
                LDA PF0Data
                STA PF0Data1
                STA PF0
                LDA PF1Data
                STA PF1Data1
                STA PF1
                LDA PF2Data
                STA PF2Data1
                STA PF2
                LDA RLEXORing
                STA RLEXORing1
                LDA PFDirection
                STA PFDirection1

; and waste the rest of the lines - not that there are any right now due to bad coding....
Wastage:

                LDY     #$0a
SkipLine:       STA     WSYNC
                DEY
                BNE     SkipLine
                RTS

; GetXORData

GetXORData:
                ; to be made less stupid later
                LDY     #$27

XORLoop:
                LDA     XORData,Y
                STA     CurrentXORData,Y
                DEY
                BNE     XORLoop
                LDA     XORData,Y
                STA     CurrentXORData,Y
                RTS

; GetRLEData - to replace GetXORData

GetRLEData:
                LDA PFDirection
                ASL
                ASL
                ASL
                ASL
                AND #$70
                STA RLEPtr
                LDY #$00

                LDA RLEXORing
                BEQ RLELoop
                LDA #$00
                STA RLEXORing
                LDA PF0Data
                EOR #$FF
                AND #$F0
                STA PF0Data
                LDA PF1Data
                EOR #$FF
                STA PF1Data
                LDA PF2Data
                EOR #$FF
                STA PF2Data
; the following is a kludge, should not be in final code
                LDA PF0Data2
                EOR #$FF
                AND #$F0
                STA PF0Data2
                LDA PF1Data2
                EOR #$FF
                STA PF1Data2
                LDA PF2Data2
                EOR #$FF
                STA PF2Data2
RLELoop:
                LDX #$00
                LDA (RLEPtr,X)
                AND #$7F
                BEQ RLEDone
                TAX
RLESubLoop:
                DEX
                BEQ RLESubDone
                LDA #$00
                STA CurrentXORData,Y
                INY
                JMP RLESubLoop
RLESubDone:
                LDA #$FF
                STA CurrentXORData,Y
                INY
                INC RLEPtr
                JMP RLELoop

RLEDone:
                LDX #$00
                LDA (RLEPtr,X)
                AND #$80
                BEQ RLEExit
                LDA #$01
                STA RLEXORing
                LDA PF0Data
                EOR #$FF
                AND #$F0
                STA PF0Data
                LDA PF1Data
                EOR #$FF
                STA PF1Data
                LDA PF2Data
                EOR #$FF
                STA PF2Data
; the following is a kludge, should not be in final code
                LDA PF0Data2
                EOR #$FF
                AND #$F0
                STA PF0Data2
                LDA PF1Data2
                EOR #$FF
                STA PF1Data2
                LDA PF2Data2
                EOR #$FF
                STA PF2Data2
RLEExit:
                RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                ORG     $FE00
PFData:

                .byte $f0,$83,$07 ; we'll get fancier later

                ORG     $FE80

XORData:

; frame 1
                 .byte $00,$00,$00,$00,$00,$00,$00,$00
                 .byte $00,$00,$00,$00,$00,$00,$00,$FF
                 .byte $00,$00,$00,$00,$00,$00,$00,$FF
                 .byte $00,$00,$00,$00,$FF,$00,$00,$FF
                 .byte $00,$00,$FF,$00,$FF,$00,$FF,$FF

                ORG     $FF00

RLEData:

; frame 1
                 .byte $10,$09,$05,$03,$03,$02,$02,$01
                 .byte $00,$00,$00,$00,$00,$00,$00,$00
; frame 2
                 .byte $0d,$09,$07,$04,$03,$03,$02,$01
                 .byte $80,$00,$00,$00,$00,$00,$00,$00
; frame 3
                 .byte $09,$0a,$08,$04,$04,$03,$02,$01
                 .byte $00,$00,$00,$00,$00,$00,$00,$00
; frame 4
                 .byte $04,$0d,$09,$04,$04,$03,$02,$01
                 .byte $80,$00,$00,$00,$00,$00,$00,$00
; frame 5
                 .byte $10,$09,$05,$03,$03,$02,$02,$01
                 .byte $80,$00,$00,$00,$00,$00,$00,$00
; frame 6
                 .byte $0d,$09,$07,$04,$03,$03,$02,$01
                 .byte $00,$00,$00,$00,$00,$00,$00,$00
; frame 7
                 .byte $09,$0a,$08,$04,$04,$03,$02,$01
                 .byte $80,$00,$00,$00,$00,$00,$00,$00
; frame 8
                 .byte $04,$0d,$09,$04,$04,$03,$02,$01
                 .byte $00,$00,$00,$00,$00,$00,$00,$00

; x = each byte in above table
; write x-1 00's into xor table
; then write an FF
; repeat until X && 7f = 0
; then if bit 7 is set
; set a "start off xored" bit yet to be defined

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Vectors
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                ORG     $FFFC
Reset           .word   Init2600
IRQ             .word   Init2600

;               END

; notes to self
; divide screen into regions
; first - player 1 sky/goalposts/ball/earth (outside playfield)
; second - player 1 playfield - regions 1 plus 2 = about 80 scanlines
; third - few lines of VBLANK if necessary to set up score display
; fourth - score display (using asymmetric playfield graphics) - probably 24 lines
; fifth - few more lines of VBLANK if necessary for player 2
; sixth - player 2 sky etc.
; seventh - player 2 playfield - regions 6 plus 7 = about 80 scanlines

; simulating a horizon
; make eight possible views like Boing but instead of sprites the views determine
; which scanlines to do the XOR on
; may have to use 40 bytes and just say that's how many lines we can draw each playfield in
; so at each scanline we do LDA PFData then EOR XORData,X then STA PFData
; for each of the three playfields (with the usual AND for PF0)
; load player 2's view in the vblank after the score display

; probably need variables indicating where to switch from sky to playfield
; or even sky to goalposts
; and where are we drawing players in all of this.... hmm


;  ------------------------------------------------------------------------
; kudla@pobox.com ... http://kudla.org/raindog ... Rob
;  ------------------------------------------------------------------------
