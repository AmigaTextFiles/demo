
	XDEF _checkmouse

_checkmouse:
	btst  #6,$bfe001
	bne.b _mousepressed
	move.l   #1,d0
	RTS

_mousepressed
	move.l   #0,d0
	RTS

