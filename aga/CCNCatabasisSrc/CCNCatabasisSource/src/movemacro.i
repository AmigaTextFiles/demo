
	include exec/types.i
   
AffMoveVar	MACRO
_mvPos\1:		dc.l	(\2)<<16
_mvEnd\1:		dc.w	0
_mvAdd\1:    	dc.l	0
_mvStep\1:		dc.w    0
		endm

; nm,v1,v2,length
AffMoveStart    MACRO
	move.l	#(\2)<<16,_mvPos\1

	move.w	#\4,_mvStep\1
	move.w	#\3,_mvEnd\1

	move.l	#(\3-(\2))<<16,d0

	divs.l	#\4,d0
	move.l	d0,_mvAdd\1
	endm

AffMoveStep MACRO
	tst.w	_mvStep\1
	beq.b	  .no\@
	sub.w	#1,_mvStep\1
	move.l	_mvAdd\1,d0
	add.l	d0,_mvPos\1
	tst.w   _mvStep\1
	bgt.b	.noend\@
		move.w  _mvEnd\1,_mvPos\1
.noend\@
.no\@
	endm

AffGetw	MACRO
	move.w	_mvPos\1,\2
	endm

; - - - - - - -- -
ExpMoveAStart Macro
	move.w	#64,_mvStep\1
	endm

	;64 step 0->256
	;nm,ax ptr to table 512
ExpMoveA Macro
	move.w  _mvStep\1,d0
	tst.w	d0
	beq.b	.no\@
	sub.w	#1,d0
	move.w	d0,_mvStep\1
	move.w	(\2,d0.w*4),d0	 ; 256->128
	sub.w	#128,d0	;128->0
	lsl.w	#1,d0
	neg.w	d0
	add.w	#256,d0
	move.w	d0,_mvPos\1

	tst.w   _mvStep\1
	bgt.b	.noend\@
		move.w  #256,_mvPos\1
.noend\@
.no\@

	endm


