
	opt c+   ;? case
    opt    ALINK

DOVALIDATE	equ	1

    include exec/execbase.i
    include exec/exec_lib.i
    include exec/memory.i

    include graphics/graphics_lib.i
    include graphics/gfxbase.i
    include hardware/custom.i
	; for VPrintf...
	include libraries/dos_lib.i

    include demodata.i

	XREF	_mfast
	XREF    __XCEXIT
	XREF    _demoEnd
	XREF    _debugv

    section code,code


	ifne    DDEBUG
	XREF	_DosBase
_dbgAllocSize:	dc.l	0
_dbgAllocType:	dc.l	0

	endc

; - - - -  - - - - Inner Memory Management
CleanMem:	; shitty clean for alloc
	; d0 size to clear
	; a0 ptr
	move.l	d0,d1
	move.l	a0,a2
	lsr.l	#2,d0
	beq	.rest
.lp
	clr.l	(a2)+
	subq	#1,d0
	bgt	.lp
.rest
	and.l	#3,d1
	beq	.end
.lp2
	clr.b	(a2)+
	subq	#1,d1
	bgt	.lp2
.end
	rts
GetNewCell:
	; fast in a1
	;can use a0,a3
	;d1 free
; STRUCT sf_MemCells,inm_SIZEOF*MAXNBMEMCELL

	lea	sf_MemCells(a1),a0
	move.w	#MAXNBMEMCELL-1,d1
.lp 	; search cell with state=0
	tst.w	inm_state(a0)
	bne		.next
		; a0 good
		rts
.next
	lea	inm_SIZEOF(a0),a0
	dbf	d1,.lp
	; error
	sub.l	a0,a0
	rts
InAllocBloc:
	;a1 fast
	;a2 first ptr
	;d0 size
	;d1 free
	sub.l	a0,a0	; default: error
.wh
	cmp.w	#1,inm_state(a2)
	bne		.next
	; 1 means available
	move.l	inm_size(a2),d1
	cmp.l	d0,d1
	blt		.next
	; - - this cell is OK
	; if exact size, just take cell
	; rare case can happens
	bne		.split
		move.w	#2,inm_state(a2)
		move.l	inm_ptr(a2),a0
		bsr	CleanMem
		rts
.split
	bsr GetNewCell
	tst.l	a0
	beq	.end
		; - - -split cells
		move.l	d0,inm_size(a0)
		move.w	#2,inm_state(a0)
		move.l	inm_ptr(a2),inm_ptr(a0)
		sub.l	d0,inm_size(a2)
		add.l	d0,inm_ptr(a2)

		move.l	inm_prev(a2),inm_prev(a0)
		move.l	a0,inm_prev(a2)

		move.l	inm_retroptr(a2),a3
		move.l	a0,(a3)
		move.l	a3,inm_retroptr(a0)

		lea		inm_next(a0),a3
		move.l	a2,(a3)
		move.l	a3,inm_retroptr(a2)

		; return cell ptr
		move.l	inm_ptr(a0),a0
		bsr	CleanMem
		bra		.end
.next
	move.l  inm_next(a2),a2
	tst.l	a2
	bne	.wh
.end
	;a0 return alloc ptr or null
	rts
; - - - -  - -- -
	XDEF    _InAlloc
	XDEF    InAlloc
	; d0 size
	;d1:0 fast, 1 chip
	; return a0
_InAlloc:
InAlloc:
	movem.l	a2/a3,-(sp)

	ifne    DDEBUG
		move.l	d0,_dbgAllocSize
		move.l	d1,_dbgAllocType
	endc
	
	
	move.l	_mfast,a1
	tst.l	d1
	bne	.chip

	; - - search fast
	move.l	sf_FastStart(a1),a2
	bsr 	InAllocBloc
	bra		.end
.chip
	move.l	sf_Chip1Start(a1),a2
	bsr InAllocBloc
	tst.l	a0
	bne		.end
	move.l	sf_Chip2Start(a1),a2
	bsr InAllocBloc
.end
	tst.l	a0
	bne	.lok
	; error
	bsr _demoEnd
	ifne    DDEBUG
;		 move.l	 _dbgAllocSize,_debugv
;		 move.l	 _dbgAllocType,_debugv+4
;		 move.l	 #666,_debugv+8

	;	 move.l	 #$CACABABE,_debugv+8
;;		  bsr     ValidateChain
	endc

	jmp     __XCEXIT
.lok
	movem.l	(sp)+,a2/a3
	move.l	a0,d0 ; for sas C compat
	rts
; - - - - - - - - -
	XDEF	_InFree
	XDEF	InFree
	; a0 ptr to free
_InFree:
InFree:
	movem.l a2/a3,-(sp)
	tst.l	a0
	beq		.end	; test better here

	move.l	_mfast,a1

	; search cell
	; STRUCT sf_MemCells,inm_SIZEOF*MAXNBMEMCELL
	lea	sf_MemCells(a1),a1


	move.w	#MAXNBMEMCELL-1,d0
.lp
	cmp.l	inm_ptr(a1),a0
	bne	.next
; - - - - - -  - - - - -
	; here it is
	; Just declare as available mem
	move.w	#1,inm_state(a1)

	; - - - - get prev and next
	move.l	inm_prev(a1),a0
	move.l	inm_next(a1),a2

	; - - see if a0 can be merged to a1
	tst.l	a0
	beq		.noprev
	cmp.w	#1,inm_state(a0)
	bne	.noprevmerge
		move.l	inm_size(a1),d0
		add.l	d0,inm_size(a0)

		; unlink a1
		move.l	inm_retroptr(a1),a3 ; on a next or start
		move.l	a2,(a3)
		tst.l	a2
		beq	.norl
		move.l	a3,inm_retroptr(a2)
		move.l	a0,inm_prev(a2)
.norl
		; - -
		move.w	#0,inm_state(a1) ; declare cell free
		move.l	a0,a1
.noprevmerge
.noprev
	; - - see if can merge a1 to next a2
	tst.l   a2
	beq	.nonext
	cmp.w	#1,inm_state(a2)
	bne	.nonextmerge

	; unlink a1, a2 is the next a1
	move.l	inm_size(a1),d0
	add.l	d0,inm_size(a2)
	move.l	inm_ptr(a1),inm_ptr(a2)
	move.w	#0,inm_state(a1) ; free cell

	move.l	inm_retroptr(a1),a0
	move.l	a2,(a0)
	move.l	a0,inm_retroptr(a2)
	move.l	inm_prev(a1),a0
	move.l	a0,inm_prev(a2)
	; ok !

.nonextmerge
.nonext

; - - - - - - - - -
	bra	.end
.next
	lea	inm_SIZEOF(a1),a1
	dbf	d0,.lp
;;	  move.l  #121212,_debugv+12


.end
	;TODO

;		 APTR	 inm_next
;		 UWORD	 inm_state
;		 UWORD	 inm_xxx
;;		  APTR	  inm_ptr
;		 ULONG	 inm_size
	movem.l (sp)+,a2/a3
	rts
; - - - - - - -  - debug, to be removed
	ifne	DOVALIDATE
ValidateChain:


	move.l	_mfast,a5
	move.l  sf_FastStart(a5),a0
	bsr 	ValidateSubChain

	move.l	_mfast,a5
	move.l  sf_Chip1Start(a5),a0
	bsr 	ValidateSubChain

	move.l	_mfast,a5
	move.l  sf_Chip2Start(a5),a0
	bsr 	ValidateSubChain


	rts
ValidateSubChain:
	; a0 start of chain

	clr.l	d7

.wh
	tst.l	a0
	beq	.end


	move.l	inm_ptr(a0),d6
	move.l	d6,cellvv
	sub.l	d6,d7
	move.l	d7,cellvv+12 ; delta ptr
	move.l	d6,d7


	move.w	 inm_state(a0),d0
	move.w	d0,cellvv+6

	move.l	inm_size(a0),a1
	move.l	a1,cellvv+8

	move.l	a0,-(sp)
	move.l	_DosBase,a6
		move.l	#cellstr,d1
		move.l	#cellvv,d2
		CALL	VPrintf

	move.l	(sp)+,a0

	move.l	inm_next(a0),a0
	bra	.wh

.end
	;count used cells
	lea	sf_MemCells(a5),a0

	clr.l	cellw
	clr.l	cellw+4
	clr.l	cellw+8

	move.w	#MAXNBMEMCELL-1,d0
.lpt
		move.w	inm_state(a0),d1
		lea		cellw,a1
		add.l	#1,(a1,d1.w*4)

		lea	inm_SIZEOF(a0),a0
	dbf	d0,.lpt

;		 STRUCT sf_MemCells,inm_SIZEOF*MAXNBMEMCELL

	move.l	_DosBase,a6
	move.l	#cellstr2,d1
	move.l	#cellw,d2
	CALL	VPrintf


	; jump a line
	move.l	_DosBase,a6
	move.l	#strend,d1
	clr.l	d2
	CALL	VPrintf

	rts
even
cellstr:	dc.b 'start:%lx type:%ld length:%ld dd:%ld'
strend:		dc.b 10,0
	even
cellvv:	dc.l	0,0,0,0

cellstr2:	dc.b 'dispo:%ld free:%ld used:%ld',10,0
	even
cellw:		dc.l	0,0,0
	endc	; DOVALIDATE
