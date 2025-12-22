

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

	XREF    obs_extruded
;///

	XREF    CopDbl3D
	XREF    fx_vblank3D

	XREF    _tileBackground
	XREF    pf1Bm

	XREF    _bezier2D
	XREF    _bezier1D

	XREF    obs_Skull

	XREF    light2Bmc
	XREF    light2Bmp
 
    section code,code

fx_d:
	;test
	move.l    _GfxBase,a6
	CALL    WaitTOF

	rts


; - - - - - - - - - - - - - - - -  - - - - - - - - -
fx_init:

	lea		bgTileSt3,a2
	move.l	pf1Bm,a1
	move.l  txtileBm,a0

	bsr		_tileBackground

	; - - - - - - -

	lea     objlist,a1
	move.l  obs_Skull,(a1)
	moveq  #1,d0
	bsr     _Scene3d_init
	move.l  a0,_scn3d_ext2
	;set light
	move.l	light2Bmc,scn_lightBM(a0)


;	 move.l	 txtileBmp,a0
;	 move.l	 CopDbl3D(pc),a1 ;   a1 dblcopper
;	 clr.w   d0
;	 bsr _SetCopperPaletteAgaDbl

	; change palette and lighting from pf2
	move.l  light2Bmp,a0
	move.l  CopDbl3D,a1 ;   a1 dblcopper
	move.w  #1,d0
	bsr _SetCopperPaletteAgaDbl

	; - - declare 3 BMs dirty
	bsr     _bmpf2_setAllDirty


	; - - -
	XREF	pf1ScrollValuesFunc
	move.l	#pf1ScrollValuesC,pf1ScrollValuesFunc
pf2Xs=(64*4)
	move.l	#((64*(16+48*1))<<16)|pf2Xs,PalOffset1
	move.l	#((64*(16+48*1))<<16)|pf2Xs,PalOffset2


	move.l	#addBarPf1C,pf1AddBarFunc

	rts
	XREF    pf1AddBarFunc
	XREF    PalOffset1
	XREF    PalOffset2
	XREF    PalOffset3

; - - - - - - - -
_scn3d_ext2: dc.l	 0

; - - list of obs:
objlist:
	dc.l    0
objlistEnd
; - - - - - - -


awayY=00
objfarZ=$540-$b0
objNearZ=$3e0-$80
objNearZ2=$3f0-$80
objNearZ3=$4f0-$80
moveBez2d:
	dc.w	8
	; table length: 16 x,y

	dc.w	-awayY,objfarZ
	dc.w	-awayY/2,objfarZ/2+objNearZ/2
	dc.w	0,objfarZ/2+objNearZ/2
	dc.w	0,objNearZ

	dc.w	0,objNearZ
	dc.w	0,objNearZ3
	dc.w	0,objNearZ3
	dc.w	0,objNearZ
	rept	6
	dc.w	0,objNearZ
	dc.w	0,objNearZ2
	dc.w	0,objNearZ2
	dc.w	0,objNearZ
	endr

rotx1dbez:
rx1bef=-48
rx1after=20
	dc.w	6
	
	dc.w    rx1bef
	dc.w    rx1bef
	dc.w    rx1bef
	dc.w    rx1bef

	dc.w    rx1bef
	dc.w    rx1bef/2
	dc.w    rx1after/2
	dc.w    rx1after

	rept	4*4
	dc.w    rx1after
	endr

redeyesbz1:
redmax=240
	dc.w	8
	
	rept	2
	dc.w	0,0,0,0
	endr

	dc.w	0,redmax/2,redmax/2,redmax
	rept	5
	dc.w    redmax,20,20,redmax
	endr

redeyesval:	dc.w	0
; - - - change one color pf2
	XDEF    setColorBk0
setColorBk0:
	;a1 copdbl
	;d0 color index in first bank
	;d1 r 8b
	;d2 g 8b
	;d3 b 8b
	; - -convert 24b thing:
	;r high
	move.w	d1,d4
	lsl.w	#4,d4
	and.w	#$0f00,d4
	;g
	move.w	d2,d5
	and.b	#$f0,d5
	or.b	d5,d4
	;b high
	move.w	d3,d5
	lsr.w	#4,d5
	and.b	#$0f,d5
	or.b	d5,d4		;d4 $0RGB high
	
	; - -  -low
	lsl.w	#8,d1		;r
	and.w	#$0f00,d1
	lsl.b	#4,d2  	;g
	or.b	d2,d1
	and.b	#$0f,d3	;b
	or.b	d3,d1		;d1 $0RGB low


	move.l	cdb_CopA(a1),a2

	move.w	#2-1,d6
.lpdbl
	lea		cp_colorBanks(a2),a2

	move.l	(a2)+,a3	; high 1st bank
	lea		(a3,d0.w*4),a3
	move.w	d4,(a3)
	; - - low
	move.l	(a2)+,a3	; high 1st bank
	lea		(a3,d0.w*4),a3
	move.w	d1,(a3)

	move.l	cdb_CopB(a1),a2

	dbf		d6,.lpdbl


	rts
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

	move.l	_scn3d_ext2(pc),a0

CLIPFAR=($0380-$80)
	move.w	#65536/CLIPFAR,scn_OoFarClip(a0)
	move.w	#CLIPFAR,scn_FarClip(a0)


	move.l	scn_obj(a0),a1

	move.l  _fxTime,d0
	lsr.l	#4,d0
	lea     obr_ty(a1),a1
	lea     moveBez2d,a0
	bsr     _bezier2D

	move.l	_scn3d_ext2(pc),a0
	move.l	scn_obj(a0),a1
;;old	 move.w  #$0300,obr_tz(a1) ; translate to front

	move.l  _fxTime,d6
	move.l	d6,d0
	lsr.w   #1,d0

	move.l	_mfast,a6
	lea		sf_SinTab(a6),a6
	and.w	#$03ff,d0
	move.w	(a6,d0.w*2),d0
	asr.w	#8,d0
;	 asr.w	 #1,d0
	move.w  d0,obr_o3(a1)


	move.l	d6,d0
	mulu.w	#7,d0
	lsr.l	#3,d0

	and.w	#$03ff,d0
	move.w	(a6,d0.w*2),d0
	asr.w	#8,d0

	move.w  d0,obr_o1(a1)


	lea     rotx1dbez(pc),a0
	move.l  _fxTime,d0
	lsr.l	#2,d0
	lea     obr_o2(a1),a1
	bsr     _bezier1D



	move.l	_scn3d_ext2(pc),a0
	move.l  bmpf2_Drawn,a1
    bsr     _Scene3d_render


	; change eye color 31

	; one curve:
	lea     redeyesbz1(pc),a0
	move.l  _fxTime,d0
	lsr.l	#2,d0
	lea     redeyesval(pc),a1
	bsr     _bezier1D
	
	;a1 copdbl
	;d0 color index in first bank
	;d1 r 8b
	;d2 g 8b
	;d3 b 8b

	
	move.l  CopDbl3D,a1
	moveq	#31,d0
	move.w	redeyesval(pc),d1	;r
	move.w	#16,d2				;g
	move.w	#10,d3				;b
	bsr		setColorBk0


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

	move.l	_scn3d_ext2(pc),a0
	bsr		_InFree

	move.l  CopDbl3D,a0
	bsr 	_cc_FreeCopperDbl
	clr.l   CopDbl3D

	XREF    haikSprite
	XREF    _CloseDblSprite

	move.l	haikSprite,a0
	bsr     _CloseDblSprite
	clr.l   haikSprite

	rts


; configure pf1 scroll and palette
pf1ScrollValuesC:
	move.l  _fxTime,d1

; - - - - -
	move.l    _mfast,a3
   
	; y scroll to d4
	;move.l	 d1,d2
	;lsr.w	 #1,d2
	;and.w	 #$03ff,d2
	;lea     sf_SinTab(a3),a3
	;move.w	 (a3,d2.w*2),d4
	;muls.w	 d5,d4
	;asr.l	 #8,d4
	;asr.w	 #7,d4 ; <<14-><<7
	;add.w	 #256,d4

	move.l	d1,d4
	lsr.w	#1,d4
	and.w	#$00ff,d4

	move.w	d4,PalOffset3+2

	; -  -horizontal scroll speed
	move.l	d1,d6
	lsl.l	#1,d1

	rts
addBarPf1C:
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

	move.l  CopDbl3D,a1
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


;	 XDEF    pf1ScrollValuesFunc
;pf1ScrollValuesFunc:	 dc.l    pf1ScrollValuesA


; - - - - - - - - - - - - - - - -  - - - - - - - - -
;/// - - - - - background tilage data
; 0end 1 norm 2 inv.
; src x0,src y0, w, h, dstx0 , dsty0

bgTileSt3:
;	 dc.w	 1,0,0,16,64,0,0
;	 dc.w	 1,24,192,8,32,16,0
;	 dc.w	 1,24,192,8,32,16,32
;	 dc.w	 1,24,192,8,32,16,64
;	 dc.w	 1,24,192,8,32,16,64+32
;	 dc.w	 1,24,64,8,128,24,0
;
;	 dc.w    2,0,0,16,64,0,64

	dc.w	1,0,64,8,64,0,0
	dc.w	1,0,64,8,64,8,0
	dc.w	1,0,64,8,64,16,0
	dc.w	1,0,64,8,64,24,0



	dc.w	0


;///

; - - -  fx table
	XDEF fx_3DExt2
fx_3DExt2:	  dc.l	  fx_init,fx_cpu,fx_end,fx_vblank3D






