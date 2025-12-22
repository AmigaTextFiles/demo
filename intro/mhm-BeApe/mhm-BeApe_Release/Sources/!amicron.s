;--------------------------------
; 
; AMICRON
; simple muzik generator for 4k
; v 0.4
;
; fast koded by
; fyrex^mayhem
; 19 aug 2k2
;
; WARNING: 020+
;---------------------------------
ECHO	equ	0
	
omicron
	move.w	#2048,d7

; for generation purposes
	ifne	0
	lea	xnotes(pc),a2
;bass
	moveq	#3,d3
	lea	mul3(pc),a3
;	jsr	solo
;solo	
	moveq	#4,d3
	lea	mul1(pc),a3
;	jsr	solo
;drum
	lea	drum_gen(pc),a3
;	jsr	beat
;hithat
	lea	hithat_gen(pc),a3
;	jsr	beat
;psy
	lea	xnotes5(pc),a2
	lea	psy_gen(pc),a3
	jmp	beat

xnotes
	dc.w	$8080
	dc.b	64,0 ; bass base freq
	dc.w	0
	dc.w	$8080
	dc.b	64,0 ; solo base freq
	dc.w	0
	dc.w	$4000
	dc.w	0
	dc.w	$4000
	dc.w	0
xnotes5
	dc.w	$4000
	dc.w	0
	
	endc
; end of generation stuff
	
	moveq	#2,d3
	lea	mul3(pc),a3
	bsr.s	solo

	lea	drum_gen(pc),a3
	bsr.s	beat

	lea	hithat_gen(pc),a3
	bsr.s	beat

	moveq	#3,d3
	lea	mul1(pc),a3
	bsr.s	solo

	lea	psy_gen(pc),a3
	bra.s	beat
	;
solo
	move.w	(a2)+,d4
	beq.s	xrts
	bsr.s	reset
	add.w	d4,d4
	bset	d5,d4
scont
	bcc.b	no_res
	bsr.b	reset
	move.b	(a2)+,d5
	lsl.w	d3,d5	
no_res
	move.l	d7,d2
.lop
	jsr	(a3)
	subq.w	#1,d2
	bftst	d2{28:4}
	bne.b	.lop
;	subq.w	#1,d5
	addq.l	#2,a1
	tst.w	d2
	bne.b	.lop

	add.w	d4,d4
	bne.s	scont

	IFNE	ECHO
	bsr.s	echo
	ENDC

	bra.s	solo
reset
	lea	2048(a4),a1
	moveq	#0,d5
xrts
	rts

beat
	move.w	(a2)+,d4
	beq.s	xrts
	add.w	d4,d4
	bset	d5,d4
gen0
	bcc.b	gen
	lea	4096(a4),a1
	move.l	d7,d2
	move.w	#1024,d5
ggg
	jsr	(a3)
	subq.w	#2,d2
	bne.b	ggg
	sub.w	d7,a0
gen
	add.w	d7,a0
	add.w	d4,d4
	bne.b	gen0
	IFNE	ECHO
	bsr.s	echo
	ENDC
	bra.s	beat

	IFNE	ECHO
echo
	lea	(-32768+1024)(a0),a1
.llo
	move.b	-1024(a1),d0
	asr.b	#3,d0
	bpl.s	.pos
	addq.b	#1,d0
.pos
	add.b	d0,(a1)+
	cmp.l	a0,a1
	bne.s	.llo
	rts
	ENDC
mul1
	move.w	(a1),d0
	move.w	d1,d6
	lsr.w	#5,d6
	add.w	d7,d6
	bra.b	mul0
mul3
	move.w	(a1),d0
	bra.b	mul0x
mul2
	add.w	#$4000,d0
mul0x
	move.w	d1,d6
	lsr.w	#4,d6
mul0
	muls.w	0(a4,d6.w*2),d0
	add.w	d5,d1
	rol.l	#8,d0
	rol.l	#2,d0
fini
	move.b	d0,(a0)+
	rts	

drum_gen
drum0	
	move.w	(a1),d0
	bsr.s	mul2
	move.w	(a1)+,d0
	bsr.s	mul2
	subq.w	#1,d5
	rts
	
hithat_gen
	bsr.s	hithat0
	move.b	d0,(a0)+
	bra.s	fini
psy_gen
	move.b	#0,(a0)+
	bsr.s	hithat0
	asr.b	#1,d0
	bra.s	fini
hithat0
	btst	#13,d3
	sne	d0
	eor.b	d0,d1
	add.b	d1,d1
	addx.w	d3,d3
	scs	d1
	
	move.w	(a1)+,d0
	add.w	#$4000,d0
	muls.w	d3,d0
	rol.l	#8,d0
	rts
; 
; last patch
;
;;	move.b	d0,(a0)+
;;	bra.s	fini


