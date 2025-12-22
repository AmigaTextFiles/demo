;---------------------------------------------------------------------------

;   * Subject: [stella] How to detect that joystick button is pressed
;   * From: "Eric BACHER" <ebacher@hotmail.com>
;   * Date: Mon, 27 Oct 1997 23:05:27 PST

;---------------------------------------------------------------------------

	processor 6502
	include vcs.h

    org $F000
Start
    SEI
    CLD
    LDX #$FF
    TXS
    LDA #0
B1  STA 0,X
    DEX
    BNE B1

MainLoop
    JSR VerticalBlank
    JSR GameCalc
    JSR DrawScreen
    JSR OverScan
    JMP MainLoop

VerticalBlank
    LDA #2
    STA WSYNC
    STA WSYNC
    STA WSYNC
    STA VSYNC
    STA WSYNC
    STA WSYNC
    LDA #44
    STA TIM64T
    LDA #0
    STA WSYNC
    STA VSYNC
    RTS

GameCalc
    LDA #0
    STA COLUBK

    LDA INPT4    
    BMI NoButton ; see Jim Nitchals follow-up post

    LDA #$88
    STA COLUBK
NoButton
    LDA #$55
    STA PF0
    STA PF2
    ASL
    STA PF1
    LDA #1
    STA CTRLPF
    RTS

DrawScreen
    LDA INTIM
    BNE DrawScreen
    STA WSYNC
    STA VBLANK
    LDY #192
ScanLoop
    STY COLUPF
    STA WSYNC
    DEY
    BNE ScanLoop
    RTS

OverScan
    LDX #30
KillLines
    STA WSYNC
    DEX
    BNE KillLines
    RTS

    org $FFFC
    .word Start
    .word Start

