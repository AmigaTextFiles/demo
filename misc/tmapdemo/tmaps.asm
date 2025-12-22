;$$TABS=8

	include	'demo.i'

	section	TextureMaps,DATA

; structure of a tmap:
; 	dc.w	256*maxx
;	dc.w	256*maxy
;	dc.w	yshiftup		; amount to shift them up by

KingTut::
	dc.w	$7fff		; maxx
	dc.w	$7fff		; maxy
	dc.w	7
	include	'kingtut.i'

	cnop	0,4
Fish::
	dc.w	$7fff		; maxx
	dc.w	$7fff		; maxy
	dc.w	7
	include	'fish.i'

	cnop	0,4
Wolves::
	dc.w	$7fff		; maxx
	dc.w	$7fff		; maxy
	dc.w	7
	include	'wolves.i'

	cnop	0,4
Mandrill::
	dc.w	$7fff		; maxx
	dc.w	$7fff		; maxy
	dc.w	7
	include	'mandrill.i'
