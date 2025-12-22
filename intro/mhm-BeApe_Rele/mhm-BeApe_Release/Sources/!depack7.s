;--------------------------------------------------------------------
;
;  DFS DECOMPRESS v0.7
;
;  (w) 26.10.1997 by Tim BÖscke
;      31.10.1997 saved some extra bytes
;
; slight size&speed optimizations 
; by fyrex on 1 aug 2002
; !!! now size is 160 bytes !!!
;
; WARNING: 020+
;
;---------------------------------------------------------------------
;
; PAY ATTENTION what ziz maxcode is needed of a true value,
; which compressor returns !
D_MAXCODE	equ	286	; compare pliz with compressor return value !

;
; if ya code is less than it's needed, then change ziz value to 0 in order to raise da speed.
D_OPTIMIZE	equ	1	; 1 == size  /  0 == speed

decrunch:
	lea	source(pc),a0   ;a0 = source
	lea	mem,a1          ;a1 = stats
        
	move.l	a1,a4   
	move.l	#D_MAXCODE+1,d7	;d7 = range (later)
.lop1
	move.l	d7,(a4)+
	subq.w	#1,d7
	bpl.s	.lop1
     
	pea	(a4)	; move.l  a4,a3           ;codestart
	addq.l	#1,d7	;d7 = 0x10000 range
	move.w	(a0)+,d6	;d6 = code
	moveq	#0,d5	;d5 = bitcount
	bsr.s	.getsymbol
	move.w	#$100,a6
.nolz77
	move.b	d0,(a4)+
.bigloop
                          	; move    #$0100,d1
	bsr.s	.getsymbol
	sub.l	a6,d0	; cmp     d1,d0
	bmi.s	.nolz77
	beq.s	.ende
	move.w	d0,d1
	move.l	a4,a5	; move    d0,a5           ;len
	bsr.s	.getsymbol
	cmp.l	a6,d0
	bmi.s	.noove8 
	lsl.w	#8,d0
	sub.l	d0,a5
			; move    d0,d1
	bsr.s	.getsymbol      
.noove8
	sub.l	d0,a5
                           ; lsl.w   #8,d1   
                           ; move.b  d0,d1
                           ; neg.w   d1
                           ; lea     (a4,d1.w),a6
                           ; move.l  a5,d1
.lzloop
	move.b	(a5)+,(a4)+
	subq.w	#1,d1      ; dbf     d1,.lzloop
	bpl.b	.lzloop
	bra.s	.bigloop

.getsymbol
	move.l	(a1),d4         ;stat0
	move.w	d6,d3
	mulu.w	d4,d3
	add.l	d4,d3
	subq.l	#1,d3
	divu.l	d7,d3	;d3=count
	move.l	a1,a2
	moveq	#-1,d0  ;decoded symbol
.statlop2
	addq.l	#1,(a2)+
	addq.l	#1,d0
	cmp.l	(a2),d3
			;     bpl.s   .break
	bmi.s	.statlop2
.break
	move.l	(a2),d3
	mulu.l	d7,d3
	divu.l	d4,d3
	move.l	-(a2),d2
	subq.l	#1,d2
	mulu.l	d2,d7
	divu.l	d4,d7
	sub.w	d3,d6
	sub.l	d3,d7

          ;  while (range<=Half) {
          ;       range<<=1;
          ;       code<<=1;
          ;       code+=nextbit(in,bitindex++);
          ;   } //end bitin
        
.bitin

;
; average loop count == 7 (6 in rare case)
; (060 cycles)
;
	IFNE	D_OPTIMIZE

;;; new fast variant
	bfextu	(a0){d5:16},d3 ; p* (6)
.bitin0
	add.l	d7,d7	; p
	add.w	d3,d3	;  s

	addx.w	d6,d6	; p*

	addq.l	#1,d5	; p
	cmp.w	#$8001,d7	;  s
	bmi.s	.bitin0     
			;---- 6 + (3*6) = ~24 (~27 usually)
;;; original variant by azure
;	bfextu	(a0){d5:1},d3	;p* (6)
;	addq.l	#1,d5	; p
;	add.w	d6,d6	;  s
;	add.l	d7,d7	; p
;	or.w	d3,d6	;  s
;	cmp.w	#$8001,d7	; p.
;	bmi.s	.bitin
;                                   ;---- 9*6 = ~54 (~63 usually) !!!!!

	ELSE
	
;;; fastest variant, but file is enlarged by 4 bytes
	move.l	d7,d3	; p
	subq.w	#1,d3	;  s
	swap	d3	; p*
	bfffo	d3{1:15},d3	; p* (9)
	bfextu	(a0){d5:d3},d4	; p* (6)
	add.l	d3,d5	; p
	lsl.w	d3,d6	;  s
	lsl.l	d3,d7	; p
	or.l	d4,d6	;  s
			;---- ~19 - fantastically, but for 4 bytes ;) !
	ENDC
	rts
.ende   
	lea	chip,a5
	move.l	$4.w,a6
	jmp	-636(a6)	; clear cache

source
	incbin	"!main.pak"

	section	data,bss
mem:
	ds.b	3*1024*1024		; 3 megs


	section	datac,bss_c
chip:
	ds.b    512*1024		; 512k
