*****************************************************************
*	Primitives.asm                                              
*	~~~~~~~~~~~~~~                                              
*	Description : This file contains all the Graphic function
*		      primitives specific to this intro/pack/demo..	 
*			
*	Code : Dennis Predovnik (SuLtAn/DVS)
*	Date : 20/3/96 
*
*****************************************************************

	section		prim_Code,code

*/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
*		 writePixel					*
*								*
* INPUT:							*
*	D0 	X Cordinate				        *
*	D1 	Y Cordinate 			                *
*	A0      Start of screen address                         *
*								*
* Description : Routine SETS a pixel in screen memory !         *
*								*
*\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

writePixel:
	movem.l  d0-d5/a0,-(sp)
      	mulu     #8,d1             ; Usually 40 for 320 Pixelz !
     	divu     #8,d0
    	add.w    d0,d1
      	swap     d0
     	adda.l   d1,a0
      	move.b   (a0),d3
      	moveq    #0,d4
      	moveq    #7,d5
      	sub.b    d0,d5
      	bset     d5,d4
      	or.b     d4,d3
      	move.b   d3,(a0)              
      	movem.l  (sp)+,d0-d5/a0
     	rts

*/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
*		 drawLine					*
*								*
* INPUT:							*
*	D0 <31-16>	Y Cordinate of start point		*
*	D0 <15-0>	X Cordinate of start point              *
*	D1 <31-16>	Y Cordinate of end point                *
*	D1 <15-0>	X Cordinate of end point                * 
*	A0		Pointer to Bit Plane                    *
*                                                               *
*\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

drawLine:
	movem.l	d0-d7/a0-a6,-(sp)

	move.w	#1,d6
	sub.w	d0,d1
	bge.s	.got_deltaX
	neg.w	d1
	neg.w	d6
.got_deltaX:
	swap	d0
	move.w	d1,d2
	swap	d1
	move.w	#40,d7                ; For 320 Width !
	sub.w	d0,d1
	bge.s	.got_deltaY
	neg.w	d1
	neg.w	d7
.got_deltaY:
	clr.w	d5
	cmp.w	d1,d2
	bge.s	.got_L_and_Sdelta
	swap	d1
	not.w	d5
.got_L_and_Sdelta:
	move.w	d0,d2
	mulu	#40,d2                ; For 320 Width !
	adda.w	d2,a0
	swap	d0
	movea.w	d7,a1
	move.w	d1,d2
	swap	d1
	add.w	d2,d2
	move.w	d2,d3
	sub.w	d1,d3
	move.w	d3,d4
	sub.w	d1,d4
	tst.w	d5
	bne.s	.deltaY_greater
.next_X:
	move.w	d0,d7
	not.w	d7
	move.w	d0,d5
	asr.w	#3,d5
	bset	d7,(a0,d5.w)
	tst.w	d1
	beq.s	.line_done
	subq.w	#1,d1
	add.w	d6,d0
	tst.w	d3
	bge.s	.add_d4_to_Y
	add.w	d2,d3
	bra.s	.next_X
.add_d4_to_Y:
	adda.w	a1,a0
	add.w	d4,d3
	bra.s	.next_X
.deltaY_greater:
.next_Y:
	move.w	d0,d7
	not.w	d7
	move.w	d0,d5
	asr.w	#3,d5
	bset	d7,(a0,d5.w)
	tst.w	d1
	beq.s	.line_done
	subq.w	#1,d1
	adda.w	a1,a0
	tst.w	d3
	bge.s	.add_d4_to_X
	add.w	d2,d3
	bra.s	.next_Y
.add_d4_to_X:
	add.w	d6,d0
	add.w	d4,d3
	bra.s	.next_Y
.line_done:

	movem.l	(sp)+,d0-d7/a0-a6
	rts

