	; GVT_SoftwareError.s by Shagratt of LSD

	; this is distributable ONLY with GRAPEVINE ISSUE 10.

	section	ddp,code

	incdir	"dh0:includes/"
	include	"libraries/gvt.i"

	; gvt call corrupts a1,a2,a3,a4,a5,a6,d0,d1
	; dont push onto stack or it guru's (!!!)

	gvtcall	$98	; display software error requester
			; does not actualy software error!
			; on KS2.xx it kill task is selected
			; it kills this task!
	clr.l	d0
	rts
	
	
	END

