**********************************************************************
*	StandardRoutines.asm
*	~~~~~~~~~~~~~~~~~~~~
*	Description : Is what it says.. Contains Repetitive standard
*		      Routines, used in alot my own productions !!  		
*			
*	Code : Dennis Predovnik (SuLtAn/DVS)
*	Date : 10/1/95 
*
**********************************************************************

	section		STDRoU_Code,code

*/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
* 	Force Console Window Open and Print		*
*	a Message..					*
*							*
*	D2 - Address of Message				*
*	D3 - Message Length				* 
*							*
*\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

printMsg:
	move.l	#dosname,a1
	moveq	#0,d0
	move.l	4.w,a6
	jsr	_LVOOpenLibrary(a6)
	tst.l	d0
	beq	msgError
	move.l	d0,_DosBase

	move.l	_DosBase,a6
	jsr	_LVOOutput(a6)
	tst.l	d0
	beq	msgError
	move.l	d0,_StdOut

	move.l	_StdOut,d1
	move.l	_DosBase,a6
	jsr	_LVOWrite(a6)		

	move.l	4.w,a6
	move.l	_DosBase,a1
	jsr	_LVOCloseLibrary(a6)

msgError:
	rts

**********************************************************************
* This function provides a method of obtaining a pointer to the base 
* of the interrupt vector table on all Amigas.  After getting this 
* pointer, use the vector address as an offset.  For example, to 
* install a level three interrupt you would do the following:
*
*		bsr	_GetVBR
*		move.l	d0,a0
*		move.l	#MyIntCode,$6c(a0)
*
* That's all there is to it!  This will help make your program 
* work on many more Amigas than is you just did this:
*
*		move.l	#MyIntCode,$6c.w
*
**********************************************************************
* Inputs: None
* Output: D0 contains vbr.
**********************************************************************

_LVOSuperVisor	equ	-30

_GetVBR:	moveq.l	#0,d0			   ; clear
		move.l	4,a6			   ; exec base
		btst.b	#AFB_68010,AttnFlags+1(a6) ; are we at least a 68010?
		beq.b	.1			   ; nope.
		lea.l	vbr_exception(pc),a5	   ; addr of function to get VBR
		jsr	_LVOSuperVisor(a6)	   ; supervisor state
.1		rts				   ; return

vbr_exception:
 dc.w	$4e7a,$0801
 rte	; back to user state code
	; movec vbr,Xn is a priv. instr.  You must be supervisor to execute!
	; many assemblers don't know the VBR, if yours doesn't, then use this
	; line instead.
	; dc.w	$4e7a,$0801

*****************************************************************
*	Repetitive Routines					*
*****************************************************************

; Inputs:
;	 Address of Coppper BitPlane Pointers = a0 
;	 Address of Screen to insert          = d0
;	 Number of Planes-1                   = d1                   
;	 RASSIZE() (WIDTH*HEIGHT)/8           = d2
;        CopSIZE                              = d3

insertCopper:
	move.w 	d0,6(a0)
	swap 	d0
	move.w 	d0,2(a0)
	swap 	d0
	add.l	d2,d0                       ; Passed as Parameter 
	add	d3,a0                       ; 2 Long words
	dbra	d1,insertCopper
	rts

; Blitter Clear Routine				        
; Inputs:
;	A1 = Address to Clear				        
;       D0 = Size of bytes to Clear ie RASSIZE()	

clr:
	move.l	a1,-(sp)
	move.l	_GfxBase,a6
	clr.l	d1
	jsr	_LVOBltClear(a6)
	move.l	(sp)+,a1
	rts

*/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
*		Controls Page Swapping				*
*								*
*	A0 - BLPT						*
*	D0 - Page 1						*
*	D1 - Page 2						*
*	D2 - DEPTH - 1						*
*	D3 - RASSIZE()						*
*       D4 - Word Size                                          *
*								*
*\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

swap1:
	cmp.l 	PAGELOG1,d0	        ; Is current Screen = Screen1
	bne 	swapit1		        ; No then branch
	move.l	d1,PAGELOG1             ; Screen2 = Logical 
	move.l	d0,PAGEPHY1		; Screen1 = Physical
	jsr 	insCopper               ; Insert it Into Copper

  	rts
  	
swapit1:
	move.l	d0,PAGELOG1		; Screen1 = Logical
	move.l	d1,PAGEPHY1		; Screen2 = Physical
	
	move.l 	d1,d0			; Display Screen 2
	jsr 	insCopper	    	; Insert screen

	rts

swap2:
	cmp.l 	PAGELOG2,d0	        ; Is current Screen = Screen1
	bne 	swapit2		        ; No then branch
	move.l	d1,PAGELOG2             ; Screen2 = Logical 
	move.l	d0,PAGEPHY2		; Screen1 = Physical
	jsr 	insCopper               ; Insert it Into Copper

  	rts
  	
swapit2:
	move.l	d0,PAGELOG2		; Screen1 = Logical
	move.l	d1,PAGEPHY2		; Screen2 = Physical
	
	move.l 	d1,d0			; Display Screen 2
	jsr 	insCopper	    	; Insert screen

	rts

swapLogo:
	cmp.l 	LPAGELOG,d0	        ; Is current Screen = Screen1
	bne 	logoSwapIt	        ; No then branch
	move.l	d1,LPAGELOG             ; Screen2 = Logical 
	move.l	d0,LPAGEPHY		; Screen1 = Physical
	jsr 	insCopper               ; Insert it Into Copper

  	rts
  	
logoSwapIt:
	move.l	d0,LPAGELOG		; Screen1 = Logical
	move.l	d1,LPAGEPHY		; Screen2 = Physical
	
	move.l 	d1,d0			; Display Screen 2
	jsr 	insCopper	    	; Insert screen

	rts

swapDot:
	cmp.l 	DOTLOG,d0	        ; Is current Screen = Screen1
	bne 	dotSwapIt	        ; No then branch
	move.l	d1,DOTLOG               ; Screen2 = Logical 
	move.l	d0,DOTPHY		; Screen1 = Physical
  	rts
  	
dotSwapIt:
	move.l	d0,DOTLOG		; Screen1 = Logical
	move.l	d1,DOTPHY		; Screen2 = Physical
	rts

;	
;	Inserts Screen at d0 in the Copper.. Physical
;

insCopper:
	move.w 	d0,6(a0)
	swap 	d0
	move.w 	d0,2(a0)
	swap 	d0
	add.l	d3,d0
	add	d4,a0           	; 2 Long words
	dbra	d2,insCopper
	rts

PAGELOG1 	dc.l	0		; Logical Screen
PAGEPHY1	dc.l	0		; Physical Screen
PAGELOG2 	dc.l	0		; Logical Screen
PAGEPHY2	dc.l	0		; Physical Screen
LPAGELOG 	dc.l	0		; Logical Screen
LPAGEPHY	dc.l	0		; Physical Screen
DOTLOG		dc.l	0               ; Logical Screen
DOTPHY          dc.l	0               ; Physical Screen
