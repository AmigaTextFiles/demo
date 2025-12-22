; darstellen eines Bildes mit Intuition Screen
; Abfrage der Maus und Textausgabe auf dem Screen

oldopenlib		=	-408	;Exec
closelib		=	-414
allocmem		=	-198
freemem			=	-210
Execbase		=	4
InitBitmap		=	-390	;GFX
LoadRGB32		=	-882
FreeRaster		=	-498
AllocRaster		=	-492
InitRastPort		=	-198
ReadPixel		=	-318
Move			=	-240
RectFill		=	-306
SetAPen			=	-342
SetBPen			=	-348
AText			=	-60
SetFont			=	-66
CloseFont		=	-78
Openscreen		=	-198	;INT
Closescreen		=	-66
read			=	-42	;DOS
open			=	-30
close			=	-36
delay			=	-198
OpenDiskFont		=	-30	;DF

MausX			=	70
MausY			=	68

	MC68020

start:
	move.l	execbase,a6		;libs ˆffnen
	lea	Intname,a1
	jsr	oldopenlib(a6)
	move.l	d0,Intbase

	lea	gfxname,a1
	jsr	oldopenlib(a6)
	move.l	d0,gfxBase

	lea	dosname,a1
	jsr	oldopenlib(a6)
	move.l	d0,dosbase

	lea	DFName,a1
	jsr	oldopenlib(a6)
	move.l	d0,dfbase


	move.l	gfxbase,a6		;Speicher f¸r Bild-Bitmap holen
	lea	BildBitmap,a0		;und in Bitmap eintragen
	move.l	#8,d7
	jsr	SR1

	lea	RasterBitMap,a0		;Speicher f¸r Raster-Bitmap holen
	move.l	#4,d7			;und in Bitmap eintragen
	jsr	SR1

	move.l	Execbase,a6		;Speicher f¸r Farben holen
	move.l	#3076,d0
	move.l	#$10004,d1
	jsr 	allocmem(a6)
	move.l	d0,farben

	move.l	dosbase,a6		;Bild datei ˆffnen
	lea	Bildname,a0
	move.l	a0,d1
	move.l	#1005,d2
	jsr	open(a6)

	move.l	farben,a0		;Anzahl der Farben und "Ab-Nr."
	move.w	#256,(a0)+		;in "Struktur" eintragen
	move.w	#0,(a0)+

	move.l	d0,Bildhandle		;Farben aus Datei einladen
	move.l	d0,d1
	move.l	a0,d2
	move.l	#3072,d3
	jsr	read(a6)

	lea	BildBitmap,a5		;Bild einladen und Datei schlieﬂen
	move.l	#7,d6
	move.l	Bildhandle,d7
	jsr	SR2

	lea	Rastername,a0		;Raster Datei ˆffnen
	move.l	a0,d1
	move.l	#1005,d2
	jsr	open(a6)
	move.l	d0,rasterhandle

	lea	RasterBitmap,a5		;Raster einladen und Datei schlieﬂen
 	move.l	#3,d6
	move.l	Rasterhandle,d7
	jsr	SR2

	move.l	gfxbase,a6
	lea	RasterRastPort,a1	;Rastport initialisieren
	jsr	InitRastPort(a6)

	lea	RasterRastPort,a0	;Bitmap in Rastport eintragen
	lea	rasterbitmap,a1
	move.l	a1,4(a0)	

	move.l	DFbase,a6		;Font ˆffnen
	lea	TextAttr,a0
	jsr	opendiskfont(a6)
	move.l	d0,TextFont

	move.l	intbase,a6		;Screen ˆffnen
	lea	newscreen,a0
	jsr	openscreen(a6)
	move.l	d0,screenhd

	add.l	#44,d0			;Farben einstellen
	move.l	gfxbase,a6
	move.l	farben,a1
	move.l	d0,a0
	jsr	loadrgb32(a6)

	move.l	screenhd,a1		;Font f¸r Screen einstellen
	add.l	#84,a1
	move.l	a1,BildRastport
	move.l	TextFont,a0
	jsr	SetFont(a6)

	move.l	BildRastport,a1		;Vordergrundfarbe einstellen
	move.l	#0,d0
	jsr	SetApen(a6)

	move.l	BildRastPort,a1		;Hintergrundfarbe einstellen
	move.l	#206,d0
	jsr	SetBPen(a6)


	moveq	#0,d7			;Mausposition auslesen
Maus:	move.l	gfxbase,a6
	move.l	Intbase,a0
	move.l	#0,d0
	move.l	#0,d1
	move.l	#0,d2
	move.w	MausX(a0),d0
	move.w	MausY(a0),d2
	divu	#2,d2
	move.w	d2,d1

	lea	rasterrastport,a1	;auslesen des farbtabnr.
	jsr	ReadPixel(a6)		;des Rasters

	cmp.l	d0,d7			;Hatten wir das Schon?
	beq	warten			;Wenn ja ->

	move.l	d0,d7			;F¸r n‰chste Pr¸fung
	subq	#2,d0			;Vorbereiten f¸r tabellensprung
	asl	#1,d0
	lea	Grˆﬂe,a0
	lea	0(a0,d0),a1
	move.w	(a1),d5
	swap	d5

	lea	X,a0
	lea	0(a0,d0),a1
	move.w	(a1),d5

	asl	#1,d0
	lea	Tabelle,a0
	move.l	0(a0,d0),a1
	move.l	a1,d6
	jsr	Text

warten:	move.l	dosbase,a6		;1/50 Sek. warten
	move.l	#1,d1
	jsr	delay(a6)

	btst	#6,$bfe001		;maustaste gedr¸ckt?
	bne	Maus			;wenn nein ->

	move.l	intbase,a6		;Screen schlieﬂen
	move.l	screenhd,a0
	jsr	closescreen(a6)

	move.l	execbase,a6		;Speicher f¸r Farben freigeben
	move.l	#3076,d0
	move.l	farben,a1
	jsr	freemem(a6)

	move.l	gfxbase,a6		;Speicher f¸r Bildbitmap freigeben
	lea	BildBitmap,a5
	move.l	#7,d7
	jsr	SR3

	lea	RasterBitmap,a5		;Speicher f¸r RasterBitmmap freig.
	move.l	#3,d7
	jsr	SR3

	move.l	TextFont,a1		;Font schlieﬂen
	jsr	closefont(a6)

	move.l	execbase,a6		;libs schlieﬂen
	move.l	intbase,a1
	jsr	closelib(a6)

	move.l	gfxbase,a1
	jsr	closelib(a6)

	move.l	dosbase,a1
	jsr	closelib(a6)

	move.l	dfbase,a1
	jsr	closelib(a6)

	move.l	#0,d0
	rts


;Subroutinen:

;Bitmap initialisieren + Speicher holen

;Startadresse der Bitmap -> a0
;Anzahl Bitplanes	 -> d7
;GFXBase		 -> a6

SR1:	move.l	a0,a5			;Bitmap initialisieren
	addq	#8,a5
	move.l	d7,d0
	move.l	#640,d1
	move.l	#256,d2
	jsr	InitBitmap(a6)

	subq	#1,d7
loop:	move.l	#640,d0			;Speicher f¸r Bitplane holen
	move.l	#256,d1
	jsr	allocraster(a6)
	move.l	d0,(a5)+
	dbra	d7,loop

	rts


;Planes in Bitmap laden + Datei schlieﬂen

;Startadresse der Bitmap	-> a5
;Anzahl der Planes-1		-> d6
;dateihandle			-> d7
;dosbase			-> a6

SR2:	addq	#8,a5

loop2:	move.l	d7,d1			;Bitplane lesen
	move.l	(a5),d2
	move.l	#20480,d3
	jsr	read(a6) 

	addq	#4,a5
	dbra	d6,loop2

	move.l	d7,d1			;Datei schlieﬂen
	jsr	close(a6)

	rts


;Speicher f¸r Bitplanes freigeben

;Startadresse der Bitmap	-> a5
;Anzahl der Planes-1		-> d7
;GfxBase			-> a6

SR3:	addq	#8,a5

loop3:	move.l	(a5),a0			;Speicher f¸r Plane freigeben
	move.l	#640,d0
	move.l	#256,d1
	jsr	freeraster(a6)

	addq	#4,a5
	dbra	d7,loop3

	rts


;Zeichnet ein weiﬂes Rechteck in "Info Box"

;gfxbase			-> a6

SR4:	move.l	BildRastPort,a1		;Vordergrundfarbe auf "weiﬂ" ‰ndern
	move.l	#206,d0
	jsr	SetApen(a6)
	
	move.l	BildRastPort,a1		;Rechteck zeichnen
	move.l	#343,d0
	move.l	#1,d1
	move.l	#636,d2
	move.l	#23,d3
	jsr	rectfill(a6)

	move.l	#0,d0			;Vordergrundfarbe auf "schwarz"
	move.l	Bildrastport,a1
	jsr	setapen(a6)

	rts


;Gibt angegebenen Text in "Info Box" aus

;Startadresse des Textes	-> d6
;L‰nge des Textes		-> oberes Wort von d5
;Position des Stiftes		-> unteres Wort von d5
;GfxBase			-> a6

Text:	jsr	SR4			;erst mal weiﬂ malen

	move.l	BildRastPort,a1		;Zeichenstift in Pos. bringen
	moveq	#0,d0
	move.w	d5,d0
	move.l	#18,d1
	jsr	move(a6)

	swap	d5
	move.l	BildRastport,a1
	move.l	d6,a0
	move.l	#0,d0
	move.w	d5,d0
	jsr	AText(a6)

	rts	


;Datenbereich

	SECTION "Datenbereich",DATA,Fast

		even
intname:	dc.b	"intuition.library",0
		even
intbase:	dc.l	0
gfxname:	dc.b	"graphics.library",0
		even
gfxbase:	dc.l	0
dosname:	dc.b	"dos.library",0
		even
dosbase:	dc.l	0
DFname:		dc.b	"diskfont.library",0
		even
dfbase:		dc.l	0
BildBitmap:	ds.b	40,0
RasterBitmap:	ds.b	40,0
Farben:		dc.l	0
Bildname:	dc.b	"Bild2.raw",0
		even
Bildhandle:	dc.l	0
Rastername:	dc.b	"Bild-Raster.raw",0
		even
Rasterhandle:	dc.l	0
RasterRastPort:	ds.b	100,0
TextAttr:	dc.l	Fontname
		dc.w	20
		dc.b	0
		dc.b	3
		even
FontName:	dc.b	"CGTimes.font",0
		even
TextFont:	dc.l	0
newscreen:	dc.w	0,0,640,256
		dc.w	8
		dc.b	0,1
		dc.w	$8000
		dc.w	$14f
		dc.l	0,0,0
		dc.l	BildBitmap
		even
screenhd:	dc.l	0
BildRastPort:	dc.l	0
Tabelle:	dc.l	Text2,0,Text4,Text5,Text6,Text7,Text8
		dc.l	Text9,Text10,Text11,0,Text13,Text14
Text2:		dc.b	" "
		even
Text4:		dc.b	"Photonentorpedoabschuﬂrampe"
		even
Text5:		dc.b	"mittlere Andockklammer"
		even
Text6:		dc.b	"groﬂe Andockklammer"
		even
Text7:		dc.b	"kleine Andockklammer"
		even
Text8:		dc.b	"Stern"
		even
Text9:		dc.b	"‰uﬂerer Habitatring"
		even
Text10:		dc.b	"OPS"
		even
Text11:		dc.b	"Pylon"
		even
Text13:		dc.b	"innerer Habitatring"
		even
Text14:		dc.b	"Promenadendeck"
		even
X:		dc.w	489,0,366,392,399,399,468,411,473,467,0,413,422
Grˆﬂe:		dc.w	1,0,27,22,19,20,5,19,3,5,0,19,14

		END
					
