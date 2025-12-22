
    opt c+
    opt    ALINK

	;include graphics/gfx.i
    include hardware/blit.i
	include demoData.i
	;include bob.i


    XREF    _debugv

CUSTOM      equ $dff000

bltddat     EQU   $000
dmaconr     EQU   $002
intenar     EQU   $01C
intreqr     EQU   $01E


bltcon0     EQU   $040
bltcon1     EQU   $042
bltafwm     EQU   $044
bltalwm     EQU   $046
bltcpt      EQU   $048
bltbpt      EQU   $04C
bltapt      EQU   $050
bltdpt      EQU   $054
bltsize     EQU   $058
bltcon0l    EQU   $05B      ; note: byte access only
bltsizv     EQU   $05C
bltsizh     EQU   $05E

bltcmod     EQU   $060
bltbmod     EQU   $062
bltamod     EQU   $064
bltdmod     EQU   $066

bltcdat     EQU   $070
bltbdat     EQU   $072
bltadat     EQU   $074


cop1lc      EQU   $080
cop2lc      EQU   $084
copjmp1     EQU   $088
copjmp2     EQU   $08A
copins      EQU   $08C
diwstrt     EQU   $08E
diwstop     EQU   $090
ddfstrt     EQU   $092
ddfstop     EQU   $094
dmacon      EQU   $096
clxcon      EQU   $098
intena      EQU   $09A
intreq      EQU   $09C
adkcon      EQU   $09E

* write definitions for dmaconw
DMAF_SETCLR    EQU   $8000
DMAF_AUDIO     EQU   $000F  * 4 bit mask
DMAF_AUD0      EQU   $0001
DMAF_AUD1      EQU   $0002
DMAF_AUD2      EQU   $0004
DMAF_AUD3      EQU   $0008
DMAF_DISK      EQU   $0010
DMAF_SPRITE    EQU   $0020
DMAF_BLITTER   EQU   $0040
DMAF_COPPER    EQU   $0080
DMAF_RASTER    EQU   $0100
DMAF_MASTER    EQU   $0200
DMAF_BLITHOG   EQU   $0400
; used
DMAF_ALL       EQU   $01FF  * all dma channels

* read definitions for dmaconr
* bits 0-8 correspnd to dmaconw definitions
DMAF_BLTDONE   EQU   $4000
DMAF_BLTNZERO  EQU   $2000

DMAB_SETCLR    EQU   15
DMAB_AUD0      EQU   0
DMAB_AUD1      EQU   1
DMAB_AUD2      EQU   2
DMAB_AUD3      EQU   3
DMAB_DISK      EQU   4
DMAB_SPRITE    EQU   5
DMAB_BLITTER   EQU   6
DMAB_COPPER    EQU   7
DMAB_RASTER    EQU   8
DMAB_MASTER    EQU   9
DMAB_BLITHOG   EQU   10
DMAB_BLTDONE   EQU   14
DMAB_BLTNZERO  EQU   13


	include blitGrid.i


    section code,code
	; this inits the constants for screen and each squares
	XDEF    _initBlitGrid
_initBlitGrid:

TAlloc	set smChip1_SIZEOF
TAlloc	set TAlloc+smChip2_SIZEOF
TAlloc	set TAlloc+smChip3_SIZEOF
TAlloc	set TAlloc+smFast_SIZEOF
	; exe size
TAlloc	set TAlloc+50000+32768
	move.l	#TAlloc,_debugv+12

	;a0 blg_
	;a1 bm_
	;d0.l dx byte start write
	;d1.w dy write start line
NBW=10
NBH=8
WORDWIDTH=2
BlitByteWidth=6
ScrHeight=256
SquareHeight=(ScrHeight/NBH)

	move.w	bm_BytesPerRow(a1),d7
	move.w	d7,blg_bpr(a0)
	move.w	d7,d2
	sub.w	#BlitByteWidth,d2
	move.w	d2,blg_bltadmod(a0)
	move.w	#(NBW*NBH)-1,blg_nbActivem1(a0)

	clr.w   blg_frame(a0)

	lea 	blg_Squares(a0),a2


	move.l	d0,a3
	mulu.w	d7,d1
	add.l	d1,a3
	; d3 const, write line jump
	move.w	#SquareHeight,d3
	mulu.w  d7,d3
;	 move.l	 d3,_debugv+4

	; just set bls_bltdpt which is constant for write
	move.w	#NBH-1,d0
.lpy
	move.l	a3,d4
	;start at end of line
	add.l	#40-BlitByteWidth,d4
	move.w	#NBW-1,d1
.lpx
		move.w	d4,d5 ; read shift
		add.w	#2,d5

		move.w	d5,bls_bltapt(a2) ; change, default
		move.w	d4,bls_bltdpt(a2) ; always

		; 3 words=6bytes
		move.w	#(SquareHeight<<6)|3,bls_bltsize(a2)

		;$01ff for fill  9f0 :copy a->d
		; shift in upper
		move.w  #$09f0|$f000,bls_bltcon0(a2)


		sub.w	#BlitByteWidth-2,d4
		lea	bls_SIZEOF(a2),a2
	dbf	d1,.lpx


	add.l	d3,a3
	dbf	d0,.lpy

	rts
;// - - - -
	; this set
	XDEF    _BlitGrid_setTornado
_BlitGrid_setTornado:
	;a0 blg_
	;d0 angle force
	;d1 zoom force

	move.w	blg_bpr(a0),d6

;d0
;d1
;d2
;d3 yrun
;d4 xrun
;d5 bltcon0 bits
;d6 bpr
;d7 loopy/loopx

;a0
;a1  ptr.w
;a2  square
;a3
;a4
;a5
;a6


	; has just to rewrite bltcon0 and bltapt for each squares

	lea blg_Squares(a0),a2

;	 move.w	 #256-16,d0

	move.w	#$09f0,d5 ; basic scheme for bltcon0


sqPixWidth=((BlitByteWidth-2)*8)
sqPixHeight=(ScrHeight/NBH)
	; just set bls_bltdpt which is constant for write
	move.w	#NBH-1,d7
	; -128+16
	move.w	#(sqPixHeight/2)-(ScrHeight/2),d3 ; center of square

;;;;	clr.w	d7 ;test
.lpy
	swap	d7

	move.w	#160-16,d4  ;144 -> -144 on line
	move.w	#NBW-1,d7
	; test
; move.w #0,d7
.lpx
		; read pointer "a" is shifted from write pointer "d"
		move.w  bls_bltdpt(a2),a1

		; - - - - - dy is: dx/(rot factor) + dy*zoom factor
		move.w	d3,d1
		muls.w	d0,d1
		asr.l	#8,d1	; source y line


		sub.w	d3,d1	;dy



		move.w	d4,d2
		neg.w	d2
		asr.w	#4,d2	;-9 -> +9

		add.w	d1,d2


		muls.w	d6,d2	; *bytesperrow		  
		add.w	d2,a1	;dy
		; - -  - - applied dx
		; zoom

		move.w	d4,d1
		muls.w	d0,d1
		asr.l	#8,d1
		sub.w	d4,d1


		move.w	d3,d2
		asr.w	#4,d2	;-7 -> +7
		add.w	d1,d2		 
        neg.w	d2
	ifd oldshit
		bge	.xpos
.xneg
			; neg...
			add.w	#2,a1
			;shift is: -1:15 ,-16:0
			;add.w	 #16,d2
		bra .xend
.xpos
		;>=0: d2 ok

		cmp.w	#16,d2 ; overflow
		blt	.noxpovf
			sub.w	#2,a1
.noxpovf
.xend
	endc

	move.w	d2,d1
	add.w	#128,d1	;manages as positive -64->63
	lsr.w	#4,d1	;/16
	sub.w	#128/16,d1
	add.w	d1,d1	;as bytes
	sub.w	d1,a1

	and.w	#$000f,d2

		ror.w	#4,d2
		or.w	d5,d2
 move.l	#131415,_debugv+8
;; move.w a1,_debugv+2
		move.w	a1,bls_bltapt(a2) ; change, default
		move.w  d2,bls_bltcon0(a2)

		lea	bls_SIZEOF(a2),a2
		sub.w	#sqPixWidth,d4

	dbf	d7,.lpx


	add.w	#sqPixHeight,d3

	swap	d7
	dbf	d7,.lpy



	rts
;// - - - -
	XDEF    _drawBlitGrid
_drawBlitGrid:
	;a0 blg_
	;a1 bm_ write
	;a3 bm_ read
	
	lea CUSTOM,a6
	moveq	#-1,d0
	move.l	d0,bltafwm(a6)	;bltafwm & bltalwm

	; - - - manage chaos
	lea		blg_frame(a0),a4
	move.w	(a4),d6
	addq	#1,d6
	move.w	d6,(a4)

;	 btst	 #0,d6
;	 bne	 .cc1
	; - - - zero
	; apply random
;	 move.l  blg_random(a0),d7
;	 mulu.l	 #$1307,d7
;	 add.l	 #$a545785,d7
;	 move.l	 d7,blg_random(a0)

;	 lsr.w	 #4,d7
;	 and.w	 #$2,d7
;	 move.w	 d7,d6	 ; x dec: 1 word or not
;	 move.w	 d6,blg_rndx(a0)
;	 swap	 d7
;	 and.w	 #$000f,d7 ;0->7
;	 sub.w	 #8,d7	 ;-4 -> 3
;	 move.w	 d7,blg_rndy(a0)

;	 bra .cc2
;.cc1
;	 ; odd frame: apply neg of previous even
;	 move.w  randomApX,d6
;	 move.w	 blg_rndy(a0),d7
;	 neg.w	 d6
;	 neg.w	 d7
;.cc2

	
	clr.w	bltcon1(a6) ; simple copy no need

	clr.w	d1
	move.b	bm_Depth(a1),d1
	subq	#1,d1
	move.l	sbm_PlaneSize(a1),d3

	move.w  blg_bltadmod(a0),d0
	move.w	d0,bltamod(a6)
	move.w	d0,bltdmod(a6)

	lea	blg_Squares(a0),a2	  
	
	move.w  blg_nbActivem1(a0),d0

   ; want no CPU when blitting
	move.w    #$8000|DMAF_BLITHOG,dmacon(a6)
;d0 square loop
;d1 nbplane const
;d2 plane loop
;d3 plane size
;d4 deltas
;d5 bltsize
;d6
;d7

;a0 blg_
;a1 bm_ -> then start plane write const
;a2 squares
;a3  start plane read const
;a4
;a5
;a6
	muls.w	bm_BytesPerRow(a3),d7
;no	   add.w   d6,d7

	move.l	bm_Planes(a1),a1 ;write
	move.l	bm_Planes(a3),a3 ;read

	;test
	move.w  #79,d0

.loops
	movem.l bls_bltapt(a2),d4/d5 ; apt/dpt size/con0
	; constant for all planes:

; or.w #$00ff,d5
	move.w	d5,bltcon0(a6) ; contains shift
	swap	d5	;is now bltsize
	; find plane adress.l + shit on screen .w
	lea	(a1,d4.w),a5	;dpt write
	swap	d4
	lea	(a3,d4.w),a4	;apt read

	move.w	d1,d2
;	 move.w	 #1,d2
.plloop
		movem.l	a4/a5,bltapt(a6) ; bltapt & bltdpt
		move.w	d5,bltsize(a6) ; set size and launch blit
		; - - blit here
		add.l	d3,a4
		add.l	d3,a5
.wait
		btst.b  #14-8,dmaconr(a6)
        bne.s   .wait

	dbf	d2,.plloop

	lea	bls_SIZEOF(a2),a2
	dbf	d0,.loops

	; switch off blit hog
	move.w    #DMAF_BLITHOG,dmacon(a6)


	rts
;	 STRUCTURE	 bltSquare,0
;		 WORD	 bls_bltapt	 ;source
;		 WORD	 bls_bltdpt	 ;dest
;		 WORD	 bls_bltsize
;		 WORD	 bls_bltcon0 ; contain shift
;	 LABEL	 bls_SIZEOF	 ;12

   
