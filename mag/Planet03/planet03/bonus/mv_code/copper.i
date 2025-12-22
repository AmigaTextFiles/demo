*************************************************************************
* Copper Macros by The Dark Coder / Morbid Visions
* vers. 3 SE / 16-07-96 / per ASM One 1.29
* questa e` una versione ridotta delle copper macros usate dai Morbid Visions
* realizzata appositamente per i sorgenti pubblicati su Infamia.
* La versione completa (integrata con le altre macros standard MV) ha
* controlli aggiuntivi sugli errori e permette di utilizzare il Blitter
* Finished Disable bit. Chi e` interessato puo` contattare The Dark Coder.

* formato
* CMOVE valore immediato, registro hardware destinazione
* WAIT  Hpos,Vpos[,Hena,Vena]
* SKIP  Hpos,Vpos[,Hena,Vena]
* CSTOP

* Nota: Hpos,Vpos coordinate copper, Hena, Vena sono i valori di maschera
* della posizione copper, opzionali (se non specificati viene assunto
* Hena=$fe e Vena=$7f)

cmove:	macro
	dc.w	 [\2&$1fe]
	dc.w	\1
	endm

wait:	macro
	dc.w	[\2<<8]+[\1&$fe]+1
	ifeq	narg-2
		dc.w	$fffe
	endc	
	ifeq	narg-4
		dc.w	$8000+[[\4&$7f]<<8]+[\3&$fe]
	endc
	endm

skip:	macro
	dc.w	[\2<<8]+[\1&$fe]+1
	ifeq	narg-2
		dc.w	$fffe
	endc	
	ifeq	narg-4
		dc.w	$8000+[[\4&$7f]<<8]+[\3&$fe]+1
	endc
	endm


cstop:	macro
	dc.w	$ffff
	dc.w	$fffe
	endm

