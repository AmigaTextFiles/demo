; $$TABS=8
; master include file for AA demo
;

	opt	p=68020
	include	'profile.i'
	basereg	blink
	addsym

PROFILE	set	0
SCREEN_WIDTH	equ	320		; width of raster for our screen
SCREEN_HEIGHT	equ	200		; height for our screen.
SCREEN_DEPTH	equ	8		; depth (number of bitplanes) for our screen

CANVAS_WIDTH	equ	320		; width of canvas to scroll over
CANVAS_HEIGHT	equ	200		; height of canvas to scroll over.

DO_CEILING	set	0

MOTION_BLUR	equ	0
DOBLUR	equ	0

	ifne	DOBLUR
HSCALE	set	2
	else
HSCALE	set	1
	endc


DUNGEON_WINDOW_WIDTH	equ	192/HSCALE
DUNGEON_WINDOW_HEIGHT	equ	90

DUNGEON_WINDOW_X	equ	0
DUNGEON_WINDOW_Y	equ	0
DUNGEON_WINDOW_RIGHT	equ	DUNGEON_WINDOW_X+(DUNGEON_WINDOW_WIDTH*HSCALE)-1

DO_DIAGNOSTICS	set	1		; diagnostic messages?
DUNGEON_GRID_SIZE	equ	16		; 16x16
DUNGEON_GRID_SHIFT	equ	4		; lg(dungeon_grid_size)

; macros for opening and closing libraries, with error checks

geta6	macro
; restore variable base pointer
	xref	_LinkerDB
	lea	_LinkerDB,a6
	endm


openlib	macro	lname,lvar
;		\1    \2
; open a library and jump to quiet_error if it can't be found.
	lea	\1,a1		;; library name
	moveq	#39,d0			;; request version 39
	move.l	a6,a5			;; save local var pointer
	move.l	_SysBase(a5),a6		;; get from local copy, not location 4!
	jsr	_LVOOpenLibrary(a6)	;; open the library
	move.l	a5,a6			;; restore variable base
	move.l	d0,\2(a5)		;; save it and test for zero
	beq	quiet_error		;; not found?
	endm

closelib	macro	lbase
;			\1
; close a library and set its base ptr to 0.
; trashes a0/a1/d0/d1
	move.l	\1(a6),d0		;; fetch library pointer and test for 0
	beq.s	already_closed\@
	move.l	d0,a1
	move.l	_SysBase(a6),a6		;; need execbase for closelib
	jsr	_LVOCloseLibrary(a6)	;; close it
	geta6				;; get back varbase
	clr.l	\1(a6)			;; clear ptr for safety
already_closed\@:
	endm


CWAIT	macro	ucl,vpos,hpos
;		\1  \2   \3
; trashes d0-d1/a0-a1
	xref	_LVOCWait,_LVOCBump
	move.l	\1,a1
	move.l	a1,-(a7)
	move.l	\2,d0
	move.l	\3,d1
	jsr	_LVOCWait(a6)
	move.l	(a7)+,a1
	jsr	_LVOCBump(a6)
	endm	

CMOVE	macro	ucl,reg,value
;		\1  \2   \3
; trashes d0-d1/a0-a1
	xref	_LVOCMove,_LVOCBump
	move.l	\1,a1
	move.l	a1,-(a7)
	move.l	\2,d0
	move.l	\3,d1
	jsr	_LVOCMove(a6)
	move.l	(a7)+,a1
	jsr	_LVOCBump(a6)
	endm	

CEND	macro	ucl
;		\1
	CWAIT	\1,#10000,#255
	endm

INITLOCALS	macro
TEMP_SIZE	set	0
	endm

WORDVAR	macro	vname
TEMP_SIZE	set	TEMP_SIZE+(TEMP_SIZE&1)	; even up
\1_w		set	TEMP_SIZE
TEMP_SIZE	set	TEMP_SIZE+2
	endm

LONGVAR	macro	vname
TEMP_SIZE	set	TEMP_SIZE+((4-(TEMP_SIZE&3))&3)	; lword align
\1_l		set	TEMP_SIZE
TEMP_SIZE	set	TEMP_SIZE+4
	endm

BVAR	macro	vname
\1_b	set	TEMP_SIZE
TEMP_SIZE	set	TEMP_SIZE+1
	endm

ARRAYVAR	macro	vname,size
TEMP_SIZE	set	TEMP_SIZE+((4-(TEMP_SIZE&3))&3)	; lword align
\1	set	TEMP_SIZE
TEMP_SIZE	set	TEMP_SIZE+\2
	endm

ALLOCLOCALS	macro
; align temp_size and sub from sp
TEMP_SIZE	set	TEMP_SIZE+((4-(TEMP_SIZE&3))&3)	; lword align
	lea	-TEMP_SIZE(a7),a7
	endm

dbug	macro	r
	xref	_kprintf
	movem.l	d0/d1/a0/a1,-(a7)
	move.l \1,-(a7)
	pea	a\@(pc)
	jsr	_kprintf
	lea	8(a7),a7
	bra.s	b\@
a\@: dc.b	'%lx ',0,0
b\@:
	movem.l	(a7)+,d0/d1/a0/a1
	endm

dbugw	macro	r
	xref	_kprintf
	movem.l	d0/d1/a0/a1,-(a7)
	move.w \1,-(a7)
	pea	a\@(pc)
	jsr	_kprintf
	lea	6(a7),a7
	bra.s	b\@
a\@: dc.b	'%x ',0
b\@:
	movem.l	(a7)+,d0/d1/a0/a1
	endm

print	macro	string
	xref	KPutStr
	movem.l	a0/a1/d0/d1,-(a7)
	lea	mystring\@(pc),a0
	jsr	KPutStr
	movem.l	(a7)+,a0/a1/d0/d1
	bra.s	skip\@
mystring\@:
	dc.b	\1,0
	cnop	0,2
skip\@:
	endm

dstring	macro	fmtstring, x,y,arg0,arg1,arg2,arg3,arg4
;		\1	  \2\3 \4   \5   \6   \7   \8
	xref	PlotString
	movem.l	d0/d1/d2/d3/a0/a1/a5,-(a7)
	move.l	a7,a5
	ifnc	"\8",""
	move.l	\8,-(a7)
	endc
	ifnc	"\7",""
	move.l	\7,-(a7)
	endc
	ifnc	"\6",""
	move.l	\6,-(a7)
	endc
	ifnc	"\5",""
	move.l	\5,-(a7)
	endc
	ifnc	"\4",""
	move.l	\4,-(a7)
	endc
	move.l	#\2,d2
	move.l	#\3,d3
	lea	tempstring\@(pc),a0
	pea	skipstr\@(pc)
	bra	PlotString
tempstring\@:
	dc.b	\1,0
	cnop	0,2
skipstr\@:
	move.l	a5,a7
	movem.l	(a7)+,d0/d1/d2/d3/a0/a1/a5
	endm

replicate	macro	reg,trashreg
;		\1  \2
	move.b	\1,\2
	lsl.l	#8,\1
	move.b	\2,\1
	move.w	\1,\2
	swap	\1
	move.w	\2,\1
	endm

plotpixel	macro	x, y, c, temp
;	          \1 \2 \3  \4
	xref	yadrtable
	move.l	(yadrtable.w,a6,\2.w*4),\4
	move.b	\3,(\4,\1.w)
	endm

_LVOGetJoyPortEvent equ	-$30
