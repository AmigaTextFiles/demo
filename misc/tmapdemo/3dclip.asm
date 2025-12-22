; $$TABS=8
; simple, dumb 3d polygon clipper.


	include	'demo.i'
	include	'3d.i'

	xref	point_coder,vertex,UnClippedPolygon


DrawClippedPolygon::
;
; input d0=orcodes,d1=andcodes
; (a0)=src poly (a1)=end poly
	ONTIMER	6
	move.w	#4,cliplim(a6)
	lea	temp_polygon_buffer2(pc),a2
reclip:
	btst	#CLIPB_TOP,d0
	beq.s	no_topclip
	lea	intersect_top(pc),a3
	moveq	#CLIPB_TOP,d3
	bsr	ClipPlane
	tst.w	d1	; codes_and !=0?
	beq.s	no_topclip
reject_polygon:
	OFFTIMER	6
	rts
no_topclip:
	btst	#CLIPB_BOT,d0
	beq.s	no_botclip
	lea	intersect_bot(pc),a3
	moveq	#CLIPB_BOT,d3
	bsr	ClipPlane
	tst.w	d1
	bne.s	reject_polygon
no_botclip:
	btst	#CLIPB_RIGHT,d0
	beq.s	no_rightclip
	lea	intersect_right(pc),a3
	moveq	#CLIPB_RIGHT,d3
	bsr.s	ClipPlane
	tst.w	d1
	bne.s	reject_polygon
no_rightclip:
	btst	#CLIPB_LEFT,d0
	beq.s	no_leftclip
	lea	intersect_left(pc),a3
	moveq	#CLIPB_LEFT,d3
	bsr.s	ClipPlane
	tst.w	d1
	bne.s	reject_polygon
no_leftclip:
	tst.w	d0	; any codes set?
	beq.s	project_polygon
	subq.w	#1,cliplim(a6)
	bne.s	reclip
	OFFTIMER	6
	rts

project_polygon:
; now, project it and move it to vertex
	ONTIMER	7
	lea	vertex(a6),a2
	moveq	#0,d0
project_loop:
	move.w	(a0)+,d4
	move.w	(a0)+,d5
	move.w	(a0)+,d6
	lea	2(a0),a0		; codes
	muls	#(DUNGEON_WINDOW_WIDTH/2),d4
	divs	d6,d4
	add.w	#DUNGEON_WINDOW_WIDTH/2,d4
	swap	d4
	muls	#(DUNGEON_WINDOW_HEIGHT/2),d5
	divs	d6,d5
	add.w	#DUNGEON_WINDOW_HEIGHT/2,d5
	move.w	d5,d4
	move.l	d4,(a2)+
	addq	#1,d0
	move.l	(a0)+,(a2)+
	cmp.l	a0,a1
	bne.s	project_loop
	OFFTIMER	7
	bsr	UnClippedPolygon
	rts

ClipPlane::
; ClipPlane - clip a polygon against a plane.
; input: a0=src poly a1=end poly a2=dest poly a3=clip routine d3=clip bit
; output: d0=or'd codes d1=anded codes
; 	a1=new end a0,a2 swapped
; polygon format is x y z c u1 u2
; where u1 and u2 are additional parameters to be clipped
; one clipper instead of 4 for simplicity and to fit in cache.
	move.l	a0,-(a7)
	move.l	a2,-(a7)
	moveq	#0,d0	; orcodes=0
	moveq	#-1,d1	; andcodes=-1. only lower word valid
; now, move first to last
	movem.l	(a0),d2/d4/d5/d6/d7/a4	; 6 lwords=2 pts
	movem.l	d2/d4/d5/d6/d7/a4,(a1)
	lea	6*2(a1),a1
clip_loop:
	lea	6*2(a0),a0		; skip initial point and handle in the wrap	
	cmp.l	a0,a1
	beq.s	done_clip
trivial_accept_loop:
	move.w	6(a0),d6		; fetch codes
	btst	d3,d6
	bne.s	cur_off
	move.l	(a0)+,(a2)+	; x y
	or.w	d6,d0		; interleave writes and ops because of wait-states
	move.l	(a0)+,(a2)+	; z c
	and.w	d6,d1
	move.l	(a0)+,(a2)+	; u1 u2
	cmp.l	a0,a1
	bne.s	trivial_accept_loop
done_clip:	move.l	a2,a1		; a1=poly+npnts
	move.l	(a7)+,a0
	move.l	(a7)+,a2		; src and dest now swapped
	rts
cur_off:
; the current point is off.
; if the previous was on, output the point bwteen prev and cur
; if the next is on, output the point between cur and next
; the plane clip routine takes d4/d5/d6=on point, (a5)=off point, d7=offy and returns
; d4/d5/d6=intxyz, d2=t
	btst	d3,-12+7(a0)	; prv off?
	bne.s	prv_was_off
	movem.w	-12(a0),d4/d5/d6
	move.l	a0,a5
	move.w	2(a5),d7
	jsr	(a3)		; call plane clip routine
	bsr	point_coder
	movem.w	d4-d7,(a2)		; output xyz
	or.w	d7,d0
	and.w	d7,d1
	lea	8(a2),a2
	move.w	8(a0),d7		; d7=u1
	move.w	-12+8(a0),d4	; d4=u0
	sub.w	d4,d7
	muls	d2,d7
	add.l	d7,d7
	swap	d7
	add.w	d4,d7
	move.w	d7,(a2)+
	move.w	10(a0),d7		; d3=v1
	move.w	-12+10(a0),d4	; d4=v0
	sub.w	d4,d7
	muls	d2,d7
	add.l	d7,d7
	swap	d7
	add.w	d4,d7
	move.w	d7,(a2)+
prv_was_off:
	btst	d3,7+12(a0)		; next off?
	bne.s	clip_loop		; next off too, so we are done
	movem.w	12(a0),d4/d5/d6
	move.l	a0,a5
	move.w	2(a5),d7
	jsr	(a3)		; comput intersection
	bsr	point_coder
	movem.w	d4-d7,(a2)		; output xyz
	or.w	d7,d0
	and.w	d7,d1
	lea	8(a2),a2
	move.w	8(a0),d7		; d3=u1
	move.w	12+8(a0),d4	; d4=u0
	sub.w	d4,d7
	muls	d2,d7
	add.l	d7,d7
	swap	d7
	add.w	d4,d7
	move.w	d7,(a2)+
	move.w	10(a0),d7		; d3=v1
	move.w	12+10(a0),d4	; d4=v0
	sub.w	d4,d7
	muls	d2,d7
	add.l	d7,d7
	swap	d7
	add.w	d4,d7
	move.w	d7,(a2)+
	bra	clip_loop

intersect_top:
; point is above z=y
; so, t=(z0-y0)/(y1-y0-z1+z0)
; out=(x1-x0)*t+x0,(y1-y0)*t+y0,y
; (a4)=x0 (a5)=x1
; ret d4/d5/d6=xyz d2=t can trash d7/a4/a5
	move.w	d6,d2	; d2=z0
	sub.w	d5,d2	; d2=z0-y0
	swap	d2
	clr.w	d2
	asr.l	#1,d2
	sub.w	d5,d6	; d6=z0-y0
	add.w	d7,d6	; d6=y1-y0+z0
	sub.w	4(a5),d6	; d6=y1-y0-z1+z0
	divs	d6,d2	; d2=t
	move.w	d4,d6	; d6=x0
	sub.w	(a5),d4
	neg.w	d4	; d4=x1-x0
	muls	d2,d4
	add.l	d4,d4
	swap	d4	; d4=t*(x1-x0)
	add.w	d6,d4	; d4=outx=t*(x1-x0)+x0
	sub.w	d5,d7	; d7=y1-y0
	muls	d2,d7
	add.l	d7,d7
	swap	d7
	add.w	d7,d5	; d5=outy=t*(x1-y0)+y0
	move.w	d5,d6	; d6=outz=outy
	rts

intersect_bot:
; point is below z=-y
; so, t=(z0+y0)/(y0+z0-z1-y1)
; out=(x1-x0)*t+x0,(y1-y0)*t+y0,-y
; (a4)=x0 (a5)=x1
; ret d4/d5/d6=xyz d2=t can trash d7/a4/a5
	move.w	d6,d2		; d2=z0
	add.w	d5,d2		; d2=z0+y0
	swap	d2
	clr.w	d2
	asr.l	#1,d2
	sub.w	d7,d6		; d6=z0-y1
	add.w	d5,d6		; d6=z0-y1+y0
	sub.w	4(a5),d6	; d6=z0-y1+y0-z1
	divs	d6,d2		; d2=t
	move.w	d4,d6		; d6=x0
	sub.w	(a5),d4
	neg.w	d4		; d4=x1-x0
	muls	d2,d4
	add.l	d4,d4
	swap	d4		; d4=t*(x1-x0)
	add.w	d6,d4		; d4=outx=t*(x1-x0)+x0
	sub.w	d5,d7		; d7=y1-y0
	muls	d2,d7
	add.l	d7,d7
	swap	d7
	add.w	d7,d5		; d5=outy=t*(x1-y0)+y0
	move.w	d5,d6	
	neg.w	d6		; d6=outz=-outy
	rts

intersect_right:
; point is to the right of z=x
; so, t=(x0-z0)/(z1-x1+x0-z0)
; out=(x1-x0)*t+x0, (y1-y0)*t+y0, x
	move.w	d4,d2		; d2=x0
	sub.w	d6,d2		; d2=x0-z0
	swap	d2
	clr.w	d2
	asr.l	#1,d2
	neg.w	d6		; d6=-z0
	add.w	d4,d6		; d6=x0-z0
	sub.w	(a5),d6		; d6=-x1+x0-z0
	add.w	4(a5),d6		; d6=z1-x1+x0-z0
	divs	d6,d2		; d2=t
	move.w	d4,d6		; d6=x0
	sub.w	(a5),d4
	neg.w	d4		; d4=x1-x0
	muls	d2,d4
	add.l	d4,d4
	swap	d4		; d4=t*(x1-x0)
	add.w	d6,d4		; d4=outx=t*(x1-x0)+x0
	sub.w	d5,d7		; d7=y1-y0
	muls	d2,d7
	add.l	d7,d7
	swap	d7
	add.w	d7,d5		; d5=outy=t*(y1-y0)+y0
	move.w	d4,d6		; d6=outz=x
	rts
	
intersect_left:
; point is to the left of z=-x
; so,t=(z0+x0)/(x0+z0-z1-x1)
; out=(x1-x0)*t+x0, (y1-y0)*t+y0, -x
	add	d4,d6		; d6=z0+x0
	move	d6,d2
	swap	d2
	clr.w	d2
	asr.l	#1,d2
	sub.w	(a5),d6		; d6=z0+x0-x1
	sub.w	4(a5),d6		; d6=z0+x0-x1
	divs	d6,d2		; d2=t
	move.w	d4,d6
	sub.w	(a5),d4		; x0-x1
	neg.w	d4		; x1-x0
	muls	d2,d4
	add.l	d4,d4
	swap	d4
	add.w	d6,d4		; d4=outx
	move.w	d5,d6		; d6=y0
	sub.w	d7,d5		; y0-y1
	neg.w	d5		; y1-y0
	muls	d2,d5
	add.l	d5,d5
	swap	d5
	add.w	d6,d5
	move.w	d4,d6
	neg.w	d6
	rts





temp_polygon_buffer2:
	ds.w	6*20		; 18 vertices max

	section	__MERGED,data
cliplim::	dc.w	0
