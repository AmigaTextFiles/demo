********************************************************************************
********************************************************************************
**                                                                            **
**            Global Vector Table Include - By Shagratt/LSD 6/4/92            **
**                                                                            **
********************************************************************************
********************************************************************************


	cmp.l	#0,a2
	bne	no_gvtruntime	

	move.l	4,a6
	lea	gvtname,a1
	jsr	-294(a6)		; find task
	cmp.l	#0,d0
	bne	_gvtloaded
	move.w	#$ffff,d0
gvt_err1	move.w	$dff006,$dff180
	dbf	d0,gvt_err1
	rts

_gvtloaded	trap	#0		; gets info from GVTruntime
no_gvtruntime:
	movem.l	a1-a6,_GVTspace
	bra	skip_gvtvars
_GVTspace:	dc.l	0,0,0,0,0,0
gvtname:	dc.b	"GVT",0
	even
skip_gvtvars:
	
gvtcall:	MACRO	\1	

	movem.l	_GVTspace,a1-a6
	
	move.w	#\1,d0
	ext.l	d0
	move.l	(a2,d0),a4
	moveq	#12,d0
	jsr	(a5)

		ENDM
		
