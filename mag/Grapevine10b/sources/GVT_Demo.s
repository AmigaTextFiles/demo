	; GVT_demo.s by Shagratt of LSD

	; this is distributable ONLY with GRAPEVINE ISSUE 10.

	section	ddp,code

	incdir	"dh0:includes/"
	include	"libraries/gvt.i"

	; gvt call corrupts a1,a2,a3,a4,a5,a6,d0,d1
	; dont push onto stack or it guru's (!!!)

	move.l	#winname,d1
	move.l	#1005,d2
	gvtcall	$fffc	; Open()

	cmp.l	#0,d1
	beq	error
	move.l	d1,handle
	
	move.l	handle,d1
	move.l	#message,d2
	move.l	#messlen,d3
	gvtcall	$ffe8	; Write()

	move.l	#100,d1
	gvtcall	$bc	; Delay()
	
	move.l	handle,d1
	gvtcall	$174	; Close()

error:	clr.l	d0
	rts


handle:		dc.l	0
winname:	dc.b	"raw:100/50/300/100/MY WINDOW",0
message:	dc.b	"Lard is the food of the future",0
messlen	= *-message

	
	END

