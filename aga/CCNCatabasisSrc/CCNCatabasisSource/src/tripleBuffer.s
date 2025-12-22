
    opt c+
    opt    ALINK

    include demodata.i

    include graphics/graphics_lib.i
    include graphics/gfxbase.i
    include hardware/custom.i


	XREF    __XCEXIT
	XREF    _doEnd
	XREF    _demoEnd

	XREF    _ClearBmRect

	XREF    _PrepareParaClear
	XREF    _debugv


	XDEF    _bmpf2_WaitDrawn
_bmpf2_WaitDrawn
	; - - get bitmap or wait
	tst.l   bmpf2_Drawn
	bne		.drawnReady
.lpdr
	tst.b	_doEnd
	bne     ExitApp
	tst.l   bmpf2_Avail
	beq		.lpdr
		move.l  bmpf2_Avail,bmpf2_Drawn
		clr.l   bmpf2_Avail
.drawnReady
	rts

; - - - - - - - - - -
	XDEF    _bmpf2_PostDrawn
_bmpf2_PostDrawn:

.lpwr
	tst.l   bmpf2_WaitPhys
	beq		.waitready
	tst.b	_doEnd
	bne     ExitApp
	bra	.lpwr
.waitready
	move.l  bmpf2_Drawn(pc),a0
	move.l  a0,bmpf2_WaitPhys
	move.l  a0,bmpf2_LastDrawn ; also
	clr.l   bmpf2_Drawn
	rts
ExitApp
	bsr 	_demoEnd
    jmp     __XCEXIT



; - - - -  - - - - -
	XDEF    _bmpf2_vbl_acknowledge
_bmpf2_vbl_acknowledge
Phys=0
Avail=4
Drawn=8
WaitP=12
VblAck=16
	;  - - - - - -switch buffer acknowledge what is seen
	lea 	bmpf2_Physic(pc),a0
	tst.l   VblAck(a0)
	beq		.noack
	tst.l   Avail(a0)	; can't override other bm ! ->next frame
	bne		.noack
		move.l  Phys(a0),Avail(a0)
		move.l  VblAck(a0),Phys(a0)
		clr.l   VblAck(a0)
.noack
		rts



; - - - - - - -  --
	XDEF    _bmpf2_vbl_SetWaitOrPhys
_bmpf2_vbl_SetWaitOrPhys:

	; - - - - -> wait to ackn, or phys
	tst.l   bmpf2_WaitPhys
	beq		.nowaitbmpf2
		move.l  bmpf2_WaitPhys(pc),a2
		move.l	a2,bmpf2_VblAck
		clr.l   bmpf2_WaitPhys
	bra	.endbmpf2
.nowaitbmpf2
	; means didn't change
	move.l  bmpf2_Physic(pc),a2
.endbmpf2
	rts
; - -  -ask a bit of WaitTof


	XDEF    _cpu_WaitTofOnNFrames
_cpu_WaitTofOnNFrames

	XREF    _GfxBase
	XREF    _fxFrame
	XREF    _cpuStartFrame
	

	move.l  _fxFrame,d0
	cmp.l   _cpuStartFrame,d0
	beq		.forceframe
	
	; since there is no wait at all with triple buffer
	; wait each 5 frames to allow keyboard interupt
	lea waitSomeFrameCount(pc),a0
	move.w	(a0),d0
	add.w	#1,d0
	move.w	d0,(a0)
	cmp		#6,d0
	blt		.nowt
		clr.w   (a0)
.forceframe
		move.l    _GfxBase,a6
		CALL    WaitTOF
.nowt
	rts
waitSomeFrameCount:	dc.w	0

; - - - - ask to be cleared whatever state they are

	XDEF    _bmpf2_setAllDirty
_bmpf2_setAllDirty:

	lea	bmpf2_Data(pc),a0
	moveq	#3,d1
	moveq  #2,d0
.lp
		move.w	#3,bmd_flags(a0)

		; - - not enough !
		; because last waiting beuffer will be displayed...
		;move.l  bmpf2_Drawn,a0
		
		movem.l	 d0/a0,-(sp)
		bsr _clearFullBmdHog
		movem.l	 (sp)+,d0/a0

		lea		bmd_sizeof(a0),a0
	dbf	d0,.lp


	


	rts
	XDEF    _clearFullBmdHog
_clearFullBmdHog:
	;a0 bmd_
	clr.w	bmd_flags(a0)

	move.l	bmd_bm(a0),a1
	lea 	sbm_SIZEOF(a1),a1 ;bob destination  struct

	clr.w	d0
	clr.w	d1

	move.w	bod_clipX2(a1),d2
	move.w  bod_clipY2(a1),d3

	bsr	_ClearBmRect

	rts
; - - - -
	XDEF    _partialClearBmd
_partialClearBmd:
	;a0 bmd_
	;x1y1 x2y2
	clr.w	bmd_flags(a0)
	movem.w 	bmd_ldX1(a0),d0/d1/d2/d3
	sub.w	d0,d2
	sub.w	d1,d3
	move.l	bmd_bm(a0),a1
	lea 	sbm_SIZEOF(a1),a1 ;bob destination  struct

	clr.w   bod_clipX1(a1) ; bug ??

	bsr     _PrepareParaClear
	;bsr _ClearBmRect


	rts
; - - - - - - - - --
	XDEF    _updateBlitterOp
_updateBlitterOp:


	rts

; - - point bmData that points info and bm.


	XDEF    bmpf2_Physic
	XDEF    bmpf2_Avail
	XDEF    bmpf2_Drawn
	XDEF    bmpf2_WaitPhys
	XDEF    bmpf2_LastDrawn
	XDEF    bmpf2_Data

bmpf2_Physic:	dc.l	0
bmpf2_Avail:	dc.l	0	;vbl->cpu dr
bmpf2_Drawn:	dc.l	0	;cpu->cpu wp
bmpf2_WaitPhys:	dc.l	0	;cpu->vbl
bmpf2_VblAck:	dc.l	0	;vbl  for vblank to check visible
; not in pipeline, to be read as feedback:
bmpf2_LastDrawn:   dc.l	   0
bmpf2_Data:
		dcb.b	 bmd_sizeof*3,0


