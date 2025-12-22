; Razor 1911 demo loader by Kyzer/CSG

	include	whdload.i
	include	whdmacros.i

base	SLAVE_HEADER
	dc.w	7,WHDLF_Disk!WHDLF_NoError
	dc.l	$100000,0		; basemem, 0
	dc.w	start-base,0,0		; slave code, dir, dontcache
	dc.b	0,$59			; debugkey, quitkey

resload	dc.l	0
flush	dc.l	0
start	lea	resload(pc),a1
	move.l	a0,(a1)+
	adda.w	#resload_FlushCache,a0
	move.l	a0,(a1)

	lea	$400.w,a0
	move.l	a0,sp
	move.l	#$4e716002,(a0)+	;$400: NOP, load
	move.l	#$4e754ef9,(a0)+	;$402: load(a0=addr,d0=name)
	lea	loader(pc),a1		;$404: diskmotor off
	move.l	a1,(a0)

	lea	_custom+2,a6

	lea	$40000,a0
	move.l	#"boot",d0
	bsr	loader

	patch	$40666,.cont
	jmp	$40646
.cont	patch	$d9c.w,decr1		; use decrunchers in fastmem
	patch	$dfc.w,decr2
	patch	$e12.w,decr3

	lea	$778a.w,a0
	move.l	#"PIC1",d0
	bsr.s	loader
	lea	$7ffe.w,a0
	lea	$74da0,a1
	bsr	decr1

	move.l	#$40980,$6c.w
	move.l	#$40be6,cop1lc-2(a6)
	move.w	#0,copjmp1-2(a6)
	move.w	#$83c0,dmacon-2(a6)
	move.w	#$c028,intena-2(a6)	; add kbd int

	;move.w	#$4afc,$4082e
	jmp	$4071a

loader	movem.l	d0-d2/a0-a1,-(sp)
	lea	.dir-8(pc),a1
.file	addq.l	#8,a1
	move.l	(a1)+,d1
	beq.s	.done
	cmp.l	d0,d1
	bne.s	.file
	movem.l	(a1)+,d0/d1
	move.l	resload(pc),a1
	moveq	#1,d2
	move.w	#$4000,intena-2(a6)
	jsr	resload_DiskLoad(a1)	; a0=addr/d0=offset/d1=size/d2=1
	move.w	#$c000,intena-2(a6)
.done	movem.l	(sp)+,d0-d2/a0-a1
	rts

.dir	dc.l	'boot', 000000, 5632
	dc.l	'PIC1', 005632, 22336
	dc.l	'MUS1', 027968, 134740
	dc.l	'DAT1', 162708, 8796
	dc.l	'MAIN', 197632, 2560
	dc.l	'OPEN', 171504, 25836
	dc.l	'FLY ', 200192, 19840
	dc.l	'PIC2', 220032, 29660
	dc.l	'IMAG', 249692, 93788
	dc.l	'MOVI', 343480, 65664
	dc.l	'PARA', 409600, 36524
	dc.l	'BJOE', 446124, 2428
	dc.l	'MUS2', 448552, 176948
	dc.l	'HRRY', 625664, 59500
	dc.l	'BOX ', 685164, 22128
	dc.l	'RUN ', 707292, 4960
	dc.l	'BLUB', 712252, 25940
	dc.l	'REAL', 738192, 15188
	dc.l	'GO  ', 753380, 5964
	dc.l	0

decr1	move.l	flush(pc),-(sp)
	bra.s	decr
decr2	move.l	flush(pc),-(sp)
	bra.s	decr+$60
decr3	move.l	flush(pc),-(sp)
	bra.s	decr+$76
decr	incbin	decr.bin
