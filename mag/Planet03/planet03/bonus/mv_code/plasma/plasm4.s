		************************************
		*       /\/\                       *
		*      /    \                      *
		*     / /\/\ \ O R B_I D           *
		*    / /    \ \   / /              *
		*   / /    __\ \ / /               *
		*   ¯¯     \ \¯¯/ / I S I O N S    *
		*           \ \/ /                 *
		*            \  /                  *
		*             \/                   *
		*     Feel the DEATH inside!       *
		************************************
		* Coded by:                        *
		* The Dark Coder / Morbid Visions  *
		************************************

; Plasma4.s	Plasma RGB a 1-bitplanes e ondulazione
;		tasto sinistro per uscire

	SECTION	DK,code

	incdir	"MV_code:"
	include	MVstartup.s		; Codice di startup: prende il
					; controllo del sistema e chiama
					; la routine START: ponendo
					; A5=$DFF000

		;5432109876543210
DMASET	EQU	%1000001111000000	; copper,bitplane,blitter DMA

Largh_plasm	equ	38		; larghezza del plasma espressa
					; come numero di gruppi di 8 pixel

; numero di bytes occupati nella copperlist da ogni riga del plasma: ogni
; istruzione copper occupa 4 bytes. Ogni riga e` formata da 1 CMOVE in
; BPLCON1, 1 WAIT,Largh_plasm CMOVEs per il plasma (compresa la
; CMOVE finale in COLOR00 per fare lo sfondo nero.
BytesPerRiga	equ	(Largh_plasm+2)*4

Alt_plasm	equ	190		; altezza del plasma espressa
					; come numero di linee

NuovaRigaR	equ	-4		; valore sommato all'indice R nella
					; SinTab tra una riga e l'altra
					; Puo` essere variato ottenendo plasmi
					; diversi, ma DEVE ESSERE SEMPRE PARI!!

NuovoFrameR	equ	6		; valore sottratto all'indice R nella
					; SinTab tra un frame e l'altro
					; Puo` essere variato ottenendo plasmi
					; diversi, ma DEVE ESSERE SEMPRE PARI!!

NuovaRigaG	equ	2		; come "NuovaRigaR" ma per componente G
NuovoFrameG	equ	8		; come "NuovoFrameR" ma componente G

NuovaRigaB	equ	8		; come "NuovaRigaR" ma per componente B
NuovoFrameB	equ	4		; come "NuovoFrameR" ma componente B

NuovaRigaO	equ	8		; come "NuovaRigaR" ma per oscillazioni
NuovoFrameO	equ	2		; come "NuovoFrameR" ma oscillazioni


START:

;	Puntiamo l'immagine nelle copperlist

	move.l	#bitplane,d0	; dove puntare
	lea	copperlist1,a1	; puntatori cop 1
	lea	copperlist2,a2	; puntatori cop 2
	move	d0,6(a1)	; scrive in copperlist 1 
	move	d0,6(a2)	; scrive in copperlist 2
	swap	d0
	move	d0,2(a1)	; scrive in copperlist 1
	move	d0,2(a2)	; scrive in copperlist 2

	bsr	InitPlasma		; inizializza la copperlist

; Inizializza i registri del blitter
WaitBlit_init:
	Btst	#6,dmaconr(a5)		; aspetta il blitter
	bne.s	WaitBlit_init

	move.l	#$4FFE8000,bltcon0(a5)	; BLTCON0/1 - D=A+B+C
					; shift A = 4 pixel
					; shift B = 8 pixel
					
	moveq	#-1,d0
	move.l	d0,bltafwm(a5)

mod_A	set	0			; modulo canale A
mod_D	set	BytesPerRiga-2		; modulo canale D: va a riga seguente
	move.l	#mod_A<<16+mod_D,bltamod(a5)	; carica i registri modulo

; moduli canali B e C = 0
	moveq	#0,d0
	move.l	d0,bltcmod(a5)		; scrive BLTBMOD e BLTCMOD

; Inizializza altri registri hardware
; D0=0
	move.l	d0,color00(a5)		; COLOR00 e COLOR01 - nero
	move	#$3e90,diwstrt(a5)	; DiwStrt - usiamo una finestra piu`
					; piccola dello schermo
	move	#$fcb1,diwstop(a5)	; DiwStop
	move	#$0036,ddfstrt(a5)	; DDFStrt - vengono fetchati 40 bytes
	move	#$00ce,ddfstop(a5)	; DDFStop
	move.l	d0,bplcon1(a5)		; BPLCON1/2
	move	#-40,bpl1mod(a5)	; BPL1MOD = -40 ripete sempre la stessa
					; riga
	move	#$1200,bplcon0(a5)	; BPLCON0 - 1 bitplane attivo
	move.l	#COPPERLIST1,cop1lc(a5)	; attiva copperlist
	move	d0,copjmp1(a5)
	move	#dmaset,dmacon(a5)	; DMACON - abilita bitplane, copper

mouse2:

	move.l	#$1ff00,d1
	move.l	#$13000,d2
.wait
	move.l	vposr(a5),d0
	and.l	d1,d0
	cmp.l	d2,d0
	bne.s	.wait

	bsr	ScambiaClists	; scambia le copperlist

	bsr	DoOriz		; effetto oscillazione orizzontale
	bsr	DoPlasma

	btst	#6,$bfe001	; mouse premuto?
	bne.s	mouse2

	rts

;****************************************************************************
; Questa routine realizza l'effetto di oscillazione orizzontale. 
; L'effetto e` realizzato modificando ad ogni riga il valore di scroll hardware
; del bitplane 1. I valori vengono letti da una tabella e scritti nella
; copperlist.
DoOriz:
	lea	OrizTab(pc),a0		; indirizzo tabella oscillazioni
	move.l	draw_clist(pc),a1	; indirizzo copperlist dove scrivere
	lea	4*2+3(a1),a1		; indirizzo secondo byte della seconda
					; word della CMOVE in BPLCON1

; legge e modifica indice
	move	IndiceO(pc),d4		; legge l'indice di partenza del
					; frame precedente
	sub	#NuovoFrameO,d4		; modifica l'indice nella tabella
					; dal frame precedente
	and	#$007F,d4		; tiene l'indice nell'intervallo
					; 0 - 127 (offset in una tabella di
					; 128 bytes)
	move	d4,IndiceO		; memorizza l'indice di partenza per
					; il prossimo frame

	move	#Alt_plasm-1,d3		; loop per ogni riga
OrizLoop:
	move.b	0(a0,d4.w),d0		; leggi valore dell'oscillazione

	move.b	d0,(a1)			; scrive il valore di scroll nella
					; CMOVE in BPLCON1

	lea	BytesPerRiga(a1),a1	; punta alla prossima riga 
					; nella copper list

; modifica indice per prossima riga
	add	#NuovaRigaO,d4		; modifica l'indice nella tabella
					; per la prossima riga

	and	#$007F,d4		; tiene l'indice nell'intervallo
					; 0 - 127 (offset in una tabella di
					; 128 bytes)

	dbra	d3,OrizLoop

	rts

;****************************************************************************
; Questa routine realizza il "double buffer" tra le copperlist.
; In pratica prende la clist dove si e` disegnato, e la visualizza copiandone
; l'indirizzo in COP1LC. Scambia le variabili, in modo tale che nel frame
; che segue si disegna sull'altra copper list
ScambiaClists:
	move.l	draw_clist(pc),d0	; indirizzo clist su cui si e` scritto
	move.l	view_clist(pc),draw_clist	; scambia le clists
	move.l	d0,view_clist

	move.l	d0,cop1lc(a5)		; copia l'indirizzo della clist
					; in COP1LC in maniera che venga
					; visualizzata nel prossimo frame

	rts


;****************************************************************************
; Questa routine inizializza la copperlist che genera il plasma. Sistema le
; istruzioni WAIT e le prima meta` delle COPPERMOVE.

InitPlasma:
	lea	Plasma1,a0	; indirizzo plasma 1
	lea	Plasma2,a1	; indirizzo plasma 2
	move.l	#$3e43FFFE,d0	; carica la prima istruzione wait in D0.
				; aspetta la riga $30 e la posizione
				; orizzontale $42
	move	#color00,d1	; mette in D1 la prima meta` di un istruzione 
				; CMOVE in COLOR00 (=$dff180)
	move	#color00+2,d4	; mette in D4 la prima meta` di un istruzione 
				; CMOVE in COLOR01 (=$dff182)
	move	#bplcon1,d5	; mette in D4 la prima meta` di un istruzione 
				; CMOVE in BPLCON1 (=$dff102)

	move	#Alt_plasm-1,d3		; loop per ogni riga
InitLoop1:
	move	d5,(a0)+		; scrive la prima parte della
					; CMOVE in BPLCON1 - clist 1
	addq.l	#2,a0			; spazio per la seconda parte
					; della CMOVE - clist 1

	move	d5,(a1)+		; scrive la prima parte della
					; CMOVE in BPLCON1 - clist 2
	addq.l	#2,a1			; spazio per la seconda parte
					; della CMOVE - clist 2

	move.l	d0,(a0)+		; scrive la WAIT - (clist 1)
	move.l	d0,(a1)+		; scrive la WAIT - (clist 2)
	add.l	#$01000000,d0		; modifica la WAIT per aspettare
					; la riga seguente

	moveq	#Largh_plasm/2-1,d2	; loop per tutta la larghezza
					; del plasma + 2 CMOVEs
					; che rimettono il nero in COLOR00/01

InitLoop2:
	move	d4,(a0)+		; scrive la prima parte della
					; CMOVE in COLOR00 - clist 1
	addq.l	#2,a0			; spazio per la seconda parte
					; della CMOVE - clist 1

	move	d4,(a1)+		; scrive la prima parte della
					; CMOVE in COLOR00 - clist 2
	addq.l	#2,a1			; spazio per la seconda parte
					; della CMOVE - clist 2

	move	d1,(a0)+		; scrive la prima parte della
					; CMOVE in COLOR01 - clist 1
	addq.l	#2,a0			; spazio per la seconda parte
					; della CMOVE - clist 1

	move	d1,(a1)+		; scrive la prima parte della
					; CMOVE in COLOR01 - clist 2
	addq.l	#2,a1			; spazio per la seconda parte
					; della CMOVE - clist 2

	dbra	d2,InitLoop2

	dbra	d3,InitLoop1
	
	rts


;****************************************************************************
; Questa routine realizza il plasma. Effettua un loop di blittate, ciascuna
; delle quali scrive una "colonna" del plasma, cioe` scrive i colori nelle
; COPPERMOVES messe in colonna.
; I colori scritti in ogni colonna sono letti da una tabella, a partire da
; un indirizzo che varia tra una colonna e l'altra in base a degli offset
; letti da un'altra tabella. Inoltre tra un frame e l'altro gli offset
; variano, realizzando l'effetto di movimento.

DoPlasma:

	lea	ColorTab,a0		; indirizzo colori
	lea	SinTab,a6		; indirizzo tabella offsets
	move.l	draw_clist(pc),a1	; indirizzo copperlist dove scrivere
	lea	4*(2+2)+2(a1),a1	; indirizzo seconda word della prima
					; colonna del plasma

; legge e modifica indice componente R
	move	IndiceR(pc),d4		; legge l'indice di partenza del
					; frame precedente
	sub	#NuovoFrameR,d4		; modifica l'indice nella tabella
					; dal frame precedente
	and	#$00FF,d4		; tiene l'indice nell'intervallo
					; 0 - 255 (offset in una tabella di
					; 128 words)
	move	d4,IndiceR		; memorizza l'indice di partenza per
					; il prossimo frame

; legge e modifica indice componente G
	move	IndiceG(pc),d5		; legge l'indice di partenza del
					; frame precedente
	sub	#NuovoFrameG,d5		; modifica l'indice nella tabella
					; dal frame precedente
	and	#$00FF,d5		; tiene l'indice nell'intervallo
					; 0 - 255 (offset in una tabella di
					; 128 words)
	move	d5,IndiceG		; memorizza l'indice di partenza per
					; il prossimo frame

; legge e modifica indice componente B
	move	IndiceB(pc),d6		; legge l'indice di partenza del
					; frame precedente
	sub	#NuovoFrameB,d6		; modifica l'indice nella tabella
					; dal frame precedente
	and	#$00FF,d6		; tiene l'indice nell'intervallo
					; 0 - 255 (offset in una tabella di
					; 128 words)
	move	d6,IndiceB		; memorizza l'indice di partenza per
					; il prossimo frame

	move	#Alt_plasm<<6+1,d3	; dimensione blittata
					; largh. 1 word, alta tutto il plasma

	moveq	#Largh_plasm-2,d2	; il loop NON viene ripetuto per tutta
					; la larghezza. Le ultime 2 colonne
					; vengono lascate stare in modo che
					; esse riscrivano il colore nero nei
					; registri COLOR01 e COLOR00

PlasmaLoop:				; inizio loop blittate

; calcola indirizzo di partenza componente R
	move	(a6,d4.w),d1		; legge offset dalla tabella

	lea	(a0,d1.w),a2		; indirizzo di partenza = ind. colori
					; piu` offset

; calcola indirizzo di partenza componente G
	move	(a6,d5.w),d1		; legge offset dalla tabella

	lea	(a0,d1.w),a3		; indirizzo di partenza = ind. colori
					; piu` offset

; calcola indirizzo di partenza componente B
	move	(a6,d6.w),d1		; legge offset dalla tabella

	lea	(a0,d1.w),a4		; indirizzo di partenza = ind. colori
					; piu` offset

WaitBlit:
	Btst	#6,dmaconr(a5)		; aspetta il blitter
	bne.s	WaitBlit

	move.l	a2,bltcpt(a5)		; BLTCPT - indirizzo sorgente R
	move.l	a3,bltapt(a5)		; BLTAPT - indirizzo sorgente G
	move.l	a4,bltbpt(a5)		; BLTBPT - indirizzo sorgente B
	move.l	a1,bltdpt(a5)		; BLTDPT - indirizzo destinazione
	move	d3,bltsize(a5)		; BLTSIZE

	addq.l	#4,a1			; punta a prossima colonna di 
					; CMOVEs nella copper list

; modifica indice componente R per prossima riga
	add	#NuovaRigaR,d4		; modifica l'indice nella tabella
					; per la prossima riga

	and	#$00FF,d4		; tiene l'indice nell'intervallo
					; 0 - 255 (offset in una tabella di
					; 128 words)

; modifica indice componente G per prossima riga
	add	#NuovaRigaG,d5		; modifica l'indice nella tabella
					; per la prossima riga

	and	#$00FF,d5		; tiene l'indice nell'intervallo
					; 0 - 255 (offset in una tabella di
					; 128 words)

; modifica indice componente B per prossima riga
	add	#NuovaRigaB,d6		; modifica l'indice nella tabella
					; per la prossima riga

	and	#$00FF,d6		; tiene l'indice nell'intervallo
					; 0 - 255 (offset in una tabella di
					; 128 words)

	dbra	d2,PlasmaLoop

	rts


; Queste 2 variabili contengono gli indirizzi delle 2 copperlist
view_clist	dc.l	COPPERLIST1	; indirizzo clist visualizzata
draw_clist	dc.l	COPPERLIST2	; indirizzo clist dove disegnare

; Questa variabile contiene il valore dell'indice nella tabella delle
; oscillazioni (posizioni orizzontali delle WAIT)
IndiceO	dc.w	0

; Questa tabella contiene i valori delle oscillazioni (valori di scroll)
OrizTab:
	DC.B	$03,$03,$03,$03,$04,$04,$04,$04,$04,$04,$04,$05,$05,$05,$05,$05
	DC.B	$05,$05,$05,$05,$05,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06
	DC.B	$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$05,$05,$05,$05
	DC.B	$05,$05,$05,$05,$05,$05,$04,$04,$04,$04,$04,$04,$04,$03,$03,$03
	DC.B	$03,$03,$03,$03,$02,$02,$02,$02,$02,$02,$02,$01,$01,$01,$01,$01
	DC.B	$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DC.B	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01
	DC.B	$01,$01,$01,$01,$01,$01,$02,$02,$02,$02,$02,$02,$02,$03,$03,$03

; Queste variabili contengono i valori degli indici per la prima colonna
IndiceR	dc.w	0
IndiceG	dc.w	0
IndiceB	dc.w	0

; Questa tabella contiene gli offset per l'indirizzo di partenza nella
; tabella dei colori
SinTab:
	DC.W	$0034,$0036,$0038,$003A,$003C,$0040,$0042,$0044,$0046,$0048
	DC.W	$004A,$004C,$004E,$0050,$0052,$0054,$0056,$0058,$005A,$005A
	DC.W	$005C,$005E,$005E,$0060,$0060,$0062,$0062,$0062,$0064,$0064
	DC.W	$0064,$0064,$0064,$0064,$0064,$0064,$0062,$0062,$0062,$0060
	DC.W	$0060,$005E,$005E,$005C,$005A,$005A,$0058,$0056,$0054,$0052
	DC.W	$0050,$004E,$004C,$004A,$0048,$0046,$0044,$0042,$0040,$003C
	DC.W	$003A,$0038,$0036,$0034,$0030,$002E,$002C,$002A,$0028,$0024
	DC.W	$0022,$0020,$001E,$001C,$001A,$0018,$0016,$0014,$0012,$0010
	DC.W	$000E,$000C,$000A,$000A,$0008,$0006,$0006,$0004,$0004,$0002
	DC.W	$0002,$0002,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	DC.W	$0002,$0002,$0002,$0004,$0004,$0006,$0006,$0008,$000A,$000A
	DC.W	$000C,$000E,$0010,$0012,$0014,$0016,$0018,$001A,$001C,$001E
	DC.W	$0020,$0022,$0024,$0028,$002A,$002C,$002E,$0030

EndSinTab:

;****************************************************************************

	SECTION	GRAPHIC,DATA_C

; Abbiamo 2 copperlists 

COPPERLIST1:
	cmove	0,bplpt			; primo	 bitplane
	cmove	0,bplpt+2		; word bassa bpl1pt

; Qui viene lasciato dello spazio vuoto per il pezzo di copperlist che genera
; il plasma. Questo spazio viene riempito dalle routine dell'effetto.
PLASMA1:
	dcb.b	alt_plasm*BytesPerRiga,0
	cstop

COPPERLIST2:
	cmove	0,bplpt			; primo	 bitplane
	cmove	0,bplpt+2		; word bassa bpl1pt

; Qui viene lasciato dello spazio vuoto per il pezzo di copperlist che genera
; il plasma. Questo spazio viene riempito dalle routine dell'effetto.
PLASMA2:
	dcb.b	alt_plasm*BytesPerRiga,0
	cstop


;****************************************************************************
; Qui c'e` la tabella di colori che viene scritta nel plasma.
; Devono esserci abbastanza colori da essere letti qualunque sia l'indirizzo
; di partenza. In questo esempio l'indirizzo di partenza puo` variare da
; "ColorTab" (primo colore) fino a "ColorTab+100" (50-esimo colore), perche`
; 100 e` il massimo offset sontenuto nella "SinTab".
; Se Alt_plasm=190 vuol dire che ogni blittata legge 190 colori.
; Quindi in totale devono esserci 240 colori.

ColorTab:
	dc.w	$0f00,$0f00,$0e00,$0e00,$0e00,$0d00,$0d00,$0d00
	dc.w	$0c00,$0c00,$0c00,$0b00,$0b00,$0b00,$0a00,$0a00,$0a00
	dc.w	$0900,$0900,$0900,$0800,$0800,$0800,$0700,$0700,$0700
	dc.w	$0600,$0600,$0600,$0500,$0500,$0500,$0400,$0400,$0400
	dc.w	$0300,$0300,$0300,$0200,$0200,$0200,$0100,$0100,$0100
	dcb.w	18,0
	dc.w	$0100,$0100,$0100,$0100,$0200,$0200,$0200,$0200
	dc.w	$0300,$0300,$0300,$0300,$0400,$0400,$0400,$0400
	dc.w	$0500,$0500,$0500,$0500,$0600,$0600,$0600,$0600
	dc.w	$0700,$0700,$0700,$0700,$0800,$0800,$0800,$0800
	dc.w	$0900,$0900,$0900,$0900,$0a00,$0a00,$0a00,$0a00
	dc.w	$0b00,$0b00,$0b00,$0b00,$0c00,$0c00,$0c00,$0c00
	dc.w	$0d00,$0d00,$0d00,$0d00,$0e00,$0e00,$0e00,$0e00
	dc.w	$0f00,$0f00,$0f00,$0f00

	dc.w	$0f00,$0f00,$0f00,$0f00,$0e00,$0e00,$0e00,$0e00
	dc.w	$0d00,$0d00,$0d00,$0d00,$0c00,$0c00,$0c00,$0c00
	dc.w	$0b00,$0b00,$0b00,$0b00,$0a00,$0a00,$0a00,$0a00
	dc.w	$0900,$0900,$0900,$0800,$0800,$0800,$0800
	dc.w	$0700,$0700,$0700,$0700,$0600,$0600,$0600,$0600
	dc.w	$0500,$0500,$0500,$0500,$0400,$0400,$0400,$0400
	dc.w	$0300,$0300,$0300,$0300,$0200,$0200,$0200,$0200
	dc.w	$0100,$0100,$0100
	dcb.w	18,0
	dc.w	$0100,$0100,$0100,$0200,$0200,$0200,$0300,$0300,$0300
	dc.w	$0400,$0400,$0400,$0500,$0500,$0500,$0600,$0600,$0600
	dc.w	$0700,$0700,$0700,$0800,$0800,$0900,$0900,$0900
	dc.w	$0a00,$0a00,$0a00,$0b00,$0b00,$0b00,$0c00,$0c00,$0c00
	dc.w	$0d00,$0d00,$0d00,$0e00,$0e00,$0e00,$0f00

; Riga dell'immagine che viene ripetuta con il BPLMOD1
; e` formata da 40 bytes alternativamente a 0 o a $FF
BITPLANE:	dcb.w	20,$00FF

	end



;****************************************************************************

In questo esempio mostriamo un plasma a 1 bitplane con un ondulazione
realizzata mediante lo scroll hardware. 
Viene utilizzato un bitplane a strisce verticali, come spiegato nella teoria.
Siccome tutte le righe del bitplane sarebbero risultate uguali, ne abbiamo
memorizzata una sola che viene ripetuta sfruttando il trucco del modulo
negativo. L'immagine e` larga 40 bytes. Pero` non viene visualizzata tutta
per permettere lo scroll hardware. Si usa quindi una "display window" piu`
stretta del solito, anche per mascherare alcuni difettucci del plasma ai
bordi. Per ottenere l'effetto ondulazione, viene variato ad ogni riga il valore
di scroll hardware. Al solito i valori vengono letti da una tabella.
La copperlist per ogni riga del plasma ha una CMOVE in BPLCON1
(per scrivere il valore dello scroll), seguita da una WAIT per sincronizzarsi
con l'inizio del fetch del bitplane, e infine ci sono le CMOVEs
del plasma, la cui destinazione e` alternativamente COLOR01 e COLOR00.
La prima CMOVE di ogni riga e` in COLOR01 e inizia 8 pixel prima che
inizi la visualizzazione dell'immagine. Questo perche` questa CMOVE
serve per determinare il colore dei pixel che entrano dal bordo destro dello
schermo mediante lo scroll hardware; siccome si tratta di pixel settati ad 1,
e` necessario scrivere in COLOR01. La successiva CMOVE in COLOR00 e`
allineata con l'inizio della finestra video. Poi si susseguono alternativamente
altre CMOVEs in COLOR01 e COLOR00. La routine di "DoPlasma" scrive una
colonna alla volta, tranne le ultime 2 che servono per rimettere il nero nei
2 registri colore.
