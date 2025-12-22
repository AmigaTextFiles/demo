;APSFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
; Legionary's Cracktro Setup 2016 (Oldsk00l Crackers)
; For executable file.

		Section	'OldSk00l Crackers',Code_c

		Incdir	'Dh0:OldSk00l Crackers/'

Start		Movem.l	d0-a6,-(a7)
		Lea	Prog,a0
		Move.l	a0,$80
		Trap	#0
		Movem.l	(a7)+,d0-a6
		Moveq	#0,d0
		Rts

Prog		Move.l	$4.W,a6
		Lea	Gfxname,a1
		Moveq	#33,d0
		Jsr	-552(a6)
		Lea	Gfxbase,a1
		Move.l	d0,(a1)
		Move.l	Gfxbase,a1
		Jsr	-414(a6)
		Move.l	Gfxbase,a6
		Lea	Oldview,a0
		Lea	Oldcop,a1
		Move.l	34(a6),(a0)
		Move.l	38(a6),(a1)
		Sub.l	a1,a1
		Jsr	-222(a6)		; Loadview
		Jsr	-270(a6)		; WaitTOF
		Jsr	-270(a6)		; WaitTOF
		Move.l	#Copper,$dff080
		Move.w	#$DEAD,$dff088
		Move.w	#$c00,$dff106
		Move.w	#0,$dff1fc
		Move.w	#$11,$dff10c
		Lea	Bplpointers,a0
		Move.l	#Screen,d0
		Moveq	#4,d7

Setallplanes	Move.w	d0,6(a0)
		Swap	d0
		Move.w	d0,2(a0)
		Swap	d0
		Addq.w	#8,a0
		Add.l	#10240,d0
		Dbf	d7,Setallplanes
		Lea	Sprpointers,a0
		Move.l	Sprite,d0
		Moveq	#7,d7

Setallsprites	Move.w	d0,6(a0)
		Swap	d0
		Move.w	d0,2(a0)
		Swap	d0
		Addq.w	#8,a0
		Dbf	d7,Setallsprites
		Move.w	$dff002,OldDma
		Move.w	$dff010,OldAdk
		Move.w	$dff01c,OldInta
		Move.w	#$7fff,$dff09a
		Move.w	#$7fff,$dff096
		Move.l	$6c,OldInt
		Moveq	#1,d0
		Jsr	DeltaMod
		Moveq	#2,d0
		Move.b	#63,d1
		Jsr	DeltaMod
		Move.l	#MusicInt,$6c
		Move.w	#$7fff,$dff09c
		Move.w	#$83f0,$dff096
		Move.w	#$c020,$dff09a
		Bsr	ShowBackground
		Bsr	ShowCoderLogo
		Bsr	ShowOSCLogo

Main		Cmp.b	#$ff,$dff006
		Bne	Main
Sync		Cmp.b	#$1f,$dff006
		Bne	Sync
		Bsr	TextWriter
		Btst	#6,$bfe001
		Bne	Main

		Move.b	#63,d7
		Moveq	#2,d0
		Move.b	#0,d1
		Jsr	DeltaMod
		Move.w	#$7fff,$dff09a
		Move.w	#$7fff,$dff096
		Move.l	Oldint,$6c
		Move.w	OldDma,d0
		Or.w	#$8000,d0
		Move.w	d0,$dff096
		Move.w	OldAdk,d0
		Or.w	#$8000,d0
		Move.w	d0,$dff09e
		Move.w	Oldinta,d0
		Or.w	#$c000,d0
		Move.w	#$7fff,$dff09c
		Move.w	d0,$dff09a
		Move.l	Gfxbase,a6
		Move.l	Oldview,a1
		Jsr	-222(a6)		; Loadview
		Jsr	-270(a6)		; WaitTOF
		Jsr	-270(a6)		; WaitTOF
		Move.l	Oldcop,$dff080
		Rte

MusicInt	Movem.l	d0-a6,-(a7)
		Move.w	#$20,$dff09c
		Moveq	#0,d0
		Jsr	DeltaMod
		Movem.l	(a7)+,d0-a6
		Rte

Bltw		Btst	#14,$dff002
Bltw2		Btst	#14,$dff002
		Bne	Bltw2
		Rts

ShowBackground	Lea	Background,a0
		Lea	Screen+40*17,a1
		Moveq	#3,d7

NextPlane	Bsr	Bltw
		Movem.l	a0/a1,$dff050
		Move.l	#0,$dff064
		Move.l	#$9f00000,$dff040
		Move.l	#-1,$dff044
		Move.w	#214*64+20,$dff058
		Lea	40*214(a0),a0
		Lea	40*256(a1),a1
		Dbf	d7,NextPlane
		Rts

ShowCoderLogo	Lea	LegionaryLogo,a0
		Lea	Screen+40*233+34,a1 ;234
		Moveq	#3,d7

NextPlane2	Bsr	Bltw
		Movem.l	a0/a1,$dff050
		Move.l	#34,$dff064
		Move.l	#$9f00000,$dff040
		Move.l	#-1,$dff044
		Move.w	#4*64+3,$dff058
		Lea	6*4(a0),a0
		Lea	40*256(a1),a1
		Dbf	d7,NextPlane2
		Rts

ShowOSCLogo	Lea	OSCLogo,a0
		Lea	Screen+6,a1
		Moveq	#2,d7

NextPlane3	Bsr	Bltw
		Movem.l	a0/a1,$dff050
		Move.l	#12,$dff064
		Move.l	#$9f00000,$dff040
		Move.l	#-1,$dff044
		Move.w	#16*64+14,$dff058
		Lea	28*16(a0),a0
		Lea	40*256(a1),a1
		Dbf	d7,NextPlane3
		Rts

TextWriter	Move.l	TextPtr,a0
		Tst.b	(a0)
		Bne	NoTextRestart
		Move.w	#0,XPtr
		Move.w	#0,YPtr
		Move.l	#Text,TextPtr
		Rts

NoTextRestart	Cmp.b	#1,(a0)
		Bne	NoTxtPause
		Move.w	#0,XPtr
		Move.w	#0,YPtr
		Addq.l	#1,a0
		Move.l	a0,TextPtr
		Rts

NoTxtPause	Move.w	XPtr,d1
		Move.w	YPtr,d2
		Lea	Font,a1
		Lea	Screen+10240*4+40*21,a2
		Move.b	(a0)+,d0
		Move.l	a0,TextPtr
		Sub.b	#32,d0
		Add.w	d0,a1
		Add.w	d1,a2
		Add.w	d2,a2
		Moveq	#7,d5

PrintChar	Move.b	(a1),(a2)
		Add.w	#96,a1
		Add.w	#40,a2
		Dbf	d5,PrintChar
		Addq.w	#1,XPtr
		Cmp.w	#39,XPtr
		Ble	NoNewLine
		Move.w	#0,XPtr
		Add.w	#40*10,YPtr
NoNewLine	Rts

Copper		Dc.w	$0100,$5000,$008e,$2c81,$0090,$2cc1,$0092,$0038
		Dc.w	$0094,$00d0,$0096,$83f0,$0102,$0000,$0104,$0000
		Dc.w	$0106,$0000,$0108,$0000,$010a,$0000,$01fc,$0000
		Dc.w	$010c,$0011

Colors
		Dc.w	$0180,$0413,$0182,$0fff,$0184,$0cae,$0186,$086c
		Dc.w	$0188,$053a,$018a,$0307,$018c,$0000,$018e,$0f0f
		Dc.w	$0190,$0000,$0192,$0000,$0194,$0000,$0196,$0000
		Dc.w	$0198,$0000,$019a,$0000,$019c,$0000,$019e,$0000

		Dc.w	$01a0,$0e28,$01a2,$0e28,$01a4,$0e28,$01a6,$0e28
		Dc.w	$01a8,$0e28,$01aa,$0e28,$01ac,$0e28,$01ae,$0e28
		Dc.w	$01b0,$0e28,$01b2,$0e28,$01b4,$0e28,$01b6,$0e28
		Dc.w	$01b8,$0e28,$01ba,$0e28,$01bc,$0e28,$01be,$0e28

Bplpointers	Dc.w	$00e0,$0000,$00e2,$0000,$00e4,$0000,$00e6,$0000
		Dc.w	$00e8,$0000,$00ea,$0000,$00ec,$0000,$00ee,$0000
		Dc.w	$00f0,$0000,$00f2,$0000

Sprpointers	Dc.w	$0120,$0000,$0122,$0000,$0124,$0000,$0126,$0000
		Dc.w	$0128,$0000,$012a,$0000,$012c,$0000,$012e,$0000
		Dc.w	$0130,$0000,$0132,$0000,$0134,$0000,$0136,$0000
		Dc.w	$0138,$0000,$013a,$0000,$013c,$0000,$013e,$0000

		Dc.w	$3c07,$fffe,$0180,$0000,$3d07,$fffe

		Dc.w	$0180,$0000,$0182,$0781,$0184,$0161,$0186,$0561
		Dc.w	$0188,$0131,$018a,$06c6,$018c,$0aa1,$018e,$0253
		Dc.w	$0190,$0363,$0192,$0cd2,$0194,$0bc2,$0196,$0292
		Dc.w	$0198,$05a5,$019a,$07e9,$019c,$0ff5,$019e,$0ff8

		Dc.w	$ffdf,$fffe
		Dc.w	$1307,$fffe,$0180,$0000,$1407,$fffe

		Dc.w	$0180,$0413,$0182,$0417,$0184,$0cff,$0186,$0ace
		Dc.w	$0188,$08ac,$018a,$079b,$018c,$068a,$018e,$0bdf
		Dc.w	$0190,$09bd,$0192,$0357,$0194,$0246,$0196,$0135
		Dc.w	$0198,$0124,$019a,$0123,$019c,$0113,$019e,$0112

		Dc.l	-2

Gfxbase		Dc.l	0
Sprite		Dc.l	0
Oldcop		Dc.l	0
Oldview		Dc.l	0
Oldint		Dc.l	0
TextPtr		Dc.l	Text
Oldinta		Dc.w	0
Olddma		Dc.w	0
Oldadk		Dc.w	0
XPtr		Dc.w	0
YPtr		Dc.w	0
Gfxname		Dc.b	'graphics.library',0

Text		Dc.b	' Retro Intros^Demos^Games In Our Minds! '
		Dc.b	'                                        '
		Dc.b	'                                        '
		Dc.b	'http://www.whdload.de (WHDLoad Homepage)'
		Dc.b	'I love "Maptapper v0.8.4" by Codetapper!'
		Dc.b	'                                        '
		Dc.b	'Legionary presents another Oldie^Goldie!'
		Dc.b	'from my Amiga ADF preservation archive. '
		Dc.b	'   Coded 2016-05-04. Freeware source!   '
		Dc.b	'<4 all kinda stuff, sources or whatever>'
		Dc.b	'                                        '
		Dc.b	'       -> legionary3@gmail.com <-       '
		Dc.b	'                                        '
		Dc.b	'Greetz to Flashtro Keep up the good work'
		Dc.b	'                                        '
		Dc.b	'^ My best regards to Wepl & Codetapper ^'
		Dc.b	'                                        '
		Dc.b	'                                        '
		Dc.b	'                                        '
		Dc.b	'                                        '
		Dc.b	'Coded to Perfection by Legionary (C)2016',1

		Dc.b	'Text Screen 2                           '
		Dc.b	'1                                       '
		Dc.b	'2                                       '
		Dc.b	'3                                       '
		Dc.b	'4                                       '
		Dc.b	'5                                       '
		Dc.b	'6                                       '
		Dc.b	'7                                       '
		Dc.b	'8                                       '
		Dc.b	'9                                       '
		Dc.b	'10                                      '
		Dc.b	'11                                      '
		Dc.b	'12                                      '
		Dc.b	'13                                      '
		Dc.b	'14                                      '
		Dc.b	'15                                      '
		Dc.b	'16                                      '
		Dc.b	'17                                      '
		Dc.b	'18                                      '
		Dc.b	'19                                      '
		Dc.b	'Coded to Perfection by Legionary (C)2016',1

		Dc.b	'Text Screen 3                           '
		Dc.b	'20                                      '
		Dc.b	'21                                      '
		Dc.b	'22                                      '
		Dc.b	'23                                      '
		Dc.b	'24                                      '
		Dc.b	'25                                      '
		Dc.b	'26                                      '
		Dc.b	'27                                      '
		Dc.b	'28                                      '
		Dc.b	'29                                      '
		Dc.b	'30                                      '
		Dc.b	'31                                      '
		Dc.b	'32                                      '
		Dc.b	'33                                      '
		Dc.b	'34                                      '
		Dc.b	'35                                      '
		Dc.b	'36                                      '
		Dc.b	'37                                      '
		Dc.b	'38                                      '
		Dc.b	'Coded to Perfection by Legionary (C)2016',0
		Even

		Section	'OldSk00l Crackers Data',Data_c

Font		Incbin	'Gfx/Fonts/CrystalFont-768x8x1.raw'
Background	Incbin	'Gfx/Background/CoolBG-320x214x4.raw'
LegionaryLogo	Incbin	'Gfx/Logos/Legionary-48x4x4.raw'
OSCLogo		Incbin	'Gfx/Logos/OSCLogo-224x16x3.raw'
DeltaMod	Incbin	'Modules/Delta Music 2.0/Archon/Zoids.dm2'

		Section	'OldSk00l Crackers BSS',Bss_c

Screen		Ds.b	10240*5
