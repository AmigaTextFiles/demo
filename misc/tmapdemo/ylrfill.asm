; $$TABS=8

	include	'demo.i'
	xref	yadrtable,rightmasktable,leftmasktable
	xref	vtable

YLRFill::
; fill a list of horizontal spans
; handles reversal cases (left > right)! However, this is an unlikely case
; so it is more optimal for the other case.
; This routine is optimized for SMALL polygons (the only interesting ones)
; input:
;  (a0)=ylr array, terminated with y<0.
; trashes: a0/a1/d1-d7
; register usage:
;  d0=color
;  d7=$fffc	( x adr mask)
;  a0=array

; lwordofs[x]=(x>>2)*4
; right mask table=00ffffff, 0000ffff, 000000ff, 00000000
; left masktable=  00000000  ff000000  ffff0000  ffffff00
	ONTIMER	10
	moveq	#$fffffffc,d7
	move.l	current_color(a6),d0
	move.w	(a0)+,d1	; ycoord
	bmi.s	done_fill	; handle empty case? why?
nextylr:
	move.l	(yadrtable.w,a6,d1.w*4),a1	; a1=screen array ptr
	move.w	(a0)+,d1			; d1=leftx
	move.w	(a0)+,d2			; d2=rightx
	cmp.w	d1,d2
	blt.s	ylr_reverse1
re_enter:
	move.w	d1,d3				; save leftx
	move.w	d2,d4				; save rightx
	and.w	d7,d3				; convert coordinate to lword offset
	and.w	d7,d4				; convert to lword offset
	add	d3,a1				; offset address register
	sub.w	d3,d4				; determine # of bytes
	beq.s	one_lword_case
	lsr.w	#2,d4
; now do left side
	move.l	(leftmasktable.w,a6,d1.w*4),d1
	move.l	(a1),d6
	and.l	d1,d6
	not.l	d1
	and.l	d0,d1
	or.l	d1,d6
	move.l	d6,(a1)+
; now, determine # of full words to do
	subq	#2,d4				; adjust for ends and dbra
	bmi.s	no_middle
1$:	move.l	d0,(a1)+
	dbra	d4,1$
no_middle:
	move.l	(rightmasktable.w,a6,d2.w*4),d2
	move.l	(a1),d1
	and.l	d2,d1
	not.l	d2
	and.l	d0,d2
	or.l	d2,d1
	move.l	d1,(a1)
	move.w	(a0)+,d1	; fetch next y
	bpl.s	nextylr
done_fill:
	OFFTIMER	10
	rts

one_lword_case:
; start and end are in one lword, so:
; mask=lmask | rmask
; if (mask=-1), right and left are reversed!
	move.l	(leftmasktable.w,a6,d1.w*4),d6
	or.l	(rightmasktable.w,a6,d2.w*4),d6
	move.l	(a1),d1
	and.l	d6,d1
	not.l	d6
	and.l	d0,d6
	or.l	d6,d1
	move.l	d1,(a1)
	move.w	(a0)+,d1
	bpl.s	nextylr
	OFFTIMER	10
	rts

ylr_reverse1:
; oh no! a backwards one has occurred due to precision problems!
; let's handle it as inefficiently as possible!
	exg	d1,d2
	bra.s	re_enter

YLRCCFill::
; fill gradient shaded polygons
	ONTIMER	10
	move.w	(a0)+,d1	; ycoord
	bmi.s	done_ylrcc
nextylrcc:
	move.l	(yadrtable.w,a6,d1.w*4),a1
	movem.w	(a0)+,d1/d2/d3/d4	; lx,rx, lc, rc
	cmp.w	d1,d2
	bge.s	no_ccrev
	exg	d3,d4
	exg	d1,d2
no_ccrev:
; now, determine delta color = (rc-lc)+1/(rc-lx+1)
	add	d1,a1		; adjust pointer
	sub	d1,d2		; d2=rx-lx
	addq	#1,d2		; rx-lc+1
	sub	d3,d4		; dc
	addq	#1,d4		; dc+1
	ext.l	d4		; for divide
	divs	d2,d4		; d4=dc*256
; now,
; d2=dbra count for output pixels
; d4=dc (8.8)
; d3=c (8.8)
; a1=output ptr
	ror.w	#8,d3		; d3=f.i
	move.b	d3,d0		; d0=c.i
	clr.b	d3		; d3=c.f
	ror.w	#8,d4
	move.b	d4,d1
	ext.w	d1
	clr.b	d4
	subq	#1,d2
	lsr.w	#1,d2
	bcc.s	ccfill_even
	move.b	d0,(a1)+
	add.w	d4,d3
	addx.w	d1,d0
ccfill_even:
	subq	#1,d2
	bmi.s	ccfill_done
ccfill_bytes:
	move.b	d0,(a1)+
	add.w	d4,d3
	addx.w	d1,d0
	move.b	d0,(a1)+
	add.w	d4,d3
	addx.w	d1,d0
	dbra	d2,ccfill_bytes
ccfill_done:
	move.w	(a0)+,d1
	bpl.s	nextylrcc
done_ylrcc:
	OFFTIMER	10
	rts

YLRUUFill::
; fill texture mapped polygons
; vbuffer contains v(x)
; out=*(tmapadr+v(x)+u(x)<<8)
;	bra	YLRUUFillT
	move.l	current_ltab(a6),d0
	bne.s	YLRUULFill
	move.w	(a0)+,d1	; ycoord
	bmi.s	done_ylrcc
nextylruu:	move.l	(yadrtable.w,a6,d1.w*4),a1	; dest coord
	movem.w	(a0)+,d1/d2/d3/d4	; lx,rx, lu, ru
	cmp.w	d1,d2
	bge.s	no_uurev
	exg	d3,d4
	exg	d1,d2
no_uurev:
; now, determine delta color = (rc-lc)+1/(rc-lx+1)
	lea	(vtable.w,a6,d1.w*4),a2	; vtable
	add	d1,a1		; adjust pointer
	sub	d1,d2		; d2=rx-lx
	addq	#1,d2		; rx-lc+1
	sub	d3,d4		; dc
	addq	#1,d4		; dc+1
	ext.l	d4		; for divide
	divs	d2,d4		; d4=dc*256
; now,
; d2=dbra count
; d4=du (8.8)
; d3=u (8.8)
; a1=output ptr
; a2=vtable
	ror.w	#8,d3		; d3=f.i
	moveq	#0,d0
	move.b	d3,d0		; d0=c.i
	clr.b	d3		; d3=c.f
	ror.w	#8,d4
	move.b	d4,d1
	ext.w	d1
	clr.b	d4
	ONTIMER	10
	lsr.w	#1,d2
	bcc.s	uufill_even
	move.l	(a2)+,a3
	move.b	(a3,d0.w),(a1)+
	add.w	d4,d3
	addx.w	d1,d0
uufill_even:
	subq	#1,d2
	bmi.s	fetchnextuu
uufill_bytes:
	move.l	(a2)+,a3
	move.b	(a3,d0.w),(a1)+
	add.w	d4,d3
	addx.w	d1,d0
	move.l	(a2)+,a3
	move.b	(a3,d0.w),(a1)+
	add.w	d4,d3
	addx.w	d1,d0
	dbra	d2,uufill_bytes
fetchnextuu:
	OFFTIMER	10
	move.w	(a0)+,d1
	bpl.s	nextylruu
done_ylruu:
	rts

YLRUULFill::
; fill texture mapped polygons, lighting with current_ltab
; vbuffer contains v(x)
; out=*(tmapadr+v(x)+u(x)<<8)
	move.l	d0,a4
	move.w	(a0)+,d1	; ycoord
	bmi.s	done_ylruu
nextylruul:
	move.l	(yadrtable.w,a6,d1.w*4),a1	; dest coord
	movem.w	(a0)+,d1/d2/d3/d4	; lx,rx, lu, ru
	cmp.w	d1,d2
	bge.s	no_uurevl
	exg	d3,d4
	exg	d1,d2
no_uurevl:
; now, determine delta color = (rc-lc)+1/(rc-lx+1)
	lea	(vtable.w,a6,d1.w*4),a2	; vtable
	add	d1,a1		; adjust pointer
	sub	d1,d2		; d2=rx-lx
	addq	#1,d2		; rx-lc+1
	sub	d3,d4		; dc
	addq	#1,d4		; dc+1
	ext.l	d4		; for divide
	divs	d2,d4		; d4=dc*256
; now,
; d2=dbra count
; d4=du (8.8)
; d3=u (8.8)
; a1=output ptr
; a2=vtable
	ror.w	#8,d3		; d3=f.i
	moveq	#0,d0
	move.b	d3,d0		; d0=c.i
	clr.b	d3		; d3=c.f
	ror.w	#8,d4
	move.b	d4,d1
	ext.w	d1
	clr.b	d4
	moveq	#0,d7
	ONTIMER	10
	lsr.w	#1,d2
	bcc.s	uufill_evenl
	move.l	(a2)+,a3
	move.b	(a3,d0.w),d7
	move.b	(a4,d7.w),(a1)+
	add.w	d4,d3
	addx.w	d1,d0
uufill_evenl:
	subq	#1,d2
	bmi.s	fetchnextuul
uufill_bytesl:
	move.l	(a2)+,a3
	move.b	(a3,d0.w),d7
	move.b	(a4,d7.w),(a1)+
	add.w	d4,d3
	addx.w	d1,d0
	move.l	(a2)+,a3
	move.b	(a3,d0.w),d7
	move.b	(a4,d7.w),(a1)+
	add.w	d4,d3
	addx.w	d1,d0
	dbra	d2,uufill_bytesl
fetchnextuul:
	OFFTIMER	10
	move.w	(a0)+,d1
	bpl	nextylruul
rts1	rts


	xref	blend_table

YLRUUFillT::
; fill texture mapped transparent polygons
; vbuffer contains v(x)
; out=*(tmapadr+v(x)+u(x)<<8)
	move.l	#blend_table,a4
	move.w	(a0)+,d1	; ycoord
	bmi.s	rts1
nextylruut:
	move.l	(yadrtable.w,a6,d1.w*4),a1	; dest coord
	movem.w	(a0)+,d1/d2/d3/d4	; lx,rx, lu, ru
	cmp.w	d1,d2
	bge.s	no_uurevt
	exg	d3,d4
	exg	d1,d2
no_uurevt:
; now, determine delta color = (rc-lc)+1/(rc-lx+1)
	lea	(vtable.w,a6,d1.w*4),a2	; vtable
	add	d1,a1		; adjust pointer
	sub	d1,d2		; d2=rx-lx
	addq	#1,d2		; rx-lc+1
	sub	d3,d4		; dc
	addq	#1,d4		; dc+1
	ext.l	d4		; for divide
	divs	d2,d4		; d4=dc*256
; now,
; d2=dbra count
; d4=du (8.8)
; d3=u (8.8)
; a1=output ptr
; a2=vtable
; a4=ltable
	ror.w	#8,d3		; d3=f.i
	moveq	#0,d0
	move.b	d3,d0		; d0=c.i
	clr.b	d3		; d3=c.f
	ror.w	#8,d4
	move.b	d4,d1
	ext.w	d1
	clr.b	d4
	ONTIMER	10
	lsr.w	#1,d2
	bcc.s	uufill_event
	move.l	(a2)+,a3
	move.w	-1(a3,d0.w),d7
	move.b	(a1),d7
	move.b	(a4,d7.w),(a1)+
	add.w	d4,d3
	addx.w	d1,d0
uufill_event:
	subq	#1,d2
	bmi.s	fetchnextuut
uufill_bytest:
	move.l	(a2)+,a3
	move.w	-1(a3,d0.w),d7
	move.b	(a1),d7
	move.b	(a4,d7.w),(a1)+
	add.w	d4,d3
	addx.w	d1,d0
	move.l	(a2)+,a3
	move.w	-1(a3,d0.w),d7
	move.b	(a1),d7
	move.b	(a4,d7.w),(a1)+
	add.w	d4,d3
	addx.w	d1,d0
	dbra	d2,uufill_bytest
fetchnextuut:
	OFFTIMER	10
	move.w	(a0)+,d1
	bpl	nextylruut
	rts


	section	__MERGED,data

current_color::
	dc.l	$ffffffff
current_ltab::
	dc.l	0
