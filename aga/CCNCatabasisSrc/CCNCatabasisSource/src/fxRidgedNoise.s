

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

	XREF    ScreenBmHexLogo


	XREF	_InFree

	XREF    _Scene3d_init
	XREF    _Scene3d_setBmConsts
	XREF    _Scene3d_render

	XREF    obs_extruded

	XREF    _bmToDblSprites64_15Full
	XREF    _setDblSprite
	XREF    _switchDblSprite
	XREF    _CloseDblSprite


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
	; patch bplcon4 in copper to have sprite palette at 128
	move.l	cdb_CopA(a0),a1
	move.l	cp_bplcon1(a1),a2
	move.w	#$0088,12(a2)
	 move.l	 cdb_CopB(a0),a1
	move.l	cp_bplcon1(a1),a2
	move.w	#$0088,12(a2)



	; - -  alloc pf1 background bm
	move.w    #256*2,d0  ; 384px
	move.w    #256,d1
	move.w    #4,d2		; 2bpl->26kb
    clr.l    d3
	bsr		_initBm	 ; does align
	move.l	a0,pf1BmRN


	; - - - - - - - - - - -
	move.l	_GfxBase,a6
	CALL    WaitBlit    ; because first of app
	CALL    OwnBlitter
	; - -  -
	move.l  nois256Bm,a0
	lea		sbm_SIZEOF(a0),a0	;bob shape struct is after gif bitmap struct

	move.l	pf1BmRN(pc),a1
	lea		sbm_SIZEOF(a1),a1	;bob destination struct is after screen bitmap

	clr.w	d0	;x
	clr.w	d1
	bsr _CopyBmAl16NoClip
	; - -  -
	move.l  nois256Bm,a0
	lea		sbm_SIZEOF(a0),a0	;bob shape struct is after gif bitmap struct

	move.l	pf1BmRN(pc),a1
	lea		sbm_SIZEOF(a1),a1	;bob destination struct is after screen bitmap

	move.w	 #256,d0
	clr.w	d1
	bsr _CopyBmAl16NoClip


	move.l  _GfxBase,a6
	CALL    DisownBlitter


	; - - - - set strange palette
	move.l	#4+128*3,d0
	clr.l	d1
	bsr	_InAlloc
	move.l	a0,RNPalette

	bsr		_makeRNoisePalette128


	move.l	RNPalette(pc),a0
	move.l	CopDbl(pc),a1 ;	  a1 dblcopper
	clr.w   d0
	bsr _SetCopperPaletteAgaDbl


	move.l  headBmp,a0
	move.l	CopDbl(pc),a1 ;	  a1 dblcopper
	move.w  #128/16,d0   ; sprite colors 16-31
	bsr _SetCopperPaletteAgaDbl


	; - - -
    	; d0:max line height
	; d1: nb sprites
	; out: a0
;	 move.w	 #184,d0
;	 moveq	 #6,d1
;	 bsr     _InitDblSprite64_15
;	 move.l	 a0,SpriteH

	move.l  headBm,a0
	bsr		_bmToDblSprites64_15Full
	move.l	a0,SpriteH




	rts
;///
; - - - - - effect bm stuffs
CopDbl:		dc.l	0
pf1BmRN:	dc.l	0
RNPalette	dc.l	0
; - - dbl buffer sprite:
SpriteH		dc.l	0
; - - end bitmaps to be loaded during effect:
	XDEF    tunBm
	XDEF    tunBmp
	XDEF    rasterLogoBm
	XDEF    punchlinesBm
tunBm:			dc.l	0
tunBmp:			dc.l	0
rasterLogoBm:	dc.l	0
punchlinesBm:	dc.l	0
loadbmDone:		dc.w	0


; - -  -- - - - - - -
fx_cpu:

	tst.w   loadbmDone
	bne		.noload
	; as you may notice, the CPU does nothing
	; during this long effect,
	; so we are loading some more resources here...

	; note those functions would exit demo
	; if file problems, and they handle quit test.

	moveq	#N_tunn,d0    ;d0.w dat file index
	clr.l	d1 ; flags
	lea		tunBmp(pc),a3 ; to receive palette
	bsr    _readGifToBm
	; a0 gif sBitmap
	move.l	a0,tunBm ; to be freed

	; so we don't hog much...
	move.l    _GfxBase,a6
	CALL    WaitTOF


	moveq	#N_cShape,d0    ;d0.w dat file index
	clr.l	d1 ; flags
	sub.l	a3,a3
	bsr    _readGifToBm
	move.l	a0,rasterLogoBm ; to be freed

	; so we don't hog much...
	move.l    _GfxBase,a6
	CALL    WaitTOF

	moveq	#N_punchl,d0    ;d0.w dat file index
	clr.l	d1 ; flags
	sub.l	a3,a3
	bsr    _readGifToBm
	move.l	a0,punchlinesBm ; to be freed

	move.w	#1,loadbmDone
.noload
	; so we don't hog much...
	move.l    _GfxBase,a6
	CALL    WaitTOF


	rts
; - - - - - - - - - - - - - - - -  - - - - - - - - -
fx_end:

	move.l  CopDbl(pc),a0
	bsr 	_cc_FreeCopperDbl
	clr.l   CopDbl

	move.l  RNPalette(pc),a0
	bsr	_InFree
	clr.l   RNPalette

	move.l	SpriteH(pc),a0
	bsr     _CloseDblSprite
	clr.l   SpriteH

	move.l  nois320Bm,a0
	bsr		_closeBm
	clr.l   nois320Bm

	move.l  nois256Bm,a0
	bsr		_closeBm
	clr.l   nois256Bm

	move.l  nois256Bmp,a0
	bsr		_InFree

;	 XREF    nois320Bm
;	 XREF    nois256Bm
;	 XREF    nois256Bmp


	rts
;/// - - - - - _makeRNoisePalette128
_makeRNoisePalette128
	;a0
	move.w	#128,(a0)
	addq	#4,a0

	move.l  nois256Bmp,a1 ;16c palette
	addq	#4,a1

	move.w	#127,d0
	clr.w	d1
.lpc
;	 move.b	 d1,(a0)+
;	 move.b	 d1,(a0)+
;	 move.b	 d1,(a0)+
	; get planes value 0,2,4,6

		move.b	d1,d3
		and.b	#1,d3	;0
		
		move.b	d1,d2
		lsr.b	#1,d2
		and.b	#2,d2
		or.b	d2,d3

		move.b	d1,d2
		lsr.b	#2,d2
		and.b	#4,d2
		or.b	d2,d3

		move.b	d1,d2
		lsr.b	#3,d2
		and.b	#8,d2
		or.b	d2,d3	; d3 pf1 0-15 value
; - - - -
		move.b	d1,d4
		and.b	#2,d4

		move.b	d1,d5
		lsr.b	#3-2,d5
		and.b	#4,d5
		or.b	d5,d4

		move.b	d1,d5
		lsr.b	#5-3,d5
		and.b	#8,d5
		or.b	d5,d4	;d4 pf2 0-14 value

; - - -  -
	add.b	d4,d3	;0-29

	cmp.b	#7,d3
	bge.b	.p2
	;  0-6
		move.b	#0,(a0)+
		move.b  #16,(a0)+
		move.b  #32,(a0)+
		bra.b	.endc
.p2
	cmp.b	#7+16,d3
	blt.b	.p3
		clr.b	d4
		move.b  d4,(a0)+
		move.b  d4,(a0)+
		move.b  d4,(a0)+
		bra.b	.endc
.p3
	;7->7+16
	sub.b	#7,d3
	clr.w	d4
	move.b	d3,d4
	add.b	d3,d3
	add.b	d3,d4	;*3
	lea		(a1,d4.w),a2

	move.b  (a2)+,(a0)+
	move.b  (a2)+,(a0)+
	move.b  (a2)+,(a0)+

.endc



	addq	#1,d1
	dbf	d0,.lpc
	rts
;///
faceStartt=(300*6)
faceGoAwayt=(300*22)
faceStartYPos=-186
faceYPos=0

faceStartXt=(300*15)

FaceMoveState:	dc.w	0
FaceMoveStateX:	dc.w	0
FaceDx:	dc.w	64*4
FaceDxStep:	dc.w	256
	AffMoveVar  mvFaceDown1,faceStartYPos
	AffMoveVar  mvFaceDown2,faceStartYPos
	AffMoveVar  mvFaceDown3,faceStartYPos
NRAppearRate: dc.w	  0
; - - - - - - - - - - - - - - - -  - - - - - - - - -
fx_vblank:
	; -  -appearRate
	move.l  _fxTime,d5
	move.l	d5,d6

	;2048 to do 0->128
	lsr.l	#5,d5
	cmp.w	#128,d5
	ble.s	 .not1
		move.w	#128,d5
.not1
	; move.w #64,d5
	move.w	d5,NRAppearRate	;0->128


;///  - - - - - face automat Y
	cmp.w	#faceStartt,d6
	blt		.nofacestart
	lea 	FaceMoveState(pc),a0
	move.w  (a0),d7
	tst.w	d7
	bne		.nostartf
		move.b	#1,1(a0)
		AffMoveStart    mvFaceDown1,faceStartYPos,faceYPos,200
.nostartf
	cmp.b	#1,d7
	bne.b	  .nofd1
		AffMoveStep 	mvFaceDown1
		AffGetw			mvFaceDown1,d0
		move.w	d0,_mvPosmvFaceDown2
		move.w	d0,_mvPosmvFaceDown3
		cmp.w	#faceGoAwayt,d6
		blt.b	.nofacego
			move.b	#2,1(a0)
			ExpMoveAStart    mvFaceDown1
.nofacego
.nofd1
		cmp.b	#2,d7
		blt	  .nofd2
		
		cmp.b	#2,d7
		bne.b	.nofacego2
		cmp.w	#faceGoAwayt+40,d6
		blt.b	.nofacego2
			move.b	#3,1(a0)
			ExpMoveAStart    mvFaceDown2
.nofacego2


		cmp.b	#3,d7
		bne.b	.nofacego3
		cmp.w	#faceGoAwayt+80,d6
		blt.b	.nofacego3
			move.b	#4,1(a0)
			ExpMoveAStart    mvFaceDown3
.nofacego3
		move.l	_mfast,a6
		lea 	sf_Smooth+256(a6),a6

		ExpMoveA 	 mvFaceDown1,a6
		ExpMoveA 	 mvFaceDown2,a6
		ExpMoveA 	 mvFaceDown3,a6
.nofd2

.nofacestart
;///
;/// - - - face automat X
	cmp.w	#faceStartXt,d6
	blt		.nofacestartX
	
	lea 	 FaceDxStep(pc),a0
	move.w	(a0),d7
	tst.w	d7
	ble		.nofacestartX
	sub.w	#1,d7
	move.w	d7,(a0)


	move.l	_mfast,a6
	lea 	sf_YDistortSine(a6),a6
	move.w	(a6,d7.w*2),d4
	;lsl.w	 #1,d4
	btst	#0,d7
	beq		.nodf
		neg.w	d4
.nodf
	add.w	#64*4,d4
	move.w	d4,FaceDx
.nofacestartX

;///



	; get 2 cos/sin to scroll...

	move.l    _mfast,a6
	lea sf_SinTab(a6),a1
	move.l  _fxTime,d0
	lsr.l	#2,d0
	move.l	d0,d7
	and.w	#$03ff,d0
	lea		(a1,d0.w*2),a2
	move.w	(a2),d1
	move.w	512(a2),d2
	asr.w	#5,d1
	asr.w	#7,d2

	add.w	d0,d1


; clr.w d1
; clr.w d2

	move.w	d1,d0	; scrollx
	and.w	#$03ff,d0
;	 move.w	 d2,scryHex


	;a0 pf1
	;a2 pf2

	move.l  CopDbl(pc),a4
	lea     cdb_scrollvh(a4),a2
	lea     cdb_scrollvh2(a4),a3



	cmp.w	#128,d5
	bge.b	.not2
	; - - up to dark
	move.w	#127,d4
	sub.w	d5,d4
	blt.b	.noup
.lpu
	move.w	#256,(a2)+
	clr.w	(a2)+
	move.w	#256,(a3)+
	clr.w	(a3)+

	dbf	d4,.lpu
.noup
	; - - down to dark

.not2


	tst.w	d5
	beq		.nodraw

	move.l  _fxTime,d6
	lsr.l	#2,d6

	move.w 	d5,d4
	add.w	d5,d4	; height displayed
	ext.l	d4
	move.l	#256<<16,d3
	divu.l	d4,d3

	clr.l	d1

	sub.w	#1,d4
.lpsetsc
	and.w	#$00ff,d2
	move.w	d2,(a2)+
	move.w	d0,(a2)+	;pf1 dx


	swap	d1
	move.w	d1,(a3)+
	swap	d1

	and.w	#$03ff,d6
	move.w	(a1,d6.w*2),d7
	asr.w	#7,d7	;<<14 -> <<7
	add.w	#128,d7
	move.w	d7,(a3)+


	add.l	d3,d1	;y
	addq	#1,d2
	add.w	#4,d6
	dbf	d4,.lpsetsc
.nodraw

	cmp.w	#128,d5
	bge.b	.not3
	; - - up to dark
	move.w	#127,d4
	sub.w	d5,d4
	blt.b	.nodown
.lpd
	move.w	#256,(a2)+
	clr.w	(a2)+
	move.w	#256,(a3)+
	clr.w	(a3)+

	dbf	d4,.lpd
.nodown
	; - - down to dark


.not3

	; - - - -  apply
; olde
;	 move.l	 pf1BmRN,a0
;	 move.l  nois320Bm,a2
;	 move.l  CopDbl(pc),a1
;	 move.w	 #0,d0
;	 move.w	 #0,d1
;	 move.w	 #0,d2
;	 move.w	 #0,d3
;	 move.l	 cdb_CopA(a1),a1
;	 bsr    _cc_setBmAGADPF


	move.l  pf1BmRN,a0
	move.l  nois320Bm,a2
    move.l  CopDbl(pc),a1

	bsr	_cc_setLineScrollsDPF


	; - - apply sprite
	move.l  SpriteH(pc),a0
	move.l  CopDbl(pc),a1
	move.w	FaceDx(pc),d0

	AffGetw	mvFaceDown1,d1

	clr.w	d2
	bsr		_setDblSprite

	move.l  SpriteH(pc),a0
	move.l  CopDbl(pc),a1
	move.w	FaceDx(pc),d0
	add.w	#64*4,d0
	AffGetw	mvFaceDown2,d1

	moveq	#2,d2
	bsr		_setDblSprite


	move.l  SpriteH(pc),a0
	move.l  CopDbl(pc),a1
	move.w	FaceDx(pc),d0
	add.w	#128*4,d0
	AffGetw	mvFaceDown3,d1

	moveq	#4,d2
	bsr		_setDblSprite

	; - - after _setDblSprite, switch
	move.l  SpriteH(pc),a0
	bsr 	_switchDblSprite



	; a0 dsp_ * sprite manager
	; a1 copperdbl
	; d0.w x*4
	; d1.w y
	; d2 nb sprite  0,2,4,6

	; - - -
	move.l  CopDbl(pc),a1
	bsr		_cc_switchCopper

;	 move.w	 #$007,$0dff180

	rts
    
; - - -  fx table
	XDEF fx_RNoise
fx_RNoise:    dc.l    fx_init,fx_cpu,fx_end,fx_vblank






