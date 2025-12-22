
; m1=(  (cb*cc   )                  ) ASR 8
; m2=( ((sa*sb*cc) ASR 8) - (ca*sc) ) ASR 8
; m3=( ((ca*sb*cc) ASR 8) + (sa*sc) ) ASR 8
; m4=(  (cb*sc   )                  ) ASR 8
; m5=( ((sa*sb*sc) ASR 8) + (ca*cc) ) ASR 8
; m6=( ((ca*sb*sc) ASR 8) - (sa*cc) ) ASR 8
; m7=-sb
; m8=(sa*cb) ASR 8
; m9=(ca*cb) ASR 8

vector_makematrix
;	cosinus data are assumed to be in d0,d1 and d2.
;	sinus data are assumed to be in a0,a1 and a2.
;	sinus/cosinus amplitude is assumed to be 256.

ca	equr	d0
sa	equr	a0
cb	equr	d1
sb	equr	a1
cc	equr	d2
sc	equr	a2

	moveq.l	#0,d6
	lea	m1(pc),a6

	move.w	sb,d7
	muls.w	cc,d7
	asr.l	#8,d7
	addx.w	d6,d7

	move.w	cb,d3
	muls.w	cc,d3
	asr.l	#8,d3
	addx.w	d6,d3
	move.w	d3,(a6)+	; m1

	move.w	sa,d3
	muls.w	d7,d3
	move.w	sc,d4
	muls.w	ca,d4
	sub.l	d4,d3
	asr.l	#8,d3
	addx.w	d6,d3
	move.w	d3,(a6)+	; m2

	move.w	ca,d3
	muls.w	d7,d3
	move.w	sc,d4
	move.w	sa,d5
	muls.w	d5,d4
	add.l	d4,d3
	asr.l	#8,d3
	addx.w	d6,d3
	move.w	d3,(a6)+	; m3

	move.w	sb,d7
	move.w	sc,d3
	muls.w	d3,d7
	asr.l	#8,d7
	addx.w	d6,d7

	move.w	sc,d3
	muls.w	cb,d3
	asr.l	#8,d3
	addx.w	d6,d3
	move.w	d3,(a6)+	; m4

	move.w	sa,d3
	muls.w	d7,d3
	move.w	cc,d4
	muls.w	ca,d4
	add.l	d4,d3
	asr.l	#8,d3
	addx.w	d6,d3
	move.w	d3,(a6)+	; m5

	move.w	ca,d3
	muls.w	d7,d3

	move.w	sa,d4
	muls.w	cc,d4
	sub.l	d4,d3
	asr.l	#8,d3
	addx.w	d6,d3
	move.w	d3,(a6)+	; m6

	move.w	sb,d3
	neg.w	d3
	move.w	d3,(a6)+	; m7

	move.w	sa,d3
	muls.w	cb,d3
	asr.l	#8,d3
	addx.w	d6,d3
	move.w	d3,(a6)+	; m8

	muls.w	ca,cb
	asr.l	#8,cb
	addx.w	d6,d3
	move.w	cb,(a6)+	; m9
	rts

m1	dc.w	0
m2	dc.w	0
m3	dc.w	0
m4	dc.w	0
m5	dc.w	0
m6	dc.w	0
m7	dc.w	0
m8	dc.w	0
m9	dc.w	0
