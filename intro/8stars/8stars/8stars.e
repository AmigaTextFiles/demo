/********* PUBLIC DOMAIN *************/

MODULE 'intuition/intuition',
       'intuition/screens',
	   'exec/memory' ,
	    'other/random' -> from http://aminet.net/package/dev/e/random

DEF 	screenPtr=NIL:PTR TO screen,
		picStarImage:PTR TO image,
		picEmpty:PTR TO image
		
OBJECT star
	state
	x
	y
	key
ENDOBJECT
		
DEF tabStars[20]:ARRAY OF LONG		
		
PROC main()
	
	seedRand()
	initPicStar()
	initStars()
	
	screenPtr:=OpenScreen([0, 0, 320,  240, 3, 0, 0, NIL, 
                      CUSTOMSCREEN	OR SCREENQUIET, 
                      NIL, NIL, NIL, NIL, NIL ]:extnewscreen)

	IF 	screenPtr			 
					 
	LoadRGB4(screenPtr.viewport,[$0000,$0222,$0444,$0666, $0999,$0BBB,$0DDD,$0FFF]:INT, 8)
	

		drawRandomStars()
	
		drawFinalsStars()
		
		Delay(10)
		
		WHILE TRUE
			hide8stars()
			IF (testLeftMouseButton()=FALSE) THEN JUMP endloop
			Delay (10)
			IF (testLeftMouseButton()=FALSE) THEN JUMP endloop
			show8stars()
			IF (testLeftMouseButton()=FALSE) THEN JUMP endloop
			Delay (10)
			IF (testLeftMouseButton()=FALSE) THEN JUMP endloop

		ENDWHILE
		
		endloop:
		
		CloseScreen(screenPtr)
	
	ENDIF
	
	CleanUp(0)
	   
ENDPROC

PROC drawRandomStars()

	DEF i
	
	FOR i:=0 TO 200
		drawStar( getRandRange(20) )
	ENDFOR	


ENDPROC

PROC testLeftMouseButton()

		BTST.B	#6,$bfe001
		BNE		mousePressed

		RETURN FALSE
		
	mousePressed:	
		RETURN TRUE
ENDPROC

PROC drawStar(nr, random=TRUE)

	DEF s:PTR TO star, img
	s:=tabStars[nr]
	
	IF  random = TRUE 
		IF s.state=1
			img:=picEmpty
			s.state:=0
		ELSE
			img:=picStarImage
			s.state:=1
		ENDIF
	ELSE 
		IF s.key=1
			img:=picStarImage
		ELSE
			img:=picEmpty
		ENDIF
	ENDIF
	
	DrawImage( screenPtr.rastport, img, s.x, s.y )
	
	wait4VBlank()
	
ENDPROC

PROC drawFinalsStars()
	DEF i
	
	FOR i:=0 TO 19
		drawStar(i, FALSE)
	ENDFOR	

ENDPROC

PROC hide8stars()

	DEF i, s:PTR TO star
	
	FOR i:=5 TO 13
		IF i <> 10
			s:=tabStars[i]
			DrawImage( screenPtr.rastport, picEmpty, s.x, s.y )
		ENDIF
	ENDFOR	

ENDPROC

PROC show8stars()

	DEF i, s:PTR TO star
	
	FOR i:=5 TO 13
		IF i <> 10
			s:=tabStars[i]
			DrawImage( screenPtr.rastport, picStarImage, s.x, s.y )
		ENDIF
	ENDFOR	

ENDPROC

PROC initPicStar()

	DEF m
	
	CopyMem({picStarLabel},m:=NewM( 40*40*3, MEMF_CHIP ),  40*40*3)
	
	picStarImage:=New ( SIZEOF image)

	picStarImage.leftedge:=0
	picStarImage.topedge:=0
	picStarImage.width:=40
	picStarImage.height:=40
	picStarImage.depth:=3
	picStarImage.imagedata:=m
	picStarImage.planepick:=7
	picStarImage.planeonoff:=0
	picStarImage.nextimage:=0
	
	m:=NewM( 40*40, MEMF_CHIP OR MEMF_CLEAR )
	
	picEmpty:=New ( SIZEOF image)
	
	picEmpty.leftedge:=0
	picEmpty.topedge:=0
	picEmpty.width:=40
	picEmpty.height:=40
	picEmpty.depth:=1
	picEmpty.imagedata:=m
	picEmpty.planepick:=0
	picEmpty.planeonoff:=0
	picEmpty.nextimage:=0

ENDPROC

PROC initStars()
	
	DEF x,y, index, ptr:PTR TO star
	
	FOR y:=0 TO 3 
		FOR x:=0 TO 4
		
			ptr:=New (SIZEOF star)
			ptr.x := 20+ (x*60)
			ptr.y := 10+ (y*60)
			
			index:=(5*y) +x
						
			IF ( (index > 4) AND (index <14) AND (index <> 10 ) )
				ptr.key := 1
			ELSE
				ptr.key :=0
			ENDIF
			
			tabStars[index]:=ptr
			
		ENDFOR
	ENDFOR
ENDPROC

PROC wait4VBlank()

	->from https://eab.abime.net/showpost.php?p=657152&postcount=2

	DEF line
	line := Shl (303,8)	
	
	loop:
	MOVE.L	$dff004,D0
	AND.L	#$1ff00,D0
	CMP.L	line,D0
	BNE.B	loop
ENDPROC

version:
CHAR '$VER: JEBAC PIS!!!',0

picStarLabel:
INCBIN 'gfx/star.raw'