

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

	XREF    pf1AddBarFunc

	XREF    obs_extruded
;///

	XREF    CopDbl3D
	XREF    fx_vblank3D

	XREF    _tileBackground
	XREF    pf1Bm

	XREF    obs_Extruded

	XREF    pf1ScrollValuesFunc
	XREF    PalOffset1
	XREF    PalOffset2
	XREF    PalOffset3

	XREF    _bezier2D
	XREF    DistortStepR
	XREF    DistortTTimer
 
    section code,code

fx_d:
	;test
	move.l    _GfxBase,a6
	CALL    WaitTOF

	rts


; - - - - - - - - - - - - - - - -  - - - - - - - - -
fx_init:

	lea		bgTileSt2,a2
	move.l	pf1Bm,a1
	move.l  txtileBm,a0

	bsr		_tileBackground

	clr.l   DistortTTimer
	clr.w	DistortStepR ;reset last distort


	; - - - - - - -

	lea     objlist,a1
	move.l  obs_Extruded,(a1)
	moveq  #1,d0
	bsr     _Scene3d_init
	move.l  a0,_scn3d_ext1
	;set light
	move.l	light1Bmc,scn_lightBM(a0)


;	 move.l	 txtileBmp,a0
;	 move.l	 CopDbl3D(pc),a1 ;   a1 dblcopper
;	 clr.w   d0
;	 bsr _SetCopperPaletteAgaDbl

;	 move.l	 light1Bmp,a0
;	 move.l  CopDbl3D(pc),a1 ;   a1 dblcopper
;	 move.w  #1,d0
;	 bsr _SetCopperPaletteAgaDbl

	; - - declare 3 BMs dirty
	bsr     _bmpf2_setAllDirty

	move.l  #pf1ScrollValuesB,pf1ScrollValuesFunc
	move.l	#addBarPf1A,pf1AddBarFunc

	rts
; - - - - - - - -
_scn3d_ext1: dc.l	 0

; - - list of obs:
objlist:
	dc.l    0
objlistEnd
; - - - -
awayY=900
objfarZ=$500
objNearZ=$300
objNearZ2=$380
moveBez2d:
	dc.w	5
	; table length: 16 x,y

	dc.w	-awayY,objfarZ
	dc.w	-awayY/2,objfarZ
	dc.w	0,objfarZ
	dc.w	0,objNearZ

	dc.w	0,objNearZ
	dc.w	0,objNearZ2
	dc.w	0,objNearZ2
	dc.w	0,objNearZ

	dc.w	0,objNearZ
	dc.w	0,objNearZ2
	dc.w	0,objNearZ2
	dc.w	0,objNearZ

	dc.w	0,objNearZ
	dc.w	0,objNearZ2
	dc.w	0,objNearZ2
	dc.w	0,objNearZ


	dc.w	0,objNearZ
	dc.w	0,objfarZ
	dc.w	awayY/2,objfarZ
	dc.w	awayY,objfarZ
; - - - - - - - - - - - - - - - -  - - - - - - - - -
fx_cpu:

	bsr	_bmpf2_WaitDrawn

	; - blit or draw here

	move.l	_GfxBase,a6
	CALL    OwnBlitter
    CALL    WaitBlit    ; because first of app

; - - -
	move.l  bmpf2_Drawn,a0
	move.w  bmd_flags(a0),d0
	btst	#0,d0
	beq.b	.noFullClear
		bsr _clearFullBmdHog
		bra.b	.endClearBm
.noFullClear	
	btst	#1,d0
	beq.b	  .endClearBm
.partialClear
		; enqueue parallel clear for each planes.
		; and start them
		bsr		_partialClearBmd
.endClearBm	   


;;;	   bra     .woot

	move.l	_scn3d_ext1(pc),a0
	move.l	scn_obj(a0),a1

	move.l  _fxTime,d0
	lsr.l	#2,d0
	lea     obr_ty(a1),a1
	lea     moveBez2d,a0
	bsr     _bezier2D

	move.l	_scn3d_ext1(pc),a0
	move.l	scn_obj(a0),a1

;	 move.w  #$0300,obr_tz(a1) ; translate to front

	move.l  _fxTime,d0
	lsr.w   #1,d0
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

	; - - - - DO NOT BREAK DisownBlitter Pairs
	move.l  _GfxBase,a6
	CALL    DisownBlitter


	; - - - pass drawn bm to waiting queue
	bsr 	_bmpf2_PostDrawn

	XREF    _cpu_WaitTofOnNFrames
	bsr     _cpu_WaitTofOnNFrames

	rts
; - - - - - - - - - - - - - - - -  - - - - - - - - -
fx_end:

	move.l	_scn3d_ext1(pc),a0
	bsr		_InFree


	rts
; - - - - - - - - - - - - - - - -  - - - - - - - - -
;/// - - - - - background tilage data
; 0end 1 norm 2 inv.
; src x0b,src y0, w(bytes), h, dstx0b , dsty0

bgTileSt2:
;	 dc.w	 1,0,0,16,64,0,0
;	 dc.w	 1,24,192,8,32,16,0
;	 dc.w	 1,24,192,8,32,16,32
;	 dc.w	 1,24,192,8,32,16,64
;	 dc.w	 1,24,192,8,32,16,64+32

;	 dc.w	 1,24,64,8,128,24,0

;	 dc.w    2,0,0,16,64,0,64

;	 dc.w	 1,0,64,8,64,0,0
;	 dc.w	 1,0,64,8,64,64,0
;	 dc.w	 1,0,64,8,64,128,0
;	 dc.w	 1,0,64,8,64,192,0

;	 dc.w	 1,24,64,8,64,0,64
;	 dc.w	 1,24,128,8,64,64,64
;	 dc.w	 1,24,64,8,64,128,64
;	 dc.w	 1,24,128,8,64,192,64

	dc.w	1,0,64,32,128,0,0


	dc.w	0


;///

addBarPf1A:
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

	move.l	#(((16+48*0)*64)<<16)|(32*4),a4


	move.l	_fxTime,d4
	lsr.l	#1,d4
	and.w	#$03ff,d4
.lp
		move.w	d3,(a2)+
		move.w	d4,(a2)+
		add.w   #bpr1,d3
		move.l	a4,(a3)+


	dbf		d2,.lp


.nobar
	rts

; - - - - -

; called from vblank:
; configure pf1 scroll and palette
pf1ScrollValuesB:
	move.l  _fxTime,d1
; - - -
;	 move.l	 d1,d2
;	 lsr.l	 #6,d2
;	 cmp.w	 #16,d2
;	 ble .nosh1
;		 move.w	 #16,d2
;.nosh1
;	 lsl.w	 #6,d2
;	 swap	 d2
;	 move.w	 #pf2Xs,d2
;	 move.l	 d2,PalOffset1
;	 add.l	 #(48*64)<<16,d2
;	 move.l	 d2,PalOffset2

;	 move.l	 #(((16)*64)<<16)|(64*4),PalOffset1
	move.l	#(((16+48*2)*64)<<16)|(64*4),PalOffset1
	move.l	#(((16+48*2)*64)<<16)|(64*4),PalOffset2

; - - - - -
	move.l    _mfast,a3

;	 move.l	 d1,d2
;	 sub.w	 #300*4,d2
;	 bgt.b	   .noscy1
;		 clr.w	 d5
;		 bra.b	 .noscy2
;.noscy1
;		 lsr.l	 #2,d2
;		 cmp.w	 #255,d2
;		 blt	 .dointerpy
;			 move.w	 #256,d5
;			 bra.b	 .noscy2
;.dointerpy
;		 lea	 sf_Smooth(a3),a4
;		 move.w	 (a4,d2.w*2),d5
;.noscy2
	; y scroll to d4
	move.l	d1,d4
	lsr.l	#2,d4

	move.l	d1,d2
	lsr.w	#1,d2
	and.w	#$03ff,d2

	lea     sf_SinTab(a3),a3
	move.w	(a3,d2.w*2),d1
	asr.w	#4,d1 ; <<14-><<7
	add.w	#256*4,d1
	; -  -horizontal scroll speed
	move.l	d1,d6
	add.l	d1,d1
	add.l	d6,d1
	lsr.l	#1,d1

	rts

; - - -  fx table
	XDEF fx_3DExt1
fx_3DExt1:	  dc.l	  fx_init,fx_cpu,fx_end,fx_vblank3D






