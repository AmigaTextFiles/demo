

;bi structure (blockinfo)

	STRUCTURE	bi,0

	APTR	bi_pfw	;указатель на блок впереди (z=z+1)
	APTR	bi_pbw	;сзади
	APTR	bi_plf	;слева (x=x-1)
	APTR	bi_prt	;справа
	
	UBYTE	bi_txfw	;если соотв. указатель=0, то номер текстуры на стене
	UBYTE	bi_txbw	;
	UBYTE	bi_txlf	;
	UBYTE	bi_txrt	;
	
	UBYTE	bi_dummy	;не равно 0 (когда равно - пустое место - конец записей)
	UBYTE	bi_flgdone	;если != 0 - уже обработано
	UWORD	bi_dummy1
	
	WORD	bi_crX	;координата x левого нижнего угла блока
	WORD	bi_crZ	;координата z (каждый блок размером 256x256)
			; вместе

	WORD	bi_lbX	;координаты левой задней (вид сверху) вершины
	WORD	bi_lbZ	; в конечном положении (повёрнутое etc.)
	WORD	bi_rbX	;правой задней
	WORD	bi_rbZ	;
	WORD	bi_rfX	;правой передней
	WORD	bi_rfZ	;
	WORD	bi_lfX	;левой передней
	WORD	bi_lfZ	; вместе

	
	LABEL	bi_SIZE

; ^ z
; |
; |     система координат блоков
; | 
; |
; *-----------> x

;end bi



;cl structure (columns)

	STRUCTURE	cl,0

	APTR	cl_nxt	;для сортировки, 0 - конец
			; в начале

	BYTE	cl_dummy	;=2 (=1 для спрайтов)
	BYTE	cl_dummy1
	
	WORD	cl_S	;s-координата на экране
	WORD	cl_Z	;z-координата

;;;!!! cl_nxt, cl_dummy, cl_Z по тем же смещениям, что и sp_nxt, sp_dummy и sp_Zr

	BYTE	cl_tx	;номер текстуры
	BYTE	cl_V	;V-координата в текстуре
			; вместе

	LONG	cl_txstep	;шаг в текстуре

	WORD	cl_Thi	;T-координаты (неклиппированные)
	WORD	cl_Tlo	;

	LABEL	cl_SIZE
;end cl

	

;sp structure (sprites)

	STRUCTURE	sp,0
	
	APTR	sp_nxt	;для сортировки; 0 - конец отсортированного списка
			; в начале структуры (по смещению 0)

	BYTE	sp_dummy	;=1 (0 - конец спрайтов), =2 для колонок
	BYTE	sp_dummy1

	WORD	sp_Xr	;повёрнутые
	WORD	sp_Zr	; вместе

	WORD	sp_Xo	;центральные координаты спрайта (неповёрнутые) [16.16]
	WORD	sp_Xof	;
	WORD	sp_Zo	;
	WORD	sp_Zof	;
	WORD	sp_Yo	;
	WORD	sp_Yof	;
			;
	WORD	sp_sX	;половинные размеры
	WORD	sp_sY	;
			;
	WORD	sp_dcr	;коэффициент уменьшения спрайта (0..65535, 65535 - полный размер)
			; вместе

	BYTE	sp_type	;0 - яркостной (без Z-затемнения)
			;1 - обычный (с Z-затемнением, 0 - прозрачный)

	BYTE	sp_txnum	;номер текстуры (0-255)
	WORD	sp_txpnt	;центральная координата в текстуре (V<<8+U)
			; вместе


	LABEL	sp_SIZE
;end sp



;ot structure (octree)

	STRUCTURE	ot,0
	
	LONG	ot_count	;сколько цветов (если <0 - недействительный узел/лист)
			; в начале
			;
	LONG	ot_R	;сумма красных компонент всех цветов
	LONG	ot_G	;зелёных
	LONG	ot_B	;синих
			; вместе
	
	APTR	ot_child0	;указатели на следующие элементы
	APTR	ot_child1	;
	APTR	ot_child2	; bitpos: 2 1 0
	APTR	ot_child3	;   bits: B G R - структура индекса
	APTR	ot_child4	;
	APTR	ot_child5	;
	APTR	ot_child6	;
	APTR	ot_child7	;
			; вместе
	
	LABEL	ot_SIZE
;end ot



;bitprogram macros definitions

STARTBIT	MACRO
BYTE	set	0
BITPOS	set	7
	ENDM

BIT	MACRO
BYTE	set	BYTE+(\1<<BITPOS)
BITPOS	set	BITPOS-1
	ifeq	(BITPOS+1)
	dc.b	BYTE
	STARTBIT
	endc
	ENDM

GO	MACRO
	BIT	1
	BIT	0
	ENDM

LEFT	MACRO
	BIT	0
	BIT	1
	ENDM

RIGHT	MACRO
	BIT	1
	BIT	1
	ENDM

PUSH	MACRO
	BIT	0
	BIT	0
	BIT	0
	ENDM

POP	MACRO
	BIT	0
	BIT	0
	BIT	1
	ENDM

STOPBIT	MACRO
	ifne	(BITPOS-7)
	dc.b	BYTE
	endc
	ENDM

;end



;macros for music programs

PLAY	MACRO
	dc.w	((\1)<<12)+((\2)<<8)+((\3)<<4)+(\4)
	ENDM

ENDPLAY	MACRO
	dc.w	0
	ENDM

;end



;macros for event program

SPEED	MACRO
	dc.w	((\1)<<4)+(\2)
	ENDM

GAP	MACRO
	dc.w	((\1)<<4)+8
	ENDM

FADE	MACRO
	dc.w	((\1)<<4)+9
	ENDM

NOISEON	MACRO
	dc.w	((\1)<<4)+10
	ENDM

NOISEOFF	MACRO
	dc.w	((\1)<<4)+11
	ENDM

NOISESML	MACRO
	dc.w	((\1)<<4)+12
	ENDM

ENDE	MACRO
	dc.w	((\1)<<4)+15
	ENDM

;end
