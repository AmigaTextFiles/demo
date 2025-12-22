

    opt c+
    opt    ALINK

    include graphics/graphics_lib.i  
    include graphics/gfxbase.i
    include hardware/custom.i

    include demodata.i
	include "/res/dat.i"

	include	k3d.i

baseModulo=40
bpr1=64
def1Mod=(bpr1-baseModulo)
bpr2=56
def2Mod=(bpr2-baseModulo)

pf2Xs=(128*4)

dochain	equ	1


	XREF    palShade
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
	XREF    light2Bmp

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


	XREF    _tileBackground
	XREF    pf1Bm

	XREF    obs_Skull

	XREF    light2Bmc

	XREF    _bezier2D
	XREF    _bezier1D

	include blitGrid.i
 
    section code,code

fx_d:
	;test
	move.l    _GfxBase,a6
	CALL    WaitTOF

	rts


; - - - - - - - - - - - - - - - -  - - - - - - - - -
fx_init:

    ;d0.w: nb planes: 1->8
    ;d1: prefsbits: CCLR_...
	move.w    #8,d0    ;d0.w: nb planes: 1->8
	move.b    #CCLR_DUALPF|CCLR_DOCOLORS,d1
	or.b    #CCLR_64|CCLR_WL_HC,d1

	bsr    _cc_InitLowResAGADbl ; d6/d7 a3/a4/a5/a6 preserved
	move.l	a0,CopDblE

	; patch bplcon4 in copper to have sprite palette at 128
	move.l	cdb_CopA(a0),a1
	move.l	cp_bplcon1(a1),a2
	move.w	#$0022,12(a2)
	 move.l	 cdb_CopB(a0),a1
	move.l	cp_bplcon1(a1),a2
	move.w	#$0022,12(a2)


	; - - - - -  -
	lea		bgTileSt3,a2
	move.l	pf1Bm,a1
	move.l  txtileBm,a0

	bsr		_tileBackground

	; - - - - - - -

	lea     objlist,a1
	move.l  obs_Skull,(a1)
	moveq  #1,d0
	bsr     _Scene3d_init
	move.l  a0,_scn3d_ext3
	;set light
	move.l	light2Bmc,scn_lightBM(a0)


	move.l  txtileBmp,a0
	move.l  CopDblE(pc),a1 ;   a1 dblcopper
	clr.w   d0
	bsr _SetCopperPaletteAgaDbl

	XREF    tunBmp
;	 move.l  light2Bmp,a0
	move.l  tunBmp,a0	; at start
	move.l  CopDblE(pc),a1 ;   a1 dblcopper
	move.w  #1,d0
	bsr _SetCopperPaletteAgaDbl



	; - - declare 3 BMs dirty
	bsr     _bmpf2_setAllDirty


	; -  -init spritescreen

	XREF	_initSpriteScreen
	XREF    rasterLogoBm
	
	move.l	rasterLogoBm,a0
	;a0 bm 320x256 4c
	; return a0: spm_
	bsr     _initSpriteScreen
	move.l	a0,rasterLogoSprite

	; some fake palette for sprite
	lea		fakespritepal(pc),a0
	move.l	CopDblE(pc),a1 ;   a1 dblcopper
	move.w  #2,d0   ; sprite colors 16-31
	bsr _SetCopperPaletteAgaDbl


	; init raster bars color table...
	lea rasterColors(pc),a0
	clr.w	d1
	move.w	#15,d0
.lprc
	move.w	d0,d2
	move.w	d1,d3
	lsl.w	#8,d3
	or.w	d3,d2
	move.w	d2,(a0)+

	move.w	d1,d2
	move.w	d0,d3
	lsl.w	#8,d3
	or.w	d3,d2
	move.w	d2,15*2(a0)

	addq	#1,d1
	dbf	d0,.lprc


	XREF    blitGrid
	XREF    _initBlitGrid
	
	move.l	blitGrid,a0
	;used just for the modulo:
	move.l  bmpf2_LastDrawn,a1
	move.l	bmd_bm(a1),a1
	; just set where it read/writes
	move.l	#8,d0 ; byte horizontal shift
	move.w	#16,d1	; nb lines start write
	bsr	_initBlitGrid
	
	
	XREF    _BlitGrid_setTornado
	move.l  blitGrid,a0
	move.w	#256,d0
	;no move.w	#256,d1
	bsr _BlitGrid_setTornado
  

	rts
; - - - - - - - -
; 4*4 used to change sprite palette on bank2
rastercp:	dc.l	(bplcon3<<16)|($3040)
			dc.l	($0182<<16)|0	;color for sprite 0,1,4
			dc.l    (($0182+8)<<16)|0	; for sprites 2,3
			dc.l    (bplcon3<<16)|($1040)
			; use same pointers than table before !
rasterColors:	 dcb.w	 32,0

fakespritepal:	dc.w	8,0
				dc.b	0,0,0
				dc.b	128,192,250 ;front
				dc.b	24,24,32
				dc.b	240,240,250

				dc.b	0,0,0
				dc.b	128,192,250 ;front
				dc.b	24,24,32
				dc.b	240,240,250
_scn3d_ext3: dc.l	 0
CopDblE:	dc.l	0
rasterLogoSprite:	dc.l	0
; - - list of obs:
objlist:
	dc.l    0
objlistEnd
redeyesbz1:
redmin=92
redmax=192-32
	dc.w	2

	dc.w	redmin,redmax/2,redmax/2,redmax
	dc.w	redmax,redmax/2,redmax/2,redmin

redeyesval:	dc.w	0

; - - - - - - - - - - - - - - - -  - - - - - - - - -
fx_cpu:

	bsr	_bmpf2_WaitDrawn

	; - blit or draw here

	move.l	_GfxBase,a6
	CALL    OwnBlitter
    CALL    WaitBlit    ; because first of app



.dotornado


	; - -copy background of last effect
	tst.w   firsttunDone
	bne		.nofirsttun
	;to pf2
	move.l  bmpf2_Drawn,a1
	move.l	bmd_bm(a1),a1
	 lea	sbm_SIZEOF(a1),a1	;bob destination struct

	XREF    tunBm
	move.l  tunBm,a0
	lea	sbm_SIZEOF(a0),a0	;bob shape struct is after gif bitmap struct

	move.w	#64,d0			    ;x
	move.w	#16,d1    		    ;y
	bsr _CopyBmAl16NoClip

	move.w	#255,maxypf2
	move.w	#1,firsttunDone
	bra	.endblit
.nofirsttun



frameZoom=200
endTornado=300*4



	;a0 blg_
	;a1 bm_ write
	;a3 bm_ read

	move.l	_fxTime,d0
	cmp.l	#endTornado,d0
	bge		.doSkull3d
	
	
	cmp.l	#frameZoom,d0
	ble		.zalreadychanged
	tst.w   changedToZoom
	bne		.zalreadychanged
		move.l  blitGrid,a0
		move.w	#256-16,d0 ; means rot+zoom
		bsr _BlitGrid_setTornado
		move.w	#1,changedToZoom
.zalreadychanged





	move.l  bmpf2_Drawn,a1
	move.l	bmd_bm(a1),a1
	move.l  bmpf2_LastDrawn,a3
	move.l	bmd_bm(a3),a3
	move.l  blitGrid,a0

; - - - - - - -
	; test:plot 4 pixel of zeros in read center
	move.l	_fxTime,d0
	cmp.l	#frameZoom,d0
	ble		.nocleanpix

	move.l	bm_Planes(a3),a4
	move.l	sbm_PlaneSize(a3),a5
	add.l	#(56*(127+16))+20+6,a4
	move.l	#$fffe7fff,d6
	move.w	#3,d7
.lpclb
		and.l	d6,(a4)
		and.l	d6,56(a4)
		add.l	a5,a4
	dbf	d7,.lpclb
.nocleanpix
; - - - - - - -
	;then only
	XREF    _drawBlitGrid
	bsr		_drawBlitGrid
	bra	.endblit




.doSkull3d

	tst.w   resetskullpaletteDone
	bne		.nowdone
	; safe to hack coppers  on cpu because palette offset are constants..
	move.l  light2Bmp,a0
	move.l  CopDblE(pc),a1 ;   a1 dblcopper
	move.w  #1,d0
	bsr 	_SetCopperPaletteAgaDbl
	move.w	#1,resetskullpaletteDone
.nowdone
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

	move.l	_mfast,a6
	lea		sf_Exp(a6),a6
	;d1 is y
	move.w	#$0050,d1
	move.l	_fxTime,d0
	sub.l	#endTornado,d0
	lsr.l	#2,d0
	cmp.l	#256,d0
	bge.b	.noarrive
		move.w	#255,d2
		sub.w	d0,d2
		move.w	(a6,d2.w*2),d2
		lsl.w	#2,d2
		sub.w	d2,d1
.noarrive
	move.l	_scn3d_ext3(pc),a0
	move.l	scn_obj(a0),a1
	move.w  #$0440,obr_tz(a1) ; translate to front
	move.w  d1,obr_ty(a1)
	move.l  _fxTime,d0
	sub.l	#endTornado,d0
	lsr.w   #2,d0
; move.w #120,d0

	sub.w	#256+64,d0
	move.w  d0,obr_o3(a1)	; y axis
;	 mulu.w	 #6,d0
;	 lsr.l	 #3,d0

 move.w #20,d0
	move.w  d0,obr_o1(a1)


	move.l  bmpf2_Drawn,a1
    bsr     _Scene3d_render

.woot

	; - - - - DO NOT BREAK DisownBlitter Pairs
.endblit
	move.l  _GfxBase,a6
	CALL    DisownBlitter

	; - - - pass drawn bm to waiting queue
	bsr 	_bmpf2_PostDrawn

	; - -after n time set punchline

	XREF    PunchlinePaster
	XREF    punchlinesBm
	move.l	_fxTime,d0
	cmp.l	#15*300,d0
	blt.b	.nopch
		tst.w   punchlineDone
		bne.b	.nopch

	;a0 spm_
	;a1 bm_ orig.
	;d0 punchline index 0-7
		move.l  rasterLogoSprite(pc),a0
		move.l  punchlinesBm,a1
		
		move.w	$dff000+vhposr,d0
		and.w	#$0007,d0
;		 moveq	 #7,d0
		bsr		PunchlinePaster
		move.w	#1,punchlineDone
.nopch



	; - - - - - - change eye color 31
	; one curve:
	lea     redeyesbz1(pc),a0
	move.l  _fxTime,d0
	lsl.l	#2,d0
	and.l	#$01ff,d0
	lea     redeyesval(pc),a1
	bsr     _bezier1D
	;a1 copdbl
	;d0 color index in first bank
	;d1 r 8b
	;d2 g 8b
	;d3 b 8b
	move.l  CopDblE,a1
	moveq	#31,d0
	move.w	redeyesval(pc),d1	;r
	move.w	#16,d2				;g
	move.w	#10,d3				;b
		XREF    setColorBk0
	bsr		setColorBk0
	; - - - - - - -

	XREF    _cpu_WaitTofOnNFrames
	bsr     _cpu_WaitTofOnNFrames

	rts
punchlineDone:	dc.w	0
firsttunDone:	dc.w	0
changedToZoom:	dc.w	0
resetskullpaletteDone:	dc.w	0
; - - - - - - - - - - - - - - - -  - - - - - - - - -
fx_end:

	move.l	_scn3d_ext3(pc),a0
	bsr		_InFree


	rts
; - - - - - - - - - - - - - - - -  - - - - - - - - -
; called from vblank:
; configure pf1 scroll and palette
pf1ScrollValuesD:
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
	
	
	move.l  _fxTime,d6	; y scroll
	lsr.l	#3,d6
	move.l	d6,d1
	lsr.l	#1,d1

	;horizontal scroll disabled on pf1 to have sprites:

	rts
; - - - - - - - - -  - -
addBarPfD:
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

	move.l  CopDblE(pc),a1
	lea     cdb_scrollvh(a1),a2
	lea     cdb_scrollvh2(a1),a3

	lea	(a2,d1.w*4),a2
	lea	(a3,d1.w*4),a3

	move.l	#(((16+48*2)*64)<<16)|((128+32)*4),a4

.lp
		move.w	d3,(a2)+
		move.w	#64*4,(a2)+
		add.w   #bpr1,d3
		move.l	a4,(a3)+


	dbf		d2,.lp


.nobar
	rts

;/// - - - - - background tilage data
; 0end 1 norm 2 inv.
; src x0,src y0, w, h, dstx0 , dsty0

bgTileSt3:
	dc.w	1,0,0,16,64,0,0

	dc.w	1,24,192,8,32,16,0
	dc.w	1,24,192,8,32,16,32
	dc.w	1,24,192,8,32,16,64
	dc.w	1,24,192,8,32,16,64+32

	dc.w	1,24,64,8,128,24,0

	dc.w    2,0,0,16,64,0,64

	dc.w	0


;///
DistortTTimer:	dc.l	0
DistortStepR:	 dc.w	 0
;;DistortStateR:   dc.w	   0
; 32,16,4  or 64,8,3 or 128,4,2
DistTl=128
DistY=4
DistShift=2
ApplyDistortE:

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
		;add.w   d2,2(a2)
		add.w	d2,VHSIZE+2(a2)
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
		;add.w   d2,2(a2)
		add.w	d2,VHSIZE+2(a2)
		addq	#4,a2
	dbf	d0,.lpy2
.noy2

.end
.no
	rts

PalOffset1:		dc.l	(64*(24))<<16
PalOffset2:		dc.l	(64*(48+2))<<16
; - - we have diffrent vblank because
; we patch copperlist to have 7 sprites
; and does specia wait state things
fx_vblank:

	add.w	#1,rastimer

	; use func that set pf1 movements:
	bsr     pf1ScrollValuesD

	; andval
	move.w	#$007f,d3

	move.l  CopDblE(pc),a1
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
	;d6 y scroll
	move.w	d6,d5
	and.w   d3,d5	;0->127
	move.w	#128-1,d0
	sub.w	d5,d0

	lsl.w	#6,d1 	;scrollbehind= *modpf1

	lsl.w	#6,d5

	; choose Y scroll speed
	btst	#7,d6
	beq.b	  .nx1
	; - -cas2 back

		move.l  PalOffset2(pc),a4

.lpscv1a
		and.w	#$1fc0,d1
		move.w	d1,(a2)+ 	;y pf1*modulopf1
		clr.w	(a2)+	 ;x pf1 &255
		add.w	#bpr1,d5
		add.w	#bpr1,d1
		move.l	a4,(a3)+ ; color index, xpf2 start
	dbf	d0,.lpscv1a
		
		bra	.nxenda
.nx1
	; - -cas1: front
	move.l  PalOffset1(pc),a4

.lpscv1b
		move.w	d5,(a2)+ 	;y pf1*modulopf1
		clr.w 	(a2)+	 ;x pf1 &255
		add.w	#bpr1,d5
		add.w	#bpr1,d1
		move.l	a4,(a3)+ ; color index, xpf2 start
	dbf	d0,.lpscv1b


.nxenda

; - -  - always 128
	moveq	#127,d0
	clr.w	d5

	; choose Y scroll speed
	btst	#7,d6
	bne.b	  .nx2
        move.l  PalOffset2(pc),a4
		; back case
.lpscv2a
		and.w	#$1fc0,d1
		move.w	d1,(a2)+ ;y pf1*modulopf1
		clr.w	(a2)+
		add.w	#bpr1,d5
		add.w	#bpr1,d1
	move.l	a4,(a3)+ ; color index, xpf2 start

	dbf	d0,.lpscv2a

		bra 	.nx2end
.nx2
		move.l  PalOffset1(pc),a4
		; front case
.lpscv2b
	move.w	d5,(a2)+ ;y pf1*modulopf1
	clr.w	(a2)+	 ;x pf1 &255
	add.w	#bpr1,d5
	add.w	#bpr1,d1
	move.l	a4,(a3)+ ; color index, xpf2 start

	dbf	d0,.lpscv2b

.nx2end

; - - loop 3
	; choose X scroll speed
	btst	#7,d6
	beq.b	  .nx3
        move.l  PalOffset2(pc),a4
		;back

	and.w   d3,d6
	sub.w	#1,d6
	blt.b	.nolpscv3a
.lpscv3a
	and.w	#$1fc0,d1
	move.w	d1,(a2)+ ;y pf1*modulopf1
	clr.w	(a2)+	 ;x pf1 &255
	add.w	#bpr1,d1
	move.l	a4,(a3)+ ; color index, xpf2 start

	dbf	d6,.lpscv3a
.nolpscv3a



		bra	.nx3end
.nx3
		move.l  PalOffset1(pc),a4
		;front


	clr.w	d5
	and.w   d3,d6
	sub.w	#1,d6
	blt.b	.nolpscv3b
.lpscv3b
	move.w	d5,(a2)+ ;y pf1*modulopf1
	clr.w	(a2)+	 ;x pf1 &255
	add.w	#bpr1,d5

	move.l	a4,(a3)+ ; color index, xpf2 start

	dbf	d6,.lpscv3b
.nolpscv3b



.nx3end
	
	
; - - - - - - - - - - -  - -
	bsr     addBarPfD
 ; - - - -  - - - - - - - -

	move.l	DistortTTimer(pc),d0


	move.l	_fxTime,d1
	sub.l	#300*1,d1	; no distort when soon
	blt		.nodsty

	lsr.l	#3,d1
	lsr.l	#8,d1

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
		move.l  CopDblE(pc),a1
		lea     cdb_scrollvh(a1),a2
		bsr ApplyDistortE
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
	move.l  CopDblE(pc),a1

	bsr     _cc_setLineScrollsDPFTileS


	; - - apply sprites

;	 move.l	 _fxTime,d3
;	 sub.l	 #300*3,d3
;	 blt	 .nospr
;

;	 move.w	 d3,d4
;	 and.w	 #$01ff,d3
;	 lsr.l	 #8,d4
;	 lsr.l	 #1,d4
;	 and.w	 #7,d4
;	 neg.w	 d3
;	 add.w	 #256,d3
;	 move.w	 d3,d1

;	 bra.b	 .sprok
;.nospr
		; sprite off down
;		 move.w	 #257,d1
;.sprok

	; - - - - SPRITES

	XREF    _setSprite4

startSprite=300*3
	move.l  _fxTime,d3
	sub.l   #startSprite,d3
	blt	    .nospr

	cmp.l	#6*300,d3
	bgt		.nospr	; if late, sprite are set forever, just ok

	lsr.l	#2,d3
	move.l	d3,spritemoveTime

	lea		decalSprite(pc),a6
	clr.w   decalsprValues+4	; index to 0

	move.w	#4,d7
.lpspr	  
	move.l	d7,-(sp)
	;
	move.l  spritemoveTime(pc),d0
	cmp.l	#255,d0
	bge		.nobez

	lea     decalsprValues(pc),a1
	lea     spritecomebez(pc),a0
	bsr     _bezier2D
	bra	.endbez
.nobez
	clr.l   decalsprValues
.endbez
	; - - - -
    lea 	decalsprValues(pc),a2
	movem.w	(a2),d0/d1/d2
	add.w	(a6)+,d0
	cmp.w	#$80*4-(64*4),d0
	bgt	.noclipx1
		move.w  #$80*4-(64*4),d0
.noclipx1

	add.w	#45,d1
	move.l  rasterLogoSprite(pc),a0
	move.l  CopDblE(pc),a1

		bsr 	_setSprite4

	add.w	#1,decalsprValues+4
	add.l	#-40,spritemoveTime

	move.l	(sp)+,d7
	dbf		d7,.lpspr
.nospr
	; - - -
	move.l  CopDblE(pc),a1
	bsr		_cc_switchCopper

	rts
; - - - -
spritecomebez:
	dc.w	1

	dc.w	-320*4,128
	dc.w	-160*4,128
	dc.w    0,64
	dc.w	0,0
spritemoveTime:	dc.l	0
decalSprite:	;time decal
				;x decal
			dc.w	($80*4)
			dc.w	($80*4)+64*4
			dc.w	($80*4)+128*4
			dc.w	($80*4)+192*4
			dc.w	($80*4)+256*4

				; X,Y,index
decalsprValues:	dc.w	0,0,0


minypf2:	dc.w	0
maxypf2:	dc.w	254
rastimer:	dc.w	0
;/// - - - - - - _cc_setLineScrollsDPFTileS

_cc_setLineScrollsDPFTileS:
    ; a0 struct Bitmap
	; a1 copperDbl
	; a2  struct Bitmap pf2
	movem.l	 a0/a1/a2,-(sp)

	lea	cdb_scrollvh(a1),a3
	move.w	(a3),d1	;* dudulo now
	lsr.w	#6,d1


;	 move.w	 2(a3),d0
	clr.w	d0

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

	; remember the last ratser index/line ratser index
	move.l	#$ffff0000,d4
	move.w  rastimer(pc),d4

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
;NOX1	 move.w	 d2,d4

	move.w  #bplcon1,(a0)+
; a1 -

;a2 bplcon1// ptr
;a3	Y.w/X.w precomp base
;a4 -> prev line BPL1Mod
;a5 pf1 prev Y
;a6  -> scramble table for bplcon1

; - - -  compute start
;NOX1	 clr.w	 d3
;	 move.b	 d2,d3
;	 move.w	 (a6,d3.w*2),d3


	;playfield2
	move.l  (VHSIZE-4)(a3),a1  ;PaletteIndex / dXpf2
	move.w	a1,d2
	and.w	#$00ff,d2
	move.w	(a6,d2.w*2),d2
	lsl.w	#4,d2
;NOX1	 or.w	 d2,d3

	move.w	d2,(a0)+ ; bplcon1
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
;	 add.w	 #255,d4 ; aka 255
;	 asr.w	 #8,d4; >>6 >>2
;	 subq	 #1,d4
;	 lsl.w	 #3,d4


 move.w	#bpl1mod,(a4)+

	; set 8balign modulos of previous line
	; it's defaultmod -prevdx + thisdx

	;a5 prev bm delta (y+x)

	move.w  #def1Mod-(bpr1),d5

	swap	d2		;ly * pf1 modulo
;NOX1	 add.w	 d4,d2

	sub.w	a5,d5
	move.w	d2,a5
	add.w	d2,d5

	move.w	d5,(a4) ; prevline bpl1mod
	move.l	a0,a4	; next
	addq	#8,a0	; let place for bpl1Mod/bpl2mod


	; - - - - - - - - PALETTE CHANGE
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
	rept    5
		movem.l (a1)+,d2/d3/d5
		movem.l d2/d3/d5,(a0)
		lea	    12(a0),a0
	endr

	bra	.nospriteraster ; can't on same line !
.nopalchange
	; - - can do sprite raster here
	move.w	d4,d2
	lsr.w	#3,d2
	swap	d4
	cmp.w	d4,d2
	beq	.nochangeraster
		move.w	d2,d4
	; - - - change color of sprite using 4 coper moves
	; swicth bank/ color 1 , color5, switch bank
	lea 	rastercp(pc),a1
	move.l	(a1)+,(a0)+
	movem.l (a1)+,d3/d5
	and.w	#$001f,d2
	move.w	4(a1,d2.w*2),d3
	move.w	d3,d5
	movem.l d3/d5,(a0)
	addq	#8,a0
	move.l	(a1)+,(a0)+

.nochangeraster
	swap	d4

.nospriteraster
; - - - when reach line 200
	swap	d7
	add.w	#$0100,d7 ; vertical copper wait

	cmp.w   #$0001,d7
	bne.b .nopt
		move.l  #$ffdffffe,(a0)+    ; pal l256 jump trick
.nopt
	swap	d7
	add.w  #1,d4
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
;NOX1	 move.w	 d2,d4

	move.w  #bplcon1,(a0)+
; - - -  compute start
;NOX1	 clr.w	 d3
;	 move.b	 d2,d3
;	 move.w	 (a6,d3.w*2),(a0)+ ; bplcon1
	clr.w	(a0)+

	; - - - - -  - - - - -  - - - bpl2mod
	; pf2 first, y is in high d2


	; - - - - - - - - -- -- - -

	; - - - find the -8,0,8,16,24 part
;	 add.w	 #255,d4 ; aka 255
;	 asr.w	 #8,d4; >>6 >>2

 move.l	 #(bpl2mod<<16)|def2Mod,(a4)+

;	 subq	 #1,d4
;	 lsl.w	 #3,d4

 move.w	#bpl1mod,(a4)+

	moveq	#def1Mod-(bpr1),d5

	swap	d2		;ly*64 fixed modulo
;	 add.w	 d4,d2

	sub.w	a5,d5
	move.w	d2,a5
	add.w	d2,d5

	move.w	d5,(a4) ; prevline bpl1mod
	move.l	a0,a4	; next
	addq	#8,a0	; let place for bpl1Mod/bpl2mod

	; - - - -- - PALETTE CHANGE RUBEGOLBER
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





; - - -  fx table	 
	XDEF fx_3DExt3
fx_3DExt3:	  dc.l	  fx_init,fx_cpu,fx_end,fx_vblank






