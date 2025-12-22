
    opt c+
    opt	ALINK
;
; Date: 2014-20-08		Vic Ferry (krabob/mkd)
;
; adapted from kalms "c2p that writes to BitMap structs".
; done for a Gif-To-BitMap struct converter's last pass, 
;(which itself was done to test for os3's BltBitMap functions 
; testing with SA_interleaved mode, for the history...)
; this one:
; 1. -writes 16bit (.w) instead of 32(.l) for other c2ps...
; 2. -is compatible with bitmap structs with 1,2,3,4,5,6,7 or 8 bitplanes. (not just 8 or 6)
;
; This is not meant to be the fastest, this is meant to be compatible with all standard os
; BitMap struct, which width alignment are 16 and not 32 (could have been 32 on aga because of the blitter but it's not the case).
; it should be running quite ok on a 68000.
; c2p1x1_8_16b_68k_bm.s
; phxass c2p1x1_8_16b_68k_bm.s I=include: M=68000

	xdef	_c2p1x1_8_16b_68k_bm
	xdef	c2p1x1_8_16b_68k_bm
	xdef	_FindMask
	xdef	FindMask
	incdir	include:
	include	graphics/gfx.i

	XREF	_debugv

	section	code,code	 
	; aligned here ?
masks:
	dc.l	$0f0f0f0f,$00ff00ff,$55555555,$cccc3333
	
;  d0.w	chunkyx [chunky-pixels]
; d1.w	chunkyy [chunky-pixels]
;d2 fwidth ext
; a0	chunkyscreen
; a1	BitMap

_c2p1x1_8_16b_68k_bm
c2p1x1_8_16b_68k_bm
	movem.l	d2-d7/a2-a6,-(sp)

		; A few sanity checks
 ;lsr.w	#1,d1 ;test
	move.w	d0,d4
	andi.w	#$0f,d4			; Even 16-pixel width?
	bne	.exit
	move.l	d2,d7 ; keep it
	move.w	d0,d2
	ext.l	d0
	moveq	#0,d4
	
	lsr.l	#3,d0	; /8->real bytes per row
	move.w	bm_BytesPerRow(a1),d4 ; to jump to next row actually.
	move.l	d4,d3
	sub.l	d0,d4	; 0 if no interleave.
;test	sub.l	d7,d4	; if ext+1 column mode

	mulu.w	d1,d2 ; d2 total chunky size
	
	move.b	bm_Depth(a1),d1
	cmp.b	#8,d1
	bgt		.exit	
	ext.w	d1	;depth
	subq	#1,d1 ; 0/7
; - - - - - - - - - -- - -  - - - -
	movem.l	d0/d2/a0/a1,-(sp)	; keep start for 5-8 planes
	movem.l	d3/d4/d7,-(sp)	;d3 full bytes per row , d4-1realrow   d7: bool ==1 if +16 ext.
			
	;  replaced by movem.l
	;	move.l	#$0f0f0f0f,d4		; Merge 4x1, part 1
	;	move.l	#$00ff00ff,d5
	;	move.l	#$55555555,d6
	;	move.l	#$cccc3333,d7 ;swap 2
	movem.l masks(pc),d4-d7
	; jump to routine according to number of planes (less tests)
	;test moveq	#2,d1
	lsl.w	#2,d1	; 68000 ? 	
	
	lea	depthTable,a3
	move.l	(a3,d1.w),a3
	jsr	(a3)	; no free *4 on 68000 :(

; - - - - - - -	end of first 4 planes
	lea		12(sp),sp
	movem.l	(sp)+,d0/d2/a0/a1	;a0 chunk start, a1 bm
	
	move.b	bm_Depth(a1),d1
	sub.b	#5,d1
	blt		.exit	; no more work
	ext.w	d1
	lsl.w	#2,d1	; 68000 ? 	
	;clr.w	d1 ;test
	; - - - - - - -got to c2p 1,2,3  or 4 "high planes"
	; --- just get stack back
	lea		-28(sp),sp

	;move.l	#$f0f0f0f0,d4	
	not.l	d4
	lea	depthTableH,a3
	move.l	(a3,d1.w),a3
	jsr	(a3)	; no free *4 on 68000 
	;bsr depth4h
	lea		28(sp),sp

.exit
	movem.l	(sp)+,d2-d7/a2-a6
	rts	
; =  = = = == = = = == = = = = = = = = = =

depthTable
	dc.l	depth1,depth2,depth3,depth4,depth4,depth4,depth4,depth4
depthTableH
	dc.l	depth1h,depth2h,depth3h,depth4h
	
depth1
	move.l	bm_Planes(a1),a3	; Setup ptrs to bpl0-3
;	movem.l	bm_Planes(a1),a3-a6	; Setup ptrs to bpl0-3
	move.l	a3,a2	
	add.l	d0,a2	;a2 end of first line

	; reuse a1: end of chunk
	move.l	a0,a1
	add.l	d2,a1
.nstarty1

.nstartx1
	movem.l	(a0)+,d0-d3	;read 16 pixels, Convert lower 4 bpls
; - - - -- - - -- - - -- - -  -swap 4

	and.l	d4,d0
	and.l	d4,d1	
	and.l	d4,d2
	and.l	d4,d3
	lsl.l	#4,d0
	lsl.l	#4,d2
	or.l	d1,d0
	or.l	d3,d2
	; d0:ae bf cg dh 	d2:im jn ko lp
	; - -  - - - - - - swap 8 .l 
	move.l	d0,d1
	move.l	d2,d3
	and.l	d5,d0 ; d0: __bf__dh 
	and.l	d5,d2 ; d2: __jn__lp
	eor.l	d0,d1 ; d1: ae__cg__
	eor.l	d2,d3 ; d3: im__ko__
	lsl.l	#8,d0 ; d0: bf__dh__
	lsr.l	#8,d3 ; d3: __im__ko
	
	or.l	d0,d2 ; d2: bfjn dhlp
	or.l	d3,d1 ; d1: aeim cgko 
	; - - - swap x1, still in .l
	; rename to just a,b,c,d
	; d1 ab
	; d2 cd
	and.l	d6,d2 ; _d
	and.l	d6,d1 ; _b
	add.l	d1,d1 ; <<1
	or.l	d1,d2 
	; - -  - - special 16b  swap x2  
	; swap d2 with itself,d0 with itself.
	move.l	d2,d1 ; abcdefgh
	and.l	d7,d1 ; a_c__f_h
	eor.l	d1,d2 ; _b_de_g_
	swap	d2
	lsl.w	#2,d2
	or.w	d2,d1 ; abcd...op2  abcd...op0  
	; - - - - - - -
	move.w	d1,(a3)+	;bpl0
	;clr.w	(a4)+
	;clr.w	(a5)+
	;clr.w	(a6)+
	
	; - - - - - - -- - - end of low4

	;a2 end of first bm line:
	cmpa.l	a3,a2
	bne	.nstartx1
	tst.w	14(sp)
	beq	.noext16
		clr.w (a3)	; do not '+'
.noext16
	; next line:
	; movem.l	d3-d4,-(sp)	;d3 full bytes per row , d4-realrow
	add.l	4(sp),a2
	move.l	8(sp),d0
	add.l	d0,a3
	;add.l	d0,a4
	;add.l	d0,a5	
	;add.l	d0,a6	
	
	
	cmpa.l	a0,a1
	bne	.nstarty1
	rts
depth2
	movem.l	bm_Planes(a1),a3-a4	; Setup ptrs to bpl0-3
	move.l	a3,a2	
	add.l	d0,a2	;a2 end of first line

;14b,7w	   move.w  d0,_debugv+6

	; reuse a1: end of chunk
	move.l	a0,a1
	add.l	d2,a1
.nstarty

.nstartx
	movem.l	(a0)+,d0-d3	;read 16 pixels, Convert lower 4 bpls
; - - - -- - - -- - - -- - -  -swap 4

	and.l	d4,d0
	and.l	d4,d1	
	and.l	d4,d2
	and.l	d4,d3
	lsl.l	#4,d0
	lsl.l	#4,d2
	or.l	d1,d0
	or.l	d3,d2
	; d0:ae bf cg dh 	d2:im jn ko lp
	; - -  - - - - - - swap 8 .l 
	move.l	d0,d1
	move.l	d2,d3
	and.l	d5,d0 ; d0: __bf__dh 
	and.l	d5,d2 ; d2: __jn__lp
	eor.l	d0,d1 ; d1: ae__cg__
	eor.l	d2,d3 ; d3: im__ko__
	lsl.l	#8,d0 ; d0: bf__dh__
	lsr.l	#8,d3 ; d3: __im__ko
	
	or.l	d0,d2 ; d2: bfjn dhlp
	or.l	d3,d1 ; d1: aeim cgko 
	; - - - swap x1, still in .l
	; rename to just a,b,c,d
	; d1 ab
	; d2 cd
	move.l	d2,d0 ;cd
	move.l	d1,d3 ;ab
	and.l	d6,d2 ; _d
	and.l	d6,d1 ; _b
	eor.l	d2,d0 ; c_
	eor.l	d1,d3 ; a_
	add.l	d1,d1 ; lsl #1
	lsr.l	#1,d0 ; _c
	or.l	d1,d2 ; bd    -> 2,0 abab efef ijij mnmn cdcd ghgh klkl opop
	or.l	d3,d0 ; ac    -> 3,1 abab efef ijij mnmn cdcd ghgh klkl opop
	; - -  - - special 16b  swap x2  
	; swap d2 with itself,d0 with itself.
	move.l	d2,d1 ; abcdefgh
	move.l	d0,d3
	
	and.l	d7,d1 ; a_c__f_h
	and.l	d7,d3
	
	eor.l	d1,d2 ; _b_de_g_
	eor.l	d3,d0
	swap	d2
	swap	d0
	lsl.w	#2,d2
	lsl.w	#2,d0

	or.w	d2,d1 ; abcd...op2  abcd...op0  
	; - - - - - - -
	move.w	d1,(a3)+	;bpl0
	or.w	d0,d3 ; abcd...op3  abcd...op1  
	move.w	d3,(a4)+	;bpl1
	; - - - - - - -- - - 

	;a2 end of first bm line:
	cmpa.l	a3,a2
	bne	.nstartx
	
	tst.w	14(sp)
	beq	.noext16
		clr.w (a3)	; do not '+'
		clr.w (a4)
.noext16
	; next line:
	; movem.l	d3-d4,-(sp)	;d3 full bytes per row , d4-realrow
;;	  move.l  4(sp),_debugv+4
	add.l	4(sp),a2
	move.l	8(sp),d0
	add.l	d0,a3
	add.l	d0,a4
	
	cmpa.l	a0,a1
	bne	.nstarty
	rts
depth3
	movem.l	bm_Planes(a1),a3-a5	; Setup ptrs to bpl0-3
	move.l	a3,a2	
	add.l	d0,a2	;a2 end of first line

	; reuse a1: end of chunk
	move.l	a0,a1
	add.l	d2,a1
.nstarty

.nstartx
	movem.l	(a0)+,d0-d3	;read 16 pixels, Convert lower 4 bpls
; - - - -- - - -- - - -- - -  -swap 4

	and.l	d4,d0
	and.l	d4,d1	
	and.l	d4,d2
	and.l	d4,d3
	lsl.l	#4,d0
	lsl.l	#4,d2
	or.l	d1,d0
	or.l	d3,d2
	; d0:ae bf cg dh 	d2:im jn ko lp
	; - -  - - - - - - swap 8 .l 
	move.l	d0,d1
	move.l	d2,d3
	and.l	d5,d0 ; d0: __bf__dh 
	and.l	d5,d2 ; d2: __jn__lp
	eor.l	d0,d1 ; d1: ae__cg__
	eor.l	d2,d3 ; d3: im__ko__
	lsl.l	#8,d0 ; d0: bf__dh__
	lsr.l	#8,d3 ; d3: __im__ko
	
	or.l	d0,d2 ; d2: bfjn dhlp
	or.l	d3,d1 ; d1: aeim cgko 
	; - - - swap x1, still in .l
	; rename to just a,b,c,d
	; d1 ab
	; d2 cd
	move.l	d2,d0 ;cd
	move.l	d1,d3 ;ab
	and.l	d6,d2 ; _d
	and.l	d6,d1 ; _b
	eor.l	d2,d0 ; c_
	eor.l	d1,d3 ; a_
	add.l	d1,d1 ; lsl #1
	lsr.l	#1,d0 ; _c
	or.l	d1,d2 ; bd    -> 2,0 abab efef ijij mnmn cdcd ghgh klkl opop
	or.l	d3,d0 ; ac    -> 3,1 abab efef ijij mnmn cdcd ghgh klkl opop
	; - -  - - special 16b  swap x2  
	; swap d2 with itself,d0 with itself.
	move.l	d2,d1 ; abcdefgh
	move.l	d0,d3
	
	and.l	d7,d1 ; a_c__f_h
	and.l	d7,d3
	
	eor.l	d1,d2 ; _b_de_g_
	eor.l	d3,d0

	lsr.w	#2,d2
	;lsr.w	#2,d0
	swap	d2
	swap	d0
	lsl.w	#2,d2
	lsl.w	#2,d0

	or.l	d2,d1 ; abcd...op2  abcd...op0  
	; - - - - - - -
	move.w	d1,(a3)+	;bpl0
	
	or.w	d0,d3 ; abcd...op3  abcd...op1  
	swap	d1
	move.w	d1,(a5)+	;bpl2
	
	move.w	d3,(a4)+	;bpl1
	;swap	d3
	;move.w	d3,(a6)+	;bpl3
	;clr.w	(a6)+
	; - - - - - - -- - - end of low4

	;a2 end of first bm line:
	cmpa.l	a3,a2
	bne	.nstartx
	tst.w	14(sp)
	beq	.noext16
		clr.w (a3)	; do not '+'
		clr.w (a4)
		clr.w (a5)
.noext16	

	; next line:
	; movem.l	d3-d4,-(sp)	;d3 full bytes per row , d4-realrow
	add.l	4(sp),a2
	move.l	8(sp),d0
	add.l	d0,a3
	add.l	d0,a4
	add.l	d0,a5	
	
	cmpa.l	a0,a1
	bne	.nstarty
	rts

depth4
	movem.l	bm_Planes(a1),a3-a6	; Setup ptrs to bpl0-3
	move.l	a3,a2	
	add.l	d0,a2	;a2 end of first line

	; reuse a1: end of chunk
	move.l	a0,a1
	add.l	d2,a1
.nstarty

.nstartx
	movem.l	(a0)+,d0-d3	;read 16 pixels, Convert lower 4 bpls
; - - - -- - - -- - - -- - -  -swap 4

	and.l	d4,d0
	and.l	d4,d1	
	and.l	d4,d2
	and.l	d4,d3
	lsl.l	#4,d0
	lsl.l	#4,d2
	or.l	d1,d0
	or.l	d3,d2
	; d0:ae bf cg dh 	d2:im jn ko lp
	; - -  - - - - - - swap 8 .l 
	move.l	d0,d1
	move.l	d2,d3
	and.l	d5,d0 ; d0: __bf__dh 
	and.l	d5,d2 ; d2: __jn__lp
	eor.l	d0,d1 ; d1: ae__cg__
	eor.l	d2,d3 ; d3: im__ko__
	lsl.l	#8,d0 ; d0: bf__dh__
	lsr.l	#8,d3 ; d3: __im__ko
	
	or.l	d0,d2 ; d2: bfjn dhlp
	or.l	d3,d1 ; d1: aeim cgko 
	; - - - swap x1, still in .l
	; rename to just a,b,c,d
	; d1 ab
	; d2 cd
	move.l	d2,d0 ;cd
	move.l	d1,d3 ;ab
	and.l	d6,d2 ; _d
	and.l	d6,d1 ; _b
	eor.l	d2,d0 ; c_
	eor.l	d1,d3 ; a_
	add.l	d1,d1 ; lsl #1
	lsr.l	#1,d0 ; _c
	or.l	d1,d2 ; bd    -> 2,0 abab efef ijij mnmn cdcd ghgh klkl opop
	or.l	d3,d0 ; ac    -> 3,1 abab efef ijij mnmn cdcd ghgh klkl opop
	; - -  - - special 16b  swap x2  
	; swap d2 with itself,d0 with itself.
	move.l	d2,d1 ; abcdefgh
	move.l	d0,d3
	
	and.l	d7,d1 ; a_c__f_h
	and.l	d7,d3
	
	eor.l	d1,d2 ; _b_de_g_
	eor.l	d3,d0

	lsr.w	#2,d2
	lsr.w	#2,d0
	swap	d2
	swap	d0
	lsl.w	#2,d2
	lsl.w	#2,d0

	or.l	d2,d1 ; abcd...op2  abcd...op0  
	; - - - - - - -
	move.w	d1,(a3)+	;bpl0
	
	or.l	d0,d3 ; abcd...op3  abcd...op1  
	swap	d1
	move.w	d1,(a5)+	;bpl2
	
	move.w	d3,(a4)+	;bpl1
	swap	d3
	move.w	d3,(a6)+	;bpl3
	; - - - - - - -- - - end of low4

	;a2 end of first bm line:
	cmpa.l	a3,a2
	bne	.nstartx

	tst.w	14(sp)
	beq	.noext16
		;move.w #-1,(a3)	; do not '+'
		;move.w #-1,(a4)
		;move.w #-1,(a5)
		;move.w #-1,(a6)	
		clr.w (a3)	; do not '+'
		clr.w (a4)
		clr.w (a5)
		clr.w (a6)
.noext16

	; next line:
	; movem.l	d3-d4,-(sp)	;d3 full bytes per row , d4-realrow
	add.l	4(sp),a2
	move.l	8(sp),d0
	add.l	d0,a3
	add.l	d0,a4
	add.l	d0,a5	
	add.l	d0,a6
	
	cmpa.l	a0,a1
	bne	.nstarty
	rts
	; second pass for 32 colors (last plane 5)
depth1h
	move.l	bm_Planes+16(a1),a3	; Setup ptrs to bpl4
	move.l	a3,a2	
	add.l	d0,a2	;a2 end of first line

	; reuse a1: end of chunk
	move.l	a0,a1
	add.l	d2,a1
.nstartyh

.nstartxh
	movem.l	(a0)+,d0-d3	;read 16 pixels, Convert lower 4 bpls
; - - - -- - - -- - - -- - -  -swap 4
	and.l	d4,d0
	and.l	d4,d1	
	and.l	d4,d2
	and.l	d4,d3
	lsr.l	#4,d1
	lsr.l	#4,d3
	or.l	d1,d0
	or.l	d3,d2
	; d0:ae bf cg dh 	d2:im jn ko lp
	; - -  - - - - - - swap 8 .l 
	move.l	d0,d1
	move.l	d2,d3
	and.l	d5,d0 ; d0: __bf__dh 
	and.l	d5,d2 ; d2: __jn__lp
	eor.l	d0,d1 ; d1: ae__cg__
	eor.l	d2,d3 ; d3: im__ko__
	lsl.l	#8,d0 ; d0: bf__dh__
	lsr.l	#8,d3 ; d3: __im__ko
	
	or.l	d0,d2 ; d2: bfjn dhlp
	or.l	d3,d1 ; d1: aeim cgko 
	; - - - swap x1, still in .l
	; rename to just a,b,c,d
	; d1 ab
	; d2 cd
	and.l	d6,d2 ; _d
	and.l	d6,d1 ; _b
	add.l	d1,d1 ; lsl #1
	or.l	d1,d2 ; bd    -> 2,0 abab efef ijij mnmn cdcd ghgh klkl opop
	; - -  - - special 16b  swap x2  
	; swap d2 with itself,d0 with itself.
	move.l	d2,d1 ; abcdefgh
	and.l	d7,d1 ; a_c__f_h
	eor.l	d1,d2 ; _b_de_g_
	swap	d2
	lsl.w	#2,d2
	or.w	d2,d1 ; abcd...op2  abcd...op0  
	; - - - - - - -
	move.w	d1,(a3)+	;bpl0
	; - - - - - - -- - - end of low4

	;a2 end of first bm line:
	cmpa.l	a3,a2
	bne	.nstartxh
	
	tst.w	14(sp)
	beq	.noext16
		clr.w (a3)	; do not '+'
.noext16

	; next line:
	; movem.l	d3-d4,-(sp)	;d3 full bytes per row , d4-realrow
	add.l	4(sp),a2
	move.l	8(sp),d0
	add.l	d0,a3
	
	
	cmpa.l	a0,a1
	bne	.nstartyh
	rts	
	; second pass for 64 colors (plane 5/6)
depth2h
	movem.l	bm_Planes+16(a1),a3-a4	; Setup ptrs to bpl4-5
	move.l	a3,a2	
	add.l	d0,a2	;a2 end of first line

	; reuse a1: end of chunk
	move.l	a0,a1
	add.l	d2,a1
.nstartyh

.nstartxh
	movem.l	(a0)+,d0-d3	;read 16 pixels, Convert lower 4 bpls
; - - - -- - - -- - - -- - -  -swap 4
	and.l	d4,d0
	and.l	d4,d1	
	and.l	d4,d2
	and.l	d4,d3
	lsr.l	#4,d1
	lsr.l	#4,d3
	or.l	d1,d0
	or.l	d3,d2
	; d0:ae bf cg dh 	d2:im jn ko lp
	; - -  - - - - - - swap 8 .l 
	move.l	d0,d1
	move.l	d2,d3
	and.l	d5,d0 ; d0: __bf__dh 
	and.l	d5,d2 ; d2: __jn__lp
	eor.l	d0,d1 ; d1: ae__cg__
	eor.l	d2,d3 ; d3: im__ko__
	lsl.l	#8,d0 ; d0: bf__dh__
	lsr.l	#8,d3 ; d3: __im__ko
	
	or.l	d0,d2 ; d2: bfjn dhlp
	or.l	d3,d1 ; d1: aeim cgko 
	; - - - swap x1, still in .l
	; rename to just a,b,c,d
	; d1 ab
	; d2 cd
	move.l	d2,d0 ;cd
	move.l	d1,d3 ;ab
	and.l	d6,d2 ; _d
	and.l	d6,d1 ; _b
	eor.l	d2,d0 ; c_
	eor.l	d1,d3 ; a_
	add.l	d1,d1 ; lsl #1
	lsr.l	#1,d0 ; _c
	or.l	d1,d2 ; bd    -> 2,0 abab efef ijij mnmn cdcd ghgh klkl opop
	or.l	d3,d0 ; ac    -> 3,1 abab efef ijij mnmn cdcd ghgh klkl opop
	; - -  - - special 16b  swap x2  
	; swap d2 with itself,d0 with itself.
	move.l	d2,d1 ; abcdefgh
	move.l	d0,d3
	
	and.l	d7,d1 ; a_c__f_h
	and.l	d7,d3
	
	eor.l	d1,d2 ; _b_de_g_
	eor.l	d3,d0

	;lsr.w	#2,d2
	;lsr.w	#2,d0
	swap	d2
	swap	d0
	lsl.w	#2,d2
	
	or.w	d2,d1 ; abcd...op2  abcd...op0  
	; - - - - - - -
	move.w	d1,(a3)+	;bpl0
	lsl.w	#2,d0
	or.w	d0,d3 ; abcd...op3  abcd...op1  
	;swap	d1
	;move.w	d1,(a5)+	;bpl2	
	move.w	d3,(a4)+	;bpl1
	;swap	d3
	;move.w	d3,(a6)+	;bpl3
	; - - - - - - -- - - end of low4

	;a2 end of first bm line:
	cmpa.l	a3,a2
	bne	.nstartxh

	tst.w	14(sp)
	beq	.noext16
		clr.w (a3)	; do not '+'
		clr.w (a4)
.noext16

	; next line:
	; movem.l	d3-d4,-(sp)	;d3 full bytes per row , d4-realrow
	add.l	4(sp),a2
	move.l	8(sp),d0
	add.l	d0,a3
	add.l	d0,a4

	cmpa.l	a0,a1
	bne	.nstartyh
	rts

	; second pass for 128 colors (plane 5/6/7)
depth3h
	movem.l	bm_Planes+16(a1),a3-a5	; Setup ptrs to bpl4-7
	move.l	a3,a2	
	add.l	d0,a2	;a2 end of first line

	; reuse a1: end of chunk
	move.l	a0,a1
	add.l	d2,a1
.nstartyh

.nstartxh
	movem.l	(a0)+,d0-d3	;read 16 pixels, Convert lower 4 bpls
; - - - -- - - -- - - -- - -  -swap 4
	and.l	d4,d0
	and.l	d4,d1	
	and.l	d4,d2
	and.l	d4,d3
	lsr.l	#4,d1
	lsr.l	#4,d3
	or.l	d1,d0
	or.l	d3,d2
	; d0:ae bf cg dh 	d2:im jn ko lp
	; - -  - - - - - - swap 8 .l 
	move.l	d0,d1
	move.l	d2,d3
	and.l	d5,d0 ; d0: __bf__dh 
	and.l	d5,d2 ; d2: __jn__lp
	eor.l	d0,d1 ; d1: ae__cg__
	eor.l	d2,d3 ; d3: im__ko__
	lsl.l	#8,d0 ; d0: bf__dh__
	lsr.l	#8,d3 ; d3: __im__ko
	
	or.l	d0,d2 ; d2: bfjn dhlp
	or.l	d3,d1 ; d1: aeim cgko 
	; - - - swap x1, still in .l
	; rename to just a,b,c,d
	; d1 ab
	; d2 cd
	move.l	d2,d0 ;cd
	move.l	d1,d3 ;ab
	and.l	d6,d2 ; _d
	and.l	d6,d1 ; _b
	eor.l	d2,d0 ; c_
	eor.l	d1,d3 ; a_
	add.l	d1,d1 ; lsl #1
	lsr.l	#1,d0 ; _c
	or.l	d1,d2 ; bd    -> 2,0 abab efef ijij mnmn cdcd ghgh klkl opop
	or.l	d3,d0 ; ac    -> 3,1 abab efef ijij mnmn cdcd ghgh klkl opop
	; - -  - - special 16b  swap x2  
	; swap d2 with itself,d0 with itself.
	move.l	d2,d1 ; abcdefgh
	move.l	d0,d3
	
	and.l	d7,d1 ; a_c__f_h
	and.l	d7,d3
	
	eor.l	d1,d2 ; _b_de_g_
	eor.l	d3,d0

	lsr.w	#2,d2
	;lsr.w	#2,d0
	swap	d2
	swap	d0
	lsl.w	#2,d2
	lsl.w	#2,d0

	or.l	d2,d1 ; abcd...op2  abcd...op0  
	; - - - - - - -
	move.w	d1,(a3)+	;bpl0

	or.w	d0,d3 ; abcd...op3  abcd...op1  
	swap	d1
	move.w	d1,(a5)+	;bpl2

	move.w	d3,(a4)+	;bpl1
	;swap	d3
	;move.w	d3,(a6)+	;bpl3
	; - - - - - - -- - - end of low4

	;a2 end of first bm line:
	cmpa.l	a3,a2
	bne	.nstartxh

	tst.w	14(sp)
	beq	.noext16
		clr.w (a3)	; do not '+'
		clr.w (a4)
		clr.w (a5)
.noext16

	; next line:
	; movem.l	d3-d4,-(sp)	;d3 full bytes per row , d4-realrow
	add.l	4(sp),a2
	move.l	8(sp),d0
	add.l	d0,a3
	add.l	d0,a4
	add.l	d0,a5	

	cmpa.l	a0,a1
	bne	.nstartyh
	rts
		; second pass for 256 colors (plane 5/6/7/8)
depth4h
	movem.l	bm_Planes+16(a1),a3-a6	; Setup ptrs to bpl4-8
	move.l	a3,a2	
	add.l	d0,a2	;a2 end of first line

	; reuse a1: end of chunk
	move.l	a0,a1
	add.l	d2,a1
.nstartyh

.nstartxh
	movem.l	(a0)+,d0-d3	;read 16 pixels, Convert lower 4 bpls
; - - - -- - - -- - - -- - -  -swap 4
	and.l	d4,d0
	and.l	d4,d1	
	and.l	d4,d2
	and.l	d4,d3
	lsr.l	#4,d1
	lsr.l	#4,d3
	or.l	d1,d0
	or.l	d3,d2
	; d0:ae bf cg dh 	d2:im jn ko lp
	; - -  - - - - - - swap 8 .l 
	move.l	d0,d1
	move.l	d2,d3
	and.l	d5,d0 ; d0: __bf__dh 
	and.l	d5,d2 ; d2: __jn__lp
	eor.l	d0,d1 ; d1: ae__cg__
	eor.l	d2,d3 ; d3: im__ko__
	lsl.l	#8,d0 ; d0: bf__dh__
	lsr.l	#8,d3 ; d3: __im__ko
	
	or.l	d0,d2 ; d2: bfjn dhlp
	or.l	d3,d1 ; d1: aeim cgko 
	; - - - swap x1, still in .l
	; rename to just a,b,c,d
	; d1 ab
	; d2 cd
	move.l	d2,d0 ;cd
	move.l	d1,d3 ;ab
	and.l	d6,d2 ; _d
	and.l	d6,d1 ; _b
	eor.l	d2,d0 ; c_
	eor.l	d1,d3 ; a_
	add.l	d1,d1 ; lsl #1
	lsr.l	#1,d0 ; _c
	or.l	d1,d2 ; bd    -> 2,0 abab efef ijij mnmn cdcd ghgh klkl opop
	or.l	d3,d0 ; ac    -> 3,1 abab efef ijij mnmn cdcd ghgh klkl opop
	; - -  - - special 16b  swap x2  
	; swap d2 with itself,d0 with itself.
	move.l	d2,d1 ; abcdefgh
	move.l	d0,d3
	
	and.l	d7,d1 ; a_c__f_h
	and.l	d7,d3
	
	eor.l	d1,d2 ; _b_de_g_
	eor.l	d3,d0

	lsr.w	#2,d2
	lsr.w	#2,d0
	swap	d2
	swap	d0
	lsl.w	#2,d2
	lsl.w	#2,d0

	or.l	d2,d1 ; abcd...op2  abcd...op0  
	; - - - - - - -
	move.w	d1,(a3)+	;bpl0
	or.l	d0,d3 ; abcd...op3  abcd...op1  
	swap	d1
	move.w	d1,(a5)+	;bpl2	
	move.w	d3,(a4)+	;bpl1
	swap	d3
	move.w	d3,(a6)+	;bpl3
	; - - - - - - -- - - end of low4

	;a2 end of first bm line:
	cmpa.l	a3,a2
	bne	.nstartxh

	tst.w	14(sp)
	beq	.noext16
		clr.w (a3)	; do not '+'
		clr.w (a4)
		clr.w (a5)
		clr.w (a6)
.noext16	

	; next line:
	; movem.l	d3-d4,-(sp)	;d3 full bytes per row , d4-realrow
	add.l	4(sp),a2
	move.l	8(sp),d0
	add.l	d0,a3
	add.l	d0,a4
	add.l	d0,a5	
	add.l	d0,a6
	
	cmpa.l	a0,a1
	bne	.nstartyh
	rts
;extern void __asm FindMask(
;	register __d0 int color,
;	register __d1 int pixelwidth,
;	register __d2 int rows, 	 
;	register __a0 char *chunk
;	register __a1 struct BitMap *mask
;  a3 == 2 if add column
;	);
FindMask
_FindMask	
	movem.l	d2-d7/a2-a6,-(sp)
	
	move.b	d0,d3
	lsl.w	#8,d3
	or.w	d0,d3
	move.w	d3,d0
	swap	d0
	move.w	d3,d0 ;clclclcl
	
	move.w	d2,d3
	mulu.w	d1,d3 ; d3 chunk size.l
	move.l	a0,a2
	add.l	d3,a2 ; a2 end of chunk.
	
	lsr.l	#3,d1 ; nb byte/line
	move.l	d1,d7	; d7 bytesperrow
	add.l	a3,d7
	
	clr.l	d6
	move.w	bm_BytesPerRow(a1),d6
	sub.w	d1,d6	; jump to next line, 0 if non-interlace
	sub.l	a3,d6
					
	lsr.w	#1,d1 ; nb word/line
	sub.w	#1,d1	;dbf
	
	move.l	bm_Planes(a1),a6
.lpy	
	move.w	d1,d3
.lpx
	;free: d2 d3
		clr.w	d2
		movem.l	(a0)+,d4-d5	;1234
		cmp.l	d0,d4	; 4bits transparent ?
		beq		.allt1
	
		cmp.b	d0,d4
		beq	.noq1
			moveq	#16,d2 ;1<<4 because 4 high bits
.noq1
		; - - - - - - -
		swap	d4	;3412
		cmp.b	d0,d4
		beq	.noq2
			or.b	#64,d2
.noq2		
		; - - - - - - -
		lsr.l	#8,d4	;_341
		cmp.b	d0,d4
		beq	.noq3
			or.b	#128,d2
.noq3	
		; - - - - - - -
		swap	d4	; 41_3
		cmp.b	d0,d4
		beq	.noq4
			or.b	#32,d2
.noq4
.allt1
	; - - - - - -  - - - - - - - - - -  - - -
		;move.l	(a0)+,d5	;5678
		cmp.l	d0,d5	; 4bits transparent ?
		beq		.allt2
	
		cmp.b	d0,d5
		beq	.noq5
			or.b	#1,d2 ;1<<1 because shifted 1 just after
.noq5
		; - - - - - - -
		swap	d5	;7856
		cmp.b	d0,d5
		beq	.noq6
			or.b	#4,d2
.noq6
		; - - - - - - -
		lsr.l	#8,d5	;_785
		cmp.b	d0,d5
		beq	.noq7
			or.b	#8,d2
.noq7
		; - - - - - - -
		swap	d5	; _7
		cmp.b	d0,d5
		beq	.noq8
			or.b	#2,d2
.noq8
.allt2
	lsl.w	#8,d2 ; ok for high
	; = = = = = = = = = = = = = = 8 low
		movem.l	(a0)+,d4-d5	;1234
		cmp.l	d0,d4	; 4bits transparent ?
		beq		.allt1b
	
		cmp.b	d0,d4
		beq	.noq1b
			or.b	#16,d2 ;1<<1 because shifted 1 just after
.noq1b
		; - - - - - - -
		swap	d4	;3412
		cmp.b	d0,d4
		beq	.noq2b
			or.b	#64,d2
.noq2b
		; - - - - - - -
		lsr.l	#8,d4	;_341
		cmp.b	d0,d4
		beq	.noq3b
			or.b	#128,d2
.noq3b
		; - - - - - - -
		swap	d4	; 41_3
		cmp.b	d0,d4
		beq	.noq4b
			or.b	#32,d2
.noq4b
.allt1b
	; - - - - - -  - - - - - - - - - -  - - -
		;move.l	(a0)+,d5	;5678
		cmp.l	d0,d5	; 4bits transparent ?
		beq		.allt2b
	
		cmp.b	d0,d5
		beq	.noq5b
			or.b	#1,d2 ;1<<1 because shifted 1 just after
.noq5b
		; - - - - - - -
		swap	d5	;7856
		cmp.b	d0,d5
		beq	.noq6b
			or.b	#4,d2
.noq6b
		; - - - - - - -
		lsr.l	#8,d5	;_785
		cmp.b	d0,d5
		beq	.noq7b
			or.b	#8,d2
.noq7b
		; - - - - - - -
		swap	d5	; _7
		cmp.b	d0,d5
		beq	.noq8b
			or.b	#2,d2
.noq8b
.allt2b
	;not.w	d2
		move.w	d2,(a6)+

	; - - - - - - - -
	dbf		d3,.lpx
	
; end of line, test
	move.w	d1,d3 ; for next .ldepthx
	; - -  - -
	cmpa.l	#0,a3
	beq		.noExtColumn
		clr.w	(a6)+ ; extra colmun mask
		;test move.w #%0011001100110011,(a6)+
		addq	#1,d3 ; in that case
.noExtColumn
	
	; - - - -  - - -- -  -end of x loop
	tst.l	d6	; interlace factor
	beq		.noInter
	
	move.l	a6,-(sp)
	
	move.b	bm_Depth(a1),d4
	ext.w	d4
	subq	#2,d4 ;-1 for df, -1 because plan1 done.
	;test move.w #1,d4
	; got to copy the line
	move.l	a6,a5
	sub.l	d7,a5
;----

.ldepthx
		lea	(a5,d7.l),a6
		move.w	(a5)+,d2
		move.w	d4,d5
.ldepth		
		move.w	d2,(a6)
		add.l	d7,a6
	dbf	d5,.ldepth
	dbf	d3,.ldepthx
	
	
	
	; to next line of first plane
	move.l	(sp)+,a6
	add.l	d6,a6		
.noInter	
	; loop y
	cmpa.l	a2,a0
	bne 	.lpy
	
	
	
	movem.l	(sp)+,d2-d7/a2-a6
	rts	
