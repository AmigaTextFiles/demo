; $$TABS=8
	include	'demo.i'
	include	'hardware/custom.i'
	
	xref	_custom
	xdef	read_joystick

read_joystick::
; joystick - get current state of switches in variables
; uses d0,d1
	move.w	_custom+joy1dat,d0
	btst	#1,d0
	sne	stick_right(a6)
	btst	#9,d0
	sne	stick_left(a6)
	move	d0,d1
	add	d0,d0
	eor	d1,d0
	btst	#1,d0
	sne	stick_down(a6)
	btst	#9,d0
	sne	stick_up(a6)
	tst.b	$bfe0ff		; fire button
	spl	stick_fire(a6)
	tst.b	stick_fire(a6)
	bmi.s	j_1
	tst.b	old_stick_fire(a6)
	smi	stick_click(a6)
j_1:	move.b	stick_fire(a6),old_stick_fire(a6)
	rts

	section	__MERGED,data

stick_up::
	ds.b	1
stick_down::
	ds.b	1
stick_left::
	ds.b	1
stick_right::
	ds.b	1
stick_fire::
	ds.b	1
stick_click::
	ds.b	1
old_stick_fire::
	ds.b	1
