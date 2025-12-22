	; GVT_BSTR.s by Shagratt of LSD

	; this is distributable ONLY with GRAPEVINE ISSUE 10.
	
	
	section	ddp,code

	incdir	"dh0:includes/"
	include	"libraries/gvt.i"

	; gvt call corrupts a1,a2,a3,a4,a5,a6,d0,d1
	; dont push onto stack or it guru's (!!!)

	gvtcall	$110	; send linefeed to COS

	move.l	#bstr1,d1
	lsr.l	#2,d1
	gvtcall	$124	; send BSTR to COS

	move.l	#12345,d1
	gvtcall	$118	; output decimal value to COS
	gvtcall	$110	; send linefeed to COS



wait:	btst	#6,$bfe001
	bne	wait



	clr.l	d0
	rts

	cnop	0,4	; long align
bstr1:	dc.b	9,"Value is "
	nop
	
	
	END

