/*
 *  The functions for pop-up menus
 *
 *  Written by Derek Zahn (Gambit Software, Madison WI), July 1987
 *
 *  This code is freely distributable and is blessed by its author for
 *  inclusion, in this form or any other, into Amiga programs,
 *  commercial or non-commercial.  If this is done, no credit must be
 *  given to me (although I wouldn't mind).
 *
 *  This code was developed and tested under Manx Aztec C, version 3.40a
 *  with small code, small data, and short integers as part of the Gambit
 *  Software development environment.  It has been "unGambitized" for
 *  general use.  I am unfamiliar with other Amiga C compilers, so cannot
 *  speculate on any porting difficulties.  This file was created with a
 *  text editor (Z) whose tabstops were set to 8, so that it may be easily
 *  and intelligibly printed.  This code was developed under 1.2; I am
 *  not sure if it will work under 1.1, but can't see why not.
 *
 *  Note that there are some features that should be supported but are not,
 *  and some issues about the function and interface that make me nervous.
 *  These are explained in the appendix to the documentation.  I would
 *  greatly appreciate receiving any enhancements and modifications to this
 *  code, or suggestions therefor.  Comments on techniques and coding
 *  style are always appreciated.  Enjoy.
 */

/* include files */

#include <exec/types.h>
#include <intuition/intuitionbase.h>
#include <intuition/intuition.h>
#include <graphics/gfxmacros.h>
#include "popmenu.h"

/* Externally defined functions used in this module */

extern struct Window *OpenWindow();
extern struct IntuiMessage *GetMsg(); /* type coercion, true... */
extern VOID CloseWindow(), ReplyMsg(), Wait();
extern VOID RectFill(), Move(), Draw(), Text(), PrintIText(), DrawImage();

/* The following functions are defined in this module */

extern LONG PopChoose();  /* blocking user interface -- exported */
extern SHORT pop_computestate(); /* see who is selected, if anybody */
extern VOID pop_highlight(); /* highlight the specified item */
extern VOID pop_unhighlight(); /* unhighlight the specified item */
extern VOID pop_do_highlighting(); /* high or un high light the item */
extern VOID pop_render(); /* draws the title (if existent) and menu items */
extern VOID pop_draw_menuitem(); /* draws the menu item */
extern struct MenuItem *pop_getitem(); /* find a MenuItem struc */
extern SHORT pop_strlen(); /* local strlen() */

/* This is structure will be used to create a window for display of the    */
/* menu.  In my heart of hearts, I wanted to use graphics library          */
/* functions instead, but reason prevailed.  Note the use of the RMBTRAP   */
/* flag -- while the pop-up menu is being processed, there is no use for   */
/* the right button.  Perhaps this should only be set if the right button  */
/* has some bearing on the pop-up menu.                                    */

static
struct NewWindow pop_window = {
	0, 0, /* LeftEdge, TopEdge: will be filled in later */
	0, 0, /* Width, Height: will be filled in later */
	(UBYTE) -1, (UBYTE) -1, /* BlockPen, DetailPen */
	MOUSEBUTTONS | MOUSEMOVE, /* IDCMP flags */
	SMART_REFRESH | REPORTMOUSE | ACTIVATE | RMBTRAP, /* flags */
	NULL, /* no gadgets */
	NULL, /* checkmark inherited later */
	NULL, /* no title */
	NULL, /* Screen -- will be filled in later */
	NULL, /* No custom bitmap */
	0, 0, /* MinWidth, MinHeight -- no change in size necessary */
	0, 0, /* MaxWidth, MaxHeight -- no change in size necessary */
	CUSTOMSCREEN /* always use this value */
};

/* It is assumed that the following point to bases of opened libraries     */

extern struct IntuitionBase *IntuitionBase;
extern struct GfxBase *GfxBase;

/*
 * PopChoose(menu, win)
 * menu -- pointer to the menu to pop
 * win -- the window to which this menu relates.  NULL means the currently
 * active window.
 *
 * This function provides a blocking pop-up menu.  It returns (LONG) -1 if 
 * either an error occurred attempting to pop or if no selection was made
 * by the user.  If a selection was made, a LONG between 0 and n-1, where
 * n is the number of Menu Items.
 *
 * -1 is also returned if a selection of a checked item was made.
 *
 * Since this code opens a window, it is up to the caller to be sure that
 * no scribbling in droll ways is done while this code is in progress.
 */

LONG
PopChoose(menu, win)
struct Menu *menu;
struct Window *win;
{
	struct Screen *screen; /* the window's screen */
	struct Window *popwin; /* the pop-up menu */
	struct IntuiMessage *message; /* our eyes and ears */
	struct MenuItem *sel_item; /* the selected item */
	SHORT pop_state, pop_newstate; /* menu selection state varaibles   */
	SHORT mouse_moved; /* keeps track of whether the mouse has moved   */
	SHORT finished; /* set when menu should be blown away */
	SHORT class; /* incoming IntuiMessage class */
	SHORT code; /* incoming IntuiMessage code */
	ULONG exclude; /* for handling mutual exclusion */

	/* Check to see that IntuitionBase and GfxBase are non-null.       */
	/* While this is not any sort of guarantee against disaster, it    */
	/* is better than nothing.                                         */

	if((IntuitionBase == NULL) || (GfxBase == NULL))
		return((LONG) (-1));

	/* One paranoid check */

	if(menu == NULL)
		return((LONG) (-1));

	/* If the menu is not MENUENABLED, nothing to do                   */

	if(!(menu->Flags & MENUENABLED))
		return((LONG) (-1));

	/* Form the menu window to blast forth into the Visual World. Note */
	/* the unconventional (and inconsistent with Intuition) ways that  */
	/* the Width and Height fields are used here.                      */

	pop_window.Width = menu->Width;
	pop_window.Height = menu->Height;

	if(win == NULL)
		win = IntuitionBase->ActiveWindow;
	if(win == NULL) /* panic */
		return((LONG) (-1));

	/* Inherit CheckMark from the "parent" window                      */

	if(win->CheckMark)
		pop_window.CheckMark = win->CheckMark;

	screen = win->WScreen;
	pop_window.Screen = screen;

	pop_window.LeftEdge = menu->LeftEdge;
	pop_window.TopEdge = menu->TopEdge;

	/* if we are supposed to return to the last-selected menu item and */
	/* such a beast exists, all other positioning information (except  */
	/* POPTIDY) will be circumvented.  The menu will appear under the  */
	/* pointer with the last-chosen item pre-selected, if this is      */
	/* possible given the POPTIDY flag and the screen constraints.     */
	/* In this case, the LeftEdge and TopEdge fields of the menu       */
	/* structure will have been altered (I know, ick!) to provide a    */
	/* relative offset with respect to the pointer to do the deed      */

	if((menu->Flags & POPREMEMBER) && (menu->Flags & POPUSED)) {
		pop_window.LeftEdge += screen->MouseX;
		pop_window.TopEdge += screen->MouseY;
	}
	else {
		if(menu->Flags & POPPOINTREL) {
			pop_window.LeftEdge += screen->MouseX;
			pop_window.TopEdge += screen->MouseY;
		}
		else if(menu->Flags & POPWINREL) {
			pop_window.LeftEdge += win->LeftEdge;
			pop_window.TopEdge += win->TopEdge;
		}
	}

	/* If the caller wishes us to be POPTIDY, the menu must completely */
	/* appear on the screen, whatever other effects this may have on   */
	/* menu positioning.  The left edge and top edge must be altered   */
	/* accordingly.  In the pathological case where the menu is larger */
	/* than the screen, -1 is returned.                                */
	/* If poptidiness is not a factor, the size of the window may have */
	/* to be altered if it shoots off the bottom or right edge of the  */
	/* screen.  There should be some similar mechanism to deal with    */
	/* the menu if it extends past the top or left edge of the screen; */
	/* as it stands now, the OpenWindow() call will fail, and the      */
	/* result may be even more dire under 1.1.  Use 1.2!               */

	if(menu->Flags & POPTIDY) {
		if((pop_window.Width > screen->Width) || 
		   (pop_window.Height > screen->Height))
		   	return((LONG) (-1));
		if(pop_window.LeftEdge + pop_window.Width > screen->Width)
			pop_window.LeftEdge = screen->Width-pop_window.Width;
		if(pop_window.TopEdge + pop_window.Height > screen->Height)
			pop_window.TopEdge=screen->Height-pop_window.Height;
		if(pop_window.LeftEdge < screen->LeftEdge)
			pop_window.LeftEdge = screen->LeftEdge;
		if(pop_window.TopEdge < screen->TopEdge)
			pop_window.TopEdge = screen->TopEdge;
	}
	else {
		if(pop_window.LeftEdge + pop_window.Width > screen->Width)
			pop_window.Width = screen->Width - 
			  pop_window.LeftEdge;
		if(pop_window.TopEdge + pop_window.Height > screen->Height)
			pop_window.Height = screen->Height -
			  pop_window.TopEdge;
	}

	/* There!  Finally, the window is ready to be displayed!  First,   */
	/* create it.                                                      */

	popwin = OpenWindow(&pop_window);
	if(popwin == NULL) /* all that work for nuthin' */
		return((LONG) (-1));

	/* Now, render the menu items and (possibly) the menu title.       */

	pop_render(popwin, menu);

	/* Now, see if the pointer is over a selection.  The variable      */
	/* 'pop_state' will from this point on hold the value, in linear   */
	/* traversal order of the MenuItems (zero-indexed), the currently  */
	/* selected menu item, or -1 if none are selected.                 */

	pop_state = pop_computestate(popwin, menu);

	/* If one is indeed currently selected, highlight it.              */

	if(pop_state >= 0)
		pop_highlight(popwin, menu, pop_state);

	/* Here is the IDCMP loop that will process the pop-up menu.  Note */
	/* that on mousemove events, I don't care where it moved, just if  */
	/* it did -- pop_computestate() will figure out where by reaching  */
	/* into the Window structure.  Not Pure Programming, somehow, but  */
	/* blessed by the Intuition manual.                                */

	finished = 0;
	while(1) {
		mouse_moved = 0;
		Wait((ULONG) 1L << popwin->UserPort->mp_SigBit);
		while(message = GetMsg(popwin->UserPort)) {
			class = message->Class;
			code = message->Code;
			ReplyMsg(message);

			/* The only messages we should be getting are      */
			/* mouse button and move events.  Button events    */
			/* could signify the end of this routine's         */
			/* epheremal spotlight role.                       */

			switch(class) {
			  case MOUSEMOVE:
			  	mouse_moved = 1;
				break;
			  case MOUSEBUTTONS:
			  	switch(code) {
				  case SELECTDOWN:
				  	if((menu->Flags & POPLEFTBUTTON) &&
					   (menu->Flags & POPTRIGGERDOWN))
					   	finished = 1;
					break;
				  case SELECTUP:
				  	if((menu->Flags & POPLEFTBUTTON) &&
					   (menu->Flags & POPTRIGGERUP))
					   	finished = 1;
					break;
				  case MENUDOWN:
				  	if((menu->Flags & POPRIGHTBUTTON) &&
					   (menu->Flags & POPTRIGGERDOWN))
					   	finished = 1;
					break;
				  case MENUUP:
				  	if((menu->Flags & POPRIGHTBUTTON) &&
					   (menu->Flags & POPTRIGGERUP))
					   	finished = 1;
					break;
				  default: /* huh? */
				  	break;
				}
				break;
			  default: /* huh? */
			  	break;
			}
		}

		/* if the exit conditions have been met, we can return our */
		/* results with honor and dignity, having served.          */
		/* Note that if we are remembering the last selection, the */
		/* menu structure is mangled to make that possible.        */

		if(finished) {
			pop_state = pop_computestate(popwin, menu);
			if(pop_state >= 0) {
				if(menu->Flags & POPREMEMBER) {
					menu->Flags |= POPUSED;
					menu->LeftEdge = -1 * popwin->MouseX;
					menu->TopEdge =  -1 * popwin->MouseY;
				}

				/* Special things to do if the menu entry  */
				/* is of type CHECKIT                      */

				sel_item = pop_getitem(menu, pop_state);
				if(sel_item->Flags & CHECKIT) {
				  if(sel_item->Flags & CHECKED) {
				    pop_state = -1;
				    if(sel_item->Flags & MENUTOGGLE)
				      sel_item->Flags &= ~CHECKED;
				  }
				  else {
				    sel_item->Flags |= CHECKED;

				    /* Handle mutual exclusion */

				    exclude = sel_item->MutualExclude;
				    if(exclude) {
				      sel_item = menu->FirstItem;
				      while(sel_item) {
				        if(exclude & 1)
				          sel_item->Flags &= ~CHECKED;
				        exclude >>= 1;
				        sel_item = sel_item->NextItem;
				      }
				    }
				  }
				}
			}
			CloseWindow(popwin);
			return((LONG) pop_state);
		}

		/* if the mouse has moved, find out its new state and      */
		/* alter the highlighting accordingly.                     */

		if(mouse_moved) {
			pop_newstate = pop_computestate(popwin, menu);
			if(pop_newstate != pop_state) {
				if(pop_state >= 0)
					pop_unhighlight(popwin,
					  menu, pop_state);
				if(pop_newstate >= 0)
					pop_highlight(popwin, 
					  menu, pop_newstate);
				pop_state = pop_newstate;
			}
		}
	}
}

/*
 * pop_computestate()
 *
 * This function checks to see where the mouse pointer is in relation to
 * the various menu items in the menu.  If it is inside one of them, it
 * returns which one (indexed by its linear position in the MenuItem list
 * with 0 being the first one).  If not, returns -1.
 *
 * Possible future enhancement: keep a set of state variables containing
 * the UL and LR corners of the last-known select box; this would make
 * a quick check possible and would cut down the computation for short
 * mouse movements (the most common).
 */

static SHORT
pop_computestate(win, menu)
struct Window *win;
struct Menu *menu;
{
	register SHORT current = 0;
	register SHORT xval, yval;
	register struct MenuItem *item;

	/* Get the x and y vals of the mouse position */

	xval = win->MouseX;
	yval = win->MouseY;

	/* If there is a title, decrement the yval by the correct amount */

	if(menu->MenuName)
		yval -= POPTITLEHEIGHT;

	/* First, see if the pointer is even in the window */

	if((xval < 0) || (yval < 0) ||
	   (xval > win->Width) || (yval > win->Height))
	   	return(-1);

	/* search through the list of menu items, checking the select box  */
	/* of each.  If containment is detected, the job is done.          */

	item = menu->FirstItem;
	while(item) {
		if((xval >= item->LeftEdge) && (yval >= item->TopEdge) &&
		   (xval <= item->LeftEdge + item->Width) &&
		   (yval <= item->TopEdge + item->Height)) {

		   	/* We have found the quarry; now, the result only  */
			/* depends on the MenuItem's ITEMENABLED flag.     */

			if(item->Flags & ITEMENABLED)
		   		return(current);
			else
				return(-1);
		}
		current++;
		item = item->NextItem;
	}

	/* If the list is exhausted, return the sad news */

	return(-1);
}

/*
 * pop_highlight()
 *
 * highlight a menu item
 */

static VOID
pop_highlight(win, menu, state)
struct Window *win;
struct Menu *menu;
SHORT state;
{
	pop_do_highlighting(win, menu, state, 0);
}

/*
 * pop_unhighlight()
 *
 * unhighlight a menu item
 */

static VOID
pop_unhighlight(win, menu, state)
struct Window *win;
struct Menu *menu;
SHORT state;
{
	pop_do_highlighting(win, menu, state, 1);
}

/*
 * pop_do_highlighting()
 *
 * Highlight or unhighlight a menu item, given its traversal number.  Assumes
 * this is a rational value -- if it isn't, Watch Out.
 */

static VOID
pop_do_highlighting(win, menu, state, mode)
struct Window *win;
struct Menu *menu;
SHORT state;
SHORT mode; /* 0 means to highlight, 1 means to unhighlight */
{
	register struct MenuItem *item;
	struct RastPort *rp;
	SHORT offset = 0;

	if(menu->MenuName)
		offset = POPTITLEHEIGHT;

	/* Get the correct MenuItem structure */

	item = pop_getitem(menu, state);

	rp = win->RPort;

	/* Now, do the highlighting!  The action to be taken depends on    */
	/* the type of highlighting desired for this item.                 */
	/* The way that the flags for highlighting works is truly bizarre  */

	if((item->Flags & HIGHNONE) == HIGHNONE)
		return;

	if(item->Flags & HIGHCOMP) {
		SetDrMd(rp, COMPLEMENT);
		RectFill(rp, (LONG) item->LeftEdge, (LONG) (item->TopEdge +
		  offset), (LONG) (item->LeftEdge + item->Width - 1),
		  (LONG) (item->TopEdge + item->Height + offset));
	}
	else if(item->Flags & HIGHBOX) {
		SetDrMd(rp, COMPLEMENT);
		Move(rp, (LONG) item->LeftEdge, (LONG) (item->TopEdge + 
		  offset));
		Draw(rp, (LONG) (item->LeftEdge + item->Width - 1),
		  (LONG) (item->TopEdge + offset));
		Draw(rp, (LONG) (item->LeftEdge + item->Width - 1),
		  (LONG) (item->TopEdge + item->Height + offset));
		Draw(rp, (LONG) item->LeftEdge,
		  (LONG) (item->TopEdge + item->Height + offset));
		Draw(rp, (LONG) item->LeftEdge, (LONG) 
		  (item->TopEdge + offset));
	}

	/*  Otherwise, the mode is HIGHIMAGE */

	else
		pop_draw_menuitem(win, item, !mode, offset);
}

/*
 * pop_render()
 *
 * renders the menu title (if existent) and the menu items
 */

static VOID
pop_render(win, menu)
struct Window *win;
struct Menu *menu;
{
	struct MenuItem *item;
	struct RastPort *rp;
	SHORT offset = 0;

	rp = win->RPort;

	/* Fill the background with color 1, like Intuition Menus */

	SetAPen(rp, 1L);
	RectFill(rp, 0L, 0L, (LONG) win->Width, (LONG) win->Height);

	/* First, if there is a Title for this menu, render it in the top */
	/* of the menu.                                                   */

	if(menu->MenuName) {
		SetDrMd(rp, JAM1);
		SetAPen(rp, 0L);
		SetBPen(rp, 1L);
		Move(rp, 4L, 7L);
		Text(rp, menu->MenuName, (LONG) pop_strlen(menu->MenuName));
		SetDrMd(rp, COMPLEMENT);
		RectFill(rp,0L,0L, (LONG) win->Width, (LONG) POPTITLEHEIGHT);
		SetDrMd(rp, JAM1);
		offset = POPTITLEHEIGHT;
	}

	/* now render all of the menu items */

	item = menu->FirstItem;
	while(item) {
		pop_draw_menuitem(win, item, 0, offset);
		item = item->NextItem;
	}
}

/* Area fill patterns */

static USHORT pop_ghost_pattern[] = {
	0x1111, 0x4444
};
static USHORT pop_normal_pattern[] = {
	0xffff, 0xffff
};

/*
 * pop_draw_menuitem()
 *
 * Draws the specified menuitem in the given rastport.  The mode argument
 * says what to draw -- 0 means draw the ItemFill, 1 the SelectFill.
 */

static VOID
pop_draw_menuitem(win, item, mode, offset)
struct Window *win;
struct MenuItem *item;
SHORT mode;
SHORT offset;
{
	APTR fill;
	struct RastPort *rp;

	/* first, figure out what to do, and return if it is a NULL thing */

	if(!mode)
		fill = item->ItemFill;
	else
		fill = item->SelectFill;

	if(!fill)
		return;

	rp = win->RPort;

	/* First, erase what may already be there, just to be sure that    */
	/* everything works out all right.                                 */

	SetAPen(rp, 1L);
	SetDrMd(rp, JAM1);
	RectFill(rp, (LONG) item->LeftEdge, (LONG) (item->TopEdge +
	  offset), (LONG) (item->LeftEdge + item->Width), (LONG)
	  (item->TopEdge + item->Height + offset));

	/* If the item is checkmarked, draw the checkmark.  Intuition made */
	/* sure that the CheckMark field of the window structure exists    */

	if(item->Flags & CHECKIT)
		if(item->Flags & CHECKED)
			DrawImage(rp, win->CheckMark, (LONG)  item->LeftEdge,
			  (LONG) (item->TopEdge + offset + 1));

	/* Now, draw the item itself -- depending on the Flag value, it    */
	/* could be either an Image or an IntuiText                        */

	if(item->Flags & ITEMTEXT)
		PrintIText(rp, fill, (LONG) item->LeftEdge, 
		  (LONG) (item->TopEdge + offset));
	else
		DrawImage(rp, fill, (LONG) item->LeftEdge, 
		  (LONG) (item->TopEdge + offset));

	/* If the ITEMENABLED flag is not set, "ghost" the item.           */

	if(!(item->Flags & ITEMENABLED)) {
		SetAPen(rp, 1L);
		SetDrMd(rp, JAM1);
		SetAfPt(rp, (USHORT *) pop_ghost_pattern, 1L);
		RectFill(rp, (LONG) item->LeftEdge, (LONG) (item->TopEdge +
		  offset), (LONG) (item->LeftEdge + item->Width), (LONG)
		  (item->TopEdge + item->Height + offset));
		SetAfPt(rp, (USHORT *) pop_normal_pattern, 1L);
	}
}

/*
 * pop_getitem()
 *
 * given the traversal number of a menu item in a menu (assumes, BTW, that
 * the arguments are valid), return a pointer to the MenuItem structure
 */

static struct MenuItem *
pop_getitem(menu, which)
struct Menu *menu;
SHORT which;
{
	struct MenuItem *item;

	item = menu->FirstItem;
	while(which--)
		item = item->NextItem;
	return(item);
}

/*
 * pop_strlen()
 *
 * a home-brewed strlen to prevent it being necessary to hook in whatever
 * huge object file in which the c library's strlen() resides.
 */

static SHORT
pop_strlen(str)
char *str;
{
	register SHORT count = 0;

	for(; *str++; count++);
	return(count);
}

/* :-) */
