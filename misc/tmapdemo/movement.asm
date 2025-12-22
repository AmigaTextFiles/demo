; $$TABS=8

	include	'demo.i'

	xref	frfract,read_joystick
	xref	stick_right,stick_left,stick_down,stick_up,stick_click
	xref	sincos

; movement routines

DoMovement::
; read the joystick and move the player
	clr.w	Moved(a6)
	bsr	read_joystick
no_freeze_player:
	move.w	frfract(a6),d0
	lsr.w	#2,d0	; 8 second rotation
	tst.b	stick_right(a6)
	beq.s	no_right
	st	Moved(a6)
	add.w	d0,PlayerHeading(a6)
no_right:
	tst.b	stick_left(a6)
	beq.s	no_left
	sub.w	d0,PlayerHeading(a6)
	st	Moved(a6)
no_left:
	clr.w	PlayerSpeed(a6)
	tst.b	stick_up(a6)
	beq.s	no_speedup
	move.w	#2048,PlayerSpeed(a6)
no_speedup:
	tst.b	stick_down(a6)
	beq.s	no_slowdown
	move.w	#-2048,PlayerSpeed(a6)
no_slowdown:
; ok, now we have the variables updated, so let's move the guy!
	move.w	PlayerHeading(a6),d0
	bsr	sincos	; d0=sin d1=cos
	move.w	frfract(a6),d2
	muls	d2,d0
	muls	d2,d1
	add.l	d0,d0
	add.l	d1,d1
	swap	d0
	swap	d1
	move.w	PlayerSpeed(a6),d2
	or.w	d2,Moved(a6)
	muls	d2,d0
	muls	d2,d1
	add.l	d0,d0
	add.l	d1,d1
	swap	d0
	swap	d1
	ext.l	d0
	ext.l	d1
	add.l	d0,PlayerX(a6)
	add.l	d1,PlayerZ(a6)
	rts


	section	__MERGED,data

PlayerX::	dc.l	0
PlayerY::	dc.l	1000
PlayerZ::	dc.l	0

Moved::	dc.w	0
PlayerSpeed::	dc.w	0
PlayerHeading::	dc.w	0
