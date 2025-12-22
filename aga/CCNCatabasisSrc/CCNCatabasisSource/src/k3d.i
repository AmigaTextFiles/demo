

	ifnd	EXEC_TYPES_I
		include	exec/types.i
	endc


;--------------- Matrix3D matrix struct 4x4.
 STRUCTURE   Matrix3D,0
	WORD	mtrx_xx     ; <<16 !!!
    WORD    mtrx_xy
	WORD	mtrx_xz
	WORD	mtrx_xp

	WORD	mtrx_yx
	WORD	mtrx_yy
	WORD	mtrx_yz
	WORD	mtrx_yp

	WORD	mtrx_zx
	WORD	mtrx_zy
	WORD	mtrx_zz
	WORD	mtrx_zp

	WORD	mtrx_px
	WORD	mtrx_py
	WORD	mtrx_pz
	WORD	mtrx_pp

    LABEL    mtrx_sizeof


	; tri or quad
	STRUCTURE Pols3D,0
		UBYTE	pls_txt
		UBYTE	pls_Nbv	;3 or4
		UWORD	pls_v0 	; *12 ?
		UWORD	pls_v1
		UWORD	pls_v2
		UWORD	pls_v3
		; - -

	LABEL	pls_SIZEOF

		; simple objects
	STRUCTURE   obs3D,0
		UWORD	obs_NbV
		UWORD	obs_NbPols
		; vtx follow obj, then pols at +nbv*16
		;NO APTR	obs_Vtx	   ; _,x,y,z ->can do *8
		;NO APTR	obs_Pols
	LABEL	obs_SIZEOF

	; vertex source
	STRUCTURE   svtx,0
		WORD	vtx_x
		WORD	vtx_y
		WORD	vtx_z
	LABEL	vtx_SIZEOF


	; vertex in camera space & proj
	STRUCTURE   svtf,0
		WORD	vtf_cx	;cam pos
		WORD	vtf_cy
		WORD	vtf_cz
		WORD	vtf_px  ; movemable
		WORD	vtf_py
		UWORD	vtf_cb
		; z cam in vtp	;DO NOT CHANGE SIZEOF CAUSE OF INDEX TRICK
	LABEL	vtf_SIZEOF	; 12->



	; vertex in camera space & proj
	STRUCTURE   svtg,0
		WORD	vtg_px  ; movemable
		WORD	vtg_py
		UWORD	vtg_cb
		; z cam in vtp	;DO NOT CHANGE SIZEOF CAUSE OF INDEX TRICK
	LABEL	vtg_SIZEOF	; 12->



	; chained list for clipping
	STRUCTURE   PolyChainedListCell,0
	;removed prev...
		APTR	plc_prev
		APTR    plc_next
		APTR	plc_vertex ; -> Vertex3D.
	LABEL   plc_sizeof 	;12

	STRUCTURE	ExtraVertexCell,plc_sizeof
		STRUCT  plce_vinst,vtf_SIZEOF
		LABEL	plce_SIZEOF

	STRUCTURE	gExtraVertexCell,plc_sizeof
		STRUCT  plge_vinst,vtg_SIZEOF
		LABEL	plge_SIZEOF

	
	; poly compiled into world base, with shared vetx index
	STRUCTURE spolyc,0
		; - - const part
		UBYTE	polc_txt ;read
		UBYTE	polc_NbV ;read 3 or4 ->0,1
		UBYTE	polc_col ;writen
		UBYTE	polc_selected  ;writen
		UWORD   polc_maxy
		; - - updated part - reused as pointer also
		UWORD	polc_z	; used for z test
		UWORD	polc_cb ; 0=no clip need. clip check after sort
		;6b here
		; - -  -now have cells
		;;old UWORD	  polc_y1
		APTR	polc_cell	;ptr to current cell handle
		;10b
		STRUCT	polc_c0,plc_sizeof
		STRUCT	polc_c1,plc_sizeof
		STRUCT	polc_c2,plc_sizeof
		STRUCT	polc_c3,plc_sizeof
		;42 b
	LABEL	polc_SIZEOF  ;58

polc_upLeftCell		equ polc_z
polc_upRightCell    equ	polc_cell
;old polc_maxy			 equ polc_col

	STRUCTURE   objRef3D,0
		STRUCT	obr_mtx,mtrx_sizeof
		; pos
		WORD	obr_tx
		WORD	obr_ty
		WORD	obr_tz
		; rot
		WORD	obr_o1	;around axis Z
		WORD	obr_o2	;around axis X
		WORD	obr_o3	;around axis Y
		WORD	obr_distort

		APTR	obr_ref	; static read obj
		APTR	obr_vtx 	; original vtx in ref

		APTR	obr_vtf ; transformed vt
		APTR	obr_vtfEnd ; to test loop
		APTR	obr_pols ;
		; - - 3 movemed
		APTR    obr_plnrm 	  ;poly norm in ref
		APTR	obr_polc ; polyc
		APTR	obr_polcEnd
		APTR	obr_next
	LABEL	obr_SIZEOF

	; struct in table for z-sorting
	STRUCTURE sSortCell,0
		APTR	stp_polc
		WORD	stp_z	; z of poly...
	LABEL	stp_SIZEOF

	; to manage whole scene,cam and clipping...
	STRUCTURE	scn3d,0
		ULONG	scn_fov

;		 LONG    scn_fovx
;		 LONG    scn_fovy
		LONG    scn_centerx
		LONG    scn_centery

		APTR    scn_lightBM

		; - - - projection stuffs

;		 ULONG   scn_pofClipX1
;		 ULONG   scn_pofClipY1
;		 ULONG   scn_pofClipX2
;		 ULONG   scn_pofClipY2

;		 ULONG   scn_fovDivClipX1
;		 ULONG   scn_fovDivClipX1_inv
;		 ULONG   scn_fovDivClipY1
;		 ULONG   scn_fovDivClipY1_inv
;		 ULONG   scn_fovDivClipX2
;		 ULONG   scn_fovDivClipX2_inv
;		 ULONG   scn_fovDivClipY2
;		 ULONG   scn_fovDivClipY2_inv
;		 LONG    scn_lastfovcomputed

		; - - -  -
		UWORD   scn_OoFarClip	;scn_OoClipFar|scn_FarClip movemed
		UWORD	scn_FarClip
		UWORD	scn_TotalNbPols
		APTR	scn_PolcsBase	; final polygons
		; to projected vertex:
		APTR	scn_mainvtf

		; -  - -
		APTR	scn_obj	; obr root

		; - -renderbuffers
		APTR	scn_ClipCellStart

		; - - sort buffers also used for clipping
		;UWORD	 scn_NbPolsNoClip
		;UWORD	 scn_NbPolsClipScreen
		;UWORD	 scn_NbPolsClipNearFar

		; 3.l MOVEMABLE !!!
		APTR	scn_polyTab1	; scn_TotalNbPols*4
		APTR	scn_polyTab2    ; scn_TotalNbPols*4
		APTR	scn_polyTab3    ; scn_TotalNbPols*4

		; 3.l MOVEMABLE !!!
		;Polytable selected end
		APTR	scn_polyTab1Se
		APTR	scn_polyTab2Se
		APTR	scn_polyTab3Se

	LABEL	scn_SIZEOF

scn_polyClipNone	equ scn_polyTab1
scn_polyClipScreen	equ scn_polyTab2
scn_polyClipNearFar	equ scn_polyTab3

scn_polyClipNoneSe	  equ scn_polyTab1Se
scn_polyClipScreenSe  equ scn_polyTab2Se
scn_polyClipNearFarSe equ scn_polyTab3Se


;------ version with its vertex to be inited,for clipping stack:
; STRUCTURE ClippingCell,0
;	 STRUCT  clcp_cell,pclc_sizeof
;	 STRUCT  clcp_vertex,vert_sizeof
;	 LABEL   clcp_sizeof

; - - without UV version
; STRUCTURE   PolyChainedListCell2,0
;	 APTR    pcl_prev   ; PolyChainedListCell *
;	 APTR    pcl_next
;	 APTR    pcl_vertex ; -> Vertex3D.
;	 LABEL   pcl_sizeof ;20 ?

; STRUCTURE ClippingCell2,0
;	 STRUCT  clc_cell,pcl_sizeof
;	 STRUCT  clc_vertex,vert_sizeof
;	 LABEL   clc_sizeof
;

