	xdef	_rotateFaces__8MainPartFv
	xref	_cos__4Util
	xref	_sin__4Util
	xref	__CXM33
	xref	__CXD33

; Offsets to various C++ structures. These MUST match the C++ structures!
; -----------------------------------------------------------------------
partModel		equ	12
partFaces		equ	partModel+4
partRotatedCoordinates	equ	partFaces+4
partAngleX		equ	partRotatedCoordinates+4
partAngleY		equ	partAngleX+2
partAngleZ		equ	partAngleY+2
partDistance		equ	partAngleZ+2
partCenterX		equ	partDistance+2
partCenterY		equ	partCenterX+2
modelNumCoordinates	equ	0
modelNumFaces		equ	2
modelCoordinates	equ	4
modelFaces		equ	8
modelSizeOf		equ	12
faceDataFace		equ	0
faceDataNormal		equ	4
faceDataRotatedNormal	equ	12
faceDataZ		equ	18
faceDataVisible		equ	20
faceDataSizeOf		equ	22
faceVertices		equ	0
faceVertexOffsets	equ	2
xx			equ	0
xy			equ	2
xz			equ	4
yx			equ	6
yy			equ	8
yz			equ	10
zx			equ	12
zy			equ	14
zz			equ	16
xx_xy			equ	18
yx_yy			equ	22
zx_zy			equ	26
angleX			equ	30
angleY			equ	32
angleZ			equ	34
localsSizeOf		equ	36

	section code

_rotateFaces__8MainPartFv:
	movem.l	d2-d7/a2-a6,-(sp)
	lea	-localsSizeOf(sp),sp

	; Precalculate sin*cos constants; range +-$3fff
	; ---------------------------------------------
	move.w	partAngleX(a0),d0
	add.w	d0,d0
	move.w	d0,angleX(sp)
	move.w	partAngleY(a0),d0
	add.w	d0,d0
	move.w	d0,angleY(sp)
	move.w	partAngleZ(a0),d0
	add.w	d0,d0
	move.w	d0,angleZ(sp)
	lea	_sin__4Util(a4),a5
	move.l	_cos__4Util(a4),a6
	; xx = cos(ax)*cos(ay)
	; xy = sin(ax)*cos(ay)
	; xz = sin(ay)
	; ------------
	move.w	angleY(sp),d0
	move.w	angleX(sp),d3
	move.w	(a5,d0.w),d2
	move.w	(a6,d0.w),d0
	move.w	(a5,d3.w),d4
	move.w	(a6,d3.w),d3
	move.w	d0,d1
	muls	d3,d0
	swap	d0
	muls	d4,d1
	swap	d1
	asr.w	#1,d2
	move.w	d0,xx(sp)
	move.w	d1,xy(sp)
	move.w	d2,xz(sp)
	
	; yx = sin(ax)*cos(az) + cos(ax)*sin(ay)*sin(az)
	; yy = -cos(ax)*cos(az) + sin(ax)*sin(ay)*sin(az)
	; yz = -cos(ay)*sin(az)
	; ---------------------
	move.w	angleZ(sp),d0
	move.w	angleX(sp),d3
	move.w	angleY(sp),d5
	move.w	(a5,d0.w),d2
	move.w	(a6,d0.w),d0
	move.w	d0,d1
	move.w	(a6,d3.w),d4
	move.w	(a5,d3.w),d3
	move.w	(a6,d5.w),d5
	muls	d3,d0
	swap	d0
	muls	d4,d1
	swap	d1
	neg.w	d1
	muls	d5,d2
	swap	d2
	neg.w	d2
	move.w	angleY(sp),d3
	move.w	angleZ(sp),d4
	move.w	(a5,d3.w),d3
	move.w	(a5,d4.w),d4
	muls	d4,d3
	swap	d3
	add.w	d3,d3
	move.w	angleX(sp),d4
	move.w	angleX(sp),d5
	move.w	(a6,d4.w),d4
	move.w	(a5,d5.w),d5
	muls	d3,d4
	swap	d4
	muls	d3,d5
	swap	d5
	add.w	d4,d0
	add.w	d5,d1
	move.w	d0,yx(sp)
	move.w	d1,yy(sp)
	move.w	d2,yz(sp)

	; zx = sin(ax)*sin(az) - cos(ax)*sin(ay)*cos(az)
	; zy = -cos(ax)*sin(az) - sin(ax)*sin(ay)*cos(az)
	; zz = cos(ay)*cos(az)
	; --------------------
	move.w	angleZ(sp),d0
	move.w	angleX(sp),d3
	move.w	angleY(sp),d5
	move.w	(a6,d0.w),d2
	move.w	(a5,d0.w),d0
	move.w	d0,d1
	move.w	(a6,d3.w),d4
	move.w	(a5,d3.w),d3
	move.w	(a6,d5.w),d5
	muls	d3,d0
	swap	d0
	muls	d4,d1
	swap	d1
	neg.w	d1
	muls	d5,d2
	swap	d2
	move.w	angleY(sp),d3
	move.w	angleZ(sp),d4
	move.w	(a5,d3.w),d3
	move.w	(a6,d4.w),d4
	muls	d4,d3
	swap	d3
	add.w	d3,d3
	move.w	angleX(sp),d4
	move.w	angleX(sp),d5
	move.w	(a6,d4.w),d4
	move.w	(a5,d5.w),d5
	muls	d3,d4
	swap	d4
	muls	d3,d5
	swap	d5
	sub.w	d4,d0
	sub.w	d5,d1
	move.w	d0,zx(sp)
	move.w	d1,zy(sp)
	move.w	d2,zz(sp)

	; xxxy = xx*xy
	; yxyy = yx*yy
	; zxzy = zx*zy
	; ------------
	move.w	xx(sp),d0
	move.w	xy(sp),d1
	muls	d1,d0
	move.l	d0,xx_xy(sp)
	move.w	yx(sp),d0
	move.w	yy(sp),d1
	muls	d1,d0
	move.l	d0,yx_yy(sp)
	move.w	zx(sp),d0
	move.w	zy(sp),d1
	muls	d1,d0
	move.l	d0,zx_zy(sp)

	; Rotate coordinates
	; ------------------
	move.l	partModel(a0),a6
	move.l	modelCoordinates(a6),a1
	move.l	partRotatedCoordinates(a0),a2
	move.w	partDistance(a0),a3
	move.w	partCenterX(a0),a4
	move.w	partCenterY(a0),a5
	move.w	modelNumCoordinates(a6),d7
	subq	#1,d7
.coord:	move.w	(a1)+,d4
	move.w	(a1)+,d5
	move.w	(a1)+,d6
	move.w	(a1)+,d0
	ext.l	d0
	move.l	d0,a6

	; x' = (xx + y)(xy + x) + z*xz - (xxxy + x*y)
	; ------------------------------------------'
	move.w	d4,d0
	add.w	xy(sp),d0
	move.w	d5,d1
	add.w	xx(sp),d1
	muls	d1,d0
	move.w	d6,d1
	muls	xz(sp),d1
	add.l	d1,d0
	sub.l	xx_xy(sp),d0
	sub.l	a6,d0
	; y' = (yx + y)(yy + x) + z*yz - (yxyy + x*y)
	; ------------------------------------------'
	move.w	d4,d1
	add.w	yy(sp),d1
	move.w	d5,d2
	add.w	yx(sp),d2
	muls	d2,d1
	move.w	d6,d2
	muls	yz(sp),d2
	add.l	d2,d1
	sub.l	yx_yy(sp),d1
	sub.l	a6,d1
	; z' = (zx + y)(zy + x) + z*zz - (zxzy + x*y)
	; ------------------------------------------'
	move.w	d4,d2
	add.w	zy(sp),d2
	move.w	d5,d3
	add.w	zx(sp),d3
	muls	d3,d2
	move.w	d6,d3
	muls	zz(sp),d3
	add.l	d3,d2
	sub.l	zx_zy(sp),d2
	sub.l	a6,d2

	; Projection
	; ----------
	asr.l	#5,d0
	asr.l	#5,d1
	; Use #4 for a wider angle (or fish eye)
	; --------------------------------------
	asl.l	#3,d2
	swap	d2
	; Store Z coordinate
	; ------------------
	move.w	d2,4(a2)
	sub.w	a3,d2
	divs	d2,d0
	divs	d2,d1
	add.w	a4,d0
	add.w	a5,d1
	; Store projected X and Y
	; -----------------------
	move.w	d0,(a2)+
	move.w	d1,(a2)+
	addq	#2,a2
	dbra	d7,.coord

	; Rotate face normals
	; -------------------
	move.l	partModel(a0),a6
	move.l	partFaces(a0),a1
	lea	faceDataNormal(a1),a1
	move.w	modelNumFaces(a6),d7
	subq	#1,d7
.norml:	move.w	(a1)+,d4
	move.w	(a1)+,d5
	move.w	(a1)+,d6
	move.w	(a1)+,d0
	ext.l	d0
	move.l	d0,a6

	; x' = (xx + y)(xy + x) + z*xz - (xxxy + x*y)
	; ------------------------------------------'
	move.w	d4,d0
	add.w	xy(sp),d0
	move.w	d5,d1
	add.w	xx(sp),d1
	muls	d1,d0
	move.w	d6,d1
	muls	xz(sp),d1
	add.l	d1,d0
	sub.l	xx_xy(sp),d0
	sub.l	a6,d0
	; y' = (yx + y)(yy + x) + z*yz - (yxyy + x*y)
	; ------------------------------------------'
	move.w	d4,d1
	add.w	yy(sp),d1
	move.w	d5,d2
	add.w	yx(sp),d2
	muls	d2,d1
	move.w	d6,d2
	muls	yz(sp),d2
	add.l	d2,d1
	sub.l	yx_yy(sp),d1
	sub.l	a6,d1
	; z' = (zx + y)(zy + x) + z*zz - (zxzy + x*y)
	; ------------------------------------------'
	move.w	d4,d2
	add.w	zy(sp),d2
	move.w	d5,d3
	add.w	zx(sp),d3
	muls	d3,d2
	move.w	d6,d3
	muls	zz(sp),d3
	add.l	d3,d2
	sub.l	zx_zy(sp),d2
	sub.l	a6,d2

	add.l	d0,d0
	add.l	d0,d0
	add.l	d1,d1
	add.l	d1,d1
	add.l	d2,d2
	add.l	d2,d2
	swap	d0
	swap	d1
	swap	d2
	
	move.w	d0,(a1)+
	move.w	d1,(a1)+
	move.w	d2,(a1)+

	lea	(faceDataSizeOf-14)(a1),a1
	dbra	d7,.norml

	; Check out which faces are visible
	; ---------------------------------
	move.l	partModel(a0),a6
	move.l	partFaces(a0),a1
	move.l	partRotatedCoordinates(a0),a2
	move.w	modelNumFaces(a6),d7
	subq	#1,d7
.visib:	move.l	faceDataFace(a1),a3
	move.l	faceVertexOffsets(a3),a3
	move.w	(a3)+,a4
	add.w	a4,a4
	move.w	a4,d0
	add.w	a4,d0
	add.w	a4,d0
	move.w	(a2,d0.w),d1	;Rx1
	move.w	2(a2,d0.w),d2	;Ry1
	move.w	(a3)+,a4
	add.w	a4,a4
	move.w	a4,d0
	add.w	a4,d0
	add.w	a4,d0
	move.w	(a2,d0.w),d3	;Rx2
	move.w	2(a2,d0.w),d4	;Ry2
	move.w	(a3)+,a4
	add.w	a4,a4
	move.w	a4,d0
	add.w	a4,d0
	add.w	a4,d0
	move.w	(a2,d0.w),d5	;Rx3
	move.w	2(a2,d0.w),d6	;Ry3
	sub.w	d1,d3
	sub.w	d1,d5
	sub.w	d2,d4
	sub.w	d2,d6
	muls	d3,d6
	muls	d4,d5
	sub.w	d6,d5
	smi.b	faceDataVisible(a1)
	lea	faceDataSizeOf(a1),a1
	dbra	d7,.visib

	; Calculate face center z coordinates
	; -----------------------------------
;	move.l	partModel(a0),a6
;	move.l	partFaces(a0),a1
;	move.l	partRotatedCoordinates(a0),a2
;	lea	4(a2),a2
;	move.w	modelNumFaces(a6),d7
;	subq	#1,d7
;.calcz:	clr.w	faceDataZ(a1)
;	move.l	faceDataFace(a1),a3
;	move.w	faceVertices(a3),d6
;	move.l	faceVertexOffsets(a3),a3
;	subq	#1,d6
;.clzlp:	move.w	(a3)+,a4
;	add.w	a4,a4
;	move.w	a4,d0
;	add.w	a4,d0
;	add.w	a4,d0
;	move.w	(a2,d0.w),d0
;	add.w	d0,faceDataZ(a1)
;	dbra	d6,.clzlp
;	lea	faceDataSizeOf(a1),a1
;	dbra	d7,.calcz

	lea	localsSizeOf(sp),sp
	movem.l	(sp)+,d2-d7/a2-a6
	rts

	end
