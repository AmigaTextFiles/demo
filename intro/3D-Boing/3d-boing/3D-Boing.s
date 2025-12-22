		opt	d+

		include	my_begin.s
		include	intuition/intuition.i
		include	graphics/rastport.i
		include	graphics/view.i
		include	"devices/audio.i"

Sin6:		=	$D61304E		;Sin(6)*65536*32768
Cos6:		=	$7F4C7E54		;Cos(6)*65536*32768
Sin45:		=	$5A82799A		;Sin(45)*65536*32768
Cos45:		=	Sin45

WaitTime:	=	24

TriangleNumber:	=	8

BeginIO:        =	-30

;—мещени€ переменных
X1:		=	0
Y1:		=	4
Z1:		=	8
X2:		=	12
Y2:		=	16
Z2:		=	20
X3:		=	24
Y3:		=	28
Z3:		=	32

Sy1:		=	0
Sx1:		=	2
Sy2:		=	4
Sx2:		=	6
Sy3:		=	8
Sx3:		=	10
dX1:		=	12
dY1:		=	14
dZ1:		=	16
dX2:		=	18
dY2:		=	20
dZ2:		=	22
nX:		=	24
nY:		=	26
nZ:		=	28
X1c:		=	30
Y1c:		=	32
Z1c:		=	34
X2c:		=	36
Y2c:		=	38
Z2c:		=	40
X3c:		=	42
Y3c:		=	44
Z3c:		=	46


Start:
;		CALLEXE	Forbid
		moveq	#40,d0			;ќткрытие graphics.library
		lea	GfxName(pc),a1
		CALLEXE	OpenLibrary
		move.l	d0,GfxBase
		beq	Exit0

		moveq	#0,d0			;ќткрытие intuition.library
		lea	IntName(pc),a1
		CALLEXE	OpenLibrary
		move.l	d0,IntBase
		beq	Exit1

		sub.l	a0,a0
		lea	ScreenDefs(pc),a1
		CALLINT OpenScreenTagList
		move.l	d0,ScreenHd
		beq	Exit2

		sub.l	a0,a0
		lea	WindowDefs(pc),a1
		CALLINT OpenWindowTagList
		move.l	d0,WindowHd
		beq	Exit3

		move.l	d0,a0
		lea	PointerData,a1		;спрайт указател€ мыши
		moveq	#1,d0			;высота
		moveq	#16,d1			;ширина
		moveq	#0,d2			;смещение по X
		moveq	#0,d3			;смещение по Y
		CALLINT	SetPointer		;гасим указатель мыши
		move.l	WindowHd,a0
		move.l	wd_RPort(a0),RstPort
		CALLINT	ViewPortAddress
		move.l	d0,a0
PalGen:
		lea	MyPalette,a1
		lea	4(a1),a2
		moveq	#7,d1			;d1=$07000000
		ror.l	#8,d1
		moveq	#0,d2			;d2=$00000000
		moveq	#1,d3
		ror.l	#8,d3			;d3=$01000000
		move.l	d3,(a1)
		lsl.l	#3,d3			;d3=$08000000

		moveq	#30,d0
		move.l	d2,(a2)+
		move.l	d2,(a2)+
		move.l	d2,(a2)+
		move.l	d1,d4
PalGen0:
		move.l	d4,(a2)+		;32 оттенка белого (0 - 31)
		move.l	d4,(a2)+
		move.l	d4,(a2)+
		add.l	d3,d4
		dbra	d0,PalGen0

		moveq	#30,d0
		move.l	d2,(a2)+
		move.l	d2,(a2)+
		move.l	d2,(a2)+
		move.l	d1,d4
PalGen1:
		move.l	d4,(a2)+		;32 оттенка красного (32 - 63)
		move.l	d2,(a2)+
		move.l	d2,(a2)+
		add.l	d3,d4
		dbra	d0,PalGen1

		lsr.l	#1,d1			;d1=$03800000
		lsr.l	#1,d3			;d3=$04000000
		moveq	#62,d0
		moveq	#0,d5
		sub.l	d3,d5
		move.l	d2,(a2)+
		move.l	d2,(a2)+
		move.l	d5,(a2)+
		move.l	d1,d4
PalGen2:
		sub.l	d3,d5			;64 оттенка зелено-синего (64 - 127)
		move.l	d2,(a2)+
		move.l	d4,(a2)+
		move.l	d5,(a2)+
		add.l	d3,d4
		dbra	d0,PalGen2

		moveq	#62,d0
		sub.l	d3,d5
		move.l	d2,(a2)+
		move.l	d5,(a2)+
		move.l	d2,(a2)+
		move.l	d1,d4
PalGen3:
		sub.l	d3,d5			;64 оттенка красно-зеленого (128 - 191)
		move.l	d4,(a2)+
		move.l	d5,(a2)+
		move.l	d2,(a2)+
		add.l	d3,d4
		dbra	d0,PalGen3

		moveq	#62,d0
		sub.l	d3,d5
		move.l	d5,(a2)+
		move.l	d2,(a2)+
		move.l	d2,(a2)+
		move.l	d1,d4
PalGen4:
		sub.l	d3,d5			;64 оттенка  cине-красного (192 - 255)
		move.l	d5,(a2)+
		move.l	d2,(a2)+
		move.l	d4,(a2)+
		add.l	d3,d4
		dbra	d0,PalGen4

		CALLGFX LoadRGB32

		bsr	C2P

CoordsGen:
		lea	Coords,a0
		lea	Colours,a1
		lea	Data2(pc),a2
		lea	Data3(pc),a3
		moveq	#TriangleNumber-1,d7
CoordsGen4:
		moveq	#8,d6
CoordsGen5:
		move.w	(a2)+,(a0)+
		addq.l	#2,a0
		dbra	d6,CoordsGen5
		move.b	(a3)+,(a1)+
		dbra	d7,CoordsGen4

		moveq	#7,d7
CoordsGen0:
		lea	Data0(pc),a2
		lea	Data1(pc),a3
		moveq	#27,d6
CoordsGen1:
		moveq	#8,d5
CoordsGen2:
		move.l	(a2)+,(a0)+
		dbra.w	d5,CoordsGen2
		move.b	(a3)+,(a1)+
		dbra	d6,CoordsGen1
		lea	Data0(pc),a2
		move.l	#Sin45,d0		;поворот сектора
		move.l	#Cos45,d1
		move.w	#3*28-1,d6
CoordsGen3:
		bsr	TurnPoint
		addq.l	#6,a2
		addq.l	#6,a2
		dbra	d6,CoordsGen3
		
		dbra	d7,CoordsGen0

		moveq	#0,d0
		moveq	#0,d1
		move.w	#319,d2
		move.w	#199,d3
		lea	Plasma,a0		;создаем плазму
		bsr	PlasmaGen
		lea	Buffer,a1
		move.w	#200*80-1,d0
Plasma0:
		add.l	#$40404040,(a0)+
		dbra	d0,Plasma0

		CALLEXE	CreateMsgPort
		move.l	d0,MsgPort
		beq	Exit4
		move.l	d0,a0
		moveq.l	#ioa_SIZEOF,d0
		CALLEXE	CreateIORequest
		move.l	d0,IORequest
		beq	Exit5
		move.l	d0,a1
		moveq	#0,d0
		moveq	#0,d1
		lea	DeviceName(pc),a0
		move.w	d0,ioa_AllocKey(a1)
		move.l	#AChanels,ioa_Data(a1)
		moveq	#1,d7
		move.l	d7,ioa_Length(a1)
		CALLEXE	OpenDevice		;открываем audio.device
		bne	Exit6
Title:
		moveq	#31,d7
Title0:
		lea	Buffer,a0
		lea	GfxData,a1
		lea	Plasma,a2
		moveq	#10,d0
Title1:
		moveq	#0,d1
Title2:
		move.l	d0,d2
		divu.w	#10,d2
		move.l	d1,d3
		divu.w	#10,d3
		move.l	-4(a1,d2.w*4),d2
		btst	d3,d2
		beq.s	Title4
		move.l	d0,d2
		mulu.w	#320,d2
		add.l	d1,d2
		move.b	(a0,d2.l),d3
		bne.s	Title3
		moveq	#$40,d3
Title3:
		cmp.b	(a2,d2.l),d3
		bcc.s	Title4
		addq.b	#6,d3
		move.b	d3,(a0,d2.l)
Title4:
		addq.l	#1,d1
		cmp.w	#320,d1
		bcs.s	Title2
		addq.l	#1,d0
		cmp.w	#190,d0
		bcs.s	Title1
		CALLGFX	WaitTOF
		bsr	C2P
		dbra	d7,Title0		

		moveq	#127,d7
Wait:
		CALLGFX	WaitTOF
		dbra	d7,Wait

		bsr	Sound

		move.w	#2999,d7
		lea	SinCosTable,a5
IntroLoop:
		move.l	WindowHd,a0
		move.l	wd_UserPort(a0),a0
		CALLEXE	GetMsg
		tst.l	d0
		bne	Exit

		lea	Buffer,a0		;фон
		lea	Plasma,a1
		move.w	#200*80-1,d6
Background:
		move.l	(a1)+,(a0)+
		dbra	d6,Background

		lea	MyVars,a0
		lea	Coords,a2
		lea	Colours,a6
Walls:
		moveq	#TriangleNumber-1,d6
Walls0:
		bsr	CameraTurn		;смещение камеры
		bsr	TriangleWalls		;отображение полигона
		add.l	#36,a2
		addq.l	#1,a6
		dbra	d6,Walls0
Sphere:
		move.w	#223,d6
IntroLoop0:
		bsr	CameraTurn		;смещение камеры

		move.w	(a5),d4			;поворот вектора смещени€
		move.w	2(a5),d5
		move.w	dY(pc),d1
		muls.w	d4,d1			;d1=dY*Sim(alfa)/2
		move.w	dZ(pc),d2
		muls.w	d5,d2			;d2=dZ*Cos(alfa)/2
		sub.l	d1,d2
		add.l	d2,d2
		swap.w	d2			;dZ'=2*(d2-d1)
		move.w	dY(pc),d0
		muls.w	d5,d0			;d0=dY*Cos(alfa)/2
		move.w	dZ(Pc),d1
		muls.w	d4,d1			;d1=dZ*Sin(alfa)/2
		add.l	d0,d1
		add.l	d1,d1
		swap.w	d1			;dY'=2*(d1+d0)
		move.w	dX(pc),d0		;смещение полигона
		add.w	d0,X1c(a0)		;X1c=X1c+dX
		add.w	d0,X2c(a0)		;X2c=X2c+dX
		add.w	d0,X3c(a0)		;X3c=X3c+dX
		add.w	d1,Y1c(a0)		;Y1c=Y1c+dY
		add.w	d1,Y2c(a0)		;Y2c=Y2c+dY
		add.w	d1,Y3c(a0)		;Y3c=Y3c+dY
		add.w	d2,Z1c(a0)		;Z1c=Z1c+dZ
		add.w	d2,Z2c(a0)		;Z2c=Z2c+dZ
		add.w	d2,Z3c(a0)		;Z3c=Z3c+dZ

		bsr	TriangleSphere		;отображение полигона

		move.l	#Sin6,d0		;поворот полигона
		move.l	#Cos6,d1
		moveq	#2,d5
IntroLoop1:
		bsr	TurnPoint
		addq.l	#6,a2
		addq.l	#6,a2
		dbra	d5,IntroLoop1
		addq.l	#1,a6
		dbra	d6,IntroLoop0
CalcCoords:
		lea	dX(pc),a0
		move.w	(a0),d0
		add.w	6(a0),d0		;dX=dX+ddX
		cmp.w	#80,d0
		bpl.s	CalcCoords0
		cmp.w	#-80,d0
		bpl.s	CalcCoords1
CalcCoords0:
		neg.w	6(a0)			;ddX=-ddX
		move.w	(a0),d0
		add.w	6(a0),d0
		add.w	6(a0),d0
		bsr	Sound
CalcCoords1:
		move.w	d0,(a0)
		move.w	2(a0),d0
		add.w	8(a0),d0		;dY=dY+ddY
		cmp.w	#16,d0
		bpl.s	CalcCoords2
		cmp.w	#-16,d0
		bpl.s	CalcCoords3
CalcCoords2:
		neg.w	8(a0)			;ddY=-ddY
		move.w	2(a0),d0
		add.w	8(a0),d0
		add.w	8(a0),d0
		bsr	Sound
CalcCoords3:
		move.w	d0,2(a0)
		move.w	4(a0),d0
		add.w	10(a0),d0		;dZ=dZ+ddZ
		cmp.w	#240,d0
		bpl.s	CalcCoords4
		cmp.w	#16,d0
		bpl.s	CalcCoords5
CalcCoords4:
		neg.w	10(a0)			;ddZ=-ddZ
		move.w	4(a0),d0
		add.w	10(a0),d0
		add.w	10(a0),d0
		bsr	Sound
CalcCoords5:
		move.w	d0,4(a0)

		CALLGFX	WaitTOF
		bsr	C2P

		add.w	SinCosOffset,a5
		cmp.w	#$8000,(a5)
		bne.s	Offset
		neg.w	SinCosOffset
		add.w	SinCosOffset,a5
Offset:
		dbra	d7,IntroLoop
Exit:
		move.l	IORequest,a1
		CALLEXE	CloseDevice
Exit6:
		move.l	IORequest,a0
		CALLEXE	DeleteIORequest
Exit5:
		move.l	MsgPort,a0
		CALLEXE	DeleteMsgPort
Exit4:
		move.l	WindowHd,a0
		CALLINT CloseWindow
Exit3:
		move.l	ScreenHd,a0
		CALLINT	CloseScreen
Exit2:
		move.l	IntBase,a1
		CALLEXE	CloseLibrary
Exit1:
		move.l	GfxBase,a1
		CALLEXE	CloseLibrary
Exit0:
;		CALLEXE	Permit
		rts
C2P:
		move.l	RstPort,a0
		moveq	#0,d0
		moveq	#0,d1
		move.l	#320,d2
		move.l	#200,d3
		move.l	d2,d4
		lea	Buffer,a2
		move.l	GfxBase,a6
		jmp	_LVOWriteChunkyPixels(a6)
Sound:
		lea	$dff000,a1
		move.w	#3,$96(a1)		;выключаем каналы 1 и 2
		bsr	SoundWait
		move.l	#Sample,d1
		move.l	d1,$a0(a1)
		move.l	d1,$b0(a1)
		move.w	#SLength/2,d1
		move.w	d1,$a4(a1)
		move.w	d1,$b4(a1)
		move.w	#3424,d1
		move.w	d1,$a6(a1)
		move.w	d1,$b6(a1)
		moveq	#64,d1
		move.w	d1,$a8(a1)
		move.w	d1,$b8(a1)
		move.w	#$8203,$96(a1)		;включаем каналы 1 и 2
		bsr	SoundWait
		move.l	#PointerData+4,d1
		move.l	d1,$a0(a1)
		move.l	d1,$b0(a1)
		moveq	#1,d1
		move.w	d1,$a4(a1)
		move.w	d1,$b4(a1)
		rts
SoundWait:
		move.b	6(a1),d1
		moveq	#WaitTime,d3
SoundWait0:
		move.b	6(a1),d2
		cmp.b	d2,d1
		beq.s	SoundWait0
		move.b	d2,d1
		dbra	d3,SoundWait0
		rts
PlasmaGen:
;d0=X1
;d1=Y1
;d2=X2
;d3=Y2
;d5 - код цвета дл€ угловых точек
;(a0) - указатель на буфер плазмы
		move.w	d2,d4
		sub.w	d0,d4
		subq.w	#2,d4
		bcc.s	PlasmaGen0		;X2-X1<2?
		move.w	d3,d4
		sub.w	d1,d4
		subq.w	#2,d4
		bcs	EndPlasmaGen		;Y2-Y1<2?
PlasmaGen0:
		move.w	d0,d4
		add.w	d2,d4
		lsr.w	#1,d4			;Xm=(X1+X2)/2
		move.w	d1,d5
		add.w	d3,d5
		lsr.w	#1,d5			;Ym=(Y1+Y2)/2

		move.w	d4,d6			;Xm
		move.w	d1,d7			;Y1
		bsr	GetPixel
		bne.s	PlasmaGen1
		move.w	d1,d7
		bsr	WritePixel
PlasmaGen1:
		move.w	d0,d6			;X1
		move.w	d5,d7			;Ym
		bsr	GetPixel
		bne.s	PlasmaGen2
		move.w	d5,d7
		bsr	WritePixel
PlasmaGen2:
		move.w	d2,d6			;X2
		move.w	d5,d7			;Ym
		bsr	GetPixel
		bne.s	PlasmaGen3
		move.w	d5,d7
		bsr	WritePixel
PlasmaGen3:
		move.w	d4,d6			;Xm
		move.w	d3,d7			;Y2
		bsr	GetPixel
		bne.s	PlasmaGen4
		move.w	d3,d7
		bsr	WritePixel
PlasmaGen4:
		move.w	d4,d6			;Xm
		move.w	d5,d7			;Ym
		bsr	WritePixel

		movem.l	d0-d5,-(sp)
		move.w	d4,d2
		move.w	d5,d3
		bsr	PlasmaGen		;X1,Y1,Xm,Ym
		movem.l	(sp)+,d0-d5

		movem.l	d0-d5,-(sp)
		move.w	d4,d0
		move.w	d5,d3
		bsr	PlasmaGen		;Xm,Y1,X2,Ym
		movem.l	(sp)+,d0-d5

		movem.l	d0-d5,-(sp)
		move.w	d4,d2
		move.w	d5,d1
		bsr	PlasmaGen		;X1,Ym,Xm,Y2
		movem.l	(sp)+,d0-d5

		movem.l	d0-d5,-(sp)
		move.w	d4,d0
		move.w	d5,d1
		bsr	PlasmaGen		;Xm,Ym,X2,Y2
		movem.l	(sp)+,d0-d5
EndPlasmaGen:
		rts
GetPixel:
;d6=X
;d7=Y
;(a0) - указатель на буфер плазмы
		move.l	a0,a1
		mulu.w	#320,d7
		add.l	d7,a1
		add.w	d6,a1
		moveq	#0,d7
		move.b	(a1),d7
		rts
WritePixel:
;d0=X1
;d1=Y1
;d2=X2
;d3=Y2
;d6=X
;d7=Y
;(a0) - указатель на буфер плазмы
		movem.l	d2-d7,-(sp)
		move.w	d6,a2
		move.w	d7,a3

		move.w	d3,d4
		sub.w	d1,d4
		move.w	d2,d5
		sub.w	d0,d5
		add.w	d5,d4			;d4=Y2-Y1+X2-X1

		move.w	d0,d6
		move.w	d1,d7
		bsr	GetPixel		;X1,Y1
		move.w	d7,d5
		move.w	d3,d7
		bsr	GetPixel		;X1,Y2
		add.w	d7,d5
		move.w	d2,d6
		move.w	d3,d7
		bsr	GetPixel		;X2,Y2
		add.w	d7,d5
		move.w	d1,d7
		bsr	GetPixel		;X2,Y1
		add.w	d7,d5			;d5=Color(X1,Y1)+Color(X2,Y1)+
						;+Color(X2,Y2)+Color(X1,Y2)
		move.w	Random(pc),d6
		mulu.w	#31421,d6
		add.w	#6927,d6
		move.w	d6,Random		;псевдослучайна€ величина
		bmi.s	WritePixel0		;Random=Random*31421+6927
		sub.w	d4,d5
		bra.s	WritePixel1
WritePixel0:
		add.w	d4,d5
WritePixel1:
		lsr.w	#2,d5			;d5=(d5+sgn(Random)*d4)/4
		cmp.w	#192,d5
		bcs.s	WritePixel3
		move.w	#191,d5
WritePixel3:
		move.l	a0,a1
		move.w	a3,d7
		mulu.w	#320,d7
		add.l	d7,a1
		add.l	a2,a1
		move.b	d5,(a1)
		movem.l	(sp)+,d2-d7
		rts
TurnPoint:
;d0=Sin(alfa)
;d1=Cos(alfa)
;(a2) - указатель на структуру с координатами вершин и кодом цвета
		move.l	X1(a2),d2
		moveq	#0,d3
		muls.l	d1,d3:d2		;d3=X*cos(alfa)/2
		move.l	Z1(a2),d4
		moveq	#0,d2
		muls.l	d0,d2:d4		;d2=Z*sin(alfa)/2
		sub.l	d2,d3
		add.l	d3,d3			;X'=2*(d3-d2)
		move.l	d3,a3

		move.l	X1(a2),d2
		moveq	#0,d3
		muls.l	d0,d3:d2		;d3=X*sin(alfa)/2
		move.l	Z1(a2),d4
		moveq	#0,d2
		muls.l	d1,d2:d4		;d2=Z*cos(alfa)/2
		add.l	d3,d2
		add.l	d2,d2			;Z'=2*(d3+d2)
		move.l	d2,Z1(a2)
		move.l	a3,X1(a2)
		rts
CameraTurn:
;(a0) - указатель на область хранени€ переменных
;(a2) - указатель на структуру с координатами вершин и кодом цвета
;Dist=256
		move.w	(a5),d0			;поворот камеры
		move.w	2(a5),d1
		move.w	Y1(a2),d2
		muls.w	d0,d2			;d2=Y1*Sim(alfa)/2
		move.w	Z1(a2),d3
		muls.w	d1,d3			;d3=Z1*Cos(alfa)/2
		sub.l	d2,d3
		add.l	d3,d3
		swap.w	d3
		move.w	d3,Z1c(a0)		;Z1c=2*(d3-d2)
		move.w	Y1(a2),d2
		muls.w	d1,d2			;d2=Y1*Cos(alfa)/2
		move.w	Z1(a2),d3
		muls.w	d0,d3			;d3=Z1*Sin(alfa)/2
		add.l	d2,d3
		add.l	d3,d3
		swap.w	d3
		move.w	d3,Y1c(a0)		;Y1c=2*(d3+d2)
		move.w	Y2(a2),d2
		muls.w	d0,d2			;d2=Y2*Sim(alfa)/2
		move.w	Z2(a2),d3
		muls.w	d1,d3			;d3=Z2*Cos(alfa)/2
		sub.l	d2,d3
		add.l	d3,d3
		swap.w	d3
		move.w	d3,Z2c(a0)		;Z2c=2*(d3-d2)
		move.w	Y2(a2),d2
		muls.w	d1,d2			;d2=Y2*Cos(alfa)/2
		move.w	Z2(a2),d3
		muls.w	d0,d3			;d3=Z2*Sin(alfa)/2
		add.l	d2,d3
		add.l	d3,d3
		swap.w	d3
		move.w	d3,Y2c(a0)		;Y2c=2*(d3+d3)
		move.w	Y3(a2),d2
		muls.w	d0,d2			;d2=Y3*Sim(alfa)/2
		move.w	Z3(a2),d3
		muls.w	d1,d3			;d3=Z3*Cos(alfa)/2
		sub.l	d2,d3
		add.l	d3,d3
		swap.w	d3
		move.w	d3,Z3c(a0)		;Z3c=2*(d3-d2)
		move.w	Y3(a2),d2
		muls.w	d1,d2			;d2=Y3*Cos(alfa)/2
		move.w	Z3(a2),d3
		muls.w	d0,d3			;d3=Z3*Sin(alfa)/2
		add.l	d2,d3
		add.l	d3,d3
		swap.w	d3
		move.w	d3,Y3c(a0)		;Y3c=2*(d3+d3)
		move.w	X1(a2),X1c(a0)		;X1c=X1
		move.w	X2(a2),X2c(a0)		;X2c=X2
		move.w	X3(a2),X3c(a0)		;X3c=X3
		rts
TriangleSphere:		
;(a0) - указатель на область хранени€ переменных
;(a2) - указатель на структуру с координатами вершин и кодом цвета
;Dist=256
		move.w	X2c(a0),d0		;провер€ем видимость
		sub.w	X1c(a0),d0
		move.w	d0,dX1(a0)		;dX1=X2c-X1c
		move.w	X3c(a0),d0
		sub.w	X1c(a0),d0
		move.w	d0,dX2(a0)		;dX2=X3c-X1c
		move.w	Y2c(a0),d0
		sub.w	Y1c(a0),d0		
		move.w	d0,dY1(a0)		;dY1=Y2c-Y1c
		move.w	Y3c(a0),d0
		sub.w	Y1c(a0),d0
		move.w	d0,dY2(a0)		;dY2=Y3c-Y1c
		move.w	Z2c(a0),d0
		sub.w	Z1c(a0),d0
		move.w	d0,dZ1(a0)		;dZ1=Z2c-Z1c
		move.w	Z3c(a0),d0
		sub.w	Z1c(a0),d0
		move.w	d0,dZ2(a0)		;dZ2=Z3c-Z1c
		muls.w	dY1(a0),d0		;вектор нормали
		move.w	dZ1(a0),d3		;как векторное произведение
		muls.w	dY2(a0),d3
		sub.w	d3,d0
		move.w	d0,nX(a0)		;nX=dZ2*dY1-dZ1*dY2
		move.w	dZ1(a0),d1
		muls.w	dX2(a0),d1
		move.w	dX1(a0),d3
		muls.w	dZ2(a0),d3
		sub.w	d3,d1
		move.w	d1,nY(a0)		;nY=dZ1*dX2-dZ2*dX1
		move.w	dX1(a0),d2
		muls.w	dY2(a0),d2
		move.w	dY1(a0),d3
		muls.w	dX2(a0),d3
		sub.w	d3,d2
		move.w	d2,nZ(a0)		;nZ=dX1*dY2-dX2*dY1
		move.w	Z1c(a0),d3
		add.w	#256,d3
		muls.w	d3,d2
		muls.w	Y1c(a0),d1
		add.l	d2,d1
		muls.w	X1c(a0),d0
		add.l	d1,d0			;(Z1+256)*nZ+Y1*nY+X1*nX<=0 ???
		bgt	Triangle6		;если нет, то невидимый
TriangleWalls:
;(a0) - указатель на область хранени€ переменных
;(a2) - указатель на структуру с координатами вершин и кодом цвета
;Dist=256
		move.l	d7,a3			;сохран€ем регистры
		move.l	d6,a4

		move.w	#$ffff,d7		;преобразовани€ 3D->2D
		move.w	Z1c(a0),d6
		add.w	#256,d6
		move.w	X1c(a0),d1
		and.l	d7,d1
		ext.l	d1
		lsl.l	#8,d1
		divs.w	d6,d1
		add.w	#160,d1			;Sx1=160+256*X1c/(Z1c+256)
		move.w	Y1c(a0),d0
		and.l	d7,d0
		ext.l	d0
		lsl.l	#8,d0
		divs.w	d6,d0
		sub.w	#100,d0
		neg.w	d0			;Sy1=100-256*Y1c/(Z1c+256)
		move.	Z2c(a0),d6
		add.w	#256,d6
		move.w	X2c(a0),d3
		and.l	d7,d3
		ext.l	d3
		lsl.l	#8,d3
		divs.w	d6,d3
		add.w	#160,d3			;Sx2=160+256*X2c/(Z2c+256)
		move.w	Y2c(a0),d2
		and.l	d7,d2
		ext.l	d2
		lsl.l	#8,d2
		divs.w	d6,d2
		sub.w	#100,d2
		neg.w	d2			;Sy2=100-256*Y2c/(Zc+256)
		move.	Z3c(a0),d6
		add.w	#256,d6
		move.w	X3c(a0),d5
		and.l	d7,d5
		ext.l	d5
		lsl.l	#8,d5
		divs.w	d6,d5
		add.w	#160,d5			;Sx3=160+256*X3c/(Z3c+256)
		move.w	Y3c(a0),d4
		and.l	d7,d4
		ext.l	d4
		lsl.l	#8,d4
		divs.w	d6,d4
		sub.w	#100,d4
		neg.w	d4			;Sy3=100-256*Y3c/(Z3c+256)

		move.b	(a6),d6			;освещенность
;d0=Sy1,d1=Sx1
;d2=Sy2,d3=Sx2
;d4=Sy3,d5=Sx3
		cmp.w	d0,d2			;—ортируем по Y
		bpl.s	Triangle0
		exg.l	d0,d2
		exg.l	d1,d3
Triangle0:
		cmp.w	d0,d4
		bpl.s	Triangle1
		exg.l	d0,d4
		exg.l	d1,d5
Triangle1:
		cmp.w	d2,d4
		bpl.s	Triangle2
		exg.l	d4,d2
		exg.l	d5,d3
Triangle2:
		move.w	d0,Sy1(a0)		;—охран€ем с MinY по MaxY
		move.w	d1,Sx1(a0)
		move.w	d2,Sy2(a0)
		move.w	d3,Sx2(a0)
		move.w	d4,Sy3(a0)
		move.w	d5,Sx3(a0)
		cmp.w	d0,d4
		beq	Triangle5
Triangle3:					;¬ерхн€€ часть треугольника
		move.w	d0,d2			;Ѕольша€ сторона
		sub.w	Sy1(a0),d2
		move.w	d5,d3
		sub.w	Sx1(a0),d3
		muls.w	d3,d2
		move.w	d4,d3
		sub.w	Sy1(a0),d3
		divs.w	d3,d2
		add.w	Sx1(a0),d2

		move.w	d0,d1			;ћеньша€ сторона 1
		sub.w	Sy1(a0),d1
		move.w	Sx2(a0),d3
		sub.w	Sx1(a0),d3
		muls.w	d3,d1
		move.w	Sy2(a0),d3
		sub.w	Sy1(a0),d3
		beq.s	Triangle4
		divs.w	d3,d1
		add.w	Sx1(a0),d1

		bsr	Line
		addq.w	#1,d0
		cmp.w	Sy2(a0),d0
		bne.s	Triangle3
Triangle4:					;Ќижн€€ часть треугольника
		move.w	d0,d2			;Ѕольша€ сторона
		sub.w	Sy1(a0),d2
		move.w	d5,d3
		sub.w	Sx1(a0),d3
		muls.w	d3,d2
		move.w	d4,d3
		sub.w	Sy1(a0),d3
		divs.w	d3,d2
		add.w	Sx1(a0),d2

		move.w	d0,d1			;ћеньша€ сторона 2
		sub.w	Sy2(a0),d1
		move.w	Sx3(a0),d3
		sub.w	Sx2(a0),d3
		muls.w	d3,d1
		move.w	Sy3(a0),d3
		sub.w	Sy2(a0),d3
		beq.s	Triangle5
		divs.w	d3,d1
		add.w	Sx2(a0),d1

		bsr	Line
		addq.w	#1,d0
		cmp.w	Sy3(a0),d0
		ble.s	Triangle4
Triangle5:
		move.l	a4,d6			;восстанавливаем регистры
		move.l	a3,d7
Triangle6:
		rts
Line:
;d1=X1, d2=X2
;d0=Y,d6=Colour
		cmp.w	d1,d2
		bpl.s	Line0
		exg.l	d1,d2
Line0:
		lea	Buffer,a1
		move.w	d0,d3
		mulu.w	#320,d3
		add.l	d3,a1
		add.w	d1,a1
		sub.w	d1,d2
Line1:
		move.b	d6,(a1)+
		dbra	d2,Line1
		rts

		GFXNAME
		INTNAME
DeviceName:	AUDIONAME
AChanels:	dc.b	$f
		even
ScreenDefs:
		dc.l	SA_Width,320
		dc.l	SA_Height,200
		dc.l	SA_Depth,8
		dc.l	SA_DisplayID,0
		dc.l	0,0
WindowDefs:
;		dc.l	WA_Top,11
;		dc.l	WA_Height,189
		dc.l	WA_Height,200
		dc.l	WA_Width,320
		dc.l	WA_Activate,1
		dc.l	WA_IDCMP,8
		dc.l	WA_CustomScreen
ScreenHd:	dc.l	0
		dc.l	0,0
dX:		dc.w	0
dY:		dc.w	0
dZ:		dc.w	16
ddX:		dc.w	1
ddY:		dc.w	1
ddZ:		dc.w	1
Random:		dc.w	0

Data0:
		incbin	SphereCoords

Data1:		dc.b	31,63,63,31,31,63,63,26,26,53,53,16,16,43
		dc.b	63,31,31,63,63,31,31,58,58,21,21,48,48,11

Data2:
		dc.w	-128,64,-32,-128,64,288,-128,-64,288
		dc.w	-128,-64,-32,-128,64,-32,-128,-64,288
		dc.w	-128,-64,-32,-128,-64,288,128,-64,288
		dc.w	-128,-64,-32,128,-64,288,128,-64,-32
		dc.w	-128,-64,288,-128,64,288,128,64,288
		dc.w	-128,-64,288,128,64,288,128,-64,288
		dc.w	128,-64,-32,128,-64,288,128,64,288
		dc.w	128,-64,-32,128,64,288,128,64,-32
Data3:
		dc.b	64,64,128,128,96,96,224,224
GfxData:
		dc.l	%00000000001111100111111000000000
		dc.l	%00000000011001100110011000000000
		dc.l	%00000000011001100011000000000000
		dc.l	%00000000011001100011100000000000
		dc.l	%00000000011001100110000000000000
		dc.l	%00000000011001100110011000000000
		dc.l	%00000000001111100011110000000000
		dc.l	%00000000000000000000000000000000
		dc.l	%00000000000000000000000000000000
		dc.l	%00000000000000011000000000111110
		dc.l	%00000000000000000000000001100110
		dc.l	%01111100011111011001111001100110
		dc.l	%01100110110011011011001100111110
		dc.l	%01100110110011011011001101100110
		dc.l	%01100110110011011011001101100110
		dc.l	%01111100110011011001111000111110
		dc.l	%01100000000000000000000000000000
		dc.l	%00111100000000000000000000000000

SinCosBegin:	dc.w	$8000,$8000
SinCosTable:	incbin	"SinCosTable"		;Sin(alfa)*32767,Cos(alfa)*32767
SinCosEnd:	dc.w	$8000

SinCosOffset:
		dc.w	4

		section	MousePointer,DATA_C
PointerData:	dc.w	0,0,0,0,0,0
Sample:		incbin	"boom"			;698
Sample0:
SLength:	=	Sample0-Sample

		section	data,BSS
Buffer:		ds.b	320*200
Plasma:		ds.b	320*200
GfxBase:	ds.l	1
IntBase:	ds.l	1
WindowHd:	ds.l	1
RstPort:	ds.l	1
MsgPort:        ds.l	1
IORequest:      ds.l	1
OldIntVector:	ds.l	1
MyVars:		ds.b	1024
MyPalette:	ds.b	3080
Coords:		ds.l	(224+TriangleNumber)*9
Colours:	ds.b	224+TriangleNumber
