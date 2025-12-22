
    opt c+
    opt    ALINK

    include graphics/graphics_lib.i
    include graphics/gfxbase.i
    include hardware/custom.i

    include demodata.i

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
	XREF	_InAlloc

	XREF	_pScreenA
	XREF	_pScreenB

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

    XREF    Playrtn
    XREF    P61_Init
    XREF	P61_Music
    XREF    P61_End
	XREF    _doEnd

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

	include blitGrid.i

	include "/res/dat.i"

	XREF    CopDblHex

    section code,code

	XREF    _initBlitGrid
	XREF    _BlitGrid_setTornado
	XREF    _drawBlitGrid

	XREF    _cpu_WaitTofOnNFrames

; - - - - - - - - - - - - - - - -  - - - - - - - - -
fx_init:

	move.l	#blg_SIZEOF,d0
	clr.l	d1
	bsr	_InAlloc
	move.l	a0,blitGrid

	move.l	ScreenBmHexLogo,a1
	move.l	#14,d0 ; byte horizontal shift
	move.w	#16,d1	; nb lines start write
	bsr	_initBlitGrid

	;a0 blg_
	;d0 angle force
	;d1 zoom force

    move.l  blitGrid(pc),a0
	move.w	#256,d0
	;no move.w	#256,d1
	bsr _BlitGrid_setTornado

	;a0 blg_
	;a1 bm_
	;d0.l dx byte start write
	;d1.w dy write start line
	; never be null !
;old	move.l  bmpf2_Physic,LastDrawn

	rts
; - - - -  - -
	XDEF    blitGrid
blitGrid:	dc.l	0
; - - - - - - - - - - - - - - - -  - - - - - - - - -
;LastDrawn:	 dc.l	 0
fx_cpu:

	; - - get bitmap or wait
	bsr     _bmpf2_WaitDrawn

	move.l	_GfxBase,a6
	CALL    OwnBlitter
    CALL    WaitBlit    ; because first of app


frameZoom=50


	;a0 blg_
	;a1 bm_ write
	;a3 bm_ read
    move.l  blitGrid(pc),a0
	
	move.l  bmpf2_Drawn,a1
	move.l	bmd_bm(a1),a1
	move.l  bmpf2_LastDrawn,a3
	move.l	bmd_bm(a3),a3
	
	;OLD move.l  ScreenBmHexLogo+4(pc),a1
	;OLD move.l  ScreenBmHexLogo(pc),a3
	
	; test:plot 4 pixel of zeros in read center
	move.w	 blg_frame(a0),d0
	cmp.w	#frameZoom,blg_frame(a0)
	ble		.nocleanpix
	move.l	bm_Planes(a3),a4
	move.l	sbm_PlaneSize(a3),a5
	add.l	#(56*(127+16))+26+6,a4
	move.l	#$fffe7fff,d6
	move.w	#3,d7
.lpclb
		and.l	d6,(a4)
		and.l	d6,56(a4)
		add.l	a5,a4
	dbf	d7,.lpclb
.nocleanpix

	;then only
	bsr	_drawBlitGrid



	move.l  _GfxBase,a6
	CALL    DisownBlitter

	; - - - pass drawn bm to waiting queue
	bsr     _bmpf2_PostDrawn

	; - - - at some point, update displacement
	move.l  blitGrid(pc),a0
	move.w	 blg_frame(a0),d0
	cmp.w	#frameZoom,d0
	bne	.noupdbg
		move.w	#256-16,d0 ; means rot+zoom
		bsr _BlitGrid_setTornado
.noupdbg


.noDraw

	; - - at some point, fade out hex effect

	cmp.l	#300*5-150,_fxTime
	blt	.nosfo
	tst.w   fadeOutColorDone
	bne		.nosfo
		move.w #1,fadeOutColorDone
		XREF    StartFadeHexout
		bsr		StartFadeHexout
.nosfo
	
	bsr 	_cpu_WaitTofOnNFrames
  

	rts
fadeOutColorDone:	dc.w   0
; - - - - - - - - - - - - - - - -  - - - - - - - - -
	XREF	_InFree
	XREF    _cc_FreeCopperDbl
	XREF    fx_end_Load
;fx_end:
;	 rts ; fx_end
	XREF    fx_vblank_Load
;fx_vblank:
;	 bsr fx_vblankGo
;	 rts fx_vblank;

; - - -  fx table
	XDEF fx_LoadGo
fx_LoadGo:	  dc.l	  fx_init,fx_cpu,fx_end_Load,fx_vblank_Load

