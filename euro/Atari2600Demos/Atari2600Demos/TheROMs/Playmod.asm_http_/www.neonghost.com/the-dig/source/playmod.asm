;---------------------------------------------------------------------------

;   * Subject: [stella] code incompatible with stella emulator
;   * From: Jim Crawford <pfister@connectnet.com>
;   * Date: Wed, 15 Oct 1997 07:54:54 -0700 (PDT)
;   * Reply-To: Jim Crawford <pfister@connectnet.com>

;---------------------------------------------------------------------------

; modified slightly from howtodrw.s
;(assembled under DASM v2.02)

        processor 6502
        org $f000

vsync   = $00         ;wait for vertical retrace
vblank  = $01         ;vertical blank
wsync   = $02         ;wait for horizontal retrace
colubk  = $09         ;background color

intim   = $284        ;timer read
tim64t  = $296        ;timer write

beginy  = $80

start
        sei             ;disable interrupts
        cld             ;clear bcd math bit

        ldx #$ff        ;set stack pointer
        txs

        lda #0          ;clear memory
clearloop
        sta 0,x
        dex
        bne clearloop

mainloop
        jsr vertblank
        inc beginy
        jsr drawscreen
        jmp mainloop

vertblank
        sta vsync       ;wait for vsync
        sta wsync       ;wait for 3 scanlines
        sta wsync
        sta wsync
        lda #44         ;set timer for 37 blank scanlines.
        sta tim64t      ;why 44?  i didn't calculate it :)
        rts

drawscreen
        lda intim       ;wait for vblank period to end
        bne drawscreen
        sta wsync       ;first scanline
        sta vblank      ;turn blanking off

        ldx #191        ;191 scanlines left...
        ldy beginy      ;start of color cycle
scanloop
        sty colubk      ;update background color
        sta wsync       ;wait for vsync
        dey             ;next color
        dex
        bne scanloop

        lda #$ff
        sta wsync       ;last one
        sta vblank      ;turn blanking on for overscan
        rts

;        org $f7fc
        org $fffc
        .word start     ;entry point
        .word start     ;int vector
