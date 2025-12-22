
	

FOFS	equ	34

	include	dat.i

; - - - concat files
	rts	; prevent false launch crash (2b)
	; here is offset "34"
begin:
    DOFILEIMP

	dc.w	NBFILES	   ; (endT-startT)/10
startT:
IMPLEMENT	set	0
    DOFILEIMP
endT:
IMPLEMENT	set	1
    DOFILEIMP

