; Extension ©1993 Pygmy Projects
; loader by Kyzer/CSG

DEBUG=1
CHIPMEM	equ	$80000
FASTMEM	equ	$80000

	include	whdload.i
	include	whdmacros.i
	include	exec/memory.i
	include	lvo/exec_lib.i

base	SLAVE_HEADER
	dc.w	8,WHDLF_Disk!WHDLF_NoError
	dc.l	CHIPMEM,0		; basemem, 0
	dc.w	start-base,0,0		; slave code, dir, dontcache
	dc.b	0,$59			; debugkey, quitkey
expmem	dc.l	FASTMEM			; expansion memory (v8)

start	move.l	a0,a6

	; initialise memory system
	bsr	InitMem

	; initialise stack
STACK	equ	256		; I checked; uses at most 156 bytes of stack
	move.w	#0,sr		; user-mode
	move.l	#STACK,d0	; demo has stack problems between
	moveq	#MEMF_ANY,d1	; USP and SSP, so put USP in fastmem
	bsr	AllocMem	; and leave SSP in chipmem
	move.l	d0,sp
	adda.w	#STACK-4,sp

	; push exit routine onto stack
	pea	TDREASON_OK.w
	pea	resload_Abort(a6)

	; load music
	move.l	#$31a00,d0	; size
	moveq	#MEMF_CHIP,d1	; attributes
	move.l	#$79c00,d2	; offset
	bsr.s	.load
	move.l	d0,-(sp)

	;load demo
	move.l  #$71800,d0	; size
	moveq	#MEMF_ANY,d1	; requirements
	move.l  #$8200,d2	; offset
	bsr.s	.load
	move.l	d0,-(sp)

	; start music
	lea	_custom+dmacon,a4
	move.w	#$1c0,(a4)
	clr.w	$80.w
	move.l	4(sp),a0	; a0=music ptr
	jsr	(a0)
	move.w	#$8080,(a4)

	move.l	(sp)+,a0	; demo ptr
	move.l	(sp)+,a2	; music ptr

	lea	.msync(pc),a1	; a1 = sync marks with music
	add.l	#$1a510,a2	; a2 = something in the music
	jmp	(a0)		; start demo

.msync	dc.w	2,4,8,$12,$16,$18,$1C,$1F,$23,$27,$28,$31,$33,$3C

; d0 = length, d1 = attribs, d2 = offset
.load	move.l	d0,d3
	bsr.s	AllocMem
	move.l	d0,a2
	move.l	d0,a0
	move.l	d2,d0
	move.l	d3,d1
	moveq	#1,d2
	jsr	resload_DiskLoad(a6)	; a0=addr/d0=offset/d1=size/d2=1
	move.l	a2,a0
	suba.l	a1,a1
	jsr	resload_Relocate(a6)	; a0=addr/a1=0
	move.l	a2,d0
	rts

;------------------------------
; AllocMem/FreeMem for WHDLoad

InitMem	move.l	expmem(pc),a0		; fastmem
	lea	$400.w,a1
	move.l	a1,(a0)
	lea	MH_SIZE(a0),a2
	move.l	a2,MH_FIRST(a0)
	move.l	#FASTMEM-MH_SIZE,MH_FREE(a0)
	move.l	a1,4.w			; chipmem
	patch	_LVOAllocMem(a1),AllocMem
	patch	_LVOFreeMem(a1),FreeMem
	clr.l	(a1)
	lea	MH_SIZE(a1),a0
	move.l	a0,MH_FIRST(a1)
	move.l	#CHIPMEM-$400-MH_SIZE,MH_FREE(a1)
	rts

AllocMem
.retry	move.l	expmem(pc),a0
	btst.b	#MEMB_CHIP,d1
	beq.s	.fast
	move.l	(a0),a0
.fast	movem.l	d0/d1,-(sp)
	bsr.s	Allocate
	move.l	(sp)+,a0	; a0=size
	move.l	(sp)+,d1	; d1=type
	tst.l	d0
	bne.s	.cont
	btst.b	#MEMB_CHIP,d1	; ah. failure. was it chip?
	bne	OUTOFMEM	; yes? total failure
	bset.b	#MEMB_CHIP,d1	; otherwise, try again as chipmem
	move.l	a0,d0
	bra.s	.retry
.cont	btst	#MEMB_CLEAR,d1
	beq.s	.done
	move.l	a0,d1
	lsr.l	#2,d1		; reduce size to longwords
	move.l	d0,a0
.clr	clr.l	(a0)+
	subq.l	#1,d1
	bne.s	.clr
.done	rts


FreeMem	move.l	expmem(pc),a0
	cmpa.l	#CHIPMEM,a1
	bcc.s	.fast
	move.l	(a0),a0
.fast	bsr.s	Deallocate
.done	rts


; Allocate and Deallocate from 3.0 ROM (yes, I could write them myself..
; but deallocate would be bugged and it'd take longer to write)

Allocate
	cmp.l	($1C,a0),d0
	bhi.b	5$
	tst.l	d0
	beq.b	6$
	move.l	a2,-(sp)
	addq.l	#7,d0
	and.w	#-8,d0
	lea	($10,a0),a2
1$	movea.l	(a2),a1
	move.l	a1,d1
	beq.b	4$
	cmp.l	(4,a1),d0
	bls.b	2$
	movea.l	(a1),a2
	move.l	a2,d1
	beq.b	4$
	cmp.l	(4,a2),d0
	bhi.b	1$
	exg	a1,a2
2$	beq.b	3$
	move.l	a3,-(sp)
	lea	(a1,d0.l),a3
	move.l	a3,(a2)
	move.l	(a1),(a3)+
	move.l	(4,a1),d1
	sub.l	d0,d1
	move.l	d1,(a3)
	sub.l	d0,($1C,a0)
	movea.l	(sp)+,a3
	move.l	a1,d0
	movea.l	(sp)+,a2
	rts

3$	move.l	(a1),(a2)
	sub.l	d0,($1C,a0)
	movea.l	(sp)+,a2
	move.l	a1,d0
	rts

4$	movea.l	(sp)+,a2
5$	moveq	#0,d0
6$	rts

Deallocate
	tst.l	d0
	beq.b	9$
	movem.l	d3/a2,-(sp)
	move.l	a1,d1
	moveq	#-8,d3
	and.l	d3,d1
	exg	d1,a1
	sub.l	a1,d1
	add.l	d1,d0
	addq.l	#7,d0
	and.l	d3,d0
	beq.b	8$
	lea	($10,a0),a2
	move.l	(a2),d3
	beq.b	4$
1$	cmpa.l	d3,a1
	bls.b	2$
	movea.l	d3,a2
	move.l	(a2),d3
	bne.b	1$
	bra.b	3$

2$	beq.b	FREETWICE
3$	moveq	#$10,d1
	add.l	a0,d1
	cmp.l	a2,d1
	beq.b	4$
	move.l	(4,a2),d3
	add.l	a2,d3
	cmp.l	a1,d3
	beq.b	5$
	bhi.b	MEMCORRUPT
4$	move.l	(a2),(a1)
	move.l	a1,(a2)
	move.l	d0,(4,a1)
	bra.b	6$

5$	add.l	d0,(4,a2)
	movea.l	a2,a1
6$	tst.l	(a1)
	beq.b	7$
	move.l	(4,a1),d3
	add.l	a1,d3
	cmp.l	(a1),d3
	bhi.b	MEMCORRUPT
	bne.b	7$
	movea.l	(a1),a2
	move.l	(a2),(a1)
	move.l	(4,a2),d3
	add.l	d3,(4,a1)
7$	add.l	d0,($1C,a0)
8$	movem.l	(sp)+,d3/a2
9$	rts

OUTOFMEM
FREETWICE
MEMCORRUPT
	illegal
