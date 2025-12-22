; $$TABS=8
;
; fakefb.asm - routines for manipulating the fake chunky pixel frame buffer
;

	include	'demo.i'			; master include file for this program.

	xref	_ChunkyToPlanar
	xref	canvas_bitmap,current_color,_LVOCopyMem,Moved

init_fakefb::
; build the y table for the fake frame buffer
; trashes d0-d4/a0-a2
	lea	yadrtable(a6),a0
	lea	fake_frame_buffer+4,a1
	move.w	#DUNGEON_WINDOW_HEIGHT-1,d0
1$:	move.l	a1,(a0)+
	lea	DUNGEON_WINDOW_WIDTH+8(a1),a1
	dbra	d0,1$
	lea	rightmasktable(a6),a0
	move.w	#DUNGEON_WINDOW_WIDTH-1,d0
	move.l	#$00ffffff,d1
2$:	move.l	d1,(a0)+
	bne.s	3$
	move.l	#$00ffffff,d1
	bra.s	4$
3$:	lsr.l	#8,d1
4$:	dbra	d0,2$
	lea	leftmasktable(a6),a0
	moveq	#0,d0
	move.l	#$ff000000,d1
	move.l	#$ffff0000,d2
	move.l	#$ffffff00,d3
	move.w	#(DUNGEON_WINDOW_WIDTH/4)-1,d4
5$:	movem.l	d0-d3,(a0)
	lea	4*4(a0),a0
	dbra	d4,5$
	rts

fill_fakefb::
; fill the whole fake frame buffer with a longword pattern.
; entr d0=pattern
; trashes: d0-d2/a0
	ONTIMER	4
	lea	fake_frame_buffer,a0
	move.l	#end_fake_fb,d1
	sub.l	a0,d1
	add.l	#7,d1
	lsr.l	#3,d1
2$:	move.l	d0,(a0)+
	move.l	d0,(a0)+
	dbra	d1,2$
	OFFTIMER	4
	rts

blur_fakefb:
	moveq	#0,d0
	move.l	#blend_table,a1
	lea	fake_frame_buffer+4,a0
	move.w	#DUNGEON_WINDOW_HEIGHT-1,d3
1$:	move.w	#(DUNGEON_WINDOW_WIDTH/4)-1,d4
2$:	move.w	(a0),d0
	move.b	(a1,d0.w),(a0)+
	move.w	(a0),d0
	move.b	(a1,d0.w),(a0)+
	move.w	(a0),d0
	move.b	(a1,d0.w),(a0)+
	move.w	(a0),d0
	move.b	(a1,d0.w),(a0)+

	dbra	d4,2$
	lea	8(a0),a0
	dbra	d3,1$
	rts

expand_fakefb:
	moveq	#0,d0
	move.l	#blend_table,a1
	move.l	#wide_fakefb,a2
	lea	fake_frame_buffer+4,a0
	move.w	#DUNGEON_WINDOW_HEIGHT-1,d3
1$:	move.w	#(DUNGEON_WINDOW_WIDTH/4)-1,d4
2$:	move.w	(a0),d0
	move.b	(a1,d0.w),d0
	swap	d0
	lea	1(a0),a0

	move.w	(a0),d0
	move.b	(a1,d0.w),d0
	move.l	d0,(a2)+
	lea	1(a0),a0

	move.w	(a0),d0
	move.b	(a1,d0.w),d0
	swap	d0
	lea	1(a0),a0

	move.w	(a0),d0
	move.b	(a1,d0.w),d0
	move.l	d0,(a2)+
	lea	1(a0),a0

	dbra	d4,2$
	lea	8(a0),a0
	dbra	d3,1$
	rts

fakefb_to_screen::
; transfer the fake frame buffer to the dungeon window
; entr: none
; trashes: a0/a1/d0/d1/d6/d7
	ifne	DOBLUR
	bsr	expand_fakefb
	lea	wide_fakefb,a0
	move.l	canvas_bitmap(a6),a1
	move.l	#DUNGEON_WINDOW_X,d0
	move.l	#DUNGEON_WINDOW_Y,d1
	move.l	#DUNGEON_WINDOW_WIDTH*2,d6
	move.l	#DUNGEON_WINDOW_HEIGHT,d7
	bra	_ChunkyToPlanar
	else
;	bsr	blur_fakefb
	ifne	MOTION_BLUR
	bsr	do_motion_blur
	lea	old_fake_fb+4,a0
	else
	lea	fake_frame_buffer+4,a0
	endc
	move.l	canvas_bitmap(a6),a1
	move.l	#DUNGEON_WINDOW_X,d0
	move.l	#DUNGEON_WINDOW_Y,d1
	move.l	#DUNGEON_WINDOW_WIDTH,d6
	move.l	#DUNGEON_WINDOW_HEIGHT,d7
	bsr	_ChunkyToPlanar
	rts
	endc

fill_fakefb_gradient::
; fill fake fb with a gradient
; entr d0=c, d1=dcdx, d2=dcdy
; trashes: d0-d5/a0
	replicate	d0,d3
	replicate	d1,d3
	replicate	d2,d3
	lea	fake_frame_buffer+4,a0
	move.w	#DUNGEON_WINDOW_HEIGHT-1,d3
1$:	move.w	#(DUNGEON_WINDOW_WIDTH/16)-1,d4
	move.l	d0,d5
2$:	move.l	d0,(a0)+
	add.l	d1,d0
	move.l	d0,(a0)+
	add.l	d1,d0
	move.l	d0,(a0)+
	add.l	d1,d0
	move.l	d0,(a0)+
	add.l	d1,d0
	dbra	d4,2$
	lea	8(a0),a0
	move.l	d5,d0
	add.l	d2,d0
	dbra	d3,1$
	rts

	

	ifne	MOTION_BLUR
do_motion_blur::
	move.l	#fake_frame_buffer,a0
	move.l	#old_fake_fb,a1
	move.w	#(DUNGEON_WINDOW_WIDTH+8)*(DUNGEON_WINDOW_HEIGHT)-1,d0
	move.l	#blend_table,a2
	moveq	#0,d1
1$:	move.b	(a1),d1
	lsl.w	#8,d1
	move.b	(a0)+,d1
	move.b	(a2,d1.l),(a1)+
	dbra	d0,1$
	rts
	endc




	section	__MERGED,DATA

render_mask::
	dc.l	0

	dc.l	end_fake_fb
yadrtable::
	ds.l	DUNGEON_WINDOW_HEIGHT
	dc.l	end_fake_fb

	dc.l	-1
rightmasktable::
	ds.l	DUNGEON_WINDOW_WIDTH
	dc.l	-1

	dc.l	-1
leftmasktable::
	ds.l	DUNGEON_WINDOW_WIDTH
	dc.l	-1
	

	section	lighttable,DATA
lightingtab::
	include	'lightingtable.i'

	section	 FakeFB,BSS
fake_frame_buffer::
	ds.b	(DUNGEON_WINDOW_WIDTH+8)*(DUNGEON_WINDOW_HEIGHT+1)
end_fake_fb::
	ds.b	(DUNGEON_WINDOW_WIDTH+12)*2
wide_fakefb::
	ds.b	DUNGEON_WINDOW_WIDTH*2*DUNGEON_WINDOW_HEIGHT

	ifne	MOTION_BLUR
old_fake_fb::
	ds.b	(DUNGEON_WINDOW_WIDTH+8)*(DUNGEON_WINDOW_HEIGHT)
	endc

	section	BigTable,DATA
blend_table::
	include	'64k.i'
