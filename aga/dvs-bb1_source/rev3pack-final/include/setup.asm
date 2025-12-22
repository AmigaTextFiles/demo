**********************************************************************
*	Setup.asm
*	~~~~~~~~~
*	Description : This is my code which sets and frees up data and 
*		      any other stuff correctly..
*			
*	Code : Dennis Predovnik (SuLtAn/DVS)
*	Date : 12/3/96 
*
**********************************************************************

	section		setup_Code,code
	
*********************************************************************
*	Alloc/Insert etc				            *
*********************************************************************	 

SETUPALL MACRO
        move.l  4.w,a6                  ; Get ExecBase
        lea     intname,a1	        ;
        moveq   #39,d0                  ; Kickstart 3.0 or higher
        jsr     _LVOOpenLibrary(a6)
        move.l  d0,_IntuitionBase       ; Store intuitionbase
                                        ; Note: If this fails then 
                                        ; Kickstart is <V39.
        move.l  4.w,a6                  ; Get ExecBase
        lea     gfxname,a1              ; Graphics name
        moveq   #33,d0                  ; Kickstart 1.2 or higher
        jsr     _LVOOpenLibrary(a6)
        tst.l   d0
        bne     insGFXBase              ; Failed to open? Then quit
	rts
insGFXBase:
        move.l  d0,_GfxBase

	move.l	#320,d0
	move.l	#(230*5),d1
	move.l	_GfxBase,a6
	jsr	_LVOAllocRaster(a6)
	tst.l	d0
	bne	insMenu1		; Cool we got mem !!
	rts				; No Cigar !!
insMenu1:
	move.l	d0,menuScreen1

	move.l	d0,a1
	move.l	#(320*230*5)/8,d0       ; Clear Screen !!
	jsr	clr
	
	move.l	#320,d0
	move.l	#(230*5),d1
	move.l	_GfxBase,a6
	jsr	_LVOAllocRaster(a6)
	tst.l	d0
	bne	insMenu2		; Cool we got mem !!
	rts				; No Cigar !!
insMenu2:
	move.l	d0,menuScreen2

	move.l	d0,a1
	move.l	#(320*230*5)/8,d0       ; Clear Screen !!
	jsr	clr
	move.l	menuScreen1,PAGELOG1

	move.l	#64,d0
	move.l	#58,d1
	move.l	_GfxBase,a6
	jsr	_LVOAllocRaster(a6)
	tst.l	d0
	bne	insDotBuf1		; Cool we got mem !!
	rts				; No Cigar !!
insDotBuf1:
	move.l	d0,dotBuf1

	move.l	d0,a1
	move.l	#(64*58)/8,d0           ; Clear Buffer !!
	jsr	clr

	move.l	#64,d0
	move.l	#58,d1
	move.l	_GfxBase,a6
	jsr	_LVOAllocRaster(a6)
	tst.l	d0
	bne	insDotBuf2		; Cool we got mem !!
	rts				; No Cigar !!
insDotBuf2:
	move.l	d0,dotBuf2

	move.l	d0,a1
	move.l	#(64*58)/8,d0           ; Clear Buffer !!
	jsr	clr
	ENDM

	
*********************************************************************
*	Free Mem etc					            *
*********************************************************************	 

FREEALL MACRO
	move.l	_GfxBase,a6
	move.l	menuScreen1,a0
	move.w	#320,d0
	move.w	#(230*5),d1
	jsr	_LVOFreeRaster(a6)

	move.l	_GfxBase,a6
	move.l	menuScreen2,a0
	move.w	#320,d0
	move.w	#(230*5),d1
	jsr	_LVOFreeRaster(a6)

	move.l	_GfxBase,a6
	move.l	dotBuf1,a0
	move.l	#64,d0
	move.l	#58,d1
	jsr	_LVOFreeRaster(a6)

	move.l	_GfxBase,a6
	move.l	dotBuf2,a0
	move.l	#64,d0
	move.l	#58,d1
	jsr	_LVOFreeRaster(a6)

	ENDM
	