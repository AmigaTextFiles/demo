        section code,code

Circle:
        jsr     KillSystem       ; Shutdown system 
        lea     Picture,a0
        lea     CopPic,a1
        move.l  a0,d0
        move.w  d0,6(a1)         ; Move the pointer to
        swap    d0               ; the picture into
        move.w  d0,2(a1)         ; the copperlist

        lea     $dff000,a6                      ; SystemOffset
        move.w  #%1000001110000000,$96(a6)      ; Turn on display
        move.l  #Copper,$80(a6)                 ; Tell the copper,
                                                ; where to get copperlist

                                ; CalculatePoints
        lea     SineTable,a0    ; Sine
        lea     64*2(a0),a1     ; Cosine
        lea     Picture,a2

        move.w  #256-1,d7
.loop   move.w  (a0,d7.w*2),d0  ; Y
        add.w   #256/2,d0       ; Center on screen
        mulu.w  #320/8,d0       ; Times the length of each line

        move.w  (a1,d7.w*2),d1  ; X
        add.w   #320/2,d1       ; Center on screen
        move.w  d1,d2
        lsr.w   #3,d1           ; Divide by 8
        add.w   d1,d0
        and.w   #7,d2           ; Get the pixelposition in the byte
        move.b  #%10000000,d3   ; Shift this 'pixel' 
        lsr.b   d2,d3           ; This is the right pixel
        or.b    d3,(a2,d0.w)    ; Place on screen
        dbf     d7,.loop

.mouse  btst     #6,$bfe001     ; Wait for the left mousebutton
        bne.b   .mouse          ; to be clicked

        jsr     GreetSystem     ; Return to system

        rts                     ; exit program


        section various_data,data

SineTable:   ds.w   256+64
             auto    cs\SineTable\0\360+90\256+64\$3f\0\w1\ny

         section picture,data_c

Picture:    ds.b  320/8*256

	section otherpeoplescode,code

            INCLUDE Eurochart34:Sources/StartUp.S	; Change this to the desired path

         section copper,data_c
Copper: dc.w    $008e,$2c81
        dc.w    $0090,$2cc1
        dc.w    $0092,$0038
        dc.w    $0094,$00b0
	dc.w	$01fc,$0003
CopPic: dc.w    $00e0,$0000
        dc.w    $00e2,$0000
        dc.w    $0100,$1200
        dc.w    $0102,$0000
        dc.w    $0104,$0000
        dc.w    $0108,$0000
        dc.w    $010a,$0000
        dc.w    $0106,$0000
        dc.w    $0180,$0000
        dc.w    $0182,$0fff
        dc.w    $0106,$0200
        dc.w    $0180,$0000
        dc.w    $0182,$0fff
        dc.w    $ffff,$fffe
