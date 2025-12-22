
    opt c+
    opt    ALINK

    include graphics/graphics_lib.i
    include graphics/gfxbase.i
    include hardware/custom.i

    include demodata.i

DOFULLWAIT  equ 1

    XREF    _debugv

    XREF    _copperCompile_InitLowResAGA
    XREF    _copperCompile_setBmAGA
    XREF    _initBm
	XREF	_closeBm

	XREF	_readGifToBm
	XREF    _readGifToChip
	XREF    _readGifToChunky
	XREF    _readBin
	XREF	_debugv

	XREF	_mfast
	XREF	_mchip1
	XREF	_mchip2
	XREF	_mchip3
	XREF	_InAlloc

	XREF	_pScreenA
	XREF	_pScreenB
	XREF    _copyBm4ToSprite_4
	XREF    _CloseSprite

	XREF	_cc_InitLowResAGADbl
	XREF	_cc_setLineScrolls
	XREF	_SetCopperPaletteAga
	XREF	_SetCopperPaletteAgaDbl
	XREF	_cc_switchCopper
	XREF    _cc_setBmAGA
	XREF    _cc_setBmAGADPF
	XREF    _cc_setLineScrollsDPF
	XREF    _cc_setLineScrollsDPF64NM


	XREF	_fxTime
	XREF    _fxFrame

	XREF	_GfxBase
	XREF	_CopyBm
	XREF    _CopyBmAl16NoClip
	XREF	_ClearBmRect

	XREF    _InitSprite64_15

    XREF    Playrtn
    XREF    P61_Init
    XREF	P61_Music
    XREF    P61_End
	XREF    _doEnd

	XREF	_demoEnd
	XREF	__XCEXIT


	XREF    _bmToDblSprites64_3Full

	; - - -resource from previous FX
	XREF    CopDblHex
	XREF	ScreenBmHex
	XREF    fxDatHex
	XREF    HexScreen
	XREF    ScreenBmHexLogo
	XREF    ScreenBmHexLogo2
	XREF    scrxHex
	XREF    scryHex

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

	include "/res/dat.i"

	XREF    CopDblHex

    section code,code


; - - - - - - - - - - - - - - - -  - - - - - - - - -
fx_init:
	;- - -  make a copperlist to set screen
    ;d0.w: nb planes: 1->8
    ;d1: prefsbits: CCLR_...


	; - - -read gif

	; - - - - little target sprite at boot must be first

	;XDEF	 targetBm
	;XDEF	 targetBmp
	;XDEF	 spriteTarget

	moveq	#N_bspec,d0    ;d0.w dat file index
	clr.l	d1 ; flags
	lea		targetBmp(pc),a3 ; to receive palette
	bsr    _readGifToBm
	; a0 gif sBitmap
	move.l	a0,targetBm ; to be freed
	; convert bm to sprite
	; d0:max line height
	; d1: nb sprites
	; out: a0
	move.w	#56,d0
	move.w	#1,d1
	bsr     _InitSprite64_15
	move.l	a0,a1
	; d0.w sprite index 0 or 2 or 4 or 6
	; d1.w source x byte offset (word aligned)
	; d2 line height
	; a0 sBitMap * 2 planes
	; a1 spm_ * sprite manager
	move.l  targetBm(pc),a0
	clr.w	d0
	clr.w	d1
	move.w	#56,d2
	bsr     _copyBm4ToSprite_4
	move.l	a1,spriteTarget

	;sprite pal
	move.l  targetBmp,a0
	move.l	CopDblHex,a1 ;   a1 dblcopper
	move.w  #2,d0   ; sprite colors 16-31
	bsr 	_SetCopperPaletteAgaDbl


	move.l  targetBm(pc),a0	;done
	bsr		_closeBm
	; - - - -

	moveq	#N_txtile,d0    ;d0.w dat file index
	clr.l	d1 ; flags
	lea		txtileBmp(pc),a3 ; to receive palette
	bsr    _readGifToBm
	; a0 gif sBitmap
	move.l	a0,txtileBm ; to be freed


	; - - -
	;haik
	moveq	#N_haik,d0    ;d0.w dat file index
	clr.l	d1 ; flags
	lea		haikBmp(pc),a3 ; to receive palette
	bsr    _readGifToBm
	; a0 gif sBitmap
	move.l	a0,haikBm ; to be freed

	move.l  haikBm,a0
	bsr		_bmToDblSprites64_3Full
	move.l	a0,haikSprite

	; a0 gif sBitmap
	move.l	haikBm(pc),a0 ; to be freed
	bsr		_closeBm
	clr.l	haikBm
	; - - -
	moveq	#N_noise320,d0    ;d0.w dat file index
	clr.l	d1 ; flags
	sub.l	a3,a3
	bsr    _readGifToBm
	; a0 gif sBitmap
	move.l	a0,nois320Bm
	; - - -
	moveq	#N_noise256,d0    ;d0.w dat file index
	clr.l	d1 ; flags
	lea		nois256Bmp(pc),a3
	bsr    _readGifToBm
	; a0 gif sBitmap
	move.l	a0,nois256Bm

	moveq	#N_sprHead,d0
	clr.l	d1
	lea		headBmp(pc),a3
	bsr     _readGifToBm
	move.l	a0,headBm

	; - - -
	moveq	#N_lwoSpike,d0
	bsr		_readBin
	move.l	a0,obs_Spike

	moveq	#N_lwoExtruded,d0
	bsr		_readBin
	move.l	a0,obs_Extruded

	moveq	#N_lwoSkull,d0
	bsr		_readBin
	move.l	a0,obs_Skull


	;- - - - -
	moveq	#N_lwg1,d7
	lea 	obs_greets(pc),a6
	move.w	#13,d6
.lpgrload
		move.l	d7,d0
		bsr     _readBin
		move.l	a0,(a6)+
		addq	#1,d7
	dbf	d6,.lpgrload

;	 moveq	 #N_lwoPatchext2,d0
;	 bsr	 _readBin
;	 move.l	 a0,obs_Patchext2

	; - - -
	moveq	#N_light1chk,d0
	lea		light1Bmp(pc),a3
	bsr		_readGifToChunky
	move.l	a0,light1Bmc

	moveq	#N_light2chk,d0
	lea		light2Bmp(pc),a3
	bsr		_readGifToChunky
	move.l	a0,light2Bmc

	moveq	#N_tit,d0    ;d0.w dat file index
	clr.l	d1 ; flags
	lea     titBmp(pc),a3
	bsr    _readGifToBm
	; a0 gif sBitmap
	move.l	a0,titBm

	moveq	#N_leyes,d0    ;d0.w dat file index
	clr.l	d1 ; flags
	lea     leyesBmp(pc),a3
	bsr    _readGifToBm
	; a0 gif sBitmap
	move.l	a0,leyesBm


	; - - - -
	moveq	#N_firstlogo,d0    ;d0.w dat file index
	clr.l	d1 ; flags
	lea		Logo1Pal(pc),a3 ; to receive palette
	bsr    _readGifToBm
	; a0 gif sBitmap
	move.l	a0,Logo1 ; to be freed

	; - - -read gif
;	 moveq	 #N_bg3,d0    ;d0.w dat file index
;	 clr.l	 d1 ; flags
;	 ; #GIF_ADDCOLUMN
;	 lea	 Palette(pc),a3 ; to receive palette
;	 bsr    _readGifToBm
;	 ; a0 gif sBitmap
;	 move.l	 a0,-(sp) ; to be freed
	; - -
;	 moveq	 #N_bg2,d0    ;d0.w dat file index
;	 clr.l	 d1 ; flags
;	 lea	 bg2Bmp(pc),a3 ; to receive palette
;	 bsr    _readGifToBm
;	 move.l  a0,bg2Bm
	; - -
;	 moveq	 #N_bg3,d0    ;d0.w dat file index
;	 clr.l	 d1 ; flags
;	 lea	 bg3Bmp(pc),a3 ; to receive palette
;	 bsr    _readGifToBm
;	 move.l  a0,bg3Bm

	; - - -
	ifd    DOMUSIC
		; direct read music to chip
		move.l	_mfast,a6
		lea		sf_datFiles(a6),a5
		move.l	 _mchip3(pc),a0
		move.w	 #N_zik,d0

		XREF    _dat_loadFileTo
		bsr	_dat_loadFileTo
		
		; olde gifed
		;move.w	 #N_zik,d0
		;move.l	 _mchip3,a0
		;bsr _readGifToChip
		;;bsr _readToChip
	endc

	move.l  Logo1Pal(pc),a0
	move.l	CopDblHex(pc),a1 ;   a1 dblcopper
	move.w  #1,d0   ; sprite colors 16-31
	bsr _SetCopperPaletteAgaDbl




	move.l  Logo1Pal(pc),a0
	bsr     _InFree
	;clr.l   Logo1Pal(pc)

AffMoveVar	MACRO
_mvPos\1:		dc.l	0
_mvEnd\1:		dc.l	0
_mvAdd\1:    	dc.l	0
_mvStep\1:		dc.w    0
		endm

; nm,v1,v2,now,length
AffMoveStart    MACRO
	move.l	#(\2)<<16,_mvPos\1

	move.w	#\4,_mvStep\1
	move.l	#\2,_mvEnd\1

	move.l	#(\3-(\2))<<16,d0

	divs.l	#\4,d0
	move.l	d0,_mvAdd\1
	endm

AffMoveStep MACRO
	tst.w	_mvStep\1
	beq		.no\@
	sub.w	 #1,_mvStep\1
	move.l	_mvAdd\1,d0
	add.l	d0,_mvPos\1
.no\@
	endm

AffGetw	MACRO
	move.w	_mvPos\1,\2
	endm

sheight		set	256
logoheight	set	166
lgYPos		set	((sheight>>1)+16-(logoheight>>1))

lgHighStart set	((-logoheight)+16)
lgLowStart	set (sheight)

lgAppearl	 set 50

	; nm,v1,v2,length
	AffMoveStart   LY1,lgHighStart,lgYPos,lgAppearl
	AffMoveStart   LY2,lgLowStart,lgYPos,lgAppearl

	; - - - prepare triple buffer
	lea	bmpf2_Data(pc),a0
	lea ScreenBmHexLogo(pc),a1
	lea bmpf2_Physic(pc),a2
	moveq  #2,d0
.lpbmd
		move.l	a0,(a2)+
		move.l	(a1)+,bmd_bm(a0)
		move.w	#256+16,bmd_Y2(a0) ; bob2 movement initial
		lea	bmd_sizeof(a0),a0
	dbf	d0,.lpbmd

	; - -to morf scroll
	STRUCTURE MorfScroll,0
		STRUCT	ms_pos,256*4
		STRUCT	ms_add,256*4
	LABEL ms_sizeof	; 2kb

	move.l	#ms_sizeof,d0
	moveq	#0,d1
	bsr	_InAlloc
	move.l	a0,scrollMorf
	move.l	a0,a2
	; - -set parallax scroll initial state
	move.l  CopDblHex(pc),a1
	lea	cdb_scrollvh(a1),a0
	move.w	#255,d0
.lpl
	move.w	d0,d1 ;255->0
	lsl.w	#2,d1 ;255*4->0
	neg.w	d1    ;-255*4->0
	add.w	#(256)*4,d1
	move.w  d1,(a0)+ ; with PF2NM version, just pf2 dx
	move.w	d1,d2
	swap	d2
	clr.w	d2
	move.l	d2,(a2)+ ; in morfable base
	clr.l	255*4(a2)
	dbf	d0,.lpl


	; - - - -end of load
	; have to wait minimal times if boot was fast
	ifd DOFULLWAIT

	; sadly have a false loop here
.fakeloadlp
	move.l	_fxTime,d0
	move.l	d0,_debugv+12

	cmp.l	#300*17,d0
	bge		.afterloadwait

	tst.b    _doEnd
	beq.b	.nodemoexit
		bsr _demoEnd
		jmp     __XCEXIT
.nodemoexit

	move.l    _GfxBase,a6
	CALL    WaitTOF


	bra		.fakeloadlp
.afterloadwait
	endc

	ifd    DOMUSIC
		jsr P61_End
		move.l	_mchip3,a0
		sub.l a1,a1
		sub.l a2,a2
		moveq #0,d0
		jsr P61_Init
	endc


	; end of init
	rts

; - - logo moves
 AffMoveVar	 LY1
 AffMoveVar	 LY2

scrollMorf:		dc.l	0
scrollMorfStep:	dc.w	0
; - -- - -
Logo1:	dc.l	0
Logo1Pal:	 dc.l	 0
;	 xdef	 bg2Bm
;	 xdef	 bg2Bmp
;bg2Bm:	 dc.l	 0
;bg2Bmp: dc.l	 0
;	 xdef	 bg3Bm
;	 xdef	 bg3Bmp
;bg3Bm:	 dc.l	 0
;bg3Bmp: dc.l	 0
	XDEF    txtileBm
	XDEF    txtileBmp
txtileBm:	  dc.l	  0
txtileBmp:	  dc.l	  0

	XDEF    haikBm
	XDEF    haikBmp
	XDEF    haikSprite
haikBm:	    dc.l    0
haikBmp:    dc.l    0
haikSprite:	dc.l	0

	XDEF    nois320Bm
	XDEF    nois256Bm
	XDEF    nois256Bmp
	XDEF    headBm
	XDEF    headBmp
nois320Bm:	dc.l    0
nois256Bm:	dc.l	0
nois256Bmp:	 dc.l	 0
headBm		dc.l	0
headBmp		dc.l	0

	XDEF    light1Bmc
	XDEF    light1Bmp
light1Bmc:	dc.l	0
light1Bmp:	dc.l	0

	XDEF    light2Bmc
	XDEF    light2Bmp
light2Bmc:	dc.l	0
light2Bmp:	dc.l	0

	XDEF	titBm
	XDEF	titBmp	  
titBm: 		dc.l	0
titBmp: 	dc.l	0

	XDEF    leyesBm
	XDEF    leyesBmp
leyesBm:	dc.l	0
leyesBmp:	dc.l	0

	
	XDEF	targetBm
	XDEF	targetBmp
	XDEF	spriteTarget
targetBm:		dc.l	0
targetBmp:		dc.l	0
spriteTarget:	dc.l	0

	XDEF	obs_Extruded
obs_Extruded:	dc.l	0

	XDEF    obs_Skull
obs_Skull:	 dc.l	 0

	XDEF    obs_Spike
obs_Spike:	 dc.l	 0

	XDEF    obs_greets
obs_greets:		dcb.l	 14,0

;	 XDEF    obs_Patchext2
;obs_Patchext2:	  dc.l	  0

copDbl:	dc.l	0
ScreenBmA:	dc.l	0
ScreenBmB:	dc.l	0
Palette:	dc.l	0
; - - - - - - - - - - - - - - - -  - - - - - - - - -
fx_cpu:
	; to disable:
;	 move.l    _GfxBase,a6
;	 CALL    WaitTOF
;	 rts
	; - - - blit copy logo pf2

	;move.w  #$00ff,$0dff000+$0180


;	 move.l	 $dff000+4,d0
;	 and.l	 #$1ff00,d0
;	 lsr.l	 #8,d0
;	 move.l	 d0,_debugv+4


	; move
	AffMoveStep LY1
	AffMoveStep LY2
	; when logo move stop, launch parralax morf
	tst.w   _mvStepLY1
	bne		.notrm	  
	tst.w   morfScrollState
	bne		.notrm
		move.w	#1,morfScrollState
		bsr SetMorfStr
.notrm


	cmp.l	#(300*7)-150,_fxTime
	blt	.notrm2
	cmp.w   #2,morfScrollState
	bge		.notrm2
		move.w	#2,morfScrollState
		bsr SetMorfStr
.notrm2



;	 move.w  #$0f0f,$0dff000+$0180


	bsr	_bmpf2_WaitDrawn

	move.l	_GfxBase,a6
	CALL    OwnBlitter
    CALL    WaitBlit    ; because first of app

	move.l  bmpf2_Drawn,a2

	AffGetw     LY1,d1
	move.w		d1,d4
	sub.w  		bmd_Y1(a2),d4
	beq	.nol1
		move.w	d1,bmd_Y1(a2)

	
	move.l  Logo1(pc),a0
	lea		sbm_SIZEOF(a0),a0	;bob shape struct is after gif bitmap struct

	;move.l	 ScreenBmHexLogo(pc),a1
	move.l	bmd_bm(a2),a1
	
	lea		sbm_SIZEOF(a1),a1	;bob destination struct is after screen bitmap

	move.w  #0,bod_clipX1(a1)
	move.w  #128+160,bod_clipX2(a1) ; marge+half screen

	move.w  #16,bod_clipY1(a1)
	move.w  #256+16,bod_clipY2(a1)

	move.w		#128+logoStartx,d0
	bsr _CopyBm

	
	; - - -clear some lines before, compute how much
	; according to draw buffer
	;move.l ScreenBmHexLogo(pc),a1
	move.l  bmpf2_Drawn,a2
	move.l	bmd_bm(a2),a1
	lea sbm_SIZEOF(a1),a1 ;bob destination  struct

	move.w	#128,d0
	AffGetw     LY1,d1
	sub.w  d4,d1

	move.w	#160,d2
	move.w	d4,d3
	ble	.nocl1
		bsr	_ClearBmRect
.nocl1
.nol1


;	 move.w  #$00ff,$0dff000+$0180

	; - - -
	 move.l  bmpf2_Drawn,a2

	AffGetw     LY2,d1
	move.w		bmd_Y2(a2),d4
	sub.w  		d1,d4
	ble	.nol2

		move.w	d1,bmd_Y2(a2)

logoStartx=32

	move.l  Logo1(pc),a0
	lea	sbm_SIZEOF(a0),a0	;bob shape struct is after gif bitmap struct

	move.l bmd_bm(a2),a1	
	lea sbm_SIZEOF(a1),a1 ;bob destination  struct
	;is  after  screen  bitmap
	move.w #128+160,bod_clipX1(a1) ; marge+half screen
	move.w #320+128,bod_clipX2(a1) ; bm width

	move.w		#128+logoStartx,d0
	bsr _CopyBm

 
	; - - -clear some lines before
	move.l  bmpf2_Drawn,a2
	move.l	bmd_bm(a2),a1
	lea 	sbm_SIZEOF(a1),a1 ;bob destination  struct

	move.w	#128+160,d0
	AffGetw     LY2,d1
	add.w	#logoheight,d1

	move.w	#160,d2
	move.w	d4,d3
	bsr	_ClearBmRect
.nol2


	; - - - - DO NOT BREAK DisownBlitter Pairs
	move.l  _GfxBase,a6
	CALL    DisownBlitter

	
	
	
	; - - - pass drawn bm to waiting queue
	bsr _bmpf2_PostDrawn



;	 move.w  #$0ff0,$0dff000+$0180


.noDraw

	; since there is no wait at all with triple buffer
	; wait each 5 frames to allow keyboard interupt
;	 lea waitSomeFrameCount(pc),a0
;	 move.w	 (a0),d0
;	 add.w	 #1,d0
;	 move.w	 d0,(a0)
;	 cmp	 #5,d0
;	 blt	 .nowt
;		 clr.w   (a0)
;;		  move.l    _GfxBase,a6
;		 CALL    WaitTOF
;.nowt
	; - - - only if less than 1 frame ?
	;old move.l    _GfxBase,a6
	;old CALL    WaitTOF

	XREF    _cpu_WaitTofOnNFrames
	bsr     _cpu_WaitTofOnNFrames


	rts
; - - - - - - - -
fadeOutColorDone:	dc.w	0	;REMOVE!
; - - - - - - - - - - - - - - - -  - - - - - - - - -
	XREF	_InFree
	XREF    _cc_FreeCopperDbl
	XDEF    fx_end_Load
fx_end_Load: ; thrown after fxLoadGo
	;
	move.l  scrollMorf(pc),a0
	bsr		_InFree

	; - - no more logo
; finally reuse triple buffer...
;	 lea ScreenBmHexLogo(pc),a6
;	 moveq	 #2,d7
;.lpc
;	 move.l	 (a6)+,a0
;	 bsr 	 _closeBm
;	 dbf d7,.lpc
	
	; - -
	move.l  fxDatHex,a0
	bsr	    _InFree
	clr.l   fxDatHex

	move.l  ScreenBmHex,a0
	bsr 	_closeBm
	clr.l   ScreenBmHex

	move.l  CopDblHex,a0
	bsr 	_cc_FreeCopperDbl
	clr.l   CopDblHex

; done before
;	 move.l  Logo1(pc),a0
;	 bsr _closeBm
;	 move.l  Logo1Pal(pc),a0
;	 bsr     _InFree

	move.l  spriteTarget,a0
	bsr     _CloseSprite
	clr.l   spriteTarget

	rts ; fx_end
morfScrollState:	dc.w	0
SetMorfStr:

	moveq  #32,d1

	;at end, must.	  move.w  d1,scrollMorfStep
	move.l  scrollMorf,a0
	move.w	#255,d0
.lpl
	move.l	(a0)+,d2
		move.l	#((128-16)*4)<<16,d3
		sub.l	d2,d3
	divs.l	d1,d3

	move.l	d3,255*4(a0)

	dbf	d0,.lpl

	move.w	d1,scrollMorfStep

	rts
;/// - - - ApplyDistort: apply distort on parallax
DistortStep:	dc.w	0
DistortState:	dc.w	0
; 32,16,4  or 64,8,3 or 128,4,2
DistTl=128
DistY=4
DistShift=2
	XDEF    ApplyDistort
	;a4 origin
	;a2 base to distort
	;d3 delta to write a2
ApplyDistort:

	lea DistortStep(pc),a0
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
		move.w	(a4),d2
		add.w	(a3)+,d2
		move.w	 d2,(a2)
		add.l	d3,a2
		addq	#4,a4
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
	; - reset previous lines
	subq	#1,d1
.lp2rest
		move.w	(a4),d2
		move.w	d2,(a2)
		add.l	d3,a2
		addq	#4,a4
	dbf	d1,.lp2rest
	; scrol outgoing distort
	tst.w	d0
	beq	.noy2
	subq	#1,d0
.lpy2
		move.w	(a4),d2
		add.w	(a3)+,d2
		move.w	 d2,(a2)
		add.l	d3,a2
		addq	#4,a4

	dbf	d0,.lpy2
.noy2

.end
.no
	rts
;///
; - - - - - - - - - - - - - - - -  - - - - - - - - -

	XDEF    fx_vblank_Load
fx_vblank_Load:

	bsr	_bmpf2_vbl_acknowledge
	; - - -  - - -

; vertical value gives obviously 0
;	 move.l	 $dff000+4,d0
;	 and.l	 #$1ff00,d0
;	 lsr.l	 #8,d0
;	 move.l	 d0,_debugv+4

	bsr     HexScreen

	; set lines per scroll, dual pf

	move.l  CopDblHex(pc),a1
	lea 	cdb_scrollvh(a1),a2
	
	move.w	scrollMorfStep(pc),d0
	tst.w	d0
	ble	.noscmorf

	; -  -
	move.l  scrollMorf,a0
	move.w	#63,d0
.lpl
	movem.l	 1024(a0),d1-d3/a1
	movem.l (a0),d4-d7

	add.l	d1,d4

	move.l	d4,(a0)+
	swap	d4
	move.w	d4,(a2)+

	add.l	d2,d5
	move.l	d5,(a0)+
	swap	d5
	move.w	d5,(a2)+

	add.l	d3,d6
	move.l	d6,(a0)+
	swap	d6
	move.w	d6,(a2)+

	add.l	a1,d7
	move.l	d7,(a0)+
	swap	d7
	move.w	d7,(a2)+

	dbf	d0,.lpl
    sub.w  #1,scrollMorfStep
	; - - after morf, enable distort
	tst.w   scrollMorfStep
	bgt	.nosd1
		; is reached once.
		move.w  #1,DistortState
		move.w	#DistTl,DistortStep
.nosd1
	
.noscmorf


	; - - apply distort
	tst.w   DistortStep
	beq	.nodsty
		move.l  scrollMorf,a4
		; a1 copdbl
        move.l  CopDblHex(pc),a1
		lea 	cdb_scrollvh(a1),a2  ; to write
		moveq	#2,d3	; dx on dest.
		bsr ApplyDistort
.nodsty






;	 move.l  CopDblHex(pc),a1
;	 lea cdb_scrollvh(a1),a0

;	 move.w	 #255,d0
;.lpl
;	 move.w	 d0,d1 ;255->0
;	 lsl.w	 #2,d1 ;255*4->0
;	 neg.w	 d1    ;-255*4->0
;	 add.w	 #(256)*4,d1

;	 move.w  d1,(a0)+ ; with PF2NM version, just pf2 dx
;	 ;move.w  #0,(a0)+
;	 dbf d0,.lpl

;-- - - - set scroll, switch copperlist
	; - - set bitmaps with scrolls into work copperlist
	move.l  ScreenBmHex(pc),a0
	move.l  CopDblHex(pc),a1 ;copperptr
	; - - -get x coord d0
	move.w  scrxHex,d0
	and.w   #$00ff,d0 ;1f*4
	move.w  scryHex,d1
	and.w   #$001f,d1
;bmpf2_Physic:	 dc.l	 0
;bmpf2_Avail:	 dc.l	 0	 ;vbl->cpu dr
;bmpf2_Drawn:	 dc.l	 0	 ;cpu->cpu wp
;bmpf2_WaitPhys: dc.l	 0	 ;cpu->vbl
;bmpf2_VblAck:	 dc.l	 0	 ;vbl  for vblank to check visible

	
	; pf2 triple buffer switch

	bsr	_bmpf2_vbl_SetWaitOrPhys
	;a2 out
    move.l	bmd_bm(a2),a2	; bm pf2

	move.w	#16,d3 ; pf2y
;;	  bsr _cc_setLineScrollsPF2NM
	XREF    _cc_setLineScrollsHEX
	bsr _cc_setLineScrollsHEX

;measure
;	 move.w  #$0009,$0dff000+$0180

	; - - -  -
	move.l	CopDblHex(pc),a1 ;copperptr
	bsr	_cc_switchCopper ; active only next vblank
	
	rts
;/// - - - - - - _cc_setLineScrollsPF2NM
; special version that does parallax scroll on just DPF2
; and no vertical mult.

	XDEF    _cc_setLineScrollsPF2NMOLD
_cc_setLineScrollsPF2NMOLD:
    ; a0 struct Bitmap
	; a1 copperDbl
	; a2  struct Bitmap pf2
	; d0 pf1x
	; d1 pf1y
	movem.l	 a0/a1/a2,-(sp)

	lea	cdb_scrollvh(a1),a3


	move.w	(a3),d2	; PF2x

	move.l	cdb_CopA(a1),a1
	bsr    _cc_setBmAGADPF


	movem.l	 (sp),a0/a1/a2 ; cdb_

	lea		cdb_scrollvh(a1),a3 ; one buffered yx scrolls per line

	; a1 cdb_ -> cp_
	move.l	cdb_CopA(a1),a1	; double buffered copper

	move.w	cp_nbLines(a1),d0
	subq	#2,d0	; start at line1

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


		; last use of a1, scramble shit
 ;;old elea	cp_scrollw+4(a1),a2	; in copper, point bltcon1
	; in this version, use ptr -8 for bplcon1 and bpl2mod
	; +4 ?
	lea cp_colorw+4(a1),a2
		
		;+1 because we modify bpl1mod in previous line

	; -  -
;	 move.w	 VHSIZE(a3),d1
;	 move.w	 d1,a6	 ; a6 first Y pf2
;	 move.w  (a3),a5 ; first Y pos PF1, used for bitmap pointers

	addq	#2,a3


	;  - -const bplcon1 for dpf1
	clr.l	d3
	move.l	cp_bplcon1(a1),a4
	move.w	(a4),d3
;	 move.l	 d3,_debugv+8

	move.l	-4(a2),a4
	move.w	d3,-6(a4)


	and.w	#$0f0f,d1	;pf1 low scroll bits already there

	move.l	d5,a1 ; now a1 defmodpf2/bprpf2


	bra	.loop64
	nop
	cnop	0,16	; inst cache align
.loop64
; - - - - -  -
;d0.w loop dec
;d1 dy
;d2 dx then tool
;d3 compute bltcon1
;d4 byte 8align dx
;d5.w
;d6 "previous BDx" , pf2, pf1
;d7 previous bdx pf2 ?

;old a0 sbm 	-> then a0.w  default bpl1mod
;old a1 cp_then -> then a1.w  bm_ byteperRow

; a0->  defmodpf1/bprpf1
; a1->  defmodpf2/bprpf2

;a2 bplcon1// ptr
;a3	Y.w/X.w precomp base
;a4 comp
;a5
;a6 NEW pf2 prevY

; - - -  compute start

	;playfield2
	move.w  (a3)+,d2

	move.w	d2,d4	;d4 XPF1/XPF2
	neg.w	d2	; it's the 8 low, consider and $00ff

	bfins	d2,d3{18:2} ; note d3 pf1 bits are set
	lsr.w	#2,d2
	bfins	d2,d3{24:4}
	lsr.w	#4,d2
	bfins	d2,d3{16:2}

	move.l	(a2),a4
	move.w	d3,-6(a4) ; bplcon1
	; - - - - -  - - - - -  - - - bpl2mod
	; pf2 first, y is in high d2
	add.w	#(63*4)+3,d4 ;xpf2      aka 255
	asr.w	#8,d4; >>6 >>2
	sub.w	#1,d4
	lsl.w	#3,d4

	move.l	-4(a2),a4 ; previous line

	move.w	a1,d5

	sub.w	d6,d5
	add.w	d4,d5
	move.w	d4,d6  ; prev=current

	move.w	d5,-2(a4) ; prevline bpl2mod

	addq	#4,a2

	dbf	d0,.loop64

	movem.l	 (sp)+,a0/a1/a2
	rts
;///

fx_end:
	move.l  Logo1(pc),a0
	bsr		_closeBm
	;clr.l   Logo1

	rts

; - - -  fx table
	XDEF fx_Load
		; fx_end_load is done next effect fx_LoadGo
fx_Load:	dc.l	fx_init,fx_cpu,fx_end,fx_vblank_Load

