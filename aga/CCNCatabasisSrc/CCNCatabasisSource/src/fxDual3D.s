

    opt c+
    opt    ALINK

    include graphics/graphics_lib.i  
    include graphics/gfxbase.i
    include hardware/custom.i

    include demodata.i
	include "/res/dat.i"

	include	k3d.i

baseModulo=48
bpr1=64
def1Mod=(bpr1-baseModulo)
bpr2=56
def2Mod=(bpr2-baseModulo)

pf2Xs=(64*4)
;/// - - - - XREFs
	XREF    _InAlloc
    
    XREF    _debugv    

    XREF    _copperCompile_InitLowResAGA
    XREF    _copperCompile_setBmAGA
    XREF    _initBm
	XREF	_closeBm

	XREF	_readGifToBm
	XREF    _readGifToChip
	XREF	_debugv

	XREF	_mfast
	XREF	_mchip1
	XREF	_mchip2
	XREF	_mchip3

	XREF	_pScreenA
	XREF	_pScreenB

	XREF	_cc_InitLowResAGADbl 
	XREF	_cc_setLineScrolls
	XREF	_SetCopperPaletteAga
	XREF	_SetCopperPaletteAgaDbl
	XREF	_cc_switchCopper
	XREF    _cc_FreeCopperDbl
	XREF    _cc_setLineScrollsDPF
	XREF    _cc_setBmAGADPF

	XREF	_fxTime


	XREF	_GfxBase
	XREF	_CopyBm
	XREF    _CopyBmAl16NoClip

    XREF    Playrtn
    XREF    P61_Init
    XREF	P61_Music
    XREF    P61_End

	XREF    bg3Bm
	XREF    bg3Bmp

	XREF    _ClearBmRect
	XREF    _clearFullBmdHog
	XREF    _partialClearBmd
	XREF    _updateBlitterOp

	XREF    light1Bmp
	XREF    light1Bmc

	XREF    txtileBmp
	XREF	txtileBm

	; - - -  -triple buffer stuffs
	; switch funcs for cpu thread
	XREF    _bmpf2_WaitDrawn
	XREF    _bmpf2_PostDrawn
	; switch func for vbl interupt
	XREF    _bmpf2_vbl_acknowledge
	XREF    _bmpf2_vbl_SetWaitOrPhys
	; points bmd_
	XREF    bmpf2_Avail
	XREF    bmpf2_Drawn
	XREF    bmpf2_WaitPhys
	XREF    bmpf2_Physic
	XREF    bmpf2_LastDrawn
	XREF    bmpf2_Data

	XREF    _bmpf2_setAllDirty

	XREF    ScreenBmHexLogo


	XREF	_InFree

	XREF    _Scene3d_init
	XREF    _Scene3d_setBmConsts
	XREF    _Scene3d_render

	XREF    _bezier2D

;///

	XREF    obs_Spike
	XREF    _setDblSprite3
	XREF    haikSprite
	XREF    haikBmp
    section code,code

; - - - - - - - - - - - - - - - -  - - - - - - - - -
fx_init:


    ;d0.w: nb planes: 1->8
    ;d1: prefsbits: CCLR_...
	move.w    #8,d0    ;d0.w: nb planes: 1->8
	move.b    #CCLR_CANSCROLL|CCLR_WL_SCROLL|CCLR_DUALPF|CCLR_DOCOLORS,d1
	or.b    #CCLR_64,d1
;not	
	or.b	#CCLR_WL_HC,d1
	;or.b    #CCLR_BMDCAS,d1
	;or.b	 #CCLR_WL_16c,d1
	bsr    _cc_InitLowResAGADbl ; d6/d7 a3/a4/a5/a6 preserved
	move.l	a0,CopDbl3D


	; patch bplcon4 in copper to have sprite palette at 128
	move.l	cdb_CopA(a0),a1
	move.l	cp_bplcon1(a1),a2
	move.w	#$0247,-4(a2)
	 move.l	 cdb_CopB(a0),a1
	move.l	cp_bplcon1(a1),a2
	move.w	#$0247,-4(a2)



	; - -  alloc pf1 background bm
	move.w    #256*2,d0  ; 512px
	move.w    #256,d1
	move.w    #4,d2		; planes
    clr.l    d3
	bsr		_initBm	 ; does align
	move.l	a0,pf1Bm


	lea		bgTileSt1,a2
	move.l	a0,a1
	move.l  txtileBm,a0

	bsr	    _tileBackground

	clr.w	DistortStepR ;reset last distort


	move.l  haikBmp,a0
	move.l	CopDbl3D(pc),a1 ;   a1 dblcopper
	move.w  #2,d0   ; sprite colors 16-31
	bsr _SetCopperPaletteAgaDbl


	; - - - -prep color table for BG
	move.l  #(64*48)*3,d0
	clr.l   d1
	bsr	    _InAlloc
	move.l  a0,palShade

	move.l  txtileBmp,a1
	addq    #4,a1

	bsr		_initPalette15_3Version
	;bsr     _initPaletteShadeTable16
	;a0 table to fill 64*48
	;a1 16c pal
    
	; - - - - - - -
	XREF    obs_Extruded
	lea     objlist,a1
	move.l  obs_Spike,(a1)
;	 move.l  obs_Extruded,(a1)
	moveq  #1,d0
	bsr     _Scene3d_init
	move.l  a0,_scn3d

	move.l	light1Bmc,scn_lightBM(a0)


	; set screen constant
	lea 	ScreenBmHexLogo(pc),a1
	move.w	#8,d0	 ;dx in byte
	move.w	#16,d1	;dy
	move.l	#$0100,d2 ; fov ?
	bsr     _Scene3d_setBmConsts

	;move.l	 scn_obj(a0),a1
	;move.l  obr_ref(a1),a2
	;move.l	 a2,_debugv+8
	;move.w	 obs_NbV(a2),_debugv+2
	;move.l	 obr_vttEnd(a1),a3

	;sub.l	 obr_vtt(a1),a3



	move.l	txtileBmp,a0
	move.l	CopDbl3D(pc),a1 ;   a1 dblcopper
	clr.w   d0
	bsr _SetCopperPaletteAgaDbl

	move.l	light1Bmp,a0
	move.l  CopDbl3D(pc),a1 ;   a1 dblcopper
	move.w  #1,d0
	bsr _SetCopperPaletteAgaDbl

	; - - declare 3 BMs dirty
	bsr     _bmpf2_setAllDirty

	rts
; - - - - - effect bm stuffs
	XDEF    pf1Bm
	XDEF    CopDbl3D
	XDEF    palShade
CopDbl3D: dc.l	  0
pf1Bm:	dc.l	0
palShade:	dc.l	0
; - - - - - - - -
_scn3d:	dc.l	0

; - - list of obs:
objlist:
	dc.l    0
objlistEnd
; - - - - - - - - - - - - - - - -  - - - - - - - - -
awayx=800
awayxb=860
moveBez2d:
	dc.w	4
	; table length: 16 x,y

	dc.w	-awayxb,0
	dc.w	(-awayxb*3)/4,0
	dc.w	0,awayxb/4
	dc.w	0,0

	dc.w	0,0
	dc.w	0,-awayxb/4
	dc.w	0,awayx/4
	dc.w	0,0

	dc.w	0,0
	dc.w	0,-awayx/4
	dc.w	(awayx*3)/4,0
	dc.w	awayx,0

	dc.w	awayx,0
	dc.w	awayx,0
	dc.w	awayx,0
	dc.w	awayx,0


timetest:   dc.l    0
fx_cpu:
	ifd	trcl
	move.w	#$707,$0dff180
	endc

	bsr	_bmpf2_WaitDrawn

	ifd	trcl
	move.w	#$000,$0dff180
	endc

	; - blit or draw here

	move.l	_GfxBase,a6
	CALL    OwnBlitter
    CALL    WaitBlit    ; because first of app

	ifd	trcl
	move.w	#$707,$0dff180
	endc
; - - -
	move.l  bmpf2_Drawn,a0
	move.w  bmd_flags(a0),d0
	btst	#0,d0
	beq.b	.noFullClear
		bsr _clearFullBmdHog
		bra.b	.endClearBm
.noFullClear	
	btst	#1,d0
	beq.b     .endClearBm
.partialClear
		; enqueue parallel clear for each planes.
		; and start them
		bsr	    _partialClearBmd
		;done already bsr	  _updateBlitterOp
.endClearBm	   
	; - -  - - - - - - -

;	 bra     .woot

	move.l	_scn3d(pc),a0
	move.l	scn_obj(a0),a1

;	 move.l	 _mfast,a6
;	 lea	 sf_Exp(a6),a5

	move.l  _fxTime,d0
	sub.l	#300*4,d0
	lsr.l	#2,d0
	lea     obr_tx(a1),a1
	lea     moveBez2d,a0
	bsr     _bezier2D
;	 clr.l	 (a1)

	move.l	_scn3d(pc),a0
	move.l	scn_obj(a0),a1

;	 move.l	 d0,d1
;	 add.l	 d1,d1
;	 add.l	 d1,d0
;	 lsr.l	 #3,d0
;	 sub.w	 #1000,d0  ;800? 1200
;	 move.w	 d0,obr_tx(a1)

	;02a0
	move.w  #$0320,obr_tz(a1) ; translate to front

	move.l  _fxTime,d0
	;lsr.w   #1,d0
; move.w #120,d0

	move.w  d0,obr_o3(a1)
	mulu.w	#6,d0
	lsr.l	#3,d0

; move.w #20,d0
	move.w  d0,obr_o1(a1)

;	 move.w  obr_mtx+mtrx_zp()

	move.l  bmpf2_Drawn,a1

    bsr     _Scene3d_render
.woot
	ifd	trcl
	move.w	#$700,$0dff180
	endc
	; - - - - DO NOT BREAK DisownBlitter Pairs
	move.l  _GfxBase,a6
	CALL    DisownBlitter


	; - - - pass drawn bm to waiting queue
	bsr _bmpf2_PostDrawn


	XREF    _cpu_WaitTofOnNFrames
	bsr     _cpu_WaitTofOnNFrames

	rts
; - - - - - - - - - - - - - - - -  - - - - - - - - -
fx_end:
; is kept
;	 move.l  CopDbl3D(pc),a0
;	 bsr 	 _cc_FreeCopperDbl
;	 clr.l   CopDbl3D

	move.l	_scn3d(pc),a0
	bsr		_InFree

	rts
; - - - - -
; called from vblank:
; configure pf1 scroll and palette
pf1ScrollValuesA:
	move.l  _fxTime,d1
; - - -
	move.l	d1,d2
	lsr.l	#6,d2
	cmp.w	#16,d2
	ble	.nosh1
		move.w	#16,d2
.nosh1
	lsl.w	#6,d2
	swap	d2
	move.w	#pf2Xs,d2
	move.l	d2,PalOffset1
	add.l	#(48*64)<<16,d2
	move.l	d2,PalOffset2

; - - - - -
	move.l    _mfast,a3

	move.l	d1,d2
	sub.w	#300*4,d2
	bgt.b	  .noscy1
		clr.w	d5
		bra.b	.noscy2
.noscy1
		lsr.l	#2,d2
		cmp.w	#255,d2
		blt		.dointerpy
			move.w	#256,d5
			bra.b	.noscy2
.dointerpy
		lea		sf_Smooth(a3),a4
		move.w	(a4,d2.w*2),d5
.noscy2
	; y scroll to d4
	move.l	d1,d2
	lsr.w	#1,d2
	and.w	#$03ff,d2
	
	lea     sf_SinTab(a3),a3
	move.w	(a3,d2.w*2),d4
	muls.w	d5,d4
	asr.l	#8,d4
	asr.w	#7,d4 ; <<14-><<7
	add.w	#256,d4
	; -  -horizontal scroll speed
	move.l	d1,d6
	lsl.l	#1,d1

	rts
	XDEF    pf1ScrollValuesFunc
pf1ScrollValuesFunc:	dc.l    pf1ScrollValuesA

addBarPf1:
	move.l	_fxTime,d0
	lsr.l	#2,d0
	move.w	#$01ff,d1
	and.w	d1,d0
	sub.w	d0,d1	;511->0
	ble		.nobar
	sub.w	#64,d1	;4xx->-64
	cmp.w	#256,d1
	bge		.nobar

	move.w	#64,d2			;nbline
	move.w	#128*bpr1,d3	; start line in txt
	tst.w	d1				;start line in copper
	bge		.noupclip
		add.w	d1,d2	;sub
		neg.w	d1
		;mulu.w	 #bpr1,d1
		lsl.w	#6,d1	; * 64
		add.w	d1,d3
		clr.w	d1
.noupclip
	tst.w	d2
	beq		.nobar
; - -  -clip down
	move.w	d1,d4
	add.w	d2,d4 ; end down
	sub.w	#256,d4
	ble		.nodclip
		sub.w	d4,d2
		ble		.nobar
.nodclip
	
	
	sub.w	#1,d2

	move.l  CopDbl3D(pc),a1
	lea     cdb_scrollvh(a1),a2
	lea     cdb_scrollvh2(a1),a3

	lea	(a2,d1.w*4),a2
	lea	(a3,d1.w*4),a3

	move.l	#(((16+48*2)*64)<<16)|(32*4),a4

.lp
		move.w	d3,(a2)+
		move.w	#64*4,(a2)+
		add.w   #bpr1,d3
		move.l	a4,(a3)+


	dbf		d2,.lp


.nobar
	rts
	XDEF    pf1AddBarFunc
pf1AddBarFunc:	dc.l    addBarPf1

startpalNorm=(64*16)
startpalS=(64*(48+16))
startpalgb=(64*((48*2)+16))
	XDEF    PalOffset1
	XDEF    PalOffset2
	XDEF    PalOffset3
PalOffset1:		dc.l	(64*(24))<<16
PalOffset2:		dc.l	(64*(48+2))<<16
PalOffset3:		dc.l	0
; - - - - - - - - - - - - - - - -  - - - - - - - - -
haiksprXt:	dc.w	(160+64)*4
			dc.w	(320)*4
			dc.w    (160+40)*4
			dc.w    (160-80)*4
			dc.w	(320)*4
			dc.w	(80)*4
			dc.w    (320-80)*4
			dc.w    (160-80)*4

	XDEF    fx_vblank3D
fx_vblank3D:

	; use func that set pf1 movements:
	move.l	   pf1ScrollValuesFunc(pc),a3
	jsr			(a3)

	; andval
	move.w	#$007f,d3

	move.l  CopDbl3D(pc),a1
	lea     cdb_scrollvh(a1),a2
	lea     cdb_scrollvh2(a1),a3
;d0 yloop
;d1 scroll speed 1
;d2 -
;d3 andval 7f
;d4 y scroll pf1
;d5 ymodulo run
;d6 scroll speed2
;d7 scroll speed choosen

;a0
;a1
;a2 pf1 write
;a3 pf2 write



	; -  --
	; 3 y loops for parallax scroll
	;d4 y scroll
	move.w	d4,d5
	and.w   d3,d5	;0->127
	move.w	#128-1,d0
	sub.w	d5,d0

	move.l  PalOffset1(pc),a4
;	 move.l	 #(startpalNorm<<16)|pf2Xs,a4 ; palette indx

	; choose X scroll speed
	move.w	d1,d7
	btst	#7,d4
	beq.b	  .nx1
		move.w	d6,d7
		move.l  PalOffset2(pc),a4
.nx1
	and.w	#$03ff,d7
	lsl.w	#6,d5
.lpscv1
		move.w	d5,(a2)+ 	;y pf1*modulopf1
		move.w 	d7,(a2)+	;x pf1 &255
		add.w	#bpr1,d5

		move.l	a4,(a3)+ ; color index, xpf2 start
	dbf	d0,.lpscv1
; - -  - always 128
	moveq	#127,d0
	clr.w	d5
	move.l  PalOffset1(pc),a4

	; choose X scroll speed
	move.w	d1,d7
	btst	#7,d4
	bne.b	  .nx2
		move.w	d6,d7
        move.l  PalOffset2(pc),a4
.nx2
	and.w	#$03ff,d7


.lpscv2
	move.w	d5,(a2)+ ;y pf1*modulopf1
	move.w 	d7,(a2)+	;x pf1 &255
	add.w	#bpr1,d5

	move.l	a4,(a3)+ ; color index, xpf2 start

	dbf	d0,.lpscv2
; - - loop 3
	; choose X scroll speed
	move.l  PalOffset1(pc),a4

	move.w	d1,d7
	btst	#7,d4
	beq.b	  .nx3
		move.w	d6,d7
        move.l  PalOffset2(pc),a4
.nx3
	and.w	#$03ff,d7
	clr.w	d5
	and.w   d3,d4
	sub.w	#1,d4
	blt.b	.nolpscv3
.lpscv3
	move.w	d5,(a2)+ ;y pf1*modulopf1
	move.w 	d7,(a2)+	;x pf1 &255
	add.w	#bpr1,d5

	move.l	a4,(a3)+ ; color index, xpf2 start

	dbf	d4,.lpscv3
.nolpscv3
; - - - - - - - - - - -  - -
	move.l	pf1AddBarFunc(pc),a1
	tst.l	a1
	beq.b	.noExtraBar
		jsr		(a1)
.noExtraBar
 ; - - - -  - - - - - - - -

	move.l	DistortTTimer(pc),d0
	clr.b	d0

	move.l	_fxTime,d1
	sub.l	#300*6,d1	; no distort when soon
	blt		.nodsty

	lsr.l	#2,d1
	clr.b	d1
	cmp.l	d0,d1
	beq		.noreldistort
		move.l	d1,DistortTTimer
		; is reached once.
		;;move.w  #1,DistortStateR
		move.w	#DistTl,DistortStepR
.nosd1
.noreldistort

	; - - apply distort
	tst.w   DistortStepR
	beq	.nodsty
		; a1 copdbl
		move.l  CopDbl3D(pc),a1
		lea     cdb_scrollvh(a1),a2
		bsr ApplyDistortR
.nodsty


	bsr _bmpf2_vbl_acknowledge
	; -  -
   

	bsr _bmpf2_vbl_SetWaitOrPhys

	;a2 bmd_ to set
	
	clr.l	d7		;0<<16
	move.b	#254,d7	;maxy

	cmp.w	#2,bmd_flags(a2) ; if we know used Y part of this screen
	bne		.notightY
		move.w	bmd_ldY1(a2),d7
		sub.w	#16,d7	; because bm start at line 16
		swap	d7
		move.w  bmd_ldY2(a2),d7
		sub.w	#16,d7
.notightY
	move.l	d7,minypf2

	move.l	bmd_bm(a2),a2	; bm pf2


	; a0 struct Bitmap pf1
	; a1 copperDbl
	; a2  struct Bitmap pf2
	move.l  pf1Bm(pc),a0
	move.l  CopDbl3D(pc),a1

	bsr     _cc_setLineScrollsDPFTileR


	; - - apply sprites

	move.l	_fxTime,d3
	sub.l	#300*3,d3
	blt		.nospr

;	 lsr.l	 #1,d3
	move.w	d3,d4
	and.w	#$01ff,d3
	lsr.l	#8,d4
	lsr.l	#1,d4
	and.w	#7,d4
	neg.w	d3
	add.w	#256,d3
	move.w	d3,d1
	
	bra.b	.sprok
.nospr
		; sprite off down
		move.w	#257,d1
.sprok

; move.w  #-229,d1
	
	lea		haiksprXt(pc),a0
	move.w	(a0,d4.w*2),d0

	move.l  haikSprite,a0
	move.l  CopDbl3D(pc),a1
	clr.w   d2
	bsr		_setDblSprite3


	XREF    _switchDblSprite
	; - - after _setDblSprite, switch
	move.l  haikSprite,a0
	bsr 	_switchDblSprite

	; - - -
	move.l  CopDbl3D(pc),a1
	bsr		_cc_switchCopper

	rts
minypf2:	dc.w	0
maxypf2:	dc.w	254

;/// - - - - - - _cc_setLineScrollsDPFTileR
	XDEF	_cc_setLineScrollsDPFTileR
_cc_setLineScrollsDPFTileR:
    ; a0 struct Bitmap
	; a1 copperDbl
	; a2  struct Bitmap pf2
	movem.l	 a0/a1/a2,-(sp)

	lea	cdb_scrollvh(a1),a3
	move.w	(a3),d1	;* dudulo now
	lsr.w	#6,d1


	move.w	2(a3),d0
	;;move.w  VHSIZE(a3),d3
	moveq	#16,d3	; y pf2
	move.w	VHSIZE+2(a3),d2

	move.l	cdb_CopA(a1),a1
	bsr    _cc_setBmAGADPF

	movem.l	 (sp),a0/a1/a2 ; cdb_

	lea		cdb_scrollvh(a1),a3 ; one buffered yx scrolls per line

	; a1 cdb_ -> cp_
	move.l	cdb_CopA(a1),a1	; double buffered copper

;	 move.w	 cp_nbLines(a1),d0
;	 subq	 #2,d0	 ; start at line1

	move.w  maxypf2(pc),d0
	subq	#1,d0
; full line test
; move.w  #255,d0


	; a4 prev bpl1mod
	move.l	cp_bplcon1(a1),a4
	addq	#2,a4 ; point bpl1mod



	; pf2dx high16  pf1dx low16
	move.l	cp_line0ByteDxPF2(a1),d6

	; - -  -- trash a0 a1
;	 move.w	  bm_BytesPerRow(a0),d5
;	 move.w	 d5,d1
;	 sub.w	  cp_baseModulo(a1),d5
;	 swap	 d5
;	 move.w	 d1,d5
;	 move.l	 d5,a0 ; defmodpf1/bprpf1

	move.l  cp_colorw(a1),a0

;	 move.w	  bm_BytesPerRow(a2),d5
;	 move.w	 d5,d1
;	 sub.w	  cp_baseModulo(a1),d5
;	 swap	 d5
;	 move.w	 d1,d5
;	 move.l	 d5,a1 ; now a1 defmodpf2/bprpf2

	; -  -
	;freed for this version:
;	 move.w	 VHSIZE(a3),d1
;	 move.w	 d1,a6	 ; a6 first Y pf2

;oldok	  move.w  (a3),a5 ; first Y pos PF1, used for bitmap pointers

	; a5 is ptr to last start
	move.w  (a3),d2	; line y1 pf1 *modulo pf1
	add.w	d6,d2
	move.w	d2,a5	; initial bm pointer dy+dx
	swap	d6	; just dx pf2 now



;;	  addq	  #4,a3

	move.l    _mfast,a6
	lea		sf_Bplcon1Scramble(a6),a6



startVW=$2c01
	move.l	#(startVW<<16)|$fffe,d7

	move.w	#-1,a2	; force palette change on first line
	;a2 previous palette index

	bra.b   .loop64c
	nop
	cnop	0,16
.loop64c
; - - - - -  -
;d0.w loop dec
;d1 dy
;d2 dx then tool
;d3 compute bltcon1
;d4
;d5.w
;d6 "previous BDx" , pf2, pf1
;d7 - vertical wait value


; a0 copper write

	; playfield 1
	move.l	(a3)+,d2 ;Y/X pf1

	; - - - vertical wait
	move.l	d7,(a0)+

	;- - -bplcon1=d3 scroll part
	move.w	d2,d4

	move.w  #bplcon1,(a0)+
; a1 -

;a2 bplcon1// ptr
;a3	Y.w/X.w precomp base
;a4 -> prev line BPL1Mod
;a5 pf1 prev Y
;a6  -> scramble table for bplcon1

; - - -  compute start
	clr.w	d3
	move.b	d2,d3
	move.w	(a6,d3.w*2),d3


	;playfield2
	move.l  (VHSIZE-4)(a3),a1  ;PaletteIndex / dXpf2
	move.w	a1,d2
	and.w	#$00ff,d2
	move.w	(a6,d2.w*2),d2
	lsl.w	#4,d2
	or.w	d2,d3

	move.w	d3,(a0)+ ; bplcon1
	; - - - - -  - - - - -  - - - bpl2mod
	; pf2 first, y is in high d2
	move.w	a1,d3

	add.w	#255,d3
	asr.w	#8,d3; >>6 >>2
	sub.w	#1,d3
	lsl.w	#3,d3


	moveq   #def2Mod,d5

 move.w	#bpl2mod,(a4)+

	sub.w	d6,d5
	add.w	d3,d5
	move.w	d3,d6  ; prev=current

	; out: d5
	; PF2 DY REMOVED HERE

	move.w	d5,(a4)+ ; prevline bpl2mod

	; - - - - - - - - -- -- - -

	; - - - find the -8,0,8,16,24 part
	add.w	#255,d4 ; aka 255
	asr.w	#8,d4; >>6 >>2
	subq	#1,d4
	lsl.w	#3,d4


 move.w	#bpl1mod,(a4)+

	; set 8balign modulos of previous line
	; it's defaultmod -prevdx + thisdx

	;a5 prev bm delta (y+x)

	move.w  #def1Mod-(bpr1),d5

	swap	d2		;ly * pf1 modulo
	add.w	d4,d2

	sub.w	a5,d5
	move.w	d2,a5
	add.w	d2,d5

	move.w	d5,(a4) ; prevline bpl1mod
	move.l	a0,a4	; next
	addq	#8,a0	; let place for bpl1Mod/bpl2mod

	; - - - palette switch ?
	move.l  a1,d3
	swap    d3
	cmp.w   d3,a2
	beq	    .nopalchange
	move.w  d3,a2   ; keep last palette state
	; - - big change here
	; can trash a1
	; can trash d2-d5
	move.l  palShade(pc),a1
	lea	    4(a1,d3.w),a1   ; start at color1
	;4*3=12.l
	rept    3
		movem.l (a1)+,d2-d5
		movem.l d2-d5,(a0)
		lea	    16(a0),a0
	endr
	movem.l (a1)+,d2-d4
	movem.l d2-d4,(a0)
	lea	    12(a0),a0

.nopalchange
; - - - when reach line 200
	swap	d7
	add.w	#$0100,d7 ; vertical copper wait

	cmp.w   #$0001,d7
	bne.b .nopt
		move.l  #$ffdffffe,(a0)+    ; pal l256 jump trick
.nopt
	swap	d7
	dbf	d0,.loop64c
; - -  - -end of screen - same with no pf2

	move.w	#255-1,d0
	sub.w  	maxypf2(pc),d0
	blt	    .nopass2

.loop64cb
	; playfield 1
	move.l	(a3)+,d2 ;Y/X pf1

	; - - - vertical wait
	move.l	d7,(a0)+

	;- - -bplcon1=d3 scroll part
	move.w	d2,d4

	move.w  #bplcon1,(a0)+
; - - -  compute start
	clr.w	d3
	move.b	d2,d3
	move.w	(a6,d3.w*2),(a0)+ ; bplcon1

	; - - - - -  - - - - -  - - - bpl2mod
	; pf2 first, y is in high d2


	; - - - - - - - - -- -- - -

	; - - - find the -8,0,8,16,24 part
	add.w	#255,d4 ; aka 255
	asr.w	#8,d4; >>6 >>2

 move.l	 #(bpl2mod<<16)|def2Mod,(a4)+

	subq	#1,d4
	lsl.w	#3,d4

 move.w	#bpl1mod,(a4)+

	moveq	#def1Mod-(bpr1),d5

	swap	d2		;ly*64 fixed modulo
	add.w	d4,d2

	sub.w	a5,d5
	move.w	d2,a5
	add.w	d2,d5

	move.w	d5,(a4) ; prevline bpl1mod
	move.l	a0,a4	; next
	addq	#8,a0	; let place for bpl1Mod/bpl2mod


	move.w  (VHSIZE-4)(a3),d3  ;PaletteIndex / dXpf2
	cmp.w   d3,a2
	beq	    .nopalchange2
	move.w  d3,a2   ; keep last palette state
	; - - big change here
	; can trash a1
	; can trash d2-d5
	move.l  palShade(pc),a1
	lea	    4(a1,d3.w),a1   ; start at color1
	;4*3=12.l
	rept    3
		movem.l (a1)+,d2-d5
		movem.l d2-d5,(a0)
		lea	    16(a0),a0
	endr
	movem.l (a1)+,d2-d4
	movem.l d2-d4,(a0)
	lea	    12(a0),a0

.nopalchange2



; - - - when reach line 200
	swap	d7
	add.w	#$0100,d7 ; vertical copper wait

	cmp.w   #$0001,d7
	bne.b .nopt2
		move.l  #$ffdffffe,(a0)+    ; pal l256 jump trick
.nopt2
	swap	d7
	dbf	d0,.loop64cb

.nopass2
; - - - - -- - - -
.end
	moveq	#-2,d0
	move.l	d0,(a0)+
	move.l	d0,(a0)+

	lea	12(sp),sp
	rts
;///

;/// - - - ApplyDistort: apply distort on parallax
	XDEF    DistortTTimer
	XDEF    DistortStepR
DistortTTimer:	dc.l	0
DistortStepR:	 dc.w	 0
;;DistortStateR:   dc.w	   0
; 32,16,4  or 64,8,3 or 128,4,2
DistTl=128
DistY=4
DistShift=2
	XDEF    ApplyDistortR
	;a2 base to distort

ApplyDistortR:

	lea DistortStepR(pc),a0
	move.w  (a0),d0
	tst.w	d0
	ble	.no
	subq	#1,d0
	move.w	d0,(a0)
	tst.w	d0
	beq	.no

	move.l	_mfast,a6
	lea		sf_YDistortSine(a6),a3


;31->16: - - -  come on
;15->0: get down

	cmp.w	#DistTl/2,d0
	blt	.gone
	; - - step31->16
	sub.w	#(DistTl/2)-1,d0  ;31->0
	neg.w	d0
	add.w	#(DistTl/2),d0 ;1->32
	; 1->16
	lsl.w	#DistShift,d0 ;8->256 gives nblines down
	tst.w	d0
	ble		.no

	move.w	#256,d1
	sub.w	d0,d1
	lea	(a3,d1.w*2),a3

    sub.w	#1,d0
.lpy1
		move.w	 (a3)+,d2
		add.w   d2,2(a2)
		sub.w	d2,VHSIZE+2(a2)
		addq	#4,a2
	dbf	d0,.lpy1

	rts
	;bra .end
.gone
	; - - - -  - -going out
	; clip differently
	;d0 15->1

	lsl.w	#DistShift,d0 ;8->256 gives nblines down
	move.w	#256,d1
	sub.w	d0,d1
	lea		(a2,d1.w*4),a2
 
	tst.w	d0
	beq	.noy2
	subq	#1,d0
.lpy2
		move.w	 (a3)+,d2
		add.w   d2,2(a2)
		sub.w	d2,VHSIZE+2(a2)
		addq	#4,a2
	dbf	d0,.lpy2
.noy2

.end
.no
	rts
;///


;/// - - - - - background tilage
; 0end 1 norm 2 inv.
; src x0,src y0, w(byte), h, dstx0 , dsty0

bgTileSt1:
	dc.w	1,0,0,16,64,0,0

	dc.w	1,24,192,8,32,16,0
	dc.w	1,24,192,8,32,16,32
	dc.w	1,24,192,8,32,16,64
	dc.w	1,24,192,8,32,16,64+32

	dc.w	1,24,64,8,128,24,0

	dc.w    2,0,0,16,64,0,64
	; -  - -
	;bar1
	dc.w	1,16,64,8,64,0,128
	dc.w	1,16,128,8,64,8,128
	dc.w	1,8,128,8,64,16,128
	dc.w	1,0,192,8,64,24,128




	dc.w	0
; - - - -
	XDEF    _tileBackground
_tileBackground:
	;a0 src bm
	;a1 dest bm
	;a2 struct
.lp
	move.w	(a2)+,d0
	tst.w	d0
	beq.b	  .endlp
	cmp.w	#1,d0
	bne.b	.nonorm
		movem.w	(a2)+,d0-d5
		bsr _copyBmPart
.nonorm
	cmp.w	#2,d0
	bne.b	.noinv
		movem.w	(a2)+,d0-d5
		bsr _copyBmPartInv
.noinv
	bra.s	.lp
.endlp
	; - -  - copy 0->256x
	; a0 src bmw=512

	move.l	bm_Planes(a1),a4


	move.w	#3,d6
.lpp
	move.l	a4,a2
	lea		32(a2),a3
	move.w	#256-1,d7
.lpcy
	; one full line
	movem.l	(a2)+,d0-d3
	movem.l	 d0-d3,(a3)
	movem.l	(a2)+,d0-d3
	movem.l	 d0-d3,16(a3)
	lea		32(a2),a2
	lea		64(a3),a3

	dbf		d7,.lpcy
	add.l	sbm_PlaneSize(a1),a4
	dbf	d6,.lpp

	rts

_copyBmPart:
	;a0 src bm_
	;a1 dest bm_
	movem.l	 a0/a1/a2,-(sp)
	;d0.w src x0 in .b
	;d1.w src y0 in lines
	;d2.w width in byte 4min.
	;d3.w height in lines
	;d4.w dest x byte
	;d5.w dest y line

	;src y
	mulu.w  bm_BytesPerRow(a0),d1
	; dest
	mulu.w  bm_BytesPerRow(a1),d5
	add.w	d0,d1
	add.w	d4,d5

	move.w	bm_BytesPerRow(a0),a2 ;src
	sub.w	d2,a2
	move.w	bm_BytesPerRow(a1),a3 ;dest
	sub.w	d2,a3

	move.l	bm_Planes(a0),a4
	move.l	bm_Planes(a1),a5

	lea		(a4,d1.w),a4
	lea		(a5,d5.w),a5

	move.l	sbm_PlaneSize(a0),a0
	move.l	sbm_PlaneSize(a1),a1

	subq   #1,d3
	move.w	d3,a6

	move.l	a4,d0
	move.l	a5,d1


	; width prepare
	lsr.w	#2,d2
	sub.w	#1,d2

	move.w	#3,d7	; nb planes-1
.lpplanes

	move.l	d0,a4
	move.l	d1,a5
	move.w	a6,d3
.lpy

	move.w	d2,d6 ; width
.lpx
		move.l  (a4)+,(a5)+

	dbf	d6,.lpx
	lea		(a4,a2.w),a4
	lea		(a5,a3.w),a5

	dbf	d3,.lpy

	add.l	a0,d0
	add.l	a1,d1

	dbf	d7,.lpplanes


	movem.l	 (sp)+,a0/a1/a2
	rts

_copyBmPartInv:
	;a0 src bm_
	;a1 dest bm_
	movem.l	 a0/a1/a2,-(sp)
	;d0.w src x0 in .b
	;d1.w src y0 in lines
	;d2.w width in byte 4min.
	;d3.w height in lines
	;d4.w dest x byte
	;d5.w dest y line

	;src y
	subq	#1,d3
	add.w	d3,d5

	mulu.w  bm_BytesPerRow(a0),d1
	; dest
	mulu.w  bm_BytesPerRow(a1),d5
	add.w	d0,d1
	add.w	d4,d5

	move.w	bm_BytesPerRow(a0),a2 ;src
	sub.w	d2,a2

	neg.w	d2
	move.w	d2,a3
	neg.w	d2
	sub.w  bm_BytesPerRow(a1),a3 ;dest

	move.l	bm_Planes(a0),a4
	move.l	bm_Planes(a1),a5

	move.w	d3,a6

	lea		(a4,d1.w),a4
	lea		(a5,d5.w),a5


	move.l	sbm_PlaneSize(a0),a0
	move.l	sbm_PlaneSize(a1),a1

	move.l	a4,d0
	move.l	a5,d1


	; width prepare
	lsr.w	#2,d2
	sub.w	#1,d2

	move.w	#3,d7	; nb planes-1
.lpplanes

	move.l	d0,a4
	move.l	d1,a5
	move.w	a6,d3
.lpy

	move.w	d2,d6 ; width
.lpx
		move.l  (a4)+,(a5)+

	dbf	d6,.lpx
	lea		(a4,a2.w),a4
	lea		(a5,a3.w),a5

	dbf	d3,.lpy

	add.l	a0,d0
	add.l	a1,d1

	dbf	d7,.lpplanes


	movem.l	 (sp)+,a0/a1/a2
	rts
;///
;/// _initPalette15_3Version
_initPalette15_3Version
	;a0 table to fill 64*48*3
	;a1 16c pal

	move.l	a1,-(sp)

	; normal palette
	bsr 	_initPaletteShadeTable16

; - - - - - - - -
	; keep 16*3 for new palette
	move.l	(sp),a1
	lea		-16*4(sp),sp
	move.l	sp,a2

	move.w	#(16*3)-1,d0
.lpc1
	clr.w	d1
	move.b	(a1)+,d1
	;mulu.w	 #3,d1
	lsr.l	#1,d1
	move.b	d1,(a2)+
	dbf	d0,.lpc1

	move.l	sp,a1
	bsr 	_initPaletteShadeTable16
   
; - - - - - - -
	move.l	16*4(sp),a1
	move.l	sp,a2

	move.w	#16-1,d0
.lpc2
	move.b	(a1)+,d1
	move.b	(a1)+,d2
	move.b	(a1)+,d3

	move.b	d1,(a2)+
	move.b	d3,(a2)+
	move.b	d2,(a2)+

	dbf	d0,.lpc2

	move.l	sp,a1
	bsr     _initPaletteShadeTable16

	lea	    (16*4)+4(sp),sp
	rts
;///
;/// - - - - - - - _initPaletteShadeTable16
_initPaletteShadeTable16:
	;a0 table to fill 64*48
	;a1 16c pal


	move.l	a1,a6
	;a1 rgb 3*16

	move.l	a1,a2

	clr.w	d2
.lpDarkToNormal

	move.l	a6,a1

	move.w	#$0180,d1
	move.w	#15,d0
.lpc1
	;d0 Y loop
	;d1.w 180
	;d2 loop x per color
	;d3
	;d4
	;d5

	; - - - R
	clr.w	d3
	move.b	(a1)+,d3	;0-255
	lsr.w	#4,d3		;high 16
	mulu.w	d2,d3
	lsr.w	#4,d3
	lsl.w	#8,d3
	; - - - G
	clr.w	d4
	move.b	(a1)+,d4	;0-255
	lsr.w	#4,d4		;high 16
	mulu.w	d2,d4
	and.b	#$f0,d4
	move.b	d4,d3
	; - - - B
	clr.w	d4
	move.b	(a1)+,d4	;0-255
	lsr.w	#4,d4		;high 16
	mulu.w	d2,d4
	lsr.w	#4,d4
	or.b	d4,d3

	move.w	d1,(a0)+	;$0180
	addq	#2,d1
	move.w	d3,(a0)+


	dbf	d0,.lpc1

	addq	#1,d2
	cmp.w	#16,d2
	bne		.lpDarkToNormal
; - - - normal to inv (solarisation)

	clr.w	d2
.lpNrmToInv

	move.l	a6,a1

	move.w	#$0180,d1
	move.w	#15,d0
.lpc2
	;d0 Y loop
	;d1.w 180
	;d2 loop x per color
	;d3
	;d4
	;d5

	; - - - R
	clr.w	d3
	move.b	(a1)+,d3	;0-255
	lsr.w	#4,d3		;high 16
	sub.w	d2,d3
	bge.b	.nr1
		neg.w	d3
.nr1
	lsl.w	#8,d3
	; - - - G
	clr.w	d4
	move.b	(a1)+,d4	;0-255
	lsr.w	#4,d4		;high 16
	sub.w	d2,d4
	bge.b	.ng1
		neg.w	d4
.ng1
	lsl.w	#4,d4
	move.b	d4,d3
	; - - - B
	clr.w	d4
	move.b	(a1)+,d4	;0-255
	lsr.w	#4,d4		;high 16
	sub.w	d2,d4
	bge.b	.nb1
		neg.w	d4
.nb1
	or.b	d4,d3

	move.w	d1,(a0)+	;$0180
	addq	#2,d1
	move.w	d3,(a0)+


	dbf	d0,.lpc2

	addq	#1,d2
	cmp.w	#16,d2
	bne		.lpNrmToInv


; - - - inv to white

	clr.w	d2
.lpInvToW

	move.l	a6,a1

	move.w	#$0180,d1
	move.w	#15,d0
.lpc3
	;d0 Y loop
	;d1.w 180
	;d2 loop x per color
	;d3
	;d4
	;d5

	; - - - R
	move.w	#255,d3
	clr.w	d5
	move.b	(a1)+,d5	;0-255
	sub.w	d5,d3	;d2 inv
	mulu.w	d2,d5
	lsr.l	#4,d5
	add.w	d5,d3
	lsl.w	#4,d3


	; - - - G
	move.w	#255,d4
	clr.w	d5
	move.b	(a1)+,d5	;0-255
	sub.w	d5,d4	;d2 inv
	mulu.w	d2,d5
	lsr.l	#4,d5
	add.w	d5,d4
	and.b	#$f0,d4
	move.b	d4,d3
	; - - - B
	move.w	#255,d4
	clr.w	d5
	move.b	(a1)+,d5	;0-255
	sub.w	d5,d4	;d2 inv
	mulu.w	d2,d5
	lsr.l	#4,d5
	add.w	d5,d4
	lsr.w	#4,d4
	and.b	#$0f,d4	   
	or.b	d4,d3

	move.w	d1,(a0)+	;$0180
	addq	#2,d1
	move.w	d3,(a0)+


	dbf	d0,.lpc3

	addq	#1,d2
	cmp.w	#16,d2
	bne		.lpInvToW

	rts
;///

; - - -  fx table
	XDEF fx_Dual3D
fx_Dual3D:	  dc.l	  fx_init,fx_cpu,fx_end,fx_vblank3D

