;$$TABS=8
;
; PolyFill.asm - simple, stupid polygon filler. No heavy attempt at
;	 optimization, since this demo doesn't really use it much.

	include	'demo.i'

VERTEX_SIZE	equ	4*2	; xyuv

	xref	YLRFill,YLRCCFill,YLRUUFill

fracbits	equ	6

get_right:
; now, loop until y change
	move.l	d5,save_d5(a6)
	move.l	right_ptr(a6),a2
gr_1:	move	(a2),d4
	move.w	4(a2),d5	; rightc
	lea	VERTEX_SIZE(a2),a2
	cmp.l	a0,a2
	bne.s	gr_2
	lea	vertex(a6),a2
gr_2	move	(a2),d1
	move	2(a2),d7
	subq	#1,d0		; better check for neg
	ble.s	got_right
	cmp	d7,d2		; same y ?
	ble.s	gr_1
; now, d4,d2=top d1/d7=bot
	move.w	d5,c_right(a6)
	sub	4(a2),d5
	ext.l	d5
	move	d7,rbot(a6)
	sub	d2,d7
	divs	d7,d5
	move.w	d5,dc_right(a6)
	neg	d7
	sub	d4,d1		; dx
	ext.l	d1
	lsl.l	#fracbits,d1
	divs	d7,d1		; dx/dy<<fracbits
	ext.l	d1
	moveq	#16-fracbits,d7
	lsl.l	d7,d1
	swap	d4
	clr	d4
	move.l	save_d5(a6),d5
got_right:
	move.l	a2,right_ptr(a6)
	rts

get_left:
	move.l	left_ptr(a6),a1
	move.l	d5,save_d5(a6)
	move.l	d4,save_d4(a6)
; now, loop until y change
gl_1:	move	(a1),d3
	move	4(a1),d4
	lea	-VERTEX_SIZE(a1),a1
	cmp.l	#vertex-VERTEX_SIZE,a1
	bne.s	gl_2
	lea	-VERTEX_SIZE(a0),a1
gl_2	move	(a1),d5
	move	2(a1),d7
; same y
	subq	#1,d0		; better check for neg
	ble.s	got_left_lst
	cmp	d7,d2		; same y ?
	ble.s	gl_1
; now, d3,d2=top d1/d7=bot
	move.w	d4,c_left(a6)
	move	d7,lbot(a6)
	sub	d2,d7
	sub	4(a1),d4
	ext.l	d4
	divs	d7,d4
	move.w	d4,dc_left(a6)
	neg	d7
	sub	d3,d5		; dx
	ext.l	d5
	lsl.l	#fracbits,d5
	divs	d7,d5		; dx/dy<<fracbits
	ext.l	d5
	moveq	#16-fracbits,d7
	lsl.l	d7,d5
	swap	d3
	clr	d3
	move.l	a1,left_ptr(a6)
	move.l	save_d4(a6),d4
got_left
	rts
got_left_lst
	move.l	a1,left_ptr(a6)
	move.l	save_d5(a6),d5
	rts

UnClippedPolygon::
; UnClippedPolygon - draw an unclipped polygon
; entr: VERTEX=x,y x,y x,y ...
; D0=nverts (3 for a triangle)
; except for termination, this routine fits entirely in the 256 byte cache.

	ONTIMER	5
	move	d0,d1		; loop ctr

	subq	#1,d1
	moveq	#-127,d2		; highest so far
	lea	vertex(a6),a0
	move.l	a0,a3		; leftmost vertex
	move.l	a0,a4		; rightmost vertex
up_1:	move.w	(a0),d3
	cmp.w	(a3),d3
	bge.s	no_new_left
	move.l	a0,a3
no_new_left:
	cmp.w	(a4),d3
	ble.s	no_new_right
	move.l	a0,a4
no_new_right:
	cmp	2(a0),d2
	bgt.s	up_2
	move	2(a0),d2
	move.l	a0,a1		; pointer to top
up_2:	lea	VERTEX_SIZE(a0),a0
	dbra	d1,up_1
	move.l	a1,a2
	movem.l	a1/a2/a3/a4,left_ptr(a6)

; now, fill in vtable!
	move.l	YLRFiller(a6),d1
	cmp.l	#YLRUUFill,d1
	bne.s	done_vtable
	move.w	(a3),d1		; leftx
	move.w	6(a3),d5	; leftv
	move.w	(a4),d3		; rightx
	move.w	6(a4),d4	; rightv
	move.l	current_tmap(a6),a4
	move.w	4(a4),d6	; shift up
	lea	6(a4),a4
	lea	(vtable.w,a6,d1.w*4),a2	; outv
	sub	d5,d4		; rv-lv
	addq	#1,d4
	sub	d1,d3		; rx-lx
	addq	#1,d3
	ext.l	d4
	divs	d3,d4
	subq	#1,d3
1$:	moveq	#0,d7
	move.w	d5,d7
	lsr.w	#8,d7
	lsl.l	d6,d7
	add.l	a4,d7
	move.l	d7,(a2)+
	add.w	d4,d5
	dbra	d3,1$
done_vtable:
	addq	#1,d0
	bsr	get_left
	bsr	get_right

; register usage:
; d0=#verts left
; d1=rightdx<<16
; d2=cury
; d3=leftx<<16
; d4=rightx<<16
; d5=leftdx<<16
; d6=ycounter

; (a0)=end of vertex buffer+4
; (a3)=ylr ptr
; 
	lea	temp_ylr(pc),a3
new_trapezoid:
	tst	d0
	ble.s	do_end
	move	d2,d6		; top y
	move	d2,d7
	sub	lbot(a6),d6
	sub	rbot(a6),d7		
	cmp	d6,d7
	bge.s	no_r_ends_first
	move	d7,d6
no_r_ends_first:
	move.w	d0,-(a7)
	move.w	c_left(a6),d7
	move.w	c_right(a6),d0
	move.w	dc_left(a6),a1
	move.w	dc_right(a6),a2
	ONTIMER	11

	subq	#1,d6
fill_lp:
	move	d2,(a3)+
	swap	d3
	subq	#1,d2
	move	d3,(a3)+
	swap	d3
	swap	d4
	move	d4,(a3)+
	swap	d4
	add.l	d1,d4
	move.w	d7,(a3)+
	add.w	a1,d7
	move.w	d0,(a3)+
	add.w	a2,d0
	add.l	d5,d3
	dbra	d6,fill_lp
	OFFTIMER	11
	move.w	d0,c_right(a6)
	move.w	d7,c_left(a6)
	move.w	(a7)+,d0
	cmp	lbot(a6),d2
	bne.s	no_l_chg
	bsr	get_left
no_l_chg:
	cmp	rbot(a6),d2
	bne	new_trapezoid
	bsr	get_right
	bra	new_trapezoid

do_end:
; do last scan line
	lea	temp_ylr(pc),a4
	cmp.l	a3,a4
	bne.s	tr_1
; no scan-lines were output, so fill a horizontal line between max and min x/y
yes_fill1:
	move.l	leftmost_vertex(a6),a0
	move.l	rightmost_vertex(a6),a1
	move	d2,(a3)+
	move	(a0),(a3)+
	move	(a1),(a3)+
	move	4(a0),(a3)+
	move	4(a1),(a3)+
	st	(a3)
	lea	temp_ylr(pc),a0
	OFFTIMER	5
	move.l	YLRFiller(a6),a1
	jmp	(a1)
tr_1:	move	d2,(a3)+
	swap	d3
	swap	d4
	move	d3,(a3)+
	move	d4,(a3)+
	move.l	c_left(a6),(a3)+
no_fill2:
	st	(a3)
	lea	temp_ylr(pc),a0
	OFFTIMER	5
	move.l	YLRFiller(a6),a1
	jmp	(a1)

temp_ylr::
	ds.w	(DUNGEON_WINDOW_HEIGHT+3)*5+1


	section	__MERGED,data
YLRFiller::	dc.l	YLRCCFill
save_d5::	ds.l	1
save_d4::	ds.l	1
rbot::	ds.w	1
lbot::	ds.w	1
; tmapped polygon data fmt:
; xyuv
vertex::
	ds.b	50*VERTEX_SIZE	; enough room for 50 point poly
left_ptr::	dc.l	0
right_ptr::	dc.l	0
leftmost_vertex::
	dc.l	0
rightmost_vertex::
	dc.l	0

c_left::	dc.w	$2000
c_right::	dc.w	$4000
dc_left::	dc.w	$0000
dc_right::	dc.w	$0000
current_tmap::	dc.l	0

	dc.l	0
vtable::	ds.l	DUNGEON_WINDOW_WIDTH
	dc.l	0


	end

