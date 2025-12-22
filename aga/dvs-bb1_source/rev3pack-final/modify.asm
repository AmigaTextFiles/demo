*****************************************************************************
*                                                                           *
*	Modify.asm                                                          *
*	~~~~~~~~~~                                                          *
*	Description : The Modifiable variables used in this Pack !  	    *	
*			                                                    *
*	Code : Dennis Predovnik (SuLtAn/DVS)                                *
*	Date : 22/4/96                                                      *
*	Release Version : 1.0                                               *
*                                                                           *
*****************************************************************************

	section		modify_DaTa,code

;----------------------------- Scroll Text ----------------------------------

scrollMSG:
	dc.b "Devious bursts onto the Australian Scene again with a NEW production " 
	dc.b "entitled Blips n Beeps AGA coded by SuLtaN !    SultaN at tha keyz, "
	dc.b "This has been a fun "
	dc.b "project to code and look forward to more releases under tha "
	dc.b "Kool Devious label by me and others....     Instructions are as follows: Up,Down "
	dc.b "Keyz move cursor, Return Selectz music, Left mouse toggles module "
	dc.b "info of module which has cursor on, left again to go back to "
	dc.b "main menu, Right mouse Exitz...      This code waz ready months ago "  
	dc.b "but for sum reason or another it waz delayed....     "
	dc.b "Ok to get in touch with me then leave me a "
	dc.b "message on Psyche's board Terrafirma !!  For coding chat or anything "  
	dc.b "else remotely interesting.....  you can also contact me by mail "
	dc.b "to the address:  Dennis Predovnik  76 William St. Herne Hill 6056, Western Australia !! "
	dc.b "or on IRC #Amiga, #Amielite as Sultn\DVS       "
	dc.b "Oh yeah finally Hi's fly to the Rave Network Overscan (RNO) crew "
	dc.b "who I did join for about a week then joined the Devious Posse..    "
	dc.b "Hi TBC..  hope you like my first prod !! Ok enuff shit from me " 
	dc.b "and onto the other Devious members..            "  
	dc.b "Analyze at the keys now... Well what to say? This is Sultans first "
	dc.b "pack that he has coded entirely on his own and I think its quite "
	dc.b "impressive indeed, but enough sucking up to him for now (I dont know "
	dc.b "what I am sucking up for, maybe to get his sister!). Devious Dezigns "
	dc.b "disk mag VISION is almost due out and if your quick and willing, it "
	dc.b "isnt too late to send in some articles, clipart, modules, all is "
	dc.b "welcome. You will find the addresses somewhere in this production. "
	dc.b "Greetings to all.        "
	dc.b "Well,  now it is the Heavyweight at the keys..  Well.  what do I have to "
	dc.b "say?  Not very much actually..  Oh, only just watch out for my cool Devious "
	dc.b "Tools series..  Greets to all the people I know, and also to the ones that "
	dc.b "I don't know.. Later..              Credits go like this...   "
        dc.b "Code and Dezign: SuLtAn     GfX:"
        dc.b " Menu logo by Dvize   Other Gfx by Psyche      "
        dc.b "         Scroll Restarts                              ",EOT
	even
	
scrollPtr
	dc.l	scrollMSG

;--------------------------- End Scroll Text --------------------------------

;----------------------- Menu Text ------------------------------------
;--------->>>  Note :  Make Sure 6 (Six) Entries ONLY !!!!  <<<--------
;--------->>>          X is in Bytes (8 Pixels = 1 Byte ) ! <<<--------
;--------->>>          Y is in Linez !!                     <<<--------
;----------------------------------------------------------------------

menu1         ; X   Y
	dc.b	16,60,  "12345678",EOT
menu2
	dc.b	14,78,  "1234567890",EOT
menu3
	dc.b    16,96,  "MODULE 3",EOT
menu4
	dc.b	16,114, "MODULE 4",EOT
menu5
	dc.b    16,132, "MODULE 5",EOT
menu6
        dc.b    16,150, "MODULE 6",EOT
	even

;---------------------- End Menu Text --------------------------------

;--------------------- Module Info Text ------------------------------
;-------->>> Note : Same as ABOVE except for the following <<<--------
;-------->>>        Can be long as want except make sure   <<<--------
;-------->>>        EOB is at the end of your Module info. <<<--------
;-------->>>        Make sure DUMMYSZ is set to correct    <<<--------
;-------->>>        size as the others above it.. Fill it  <<<--------
;-------->>>        with "*"'s to achieve this !!          <<<--------
;---------------------------------------------------------------------


Info0         ; X  Y
	dc.b    11,68, "   Module Name   ",EOT
	dc.b	11,78, "   -----------   ",EOT
	dc.b    11,88, "                 ",EOT
	dc.b    11,98, " Author: Micheal ",EOT
	dc.b    11,108,"         Fisher  ",EOT
	dc.b    11,118,"                 ",EOT
	dc.b    11,128," Format: Tracker ",EOT
	dc.b    11,138," Date  : 14/4/96 ",EOT,EOB

Info1
	dc.b    11,68, "   Module Name   ",EOT
	dc.b	11,78, "   -----------   ",EOT
	dc.b    11,88, "                 ",EOT
	dc.b    11,98, " Author: Bennet  ",EOT
	dc.b    11,108,"         Fisher  ",EOT
	dc.b    11,118,"                 ",EOT
	dc.b    11,128," Format: Tracker ",EOT
	dc.b    11,138," Date  : 15/4/96 ",EOT,EOB

Info2
	dc.b    11,68, "   Module Name   ",EOT
	dc.b	11,78, "   -----------   ",EOT
	dc.b    11,88, "                 ",EOT
	dc.b    11,98, " Author: Aldo    ",EOT
	dc.b    11,108,"         Fisher  ",EOT
	dc.b    11,118,"                 ",EOT
	dc.b    11,128," Format: Tracker ",EOT
	dc.b    11,138," Date  : 16/4/96 ",EOT,EOB
	
Info3
	dc.b    11,68, "   Module Name   ",EOT
	dc.b	11,78, "   -----------   ",EOT
	dc.b    11,88, "                 ",EOT
	dc.b    11,98, " Author: Dipstick",EOT
	dc.b    11,108,"         Fisher  ",EOT
	dc.b    11,118,"                 ",EOT
	dc.b    11,128," Format: Tracker ",EOT
	dc.b    11,138," Date  : 17/4/96 ",EOT,EOB
	
Info4
	dc.b    11,68, "   Module Name   ",EOT
	dc.b	11,78, "   -----------   ",EOT
	dc.b    11,88, "                 ",EOT
	dc.b    11,98, " Author: Darren  ",EOT
	dc.b    11,108,"         Fisher  ",EOT
	dc.b    11,118,"                 ",EOT
	dc.b    11,128," Format: Tracker ",EOT
	dc.b    11,138," Date  : 18/4/96 ",EOT,EOB

Info5
	dc.b    11,68, "   Module Name   ",EOT
	dc.b	11,78, "   -----------   ",EOT
	dc.b    11,88, "                 ",EOT
	dc.b    11,98, " Author: Dopey   ",EOT
	dc.b    11,108,"         Fisher  ",EOT
	dc.b    11,118,"                 ",EOT
	dc.b    11,128," Format: Tracker ",EOT
	dc.b    11,138," Date  : 19/4/96 ",EOT,EOB
	even

DUMMYSZ dc.b       0,0,"*****************",EOT  ; This has to be same length
INFSIZE equ  *-DUMMYSZ                          ; as Linez above it.. Want
	even                                    ; more room make this bigger
                                                ; and the linez above bigger
                                                ; also, but make sure it's
                                                ; equal length with this !!
;--------------------- End Module Info Text --------------------------

;-------------------------- FADE TIME --------------------------------
;---->>>  Due to popular demand we have a fade DELAY           <<<---- 
;---->>>  Measured in Vertical Blanks.. ie 50 VB's = 1 Sec     <<<----
;---------------------------------------------------------------------

PDELAY	dc.w	5                               ; Pic Fade Delay
CDELAY	dc.w	3                               ; Cursor Fade Delay
TDELAY  dc.w	3				; Text Fade Delay

;------------------------ END FADE TIME ------------------------------

;--------------------- Cursor Variables ------------------------------

; Cursor Left Variables
CURL_X	   = 125       ; Left X         <<-- You can change this !!
CURL_Y     = 101       ; Left Y         <<-- IF Nessecary !!
CURL_YSTOP = CURL_Y+12 ; Left Y Stop    <<-- DON'T CHANGE !!

; Cursor Right Variables
CURR_X	   = 162       ; Right X        <<-- You can change this !!
CURR_Y     = 101       ; Right Y        <<-- IF Nessecary!!
CURR_YSTOP = CURR_Y+12 ; Right Y Stop   <<-- DON'T CHANGE !!

LINEHEIGHT = 18        ; Line Height !  <<-- IF Changed Text Y, Experiment !

;--------------------- EXE Variable ----------------------------------
;---->>> If your a smart ass and want for some reason to have <<<-----
;---->>> the cursor start on a different line then you must   <<<-----
;---->>> also change this... say you want the cursor to start <<<-----
;---->>> on line 1 instead of line 0 then change it from 0 to <<<-----
;---->>> 1, or if you want line 2 then change it to 2 etc..   <<<-----
;---->>> BUT don't forget to change the cursor variables !!!  <<<-----
;---->>> ALSO change the bit of assembler code to correspond  <<<-----
;---->>> with the initial music played at the start...        <<<-----
;---->>> IE say the you want MOD3 to play at the start then   <<<-----
;---->>> replace "lea.l Mod0,a0" with "lea.l MOD2,a0"...      <<<-----
;---->>> REMEMBER I start counting from Zero (0) !!!          <<<-----
;---------------------------------------------------------------------

exeVar	dc.w	0

initINIT:
	lea.l	Mod0,a0
	rts

;--------------------- End Cursor Variables --------------------------

;--------------------- Music (Pro-tracker format)---------------------
;--------------->>> IMPORTANT: Make Sure Un-Crunched <<<--------------
;---------------------------------------------------------------------

	section	ChiPData,code_c
Mod0
	incbin	"MODS/mod.1"
Mod1
	incbin	"MODS/mod.2"
Mod2
	incbin	"MODS/mod.3"
Mod3
	incbin	"MODS/mod.4"
Mod4
	incbin	"MODS/mod.5"
Mod5
	incbin	"MODS/mod.6"

;---------------------- End Music data -------------------------------

;------------------------- 8*8 Font ----------------------------------
;----------->>> IMPORTANT : Make sure it's a 8*8 font only <<<--------
;----------->>>             in RAW format...               <<<--------
;---------------------------------------------------------------------

FONT	 incbin "GFX/Font.raw"

;----------------------- End 8*8 Font -------------------------------- 

