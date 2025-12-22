; Kompakt kodsnutt med lite klurigt loopande. ;)

	XDEF	_drawtunnel

; in	d0	number of pixels
;	a0	tunneltab
;	a1	texture
;	a2	chunkybuffer

_drawtunnel
	subq.l	#1,d0        ; Gå till nästa pixel (n-1)
	beq.s	.npixel      ; Om pixel 0 avsluta då...
	moveq	#0,d1        ; Nollställ d1
	swap	d0           ; Byt plats på worden i d0
.pix64k	swap	d0           ; Byt plats på worden i d0
.pixel	move.w	(a0)+,d1     ; Position från tabellen++ in i d1
	move.b	(a1,d1.l),(a2)+ ; x el. y till chunkybuf.
	dbf	d0,.pixel
	swap	d0
	dbf	d0,.pix64k
.npixel	rts
