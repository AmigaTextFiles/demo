; $$TABS=8
	include	'demo.i'
; simple 3d package
; only supports heading for now.

	xref	PlayerHeading,PlayerX,PlayerY,PlayerZ
	xref	current_color,sincos,UnClippedPolygon,vertex
	xref	DrawClippedPolygon
	xref	YLRCCFill,YLRUUFill,YLRFiller,lightingtab,current_ltab
	
	xref	KingTut,Fish,Mandrill,Wolves,current_tmap

DUNGEON_PT_SIZE	equ	16	; xyzcuv..
DUNGEON_PT_SHIFT	equ	4

render_3d::
	ONTIMER	3
	bsr	generate_matrix
	clr.l	current_color(a6)
	bsr	DoGridPoints
	ONTIMER	12
	bsr	LightPoints
	OFFTIMER	12
	move.l	#YLRCCFill,YLRFiller(a6)
	bsr	RenderFloor
	move.l	#YLRUUFill,YLRFiller(a6)
	bsr	add_objects
	OFFTIMER	3
	rts


generate_matrix::
	move.w	PlayerHeading(a6),d0
	neg.w	d0
	bsr	sincos		; d0=sin d1=cos
	move.w	d1,m11(a6)
	move.w	d1,m33(a6)
	move.w	d0,m31(a6)
	neg.w	d0
	move.w	d0,m13(a6)
	asr.w	m13(a6)
	asr.w	m33(a6)
	rts

XForm32::
; entr d4/d5/d6=xyz
; returns d4-d6=32 bit xyz
; trashes d0/d7
	sub.l	PlayerX(a6),d4
	sub.l	PlayerY(a6),d5
	sub.l	PlayerZ(a6),d6
	muls	m22(a6),d5
	add.l	d5,d5
	move.l	d4,d0
	move.l	d6,d7	
	muls	m11(a6),d4
	muls	m31(a6),d7
	add.l	d7,d4
	add.l	d4,d4
	muls	m13(a6),d0
	muls	m33(a6),d6
	add.l	d0,d6
	add.l	d6,d6
	rts


Do3dPoint:
; entr (a5)=16 bit xyz coordinates
; exit:d4-d7=point,codes
;      (a5)=next point
; trashes: d0
;
	movem.w	(a5),d4/d5/d6
	lea	3*2(a5),a5
	sub.l	PlayerX(a6),d4
	sub.l	PlayerY(a6),d5
	sub.l	PlayerZ(a6),d6

matrix_multiply::
; for a pure heading matrix, only m11, m13, m31, m33 are important
; (to throw in y scaling, m22 is the key)
; x'=(xyz).(m11,m21,m31)
; y'=(xyz).(m12,m22,m32)
; z'=(xyz).(m13,m23,m33)
; entr: d4-d6=xyz
; exit: d4-d6.w=xyz' d7=codes
; trashes:
	muls	m22(a6),d5
	add.l	d5,d5
	swap	d5
	move.l	d4,d0
	move.l	d6,d7	
	muls	m11(a6),d4
	muls	m31(a6),d7
	add.l	d7,d4
	add.l	d4,d4
	swap	d4
	muls	m13(a6),d0
	muls	m33(a6),d6
	add.l	d0,d6
	add.l	d6,d6
	swap	d6

point_coder::
; d7=codes(d4,d5,d6)
; B0 = point to left of z=-x
; B1 = point to right of z=x
; B2 = point above z=y
; B3 = point below z=-y
; B8 = z<0 (2d clip-possible flag)
; cc reflects d7
	move	d6,d7
	neg	d7
	bge.s	set_7
	cmp	d7,d4
	blt.s	set_0
	cmp	d6,d4
	bgt.s	set_1
	cmp	d6,d5
	bgt.s	set_2
	cmp	d7,d5
	blt.s	set_3
	moveq	#0,d7
	rts
set_0:	cmp	d6,d5
	bgt.s	set_902
	cmp	d7,d5
	blt.s	set_903
	moveq	#1,d7
	rts
set_902:
	moveq	#5,d7
	rts
set_903:
	moveq	#9,d7
	rts
set_1:	cmp	d6,d5
	bgt.s	set_12
	cmp	d7,d5
	blt.s	set_13
	moveq	#2,d7
	rts
set_12:	moveq	#6,d7
	rts
set_13:	moveq	#$0a,d7
	rts
set_2:	moveq	#4,d7
	rts
set_3:	moveq	#8,d7
	rts
set_7:	cmp	d7,d4
	blt.s	set_8
	cmp	d6,d5
	bgt.s	set_712
	moveq	#$ffffff8a,d7
	rts
set_8:	cmp	d6,d4
	bgt.s	set_81
	cmp	d6,d5
	bgt.s	set_82
	moveq	#$ffffff89,d7
	rts
set_81:	cmp	d6,d5
	bgt.s	set_52
	moveq	#$ffffff8b,d7
	rts
set_52:	cmp	d7,d5
	blt.s	set_523
	moveq	#$ffffff87,d7
	rts
set_523:
	moveq	#$ffffff8f,d7
	rts
set_82:	cmp	d7,d5
	blt.s	set_823
	moveq	#$ffffff85,d7
	rts
set_823:
	moveq	#$ffffff8d,d7
q	rts
set_712:
	cmp	d7,d5
	blt.s	set_4
	moveq	#$ffffff86,d7
	rts
set_4:	moveq	#$ffffff8e,d7
	rts

DUNGEON_MINX	equ	-8192
DUNGEON_MINZ	equ	-8192
DUNGEON_XSTEP	equ	16384*2/(DUNGEON_GRID_SIZE)
DUNGEON_ZSTEP	equ	16384*2/(DUNGEON_GRID_SIZE)
DUNGEON_Y		equ	0
DUNGEON_TOPY	equ	2000

LightPoints:
; now, light all grid points.
; intens=intenstable(|x^2+z^2|)
	move.l	#DUNGEON_MINX,d0
	move.l	#DUNGEON_MINZ,d1
	sub.l	PlayerX(a6),d0
	sub.l	PlayerZ(a6),d1
	move.w	#DUNGEON_GRID_SIZE-1,d2	; outer counter
	move.l	#DungeonPoints,a0
	move.l	#intenstable,a2
outer_lloop:
	move.l	a0,a1			; save
	move.l	d0,d7
	move.w	#(DUNGEON_GRID_SIZE)-1,d3	; inner counter
	move	d1,d5
	muls	d5,d5
inner_lloop:
	move	d0,d4
	muls.w	d4,d4
	add.l	d5,d4
	bpl.s	1$
	neg.l	d4
1$:
	swap	d4
	cmp.w	#256,d4
	blo.s	2$
	move.w	#255,d4
2$:	move.w	(a2,d4.w*2),d4
	move.w	d4,8(a0)

	ifne	DO_CEILING
	move.w	d4,d6
	mulu	10+DUNGEON_PT_SIZE(a0),d6
	swap	d6
	move	d6,10+DUNGEON_PT_SIZE(a0)
	endc

	mulu	10(a0),d4
	swap	d4
	move.w	d4,10(a0)


	add.l	#DUNGEON_XSTEP/2,d0
	lea	DUNGEON_PT_SIZE*2(a0),a0
	dbra	d3,inner_lloop
	lea	DUNGEON_GRID_SIZE*2*DUNGEON_PT_SIZE(a1),a0
	move.l	d7,d0
	add.l	#DUNGEON_ZSTEP/2,d1
	dbra	d2,outer_lloop
	rts

DoGridPoints:
; fill DungeonPoints with interpolated grid
; 
; startpt=xform32(MINX,0,MINZ)
; dp/dx=(m11*xstep,0,m13*xstep)
; dp/dz=(m31*zstep,0,m33*zstep)
; for(i=0;i<grid_size;i++)
;   tempp=startpt
;   for(j=0;j<grid_size;j++)
;     *(nextpt++)=tempp *(nextpt++)=codes(tempp)
;     tempp+-dp/dx
;   startpt+=dp/dz

	move.w	#$1234,rand_seed(a6)
	ONTIMER	8
	move.l	#DUNGEON_MINX,d4
	move.l	#DUNGEON_Y,d5
	move.l	#DUNGEON_MINZ,d6
	bsr	XForm32				; d4-d6=upper left corner
	swap	d5
; now, gen deltas
	move.l	#DUNGEON_TOPY,d0
	sub.l	PlayerY(a6),d0
	muls	m22(a6),d0
	add.l	d0,d0
	swap	d0
	move.w	m11(a6),d1
	muls	#DUNGEON_XSTEP,d1
	move.l	d1,a5
	move.w	m13(a6),d1
	muls	#DUNGEON_XSTEP,d1		; a5/d1=dp/dx
	move.w	m31(a6),d2
	muls	#DUNGEON_ZSTEP,d2
	move.w	m33(a6),d3
	muls	#DUNGEON_ZSTEP,d3
	move.l	d2,a1
	move.l	d3,a2				; a1/a2=dp/dz
	move.l	#DungeonPoints,a0
	moveq	#DUNGEON_GRID_SIZE-1,d2		; outer counter
outer_loop:
	move.l	d4,a3				; save
	move.l	d6,a4
	moveq	#DUNGEON_GRID_SIZE-1,d3		; inner counter
inner_loop:
	swap	d4
	swap	d6
	bsr	point_coder
	movem.w	d4-d7,(a0)
	move.w	rand_seed(a6),d7
	mulu	#$1efd,d7
	add	#$dff,d7
	move.w	d7,rand_seed(a6)
	move.w	d7,10(a0)
	exg.l	d0,d5
	bsr	point_coder
	movem.w	d4-d7,DUNGEON_PT_SIZE(a0)

	ifne	DO_CEILING
	move.w	rand_seed(a6),d7
	mulu	#$1efd,d7
	add	#$dff,d7
	move.w	d7,rand_seed(a6)
	move.w	d7,DUNGEON_PT_SIZE+10(a0)
	endc

	lea	DUNGEON_PT_SIZE*2(a0),a0
	exg.l	d0,d5
	swap	d4
	swap	d6
	add.l	a5,d4
	add.l	d1,d6
	dbra	d3,inner_loop
	move.l	a3,d4
	move.l	a4,d6
	add.l	a1,d4
	add.l	a2,d6
	dbra	d2,outer_loop
	OFFTIMER	8
	rts

RenderFloor:
; now, let's attempt to fill polygons for a test
; for(i=0;i<npoints-1;i++)
;  for(j=0;j<npoints-1;j++)
;   dopoly(dp[i,j],dp[i,j+1],dp[i+1,j+1],dp[i+1,j]
	ONTIMER	9
	move.l	#DungeonPoints,a0
	move.w	#DUNGEON_GRID_SIZE-2,d7	; outer
1$:
	ifne	DO_CEILING
	move.w	#((DUNGEON_GRID_SIZE-1)*2)-1,d6	; inner
	else
	move.w	#(DUNGEON_GRID_SIZE-1)-1,d6
	endc

	move.l	a0,a1			; save
2$:
	lea	temp_polygon_buffer(a6),a2
	movem.w	(a1),d2/d3/d4/d5		; xyzc
	move.w	d5,d0		; orcodes
	move.w	d5,d1		; andcodes
	movem.w	d2/d3/d4/d5,(a2)
	move.w	10(a1),8(a2)
	lea	6*2(a2),a2

	movem.w	DUNGEON_PT_SIZE*2(a1),d2/d3/d4/d5		; xyzc
	or.w	d5,d0
	and.w	d5,d1
	movem.w	d2/d3/d4/d5,(a2)
	move.w	DUNGEON_PT_SIZE*2+10(a1),8(a2)
	lea	6*2(a2),a2

	movem.w	DUNGEON_GRID_SIZE*DUNGEON_PT_SIZE*2+DUNGEON_PT_SIZE*2(a1),d2/d3/d4/d5
					; xyzc
	or.w	d5,d0
	and.w	d5,d1
	movem.w	d2/d3/d4/d5,(a2)
	move.w	DUNGEON_GRID_SIZE*DUNGEON_PT_SIZE*2+DUNGEON_PT_SIZE*2+10(a1),8(a2)
	lea	6*2(a2),a2

	movem.w	DUNGEON_GRID_SIZE*DUNGEON_PT_SIZE*2(a1),d2/d3/d4/d5		; xyzc
	and.w	d5,d1
	bne.s	3$	; trivial reject
	or.w	d5,d0
	movem.w	d2/d3/d4/d5,(a2)
	move.w	DUNGEON_GRID_SIZE*DUNGEON_PT_SIZE*2+10(a1),8(a2)
	lea	6*2(a2),a2
	movem.l	d6/d7/a0/a1,-(a7)
	move.l	a2,a1
	lea	temp_polygon_buffer(a6),a0
	OFFTIMER	9
	bsr	DrawClippedPolygon
	ONTIMER	9
	movem.l	(a7)+,d6/d7/a0/a1
3$:	ifne	DO_CEILING
	lea	DUNGEON_PT_SIZE(a1),a1	; was *2
	else
	lea	DUNGEON_PT_SIZE*2(a1),a1
	endc
	dbra	d6,2$
	lea	DUNGEON_GRID_SIZE*DUNGEON_PT_SIZE*2(a0),a0
	dbra	d7,1$
	OFFTIMER	9
done_3dblock:
	rts

DO_FACE	macro	x1,z1,x2,z2
;		\1 \2 \3 \4
; generate x1,-y,z1 x2,-y,z2 x2,+y,z2 x1,+y,z1
	moveq	#0,d0	;; codes_or
	moveq	#-1,d1	;; codes_and
	lea	temp_polygon_buffer(a6),a1
	move.l	a1,a0
	move.l	\2,d3
	lsl.l	#DUNGEON_GRID_SHIFT,d3
	add.l	\1,d3
	lsl.l	#DUNGEON_PT_SHIFT+1,d3
	move.l	#DungeonPoints,a2
	add.l	d3,a2
	move.w	6(a2),d3
	or.w	d3,d0
	and.w	d3,d1
	move.l	(a2),(a1)
	move.l	4(a2),4(a1)
	move.l	#$7fff0000,8(a1)
	move.w	8(a2),d2
	move.w	DUNGEON_PT_SIZE+6(a2),d3
	or.w	d3,d0
	and.w	d3,d1
	move.l	DUNGEON_PT_SIZE(a2),36(a1)
	move.l	DUNGEON_PT_SIZE+4(a2),40(a1)
	move.l	#$00000000,44(a1)
	move.l	\4,d3
	lsl.l	#DUNGEON_GRID_SHIFT,d3
	add.l	\3,d3
	lsl.l	#DUNGEON_PT_SHIFT+1,d3
	move.l	#DungeonPoints,a2
	add.l	d3,a2
	move.w	6(a2),d3
	or.w	d3,d0
	and.w	d3,d1
	move.l	(a2),12(a1)
	move.l	4(a2),16(a1)
	add.w	8(a2),d2
	move.l	#$7fff7fff,20(a1)
	move.w	DUNGEON_PT_SIZE+6(a2),d3
	or.w	d3,d0
	and.w	d3,d1
	bne.s	trivial_reject\@
	move.l	DUNGEON_PT_SIZE(a2),24(a1)
	move.l	DUNGEON_PT_SIZE+4(a2),28(a1)
	move.l	#$00007fff,32(a1)
; now, d2=ltab
	sub.l	a2,a2
	lsr.w	#1,d2
	beq.s	trivial_reject\@
	cmp.w	#$2f00,d2
	bhs.s	got_ltab\@
	clr.b	d2
	move.l	#lightingtab,a2
	add.w	d2,a2
got_ltab\@:
	move.l	a2,current_ltab(a6)
	lea	12*4(a1),a1
	movem.l	d4-d7,-(a7)
	bsr	DrawClippedPolygon
	movem.l	(a7)+,d4-d7
trivial_reject\@:
	endm



do_3dblock::
; passed (a3)=&block
; adr(x,z)=((z*gridsize)+x)*16
; first, do upper face
	movem.w	(a3),d4/d5/d6/d7	; minx,minx,maxx,maxz
; now, check if can see upper face
; if 1024*(b.maxz)+DUNGEON_MINZ <PlayerZ, then visible
	move.l	d7,d0
	lsl.l	#8,d0
	lsl.l	#2,d0
	add.l	#DUNGEON_MINZ,d0
	cmp.l	PlayerZ(a6),d0
	bge	no_topface
; for clockwise face, do minx,+y,maxz minx,-y,maxz maxx,-y,maxz maxx,+y,maxz
	move.l	#KingTut,current_tmap(a6)
	DO_FACE	d4,d7,d6,d7
no_topface:
; now, do left face
; if playerx < (1024*(b.minx)) then visible
	move.l	d4,d0
	lsl.l	#8,d0
	lsl.l	#2,d0
	add.l	#DUNGEON_MINX,d0
	cmp.l	PlayerX(a6),d0
	ble	no_leftface
	move.l	#Fish,current_tmap(a6)
	DO_FACE	d4,d5,d4,d7
no_leftface:
; now, do right face
; if playerx > (1024*max+minx) then visible
	move.l	d6,d0
	lsl.l	#8,d0
	lsl.l	#2,d0
	add.l	#DUNGEON_MINX,d0
	cmp.l	PlayerX(a6),d0
	bge	no_rightface
	move.l	#Wolves,current_tmap(a6)
	DO_FACE	d6,d7,d6,d5

no_rightface:
; now, do lower face
; if playerZ < minz then visible
	move.l	d5,d0
	lsl.l	#8,d0
	lsl.l	#2,d0
	add.l	#DUNGEON_MINZ,d0
	cmp.l	PlayerZ(a6),d0
	ble	no_botface
	move.l	#Mandrill,current_tmap(a6)
	DO_FACE	d6,d5,d4,d5
no_botface:
	rts


add_objects::
; lame "distance" sort
	lea	ObjectList,a0
	move.l	PlayerX(a6),d2
	move.l	PlayerZ(a6),d3
	lea	sortlist(a6),a1
next_object::
	tst.l	(a0)+		; terminator?
	beq.s	done_adding
do_add:	move.l	(a0)+,d0	; x
	move.l	(a0)+,d1	; z
	sub.l	d2,d0
	bpl.s	1$
	neg.l	d0
1$:	sub.l	d3,d1
	bpl.s	2$
	neg.l	d1
2$:	cmp.l	d0,d1
	bhs.s	3$
	exg.l	d0,d1
3$:	add.l	d1,d1
	add.l	d1,d0		; d0=distance approximation
	cmp.l	4(a0),d0
	bhs.s	no_add_to_sorted_list
	move.l	d0,(a0)		; save distance
	move.l	a0,(a1)+
no_add_to_sorted_list:
	lea	12(a0),a0	; skip to next object
	tst.l	(a0)+
	bne.s	do_add
done_adding:
; now, sort list from a0 to a1
; only a tiny number of objects, so use bubble sort
	lea	-4(a1),a2
outer:	lea	sortlist(a6),a0
	cmp.l	a0,a2
	ble.s	done_outer
resort:	cmp.l	a0,a2
	beq.s	done_inner
	move.l	(a0)+,a3
	move.l	(a0),a4
	move.l	(a3),d0
	cmp.l	(a4),d0
	bhs.s	resort
	move.l	a4,-4(a0)
	move.l	a3,(a0)
	bra.s	resort
done_inner:
	lea	-4(a2),a2
	bra.s	outer
done_outer:

; now, drain sort list
	lea	sortlist(a6),a0
nextobject:
	cmp.l	a0,a1		; at end?
	beq.s	done_plotting_objects
	move.l	(a0)+,a3
	move.l	-12(a3),a4	; get handler pointer
	move.l	8(a3),a3	; get data pointer
	movem.l	a0/a1,-(a7)
	jsr	(a4)
	movem.l	(a7)+,a0/a1
	bra.s	nextobject
done_plotting_objects:
	rts

	section	__MERGED,data
m11::	dc.w	$7fff
m21::	dc.w	0
m31::	dc.w	0
m12::	dc.w	0
m22::	dc.w	-$73ff
m32::	dc.w	0
m13::	dc.w	0
m23::	dc.w	0
m33::	dc.w	$7fff

rand_seed::	dc.w	1

sortlist::
	ds.l	20

tmap_selector::
	dc.w	0

temp_polygon_buffer::
	ds.w	6*18

	section	DungeonArray,DATA
defblock	macro	x,z,sym
;		\1\2 \3
	dc.l	do_3dblock
	dc.l	-8192+512+(\1*1024)
	dc.l	-8192+512+(\2*1024)
	dc.l	0
	dc.l	8192+4096
	dc.l	\3
	endm

; dc.w x,y,z,codes,x,y,z,codes [0,0]
; dc.w x,y,z,codes,x,y,z,codes [1,0]
DungeonPoints::
	ds.w	DUNGEON_GRID_SIZE*DUNGEON_GRID_SIZE*DUNGEON_PT_SIZE

ObjectList::

	defblock	1,1,block_b1
	defblock	2,2,block_b2
	defblock	1,3,block_b3
	defblock	12,1,block_b4
	defblock	7,4,block_b5
	defblock	4,5,block_b6
	defblock	12,7,block_b7
	defblock	2,10,block_b8
	defblock	2,13,block_b9
	defblock	6,11,block_b10
	defblock	11,13,block_b11
	dc.l	0			; terminator

block_b1:	dc.w	1,1,1+1,1+1
block_b2:	dc.w	2,2,2+1,2+1
block_b3:	dc.w	1,3,1+1,3+1
block_b4:	dc.w	12,1,12+1,1+1
block_b5:	dc.w	7,4,7+1,4+1
block_b6:	dc.w	4,5,4+1,5+1
block_b7:	dc.w	12,7,12+1,7+1
block_b8:	dc.w	2,10,2+1,10+1
block_b9:	dc.w	2,13,2+1,13+1
block_b10:	dc.w	6,11,6+1,11+1
block_b11:	dc.w	11,13,11+1,13+1


	section	IntensityTable,DATA
intenstable::
	include	'intens.i'
