; Eld rutin (förhoppningsvis)

	XDEF  fire

	section  code,code

; d0.w   chunkyx [chunky-pixels]
; d1.w   chunkyy [chunky-pixels]

; a0  chunkybuffer

_fire
fire
	movem.l  d2-d7/a2-a6,-(sp)

	;Elduppeldningskod skall ligga här...

	movem.l  (sp)+,d2-d7/a2-a6
	rts

