/******************************************************************************
*
*	GlobeDemo.c v1.0 6/20/88  COPYRIGHT 1988 BOB CORWIN JR.
*
*	Inspired by "FRAMEDEMO" demo written by Sun Microsystems(TM)
*	for their UNIX-based workstations.
*
*	Very simple frame animator. Looks for image 
*	files in dir "GLOBEIMAGES:" with names "Fxx" Where xx 
*	is a number from 01 to 30 representing RAW IMAGE BIT
*	PLANE data dimensioned 128x64x2. If dir not found attemps to load
*	from current directory. Works under amigaDOS and workbench.
*	And icon is provided for workbench use.
*
*	Uses Mouse-Relative 'Pop-Up' menus code written by DEREK ZAHN 
*	(Gambit Software, Madison WI), July 1987 ("DEREK, I REALLY LIKE
*	YOUR POPUP MENUS,  THEY'RE SO EASY TO USE!")
*
*	This version functions in both High & Medium Resolution modes;
*	however, the globeframes were designed for use in 
*	medium resolution displays (640x200).
*
*	MAY BE FREELY DISTRIBUTED PROVIDED THIS HEADER IS INCLUDED.
*	THIS IS FREEWARE HOWEVER, IF YOU USE IT LET ME KNOW WHAT YOU
*	THINK OF IT.
*
*	BOB CORWIN 			USENET: kodak!bc@ektools
*	3 MELONIE DRIVE
*	BROCKPORT, NEW YORK 14420
*	(716)638-6361
*							        
******************************************************************************/

#include <exec/types.h>
#include <exec/memory.h>
#include <libraries/dos.h>
#include <libraries/dosextens.h>
#include <intuition/intuitionbase.h>
#include <intuition/intuition.h>
#include <graphics/gfxmacros.h>
#include "popmenu.h"			/** HEADER FOR RELATIVE MENUS **/

extern LONG PopChoose();		/** RELATIVE MENUS 'MAIN' FUNCTION **/
typedef struct Window WINDOW;
typedef struct FileLock *LOCK;

struct GfxBase *GfxBase;
struct IntuitionBase *IntuitionBase;

#define FRAMES 30

#define FASTER  0
#define SLOWER  1
#define COLORS  2
#define ABOUT   3
#define QUIT    4

					/** FILE NAMES FOR IMAGES **/
UBYTE FileNames[30][4] = { "f01","f02","f03","f04","f05","f06","f07","f08",
		"f09","f10","f11","f12","f13","f14","f15","f16","f17","f18",
		"f19","f20","f21","f22","f23","f24","f25","f26","f27","f28",
		"f29","f30" };

struct NewWindow newwindow = { 		/** DEMO'S WINDOW	  **/
	100,100,
	138,80,
	-1,-1,
	MOUSEBUTTONS,			/** RMBTRAP FOR POPUP MENU USE **/
	WINDOWDRAG|SIMPLE_REFRESH|ACTIVATE|NOCAREREFRESH|RMBTRAP ,
	NULL,
	NULL,
	"Globe Demo",
	NULL,
	NULL,
	NULL,NULL,NULL,NULL,
	WBENCHSCREEN 
};
struct NewWindow about_window = { 	/** WINDOW FOR DEMO'S INFO REQUESTER **/
	12,22,
	356,78,
	-1,-1,
	REQCLEAR,
	SIMPLE_REFRESH|NOCAREREFRESH|RMBTRAP,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,NULL,NULL,NULL,
	WBENCHSCREEN 
};

WINDOW *GlobeWindow, *ReqWindow;

struct Gadget about_gadget = {	     /** GADGET STRUCTURE FOR INFO REQUESTER **/
	NULL,
	4,2,340,70,
	GADGHCOMP,
	GADGIMMEDIATE|RELVERIFY|ENDGADGET,
	REQGADGET|BOOLGADGET,
	NULL,
	NULL,	
	NULL,
	NULL, NULL, NULL, NULL
};
struct IntuiText about_text4 = {     /** TEXT STRUCTURE FOR INFO REQUESTER **/
	(UBYTE) 0, (UBYTE) 1,
	JAM1,
	(SHORT) 10, (SHORT) 52,
	NULL,
	(UBYTE *) "POPUP Menus support by DEREK ZAHN ",
	NULL
};
struct IntuiText about_text3 = {
	(UBYTE) 0, (UBYTE) 1,
	JAM1,
	(SHORT) 10, (SHORT) 42,
	NULL,
	(UBYTE *) "by Sun Microsystems.",
	&about_text4
};
struct IntuiText about_text2 = {
	(UBYTE) 0, (UBYTE) 1,
	JAM1,
	(SHORT) 10, (SHORT) 32,
	NULL,
	(UBYTE *) "Inspired by demo 'Framedemo' ",
	&about_text3
};
struct IntuiText about_text1 = {
	(UBYTE) 1, (UBYTE) 0,
	JAM2,
	(SHORT) 10, (SHORT) 12,
	NULL,
	(UBYTE *) " GLOBE DEMO copyright 1988 by BOB CORWIN ",
	&about_text2
};

struct Requester about_request = {
	NULL,
	4,2,348,74,
	0,0,
	(struct Gadget *)&about_gadget,
	NULL, /* about_border */
	&about_text1,
	NULL,	/* FLAGS */
	2,	/* BACKFILL */
	NULL,
	{ NULL },
	NULL,
	NULL,
	{ NULL }

};

struct IntuiText globe_text5_text = {    /** POP-UP MENU TEXT **/
	(UBYTE) 0, (UBYTE) 1,
	JAM1,
	(SHORT) 10, (SHORT) 2,
	NULL,
	(UBYTE *) "Quit",
	NULL
};

struct MenuItem globe_text5 = {
	NULL,
	(SHORT) 0, (SHORT) 40,
	(SHORT) 80, (SHORT) 10,
	(USHORT) (ITEMTEXT | HIGHCOMP | ITEMENABLED),
	(LONG) 0,
	(APTR) &globe_text5_text,
	NULL,
	(BYTE) 0,
	NULL,
	(USHORT) 0
};


struct IntuiText globe_text4_text = {
	(UBYTE) 0, (UBYTE) 1,
	JAM1,
	(SHORT) 10, (SHORT) 2,
	NULL,
	(UBYTE *) "About...",
	NULL
};

struct MenuItem globe_text4 = {
	&globe_text5,
	(SHORT) 0, (SHORT) 30,
	(SHORT) 80, (SHORT) 10,
	(USHORT) (ITEMTEXT | HIGHCOMP | ITEMENABLED),
	(LONG) 0,
	(APTR) &globe_text4_text,
	NULL,
	(BYTE) 0,
	NULL,
	(USHORT) 0
};

struct IntuiText globe_text3_text = {
	(UBYTE) 0, (UBYTE) 1,
	JAM1,
	(SHORT) 10, (SHORT) 2,
	NULL,
	(UBYTE *) "COLORS",
	NULL
};

struct MenuItem globe_text3 = {
	&globe_text4,
	(SHORT) 0, (SHORT) 20,
	(SHORT) 80, (SHORT) 10,
	(USHORT) (ITEMTEXT | HIGHCOMP | ITEMENABLED),
	(LONG) 0,
	(APTR) &globe_text3_text,
	NULL,
	(BYTE) 0,
	NULL,
	(USHORT) 0
};

struct IntuiText globe_text2_text = {
	(UBYTE) 0, (UBYTE) 1,
	JAM1,
	(SHORT) 10, (SHORT) 2,
	NULL,
	(UBYTE *) "SLOWER",
	NULL
};

struct MenuItem globe_text2 = {
	&globe_text3,
	(SHORT) 0, (SHORT) 10,
	(SHORT) 80, (SHORT) 10,
	(USHORT) (ITEMTEXT | HIGHCOMP | ITEMENABLED),
	(LONG) 0,
	(APTR) &globe_text2_text,
	NULL,
	(BYTE) 0,
	NULL,
	(USHORT) 0
};

struct IntuiText globe_text1_text = {
	(UBYTE) 0, (UBYTE) 1,
	JAM1,
	(SHORT) 10, (SHORT) 2,
	NULL,
	(UBYTE *) "FASTER",
	NULL
};

struct MenuItem globe_text1 = {
	&globe_text2,
	(SHORT) 0, (SHORT) 0,
	(SHORT) 80, (SHORT) 10,
	(USHORT) (ITEMTEXT | HIGHCOMP | ITEMENABLED),
	(LONG) 0,
	(APTR) &globe_text1_text,
	NULL,
	(BYTE) 0,
	NULL,
	(USHORT) 0
};

struct Menu globe_menu = {
	NULL,
	(SHORT) -1 * ((50 + POPTITLEHEIGHT) / 2),
	(SHORT) -1 * POPTITLEHEIGHT / 2,
	(SHORT) 80, (SHORT) 50 + POPTITLEHEIGHT,
	(USHORT) (MENUENABLED | POPTIDY | POPPOINTREL | POPRIGHTBUTTON | 
		  POPREMEMBER | POPTRIGGERUP),
	(BYTE *) "Goodies",
	&globe_text1
};

					/** ALTERNATE COLORS FOR GLOBE **/

UWORD colortab2[5][3] = { 4, 4, 15, 4, 4, 15,  4, 4, 15, 15, 14, 0, };
UWORD colortab3[5][3] = { 0, 9,  5, 0, 0,  0, 13, 0,  5,  0,  7, 0, };



LOCK launchDir, imageDir;

struct RastPort *rastPort;

struct MsgPort *GlobePort;

struct GlobeMsg {
	struct Message Msg;
	UBYTE *images[FRAMES];	/** POINTERS TO IMAGE DATA FOR ALL INSTANCES **/
	UWORD color_2R;		/** OF THIS PROGRAM TO SHARE.		     **/
	UWORD color_2G;
	UWORD color_2B;
	UWORD color_3R;
	UWORD color_3G;
	UWORD color_3B;
	} globeMsg;	


struct BitMap bitmap[FRAMES];

/*******************************************************************************
*
* InitGlobePort() 
*
*	This function initializes a MsgPort for all instances of this porgram
*   to share. When 2nd and subsequent invocations of this program call this
*   function, previous invocations are searched out and if found provide 
*   pointers to the globedemo image data and also original the WorkBench colors,
*   #2 & #3 which are to be restored on exit of the last copy of the program.
*
*******************************************************************************/

BOOL InitGlobePort() {
UWORD t;
BOOL found_port;
struct GlobeMsg *gmsg;

  if(( GlobePort = (struct MsgPort *)FindPort("GlobeMR.Niwroc")) != 0) {
    found_port = TRUE;

    Forbid();
    gmsg = (struct GlobeMsg *)GlobePort->mp_MsgList.lh_Head;
    for(t=0; t < FRAMES; t++)
      globeMsg.images[t] = gmsg->images[t];    
      globeMsg.color_2R = gmsg->color_2R;
      globeMsg.color_2G = gmsg->color_2G;
      globeMsg.color_2B = gmsg->color_2B;
      globeMsg.color_3R = gmsg->color_3R;
      globeMsg.color_3G = gmsg->color_3G;
      globeMsg.color_3B = gmsg->color_3B;
    Permit();

  }
  else found_port = FALSE;

  GlobePort = (struct MsgPort *)CreatePort("GlobeMR.Niwroc",0); 

  return(found_port);
     
}

/*******************************************************************************
*
* SamaritanCleanUp(gp) 
*
*	This function searches for a resident port indicating a continuing need
* for access to the GlobeDemo Image data. It returns either 30 or 0, indicating 
* the number of image frames to deallocate.
*
*******************************************************************************/

UWORD SamaritanCleanUp(gp) struct MsgPort *gp; {
struct MsgPort *gport;
UWORD frames2free;


   if(((gport = (struct MsgPort *)FindPort("GlobeMR.Niwroc")) != 0) && 
	gport != gp) frames2free = 0;
	
   else
        if((gport = (struct MsgPort *)FindName(gport,"GlobeMR.Niwroc")) != 0)
		frames2free = 0;

   else frames2free = FRAMES;

   DeletePort(gp);
   return(frames2free);

}


/*******************************************************************************
*
* AllocBitMap(bm), FreeBitMap(bm), LoadBitMap(file,bm,colors)
*
* These Routines were borrowed from EA/COMMODORE IFF FILES & cropped for use
* in this program.
*
*******************************************************************************/

UBYTE *AllocBitMap(bm) struct BitMap *bm; {
    int i;
    LONG psz = bm->BytesPerRow*bm->Rows;
    UBYTE *ptr, *p = (UBYTE *)AllocMem(bm->Depth*psz, MEMF_CHIP|MEMF_PUBLIC);
    ptr = p;
    for (i=0; i<bm->Depth; i++)  { 
	bm->Planes[i] = p;
	p += psz;
	}
    return(ptr);

    }

void FreeBitMap(bm) struct BitMap *bm;  {

    if (bm->Planes[0])  {
	FreeMem(bm->Planes[0], bm->BytesPerRow * bm->Rows * bm->Depth);
	}
    }

VOID LoadBitMap(file,bm,colors)	/*** LOAD IMAGE FILE INTO BITMAP ***/
    LONG file;	
    struct BitMap *bm;
    SHORT *colors;
    {
    SHORT i;
    LONG number, plane_size;
    plane_size = bm->BytesPerRow*bm->Rows;
    for (i=0; i<bm->Depth; i++) {
	number =  Read(file, bm->Planes[i], plane_size);
	if (number<plane_size) BltClear(bm->Planes[i],plane_size,1);
	}

    }



/** main() ******************************************************************/

	
void main()  
{
    struct IntuiMessage *message, *reqmsg;
    ULONG class;
    UWORD code;
    WORD  gwidth,gheight,gdepth;		/** IMAGE DIMENSIONS **/
    LONG  file, loop, frame, delay, t, val;
    struct ViewPort *viewport;
    struct ColorMap *colormap;
    UWORD color2, color3, c;			/** USERS DEFAULT COLORS **/
    UWORD color2R, color2G, color2B, color3R, color3G, color3B;
    BOOL  resident;				/** TRUE IF ANOTHER INSTANCE **/
						/** OF PROGRAM IS RUNNING    **/

    if( !(GfxBase = (struct GfxBase *)OpenLibrary("graphics.library",0)) ){
	exit(0);
    }

    if( !(IntuitionBase = (struct IntuitionBase *)
  	OpenLibrary("intuition.library",0)) ) {
          goto jail1;
    }

    delay  = 4;		/** DEFAULT INTERVAL BETWEEN GLOBEFRAMES **/

    gwidth  = 128;	/** GLOBE DIMENSIONS **/
    gheight = 64;
    gdepth  = 2;

	/********** LOOK FOR FOR EXISTING PORT & CREATE NEW PORT ************
	*								    *
	* First look for the existance of another port. If one exists, use  *
	* it's copy of image pointers. No need to load further copies of    *
	* image data, initialize new BitMap only			    *
	*								    *
	*********************************************************************/

    if((resident = InitGlobePort()) == TRUE) {
       for(loop = 0; loop < FRAMES; loop++) {
 	  InitBitMap(&bitmap[loop], gdepth, gwidth, gheight);
	  bitmap[loop].Planes[0] = globeMsg.images[loop];
	  bitmap[loop].Planes[1] = globeMsg.images[loop]+1024;
       }

    }
    else {
		/**********************************************************
		*							  *
		* Look for images in directory "GLOBEIMAGES". If no such  *
		* directory exists look in current directory. If images   *
		* still arn't found nothing to do but exit.		  *
		*							  *
		**********************************************************/

	if((imageDir  = (LOCK)Lock("GLOBEIMAGES", ACCESS_READ)) != 0)
	   launchDir = (LOCK)CurrentDir(imageDir);
	
	for(loop = 0; loop < FRAMES; loop++) {
	
 	    file = Open(&FileNames[loop], MODE_OLDFILE);
	    if(!file) {
		if(imageDir) {
		  for(t = 0; t < loop; t++) {
		    FreeBitMap(&bitmap[t]);		
                  }

        	} 
		else {
		}

	      (VOID)SamaritanCleanUp(GlobePort);
	      goto jail3;

	    }
 	    InitBitMap(&bitmap[loop], gdepth, gwidth, gheight);
	    globeMsg.images[loop] = AllocBitMap(&bitmap[loop]);
	    LoadBitMap(file,&bitmap[loop], NULL);
	    Close(file);
        }
    }
	

	if((GlobeWindow = (WINDOW *)OpenWindow(&newwindow)) == 0) {
	  goto jail4;
	}

	viewport = (struct ViewPort *)ViewPortAddress(GlobeWindow);
	rastPort = GlobeWindow->RPort;

	/*********************************************************************
	*
	*  Get & Save original colors for clean User-Friendly exit.
	*
	*********************************************************************/
	if(!(resident)) {
		colormap = viewport->ColorMap;

		color2  = GetRGB4(colormap, 2);
		color2B = color2 & 15;
		color2G = (color2 >> 4) & 15;
		color2R = (color2 >> 8) & 15;

		color3  = GetRGB4(colormap, 3);
		color3B = color3 & 15;
		color3G = (color3 >> 4) & 15;
		color3R = (color3 >> 8) & 15;

		globeMsg.color_2R = color2R;
		globeMsg.color_2G = color2G;
		globeMsg.color_2B = color2B;
		globeMsg.color_3R = color3R;
		globeMsg.color_3G = color3G;
		globeMsg.color_3B = color3B;
	}

	colortab2[4][0] = globeMsg.color_2R;
	colortab2[4][1] = globeMsg.color_2G;
	colortab2[4][2] = globeMsg.color_2B;
	colortab3[4][0] = globeMsg.color_3R;
	colortab3[4][1] = globeMsg.color_3G;
	colortab3[4][2] = globeMsg.color_3B;

	PutMsg(GlobePort,(struct Message *)&globeMsg);

	c = 0;

	SetRGB4(viewport, 2, colortab2[0][0], colortab2[0][1], colortab2[0][2]);
	SetRGB4(viewport, 3, colortab3[0][0], colortab3[0][1], colortab3[0][2]);
	
	/*********************************************************************
	*
	* Main Pop-Up Menu event loop - Normal Menu button events are trapped
	* so Intuition just passes them on to us without acting on them. More
	* information can be found in the POPMENU documentation.
	*
	*********************************************************************/

        while(1) {
	  for(frame = 0; frame < FRAMES; frame++) {

		while(message = (struct IntuiMessage *)
		GetMsg(GlobeWindow->UserPort)) {
			class = message->Class;
			code = message->Code;
			ReplyMsg(message);
			switch(class) {
			  case MOUSEBUTTONS:
			  	switch(code) {

				  case MENUDOWN:
					val = (SHORT) PopChoose(&globe_menu,
					  NULL);

					switch(val) {
						case FASTER: if(delay > 7) 
								delay -= 4;
							else	
							if(delay > 5) 
								delay -= 2;
							else
							if(delay > 0)
								delay--;
							break;

						case SLOWER: if(delay < 4) 
								delay++;
							else
							if(delay < 7)
								delay += 2;
							else
								delay += 4;
		 					break;

case COLORS: 
   if(++c > 4) c = 0;
   SetRGB4(viewport, 2, colortab2[c][0], colortab2[c][1], colortab2[c][2]);
   SetRGB4(viewport, 3, colortab3[c][0], colortab3[c][1], colortab3[c][2]);

   break;

			case ABOUT: 
				if((ReqWindow = (WINDOW *)
				OpenWindow(&about_window)) != NULL) {

				BltBitMapRastPort(&bitmap[frame],0,0,rastPort,
				5,12,128,64,0xc0);

				(VOID)Request((struct Requester *)
						&about_request,	ReqWindow);

				Wait(1<<ReqWindow->UserPort->mp_SigBit);
					reqmsg = (struct IntuiMessage *)
					GetMsg(ReqWindow->UserPort);

					ReplyMsg(reqmsg);
					CloseWindow(ReqWindow); 
				}
				break;

			case QUIT: 
				goto jail5;					
				default: break;
				}
				break;

			  default: break;
			}
			break;

		  default: break;
		}

	    }

	    /** THIS IS THE WHOLE PROGRAM IN A SINGLE LINE **/
	    BltBitMapRastPort(&bitmap[frame],0,0,rastPort,5,12,128,64,0xc0);
	    Delay(delay);
          }
	}


    /***************************************************************************
    *
    *  CLEAN UP CLEAN UP CLEAN UP CLEAN UP CLEAN UP CLEAN UP CLEAN UP CLEAN UP 
    *
    ***************************************************************************/

    jail5:
	if(GlobeWindow) CloseWindow(GlobeWindow);

    jail4:

    /** LAST INSTANCE OF PROGRAM TO EXIT RETURNS MEMORY AND RESTORES COLORS **/


	if((t = SamaritanCleanUp(GlobePort)) != 0) {
           SetRGB4(viewport,2,colortab2[4][0],colortab2[4][1],colortab2[4][2]);
           SetRGB4(viewport,3,colortab3[4][0],colortab3[4][1],colortab3[4][2]);
	}

	while(t-- > 0) {
	  FreeBitMap(&bitmap[t]);
	}


    jail3:    
	if(launchDir) (VOID)CurrentDir(launchDir);
	if(imageDir) UnLock(imageDir);
	
    jail2:
	if(IntuitionBase) CloseLibrary(IntuitionBase);

    jail1:
	if(GfxBase) CloseLibrary(GfxBase);
	exit(0);
  }




