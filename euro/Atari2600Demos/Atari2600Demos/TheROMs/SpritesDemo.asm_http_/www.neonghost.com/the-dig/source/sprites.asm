;---------------------------------------------------------------------------

;   * Subject: [stella] Sprites source code
;   * From: Bob Colbert <rcolbert@oasis.novia.net>
;   * Date: Wed, 5 Mar 1997 15:33:35 -0600 (CST)

;---------------------------------------------------------------------------
; Sprites - By Bob Colbert
; Shows 7 copies of player 0 bouncing around the screen
; Player 1 is not used yet, but could be easily added.
; Sorry about the lack of comments
; I will be using this code to make my next game,
; Of course it still needs to be heavily optimized
; The players are double height resolution and the
; Background is quad height resolution.  I am fairly
; Sure that with some optimization, the players could be
; single resolution

    processor  6502
    include    vcs.h

MAXSPRITE   = $05

hpos        = $80 ; horizontal position of sprites 0 - 3
vpos        = #hpos + #MAXSPRITE + 1    ; vertical position of sprites 0 - 3
vline       = #vpos + #MAXSPRITE + 1    ; current vertical line being drawn
sprvmot     = #vline + #MAXSPRITE + 1   ; vertical motion for sprite (0 - 3)
sprhmot     = #sprvmot + #MAXSPRITE + 1 ; horizontal motion for sprite (0 - 3)
sprtclr     = #sprhmot + #MAXSPRITE + 1 ; list of sprite colors
sprtlst     = #sprtclr + #MAXSPRITE + 1 ; list of sprites to draw
flglst      = #sprtlst + #MAXSPRITE + 1 ;
nxtsprt     = #flglst + #MAXSPRITE + 1 ;
curclr      = #nxtsprt + #MAXSPRITE + 1 ;
tempvar     = #curclr + 1  ; temp variable
tempvar2    = #tempvar + 1  ; another temp variable
p0count     = #tempvar2 + 1 ; number of lines left to draw for player 0
p1count     = #p0count + 1  ; number of lines left to draw for player 1
sprtptr     = #p1count + 1  ; pointer to current sprite
spmvptr     = #sprtptr + 1  ; pointer to sprite to move this frame
frame       = #spmvptr + 1
    org     $f000
isprvpos
    .byte   $30,$32,$20,$28,$18,$10,$32,$20
isprhpos
    .byte   $30,$40,$22,$28,$12,$50,$38,$28
isprvmot
    .byte   $ff,$1,$1,$ff,$1,$ff,$1,$1
isprhmot
    .byte   $1,$fe,$ff,$2,$ff,$1,$ff,$1
isprtclr
    .byte   $0e,$73,$16,$33,$22,$12,$53,$63
Start
    LDA     #$0
    STA     PF2     ;   save into a pattern control register
    LDA     #$01
    STA     CTRLPF  ;   set background control register
    ldx     #$00
    stx     COLUPF
    ldx     #MAXSPRITE
    stx     spmvptr
isprtlp
    lda     isprvpos,x
    sta     vpos,x
    lda     isprhpos,x
    sta     hpos,x
    lda     isprvmot,x
    sta     sprvmot,x
    lda     isprhmot,x
    sta     sprhmot,x
    lda     isprtclr,x
    sta     sprtclr,x
    txa
    sta     sprtlst,x
    dex
    bpl     isprtlp
    lda     #$43
    sta     COLUPF
SFRAME
    ldx     #$0
    stx     sprtptr
    lda     sprtlst,x
    tax
    LDA     #$56
    STA     COLUP0  ;   set right side color
    STA     WSYNC   ;   wait for horizontal sync
    STA     VBLANK  ;   start vertical blanking
    STA     VSYNC   ;   start vertical retrace
    LDA     #$2A
    STA     TIM8T   ; set timer for appropriate length

Loop1
    LDY     INTIM
    BNE     Loop1   ; waste time
    STY     WSYNC   ;   wait for horizontal sync
    STY     VSYNC   ;   end vertical retrace period
    LDA     #$24
    STA     TIM64T  ; set timer for next wait
    sta     WSYNC
    LDA     SWCHB
    AND     #$01    ;  check for reset switch
    BNE     NReset
    nop             ;   only interrupt available - must have vector set
NReset
    ldx     #MAXSPRITE
mvlp
    jsr     mvsprt
    dex
    bpl     mvlp
    jsr     srtsprt
    jsr     pri0
    jsr     res0
    jsr     zrtsprt

Loop2
    LDY     INTIM
    BNE     Loop2   ;   waste time
    STY     WSYNC   ;   wait for horizontal sync
    STY     VBLANK  ;   end vertical blanking
    sty     WSYNC
    LDX     #$38    ;  number of lines to draw on screen
    stx     vline
Loop3
    STY     WSYNC   ;   wait for horizontal sync
Loop3a
    lda     vline
    sta     PF1     ;   change a background pattern with each line
loop3b
    ldy     sprtptr
    lda     nxtsprt,y
    bmi     notstart
    tax
    lda     sprtclr,x
    sta     curclr
    lda     vline
    cmp     vpos,x
    bne     notstart
    lda     p0count
    bne     notstart2
    sta     WSYNC
    lda     #$8
    sta     p0count
    lda     hpos,x
    jsr     calcpos
    sta     HMP0
    lda     #$0
    sta     GRP0
    iny
    iny
    iny
    sta     WSYNC
resloop0
    dey
    bpl     resloop0
    sta     RESP0
    sta     WSYNC
    sta     HMOVE
    dec     vline
    bne     Loop3a
    ldy     #$10
ovrscn
    sta     WSYNC
    dey
    bpl     ovrscn
    jmp     SFRAME
notstart
    lda     p0count
notstart2
    tay
    beq     nodraw1
    dec     p0count
    lda     curclr
    sta     COLUP0
    lda     shape,y
    tay
nodraw1
    sta     WSYNC
    sty     GRP0
    sta     WSYNC
nosync
    jsr     drawplr
    cmp     #$0
    BNE     Loop3
pagend
    jmp     SFRAME

drawplr
    lda     p0count
    tay
    beq     nodraw
    LDA     #$0
    sta     tempvar
    dec     p0count
    bne     ndr2
    inc     tempvar
ndr2
    lda     shape,y
    tay
nodraw
    sta     WSYNC
    sty     GRP0
    dec     vline
    ldx     sprtptr
    lda     tempvar
    beq     nxt
    inx
    cpx     #MAXSPRITE+1
    bne     ndr1
    ldx     #$0
ndr1
    lda     nxtsprt,x
    tay
    lda     vline
    cmp     vpos,y
    bne     endraw
nxt
    stx     sprtptr
endraw
    ldx     sprtptr
    lda     vline
    rts

mvright
    JSR    calcpos
    STA    HMP0
    lda    #$0
    sta    GRP0
    INY            ;2
    INY            ;2
    INY            ;2
    STA    WSYNC   ;3
resloop
    DEY            ;2
    BPL    resloop ;2
    STA    RESP0
    sta    WSYNC
    sta    HMOVE
    RTS            ;6

calcpos
    TAY            ;2
    INY            ;2
    TYA            ;2
    AND    #$0F    ;2
    STA    tempvar  ;3
    TYA            ;2
    LSR            ;2
    LSR            ;2
    LSR            ;2
    LSR            ;2
    TAY            ;2
    CLC            ;2
    ADC    tempvar  ;3
    CMP    #$0F    ;2
    BCC    nextpos ;2
    SBC    #$0F    ;2
    INY            ;2

nextpos
    EOR    #$07    ;2
    ASL            ;2
    ASL            ;2
    ASL            ;2
    ASL            ;2
    RTS            ;6

srtsprt
    ldx     #MAXSPRITE-1
    lda     #$0
    sta     tempvar
srtloop
    lda     sprtlst+1,x
    tay
    lda     vpos,y
    sta     tempvar2
    lda     sprtlst,x
    tay
    lda     vpos,y
    cmp     tempvar2
    bpl     noswtch
    lda     sprtlst+1,x
    tay
    lda     sprtlst,x
    sta     sprtlst+1,x
    sty     sprtlst,x
    lda     #$1
    sta     tempvar
noswtch
    dex
    bpl     srtloop
    lda     tempvar
    bne     srtsprt
    rts

zrtsprt
    ldx     #$0
    ldy     #$0
zrtloop
    lda     flglst,x
    and     #$40
    bne     zrt1
    lda     sprtlst,x
    sta     nxtsprt,y
    lda     flglst,x
    ora     #$80
    sta     flglst,x
    iny
zrt1
    lda     flglst,x
    and     #$8f
    sta     flglst,x
    inx
    cpx     #MAXSPRITE+1
    bne     zrtloop
    cpy     #MAXSPRITE+1
    beq     zrt2
;    lda     sprtlst,x
    lda     #$ff
    sta     nxtsprt,y
zrt2
    rts

pri0
    lda     #$38
    sta     tempvar
    ldx     #$0
    stx     tempvar2
pri1
    lda     sprtlst,x   ;   Get first sprite #
    tay
    lda     vpos,y      ;   Get sprite y's vpos
    cmp     tempvar     ;   Compare to current line
    bpl     pri2        ;   If there is a conflict go to pri2
    sec                 ;   Subtract height of sprite
    sbc     #$7
    sta     tempvar     ;   Save as next possible vpos
pri5
    inx
    cpx     #MAXSPRITE+1
    bne     pri1
    ldx     #MAXSPRITE
pri5a
    lda     flglst,x
    and     #$bf
    sta     flglst,x
    dex
    bpl     pri5a
    rts
pri2
    lda     flglst,x   ;   get sprite #
    ora     #$20        ;   Set "conflict" flag
    sta     flglst,x
    bne     pri5

res0

    lda     #$0
    sta     tempvar     ;   first conflicting sprite
    sta     tempvar2    ;   last sprite drawn
    ldx     #MAXSPRITE
res1
    lda     flglst,x   ;   get sprite #
    and     #$20        ;   check bit 5
    bne     res2        ;   if conflict go to res2
    ldy     tempvar2
    cpy     #$1
    bne     res1a
    lda     flglst,x
    and     #$bf
    sta     flglst,x
    jmp     res6
res1a
    ldy     tempvar     ;   was there a conflict before?
    beq     res5        ;   nope get otta here
    lda     flglst,x   ;   get sprite #
    ora     #$40        ;
    sta     flglst,x   ;   set the "don't draw" flag
    ldy     tempvar2    ;   we're at the last conflicting sprite
    bmi     res6        ;   if a sprite has been chosen, get out
    ldy     tempvar     ;   get first sprite w/conflict
    lda     flglst,y   ;
    and     #$bf        ;   clear the "don't draw" flag
    sta     flglst,y   ;
    jmp     res6
res2
    lda     flglst,x   ;   get sprite #
    ora     #$40
    sta     flglst,x   ;   set "don't draw" flag
    ldy     tempvar     ;   check to see if first conflict
    bne     res3        ;   nope, go to res3
    stx     tempvar     ;   yep, save table index in tempvar
res3
    and     #$80        ;   was it drawn?
    beq     res4        ;   nope, go to res4
    lda     #$1
    sta     tempvar2    ;   found 1 drawn, next non-drawn is o.k.
    bne     res5
res4
    lda     tempvar2    ;   see if drawn sprite found
    cmp     #$1
    beq     res4a       ;   yes
    jmp     res5
res4a
    lda     flglst,x   ;   get sprite #
    and     #$bf        ;   clear "don't draw" flag
    sta     flglst,x
    lda     #$81
    sta     tempvar2
    bne     res5
res6
    lda     #$0
    sta     tempvar
    sta     tempvar2
res5
    dex
    bpl     res1
    ldx     #MAXSPRITE
res7
    lda     flglst,x
    and     #$4f ; change to 4f
    sta     flglst,x
    dex
    bpl     res7
    rts

mvsprt
    lda     hpos,x
    clc
    adc     sprhmot,x
    cmp     #$4
    beq     mmv1
    cmp     #$98 ; A0 is the limit
    bne     mmv2
mmv1
    lda     #$0
    sec
    sbc     sprhmot,x
    sta     sprhmot,x
    bne     mvsprt
mmv2
    sta     hpos,x
mvsprt2a
    lda     vpos,x
    clc
    adc     sprvmot,x
    cmp     #$8
    beq     chsprvmot
    cmp     #$38
    bne     mvsprt2b
chsprvmot
    lda     #$0
    sec
    sbc     sprvmot,x
    sta     sprvmot,x
    bne     mvsprt2a
mvsprt2b
    sta     vpos,x
    rts

bitpos
    .byte  $01,$02,$04,$08,$10,$20,$40,$80

shape
    .byte  $00,$81,$42,$24,$18,$24,$42,$81,$00

    org     $fffa
    .byte   <Start
    .byte   >Start
    .byte   <Start
    .byte   >Start
    .byte   <Start
    .byte   >Start
