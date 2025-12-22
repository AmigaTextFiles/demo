

    opt c+
    opt    ALINK

    include graphics/graphics_lib.i  
    include graphics/gfxbase.i
    include hardware/custom.i

    include demodata.i
	include "/res/dat.i"

	include	movemacro.i

baseModulo=48
bpr1=64
def1Mod=(bpr1-baseModulo)
bpr2=56
def2Mod=(bpr2-baseModulo)

	XREF    _InAlloc
    
    XREF    _debugv    

    XREF    _copperCompile_InitLowResAGA
    XREF    _copperCompile_setBmAGA
    XREF    _initBm
	XREF	_closeBm

	XREF	_readGifToBm
	XREF    _readGifToChip


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

	XREF    nois320Bm
	XREF    nois256Bm
	XREF    nois256Bmp
	XREF    headBm
	XREF    headBmp

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



	XREF	_InFree

	XREF    _Scene3d_init
	XREF    _Scene3d_setBmConsts
	XREF    _Scene3d_render

	XREF    obs_extruded

	XREF    _bmToDblSprites64_15Full
	XREF    _setDblSprite
	XREF    _switchDblSprite

	
	XREF    titBmp
	XREF    titBm
	
	section code,code

; - - - - - - - - - - - - - - - -  - - - - - - - - -
;/// - - -  init
fx_init:
    ;d0.w: nb planes: 1->8
    ;d1: prefsbits: CCLR_...
	move.w    #7,d0    ;d0.w: nb planes: 1->8
	move.b    #CCLR_CANSCROLL|CCLR_DOCOLORS|CCLR_WL_SCROLL,d1

	bsr    _cc_InitLowResAGADbl ; d6/d7 a3/a4/a5/a6 preserved
	move.l	a0,CopDbl
	ifd edfzdfzd
	; patch bplcon4 in copper to have sprite palette at 128
	move.l	cdb_CopA(a0),a1
	move.l	cp_bplcon1(a1),a2
	move.w	#$0088,12(a2)
	 move.l	 cdb_CopB(a0),a1
	move.l	cp_bplcon1(a1),a2
	move.w	#$0088,12(a2)
	endc

	
	move.l	titBmp,a0
	move.l	CopDbl(pc),a1 ;	  a1 dblcopper
	clr.w   d0
	bsr _SetCopperPaletteAgaDbl


;	 move.l  XXXX,a0
;	 move.l	 CopDbl(pc),a1 ;   a1 dblcopper
;	 move.w  #128/16,d0   ; sprite colors 16-31
;	 bsr _SetCopperPaletteAgaDbl


;	 move.l  headBm,a0
;	 bsr	 _bmToDblSprites64_15Full
;	 move.l	 a0,SpriteH

nbColors=96
	move.l	#4+(nbColors*3),d0	 ; nbcolors aligned tocolor banks
	clr.l	d1
	bsr	_InAlloc
	move.l	a0,DifPalette
	move.w	#nbColors,(a0)

	rts
;///
; - - - - - effect bm stuffs
CopDbl:		dc.l	0
pf1BmRN:	dc.l	0
RNPalette	dc.l	0
DifPalette:	   dc.l	   0   ; new palette 4+128*3
; - - dbl buffer sprite:
SpriteH		dc.l	0


; - -  -- - - - - - -
fx_cpu:

	move.l    _GfxBase,a6
	CALL    WaitTOF


	rts
; - - - - - - - - - - - - - - - -  - - - - - - - - -
fx_end:

	move.l	DifPalette(pc),a0
	bsr		_InFree
	clr.l   DifPalette

	move.l  CopDbl(pc),a0
	bsr 	_cc_FreeCopperDbl
	clr.l   CopDbl

	move.l  titBm,a0
	bsr	_closeBm
	clr.l   titBm

	move.l  titBmp,a0
	bsr		_InFree
	clr.l   titBmp

	rts
tattAppear=128
tattAll=256
TitAppearRate: dc.w    tattAppear+tattAll
goAwayt:   dc.w	   0


;/// - - - ApplyDistort: apply distort on parallax
DistortState:  dc.w	   0
DistortStepT:	 dc.w	 0
; 32,16,4  or 64,8,3 or 128,4,2
;256 2 1
DistTl=256
DistY=2
DistShift=1
ApplyDistortT:

	lea DistortStepT(pc),a0
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
	lea		(a3,d1.w*2),a3
	addq	#2,a2
    sub.w	#1,d0
.lpy1
		move.w	 (a3)+,d2
		asr.w	#3,d2
		add.w   d2,(a2)
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
	lea		2(a2,d1.w*4),a2

	tst.w	d0
	beq	.noy2
	subq	#1,d0
.lpy2
		move.w	 (a3)+,d2
		asr.w	#3,d2
		add.w   d2,(a2)
		addq	#4,a2
	dbf	d0,.lpy2
.noy2

.end
.no
	rts
;///


; - - - - - - - - - - - - - - - -  - - - - - - - - -
fx_vblank:
  
	lea	TitAppearRate(pc),a0
	move.w	(a0),d7
	tst.w	d7
	beq		.nointro
	subq	#1,d7
	move.w	d7,(a0)

;/// - -  - - appear
	move.l  CopDbl(pc),a4
	lea     cdb_scrollvh(a4),a2
	; set line 256(empty), scroll0 to all lines
	move.l	#(256)<<16|(0),d1
	move.w	#(256/4)-1,d0
.lpc
	move.l	d1,(a2)+
	move.l	d1,(a2)+
	move.l	d1,(a2)+
	move.l	d1,(a2)+
	dbf	d0,.lpc


	move.w	#tattAppear+tattAll,d6
	sub.w	d7,d6	;d6: 1->384


	; -  - - then makes lines come
	lea     cdb_scrollvh(a4),a2
	move.l	_mfast(pc),a6
	lea		sf_Exp(a6),a5	; x2 curve
	lea		sf_YDistortSine(a6),a6
	clr.l	d1
	move.w	#255,d0
.lpc2
	move.w	d6,d5
	sub.w	d1,d5
	ble		.next
	;d5 1->128
	cmp.w	#128,d5	   
	bge		.lineOn
	; d5 [1,128] for each
	move.w	#128,d4
	sub.w	d5,d4
	move.w	(a6,d4.w*4),d5
	move.w	(a5,d4.w*4),d4 ;0->255
	btst	#0,d1
	bne		.noneg
		neg.w	d4
.noneg

	add.w	d1,d4
; move.w  d5,d3
; asr.w	  #4,d3
; add.w	 d3,d4
	blt		.next
	cmp.w	#256,d4
	bge		.next

	lea 	(a2,d4.w*4),a3


	move.w	d1,(a3)+
	;-
;	 asr.w	 #1,d5
	move.w	d5,(a3)+

	addq	#1,d1	;n
	dbf	d0,.lpc2
    bra	.endmoves
.lineOn
	lea 	(a2,d1.w*4),a3
	move.w	d1,(a3)+
	clr.w	(a3)+
.next
	addq	#1,d1	;n
	dbf	d0,.lpc2
	bra	.endmoves
.nointro
.afterintro
	move.l  CopDbl(pc),a4
	lea     cdb_scrollvh(a4),a2

	clr.l	d1
	move.w	#(256/4)-1,d0
.lpclassic
	rept	4
		move.w	d1,(a2)+
		clr.w	(a2)+
		addq	#1,d1
	endr
	dbf	d0,.lpclassic


.endmoves
;///

;/// - - - - - - little move after
littlemovet=(256+128)*6
	move.l	_fxTime,d1
	cmp.l	#(256+128)*6,d1
	blt		.nolmoves
	tst.w   DistortState
	bne		.nosd1
		move.w	#1,DistortState
		move.w	#DistTl,DistortStepT
.nosd1
.noreldistort

	; - - apply distort
	tst.w   DistortStepT
	beq	.nodsty
		; a1 copdbl
		move.l  CopDbl(pc),a1
		lea     cdb_scrollvh(a1),a2
		bsr ApplyDistortT
.nodsty
.nolmoves
;///
; - - - -go away
gooawayt=(littlemovet)+(DistTl*6)+300+150
	move.l	_fxTime,d1
	cmp.l	#gooawayt,d1
	blt		.nogoaway

	move.l  CopDbl(pc),a4
	lea     cdb_scrollvh(a4),a2

	;half height
	lea     goAwayt(pc),a3
	move.w  (a3),d1
	cmp.w	#128,d1
	bge		.noadd
		add.w	#2,d1
.noadd
	move.w	d1,(a3)
		move.w	d1,d5
		lsl.w	#2,d5	; let's say it's dx
		neg.w	d5
	move.w	d1,d3	; rest up
	add.w  #128,d1	;128->192
	move.l	#(128)<<16,d2
	divu.l	d1,d2
	mulu.w	d2,d3  ;d3 start.l

	; Y zoom loop
	move.w	#255,d0
.lpcg
	move.l	d3,d4
	swap	d4
;	 and.w	 #$00ff,d4
	move.w	d4,(a2)+
	;move.w	 d5,(a2)+
	clr.w	(a2)+
	add.l	d2,d3
	dbf	d0,.lpcg
 ;  - - - - -
 ; palette solarisation

	move.w  goAwayt(pc),d1
	sub.w	#1,d1
	lsl.w	#1,d1
	move.l DifPalette(pc),a0
	move.l titBmp,a1
	addq	#4,a0
	addq	#4,a1

	move.w	#nbColors-1,d0
.lpsol
		clr.w	d2
		clr.w	d3
		clr.w	d4
		move.b	(a1)+,d2
		move.b	(a1)+,d3
		move.b	(a1)+,d4

		sub.w	d1,d2
		bgt.b	.noabsr
			neg.w	d2
.noabsr
		move.b	d2,(a0)+

		sub.w	d1,d3
		bgt.b	.noabsg
			neg.w	d3
.noabsg
		move.b	d3,(a0)+
		
		sub.w	d1,d4
		bgt.b	.noabsb
			neg.w	d4
.noabsb
		move.b	d4,(a0)+

	dbf	d0,.lpsol

	move.l DifPalette(pc),a0
	move.l  CopDbl(pc),a1
	move.l	cdb_CopA(a1),a1
	clr.w	d0
	bsr		_SetCopperPaletteAga


.nogoaway
	; - - - - recompile copperlist
	move.l  titBm,a0
    move.l  CopDbl(pc),a1
	bsr		_cc_setLineScrolls
	; - - -
	move.l  CopDbl(pc),a1
	bsr		_cc_switchCopper

;	 move.w	 #$007,$0dff180

	rts
    
; - - -  fx table
	XDEF fx_Title
fx_Title:    dc.l    fx_init,fx_cpu,fx_end,fx_vblank






