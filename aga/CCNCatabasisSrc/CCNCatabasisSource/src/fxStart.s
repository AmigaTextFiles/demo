

    opt c+
    opt    ALINK

    include graphics/graphics_lib.i 
    include graphics/gfxbase.i
    include hardware/custom.i

    include demodata.i

	include "/res/dat.i"


    XREF    _cc_InitLowResAGA
    XREF    _cc_setBmAGA
    XREF    _initBm
	XREF    _closeBm
	XREF	_SetCopperPaletteAgaDbl
	XREF	_cc_InitLowResAGADbl
	XREF    _cc_FreeCopperDbl
	XREF    _cc_InitCopScDbl
	XREF	_cc_setLineScrolls
	XREF    _cc_switchCopper
	XREF    _cc_setBmAGADPF
	XREF    _cc_setLineScrollsDPF
	XREF    _cc_setLineScrollsDPF64NM

	XREF	_readGifToBm
	XREF	_debugv


	XREF    _setSprite4

	XREF	_mfast
	XREF	_mchip1
	XREF	_mchip2
	XREF	_mchip3


	XREF	_GfxBase

	; bob.s
	XREF	_CopyBm
	XREF	_CopyBmAl16NoClip

	XREF	_fxTime
	XREF	_fxTime2	; not reset
	XREF	_midY

	XREF    _InAlloc
	XREF    _InFree

	XREF    __XCEXIT
	XREF    _demoEnd

; olde
;NBW=24
;NBH=18
NBW=14
NBH=10


	; - - data for this effect
	STRUCTURE	structFx,0
		; $0RGB screen
		STRUCT      sfx_rgbs,(NBW*NBH*2)
		; adapted sinus tables
		STRUCT		sfx_Sin8p,256*2	; RGB subscreen
		; this one is also used to shade in colors
		STRUCT		sfx_SinA,256*2	; (0->15)*16 sine
	LABEL		sfx_SIZEOF


    section code,code
; width of the pattern in pixel
PATWIDTH	equ	384		 ;96

; - - - - - - - - - - - - - - - -  - - - - - - - - -
fx_init:
	;--- alloc dbl buffer bitmap for pf2
	lea ScreenBmHexLogo(pc),a6
	moveq	#2,d7
.lpbm2
	move.w	#320+128,d0
	move.w	#256+32,d1 ;+32 lines for bliter tornado
	moveq	#4,d2	  ; 2bpl->26kb
    clr.l    d3
	bsr		_initBm	 ; does align
	move.l	a0,(a6)+
	dbf		d7,.lpbm2


	
	;- - -  make a copperlist to set screen
    ;d0.w: nb planes: 1->8
    ;d1: prefsbits: CCLR_...
	move.w    #8,d0    ;d0.w: nb planes: 1->8
	move.w    #CCLR_DUALPF|CCLR_64|CCLR_CANSCROLL|CCLR_DOCOLORS|CCLR_WL_HC,d1

	; CCLR_BM32 CCLR_64
	; #CCLR_WL_SCROLL
	bsr    _cc_InitLowResAGADbl ; d6/d7 a3/a4/a5/a6 preserved
	move.l	a0,CopDblHex

	; - - - alloc screen bitmap
	; PATWIDTH*2
	move.w    #PATWIDTH,d0  ; 384px
	move.w    #256+32,d1
	move.w    #4,d2		; 2bpl->26kb
    clr.l    d3
	bsr    _initBm	; does align
	move.l	a0,ScreenBmHex


	;  - - alloc effect tables
	move.l	#sfx_SIZEOF,d0
	bsr		_InAlloc
	move.l	d0,fxDatHex
	move.l	d0,a0
	; - -

	; - - translate adapted sine tables from original sinus
	move.l    _mfast,a3

	lea     sf_SinTab(a3),a3
	lea     sfx_Sin8p(a0),a1
	lea 	sfx_SinA(a0),a2   ; just clear it
	move.w	#255,d0
.s2
	move.w	(a3),d1	;1024->256
	lea		4*2(a3),a3

	asr.w	#7,d1
	add.w	#8*16,d1
	cmp.w	#$00ff,d1
	ble	.noc
		move.w	#$00ff,d1
.noc
	cmp.w	#$0010,d1
	bge	.nopc
		move.w	#$0010,d1 ; d1 min, more cool
.nopc

	and.w	#$00ff,d1
	move.w	d1,(a1)+
	clr.w	(a2)+
	dbf	d0,.s2


; - - - - - - - - - - -
; test unit for dat/ gif
;	 moveq	 #6,d0    ;d0.w dat file index
;	 move.w  #0,d1 ; d1 flag for extra column
;	 ; #GIF_ADDCOLUMN
;	 sub.l	 a3,a3
;	 bsr    _readGifToBm
;	 ; exception to exit
;	 bsr _demoEnd
;	 jmp __XCEXIT
; - - -  - - - - - - - - - -


	; - - -read gif pattern

	moveq	#N_bootpat,d0    ;d0.w dat file index
	move.w  #0,d1 ; d1 flag for extra column
	; #GIF_ADDCOLUMN
	sub.l	a3,a3
	bsr    _readGifToBm



	; a0 gif sBitmap
	
	move.l	a0,-(sp) ; to be freed

	; - -
	lea	sbm_SIZEOF(a0),a0	;bob shape struct is after gif bitmap struct

	move.l	ScreenBmHex(pc),a1
	lea	sbm_SIZEOF(a1),a1	;bob destination struct is after screen bitmap

	movem.l	 a0/a1,-(sp) ; params for bob drawing

	move.l	_GfxBase,a6
	CALL    WaitBlit    ; because first of app
	CALL    OwnBlitter

	;a0 sb
	clr.w	d7
.lpy
	movem.l	(sp),a0/a1

	clr.w	d0	;x
	move.w    d7,d1	;Y
	bsr _CopyBmAl16NoClip

	add.w	#32,d7
	cmp.w	#32*9,d7
	blt	.lpy

	move.l  _GfxBase,a6
	CALL    DisownBlitter

	add.l #8,sp
	
	; a0 sBitmap, can close  gif pattern
	move.l	(sp)+,a0
	bsr	_closeBm

	rts 
; - - - -  - - - - - - - -
fx_End:

; moved next effect (fxLoad)
;	 move.l  fxDatHex(pc),a0
;	 bsr	 _InFree
;	 clr.l	 fxDatHex
;	 move.l	 ScreenBmHex(pc),a0
;	 bsr _closeBm
;	 clr.l   ScreenBmHex
;	 move.l	 CopDblHex(pc),a0
;	 bsr _cc_FreeCopperDbl
;	 clr.l	 CopDblHex

;test	 move.l	 #$b0c0deca,_debugv+8

	rts
; - - - - - - - - - - - - - - - -  - - - - - - - - -
;  no fx_cpu because, vblank only effect
; - - - - - - - - - - - - - - - -  - - - - - - - - -
	XDEF    CopDblHex
	XDEF	ScreenBmHex
	XDEF    ScreenBmHexLogo
	XDEF    ScreenBmHexLogo2
	XDEF    ScreenBmHexLogo3
	XDEF    fxDatHex

CopDblHex:	  dc.l	  0
ScreenBmHex:   dc.l	   0
ScreenBmHexLogo:	dc.l	0 ; triple buffer
ScreenBmHexLogo2:	dc.l	0
ScreenBmHexLogo3:	dc.l	0
 
fxDatHex:	   dc.l	   0

	XDEF    scrxHex
	XDEF    scryHex
scrxHex:   dc.w	   0
scryHex:   dc.w	   0
appear:	dc.w	256

HexDisappear:  dc.w	0
	XDEF    StartFadeHexout
StartFadeHexout:

		rts
	move.l	fxDatHex(pc),a5
	tst.l	a5
	beq	.end
;	 move.l	 #110011,_debugv+12

	move.l	fxDatHex(pc),a5
	; say sin8p has now diff to white
	lea	sfx_Sin8p(a5),a0
	lea sfx_SinA(a5),a1

	move.w	#255,d1
.lpf
		move.l	#255,d3
		move.w	(a1)+,d2
		;move.w	 d2,_debugv+2
		
		lsr.w	#8,d2
		sub.w	d2,d3

		move.w	 d3,(a0)+
	dbf	d1,.lpf
	move.w	#256,appear
.end
	rts	   
	
	XDEF    HexScreen
HexScreen:

;/// - - - -  - fade in the drawn sinus table
	move.l	fxDatHex(pc),a5

	lea	appear(pc),a0
	move.w	(a0),d0
	ble		.nofade
		subq	#1,d0
		move.w	d0,(a0)

		lea	sfx_Sin8p(a5),a0
		lea sfx_SinA(a5),a1

	move.w	#255,d1
.lpf
		move.w	(a0)+,d2
		add.w	d2,(a1)+
	dbf	d1,.lpf

.nofade
;///

;/// - - -get x y bitmap scroll coords
	; get 2 cos/sin to scroll...

	move.l    _mfast,a6
	lea sf_SinTab(a6),a1
	move.l  _fxTime2,d0
	lsr.l	#2,d0

	and.w	#$03ff,d0
	lea		(a1,d0.w*2),a2
	move.w	(a2),d1
	move.w	512(a2),d2
	asr.w	#5,d1
	asr.w	#7,d2

	move.w	d1,scrxHex
	move.w	d2,scryHex

;	 clr.w   scrxHex
;	 clr.w   scryHex
; test
; move.w  #5,scryHex


;wasok	  move.l  _fxTime,d0
;	 ;lsr.l   #2,d0
;	 move.w	 d0,scrxHex
;	 ; - - - get y coord +mod, 2pn easier
;	 move.w  _fxTime+2,d1
;	 lsr.w   #2,d1
;	 move.w	 d1,scryHex
;///
;/// - - - - - find copscreen colors
	lea	sfx_rgbs(a5),a0

	move.w	scrxHex,d4
	lsr.w	#2,d4	; to pixel
	move.w	d4,d0
	and.w	#$ffc0,d4
	sub.w	d0,d4

	;----
	move.w	scryHex,d0
	add.w	#-1,d0
	and.w	#$ffe0,d0
		clr.l	d1
		move.w	d0,d1	; for rotation scroll
	sub.w	scryHex,d0
;done

	move.l	d1,a4	; low scroll bits kept for yrotation trick
	; - - - find rotation
	
	lea	sf_SinTab(a6),a1

	move.l	_fxTime2,d1
; clr.l	 d1

	lsr.l	#2,d1

	and.w	#$03ff,d1
	move.w	(a1,d1.w*2),d2 ;sin -1<<14 -> 1<<14
	add.w	#256,d1
	move.w	(a1,d1.w*2),d3 ;cos
	; note:  apply zoom on d2 d3

	move.w	_midY,d6	 ;-0.5*height
	neg.w   d6
	add.l	a4,d6	; must shift low scroll bits


	move.w	d4,d1
	sub.w	#160,d1

	; - - apply rotation for Y
	; rot: ny= y*cos + x*sin
	muls.w	d2,d1	;x*sin
	muls.w	d3,d6	;y*cos
	add.l	d1,d6	;yS<<14
	lsr.l	#2,d6	;yS pixel<<12
	move.l	d6,a4	; rotation of corner for just Y

	; - -  find dyV dyH
	ext.l	d2
	ext.l	d3
;oldok	  lsl.l	  #2,d2	  ; must stand for 16 pix<<12
;oldok	  lsl.l	  #2,d3	  ;*16, >>2 -> <<2
	lsl.l	#3,d2
	lsl.l	#3,d3

	move.l	d2,d7	;dyH
	move.l	d3,a2	;dyV
	; we work in pix<<12

	; back to little draw sinus
	lea	sfx_SinA(a5),a1

;
;d0.w  hloop / y coord
;d1.w wloop
;d2.w xcoord run
;d3 tool in
;d4 xcoord line  start
;d5 yL
;d6 tool in
;d7 dyH


;a0 table write
;a1 sinus
;a2 dyV
;a3
;a4 yS
;a5 -0.5*dyV for pair half shifted up
;a6 fast

	move.l	a2,d2
	asr.l	#1,d2
	neg.l	d2
	move.l	d2,a5

	swap	d0
	move.w	#NBH-1,d0
.lh
	swap	d0	;to ydelta
	move.w	 d4,d2

	; xstart+=sin(y)
	move.w	d0,d3
	move.w	 _fxTime2+2,d1

; clr.w	 d1

	lsr.w	#2,d1
	;lsl.w	 #1,d1
	;lsr.w	 #1,d1
	sub.w	d1,d3
	and.w	#$00ff,d3
	move.b	 (a1,d3.w*2),d3
	lsr.w	#1,d3
	add.w	d3,d2
	; - - rotated y
	move.l	a4,d5 ; yL=yS


	move.w	#(NBW/2)-1,d1
.lw
;- - - -
	move.w  d0,d3
	; consider d3 true full res Y
	sub.w	d2,d3


	and.w	#$00ff,d3
	; get high of .w because of start shade pass
	move.b	 (a1,d3.w*2),d3
 lsr.w	 #1,d3
	move.w	d3,d6
	and.w	#$00f0,d3
	lsr.w	#5,d6
	or.b	d6,d3

;	 lsr.w   #4,d3	 ;blue
; move.w  d3,d6
; lsr.w	 #1,d6
; lsl.w	 #4,d6
; or.b	 d6,d3

	move.l	d5,d6
	asr.l	#8,d6	;>>12
	lsr.l	#4,d6
	and.w	#$00ff,d6
	move.b	 (a1,d6.w*2),d6
	lsl.w	#4,d6
	and.w	#$0f00,d6

 or.w	 d6,d3

	; green
;	 move.b	 384(a1),d6
;	 and.b	 #$f0,d6
;	 or.b	 d6,d3

	move.w   d3,(a0)+

	add.w	#32,d2 ; always
	add.l	d7,d5	;yL+=dyH rotated Y

; - - - -

	move.w	d0,d3
	sub.w	#16,d3
	; consider d3 true full res Y
	sub.w	d2,d3

	and.w	#$00ff,d3
	move.b	 (a1,d3.w*2),d3
 lsr.w	 #1,d3
;	 lsr.w   #4,d3
 move.w	 d3,d6
 and.w	 #$00f0,d3
 lsr.w	#5,d6
 or.b	d6,d3

	move.l	a5,d6 ; must sub half dyv for this one !
	add.l	d5,d6

	asr.l	#8,d6	;>>12
	lsr.l	#4,d6
	and.w	#$00ff,d6
	move.b	 (a1,d6.w*2),d6
	lsl.w	#4,d6
	and.w	#$0f00,d6
 or.w	 d6,d3

	; green
;	 move.b	 384(a1),d6
;	 and.b	 #$f0,d6
;	 or.b	 d6,d3
	
	move.w   d3,(a0)+

	add.w	#32,d2 ; always
	add.l	d7,d5	;yL+=dyH rotated Y
	
	dbf		d1,.lw
; - - -
	add.l	a2,a4	;ys+=dyV for rotated y

;oldok	  add.w	  #16,d0
	add.w	#32,d0
	swap	d0
	dbf	d0,.lh


;///

; move.w #$00f0,$dff000+$0180

;/// - - -  - (OLD) set colors to scrambled copperlist
	ifd	   DRSFG
;;;	   bra .disab

	move.l	fxDatHex(pc),a1
	; add 0> lea	 sfx_rgbs(a1),a1 ; colors start line

	move.l  CopDblHex(pc),a2   ;copperptr
	move.l  cdb_CopA(a2),a5
	lea		cp_colorw(a5),a2

	move.w	scrxHex,d0
	lsr.w	#2,d0
	and.w	#$001f,d0 ; 0->31

srclinew=(NBW*2)


	move.l	#$00020000,d4

	move.w	#srclinew,d6
	move.w	#2,d7

	;test
;;	  move.w  #240,cp_nbLines(a5)
	clr.w	d0	;nbline total

	move.w	scryHex,d2
	sub.w	#1,d2	; had to do that

	move.w	d2,d1
	not.w	d1
	btst	#3,d1
	beq		.nohigh
		and.w	#$0007,d1 ;nby high -1 perfect for dbf
		bra	.highac
.nohigh
	and.w	#$0007,d1
	bra     .lowac

;d0 line count
;d1 8-height loop dbf
;d2 width loop

;a0 line read
;a1 start line read
;a2 copper start base
;a3 copper ptr
;a4
;a5 cp_
;a6 fast


.lcpny

; - - - - - - - 8 high
	moveq	#7,d1
.highac
.lh2a
	move.l	a1,a0	; restart line
	move.l	(a2)+,a3

		rept	3
		movem.l	(a0)+,d3/d5	; read 4 cols.
		move.w	d3,6(a3)
		swap	d3
		move.w	d5,6+8(a3)
		swap	d5
		move.w	d3,2(a3)
		move.w	d5,2+8(a3)
		lea		16(a3),a3
		endr

	addq	#4,a3	; jump H wait

		rept	3
		movem.l	(a0)+,d3/d5	; read 4 cols.
		move.w	d3,6(a3)
		swap	d3
		move.w	d5,6+8(a3)
		swap	d5
		move.w	d3,2(a3)
		move.w	d5,2+8(a3)
		lea		16(a3),a3
		endr

	addq	#1,d0
	cmp.w	cp_nbLines(a5),d0
	bge	.cpend
	dbf	d1,.lh2a

; - - - -  - - - 8 low
	moveq	#7,d1
.lowac
.lh2b
	move.l	a1,a0
	move.l	(a2)+,a3

	lea		-2(a0),a0

	move.l	#$01820000,d3

	moveq	#5,d2
.lpnlx
	move.w	(a0,d7.w),d3
	move.l	d3,(a3)+
	lea		4(a0),a0
	add.l	d4,d3

	move.w  (a0,d6.w),d3
	move.l	d3,(a3)+ ;up line
	add.l	d4,d3

	dbf	d2,.lpnlx

	addq	#4,a3	; jump H wait

	; - - -
	move.l	#$01820000,d3
	moveq	#5,d2
.lpnlx2
	move.w	(a0,d7.w),d3
	move.l	d3,(a3)+
	lea		4(a0),a0
	add.l	d4,d3

	move.w  (a0,d6.w),d3
	move.l	d3,(a3)+ ;up line
	add.l	d4,d3

	dbf	d2,.lpnlx2

	addq	#1,d0
	cmp.w	cp_nbLines(a5),d0
	bge	.cpend
	dbf	d1,.lh2b
; - -
	lea srclinew(a1),a1
	bra .lcpny
.cpend	  
	
.disab
	endc
;///

	
	
	; - - -  -top of frame computation here
	rts	; end HexScreen
	XREF    spriteTarget

fx_vblank:

	move.l  _fxTime2,d0
	lsr.l	#2,d0
	sub.w	#(300*6)/4,d0
	blt		.nosprite
	move.l	_mfast,a6
	lea		sf_Exp(a6),a6

	;0->64 comin
	cmp.w	#64,d0
	bge		.nocomesp
	neg.w	d0
	add.w	#63,d0

	move.w	(a6,d0.w*8),d1	;255->0
	lsr.w	#2,d1	;63->0
	add.w	#54+256-64,d1

	; - - can display sprite

	; a0 spm_ * sprite manager
	; a1 copperdbl
	; d0.w x*4
	; d1.w y
	; d2 sprite index 0,2,4,6

	bra.b	  .endmovesp
.nocomesp
	sub.w	#64+75*8,d0
	blt		.normalsp

	cmp.w	#64,d0
	bge.b	  .nosprite

	; -  sprite leaving
	move.w	(a6,d0.w*8),d1	;0->255
	lsr.w	#2,d1	;63->0
	add.w	#54+256-64,d1
	bra.b	  .endmovesp

.normalsp
	move.w	#54+256-66,d1
.endmovesp

	move.l  spriteTarget,a0 ;should be there !
	tst.l	a0
	beq		.nosprite

    move.l	CopDblHex(pc),a1
	move.w	#128*4+(320-64)*4,d0
	clr.w	d2
	bsr     _setSprite4

.nosprite
	
	
	
	bsr HexScreen

;///-- - - - set scroll, switch copperlist

; - -old ok, no DPF
;	 move.l	 ScreenBmHex(pc),a0
;	 move.l	 CopDblHex(pc),a1 ;copperptr
;	 move.l  cdb_CopA(a1),a1
	; - - -get x coord d0
;	 move.w  scrxHex,d0
;	 and.w	 #$007f,d0 ;1f*4
;	 move.w	 scryHex,d1
;	 and.w	 #$000f,d1
;	 bsr	 _cc_setBmAGA
;  - - - - ANOTHER OK
	move.l  ScreenBmHex(pc),a0
	move.l  CopDblHex(pc),a1 ;copperptr
;;	  move.l  cdb_CopA(a1),a1

	
	; - - -get x coord d0
	move.w  scrxHex,d0
	and.w   #$00ff,d0 ;3f*4
	move.w  scryHex,d1
	and.w   #$001f,d1

	move.l  ScreenBmHexLogo(pc),a2
;	 clr.l   d2
;	 clr.l   d3
;	 bsr     _cc_setBmAGADPF
	move.w	#16,d3  ; pf2y
	bsr _cc_setLineScrollsHEX









;measure


	; - - -  -
	move.l	CopDblHex(pc),a1 ;copperptr
	bsr	_cc_switchCopper
;///

; move.w #$0ff0,$dff000+$0180

	rts
	
;/// - - - - - - _cc_setLineScrollsHEX
; special version that does parallax scroll on just DPF2
; and no vertical mult.

	XDEF    _cc_setLineScrollsHEX
_cc_setLineScrollsHEX:



    ; a0 struct Bitmap
	; a1 copperDbl
	; a2  struct Bitmap pf2
	; d0 pf1x
	; d1 pf1y
	; d3 pfy2
	movem.l	 a0/a1/a2,-(sp)

	lea	cdb_scrollvh(a1),a3
	move.w  (a3),d2 ; PF2x

	move.l	cdb_CopA(a1),a1
	bsr    _cc_setBmAGADPF


	movem.l	 (sp),a0/a1/a2 ; cdb_

	lea		cdb_scrollvh(a1),a3 ; one buffered yx scrolls per line

	; a1 cdb_ -> cp_
	move.l	cdb_CopA(a1),a1	; double buffered copper

	move.w	cp_nbLines(a1),d0
	subq	#2,d0	; start at line1 + one line out of loop

	; pf2dx high16  pf1dx low16
	move.w	cp_line0ByteDxPF2(a1),d6

	; - -  -- trash a0 a1
	move.w	 bm_BytesPerRow(a0),d5
	move.w	d5,d1
	sub.w	 cp_baseModulo(a1),d5
	swap	d5
	move.w	d1,d5
	move.l	d5,a0 ; defmodpf1/bprpf1

	move.w	 bm_BytesPerRow(a2),d5
	move.w	d5,d1
	sub.w	 cp_baseModulo(a1),d5


; - - finally not, rewrite copperwith all lines
;;;;	addq	#2,a3


	move.l  cp_colorw(a1),a0

	; a6 must be ptr to before screen bpl2mod .w value
	move.l	cp_bplcon1(a1),a6
	clr.l	d3
	move.w	(a6),d3 ; before screen bplcon1
	addq	#8,a6

	move.l	d5,a1 ; now a1 defmodpf2/bprpf2
; source color table width
srclinew=(NBW*2)


; - - - - -  - - - - - - -
oneLineWaitPF2	  MACRO
	; - - - vertical wait
	move.w  d1,(a0)+
	move.w  #$fffe,(a0)+ ;$ff00 ? fffe?

	move.w  #bplcon1,(a0)+

	; - - -pf2
	move.w  (a3)+,d5



	move.w	d5,d4	;d4 XPF1/XPF2
	neg.w	d5	; it's the 8 low, consider and $00ff

	bfins	d5,d3{18:2} ; note d3 pf1 bits are set
	lsr.w	#2,d5
	bfins	d5,d3{24:4}
	lsr.w	#4,d5
	bfins	d5,d3{16:2}

	move.w  d3,(a0)+
	; - - - - - -
	; let place for bpl2mod
	move.w  #bpl2mod,(a0)+
	; - - - - -  - - - - -  - - - bpl2mod

	add.w	#(63*4)+3,d4 ;xpf2      aka 255
	asr.w	#8,d4; >>6 >>2
	sub.w	#1,d4
	lsl.w	#3,d4

	move.w	a1,d5

	sub.w	d6,d5
	add.w	d4,d5
	move.w	d4,d6  ; prev=current


	move.w  d5,(a6) ; prevline bpl2mod

	move.l  a0,a6 ; keep bpl2mod for next line
	addq    #2,a0

	add.w	#$0100,d1 ; vertical copper wait
	ENDM
; - - - - -  - - - - - -
	; copper second line value:l0 2c ,  $2d01 l1
startVW=$2c01
	move.w	#startVW,d1
	; first line out of loop

	oneLineWaitPF2


	; can use
	; d4 d5 ->trashable
	; d2 d7 -> recallable
	
	; a2 color read ptr
	; d2 y waiter

	move.l	fxDatHex(pc),a4
	; add 0> lea	 sfx_rgbs(a4),a4 ; colors start line
	move.l	a4,a2
	move.w	#$0182,d4
	
	move.w	scryHex,d2
	sub.w	#1,d2 ; need ?
;;;old	  not.w	  d2
	btst	#4,d2
;;;old	  beq	  .lowline0
	bne	.lowline0
.highline0
;;;	   and.w   #$000f,d2
	; - - linear
	rept	3 ; 4*3=12=nbw
    movem.l (a2)+,d5/d7 ; 4 colors

	move.w	d4,(a0)
	addq	#2,d4
	move.w	d4,4(a0)
	addq	#2,d4
	move.w	d5,6(a0)
	swap	d5
	move.w	d5,2(a0)
	addq	#8,a0
	
	move.w	d4,(a0)
	addq	#2,d4
	move.w	d4,4(a0)
	addq	#2,d4
	move.w	d7,6(a0)
	swap	d7
	move.w	d7,2(a0)
	addq	#8,a0
	endr
	;13eme color:
	move.w	d4,(a0)+
	move.w	(a2),(a0)+


	bra	.lowline0end
.lowline0
;;;	   and.w   #$000f,d2

	rept	6
	move.w	d4,(a0)+
	addq	#2,d4
	move.w	(a2),(a0)+

	move.w	d4,(a0)+
	addq	#2,d4
	move.w	srclinew+2(a2),(a0)+
	addq	#4,a2
	endr
	;13eme color:
	move.w	d4,(a0)+
	move.w	(a2),(a0)+

	lea		srclinew(a4),a4


.lowline0end
	addq	#1,d2

	bra	.loop
	nop
	cnop	0,16	; inst cache align
.loop
; - - - - -  -
;d0.w loop dec
;d1.w - coper vert wait value
;d2 -
;d3 compute bltcon1
;d4 byte 8align dx
;d5 comp
;d6 "previous BDx" , pf2, pf1
;d7 -

;a0 -N write
;a1->  defmodpf2/ bytesperrow pf2
;a2 - COLOR:
;a3 dX.w pf2 paralax scroll per line
;a4 -
;a5 -
;a6 - prev bpl2mod

	oneLineWaitPF2
	; - - check if line needs color change
	move.w	d2,d5
	and.b	#$0f,d5
	bne	.nocolorChange
; - - - -got color change
	btst	#4,d2
	bne	.lowline
.highline
	move.l	a4,a2
	move.w	#$0182,d4

	; - - linear
	rept	3 ; 4*3=12=nbw
    movem.l (a2)+,d5/d7 ; 4 colors

	move.w	d4,(a0)
	addq	#2,d4
	move.w	d4,4(a0)
	addq	#2,d4
	move.w	d5,6(a0)
	swap	d5
	move.w	d5,2(a0)
	addq	#8,a0

	move.w	d4,(a0)
	addq	#2,d4
	move.w	d4,4(a0)
	addq	#2,d4
	move.w	d7,6(a0)
	swap	d7
	move.w	d7,2(a0)
	addq	#8,a0
	endr
	;13eme color:
	move.w	d4,(a0)+
	move.w	(a2),(a0)+



	bra	.endlowline
.lowline
	move.l	a4,a2
	move.w	#$0182,d4

	rept	6
	move.w	d4,(a0)+
	addq	#2,d4
	move.w	(a2),(a0)+

	move.w	d4,(a0)+
	addq	#2,d4
	move.w	srclinew+2(a2),(a0)+
	addq	#4,a2
	endr
	;13eme color:
	move.w	d4,(a0)+
	move.w	(a2),(a0)+

	lea		srclinew(a4),a4
.endlowline
; - - - - - - -
.nocolorChange

	; + colors scroll y line
	addq	#1,d2


; - - - when reach line 200
	cmp.w   #$0001,d1
	bne .nopt
		move.l  #$ffdffffe,(a0)+    ; pal l256 jump trick
.nopt

	dbf d0,.loop
	; - -  set copper end
.copend
	moveq	#-2,d0
	move.l	d0,(a0)+
	move.l	d0,(a0)+


	movem.l	 (sp)+,a0/a1/a2
	rts
;///
	
	
	
	XDEF 	fx_Start
fx_Start:	dc.l	fx_init,0,fx_End,fx_vblank


