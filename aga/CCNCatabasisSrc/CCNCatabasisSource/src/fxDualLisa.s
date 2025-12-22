

    opt c+
    opt    ALINK

    include graphics/graphics_lib.i  
    include graphics/gfxbase.i
        include hardware/blit.i
    include hardware/custom.i

    include demodata.i
	include "/res/dat.i"

	include	k3d.i

baseModulo=48
bpr1=48
def1Mod=(bpr1-baseModulo)
bpr2=40
def2Mod=(bpr2-baseModulo)
; height of regardc-1 empty line
bmHeight=169
bmTunHeight=256
; 7 + 8 colors, bank shift:
palShiftAlloc=(16*4)

floodtStart=300*6  ; obsolete
greetstStart=300*14

startTunn=300*12

;/// - - XREFs

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

	XREF    leyesBm
	XREF    leyesBmp

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

	XREF    _bmpf2_setAllDirty

	XREF	_InFree

	XREF    _Scene2d_init
	XREF    _Scene2d_render
	XREF    _scene2d_Refresh

;///

	XREF    _Scene3d_init
	XREF    _Scene2d_3dTo2d

    section code,code

; - - - - - - - - - - - - - - - -  - - - - - - - - -
;/// - - - - - - fx_init
fx_init:
	; - -  alloc pf1 background bm
	move.w    #384,d0  ; 384px, 320+64,64 pixel aligned
	move.w    #bmHeight+1+bmTunHeight,d1
	move.w    #4,d2		; planes
	clr.l    d3        ;useless flags ?
	bsr		_initBm	 ; does align
	move.l	a0,bmPf1
	
	; - -copy regards up there:
	move.l	_GfxBase,a6	   
	CALL    OwnBlitter
	CALL    WaitBlit    ; because first of app
	; - -- -


	move.l  bmPf1(pc),a1
    lea	sbm_SIZEOF(a1),a1	;bob destination struct

	move.l  leyesBm,a0
	lea	sbm_SIZEOF(a0),a0	;bob shape struct is after gif bitmap struct

	clr.w	d0	;x
	clr.w	d1	;y
	bsr _CopyBmAl16NoClip

	; - -  - -
	move.l  bmPf1(pc),a1
    lea	sbm_SIZEOF(a1),a1	;bob destination struct

	XREF    tunBm
	move.l  tunBm,a0
	lea	sbm_SIZEOF(a0),a0	;bob shape struct is after gif bitmap struct

	move.w	#16,d0				;x
	move.w	#bmHeight+1,d1	  ;y
	bsr _CopyBmAl16NoClip

	; - - - -
	move.l  _GfxBase,a6
	CALL    DisownBlitter

	; - - can free this now, keep palette
    move.l  leyesBm,a0
	bsr		_closeBm
	clr.l   leyesBm

	; - - can free this now, keep palette
	;not because fade
	;move.l  tunBm,a0
	;bsr	 _closeBm
	;clr.l   tunBm


    ;d0.w: nb planes: 1->8
    ;d1: prefsbits: CCLR_...
	move.w    #8,d0    ;d0.w: nb planes: 1->8
;	 move.b    #CCLR_CANSCROLL|CCLR_WL_SCROLL|CCLR_DUALPF|CCLR_DOCOLORS,d1
	move.b    #CCLR_CANSCROLL|CCLR_DOCOLORS,d1
	or.b    #CCLR_64,d1
	or.b    #CCLR_WL_HC,d1
	;or.b    #CCLR_BMDCAS,d1
	;or.b	 #CCLR_WL_16c,d1
	bsr    _cc_InitLowResAGADbl ; d6/d7 a3/a4/a5/a6 preserved
	move.l	a0,CopDbl

    
	; - - - - - - -
;re?
;	 lea     objlist,a1
;	 move.l  obs_extruded(pc),(a1)
;	 moveq  #1,d0
;	 bsr     _Scene3d_init
;	 move.l  a0,_scn3d
;	 move.l	 light1Bmc,scn_lightBM(a0)


	; create palette 256c

	bsr     multiplyPal16c
	move.l	a0,specPal


	lea     palShiftAlloc*3(a0),a0
	move.l	CopDbl(pc),a1 ;	  a1 dblcopper
	clr.w   d0
	bsr _SetCopperPaletteAgaDbl

	; - - -alloc 6 planes ... pf2 circling buffers

	move.w    #320,d0
	move.w    #256,d1
	move.w    #6,d2
	clr.l    d3
	bsr		_initBm	 ; does align
	move.l	a0,_pf2planesBm
	; then we fake 4 planes
	; and keep a plane for draw
	move.b	#4,bm_Depth(a0)

	move.l	a0,a3
	bsr		initSpecialSbm

	; - - declare 3 BMs dirty
	;nothere bsr     _bmpf2_setAllDirty

	; - - init 2d polys
nquad=128+32
	move.w	#nquad*2,d5	;nbv
	move.w	#nquad-1,d1 ;nbquads
	bsr		_Scene2d_init
	move.l  a0,_scn2d
	rts
;///
; - - - - - effect bm stuffs
bmPf1:	dc.l	0
CopDbl:	dc.l	0
specPal:	dc.l	0
_scn2d:	dc.l	0
; - - - -
_pf2planesBm: dc.l	  0
_bmdMainAlloc:		dc.l	0
; - - - - - - - - - -
	;used for draw or null:
_bmdToDraw:			dc.l	0
; 6 filled at init:
_bmdWaitingFrame:	dc.l	0
_bmdP0:	dc.l	0
_bmdP1:	dc.l	0
_bmdP2:	dc.l	0
_bmdP3:	dc.l	0
_BmdFreeWaiting:   dc.l	   0

dtEyes:		dc.w	0
drawState:	dc.w	0
greetObjIndex:	dc.w	-1
greetmvttime:	dc.w	0
scnGreet:	dc.l	0
objList:	dc.l	0,0
dbgl:	dc.w	0
maxy2dirty:	dc.w	0
; - - - - - - - - - - - - - - - -  - - - - - - - - -
;/// - - - initSpecialSbm
initSpecialSbm:
	;a3 bm 6 planes
	move.l	#(sbms_SIZEOF+bmd_sizeof)*6,d0
	clr.l	d1
	bsr		_InAlloc
	move.l	a0,a1
	move.l	a0,_bmdMainAlloc

	lea		bm_Planes(a3),a4

	lea     _bmdWaitingFrame(pc),a5

	move.w	#5,d0
.lpinitbmd
; bmd then bm
	lea 	bmd_sizeof(a1),a2	;bm
	move.l	a2,bmd_bm(a1)
	move.w	#256,bm_Rows(a2)
	move.w	#40,bm_BytesPerRow(a2)
	move.b	#1,bm_Depth(a2)
	move.l	#40*256,sbm_PlaneSize(a2)
	move.l	(a4)+,a6	
	move.l	a6,bm_Planes(a2)
	; -  -bod_also !
	lea		sbms_bobDest(a2),a3
;		 APTR    bod_background	 ;Bitmap *
;		 APTR    bod_dest			 ;Bitmap * can be same as sm_background
;		 ; note: following different if bm interleaved
;		 UWORD   bod_OnePlaneByteWidth
;		 WORD    bod_clipX1
;		 WORD    bod_clipX2
;		 WORD    bod_clipY1
;		 WORD    bod_clipY2
	move.l	a2,bod_background(a3)
	move.l	a2,bod_dest(a3)
	move.w  #40,bod_OnePlaneByteWidth(a3)
	move.w	#319,bod_clipX2(a3)
	move.w	#255,bod_clipY2(a3)
	move.l	a1,(a5)+



	lea		sbms_SIZEOF+bmd_sizeof(a1),a1
	dbf		d0,.lpinitbmd
	rts
;///
;/// - - - - cpu
fx_cpu:


	; - blit or draw here
	lea _BmdFreeWaiting(pc),a0
	move.l  (a0),a1
	tst.l	a1
	beq		.dowait

	move.l	a1,_bmdToDraw
	clr.l	(a0)

	move.l	_GfxBase,a6
	CALL    OwnBlitter
    CALL    WaitBlit    ; because first of app


; - - -
	move.l  _bmdToDraw(pc),a0
	move.w  bmd_flags(a0),d0
	btst    #1,d0
	beq.b     .endClearBm
.partialClear

		bsr	    _partialClearBmd

.endClearBm
	; - -  - - - - - - -
;	 move.w  drawState(pc),d0
;	 tst.w	 d0
;	 bgt	 .drawgreetings

	move.l  _scn2d(pc),a0
	move.l	_fxTime,d0
	bsr		_scene2d_Refresh   ; actually wobble

	; - blitter clean can be still on
	; if have to compute this, better do computation while still blitting:

	move.l  scnGreet(pc),a0
	tst.l	a0
	beq 	.nogrettcompute
	move.l	_bmdToDraw(pc),a1
	bsr		_Scene2d_3dTo2d
.nogrettcompute
	; - - -back to real bm drawing:
	move.l  _scn2d(pc),a0
	move.l	_bmdToDraw(pc),a1
	bsr		_Scene2d_render

	move.l	_bmdToDraw(pc),a1
	move.w	 bmd_ldY2(a1),maxy2dirty ; keep this
            
	; - - - change screen object to draw here
endWobble=16*300
	move.l	_fxTime,d0
	cmp.l	#endWobble,d0
	blt		.nodrawchange
		move.w	#1,drawState
		; draw less polygons when greetings...
		move.l  _scn2d(pc),a0
		move.w	#48,scn_TotalNbPols(a0)
		; less vertexes too !
		move.l	scn_obj(a0),a1
		move.l obr_vtf(a1),d0
		add.l	#49*2*vtf_SIZEOF,d0
		move.l	d0,obr_vtfEnd(a1)


;old		move.l  _scn2d(pc),a0
;		 bsr	 _InFree
;		 clr.l   _scn2d
.nodrawchange

;old	bra.b	  .enddraw
.drawgreetings
	; - - - - - - - - draw greetings
	move.l  scnGreet(pc),a0
	tst.l	a0
	beq		.enddraw

	move.l	scn_obj(a0),a1

;	 move.l	 d0,d1
;	 add.l	 d1,d1
;	 add.l	 d1,d0
;	 lsr.l	 #3,d0
;	 sub.w	 #1000,d0  ;800? 1200
;	 move.w	 d0,obr_tx(a1)


	move.w  greetmvttime(pc),d0
	move.w	d0,d1
	lsr.w	#1,d1
	sub.w	#128,d1
	move.w	d1,obr_distort(a1)

	add.w	#129,d0	  ; min z
	move.w  d0,obr_tz(a1) ; translate to front

	;-- a bit of rotation ?
	move.l	_mfast,a6
	lea     sf_SinTab(a6),a6
	move.l	_fxTime,d2
	;lsl.l	 #1,d2
	and.w	#$03ff,d2
	move.w	(a6,d2.w*2),d4
	asr.w	#8,d4
	asr.w	#2,d4
	move.w	d4,obr_o1(a1)


	move.l  scnGreet(pc),a0
	tst.l	a0
	beq 	.enddraw

;done up there	  move.l  _bmdToDraw(pc),a1
;	 bsr	 _Scene2d_3dTo2d
;ok	   move.l  scnGreet(pc),a0
	move.l	_bmdToDraw(pc),a1
	bsr		_Scene2d_render

	; force dirty ly1 to top screen
	move.l	_bmdToDraw(pc),a1
	clr.w	bmd_ldY1(a1)

	;
	move.w  maxy2dirty(pc),d0
	move.w  bmd_ldY2(a1),d1
	cmp.w	d0,d1
	bge	.nomoredown
		move.w	d0,bmd_ldY2(a1) ; please clean down this
.nomoredown


.enddraw
	; - - - - DO NOT BREAK DisownBlitter Pairs
	move.l  _GfxBase,a6
	CALL    DisownBlitter


 

	; - - - pass drawn bm to waiting queue
	lea		_bmdToDraw(pc),a0
	move.l	(a0),a1
	clr.l	(a0)
	move.l	a1,_bmdWaitingFrame

	; - -change states here, to not break blitter pair
	tst.w   drawState
	beq		.nogreetstate

	move.l	_fxTime,d0
	sub.l	#endWobble,d0
	blt		.nogreetstate
	;lsr.l	 #1,d0
	move.w	d0,d1	; d1 index of greet
	lsr.w	#1,d1
	lsr.w	#8,d1
	   ;
	and.w   #$01ff,d0   ; time of movement
	add.w	d0,d0
	move.w  d0,greetmvttime

	; if index of greet is different, reset object
	move.w  greetObjIndex(pc),d2
	cmp.w	d2,d1
	beq		.objok
		move.w	d1,greetObjIndex
		cmp.w	#-1,d2 ; before
		beq		.noobjclose
			move.l  scnGreet(pc),a0
			tst.l	a0
			beq.b	.noobjclose
 add.w	#1,dbgl
; move.w dbgl,_debugv+16+2
			bsr		_InFree

			clr.l   scnGreet
.noobjclose
	cmp.w	#14,d1
	bge		.nogreetstate

	; create new obj
	XREF    obs_greets
	lea     obs_greets,a0
	lea		(a0,d1.w*4),a0

	lea     objList,a1
	move.l  (a0),(a1)
	moveq  #1,d0
	bsr     _Scene3d_init ; alloc can throw exit
	move.l  a0,scnGreet
.objok


.nogreetstate



.dowait
;	 move.l    _GfxBase,a6
;	 CALL    WaitTOF

	XREF    _cpu_WaitTofOnNFrames
	bsr 	_cpu_WaitTofOnNFrames

	rts
;///
; - - - - - - - - - - - - - - - -  - - - - - - - - -
fx_end:
	move.l  _scn2d(pc),a0
	bsr	    _InFree
	clr.l   _scn2d

	move.l  CopDbl(pc),a0
	bsr 	_cc_FreeCopperDbl
	clr.l   CopDbl

	move.l	_scn2d(pc),a0
	bsr		_InFree

	move.l  _pf2planesBm(pc),a0
	bsr		_closeBm

	move.l  _bmdMainAlloc(pc),a0
	bsr		_InFree

	rts
; - - - - - - - - - - - - - - - -  - - - - - - - - -
; - - - multiplyPal16c
mv0=0
mv1=64
mv2=128
mv3=192
mv4=255
betterbits:	
			dc.b	mv0,mv4,mv3,mv4
			dc.b	mv2,mv4,mv3,mv4
			dc.b	mv1,mv4,mv3,mv4
			dc.b	mv2,mv4,mv3,mv4

			;dc.b	 0,64,128,128
			;dc.b	 192,192,192,192
			;dc.b	 255,255,255,255
			;dc.b	 255,255,255,255
palscramble:	
	dc.w	$0180,$0180+(1*2)
	dc.w	$0180+(4*2),$0180+(5*2)
	dc.w	$0180+(16*2),$0180+(17*2)
	dc.w	$0180+(20*2),$0180+(21*2)

	; does 16*16=256 colors
multiplyPal16c:
	;a0 pal 16c in
	;a0 out 256c

	lea     betterbits(pc),a4
	; alloc one shade 16c table and one full 256c
	move.l	#4+(256*3)+(palShiftAlloc*3),d0
	clr.l	d1
	bsr		_InAlloc
	move.l	a0,a1


;/// - - -  - - - - first 16c NORMAL
	move.l  leyesBmp,a3
	addq	#4+3,a3	;read

; - - normal
	lea 	palscramble+2(pc),a5
	move.w	#6,d0 	; color 1-7
	move.l	#(bplcon3<<16)|($0000),(a1)+ ; bank shift
.lpsameshade1d
	move.w	(a5)+,(a1)+

	move.b	(a3)+,d2
	move.b	(a3)+,d3
	move.b	(a3)+,d4
	lsr.b	#4,d2
	lsr.b	#4,d3
	lsr.b	#4,d4

	lsl.w	#8,d2
	lsl.b	#4,d3
	or.b	d3,d2
	and.b	#$0f,d4
	or.b	d4,d2
	move.w	d2,(a1)+

	;add.w	 #2,d1
	dbf	d0,.lpsameshade1d


	move.l	#(bplcon3<<16)|($4000),(a1)+ ; bank shift

	lea 	palscramble(pc),a5
	move.w	#6,d0
.lpsameshade2d
	move.w	(a5)+,(a1)+

	move.b	(a3)+,d2
	move.b	(a3)+,d3
	move.b	(a3)+,d4
	lsr.b	#4,d2
	lsr.b	#4,d3
	lsr.b	#4,d4

	lsl.w	#8,d2
	lsl.b	#4,d3
	or.b	d3,d2
	and.b	#$0f,d4
	or.b	d4,d2
	move.w	d2,(a1)+

	;add.w	 #2,d1
	dbf	d0,.lpsameshade2d
;///
;/// - - -  - - - - first 16c dark
	move.l  leyesBmp,a3
	addq	#4+3,a3	;read
	
	lea 	palscramble+2(pc),a5

	move.l	#(bplcon3<<16)|($0000),(a1)+ ; bank shift

	move.w	#6,d0 	; color 1-7
.lpsameshade1
	move.w	(a5)+,(a1)+

	move.b	(a3)+,d2
	move.b	(a3)+,d3
	move.b	(a3)+,d4
	lsr.b	#5,d2
	lsr.b	#5,d3
	lsr.b	#5,d4

	lsl.w	#8,d2
	lsl.b	#4,d3
	or.b	d3,d2
	and.b	#$0f,d4
	or.b	d4,d2
	move.w	d2,(a1)+

	;add.w	 #2,d1
	dbf	d0,.lpsameshade1


	move.l	#(bplcon3<<16)|($4000),(a1)+ ; bank shift

	lea 	palscramble(pc),a5
	move.w	#6,d0
.lpsameshade2
	move.w	(a5)+,(a1)+

	move.b	(a3)+,d2
	move.b	(a3)+,d3
	move.b	(a3)+,d4
	lsr.b	#5,d2
	lsr.b	#5,d3
	lsr.b	#5,d4

	lsl.w	#8,d2
	lsl.b	#4,d3
	or.b	d3,d2
	and.b	#$0f,d4
	or.b	d4,d2
	move.w	d2,(a1)+

	;add.w	 #2,d1
	dbf	d0,.lpsameshade2
;///
;/// - - - - -second palette for tunnel image
	XREF	tunBmp
	move.l  tunBmp,a3
	addq	#4+3,a3   ;read

	move.l	#(bplcon3<<16)|($0000),(a1)+ ; bank shift


	lea 	palscramble+2(pc),a5
	move.w	#6,d0 	; color 1-7

.lpsameshade1b
	move.w	(a5)+,(a1)+

	move.b	(a3)+,d2
	move.b	(a3)+,d3
	move.b	(a3)+,d4
	lsr.b	#4,d2
	lsr.b	#4,d3
	lsr.b	#4,d4

	lsl.w	#8,d2
	lsl.b	#4,d3
	or.b	d3,d2
	and.b	#$0f,d4
	or.b	d4,d2
	move.w	d2,(a1)+

	dbf	d0,.lpsameshade1b

	move.l	#(bplcon3<<16)|($4000),(a1)+ ; bank shift

	lea 	palscramble(pc),a5
	move.w	#6,d0
.lpsameshade2b
	move.w	(a5)+,(a1)+

	move.b	(a3)+,d2
	move.b	(a3)+,d3
	move.b	(a3)+,d4
	lsr.b	#4,d2
	lsr.b	#4,d3
	lsr.b	#4,d4

	lsl.w	#8,d2
	lsl.b	#4,d3
	or.b	d3,d2
	and.b	#$0f,d4
	or.b	d4,d2
	move.w	d2,(a1)+

	;add.w	 #2,d1
	dbf	d0,.lpsameshade2b
;///
;/// - - - - - - -  - -  then 256 palette scramble
	move.l  leyesBmp,a2
	lea	    4(a2),a2    ; a2 16c
	
	move.w	#256,(a1)
	addq	#4,a1

	clr.w	d0
.lpplaneLoop

	move.w	d0,d1
	and.w	#1,d1
	
	move.b	d0,d2
	lsr.b	#1,d2
	and.b	#2,d2
	or.b	d2,d1

	move.b	d0,d2
	lsr.b	#2,d2
	and.b	#4,d2
	or.b	d2,d1

	move.b	d0,d2
	lsr.b	#3,d2
	and.b	#8,d2
	or.b	d2,d1	;pf1 index

	move.w	d1,d2
	add.w	d1,d1
	add.w	d2,d1	;d1*3

	lea		(a2,d1.w),a3
	clr.w	d2
	clr.w	d3
	clr.w	d4
	move.b	(a3)+,d2 ;rgb
	move.b	(a3)+,d3
	move.b	(a3)+,d4

	; - - - get pf2 code

	move.w	d0,d1
	lsr.b	#1,d1
	and.w	#1,d1

	move.b	d0,d5
	lsr.b	#2,d5
	and.b	#2,d5
	or.b	d5,d1

	move.b	d0,d5
	lsr.b	#3,d5
	and.b	#4,d5
	or.b	d5,d1

	move.b	d0,d5
	lsr.b	#4,d5
	and.b	#8,d5
	or.b	d5,d1

	clr.w	d5
	move.b	(a4,d1.w),d5
  
	sub.w	d5,d2
	bge.b	  .absr
		neg.w	d2
.absr
	move.b	d2,(a1)+


	sub.w	d5,d3
	bge.b	  .absg
		neg.w	d3
.absg
	move.b	d3,(a1)+

	
	sub.w	d5,d4
	bge.b	  .absb
		neg.w	d4
.absb
	move.b	d4,(a1)+


	add.w	#1,d0
	cmp.w	#256,d0
	blt		.lpplaneLoop
;///
	;a0 out
	rts
;
; - - - - - - - - - - - - - - - -  - - - - - - - - -
floodY:	dc.w    170 ;170    ; start value
fx_vblank:
;/// - - - scroll things

	move.w	#16*4,d7	;dx pf1


	; if part2, no part1
	move.l	_fxTime,d0
	sub.l	#startTunn,d0
	blt		.tuntba
	lsr.l	#3,d0  ;3
	cmp.w	#255,d0
	blt		.tuntba
		bra	.novbleyes
.tuntba



	move.l  CopDbl(pc),a1
	lea     cdb_scrollvh(a1),a2
	lea     cdb_scrollvh2(a1),a3

	move.l	_mfast,a6

	move.l	_fxTime,d2
	cmp.l	#256*4,d2
	bge		.okscy
		lsr.l	#2,d2	;0->256
		neg.w	d2
		add.w	#256,d2	;256->0
		and.w	#$00ff,d2
		
		lea		sf_Exp(a6),a5
		move.w	(a5,d2.w*2),d2
		tst.w	d2
		bgt		.noytd
		move.w	#1,d2
.noytd

		bra	.endscy
.okscy
		move.w	#1,d2
.endscy


	move.w  floodY(pc),d4
	; - - - - d2 y empty start
	; empty lines
	tst.w	d2
	ble		.nofirstempty
	move.w	d2,d0
	cmp.w	d4,d0
	ble	.noby1e
		move.w  d4,d0
.noby1e

	sub.w	#1,d0
.lpem
		move.w	#bmHeight*bpr1,(a2)+
		clr.w	(a2)+
		clr.l	(a3)+
	dbf	d0,.lpem
.nofirstempty

	; - - then bm
	move.w	d2,d0
	neg.w	d0
	add.w	d4,d0
	ble		.nobmpart

	sub.w	#1,d0
	clr.w	d1
.lpbmp
		move.w	d1,(a2)+
		add.w	#bpr1,d1
		move.w	d7,(a2)+
		clr.l	(a3)+
		dbf		d0,.lpbmp
.nobmpart
	; - - - - - -end part height: 256-d3
;d0 work
;d1 bmy up
;d2 loop
;d3 work
;d4 -
;d5 sin run
;d6 computed sin dx
;d7 main bm dx
;
;a0
;a1 sint
;a2 fill pf1 dydx
;a3 fill pf2 palpf1 / pf2 dx
;a4
;a5
;a6
	lea 	sf_SinTab(a6),a1
	move.l	_fxTime,d5
	
	
	;;;move.w  d2,d1
	move.w	d4,d1
	sub.w	d2,d1

;oldok	  move.w   #255-(bmHeight+1),d2
	move.w	#256-1,d2
	sub.w	d4,d2
	ble	.nolastpart
	;move.w	 #(bmHeight-1),d1
	move.w	#16,d4 ; force of distort
.lpmlast
		move.w	d1,d0

		and.w	#$03ff,d5
		move.w	(a1,d5.w*2),d3
		muls.w	d4,d3
		;asr.l	 #8,d3
		;asr.l	 #6,d3
		;asr.l	 #5,d3
		swap	d3
		add.w	d3,d0

		move.w	d3,d6


		tst.w	d0
		bge.b	 .okyup1
			move.w  #bmHeight,d0
			bra.b	.okydn1
.okyup1
		
		cmp.w	#bmHeight,d0
		blt.b	  .okydn1

		move.w  #bmHeight-1,d0
.okydn1

		;-----

		move.w	d0,d3
		lsl.w	#4,d0	;*16
		lsl.w	#5,d3	;*32
		add.w	d3,d0   ;*48
		move.w	d0,(a2)+

		sub.w	#1,d1 ;y?
		add.w	#20,d5
		; - -
		add.w	d7,d6
		move.w	d6,(a2)+
		move.l	#1<<16,(a3)+
		add.w	#2,d4
	dbf	d2,.lpmlast

.nolastpart
.novbleyes

; - - - -  -  - - there comes the tunnel



	move.l	_fxTime,d0
	sub.l	#startTunn,d0
	blt		.notunn
	lsr.l	#3,d0  ;3
	cmp.w	#255,d0
	ble		.tuntb
		move.w	#255,d0
.tuntb

	move.w	d0,d1
	tst.w	d1
	ble		.notunn

	move.l  CopDbl(pc),a1
	lea     cdb_scrollvh+4(a1),a2
	lea     cdb_scrollvh2+4(a1),a3


	move.w	#(bmHeight+1)+256,d2
	sub.w	d0,d2

	
	;*48 = 32+16
	move.w	d2,d3
	lsl.w	#5,d2
	lsl.w	#4,d3
	add.w	d3,d2

	;move.w	 #(bmHeight+1)*bpr1,d2
	sub.w	#1,d1
.lpytunn
	move.w	d2,(a2)+
	add.l	#bpr1,d2
	move.w	d7,(a2)+
	move.l	#2<<16,(a3)+

	dbf	d1,.lpytunn



.notunn

;///



; - - - - - - -  --  - - bm 6buffers things
; 6 filled at init:
;_bmdWaitingFrame:	 dc.l	 0
;_bmdP0: dc.l	 0
;_bmdP1: dc.l	 0
;_bmdP2: dc.l	 0
;_bmdP3: dc.l	 0
;_BmdFreeWaiting:   dc.l    0

	
	; - -  -
    move.l  _bmdWaitingFrame(pc),a0
	tst.l   a0
	beq		.nobmchange	   
	tst.l   _BmdFreeWaiting
	bne		.nobmchange

	clr.l   _bmdWaitingFrame
	lea		_bmdP0(pc),a1
	movem.l	(a1),a2/a3/a4/a5
	move.l	a0,(a1)+
	movem.l	a2-a5,(a1)	; cycled !
.nobmchange
	;synchro planes
	lea		_bmdP0(pc),a1
	movem.l	(a1),a0/a3/a4/a5
	move.l	bmd_sizeof+bm_Planes(a0),a0
	move.l	bmd_sizeof+bm_Planes(a3),a3
	move.l	bmd_sizeof+bm_Planes(a4),a4
	move.l	bmd_sizeof+bm_Planes(a5),a5

	move.l	_pf2planesBm(pc),a2
	lea		bm_Planes(a2),a1
	movem.l	 a0/a3/a4/a5,(a1)

	; - - -  -
	; a0 struct Bitmap pf1
	; a1 copperDbl
	; a2  struct Bitmap pf2
	move.l  bmPf1(pc),a0
	move.l  CopDbl(pc),a1
	move.l	_pf2planesBm(pc),a2
	bsr     _cc_setLineScrollsDPFTileL

	; - - -
	move.l  CopDbl(pc),a1
	bsr		_cc_switchCopper

;	 move.w	 #$007,$0dff180

	rts

;/// - - - - - - _cc_setLineScrollsDPFTileL
	XDEF	_cc_setLineScrollsDPFTileL
_cc_setLineScrollsDPFTileL:
    ; a0 struct Bitmap
	; a1 copperDbl
	; a2  struct Bitmap pf2
	movem.l	 a0/a1/a2,-(sp)

	lea	cdb_scrollvh(a1),a3
;	 move.w	 (a3),d1 ;* dudulo now
;	 lsr.w	 #6,d1
	move.w	#bmHeight,d1 ; without *modulo here

	move.w	2(a3),d0
	;;move.w  VHSIZE(a3),d3
	clr.w	d3
	move.w	VHSIZE+2(a3),d2

	move.l	cdb_CopA(a1),a1
	bsr    _cc_setBmAGADPF

	movem.l	 (sp),a0/a1/a2 ; cdb_

	lea		cdb_scrollvh(a1),a3 ; one buffered yx scrolls per line

	; a1 cdb_ -> cp_
	move.l	cdb_CopA(a1),a1	; double buffered copper

;	 move.w	 cp_nbLines(a1),d0
;	 subq	 #2,d0	 ; start at line1


 move.w  #255,d0


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

;	 move.l	 #.end-.loop64,_debugv+12

startVW=$2c01
	move.l	#(startVW<<16)|$fffe,d7

	move.w	#0,a2  ; force palette change on first line
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

; palette change with lisa
	move.l 	specPal(pc),a1
	lsl.w	#6,d3
	lea	    (a1,d3.w),a1   ; start at color1
	rept    4
		movem.l (a1)+,d2-d5
		movem.l d2-d5,(a0)
		lea     16(a0),a0
	endr
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

.end
	moveq	#-2,d0
	move.l	d0,(a0)+
	move.l	d0,(a0)+

	lea	12(sp),sp
	rts
;///
      

; - - -  fx table
	XDEF fx_DualLisa
fx_DualLisa:    dc.l    fx_init,fx_cpu,fx_end,fx_vblank






