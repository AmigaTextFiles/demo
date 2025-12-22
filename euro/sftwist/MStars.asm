*  StarFields for MSHOW



****************************************************************************
* Symbol Definitions
*
MINBOX		equ	-450
MAXBOX		equ	450
BOXRANGE	equ	MAXBOX-MINBOX+1

NSTARS		equ	70		; Must be even

MAGIC		equ	(256<<8)
ZPULL		equ	780

****************************************************************************
* Welcome to the actual stars code.
*

*****  extern WORD far scrwide;
*****  extern WORD far scrhigh;
*****  extern WORD far delta_x;
*****  extern WORD far delta_y;
*****  extern WORD far delta_z;
*****  extern WORD far spin_x;
*****  extern WORD far spin_y;
*****  extern WORD far spin_z;
*****  extern WORD far CenterX;
*****  extern WORD far CenterY;
*****  extern PLANEPTR far Plane1ptr;
*****  extern PLANEPTR far Plane2ptr;
*****  UWORD StarColors[]={0,0x558,0x88B,0xFFF};


	CODE,PUBLIC
	xdef @StarOffsets
	xdef _ComputeStarField
	xdef _DisplayStarField
*****    VOID __regargs StarOffsets(ULONG mod_d0);
*****    VOID ComputeStarField();
*****    VOID DisplayStarField();

	xdef	_scrwide
	xdef	_scrhigh
	xdef	_delta_x
	xdef	_delta_y
	xdef	_delta_z
	xdef	_spin_x
	xdef	_spin_y
	xdef	_spin_z
	xdef	_CenterX
	xdef	_CenterY
	xdef	_Plane1ptr
	xdef	_Plane2ptr

@StarOffsets   ; Computes 480 screen offsets
	move.l	d2,-(sp)

	move.l	#199,d2
	lea		YOffTable,a0
	moveq.l	#0,d1

1$	move.l	d1,(a0)+
	add.l	d0,d1
	dbra		d2,1$

	move.l	(sp)+,d2
	rts

_ComputeStarField
	movem.l	d2-d7/a2-a6,-(SP)
	bsr		AddSpins
	bsr		GenMat
	bsr		Transform
	bsr.s	MoveStars
	movem.l	(SP)+,d2-d7/a2-a6
	rts

_DisplayStarField
	movem.l	d2-d7/a2-a6,-(SP)
	bsr.s	EraseStars
	;	bsr		DrawStars	;Fall thru to this routine
	movem.l	(SP)+,d2-d7/a2-a6
	rts

****************************************************************************
* Move the stars
*
MoveStars	lea		XCoords(pc),a0
		lea		YCoords(pc),a1
		lea		ZCoords(pc),a2
		move.w	_delta_x(pc),d0
		move.w	_delta_y(pc),d1
		move.w	_delta_z(pc),d2
		move.w	#BOXRANGE,d4
		moveq	#NSTARS-1,d7

0$		move.w	(a0),d3
		add.w	d0,d3		; Add move delta
		cmp.w	#MAXBOX,d3	; Too big?
		bgt.s	1$
		cmp.w	#MINBOX,d3	; Too small?
		bge.s	2$
		add.w	d4,d3		; Wrap up
		bra.s	2$
1$		sub.w	d4,d3		; Wrap down
2$		move.w	d3,(a0)+

		move.w	(a1),d3
		add.w	d1,d3
		cmp.w	#MAXBOX,d3
		bgt.s	11$
		cmp.w	#MINBOX,d3
		bge.s	22$
		add.w	d4,d3
		bra.s	22$
11$		sub.w	d4,d3
22$		move.w	d3,(a1)+

		move.w	(a2),d3
		add.w	d2,d3
		cmp.w	#MAXBOX,d3
		bgt.s	111$
		cmp.w	#MINBOX,d3
		bge.s	222$
		add.w	d4,d3
		bra.s	222$
111$		sub.w	d4,d3
222$		move.w	d3,(a2)+

		dbra	d7,0$

		rts


****************************************************************************
* Star rendering routines.
*
* This too has undergone a re-write since 1.0.  A BSET instruction is now
* used to plot the star directly into the bitmap.  The Y-offset into the
* bitmap is now fetched from a pre-computed table to save on a multiply.
* A change to the in-memory representation of the projected points saved
* a few cycles in memory fetches.  Further, rendering is now done with bytes
* rather than words (since BSETs to memory are only byte-wide); any loss on
* higher-order processors is made up for by the faster clock.
*
* EraseStars underwent a kooky change since it appears to be the blocking
* factor for clean rendering on a 68000.  Getting even faster would mean
* major towering, which falls under the law of diminshing returns.
*
EraseStars
		moveq	#0,d0
		move.l	_Plane1ptr(pc),a1
		move.l	_Plane2ptr(pc),a2
		lea		PlaneOffsets,a4
		moveq	#(NSTARS>>1)-1,d7	; As the programmer :-), I
					;  guarantee the count will be even

1$		move.l	(a4)+,d1	; Grab two offsets
		move.b	d0,0(a1,d1.l)	; Blast entire byte
		move.b	d0,0(a2,d1.l)
		move.l	(a4)+,d1
		move.b	d0,0(a1,d1.l)	; Blast entire byte
		move.b	d0,0(a2,d1.l)
		dbra	d7,1$

DrawStars	lea		TransformBuff,a0	; Coords in YXZ order
		lea		YOffTable,a1
		lea		PlaneOffsets,a3
		move.l	_Plane1ptr(pc),a2
		move.l	_Plane2ptr(pc),a4
		moveq	#NSTARS-1,d7
		move.w	_scrhigh(pc),d4
		move.w	_scrwide(pc),d5
NextDraw	move.w	(a0)+,d1	; Load and check Y value
		bmi.s	clipped_y
		cmp.w	d4,d1
		bge.s	clipped_y

		move.w	(a0)+,d0	; Load and check X value
		bmi.s	clipped_x
		cmp.w	d5,d0
		bge.s	clipped_x

		moveq.l	#0,d2
		move.w	d0,d2
		not.w	d0		; Invert X for BSET bit positon
		lsr.l	#3,d2		; Compute byte offset in line
		lsl.l	#2,d1
		move.l	0(a1,d1.w),d1	; Get Y offset from table
		add.l	d1,d2
		move.l	d2,(a3)+	; Store computed offset
		move.w	(a0)+,d6	; Load Z
		cmp.w	#-176,d6	; Z closer than this?
		ble.s	1$		; No, draw just plane 1 (dim)

		bset		d0,0(a4,d2.l)	; This plane definitely gets written
		cmp.w	#130,d6		; Very close?
		ble.s	2$		; No
1$		bset		d0,0(a2,d2.l)	;    Yes; draw brightest value
2$
		dbra		d7,NextDraw

		rts

clipped_y	addq.w	#2,a0		; Skip unread x
clipped_x	addq.w	#2,a0		; Skip unread z
		clr.l	(a3)+
		dbra		d7,NextDraw

		rts


****************************************************************************
* This is the biggie.
*
* This has been completely re-written, and where the biggest speed gains
* were realized.  It used to be three discrete rotations.  Now it's a full
* matrix operation.
*
* The source XYZ values are loaded into D0-D2.  The resulting XYZ values are
* left in D3-D5.  The matrix is stored in column-major ZYX order.  This is
* done to facilitate early rejection of Z values behind the camera (though
* I don't yet make use of that).
*
* The matrix elements are in 2.14 bit fixed-point notation.  The numbers in
* the coordinate array are straight integers.
*
Transform	lea		XCoords(pc),a0
		lea		YCoords(pc),a1
		lea		ZCoords(pc),a2
		lea		TransformBuff,a4
		moveq	#NSTARS-1,d7
		move.l	#MAGIC,d6
		move.w	#ZPULL,a5	; Being used for storage

	;------	Load vertex and matrix.
NextStar	move.w	(a0)+,d0	; Fetch X, Y, and Z
		move.w	(a1)+,d1
		move.w	(a2)+,d2
		lea		Matrix(pc),a3	; Fetch matrix

	;------	Multiply vertex through matrix.
	;------	First column is Z.
		move.w	d0,d5		; X
		muls		(a3)+,d5	;   * *mat++
		move.w	d1,d4		; Y
		muls		(a3)+,d4	;   * *mat++
		add.l	d4,d5		;		Accumulate to D5
		move.w	d2,d4		; Z
		muls		(a3)+,d4	;   * *mat++
		add.l	d4,d5		;		Accumulate to D5
		swap		d5
		rol.l	#2,d5		; D5 >>= 14;

	;------	Second column is Y.
		move.w	d0,d4		; X
		muls		(a3)+,d4	;   * *mat++
		move.w	d1,d3		; Y
		muls		(a3)+,d3	;   * *mat++
		add.l	d3,d4		;		Accumulate to D4
		move.w	d2,d3		; Z
		muls		(a3)+,d3	;   * *mat++
		add.l	d3,d4		;		Accumulate to D4
		swap		d4
		rol.l	#2,d4		; D4 >>= 14;

	;------	Third column is X.
		move.w	d0,d3		; X
		muls		(a3)+,d3	;   * *mat++
		move.w	d1,d0		; Y (original X no longer needed)
		muls		(a3)+,d0	;   * *mat++
		add.l	d0,d3		;		Accumulate to D3
		move.w	d2,d0		; Z
		muls		(a3)+,d0	;   * *mat++
		add.l	d0,d3		;		Accumulate to D3
		swap		d3
		rol.l	#2,d3		; D3 >>= 14;

****************
* Here is performed the perspective projection.
*
* Normally, this is accomplished by dividing both X and Y by the Z
* coordinate.  However, in this case, only one division is performed to
* calculate a fixed-point scaling factor, which is then multiplied by the
* X and Y values.  This is done because multiplication is cheaper than
* division.  The perspective scalar is:
*
*	    MAGIC
*	-------------
*	- (Z - ZPULL)
*
* The subtraction from Z is to "pull" the stars away from the camera (which
* is at Z == 0) so that they'll be visible.  The negation effectively flips
* the Z axis, which makes the calculation easier (trust me).  MAGIC and
* ZPULL are currently set to 256 and 780 respectively.  The 256 is a number
* I pulled out of Thin Air.  (So's the 780, for that matter...)  Feel free
* to play with them to see what happens.
*
* The projected points are stored in YXZ order.
*
	;------	Compute scalar.
		move.l	d6,d0		; MAGIC
		move.w	a5,d1		; ZPULL
		sub.w	d5,d1		;	- Z
		ble.s	BehindCamera
		divu		d1,d0		; == 256 / (ZPULL - Z)
		bvs.s	BehindCamera	; Shunt wild division

	;------	Multiply scalar by X and Y components.
		move.w	d4,d1		; Y
		muls		d0,d1		;   * 256 / (ZPULL - Z)
		lsr.l	#8,d1		; (Unavoidable.  Ack!)
          lsr.l     #1,d1
		add.w	_CenterY(pc),d1
		move.w	d1,(a4)+	; Y store

		move.w	d3,d1		; X
		muls		d0,d1		;   * 256 / (ZPULL - Z)
		lsr.l	#8,d1
		add.w	_CenterX(pc),d1
		move.w	d1,(a4)+	; X store

		move.w	d5,(a4)+	; Z store (for pixel brightness)

		dbra		d7,NextStar

		rts

	;------	Whoops!  Behind the camera.  Force an invisible point.
BehindCamera
		moveq	#-1,d1
		move.l	d1,(a4)+	; X and Y store
		move.w	d5,(a4)+	; Z store
		dbra		d7,NextStar

		rts



****************************************************************************
* Generate a matrix.
*
* This routine generates a three-rotation matrix all at once, in ZYX order.
* Rotations are anti-clockwise.
*
GenMat	move.w	theta_z(pc),d0	; Collect sines and cosines
		bsr		SinCos
		move.w	d0,d4		; sinZ
		move.w	d1,d5		; cosZ
		move.w	theta_y(pc),d0
		bsr		SinCos
		move.w	d0,d2		; sinY
		move.w	d1,d3		; cosY
		move.w	theta_x(pc),d0
		bsr		SinCos

		lea	Matrix(pc),a0	; Point at matrix

	;------	Compute first column Z.
	;------	sinX * sinZ - cosX * sinY * cosZ
		move.w	d0,d7		; sinX
		muls		d4,d7		;      * sinZ
		move.w	d1,d6		; cosX
		muls		d2,d6		;      * sinY
		swap		d6
		rol.l	#2,d6
		move.w	d6,a1		;		(Save for later)
		muls		d5,d6		; 	      * cosZ
		sub.l	d6,d7
		swap		d7
		rol.l	#2,d7		; D7 >>= 14
		move.w	d7,(a0)+	;			(Store)

	;------	sinX * cosZ + cosX * sinY * sinZ
		move.w	d0,d6		; sinX
		muls		d5,d6		;      * cosZ
		move.w	a1,d7		; cosX * sinY
		muls		d4,d7		;	      * sinZ
		add.l	d6,d7
		swap		d7
		rol.l	#2,d7
		move.w	d7,(a0)+	;			(Store)

	;------	cosX * cosY
		move.w	d1,d7		; cosX
		muls		d3,d7		;      * cosY
		swap		d7
		rol.l	#2,d7
		move.w	d7,(a0)+	;			(Store)

	;------	Compute second column Y.
	;------	cosX * sinZ + sinX * sinY * cosZ
		move.w	d1,d7		; cosX
		muls		d4,d7		;      * sinZ
		move.w	d0,d6		; sinX
		muls		d2,d6		;      * sinY
		swap		d6
		rol.l	#2,d6
		move.w	d6,a1		;		(Save for later)
		muls		d5,d6		;	      * cosZ
		add.l	d6,d7
		swap		d7
		rol.l	#2,d7
		move.w	d7,(a0)+	;			(Store)

	;------	cosX * cosZ - sinX * sinY * sinZ
		move.w	d1,d7		; cosX
		muls		d5,d7		;      * cosZ
		move.w	a1,d6		; sinX * sinY
		muls		d4,d6		;	      * sinZ
		sub.l	d6,d7
		swap		d7
		rol.l	#2,d7
		move.w	d7,(a0)+	;			(Store)

	;------	-sinX * cosY
		move.w	d0,d7		;  sinX
		neg.w	d7		; -
		muls		d3,d7		;	* cosY
		swap		d7
		rol.l	#2,d7
		move.w	d7,(a0)+	;			(Store)

	;------	Compute third column X.
	;------	cosY * cosZ
		move.w	d3,d7		; cosY
		muls		d5,d7		;      * cosZ
		swap		d7
		rol.l	#2,d7
		move.w	d7,(a0)+	;			(Store)

	;------	-cosY * sinZ
		move.w	d3,d7		;  cosY
		neg.w	d7		; -
		muls		d4,d7		;	* sinZ
		swap		d7
		rol.l	#2,d7
		move.w	d7,(a0)+	;			(Store)

	;------	sinY
		move.w	d2,(a0)+	;			(Store)

	;------	Phew!  We're outa here.
		rts


****************************************************************************
* Sine/Cosine calculator.  Nothing amazing here, just a table lookup.
*
* This got a lot more complicated for no good reason :-).  The sine/cosine
* table ranges from 0-90°.  The code selects the proper values and negates
* them based on the quadrant in which the angle lies.  2048 == 360 degrees.
* Sine table entries are represented using 14 bit fixed point fractions.
*
* Angle passed in D0.  May now be an odd number.
* Returns sine in D0, cosine in D1.
*
SinCos	move.w	d2,-(sp)

		add.w	d0,d0		; Word offset
		lea		SineTable(pc),a5
		move.w	d0,d2		; Copy
		and.w	#1024-1,d0	; Clip to 90°
		move.w	#1024,d1	; d0 == ang
		sub.w	d0,d1		; d1 == gna

		move.w	0(a5,d0.w),d0	; Fetch sine candidate
		move.w	0(a5,d1.w),d1	; Fetch cosine candidate

	;------	Determine which is sine and which is cosine.
		lsl.w	#5,d2		; Shift quadrant bits into Carry and
					;  Minus flags.
		bpl.s	1$		; First or third quadrant?
		exg		d0,d1		; Yes, exchange values
1$
	;------	Is sine negative?
		bcc.s	2$		; Third or fourth quadrants?
		neg.w	d0		; Yes, negate si(g)ne

	;------	Is cosine negative?  We test for this two ways, depending on
	;------	the result of the previous test.
		tst.w	d2		; Quadrant 3?
		bpl.s	88$		; Yes, negate cosine
		bra.s	99$

2$		tst.w	d2		; Quadrant 2?
		bpl.s	99$
88$		neg.w	d1		; Yes, negate cosine

99$		move.w	(sp)+,d2
		rts


****************************************************************************
* Add spins to current rotation angles.  Clip to 360° circle.
*
AddSpins	move.w	#2048-1,d1	; 360° == 2048 EHG
		lea	theta_x(pc),a0
		lea	_spin_x(pc),a1

		move.w	(a0),d0		; Get angle
		add.w	(a1)+,d0	; Add spin
		and.w	d1,d0		; Clip to 360°
		move.w	d0,(a0)+	; Store it back

		move.w	(a0),d0
		add.w	(a1)+,d0
		and.w	d1,d0
		move.w	d0,(a0)+

		move.w	(a0),d0
		add.w	(a1),d0
		and.w	d1,d0
		move.w	d0,(a0)

		rts

****************************************************************************
* Data!  (Yes, Captain?)
*
_delta_x	dc.w	10	; Star movement
_delta_y	dc.w	5
_delta_z	dc.w	2
theta_x	dc.w	0	; Initial/current rotation angles
theta_y	dc.w	0
theta_z	dc.w	0
_spin_x	dc.w	4	; Spin velocities
_spin_y	dc.w	5
_spin_z	dc.w	3

wrk_delta	dc.w	0,0,0	; Working areas for the parser
wrk_theta	dc.w	0,0,0
wrk_spin	dc.w	0,0,0

_scrwide	dc.w	320
_scrhigh	dc.w	200

CurrentSinCos
		dc.w	0	; theta_x
		dc.w	0
		dc.w	0	; theta_y
		dc.w	0
		dc.w	0	; theta_z
		dc.w	0
Matrix	dc.w	0,0,0,0,0,0,0,0,0
_CenterX	dc.w	160
_CenterY	dc.w	100
_Plane1ptr	dc.l	0
_Plane2ptr	dc.l	0

XCoords	dc.w	$FF37,$FED2,$6A,$FFF7,$C8,$CD,$FFF9,$132,$FF35
		dc.w	$FF9A,$FF7F,$16B,$EC,$FFF7,$186,$FF5A,$FF0D,$177
		dc.w	$FEAF,$6F,$FF5F,$FF22,$150,$2B,$FED5,$FEE3,$90,$AA
		dc.w	$FEBE,$13A,$12D,$FFA4,$FF49,$FEEE,$41,$164,$FF09
		dc.w	$8A,$FFE3,$D2,$FEBE,$13A,$12D,$FFA4,$FF49,$FEEE,$41
		dc.w	$164,$FF09,$8A,$FF46,$FF85,$154,$FF19,$60,$FF5C,$9B
		dc.w	$FFA8,$FF18,$158,$AE,$FF2F,$FE72,$21,$8C,$FE8B,$CF
		dc.w	$48,$FF7A,$137,$C8,$FED4
YCoords	dc.w	$FF5F,$FF22,$150,$2B,$FED5,$FEE3,$90,$AA,$FEBE,$13A
		dc.w	$12D,$FFA4,$FF49,$FEEE,$41,$164,$FF09,$8A,$FFE3,$D2
		dc.w	$FF37,$FED2,$6A,$FFF7,$C8,$CD,$FFF9,$132,$FF35
		dc.w	$FF9A,$FF7F,$16B,$EC,$FFF7,$186,$FF5A,$FF0D,$177
		dc.w	$FEAF,$6F,$177,$FEAF,$6F,$FF5F,$FF22,$150,$2B,$FED5
		dc.w	$FEE3,$90,$164,$FF09,$8A,$FFE3,$FF52,$FF2F,$18E,$21
		dc.w	$FF74,$FE8B,$CF,$FFB8,$86,$FEC9,$D2,$FF22,$94,$14D
		dc.w	$FE9B,$F4,$C8,$12C
ZCoords	dc.w	$FF52,$FF2F,$FE72,$21,$8C,$175,$FF31,$FFB8,$FF7A
		dc.w	$137,11,$153,$FF22,$94,$14D,$FE9B,$F4,$FEEC,$9B
		dc.w	$FF46,$FF85,$154,$FF19,$60,$FF5C,$9B,$FFA8,$FF18
		dc.w	$158,$FF61,$FE8F,$F8,$FEE7,$8C,$FF85,$48,$FEAC
		dc.w	$FF17,$6A,$13B,$FF01,$FF3A,$FFF9,7,$BE,$12B,$FED1
		dc.w	$FE94,$FC,$FF91,$CD,$FFF9,$132,$FF35,$FF9A,$FF7F
		dc.w	$16B,$EC,$FFF7,$186,$FED2,$6A,$FFF7,$C8,$CD,$FFF9
		dc.w	$132,$FF35,$FF9A,$FF7F,$96,$FF06


SineTable	dc.w	0,50,101,151,201,251,302,352
		dc.w	402,452,503,553,603,653,704,754
		dc.w	804,854,904,955,1005,1055,1105,1155
		dc.w	1205,1255,1306,1356,1406,1456,1506,1556
		dc.w	1606,1656,1706,1756,1806,1856,1906,1956
		dc.w	2006,2055,2105,2155,2205,2255,2305,2354
		dc.w	2404,2454,2503,2553,2603,2652,2702,2752
		dc.w	2801,2851,2900,2949,2999,3048,3098,3147
		dc.w	3196,3246,3295,3344,3393,3442,3492,3541
		dc.w	3590,3639,3688,3737,3786,3835,3883,3932
		dc.w	3981,4030,4078,4127,4176,4224,4273,4321
		dc.w	4370,4418,4467,4515,4563,4612,4660,4708
		dc.w	4756,4804,4852,4900,4948,4996,5044,5092
		dc.w	5139,5187,5235,5282,5330,5377,5425,5472
		dc.w	5520,5567,5614,5661,5708,5756,5803,5850
		dc.w	5897,5943,5990,6037,6084,6130,6177,6223
		dc.w	6270,6316,6363,6409,6455,6501,6547,6593
		dc.w	6639,6685,6731,6777,6823,6868,6914,6960
		dc.w	7005,7050,7096,7141,7186,7231,7276,7321
		dc.w	7366,7411,7456,7501,7545,7590,7635,7679
		dc.w	7723,7768,7812,7856,7900,7944,7988,8032
		dc.w	8076,8119,8163,8207,8250,8293,8337,8380
		dc.w	8423,8466,8509,8552,8595,8638,8680,8723
		dc.w	8765,8808,8850,8892,8935,8977,9019,9061
		dc.w	9102,9144,9186,9227,9269,9310,9352,9393
		dc.w	9434,9475,9516,9557,9598,9638,9679,9720
		dc.w	9760,9800,9841,9881,9921,9961,10001,10040
		dc.w	10080,10120,10159,10198,10238,10277,10316,10355
		dc.w	10394,10433,10471,10510,10549,10587,10625,10663
		dc.w	10702,10740,10778,10815,10853,10891,10928,10966
		dc.w	11003,11040,11077,11114,11151,11188,11224,11261
		dc.w	11297,11334,11370,11406,11442,11478,11514,11550
		dc.w	11585,11621,11656,11691,11727,11762,11797,11831
		dc.w	11866,11901,11935,11970,12004,12038,12072,12106
		dc.w	12140,12173,12207,12240,12274,12307,12340,12373
		dc.w	12406,12439,12472,12504,12537,12569,12601,12633
		dc.w	12665,12697,12729,12760,12792,12823,12854,12885
		dc.w	12916,12947,12978,13008,13039,13069,13100,13130
		dc.w	13160,13190,13219,13249,13279,13308,13337,13366
		dc.w	13395,13424,13453,13482,13510,13538,13567,13595
		dc.w	13623,13651,13678,13706,13733,13761,13788,13815
		dc.w	13842,13869,13896,13922,13949,13975,14001,14027
		dc.w	14053,14079,14104,14130,14155,14181,14206,14231
		dc.w	14256,14280,14305,14329,14354,14378,14402,14426
		dc.w	14449,14473,14497,14520,14543,14566,14589,14612
		dc.w	14635,14657,14680,14702,14724,14746,14768,14789
		dc.w	14811,14832,14854,14875,14896,14917,14937,14958
		dc.w	14978,14999,15019,15039,15059,15078,15098,15118
		dc.w	15137,15156,15175,15194,15213,15231,15250,15268
		dc.w	15286,15304,15322,15340,15357,15375,15392,15409
		dc.w	15426,15443,15460,15476,15493,15509,15525,15541
		dc.w	15557,15573,15588,15604,15619,15634,15649,15664
		dc.w	15679,15693,15707,15722,15736,15750,15763,15777
		dc.w	15791,15804,15817,15830,15843,15856,15868,15881
		dc.w	15893,15905,15917,15929,15941,15952,15964,15975
		dc.w	15986,15997,16008,16018,16029,16039,16049,16059
		dc.w	16069,16079,16088,16098,16107,16116,16125,16134
		dc.w	16143,16151,16160,16168,16176,16184,16192,16199
		dc.w	16207,16214,16221,16228,16235,16242,16248,16255
		dc.w	16261,16267,16273,16279,16284,16290,16295,16300
		dc.w	16305,16310,16315,16319,16324,16328,16332,16336
		dc.w	16340,16343,16347,16350,16353,16356,16359,16362
		dc.w	16364,16367,16369,16371,16373,16375,16376,16378
		dc.w	16379,16380,16381,16382,16383,16383,16384,16384
		dc.w	16384

		SECTION EuroStars,BSS
StartBSS:

TransformBuff	ds.w	NSTARS*3	; Written in YXZ order
PlaneOffsets	ds.l	NSTARS
YOffTable		ds.l 200

EndBSS:
		END
