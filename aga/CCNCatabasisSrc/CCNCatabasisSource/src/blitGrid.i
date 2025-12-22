	ifnd	EXEC_TYPES_I
		include exec/types.i
	endc



	STRUCTURE	bltSquare,0
		WORD	bls_bltapt	;source
		WORD	bls_bltdpt	;dest
		WORD	bls_bltsize
		WORD	bls_bltcon0 ; contain shift
	LABEL	bls_SIZEOF	;12


	STRUCTURE	BlitGrid,0
		WORD	blg_bltadmod ;same value WORD lg_bltdmod
		WORD	blg_bpr ;bytesperrow
		; squares active-1
		WORD	blg_nbActivem1
		WORD	blg_frame

		WORD	blg_rndy
		WORD	blg_rndx

		LONG    blg_random		  
		
		; table of squares
		; 12*80=960
		STRUCT	blg_Squares,bls_SIZEOF*(10*8)
	LABEL	blg_SIZEOF

