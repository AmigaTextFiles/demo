	section prog,code
	opt o+,w-
	move.l #0,0
	lea glib(pc),a1
 	move.l 4.w,a6
 	jsr -408(a6)
	move.l d0,A1
	move.l 38(A1),oc
	jsr -414(a6)
	jsr -132(a6)
 	move.l #NC,$dff080
w	btst #6,$bfe001
	bne w
	jsr -138(a6)
 	move.l oc,$dff080
	moveq #0,d0
	rts
glib	dc.b "graphics.library",0
	even
oc	DC.l 0
	section cp,data_c
NC:	dc.w $100,0
	dc.w $120,0,$122,0,$124,0,$126,0,$128,0,$12a,0,$12c,0,$12e
	dc.w 0,$130,0,$132,0,$134,0,$136,0,$138,0,$13a,0,$13c,0,$13e,0
	dc.w $180,0
	

****COPPER LIST****

 	dc.w $3401,$fffe,$180,$f00		;line $34 - Red
 	dc.w $8001,$fffe,$180,$ff0		;line $80 - Yellow
 	dc.w $8101,$fffe,$180,$00f		;line $81 - Blue
 	dc.w $a001,$fffe,$180,$0f0		;line $a0 - Green


 	DC.w $FFFF,$FFFE

	



