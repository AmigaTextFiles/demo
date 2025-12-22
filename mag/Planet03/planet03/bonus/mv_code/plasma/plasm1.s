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

; Plasma1.s	Plasma 0-bitplanes
; 		commenti alla fine del sorgente

	SECTION	DK,code

	incdir	"MV_code:"
	include	MVstartup.s		; Codice di startup: prende il
					; controllo del sistema e chiama
					; la routine START: ponendo
					; A5=$DFF000

		;5432109876543210
DMASET	EQU	%1000001111000000	; copper,bitplane,blitter DMA

Largh_plasm	equ	30		; larghezza del plasma espressa
					; come numero di gruppi di 8 pixel

BytesPerRiga	equ	(Largh_plasm+2)*4	; numero di bytes occupati
						; nella copperlist da ogni riga
						; del plasma: ogni istruzione
						; copper occupa 4 bytes

Alt_plasm	equ	100		; altezza del plasma espressa
					; come numero di linee

NuovaRiga	equ	4		; valore sommato all'indice nella
					; SinTab tra una riga e l'altra
					; Puo` essere variato ottenendo plasmi
					; diversi, ma DEVE ESSERE SEMPRE PARI!!

NuovoFrame	equ	6		; valore sottratto all'indice nella
					; SinTab tra un frame e l'altro
					; Puo` essere variato ottenendo plasmi
					; diversi, ma DEVE ESSERE SEMPRE PARI!!

START:
	lea	custom,a5		; CUSTOM REGISTER in a5

	bsr	InitPlasma		; inizializza la copperlist

; Inizializza i registri del blitter
WaitBlit_init:
	Btst	#6,dmaconr(a5)		; aspetta il blitter
	bne.s	WaitBlit_init

	move.l	#$09f00000,bltcon0(a5)	; operazione copia da A a D
	moveq	#-1,d0			; D0 = $FFFFFFFF
	move.l	d0,bltafwm(a5)		; disabilita le maschere

mod_A	set	0			; modulo canale A
mod_D	set	BytesPerRiga-2		; modulo canale D: va a riga seguente
	move.l	#mod_A<<16+mod_D,bltamod(a5)	; carica i registri modulo

; Inizializza altri registri hardware
	move	#$000,color00(a5)	; colore sfondo - nero
	move	#$0200,bplcon0(a5)	; BPLCON0 - no bitplanes attivi
	move.l	#COPPERLIST,cop1lc(a5)	; attiva copperlist
	move	d0,copjmp1(a5)
	move	#dmaset,dmacon(a5)	; DMACON - abilita bitplane, copper

mouse:

; attendi linea $130 (304)
	move.l	#$1ff00,d1
	move.l	#$13000,d2
.wait
	move.l	vposr(a5),d0
	and.l	d1,d0
	cmp.l	d2,d0
	bne.s	.wait

	bsr	DoPlasma

	btst	#6,$bfe001	; mouse premuto?
	bne.s	mouse

	rts

*****************************************************************************
* Questa routine inizializza la copperlist che genera il plasma. Sistema le
* istruzioni WAIT e le prima meta` delle COPPERMOVE. Alla fine della riga
* del plasma viene inserita un ultima COPPERMOVE che carica il colore
* nero in COLOR00.

InitPlasma:
	lea	Plasma,a0	; indirizzo plasma
	move.l	#$6051FFFE,d0	; carica la prima istruzione wait in D0.
				; aspetta la riga $60 e la posizione
				; orizzontale $51
	move	#$180,d1	; mette in D1 la prima meta` di un istruzione 
				; "copper move" in COLOR00 (=$dff180)

	moveq	#Alt_plasm-1,d3		; loop per ogni riga
.Loop1:
	move.l	d0,(a0)+		; scrive la WAIT
	add.l	#$01000000,d0		; modifica la WAIT per aspettare
					; la riga seguente

	moveq	#Largh_plasm,d2		; loop per tutta la larghezza
					; del plasma + una volta per
					; l'ultima "copper move" che rimette
					; il nero come sfondo

.Loop2:
	move	d1,(a0)+		; scrive la prima parte della
					; "copper move"
	addq.l	#2,a0			; spazio per la seconda parte
					; della "copper move"
					; (riempito poi dalla routine DoPlasma)

	dbra	d2,.Loop2

	dbra	d3,.Loop1
	
	rts


*****************************************************************************
* Questa routine realizza il plasma. Effettua un loop di blittate, ciascuna
* delle quali scrive una "colonna" del plasma, cioe` scrive i colori nelle
* COPPERMOVES messe in colonna.
* I colori scritti in ogni colonna sono letti da una tabella, a partire da
* un indirizzo che varia tra una colonna e l'altra in base a degli offset
* letti da un'altra tabella. Inoltre tra un frame e l'altro gli offset
* variano, realizzando l'effetto di movimento.

DoPlasma:

	lea	ColorTab,a0		; indirizzo colori
	lea	SinTab,a3		; indirizzo tabella offsets
	lea	Plasma+6,a1		; indirizzo prima word della prima
					; colonna del plasma

	move	Indice(pc),d0		; legge l'indice di partenza del
					; frame precedente
	sub	#NuovoFrame,d0		; modifica l'indice nella tabella
					; dal frame precedente
	and	#$00FF,d0		; tiene l'indice nell'intervallo
					; 0 - 255 (offset in una tabella di
					; 128 words)
	move	d0,Indice		; memorizza l'indice di partenza per
					; il prossimo frame

	move	#Alt_plasm<<6+1,d3	; dimensione blittata
					; largh. 1 word, alta tutto il plasma

	moveq	#Largh_plasm-1,d2	; loop per tutta la larghezza
PlasmaLoop:				; inizio loop blittate

	move	(a3,d0.w),d1		; legge offset dalla tabella

	lea	(a0,d1.w),a2		; indirizzo di partenza = ind. colori
					; piu` offset

.WaitBlit:
	Btst	#6,dmaconr(a5)		; aspetta il blitter
	bne.s	.WaitBlit

	move.l	a2,bltapt(a5)		; BLTAPT - indirizzo sorgente
	move.l	a1,bltdpt(a5)		; BLTDPT - indirizzo destinazione
	move.w	d3,bltsize(a5)		; BLTSIZE

	addq.l	#4,a1			; punta a prossima colonna di 
					; "copper moves" nella copper list

	add	#NuovaRiga,d0		; modifica l'indice nella tabella
					; per la prossima riga

	and	#$00FF,d0		; tiene l'indice nell'intervallo
					; 0 - 255 (offset in una tabella di
					; 128 words)

	dbra	d2,PlasmaLoop

	rts


; Questa variabile contiene il valore dell'indice per la prima colonna
Indice	dc.w	0

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

COPPERLIST:

	wait	7,$40		; disegna barra rossa
	cmove	$C00,color00
	wait	7,$44
	cmove	$000,color00

; Qui viene lasciato dello spazio vuoto per il pezzo di copperlist che genera
; il plasma. Questo spazio viene riempito dalle routine dell'effetto.
PLASMA:	dcb.b	alt_plasm*BytesPerRiga,0

	wait	7,$e0		; disegna barra rossa
	cmove	$C00,color00
	wait	7,$e4
	cmove	$000,color00

	cstop

*****************************************************************************
; Qui c'e` la tabella di colori che viene scritta nel plasma.
; Devono esserci abbastanza colori da essere letti qualunque sia l'indirizzo
; di partenza. In questo esempio l'indirizzo di partenza puo` variare da
; "ColorTab" (primo colore) fino a "ColorTab+100" (50-esimo colore), perche`
; 100 e` il massimo offset sontenuto nella "SinTab".
; Se Alt_plasm=100 vuol dire che ogni blittata legge 100 colori.
; Quindi in totale devono esserci 150 colori.

ColorTab

	dc.w	$100,$200,$300,$400,$500,$600,$700
	dc.w	$800,$900,$A00,$B00,$C00,$D00,$E00,$F00

	dc.w	$F00,$E00,$D00,$C00,$B00,$A00,$900,$800
	dc.w	$700,$600,$500,$400,$300,$200

	dc.w	$002,$003,$004,$005,$006,$007
	dc.w	$008,$009,$00A,$00B,$00C,$00D,$00E,$00F

 dc.w $00e,$01d,$02d,$03d,$04d,$05d,$06d,$07d,$08d,$09d	; blu-verde
 dc.w $0Ad,$0Bd,$0Cd,$0Dd,$0Ed,$0Fd,$0Fd,$0Ed,$0Dd,$0Cd
 dc.w $0Bd,$0Ad,$09d,$08d,$07d,$06d,$05d,$04d,$03d,$02d
 dc.w $01d,$00e

 dc.w $00e,$01d,$02c,$03b,$04a,$059,$068,$077,$086,$095	; blu-verde
 dc.w $0A4,$0B3,$0C2,$0D1,$0E0


	dc.w	$0F0,$0E0,$0D0,$0C0,$0B0,$0A0,$090,$080
	dc.w	$070,$060,$050,$040,$030,$020,$010

	dc.w	$010,$020,$030,$040,$050,$060,$070
	dc.w	$080,$090,$0A0,$0B0,$0C0,$0D0,$0E0,$0F0

	dc.w	$1F0,$2F0,$3F0,$4F0,$5F0,$6F0,$7F0,$8F0
	dc.w	$9F0,$AF0,$BF0,$CF0,$DF0,$EF0,$FF0

	dc.w	$FF0,$EE0,$DD0,$CC0,$BB0,$AA0,$990,$880
	dc.w	$770,$660,$550,$440,$330,$220,$110

	end

;****************************************************************************

In questo esempio abbiamo un plasma 0 bitplanes.
L'effetto e` basato su un frammento di copperlist che viene costruito dalla
routine "InitPlasma". Tale frammento funziona in questo modo: per ogni riga
dello schermo effettua una serie di CMOVEs che cambiano il valore di COLOR00.
L'ultima CMOVE rimette il valore $000 (nero) in COLOR00. Si forma in
questo modo una tabella rettangolare di CMOVEs. Il numero di CMOVEs presenti in
ogni riga (esclusa quella finale che setta lo sfondo al nero) e` espresso dal
parametro "Largh_plasm". Il numero di righe che formano il plasma e` espresso
dal parametro "Alt_plasm". In totale abbiamo dunque un numero di CMOVEs (sempre
escludendo quelle che rimettono il nero) pari a Largh_plasm*Alt_plasm. La
routine "InitPlasma" non scrive i colori caricati da queste CMOVEs (cioe` non
scrive le seconde word). Questo compito e` lasciato alla routine "DoPlasma",
che viene eseguita ad ogni frame, e che ogni volta scrive dei valori diversi
nelle seconde words delle CMOVEs. La scrittura avviene mediante un loop di
blittate. Ogni blittata riempie una "colonna" di CMOVEs. Per esempio, la
prima blittata scrive la seconda word della prima CMOVE di ciascuna riga.
I valori dei colori vengono letti da una tabella. Ad ogni iterazione si leggono
i colori a partire da una diversa posizione nella tabella. Anche tra un frame e
l'altro la posizione di partenza viene variata. Tutte le variazioni della
posizione avvengono in base a tabelle e possono essere variate agendo sui
2 parametri "NuovaRiga" e "NuovoFrame". Notate che la routine e` stata
ottimizzata inizializzando tutti i registri del blitter all'inizio del
programma.
