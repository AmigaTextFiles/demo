

    opt c+
    opt    ALINK
    
    ;include graphics/graphics_lib.i
    ;include graphics/gfxbase.i


	include 	hardware/custom.i
	include		demodata.i


    XREF    _debugv    

    section code,code

; length of precomputed sinus table:


	XREF	_debugv
	
	XREF	_mfast

	XDEF	_initMoves
_initMoves:
	move.l	_mfast,a5

	;STRUCT sf_SinTab,(1024+512)*2
		
   ; init some  short math tables if we can do it quickly:
    move.w  #512-1,d0	; do 0 to Pi, more would diverge
    lea     sf_SinTab(a5),a0
    move.l	#6557184,d2   ; d2 is speed
	clr.l	d1        
.initSinLoop
		move.l	d1,d3
		move.l	d1,d4
		swap	d3
		move.w	d3,(a0)+

			move.w  d3,d5
			asr.w	#4,d5
			move.w	d5,(sf_SinTab2-sf_SinTab)-2(a0)
			move.w	d5,(sf_SinTab2-sf_SinTab)+(1023*2)(a0)

		divs.l	#26559,d4		; divs.w ?
		move.w	d3,1023*2(a0)
          

		neg.w	d3
		move.w	d3,(512-1)*2(a0)

			neg.w	d5
			move.w	d5,(sf_SinTab2-sf_SinTab)+(511*2)(a0)

		add.l	d2,d1
		sub.l	d4,d2
    dbf	d0,.initSinLoop
; - - - -  - - - Sqrt
;	 leal	 SqrtTun,a0	 ;8192*2.b
;
;	 move.w	 #8191,d0
;	 clr.l	 d7
;	 clr.l	 d1
;bclpsqr1:
;	 move.l	 d7,d1
*************
;entré d1.l
;	 moveq.l #-1,d2
;sqrt1L9:
;	 add.l	 #2,d2
;	 sub.l	 d2,d1
;	 bcc sqrt1L9

;	 asr.l	 #1,d2
;;sorti en d2.l
**********
;	 tst.l	 d2
;	 bne nopsqr1
;	 move.l	 #1,d2
;nopsqr1:
;	 move.w	 d2,(a0)+

;	 add.l	 #64,d7
;	 dbf.w	 d0,bclpsqr1

; - - -- - - create a x*x smoothing curve
	;STRUCT sf_Smooth,256*2
	lea	sf_Smooth+(128*2)(a5),a0
	
	; result is *256	
	move.w	#127,d0
	move.w	d0,d1	
.smlp1
		; 0->0.5  x=x*x*2
		move.w	d0,d2
		mulu.w	d2,d2	;<<16
		lsr.l	#8-1,d2	;<<8 *2
		move.w	d2,-(a0)
	dbf	d0,.smlp1
	; -  just mirror second part so it does 0.5->1  x=x-1 x=x*x*2  x=1-x

	lea 128*2(a0),a1
	move.l	a1,a0

	move.w	#127,d0
.smlp2
	move.w	-(a1),d1 ; 1<<7
	move.w	#128,d2
	move.w	d2,d3
	sub.w	d1,d2
	add.w	d2,d3
	move.w	d3,(a0)+


	dbf	d0,.smlp2

;	 lea 256*2(a0),a0
;.smlp2
;		 ;0.5->1  x=x-1 x=x*x*2  x=1-x
;		 move.w	 d1,d0
;		 add.w	 #128-256,d0 ; -0.->0
;		 muls.l	 d0,d0 ; makes positive
;		 lsr.l	 #8-1,d0  ;<<16 back to <<8, *2
;		 move.w	 #256,d2
;		 sub.w	 d0,d2
;		 move.w	 d2,-(a0)
;
;	 dbf d1,.smlp2
; - - - -  - -
	; signals that distort screen paralax
	;STRUCT sf_YDistortSine,2*256
	; multiply smooth (in, out) and parallax

	lea	sf_YDistortSine(a5),a0
	lea	sf_SinTab(a5),a1 ; no start at 0 because of sin(x)/x
	lea sf_Smooth(a5),a2

sinRun=6
	clr.w	d3	; sin runner

	moveq  #127,d0  ; 127
.lpd1
		; multiply sin(x)/x with
		and.w	#$03ff,d3
		move.w	(a1,d3.w*2),d1 ;<<14
		muls.w	(a2),d1
		asr.l	#8,d1
		asr.l   #6,d1
		move.w	d1,(a0)+
		add.w	#sinRun,d3  ; sin run
		addq	#4,a2
	dbf	d0,.lpd1

	moveq  #127,d0  ; 127
.lpd2
		subq	#4,a2
		; multiply sin(x)/x with
		and.w	#$03ff,d3
		move.w	(a1,d3.w*2),d1 ;<<14
		muls.w	(a2),d1
		asr.l	#8,d1
		asr.l   #6,d1
		move.w	d1,(a0)+
		add.w	#sinRun,d3  ; sin run		 
	dbf	d0,.lpd2
;  - - - - - - --

	lea		sf_Exp(a5),a0
	clr.l	d1
	move.w	#255,d0
.lpexp
	move.w	d1,d2
	mulu.w	d2,d2
	lsr.l	#8,d2
	move.w	d2,(a0)+
	addq	#1,d1
	dbf	d0,.lpexp

;  - - - - - not a move...


	lea		sf_Bplcon1Scramble(a5),a0
	clr.l	d0
.lpbplscr
	move.w	d0,d1
	clr.w	d2
	neg.w	d1

	; PF1 d0
	bfins	d1,d2{22:2}
	lsr.w	#2,d1
	bfins	d1,d2{28:4}
	lsr.w	#4,d1
	bfins	d1,d2{20:2}
	move.w	d2,(a0)+

	addq	#1,d0
	cmp.w	#256,d0
	blt		.lpbplscr

	


;	 move.w	 (a0)+,d0
;	 ext.l	 d0
;	 move.l	 d0,_debugv

;	 move.w	 (a0)+,d0
;	 ext.l	 d0
;	 move.l	 d0,_debugv+4

;	 move.w	 (a0)+,d0
;	 ext.l	 d0
;	 move.l	 d0,_debugv+8

;	 move.w	 (a0)+,d0
;	 ext.l	 d0
;	 move.l	 d0,_debugv+12

	
	;STRUCT sf_YDistortDiv,2*256

	rts
	cnop	0,16
oneBezier:
	move.w	(a0),d2				;x0
	lea		(a0,d6.w),a2
	move.w	(a2),d3	   ;x1
	move.w	d3,d4	;x1
	muls.w	d1,d2
	muls.w	d0,d3
	add.l	d2,d3	;d3 x01 d2 free
	asr.l	#8,d3

	lea		(a2,d6.w),a2
	move.w	(a2),d2	 ;x2
	move.w	d2,d5		;x2

	muls.w	d1,d4
	muls.w	d0,d2
	add.l	d4,d2	;d4 free
	asr.l	#8,d2   ;d2 x12
	move.w	d2,d4	;d4 x12

	muls.w	d1,d3 ;x01
	muls.w	d0,d2 ;x12
	add.l	d3,d2	;xa
	asr.l	#8,d2	;xa

	lea		(a2,d6.w),a2
	move.w	(a2),d3	 ;x3
	muls.w	d1,d5
	muls.w	d0,d3
	add.l	d5,d3
	asr.l	#8,d3	;x23

	muls.w	d1,d4	;x12
	muls.w	d0,d3	;x23
	add.l	d4,d3
	asr.l	#8,d3	;xb

	muls.w	d1,d2
	muls.w	d0,d3
	add.l	d2,d3
	asr.l	#8,d3

	move.w	d3,(a1)+

	rts
	cnop	0,16
	XDEF    _bezier2D
_bezier2D:
	;a0 table
	;d0 main "time" ->256 per quads
	;a1 : ptr X Y

	move.w	(a0)+,d2	;nb quads

	; - - -

;d2 nbquads
	move.w	d2,d3
	lsl.w	#8,d3	; max t
.whnotintime
	cmp.w	d3,d0
	blt	.tok
	sub.w	d3,d0
	bra		.whnotintime
.tok
	; - -
	tst.w	d0
	bgt		.dob
	; before t0, send 1st coord
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	rts
.dob
	;- - d0 OK
	move.w	d0,d3
	lsr.w	#8,d3		;D3 quad number
	lsl.w	#quadSize2DShift,d3
	lea		(a0,d3.w),a0	; points quad
	
	move.w	#255,d1
	and.w	d1,d0   ;interoplate factor t
	sub.w	d0,d1	; mint
;d0 t
;d1 1-t

quadSize2D=16
quadSize2DShift=4
bdataSize=4
	moveq	#4,d6
	bsr		oneBezier
	addq	#2,a0
	bsr		oneBezier

	rts

    ;	 float mint = 1.0f - t;
;	 float x01 = x0 * mint + x1 * t;
;	 float x12 = x1 * mint + x2 * t;
;	 float x23 = x2 * mint + x3 * t;
;	 float out_c1x = x01 * mint + x12 * t;
;	 float out_c2x = x12 * mint + x23 * t;
;	 x=out_c1x * mint + out_c2x * t;

quadSize1D=8
quadSize1DShift=3
bdata1Size=2
	XDEF    _bezier1D
_bezier1D:
	;a0 table
	;d0 main "time" ->256 per quads
	;a1 : ptr X

	move.w	(a0)+,d2	;nb quads

	; - - -

;d2 nbquads
	move.w	d2,d3
	lsl.w	#8,d3	; max t
.whnotintime
	cmp.w	d3,d0
	blt	.tok
	sub.w	d3,d0
	bra		.whnotintime
.tok
	; - -
	tst.w	d0
	bgt		.dob
	; before t0, send 1st coord
	move.w	(a0)+,(a1)+
	rts
.dob
	;- - d0 OK
	move.w	d0,d3
	lsr.w	#8,d3		;D3 quad number
	lsl.w	#quadSize1DShift,d3
	lea		(a0,d3.w),a0	; points quad

	move.w	#255,d1
	and.w	d1,d0   ;interoplate factor t
	sub.w	d0,d1	; mint
;d0 t
;d1 1-t
	moveq	#bdata1Size,d6
	bsr		oneBezier

	rts
