	; GVT_Requester.s by Shagratt of LSD

	; this is distributable ONLY with GRAPEVINE ISSUE 10.

	section	ddp,code

	incdir	"dh0:includes/"
	include	"libraries/gvt.i"

	; gvt call corrupts a1,a2,a3,a4,a5,a6,d0,d1?
	; dont push regs onto stack or it guru's (!!!)

	move.l	#t1,d1
	move.l	#t2,d2
	lsr.l	#2,d1	; make bptr
	lsr.l	#2,d2	; make bptr
	gvtcall	$d0	; make requester

	; d1 = 1/0 - retry/cancel
	
	clr.l	d0
	rts
	
	; make sure following are long aligned

	cnop	0,4	; long align
t1:	dc.b	"*Volume in drive df0:",0

	cnop	0,4	; long align
t2:	dc.b	"*is covered with lard",0
	
	
	END

