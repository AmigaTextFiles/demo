;APS0000011F0000011F0000057E0000029F0000011F0000011F0000011F0000011F0000011F0000011F

;   "Tiny" - a 256-byte starfield intro by Dr. Doom / IRIS
;   coded 26/07/2001

		section	code,code_c
start		nop					; 256 bytes is too
		nop					; much, zeeball!
		nop
		nop
		nop
		nop
		move.l	4.w,a6
		moveq	#10240>>8,d0
		lsl.l	#8,d0
		moveq	#3,d1
		jsr	-198(a6)
		move.l	d0,a2
.loop		move.l	4(a6),a6
		move.l	10(a6),a0
		move.l	(a0)+,d0
		add.l	(a0)+,d0
		add.l	(a0),d0
		cmp.l	#"grap"+"hics"+".lib",d0
		bne.b	.loop
		lea	$dff000,a5
		move.l  $22(a6),d4
		sub.l	a1,a1
		jsr	-222(a6)
		lea	copper(pc),a0
		move.l	a0,$080(a5)
		moveq.l	#-79,d0
		lea	8192(a2),a0
		move.w	#128*3-1,d7
.initloop	ror.l	d0,d0
		addq.l	#7,d0
		move.w	d0,(a0)+
		dbra	d7,.initloop		
.mainloop	cmp.w	#$12f,5(a5)
		bne.b	.mainloop
		move.l	a2,$e0(a5)
		move.l	a2,a0
		move.w	#8192/4-1,d7
.clearloop	clr.l	(a0)+
		dbra	d7,.clearloop
		moveq	#128-1,d6
.loopstar	movem.w	(a0)+,d0-d2	
		subq.b	#7,-2(a0)
		bcs.b	.skipstar
		lsr.w	#7,d2
		divs.w	d2,d0
		divs.w	d2,d1
		add.w	#160,d0
		cmp.w	#320,d0
		bhs.b	.skipstar
		add.w	#100,d1
		cmp.w	#200,d1
		bhs.b	.skipstar
		muls.w	#40,d1
		moveq	#-$80,d2
		ror.b	d0,d2
		lsr.w	#3,d0
		add.w	d0,d1
		or.b	d2,(a2,d1.w)
.skipstar	dbra	d6,.loopstar
		btst.b	#2,$016(a5)
		bne.b	.mainloop
		move.l  d4,a1
		jsr	-222(a6)
		move.l	$26(a6),$080(a5)
		rts
copper		dc.w	$0100,$1200
		dc.w	$0180,$0424
		dc.w	$0182,$008f
		dc.w	$0096,$0020
		dc.l	-2

