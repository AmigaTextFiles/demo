;  ------------------------------------------------------------------------

;   * Subject: Re: About SHIPS.ASM (was: Re: [stella] Jim's heart
;   * From: Piero Cavina <p.cavina@mo.nettuno.it>
;   * Date: Wed, 17 Jun 1998 16:36:36 +0200

;  ------------------------------------------------------------------------

; See original message post for details
; http://www.biglist.com/lists/stella/archives/9806/msg00088.html


; The Lifeboat game.
; by Kurt Woloch. Started on June 10th, 1997
;                                         |
; Wow, did it take one year? ;-) ---------|
; Modified by Piero Cavina June 17h 1998

; Based on the Game&Watch "Lifeboat" by Nintendo.
; I came onto the idea to write this game when I saw that the game mentioned
; above was sold for $81 at eBay.
; Further pushing of this game idea occured through the film "Titanic".
; I was considering earlier to write a sound demo playing "My heart will go
; on" on the 2600.
; Finally, this game is dedicated to Jim who passed away on June 4th, as far
; as I know. I'm afraid he won't be around anymore to optimize this code,
; but I'll do my best to make it attractive in spite of that.
; His heart will go on in all of us...
;
; The objective of this game is to save as many ship-wrecked persons as you
; can by moving around with the lifeboat. The shipwrecked persons appear
; on the ship and jump down to land on the lifeboat, while the ship is
; slowly sinking - as the Titanic did way back then.
; Now, there's only room for four people maximum in the boat. To empty it
; again, you have to move it to the left or right of the screen, where your
; passengers will jump out of the boat, onto land. Now I know this has
; nothing to do with the Titanic, where there was no water around, but who
; cares...
;
; This game is based on the demo How to Draw A Playfield
; by Nick Bensema  9:23PM  3/2/97, but I don't know how much of this remained
; intact.
;
; OK, let's go to the code itself now. Sorry for my heavy commenting, which
; I know has been offended before on Stellalist, but if you don't want to
; read that, just skip it, or close the file!
;
; OK, now for the programming flow. Usually, it goes like this:
;
; Clear memory and registers
; Set up variables
; Loop:
;    Do the vertical blank
;    Do game calculations
;    Draw screen
;    Do more calculations during overscan
;    Wait for next vertical blank
; End Loop.
;
; This source code is for compiling with DASM. Frankly, I don't care about
; any other compilers...
;
        processor 6502
        include vcs.h

; The vhs.h file here is a bit special. In fact, I didn't take this one
; anywhere from the list, but took the equates from a listing Distella
; generated...

        org $F000

; OK, so this means the code starts at $F000, although in fact the first
; digit is more or less regardless, since I won't refer to any memory
; locations in the ROM by their address, but only by label.

; Now, here come the equates for the variables I use by now:

SinkCount  = $80  ;This counts the frames until the ship goes down again by
                  ;one line.

SinkLevel  = $81  ;This counts the lines remaining from the ship display.

;At this time, I haven't got any men in here. I'll change that sometime...

Temp       = $82
SoundCount = $83
DecayCount = $84
PlayfieldY = $90

SinkLinesL = $85
SinkLinesH = $86

;Now, some equates for colors. Since I plan to do a PAL version of this,
; they should be easy to alter.

White = $07
Red   = $43
Pink  = $47
Yellow = $17
Brown = $20
Skyblue = $96
Waterblue = $84
Shadowblue = $90

Start

; Now, we set up the CPU.

        SEI  ; Disable interrupts, if there are any.
        CLD  ; Clear BCD math bit.
        LDX  #$FF
        TXS  ; Set stack to beginning.

; Clear up the whole memory
; Since X is already loaded to 0xFF, our task becomes simply to count
; everything off.
;
        LDA #0
INCLR1  STA 0,X
        DEX
        BNE INCLR1

; The above routine does not clear location 0, which is VSYNC.  We will
; take care of that later.
;
; At this point in the code we would set up things like the data
; direction registers for the joysticks and such.
; In fact, I don't have the joystick in here yet. There's much more to
; come...
;
        JSR  GameInit
;
; Here is a representation of our program flow.
;
MainLoop
        JSR  VerticalBlank ;Execute the vertical blank.
        JSR  CheckSwitches ;Check console switches.
        JSR  GameCalc      ;Do calculations during Vblank
        JSR  DrawScreen    ;Draw the screen
        JSR  OverScan      ;Do more calculations during overscan
        JMP  MainLoop      ;Continue forever.
;
; It is important to maintain a stable screen, and this routine
; does some important and mysterious things.  Actually, the only
; mysterious part is VSYNC.  All VBLANK does is blank the TIA's
; output so that no graphics are drawn; otherwise the screen
; scans normally.  It is VSYNC which tells the TV to pack its
; bags and move to the other corner of the screen.
;
; Fortunately, Nick's program sets VBLANK at the beginning of the
; overscan period, which usually precedes this subroutine, so
; it is not changed here - and I kept that here.
;
VerticalBlank
        LDX  #0
        LDA  #2
        STA  WSYNC
        STA  WSYNC
        STA  WSYNC
        STA  VSYNC ;Begin vertical sync.
        STA  WSYNC ; First line of VSYNC
        STA  WSYNC ; Second line of VSYNC.
;
; But before we finish off the third line of VSYNC, why don't we
; use this time to set the timer?  This will save us a few cycles
; which would be more useful in the overscan area.
;
; To insure that we begin to draw the screen at the proper time,
; we must set the timer to go off just slightly before the end of
; the vertical blank space, so that we can WSYNC up to the ACTUAL
; end of the vertical blank space.  Of course, the scanline we're
; going to omit is the same scanline we were about to waste VSYNCing,
; so it all evens out.
;
; Atari says we have to have 37 scanlines of VBLANK time.  Since
; each scanline uses 76 cycles, that makes 37*76=2888 cycles.
; We must also subtract the five cycles it will take to set the
; timer, and the three cycles it will take to STA WSYNC to the next
; line.  Plus the checking loop is only accurate to six cycles, making
; a total of fourteen cycles we have to waste.  2888-14=2876.
; Aaargh, oops! Of course Nick's calculation is wrong here.
; 2888-14 is, of course, 2874. But who cares?
;
;
; We almost always use TIM64T for this, since the math just won't
; work out with the other intervals.  2880/64=44.something.
;
        LDA  #44
        STA  TIM64T
;
; And now's as good a time as any to clear the collision latches.
;
        LDA #0
        STA CXCLR
;
; Now we can end the VSYNC period.
;
        STA  WSYNC ; Third line of VSYNC.
        STA  VSYNC ; (0)
;
; At this point in time the screen is scanning normally, but
; the TIA's output is suppressed.  It will begin again once
; 0 is written back into VBLANK.
;
        RTS
;
; Checking the game switches is relatively simple.  Theoretically,
; some of it could be slipped between WSYNCs in the VBlank code.
; But we're going for clarity here.
;
; Here, we check for the reset switch. Also, we set the background color,
; though this is a bit dirty, but who cares... Nick did it here too.
;
CheckSwitches
       LDA SWCHB
       AND #1
       BNE NoReset
       JSR GameInit
NoReset
       LDA #Skyblue
       STA COLUBK  ; Background will be cyan.
       RTS
;
; Minimal game calculations, just to get the ball rolling.
;
GameCalc
;
; OK, here we do the sinking. We'll decrease the sink count until it's 0,
; then we'll decrease the value that's left for the ship scanlines.

        DEC SinkCount
        BNE NoSinkNow
        LDA #50
        STA SinkCount
        DEC SinkLevel
        BNE NoSinkNow
        LDA #112 ; ship-only height
        STA SinkLevel
NoSinkNow

;Now we took care for making the ship sink, we play a little tune in here.
; What will James Horner think about this? If he ever hears THAT...

;Here we reduce the decay by 1. If it's zero, we pull everything back up,
; start the next note and increase the note counter.

        DEC DecayCount
        BNE DecayNotZero

;If the current note holds 0, no new note is set.

        LDX SoundCount
        LDA Sound0Freq,X
        BEQ NoNote0
        STA AUDF0
NoNote0
        LDA Sound1Freq,X
        BEQ NoNote1
        STA AUDF1
NoNote1
        LDA #16
        STA DecayCount
        LDA #15
        STA AUDV0
        STA AUDV1
        INC SoundCount
        RTS

;Now we take care of decay. The old note decays one beat before the new
; note is played, so we set the volume only if we don't encounter a zero
; in the current note, which means the note will be held.
; Note that this happens only if no new notes were set.

DecayNotZero
        LDX SoundCount
        LDA Sound0Freq,X
        BEQ NoDecay0
        LDA DecayCount
        STA AUDV0
NoDecay0
        LDA Sound1Freq,X
        BEQ NoDecay1
        LDA DecayCount
        STA AUDV1

NoDecay1
        RTS
;
; DrawScreen first waits for the timer, then for the next scanline.
;
DrawScreen
        LDA INTIM
        BNE DrawScreen ; Whew!
        STA WSYNC
        STA VBLANK  ;End the VBLANK period with a zero.
;
; Now the actual playfield is drawn. As stated earlier, I use a reflected
; playfield here. Unlike Nick, I don't set the "score" bit here. In fact,
; I haven't seen much games where this is used.
;
        LDA  #1       ;Set the reflected playfield.
        STA  CTRLPF

; Now, in principle, the first eight scanlines should contain a 6-digit
; score counter, but I didn't include that here.
; So at the moment, when the ship is fully visible, there are 48 empty
; scanlines above it. This is reflected by the graphics data, containing
; 48 empty blocks. That's wasting 48 ROM bytes! Well, maybe I can improve on
; this...
; However, as the ship is sinking, we'll have to draw additional scanlines.
; We do this as follows: We put the remaining visible scanlines to X.
; Then we compare X to 164 (the total scanline number we do until the
; bottom of the ship) and do some WSYNC's until it's equal.

        LDA  #160 ;ship+sky height
        SEC
        SBC  SinkLevel
        TAX
SinkingLines
        STA WSYNC
        DEX
        BNE SinkingLines
SinkingDone

; Initialize some display variables.
; Now we can start to draw the ship itself.
; For this purpose, we load the current ship line into y.
; Then we increment y every line until we reached the maximum lines.

        LDA SinkLevel
        AND #%00000011
        STA SinkLinesL
        LDA SinkLevel
        LSR
        LSR
        STA SinkLinesH
        BEQ DoneShip

        LDY #0 ;We start at the first line
ShipLoop
        STA WSYNC

        LDA Forecolor,Y
        STA COLUPF
        LDA PF1Graphics,Y
        STA PF1
        LDA PF2Graphics,Y
        STA PF2

        STA WSYNC

        STA WSYNC

        STA WSYNC

        INY
        CPY SinkLinesH
        BNE ShipLoop

DoneShip

        LDA SinkCount
        LSR
        ORA #Waterblue
        STA COLUPF
        STA COLUBK
        TAY

        LDX SinkLinesL
        DEX
        BMI DoneShip1

        STA WSYNC
        DEY
        DEY
        STY COLUPF
        STY COLUBK

        DEX
        BMI DoneShip1

        STA WSYNC
        DEY
        DEY
        STY COLUPF
        STY COLUBK

        DEX
        BMI DoneShip1

        STA WSYNC
        DEY
        DEY
        STY COLUPF
        STY COLUBK


DoneShip1

; Now, we have to draw the water, so we set the foreground to blue
; and do another 36 scanlines. (Did I count that right?)

        STA WSYNC
        LDA #Shadowblue
        STA COLUPF
        LDA #Waterblue
        STA COLUBK
        LDY #37
waterloop1
        STA WSYNC
        DEY
        BNE waterloop1

;
; Clear all registers here to prevent any possible bleeding.
;
        LDA #2
        STA WSYNC  ;Finish this scanline.
        STA VBLANK ; Make TIA output invisible,
        ; Now we need to worry about it bleeding when we turn
        ; the TIA output back on.
        ; Y is still zero.
        STY COLUBK
        STY PF0
        STY PF1
        STY PF2
        STY GRP0
        STY GRP1
        STY ENAM0
        STY ENAM1
        STY ENABL
        RTS

;
; For the Overscan routine, one might take the time to process such
; things as collisions.  I, however, would rather waste a bunch of
; scanlines, since I haven't drawn any players yet.
;
OverScan   ;We've got 30 scanlines to kill.
        LDX #30
KillLines
         STA WSYNC
         DEX
         BNE KillLines
        RTS

;
; GameInit could conceivably be called when the Select key is pressed,
; or some other event.
; Well, here's a little flaw. I'd rather put this at the BEGINNING of the
; code, but I'll leave it here for now. At the moment, this is only called
; when powering up the system (or starting the emulator).
; Here we'll set the ship to its full height (not sunk yet) and the sinking
; counter to its normal value.
;
GameInit
        LDA #112      ;Full ship height is 116 scanlines+at least 48 above.
                      ;                    ^^^ 112?
        STA SinkLevel
        LDA #50       ;Ship goes down one scanline every 50 frames.
        STA SinkCount
        LDA #14       ;Bring audio volume near maximum
        STA AUDV0
        STA AUDV1
        LDA #12       ;Store distortion value 12 for Channel 0 (vocal)
        STA AUDC0
        LDA #1        ;and value 1 for Channel 1 (bass). Sorry I couldn't
        STA AUDC1     ;do the other instruments, but the 2600 only has got
        LDA #16       ;2 channels!
        STA DecayCount ;Do another note every 16 frames.
        RTS

        org $FD00

; This is the sound data.
; Data for Channel 1 (Distortion 12 - Vocal voice)
; A 0 means that the note is held on...

Sound0Freq
   .byte 16,0,0,16,16,0,16,0,17,0,16,0,0,0,16,0 ;Every night in my dreams, I
   .byte 17,0,16,0,0,0,14,0,12,0,0,0,14,0,0,0 ;see you, I feel you.
   .byte 16,0,0,16,16,0,16,0,17,0,16,0,0,0,14,0 ;That is how I know you go
   .byte 22,0,0,0,0,0,0,0,0,0,0,0,24,22,19,17 ;on.
   .byte 16,0,0,16,16,0,16,0,17,0,16,0,0,0,16,0 ;Far across the distance, and
   .byte 17,0,16,0,0,0,14,0,12,0,0,0,14,0,0,0 ;spaces between us,
   .byte 16,0,0,16,16,0,16,0,17,0,16,0,0,0,14,0 ;you have come to show you go
   .byte 22,0,0,0,0,0,0,0,0,0,0,0,24,22,19,17 ;on.
   .byte 16,0,0,0,0,0,0,0,14,0,0,0,0,0,22,0 ;Near, far, where
   .byte 10,0,0,0,11,0,12,14,14,0,0,0,12,0,11,0 ;ever you are, I be-
   .byte 12,0,0,0,14,0,16,0,17,0,16,0,0,0,17,0 ;lieve that the heart does go
   .byte 19,0,0,0,19,0,0,0,19,0,0,0,24,22,19,17 ;on.
   .byte 16,0,0,0,0,0,0,0,14,0,0,0,0,0,22,0 ;Once more, you
   .byte 10,0,0,0,11,0,12,14,14,0,0,0,12,0,11,0 ;open the door, and you're
   .byte 12,0,0,0,14,0,16,0,17,0,16,0,0,0,16,0 ;here in my heart and my
   .byte 17,0,16,0,0,0,14,0,12,0,0,0,14,0,0,0 ;heart will go on and...

;And now, the bass line (Distortion: 1)

Sound1Freq
   .byte 13,0,0,17,13,0,0,0,17,0,0,23,17,0,0,0
   .byte 19,0,0,27,19,0,0,0,17,0,0,23,17,0,0,0
   .byte 13,0,0,17,13,0,0,0,17,0,0,23,17,0,0,0
   .byte 19,0,0,27,19,0,0,27,19,0,0,27,19,0,17,0
   .byte 13,0,0,17,13,0,0,0,17,0,0,23,17,0,0,0
   .byte 19,0,0,27,19,0,0,0,17,0,0,23,17,0,0,0
   .byte 13,0,0,17,13,0,0,0,17,0,0,23,17,0,0,0
   .byte 19,0,0,27,19,0,0,27,19,0,0,27,19,0,17,0
   .byte 15,0,0,20,15,0,0,0,17,0,0,23,17,0,0,0
   .byte 19,0,0,27,19,0,0,0,17,0,0,23,17,0,17,0
   .byte 15,0,0,20,15,0,15,0,17,0,0,23,17,0,17,0
   .byte 19,0,0,27,19,0,0,27,19,0,0,27,19,0,17,0
   .byte 15,0,0,20,15,0,0,0,17,0,0,23,17,0,0,0
   .byte 19,0,0,27,19,0,0,0,17,0,0,23,17,0,17,0
   .byte 15,0,0,20,15,0,15,0,17,0,0,23,17,0,17,0
   .byte 19,0,0,27,19,0,19,0,17,0,0,23,17,0,17,0
;
; Graphics are placed so that the extra cycle in the PFData,X indexes
; is NEVER taken, by making sure it never has to index across a page
; boundary.  This way our cycle count holds true.
;

        org $FF00
;
; This is the tricky part of drawing a playfield: actually
; drawing it.  Well, the display routine and all that binary
; math was a bit tricky, too, but still, listen up.
;
; By the way, this game works with a REFLECTED playfield.
;
; In PF0 and PF2, the most significant bit (bit 7) is on the RIGHT
; side.  In PF1, the most significant bit is on the LEFT side.  This
; means that relative to PF0 and PF2, PF1 has a reversed bit order.
;
;    PF0  |     PF1       |      PF2
;  4 5 6 7|7 6 5 4 3 2 1 0|0 1 2 3 4 5 6 7

;PFData0  ;       4 5 6 7
;       .byte $00,$f0,$00,$A0,$A0,$E0,$A0,$A0
;PFData1  ;      7 6 5 4 3 2 1 0

PF1Graphics
       .byte $00,$00,$00,$03,$03,$13,$13,$1F
       .byte $1F,$1F,$1F,$7F,$7F,$7F,$7F,$5B
       .byte $7F,$7F,$7F,$2B,$3F,$3F,$3F,$15
       .byte $1F,$1F,$1F,$0F

;PFData2  ;      0 1 2 3 4 5 6 7

PF2Graphics
       .byte $80,$80,$80,$C0,$C0,$C3,$F3,$F3
       .byte $F3,$FF,$FF,$FF,$FF,$FF,$FF,$B6
       .byte $FF,$FF,$FF,$B6,$FF,$FF,$FF,$B6
       .byte $FF,$FF,$FF,$FF

;       .byte $00,$FF,$00,$EE,$A2,$A2,$A2,$E2

;PFLColor ; Ship color stripes

Forecolor
       .byte $07,$07,$07,$43,$43,$47,$47,$47
       .byte $17,$17,$17,$43,$07,$43,$20,$20
       .byte $20,$20,$20,$20,$20,$20,$20,$20
       .byte $20,$20,$20,$20

;PFRColor ; Background color stripes (every 8 scanlines!)
;       .byte $80,$80,$80,$80,$80,$80,$80,$80
;       .byte $80,$81,$82,$83,$84,$85,$86,$87
;       .byte $77,$76,$75,$74,$73,$72,$71,$70
;       .byte $70,$70,$70,$70,$70,$70,$70,$70

        org $FFFC
        .word Start
        .word Start