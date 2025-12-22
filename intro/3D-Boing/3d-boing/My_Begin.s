*		output  dh1:dev/devpac/rts
		incdir	dh1:dev/devpac/include

TRUE:		=	-1
FALSE:		=	0

* exec.library

		include	lvo/exec_lib.i
		include	exec/exec.i

CALLEXE		macro
		move.l	4.w,a6
		jsr	_LVO\1(a6)
		endm

* dos.library

		include	lvo/dos_lib.i

MODE_OLDFILE:	=	1005
MODE_NEWFILE:	=	1006

CALLDOS		macro
		move.l	DosBase,a6
		jsr	_LVO\1(a6)
		endm

DOSNAME		macro
DosName:	dc.b	'dos.library',0
		endm

* intuition.library

		include	intuition/iobsolete.i
		include	lvo/intuition_lib.i

CALLINT		macro
		move.l	IntBase,a6
		jsr	_LVO\1(a6)
		endm

INTNAME		macro
IntName:	dc.b	'intuition.library',0
		endm

* asl.library

		include	lvo/asl_lib.i
		include	libraries/asl.i

CALLASL		macro
		move.l	AslBase,a6
		jsr	_LVO\1(a6)
		endm

ASLNAME		macro
AslName:	dc.b	'asl.library',0
		endm

* gadtools.library

		include	lvo/gadtools_lib.i
		include	libraries/gadtools.i

CALLGT		macro
		move.l	GTBase,a6
		jsr	_LVO\1(a6)
		endm

GTNAME		macro
GTName:	dc.b	'gadtools.library',0
		endm

* graphics.library

		include	lvo/graphics_lib.i

CALLGFX		macro
		move.l	GfxBase,a6
		jsr	_LVO\1(a6)
		endm

GFXNAME		macro
GfxName:	dc.b	'graphics.library',0
		endm

* rtgmaster.library

		include	lvo/rtgmaster_lib.i

CALLRTG		macro
		move.l	RtgMasterBase,a6
		jsr	_LVO\1(a6)
		endm

RTGNAME		macro
RtgName:	dc.b	'rtgmaster.library',0
		endm

* hardware

* Порт джойстика/мыши 1 (R)
joy0dat:	=$DFF00A
* Порт джойстика/мыши 2 (R)
joy1dat:	=$DFF00C
* Состояние кнопок джойстика/мыши 1 (бит 7) и 2 (бит 6) (R)
ciagameport:	=$bfe001
* Сырой код нажатой клавиши (R)
ciasdr:		=$bfec01
* Регистр управления DMA (R)
dmaconr:	=$DFF002
* Регистр управления DMA (W)
dmacon:		=$DFF096
* Регистр режимов работы аудио-каналов (W)
adkcon:		=$DFF09E

* Аудио-канал 0
* Регистр начала таблицы данных, биты 16-18 (W)
aud0ptr:	=$DFF0A0
* Регистр начала таблицы данных, биты 0-15 (W)
aud0ptrl:	=$DFF0A2
* Регистр размера таблицы данных (W)
aud0len:	=$DFF0A4
* Регистр периода выборки данных (W)
aud0per:	=$DFF0A6
* Регистр громкости (W)
aud0vol:	=$DFF0A8
* Регистр (буфер) данных (W)
aud0dat:	=$DFF0AA

* Аудио-канал 1
* Регистр начала таблицы данных, биты 16-18 (W)
aud1ptr:	=$DFF0B0
* Регистр начала таблицы данных, биты 0-15 (W)
aud1ptrl:	=$DFF0B2
* Регистр размера таблицы данных (W)
aud1len:	=$DFF0B4
* Регистр периода выборки данных (W)
aud1per:	=$DFF0B6
* Регистр громкости (W)
aud1vol:	=$DFF0B8
* Регистр (буфер) данных (W)
aud1dat:	=$DFF0BA

* Аудио-канал 2
* Регистр начала таблицы данных, биты 16-18 (W)
aud2ptr:	=$DFF0C0
* Регистр начала таблицы данных, биты 0-15 (W)
aud2ptrl:	=$DFF0C2
* Ригистр размера таблицы данных (W)
aud2len:	=$DFF0C4
* Регистр периода выборки данных (W)
aud2per:	=$DFF0C6
* Регистр громкости (W)
aud2vol:	=$DFF0C8
* Регистр (буфер) данных (W)
aud2dat:	=$DFF0CA

* Аудио-канал 3
* Регистр начала таблицы данных, биты 16-18 (W)
aud3ptr:	=$DFF0D0
* Регистр начала таблицы данных, биты 0-15 (W)
aud3ptrl:	=$DFF0D2
* Регистр размера таблицы данных (W)
aud3len:	=$DFF0D4
* Регистр периода выборки данных (W)
aud3per:	=$DFF0D6
* Регистр громкости (W)
aud3vol:	=$DFF0D8
* Регистр (буфер) данных (W)
aud3dat:	=$DFF0DA

INIT:		MACRO
pr_CLI:		=$ac
pr_MsgPort:	=$5c
		movem.l	d0/a0,-(sp)	;сохраняем начальные переменные
		clr.l	returnmsg
		sub.l	a1,a1
		CALLEXE	FindTask	;ищем нас
		move.l	d0,a4
		tst.l	pr_CLI(a4)
		beq.s	fromworkbench
;иы были вызваны из CLI
		movem.l	(sp)+,d0/a0	;восстaнавливаем регистры
		bra.s	end_startup	;и запускаем программу пользователя
;иы были вызваны из Worckbench
fromworkbench:
		lea	pr_MsgPort(a4),a0
		CALLEXE	WaitPort	;ждем сообщение
		lea	pr_MsgPort(a4),a0
		CALLEXE	GetMsg		;и получаем его
		move.l	d0,returnmsg	;сохраним его для дальнейшего ответа
		movem.l	(sp)+,d0/a0	;восстaнавливаем начальные переменные
end_startup:
		bsr.s	main		;вызываем вашу программу
;возврат с кодом в d0
		move.l	d0,-(sp)	;сохраним его
		tst.l	returnmsg
		beq.s	exittodos
		CALLEXE	Forbid
		move.l	returnmsg(pc),a1
		CALLEXE	ReplyMsg
exittodos:
		move.l  (sp)+,d0	;восстaнавливаем код возврата
		rts
returnmsg:	dc.l 0
		ENDM
main:
