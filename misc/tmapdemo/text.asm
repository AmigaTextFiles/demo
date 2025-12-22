; $$TABS=8
; text plotting routines for demo

	include	'demo.i'
	include	'graphics/rastport.i'

	xref	_SysBase,_LVORawDoFmt,_LVOMove,_LVOText,_LVOSetABPenDrMd
	xref	canvas_rport,_GfxBase

PlotString::
; PlotString - plot a string (and potentially two numbers)
; input 4(a7)=numbers to be printed
;	a0=c style format string
;	d2/d3=xy coords
; trashes: d2/d3/d0/d1/a0/a1
	movem.l	a5/a2/a3,-(a7)
	move.l	a6,a5
	lea	16(a7),a1		; pointer to passed args
	clr.l	TextLength(a5)
	lea	MyPutChProc(pc),a2
	lea	TextBuffer(pc),a3
	move.l	_SysBase(a6),a6
	jsr	_LVORawDoFmt(a6)
	lea	canvas_rport(a5),a1
	move.l	_GfxBase(a5),a6
	move.l	d2,d0
	move.l	d3,d1
	jsr	_LVOMove(a6)
	lea	canvas_rport(a5),a1
	moveq	#31,d0	; apen
	moveq	#0,d1	; bpen
	move.l	#RP_JAM2,d2
	jsr	_LVOSetABPenDrMd(a6)	; doesn't do anything if nothing changed.
	lea	canvas_rport(a5),a1
	lea	TextBuffer(pc),a0
	move.l	TextLength(a5),d0
	subq.l	#1,d0			; subtract off trailing null
	jsr	_LVOText(a6)
	move.l	a5,a6
	movem.l	(a7)+,a5/a2/a3
	rts

MyPutChProc:
	addq.l	#1,TextLength
	move.b	d0,(a3)+
	rts


TextBuffer:
	ds.b	80


	section	__MERGED,data
TextLength::
	dc.l	0
