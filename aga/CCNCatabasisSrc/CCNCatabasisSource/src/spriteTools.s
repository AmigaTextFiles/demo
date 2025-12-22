
    opt c+
    opt    ALINK

    ;include graphics/graphics_lib.i
    ;include graphics/gfxbase.i


    include hardware/custom.i
    include    demodata.i

	XREF	_ntsc	;1b
    XREF    _debugv

	XREF	_InAlloc
	XREF	_InFree

	XREF    _readGifToBm
	XREF    _closeBm


    section code,code



	STRUCTURE	sSpriteManager,0
		APTR	spm_alloc	; unaligned chip alloc to be freed
		UWORD	spm_NbSprites ;1-8
		UWORD	spm_Rows	; sprite heights for all
		; - - - hardware like pointers to chip mem defs - -  -
		STRUCT	spm_ptrt,4*8

	LABEL	spm_SIZEOF


	; for double buffer version , modifiable:
	; must be used if y<0
	STRUCTURE	sSPriteDblManager,0
		APTR	dsp_ptrA	; to be activated
		APTR	dsp_ptrB	; current active
		WORD	dsp_x
		WORD	dsp_y
		; - - -
		APTR	dsp_alloc	; unaligned chip alloc to be freed
		UWORD	dsp_NbSprites ;1-8
		UWORD	dsp_Rows	; sprite heights for all
		; 2 games of sprite in chip
		STRUCT	dsp_ptrt1,4*8
		STRUCT	dsp_ptrt2,4*8
	LABEL	dsp_SIZEOF



;/// - - - - - -  - - _InitDblSprite64_15
	XDEF    _InitDblSprite64_15
_InitDblSprite64_15:
	; d0:max line height
	; d1: nb sprites
	; out: a0
	movem.l	d0/d1,-(sp)

	move.l	#dsp_SIZEOF,d0
	clr.l	d1
	bsr	_InAlloc
	tst.l	a0
	beq	.end
	movem.l	(sp),d0/d1

	move.w  d0,dsp_Rows(a0)
	move.w	d1,dsp_NbSprites(a0)
	move.l	a0,-(sp)
	; - - -
	lsl.w	#4,d0	; *16 2 64px lines
	add.w	#16+16,d0  ; size for vpos/hpos in *4 mode
					; + zero end lines
	move.w	d0,d7	; d7 size 1spr

	mulu.w	d1,d0	;.l
	lsl.l	#1,d0	;*2 again for dbl buffer

	addq   #8,d0    ; align *not 7*

	moveq	#1,d1	;chip
	bsr	_InAlloc

	move.l	(sp)+,a1
	tst.l	a0
	bne		.noerr
		move.l	a1,a0
		bsr	_InFree
		sub.l	a0,a0
		bra	.end
.noerr

	move.w	dsp_NbSprites(a1),d1
	sub.w	#1,d1
	move.w	d1,d6 ; for dbl buf

	move.l	a0,dsp_alloc(a1)
	lea		dsp_ptrt1(a1),a2
	move.l	a0,d0
	and.b	#$f8,d0 ;16b align
	ext.l	d7
.lp1
	move.l	d0,(a2)+
	add.l	d7,d0
	dbf	d1,.lp1

	lea		dsp_ptrt2(a1),a2
.lp2
	move.l	d0,(a2)+
	add.l	d7,d0
	dbf	d6,.lp2

	;-- set dbl buffer ptrs

	lea     dsp_ptrt1(a1),a2
	move.l	a2,dsp_ptrA(a1)
	lea     dsp_ptrt2(a1),a2
	move.l	a2,dsp_ptrB(a1)

	move.l	a1,a0
.end
	addq	#8,sp
	rts
;///

;/// - - - - - _CloseDblSprite
	XDEF	_CloseDblSprite
_CloseDblSprite
	;a0
	tst.l	a0
	beq		.end

	move.l	a0,a5
	move.l	dsp_alloc(a0),a0
	bsr	_InFree

	move.l	a5,a0
	bsr	_InFree
.end
	rts
;///
;/// - - - - - _bmToDblSprites64_15
	; translate a 4plane bitmap to 64px column attached sprite

	; d1.w source x byte offset (word aligned)
	; d2 line height
	; a0 sBitMap *
	; a2 *chip
	;
	XDEF    _bmToDblSprites64_15
_bmToDblSprites64_15
	
	move.l	(a2)+,a3  ; a3 chip of sprite0
	move.l	(a2),a2  ; a2 chip of sprite1

	; 2 first line must be inited later for position
	; got to clean 2 first lines
	clr.l	d3
	clr.l	d4
	clr.l	d5
	clr.l	d6
	movem.l	d3-d6,(a3)
	lea	16(a3),a3	; jump to bm
	movem.l	d3-d6,(a2)
	lea	16(a2),a2	; jump to bm

	lea	bm_Planes(a0),a4	; a4 table of source planes
	clr.l	d5
	move.w	bm_BytesPerRow(a0),d5

	; a3: 2 high planes
	; a2: 2 low planes

	move.l	(a4)+,a5	; source0
	move.l	(a4)+,a6	; source1
	lea		(a5,d1.w),a5	; horizontal displace
	lea		(a6,d1.w),a6

	subq	#1,d2

	move.l	d2,d0
.lp1
		; 2 first plane to sprite0
		movem.l	(a5),d3/d4
		movem.l	d3/d4,(a3)
		add.l	d5,a5
		lea	8(a3),a3
		movem.l	(a6),d3/d4
		movem.l	d3/d4,(a3)
		add.l	d5,a6
		lea	8(a3),a3
	dbf	d2,.lp1
	; - - end lines !
	clr.l	(a3)+
	clr.l	(a3)+
	clr.l	(a3)+
	clr.l	(a3)+


	; now write a2
	; -  - source
	move.l	(a4)+,a5	; source2
	move.l	(a4),a6	   ; source3
	lea		(a5,d1.w),a5	; horizontal displace
	lea		(a6,d1.w),a6
.lp2

		; 2 last plane to sprite1
		movem.l	(a5),d3/d4
		movem.l	d3/d4,(a2)
		add.l	d5,a5
		lea	8(a2),a2
		movem.l	(a6),d3/d4
		movem.l	d3/d4,(a2)
		add.l	d5,a6
		lea	8(a2),a2
	dbf	d0,.lp2
	; - - end lines !
	clr.l	(a2)+
	clr.l	(a2)+
	clr.l	(a2)+
	clr.l	(a2)+
	rts
;///
;/// - - - -  - - _bmToDblSprites64_15Full
	XDEF    _bmToDblSprites64_15Full
_bmToDblSprites64_15Full

	;a0 bm
	;a1 dsp_
	move.l	a0,-(sp)
	move.w	bm_BytesPerRow(a0),d1
	lsr.w	#3,d1 	;/64 nb double sprites
	move.w	d1,-(sp)

	lsl.w	#1,d1   ; nb real sprites

	move.w	bm_Rows(a0),d0
	bsr     _InitDblSprite64_15


	move.w	(sp)+,d7
	move.l	a0,a1	;dsp_
	move.l	(sp)+,a0


	subq   #1,d7	; loop by double sprites

	; - - - convert BM to sprites
	clr.l	d0 ;spr index
	clr.l	d1 ; byte offset
.lpbmTosp1

	move.w  bm_Rows(a0),d2

	; d0.w sprite index 0 or 2 or 4 or 6
	; d1.w source x byte offset (word aligned)
	; d2 line height
	; a0 sBitMap *
	; a2 spr chip ptr

	movem.l	 d0/d1/d7,-(sp)

		lea		dsp_ptrt1(a1,d0.w*4),a2
		bsr 	_bmToDblSprites64_15

		movem.l	 (sp),d0/d1
		move.w  bm_Rows(a0),d2
		lea		dsp_ptrt2(a1,d0.w*4),a2
		bsr 	_bmToDblSprites64_15

	movem.l	 (sp)+,d0/d1/d7

	;d7 ok

	addq	#2,d0
	addq	#8,d1
	dbf	d7,.lpbmTosp1

	; return a0 dsp_
	move.l	a1,a0
	rts
;///

;/// - - - - - _bmToDblSprites64_15
	; translate a 4plane bitmap to 64px column attached sprite

	; d1.w source x byte offset (word aligned)
	; d2 line height
	; a0 sBitMap *
	; a2 *chip
	;
	XDEF    _bmToDblSprites64_3
_bmToDblSprites64_3

	move.l	(a2)+,a3  ; a3 chip of sprite0
	move.l	(a2),a2  ; a2 chip of sprite1

	; 2 first line must be inited later for position
	; got to clean 2 first lines
	clr.l	d3
	clr.l	d4
	clr.l	d5
	clr.l	d6
	movem.l	d3-d6,(a3)
	lea	16(a3),a3	; jump to bm

	lea	bm_Planes(a0),a4	; a4 table of source planes
	clr.l	d5
	move.w	bm_BytesPerRow(a0),d5


	move.l	(a4)+,a5	; source0
	move.l	(a4)+,a6	; source1
	lea		(a5,d1.w),a5	; horizontal displace
	lea		(a6,d1.w),a6

	subq	#1,d2

	move.l	d2,d0
.lp1
		; 2 first plane to sprite0
		movem.l	(a5),d3/d4
		movem.l	d3/d4,(a3)
		add.l	d5,a5
		lea	8(a3),a3
		movem.l	(a6),d3/d4
		movem.l	d3/d4,(a3)
		add.l	d5,a6
		lea	8(a3),a3
	dbf	d2,.lp1
	; - - end lines !
	clr.l	(a3)+
	clr.l	(a3)+
	clr.l	(a3)+
	clr.l	(a3)+
   
	rts
;///

;/// - - - -  - - _bmToDblSprites64_3Full
	XDEF    _bmToDblSprites64_3Full
_bmToDblSprites64_3Full

	;a0 bm
	;a1 dsp_
	move.l	a0,-(sp)
	move.w	bm_BytesPerRow(a0),d1
	lsr.w	#3,d1 	;/64 nb sprites
	move.w	d1,-(sp)

	move.w	bm_Rows(a0),d0
	bsr     _InitDblSprite64_15 ; works the same

	move.w	(sp)+,d7  ; nb spr
	move.l	a0,a1	;dsp_
	move.l	(sp)+,a0    ; bm_

	subq   #1,d7	; loop by double sprites

	; - - - convert BM to sprites
	clr.l	d0 ;spr index
	clr.l	d1 ; byte offset
.lpbmTosp1

	move.w  bm_Rows(a0),d2

	; d0.w sprite index 0 or 2 or 4 or 6
	; d1.w source x byte offset (word aligned)
	; d2 line height
	; a0 sBitMap *
	; a2 spr chip ptr

	movem.l	 d0/d1/d7,-(sp)

		lea		dsp_ptrt1(a1,d0.w*4),a2
		bsr 	_bmToDblSprites64_3

		movem.l	 (sp),d0/d1
		move.w  bm_Rows(a0),d2
		lea		dsp_ptrt2(a1,d0.w*4),a2
		bsr 	_bmToDblSprites64_3

	movem.l	 (sp)+,d0/d1/d7

	;d7 ok

	addq	#1,d0
	addq	#8,d1
	dbf	d7,.lpbmTosp1

	; return a0 dsp_
	move.l	a1,a0
	rts
;///


	XDEF    _switchDblSprite
_switchDblSprite:
	;a0 dsp_

	movem.l  dsp_ptrA(a0),d0/d1
	move.l	d1,dsp_ptrA(a0)
	move.l	d0,dsp_ptrB(a0)

	rts

;///- - - - - _setDblSprite
	; link sprite to copper
	; a0 dsp_ * sprite manager
	; a1 copperdbl
	; d0.w x*4
	; d1.w y
	; d2 nb sprite  0,2,4,6
	XDEF	_setDblSprite
_setDblSprite:

	cmp.w	#-64*4,d0
	ble 	.nosp

	add.w  #$80*4,d0	; hard x coord


	; - - - common part
	move.l  dsp_ptrA(a0),a2
	lea	 	(a2,d2.w*4),a2
	move.l	(a2)+,a3  ;a3 ptr chip
	move.l	(a2),a4   ; get pointers now, can be slided before set in copper

	; - - undo last clipY hack if was used
	move.w	2(a3),d5
	tst.w	d5
	beq.b	.norepair
		clr.w	2(a3)

		; set bm back where it was
		lea		(a3,d5.w),a5
		move.w	4(a3),(a5)
		move.w	6(a3),8(a5)
		lea		(a4,d5.w),a5
		move.w	10(a3),(a5)
		move.w	12(a3),8(a5)
.norepair


;	 cmp.w	 #256,d1
;	 blt.b	 .toolow
;	 bra	 .nosp
;.toolow

	; - -  - manage Y clip by poking in bitmap
	; we can because of sprite dblbuffer
	tst.w	d1
	bge.b	.nolowy

	move.w	d1,d6
	neg.w	d6
	cmp.w	dsp_Rows(a0),d6
	blt	.doyclip
		; too far no sprite
		; - - declare no sprite on copper
.nosp
		move.l	cp_sprite(a1),a5
		lea		(a5,d2.w*8),a5
		clr.w  4(a5) ;low
		clr.w  (a5) ; high
		clr.w  4+8(a5) ;low
		clr.w  8(a5) ; high
		rts
.doyclip
	; keep line where we post ctrl at start
	move.w	d6,d5
	lsl.w	#4,d5	;*16
	move.w	d5,2(a3)	; free slot in ctrl 64b 1st spr

	; then backup bm place used for ctrl
	lea		(a3,d5.w),a5
	move.w	(a5),4(a3)
	move.w	8(a5),6(a3)

	lea		(a4,d5.w),a4
	move.w	(a4),10(a3)
	move.w	8(a4),12(a3)
	lea		(a3,d5.w),a3	;a3 a4 points new


	move.w	#44,d1	; start at top of screen
	move.w  dsp_Rows(a0),d5
	sub.w   d6,d5
	add.w	d1,d5
	move.w	d5,d6	;y2

	bra.b   .endclipy
.nolowy

    add.w	#44,d1
	move.w	d1,d6
	add.w	dsp_Rows(a0),d6

.endclipy
	;here
	;d1=y1 hardware coord
	;d6=y2 hardware coord

	move.l	cdb_CopA(a1),a1
	; compute vstop d6


	
	; - - -1. set sprite head
	;d0 x	; 11 bit
	;d1 y vstart
	;d6 y vstop
	;d4.w ctrl1
	;d5.w ctrl2
	clr.w	d4
	clr.w	d5
	; - - - x
	bfins	d0,d5{27:2}
	lsr.w	#2,d0
	bfins	d0,d5{31:1}
	lsr.w	#1,d0
	move.b	d0,d4


	; - - - vstart
	bfins	d1,d4{16:8}
		; can write d4 here
		move.w	d4,(a3)

	lsr.w	#8,d1
	bfins	d1,d5{29:1}

		; can write d4 again
		move.w	d4,(a4)

	; - - - vstop
	bfins	d6,d5{16:8}
	lsr.w	#8,d6
	bfins	d6,d5{30:1}

	; declare 2nd sprite as attached
	move.w	d5,8(a3)	;ctrl2 at line2
	bset    #7,d5
	move.w	d5,8(a4)

	; - - -2. points sprite in copper
	move.l	a3,d3
	move.l	cp_sprite(a1),a5

	lea		(a5,d2.w*8),a5
	move.w  d3,4(a5) ;low
	swap    d3
	move.w  d3,(a5) ; high

	move.l	a4,d3
	move.w	d3,4+(1*8)(a5) ;low
	swap	d3
	move.w	d3,(1*8)(a5) ; high


	rts
;///


;///- - - - - _setDblSprite3
	; link sprite to copper
	; a0 dsp_ * sprite manager
	; a1 copperdbl
	; d0.w x*4
	; d1.w y
	; d2 nb sprite  0,1,2,3,4
	XDEF	_setDblSprite3
_setDblSprite3:

	cmp.w	#-64*4,d0
	ble 	.nosp

	add.w  #$80*4,d0	; hard x coord

	move.w  dsp_Rows(a0),d3
	neg.w	d3
	cmp.w	d3,d1
	bgt		.nobefore
		move.w	#257,d1
.nobefore




	; - - - common part
	move.l  dsp_ptrA(a0),a2
	lea	 	(a2,d2.w*4),a2
	move.l	(a2)+,a3  ;a3 ptr chip

	; - - undo last clipY hack if was used
	move.w	2(a3),d5
	tst.w	d5
	beq.b	.norepair
		clr.w	2(a3)

		; set bm back where it was
		lea		(a3,d5.w),a5
		move.w	4(a3),(a5)
		move.w	6(a3),8(a5)
;		 lea	 (a4,d5.w),a5
;		 move.w	 10(a3),(a5)
;		 move.w	 12(a3),8(a5)
.norepair


;	 cmp.w	 #256,d1
;	 blt.b	 .toolow
;	 bra	 .nosp
;.toolow

	; - -  - manage Y clip by poking in bitmap
	; we can because of sprite dblbuffer
	tst.w	d1
	bge.b	.nolowy

	move.w	d1,d6
	neg.w	d6
	cmp.w	dsp_Rows(a0),d6
	blt	.doyclip
		; too far no sprite
		; - - declare no sprite on copper
.nosp
		move.l	cp_sprite(a1),a5
		lea		(a5,d2.w*8),a5
		clr.w  4(a5) ;low
		clr.w  (a5) ; high
		clr.w  4+8(a5) ;low
		clr.w  8(a5) ; high
		rts
.doyclip
	; keep line where we post ctrl at start
	move.w	d6,d5
	lsl.w	#4,d5	;*16
	move.w	d5,2(a3)	; free slot in ctrl 64b 1st spr

	; then backup bm place used for ctrl
	lea		(a3,d5.w),a5
	move.w	(a5),4(a3)
	move.w	8(a5),6(a3)

;	 lea	 (a4,d5.w),a4
;	 move.w	 (a4),10(a3)
;	 move.w	 8(a4),12(a3)

	lea		(a3,d5.w),a3	;a3 a4 points new


	move.w	#44,d1	; start at top of screen
	move.w  dsp_Rows(a0),d5
	sub.w   d6,d5
	add.w	d1,d5
	move.w	d5,d6	;y2

	bra.b   .endclipy
.nolowy

    add.w	#44,d1
	move.w	d1,d6
	add.w	dsp_Rows(a0),d6

.endclipy
	;here
	;d1=y1 hardware coord
	;d6=y2 hardware coord

	move.l	cdb_CopA(a1),a1
	; compute vstop d6



	; - - -1. set sprite head
	;d0 x	; 11 bit
	;d1 y vstart
	;d6 y vstop
	;d4.w ctrl1
	;d5.w ctrl2
	clr.w	d4
	clr.w	d5
	; - - - x
	bfins	d0,d5{27:2}
	lsr.w	#2,d0
	bfins	d0,d5{31:1}
	lsr.w	#1,d0
	move.b	d0,d4


	; - - - vstart
	bfins	d1,d4{16:8}
		; can write d4 here
		move.w	d4,(a3)

	lsr.w	#8,d1
	bfins	d1,d5{29:1}

		; can write d4 again
;		 move.w	 d4,(a4)

	; - - - vstop
	bfins	d6,d5{16:8}
	lsr.w	#8,d6
	bfins	d6,d5{30:1}

	; declare 2nd sprite as attached
	move.w	d5,8(a3)	;ctrl2 at line2
;	 bset    #7,d5
;	 move.w	 d5,8(a4)

	; - - -2. points sprite in copper
	move.l	a3,d3
	move.l	cp_sprite(a1),a5

	lea		(a5,d2.w*8),a5
	move.w  d3,4(a5) ;low
	swap    d3
	move.w  d3,(a5) ; high

;	 move.l	 a4,d3
;	 move.w	 d3,4+(1*8)(a5) ;low
;	 swap	 d3
;	 move.w	 d3,(1*8)(a5) ; high


	rts
;///

;/// - - - - _InitSprite64_4
;	 XDEF    _InitSprite64_4
;_InitSprite64_4:
	;d0 max line height
	;TODO?
	;out:a0
;	 rts
;///
;/// - - - - - -  - - _InitSprite64_15
	XDEF    _InitSprite64_15
_InitSprite64_15:
	; d0:max line height
	; d1: nb sprites
	; out: a0
	movem.l	d0/d1,-(sp)

	move.l	#spm_SIZEOF,d0
	clr.l	d1
	bsr	_InAlloc
	tst.l	a0
	beq	.end
	movem.l	(sp),d0/d1

	move.w  d0,spm_Rows(a0)
	move.w	d1,spm_NbSprites(a0)
	move.l	a0,-(sp)
	; - - -
	lsl.w	#4,d0	; *16 2 64px lines
	add.w	#16+16,d0  ; size for vpos/hpos in *4 mode
					; + zero end lines
	move.w	d0,d7	; d7 size 1spr

	mulu.w	d1,d0	;.l
	addq   #8,d0    ; align *not 7*

	moveq	#1,d1	;chip
	bsr	_InAlloc

	move.l	(sp)+,a1
	tst.l	a0
	bne		.noerr
		move.l	a1,a0
		bsr	_InFree
		sub.l	a0,a0
		bra	.end
.noerr

	move.w	spm_NbSprites(a1),d1
	sub.w	#1,d1

	move.l	a0,spm_alloc(a1)
	lea		spm_ptrt(a1),a2
	move.l	a0,d0
	and.b	#$f8,d0
	move.l	d0,a0

.lp
	move.l	a0,(a2)+
	lea	(a0,d7.w),a0
	dbf	d1,.lp
	move.l	a1,a0
.end
	addq	#8,sp
	rts
;///
;/// - - - - - closeSprite
	XDEF	_CloseSprite
_CloseSprite
	;a0
	tst.l	a0
	beq		.end

	move.l	a0,a5
	move.l	spm_alloc(a0),a0
	bsr	_InFree

	move.l	a5,a0
	bsr	_InFree
.end
	rts
;///
;/// - - - - - _copyBmToSprite64
	; translate a 4plane bitmap to 64px column attached sprite

	; d0.w sprite index 0 or 2 or 4 or 6
	; d1.w source x byte offset (word aligned)
	; d2 line height
	; a0 sBitMap *
	; a1 spm_ * sprite manager
	;
	XDEF    _copyBm4ToSprite64
_copyBm4ToSprite64:

	lea		spm_ptrt(a1,d0.w*4),a2
	move.l	(a2)+,a3  ; a3 chip of sprite0
	move.l	(a2),a2  ; a2 chip of sprite1

	; 2 first line must be inited later for position
	; got to clean 2 first lines
	clr.l	d3
	clr.l	d4
	clr.l	d5
	clr.l	d6
	movem.l	d3-d6,(a3)
	lea	16(a3),a3	; jump to bm
	movem.l	d3-d6,(a2)
	lea	16(a2),a2	; jump to bm

	lea	bm_Planes(a0),a4	; a4 table of source planes
	clr.l	d5
	move.w	bm_BytesPerRow(a0),d5

	; a3: 2 high planes
	; a2: 2 low planes

	move.l	(a4)+,a5	; source0
	move.l	(a4)+,a6	; source1
	lea		(a5,d1.w),a5	; horizontal displace
	lea		(a6,d1.w),a6


	subq	#1,d2
	move.l	d2,d0
.lp1
		; 2 first plane to sprite0
		movem.l	(a5),d3/d4
		movem.l	d3/d4,(a3)
		add.l	d5,a5
		lea	8(a3),a3
		movem.l	(a6),d3/d4
		movem.l	d3/d4,(a3)
		add.l	d5,a6
		lea	8(a3),a3
	dbf	d2,.lp1
	; - - end lines !
	clr.l	(a3)+
	clr.l	(a3)+
	clr.l	(a3)+
	clr.l	(a3)+


	; now write a2
	; -  - source
	move.l	(a4)+,a5	; source2
	move.l	(a4),a6	   ; source3
	lea		(a5,d1.w),a5	; horizontal displace
	lea		(a6,d1.w),a6
.lp2

		; 2 last plane to sprite1
		movem.l	(a5),d3/d4
		movem.l	d3/d4,(a2)
		add.l	d5,a5
		lea	8(a2),a2
		movem.l	(a6),d3/d4
		movem.l	d3/d4,(a2)
		add.l	d5,a6
		lea	8(a2),a2
	dbf	d0,.lp2
	; - - end lines !
	clr.l	(a2)+
	clr.l	(a2)+
	clr.l	(a2)+
	clr.l	(a2)+
	rts
;///

;/// - - - - - _copyBmToSprite_4
	; translate a 4plane bitmap to 64px column attached sprite

	; d0.w sprite index 0 or 2 or 4 or 6
	; d1.w source x byte offset (word aligned)
	; d2 line height
	; a0 sBitMap * 2 planes
	; a1 spm_ * sprite manager
	;
	XDEF    _copyBm4ToSprite_4
_copyBm4ToSprite_4:

	lea		spm_ptrt(a1,d0.w*4),a2
	move.l	(a2),a3  ; a3 chip of sprite0
	;move.l	 (a2),a2  ; a2 chip of sprite1

	; 2 first line must be inited later for position
	; got to clean 2 first lines
	clr.l	d3
	clr.l	d4
	clr.l	d5
	clr.l	d6
	movem.l	d3-d6,(a3)
	lea	16(a3),a3	; jump to bm
;	 movem.l d3-d6,(a2)
;	 lea 16(a2),a2	 ; jump to bm

	lea	bm_Planes(a0),a4	; a4 table of source planes
	clr.l	d5
	move.w	bm_BytesPerRow(a0),d5

	;OLD a3: 2 high planes
	; a2: 2 low planes

	move.l	(a4)+,a5	; source0
	move.l	(a4)+,a6	; source1
	lea		(a5,d1.w),a5	; horizontal displace
	lea		(a6,d1.w),a6


	subq	#1,d2
	move.l	d2,d0
.lp1
		; 2 first plane to sprite0
		movem.l	(a5),d3/d4
		movem.l	d3/d4,(a3)
		add.l	d5,a5
		lea	8(a3),a3
		movem.l	(a6),d3/d4
		movem.l	d3/d4,(a3)
		add.l	d5,a6
		lea	8(a3),a3
	dbf	d2,.lp1
	; - - end lines !
	clr.l	(a3)+
	clr.l	(a3)+
	clr.l	(a3)+
	clr.l	(a3)+

	rts
;///
;///- - - - - set sprite
	; link sprite to copper
	; a0 spm_ * sprite manager
	; a1 copperdbl
	; d0.w x*4
	; d1.w y
	; d2 sprite index 0,2,4,6
	XDEF	_setSprite
_setSprite:

	move.l	cdb_CopA(a1),a1
	; compute vstop d6
	move.w	d1,d6
	add.w	spm_Rows(a0),d6

	lea	 spm_ptrt(a0,d2.w*4),a2
	move.l	(a2)+,a3  ;a3 ptr chip
	move.l	(a2),a4
	; - - -1. set sprite head
	;d0 x	; 11 bit
	;d1 y vstart
	;d6 y vstop
	;d4.w ctrl1
	;d5.w ctrl2
	clr.w	d4
	clr.w	d5
	; - - - x
	bfins	d0,d5{27:2}
	lsr.w	#2,d0
	bfins	d0,d5{31:1}
	lsr.w	#1,d0
	;? bfins   d0,d4{24:8}
	move.b	d0,d4


	; - - - vstart
	bfins	d1,d4{16:8}
		; can write d4 here
		move.w	d4,(a3)

	lsr.w	#8,d1
	bfins	d1,d5{29:1}

		; test scrollx
		;;;;add.b	#8,d4

		; can write d4 again
		move.w	d4,(a4)

	; - - - vstop
	bfins	d6,d5{16:8}
	lsr.w	#8,d6
	bfins	d6,d5{30:1}

	; declare 2nd sprite as attached
;;	  bset	  #7,d5
	move.w	d5,8(a3)	;ctrl2 at line2
	bset    #7,d5
	move.w	d5,8(a4)

	; - - -2. points sprite in copper
	move.l	a3,d3
	move.l	cp_sprite(a1),a5

	lea		(a5,d2.w*8),a5
	move.w  d3,4(a5) ;low
	swap    d3
	move.w  d3,(a5) ; high

	move.l	a4,d3
	move.w	d3,4+(1*8)(a5) ;low
	swap	d3
	move.w	d3,(1*8)(a5) ; high


	rts
;///


;///- - - - - set sprite4
	; link sprite to copper
	; a0 spm_ * sprite manager
	; a1 copperdbl
	; d0.w x*4
	; d1.w y
	; d2 sprite index 0,1,2,3,4,...
	XDEF	_setSprite4
_setSprite4:

	move.l	cdb_CopA(a1),a1
	; compute vstop d6
	move.w	d1,d6
	add.w	spm_Rows(a0),d6

	lea	 spm_ptrt(a0,d2.w*4),a2
	move.l	(a2),a3  ;a3 ptr chip
	; - - -1. set sprite head
	;d0 x	; 11 bit
	;d1 y vstart
	;d6 y vstop
	;d4.w ctrl1
	;d5.w ctrl2
	clr.w	d4
	clr.w	d5
	; - - - x
	bfins	d0,d5{27:2}
	lsr.w	#2,d0
	bfins	d0,d5{31:1}
	lsr.w	#1,d0
	;? bfins   d0,d4{24:8}
	move.b	d0,d4


	; - - - vstart
	bfins	d1,d4{16:8}
		; can write d4 here
		move.w	d4,(a3)

	lsr.w	#8,d1
	bfins	d1,d5{29:1}

		; test scrollx
		;;;;add.b	#8,d4

	; - - - vstop
	bfins	d6,d5{16:8}
	lsr.w	#8,d6
	bfins	d6,d5{30:1}

	; declare 2nd sprite as attached
;;	  bset	  #7,d5
	move.w	d5,8(a3)	;ctrl2 at line2

	; - - -2. points sprite in copper
	move.l	a3,d3
	move.l	cp_sprite(a1),a5

	lea		(a5,d2.w*8),a5
	move.w  d3,4(a5) ;low
	swap    d3
	move.w  d3,(a5) ; high

	rts
;///


;/// - - - - - _initSpriteScreen
	XDEF    _initSpriteScreen
_initSpriteScreen:
	;a0 bm 320x256 4c
	; return a0: spm_

	; - - - alloc sprite manager and aligned bitmap chip mem
	move.l	a0,-(sp)


	move.w	bm_Rows(a0),d0 ; screen height
	move.w	#6,d1	;d1 nb sprites
	bsr	_InitSprite64_15
	tst.l	a0
	beq		.errbm
	
	move.l	a0,-(sp)
	move.l	4(sp),a1

	;a0 spm_
	;a1 original bitmap
	;a2 spr ptr reader
	;a3 sprite ptr
	;a4 bm1
	;a5 bm2

	move.w	bm_BytesPerRow(a1),d5
	move.l	bm_Planes+4(a1),a5
	move.l	bm_Planes(a1),a4

	lea spm_ptrt(a0),a2
	move.w	spm_Rows(a0),a6
	sub.w	#1,a6


	;d2 d3 original x,y

	; -  - loop per sprite
	move.w	#4,d7
.lpspr
	move.l	(a2)+,a3
	; jump control lines
	lea	16(a3),a3

	move.l	a4,a0
	move.l	a5,a1

	move.w	a6,d6
.bmh
		movem.l	(a0),d0/d1
		movem.l	d0/d1,(a3)
		lea	(a0,d5.w),a0
		lea	8(a3),a3

		movem.l	(a1),d0/d1
		movem.l	d0/d1,(a3)
		lea	(a1,d5.w),a1
		lea	8(a3),a3
	dbf	d6,.bmh
	addq	#8,a4
	addq	#8,a5	 
	dbf	d7,.lpspr

.endt
	; original bm not needed
	move.l	4(sp),a0
	bsr	_closeBm
	move.l	(sp)+,a0	; return sprite manager
	addq	#4,sp
	rts
.errbm
	addq	#4,sp
.err
	sub.l	a0,a0
	rts
;///
;/// - - - - _SetSpriteScreen
	XDEF    _SetSpriteScreen
_SetSpriteScreen:
	;a0 spm_
	;a1 copdbl
	;d0 x
	;d1 y
	;d2 loop
	lea spm_ptrt(a0),a2

	move.l	cdb_CopA(a1),a1
	move.l	cp_sprite(a1),a1

;a0 spm_
;a1 copper
;a2 spm_ ptrs
;a3 ptr
;a4 Height
;a5
;a6

	move.w  spm_Rows(a0),a4

	move.w	#4,d2	;5
.splp

	move.l	(a2)+,a3
	; - -  set sprite in copper
	move.l	a3,d3
	move.w	d3,4(a1)
	swap	d3
	move.w	d3,(a1)
	addq	#8,a1
	
	; - - set 2 ctrl words for size/position
	move.w  d0,d3
	move.w	d1,d4
	move.w	d1,d7
	add.w	a4,d7	; +height

	clr.w	d5
	; - - - x
	bfins	d3,d5{27:2}
	lsr.w	#2,d3
	bfins	d3,d5{31:1}
	lsr.w	#1,d3
	;stupid bfins	d3,d6{24:8}
	move.b	d3,d6

	; - - - vstart
	bfins	d4,d6{16:8}
	lsr.w	#8,d4
	bfins	d4,d5{29:1}
	; - - - vstop
	bfins	d7,d5{16:8}
	lsr.w	#8,d7
	bfins	d7,d5{30:1}

	move.w	d6,(a3)
	move.w	d5,8(a3)
;test	 move.l	 #-1,16+16(a3)
	; next
	add.w	#64*4,d0
	dbf	d2,.splp
	
	rts
;///


;/// - - - _SetSpritePalette4Dbl
	XDEF    _SetSpritePalette4Dbl
_SetSpritePalette4Dbl:
	;a0 4c pal ?
	;a1 copdbl
	; put color 1,2,3 to 32+ 1,2,3+5,6,7+...

	movem.l	a0/a1,-(sp)

	move.l	cdb_CopA(a1),a1
	bsr		_SetSpritePalette4
	; - - dbl copper
	movem.l	(sp)+,a0/a1

	move.l	cdb_CopB(a1),a1
	bsr		_SetSpritePalette4

	rts
_SetSpritePalette4:
	lea		cp_colorBanks+8(a1),a1
	; cpb_SIZEOF=8
	
;	 move.w    spa_ColorCount(a0),d1
;	 beq	 .noc
	lea        spa_Colors+3(a0),a3 ; jump color 1
	
    ; per 32c loop, high
	move.l	(a1)+,a2 ;a2 wr
	;49-63?

	move.w	#3,d2
.lpr1
	addq	#4,a2 ; start color1
    move.l	a3,a0
	move.w    #2,d3
.clhigh
    	clr.w    d4
		move.b    (a0)+,d4
    	lsl.w    #4,d4
		move.b    (a0)+,d4
		move.b    (a0)+,d5
    	; get high4 of each
    	and.b    #$f0,d4
    	lsr.b    #4,d5
    	or.b    d5,d4
		move.w   d4,(a2)
		addq	#4,a2
    dbf    d3,.clhigh

	dbf	d2,.lpr1

    ; switch to low bit banks
	move.l	(a1),a2 ;a2 wr

	move.w	#3,d2
.lpr2
	addq	#4,a2 ; start color1
	move.l	a3,a0
	move.w    #2,d3
.cllow
		move.b    (a0)+,d4
			and.b    #$0f,d4
			lsl.w    #8,d4

    	move.b    (a0)+,d4
    	move.b    (a0)+,d5
    	; get low4 of each
		lsl.b    #4,d4
    	and.b    #$0f,d5
		or.b    d5,d4
		move.w    d4,(a2)
		addq	#4,a2
	dbf    d3,.cllow

	dbf		d2,.lpr2
.noc


	rts
;///

;/// - -    PunchlinePaster
	XDEF    PunchlinePaster
PunchlinePaster:
	;a0 spm_
	;a1 bm_ orig.
	;d0 punchline index 0-7
	; it's all 2 planes !
	; rescramble a 224px with

	;	 APTR	 spm_alloc	 ; unaligned chip alloc to be freed
	;	 UWORD	 spm_NbSprites ;1-8
	;	 UWORD	 spm_Rows	 ; sprite heights for all
	;	 ; - - - hardware like pointers to chip mem defs - -  -
	;	 STRUCT	 spm_ptrt,4*8

	; get start of punchline bm
	movem.l	 bm_Planes(a1),a4/a5
	move.w	bm_BytesPerRow(a1),d1

	and.w	#$0007,d0
	lsl.w	#5,d0	;32 lines per
	mulu.w	d1,d0
	add.l	d0,a4
	add.l	d0,a5


	movem.l	a4/a5,-(sp)

	lea spm_ptrt(a0),a2

startline=196
lineh=30
	; - -  - first 16px
	move.l	(a2)+,a3 ;bm
	lea		16+(startline*16)+6(a3),a3

	move.w	#lineh-1,d0
.lpy1
		move.w	(a4),(a3)
		lea		(a4,d1.w),a4
		move.w	(a5),8(a3)
		lea		(a5,d1.w),a5
		lea		16(a3),a3
	dbf		d0,.lpy1
; - - - - - -
	movem.l	(sp)+,a4/a5
	addq	#2,a4
	addq	#2,a5
; - - - - - -
	moveq	#2,d7
.lpw
	movem.l	a4/a5,-(sp)

	move.l	(a2)+,a3 ;bm
	lea		16+(startline*16)(a3),a3

	move.w	#lineh-1,d0
.lpy2
		move.l	(a4),(a3)+
		move.l	4(a4),(a3)+
		move.l	(a5),(a3)+
		move.l	4(a5),(a3)+

		lea		(a4,d1.w),a4
		lea		(a5,d1.w),a5

	dbf		d0,.lpy2
	
	movem.l	(sp)+,a4/a5
	addq	#8,a4
	addq	#8,a5
	dbf		d7,.lpw
; - - -- last 16 pixels

	move.l	(a2)+,a3 ;bm
	lea		16+(startline*16)(a3),a3

	move.w	#lineh-1,d0
.lpy3
		move.w	(a4),(a3)
		move.w	(a5),8(a3)
		lea		16(a3),a3

		lea		(a4,d1.w),a4
		lea		(a5,d1.w),a5

	dbf		d0,.lpy3

	rts
;///
