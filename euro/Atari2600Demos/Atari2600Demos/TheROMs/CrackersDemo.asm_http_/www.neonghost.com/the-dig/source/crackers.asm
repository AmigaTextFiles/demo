;---------------------------------------------------------------------------

;   * Subject: [stella] Crackers' Easy Playfield Graphics Code
;   * From: crackers@freenet.hamilton.on.ca
;   * Date: Sat, 8 Mar 1997 15:33:43 -0500 (EST)

;---------------------------------------------------------------------------

        processor 6502

VSYNC   =  $00       ;this tells assembler what
VBLANK  =  $01       ;the locations of all those funky
WSYNC   =  $02       ;2600 codes are
COLUPF  =  $08       ;
COLUBK  =  $09       ;you can see that this demo doesn't really do
CTRLPF  =  $0A       ;much.
PF0     =  $0D       ;
PF1     =  $0E       ;I had also made some stupid 5:00 in the morning
PF2     =  $0F       ;errors here that wouldn't let my first attempt
CXCLR   =  $2C       ;compile. Make sure you are well rested before you
INTIM   =  $284      ;attempt to programme the Atari 2600 or you risk
TIM64T  =  $296      ;losing your sanity.

        org  $F000

start   SEI            ;setting up the 6507
        CLD
        LDX  #$FF
        TXS
        LDA  #$00

zero    STA  $00,X     ;zeroing out all the locations
        DEX
        BNE  zero

main    JSR  vertb      ;this is the main loop of the programme
        JSR  scrnvar    ;starts with vertical blank then loads the screen
        JSR  draw       ;variables then draws the screen, then does the
        JSR  oscan      ;overscan, then does it all over and over again
        JMP  main       ;until you terminate the programme.

scrnvar LDA  #$00        ;make the playfield graphics black
        STA  COLUPF
        LDA  #$4F        ;make the background pink
        STA  COLUBK
        LDA  #$01        ;reflect the left half of the playfield on the
        STA  CTRLPF      ;right
        RTS

vertb   LDX  #$00         ;thank you Nick Bensema for teaching us all
        LDA  #$02         ;how to do a vertical blank.
        STA  WSYNC        ;who knows if I could have figured out this one
        STA  WSYNC        ;on my own. I want to have your baby!
        STA  WSYNC
        STA  VSYNC        ;<- here was one of my 5:00 in the morning errors.
        STA  WSYNC        ;I had typed WSYNC instead of VSYNC. Bleary eyes
        STA  WSYNC        ;and programming make a deadly combination!
        LDA  #$2C
        STA  TIM64T       ;much like cheese burgers an loneliness.
        LDA  #$00
        STA  CXCLR        ;<- don't know why I left this in... but what the
        STA  WSYNC        ;heck it looks cute.
        STA  VSYNC        ;**********CHANGED CODE FROM ORIGINAL**************
        RTS               ;had made another stupid 5am error. (STA WSYNC)

draw    LDA  INTIM         ;getting ready to draw the screen
        BNE  draw
        STA  WSYNC
        STA  VBLANK
        LDY  #$08          ;how many scanlines is each block?
        LDX  #$17          ;number of blocks of data. LDY * LDX = 192!

load    LDA  playf0,X      ;load in the data for playfield 1
        STA  PF0
        LDA  playf1,X      ;load in the data for playfield 2
        STA  PF1
        LDA  playf2,X      ;load in the data for playfield 3
        STA  PF2

grfx    STA  WSYNC         ;draw the scanline
        DEY                ;decrease the block number
        BEQ  block         ;if it's zero it's time for a new block
        JMP  grfx          ;if not then repeat the previous scanline

block   TXA                ;another 5 A.M. error had "LDA X" what was I on?
        BEQ  clear         ;checks to see if you've reached the last block.
        DEX                ;if not then got ot the next block number.
        LDY  #$08          ;set up for a new block.
        JMP  load          ;go load your new block of data in.

clear   LDA  #$02          ;all done the screen. Now let's clear everything
        STA  WSYNC         ;and get ready for the next exciting screen.
        STA  VBLANK        ;which in this case, just happens to be the same
        LDX  PF0           ;as the first.
        LDX  PF1           ;isn't this fun?
        LDX  PF2
        RTS

oscan   LDX  #$1E          ;now we're getting ready to do the 30 lines of
                           ;overscan
waste   STA  WSYNC         ;and in this demo we're just going blow them all
        DEX                ;off. But in a real game you wouldn't waste all
        BNE  waste         ;these valuable cycles. Not unles you want a
        RTS                ;really dull game.

        org  $FF00

playf0  .byte $00   ;and here are the graphics for each block. My programme
        .byte $00   ;draws 24 blocks each is 8 scan lines high. 24*8=192
        .byte $00   ;so by changing the values for LDY and LDX up in the
        .byte $00   ;draw routine you can alter your vertical resolution for
        .byte $00   ;your playfield graphics. Just make sure that both values
        .byte $00   ;multiply together to make 192. This will let you draw
        .byte $00   ;1*192=192
        .byte $00   ;2*96 =192
        .byte $00   ;4*48 =192
        .byte $00   ;6*32 =192
        .byte $00   ;8*24 =192 (also makes nice square blocks!)
        .byte $20   ;16*12=192
        .byte $20   ;32*6 =192 (okay, we're getting rediculous)
        .byte $70   ;64*3 =192
        .byte $f0   ;96*2 =192
        .byte $f0   ;192*1=192
        .byte $f0   ;
        .byte $e0   ;Anyways... also note that the graphics data here
        .byte $e0   ;is stored upsidedown. Trust me, it's much easier
        .byte $c0   ;to load it this way.
        .byte $80   ;
        .byte $00   ;Using this kind of drawing routine would make it easy
        .byte $00   ;to create a playfield graphics editor that will auto
        .byte $00   ;generate the playfield data in a text file. Then you
playf1  .byte $00   ;can just cut and paste the data into your source code.
        .byte $00   ;But I honestly don't know how well my playfield drawing
        .byte $00   ;routine can be adapted to work in a game. Maybe our
        .byte $00   ;resident "2600 Gods" Nick Bensema or Bob Colbert can
        .byte $00   ;offer some criticism.
        .byte $00   ;
        .byte $00   ;Well that's about all I've got to say on the subject.
        .byte $00   ;It was actually a lot of fun figuring this stuff out
        .byte $00   ;and now that I've actually written my own code to draw
        .byte $00   ;a screen, the 2600 is a lot less scary now.
        .byte $10   ;But don't expect a game from me anytime soon. What i've
        .byte $10   ;just done now is the equivalent of a
        .byte $11   ;10 PRINT "HELLO"
        .byte $3b   ;20 GOTO 10
        .byte $7b   ;basic programme. It's simple and probably silly, and no
        .byte $ff   ;doubt the real programmers will look at it and laugh at
        .byte $ff   ;me and say something like. "Feh! I could have done that
        .byte $ff   ;whole thing with three lines of code!"
        .byte $ff   ;But hey, we've all got to start somewhere.
        .byte $ff   ;Anyways, feel free to muck about with this and draw your
        .byte $ff   ;own playfield pictures by editing the data. Maybe we
        .byte $ff   ;could have an informal "2600 playfield graphics art
        .byte $7c   ;contest."
        .byte $30   ;
playf2  .byte $00   ;incidently... if you don't know what this is supposed
        .byte $00   ;to be a picture of, try singing "Nanana nanana Nanana
        .byte $80   ;nanana" over and over while looking at the picture.
        .byte $80   ;
        .byte $c0   ;
        .byte $c0   ;                       CRACKERS
        .byte $c0   ;           (Baby's first code from hell!!!!!!)
        .byte $e2   ;
        .byte $e2   ;
        .byte $f2   ;
        .byte $fa   ;
        .byte $ff   ;
        .byte $1f   ;
        .byte $5f   ;
        .byte $5f   ;
        .byte $9f   ;
        .byte $df   ;
        .byte $cf   ;
        .byte $af   ;
        .byte $93   ;
        .byte $71   ;
        .byte $38   ;
        .byte $0c   ;This code is PUBLIC DOMAIN.
        .byte $04   ;By Chris "Crackers" Cracknell, March 8, 1997

        org $FFFC
        .word start
        .word start

