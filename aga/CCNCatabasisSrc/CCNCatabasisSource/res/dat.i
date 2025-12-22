
; - - - dat.i
	;when included in code
	; we just have a N_label code for the resource
	;when included from dat.s
	; we compile a header and then resource in .dat

NBFILES	SET	0
ADDFILE	MACRO
	ifnd	IMPLEMENT
N_\1	 SET NBFILES
NBFILES	SET NBFILES+1
	else
	ifne	IMPLEMENT
sta\1:	incbin	 \2
end\1:	even
	else
	dc.w	0
	dc.l    FOFS+(sta\1-begin),(end\1-sta\1)
	endc
	endc
	ENDM

	; - - list files in dat, keep index.
DOFILEIMP	MACRO
	; add files here, once and for all

	; -  -first load phase phase (fxLoad)

	ADDFILE	bootpat,bootpat3b.gif
	ADDFILE bspec,target1.gif
	ADDFILE	txtile,texturesG.gif
	ADDFILE	haik,haik.gif
	ADDFILE	tit,cata3c.gif

	ADDFILE noise320,nois320t2b.gif
	ADDFILE noise256,nois256t3b.gif
	ADDFILE	sprHead,headcut2.gif

	ADDFILE	leyes,regardc.gif

	ADDFILE	lwoSpike,lwo/spike120.lwo.obs
	ADDFILE	lwoExtruded,lwo/extruded.lwo.obs
	ADDFILE	lwoSkull,lwo/skull.lwo.obs

	ADDFILE	lwg1,lwo/1_gr.lwo.obs
	ADDFILE	lwg2,lwo/2_gr.lwo.obs
	ADDFILE lwg3,lwo/3_gr.lwo.obs

	ADDFILE	lwg4,lwo/4_gr.lwo.obs
	ADDFILE	lwg5,lwo/5_gr.lwo.obs
	ADDFILE	lwg6,lwo/6_gr.lwo.obs
	ADDFILE	lwg7,lwo/7_gr.lwo.obs
	ADDFILE	lwg8,lwo/8_gr.lwo.obs
	ADDFILE	lwg9,lwo/9_gr.lwo.obs
	ADDFILE	lwg10,lwo/10_gr.lwo.obs
	ADDFILE	lwg11,lwo/11_gr.lwo.obs
	ADDFILE	lwg12,lwo/12_gr.lwo.obs
	ADDFILE	lwg13,lwo/13_gr.lwo.obs
	ADDFILE	lwg14,lwo/14_gr.lwo.obs

	ADDFILE light1chk,light2.gif
	ADDFILE	light2chk,light2b.gif

	ADDFILE	firstlogo,nytrikLogo2.gif

	ADDFILE zik,P61.spokf

	; - load during plasma

	ADDFILE	tunn,tunn.gif
	ADDFILE	cShape,cocoonshape.gif
	ADDFILE	punchl,punchlines.gif

	ENDM

	ifnd	IMPLEMENT
	; just declare N_ const
	DOFILEIMP
	endc
