/*
 *  Constant definitions needed by the pop-up menu code.
 *
 *  Written by Derek Zahn (Gambit Software, Madison WI), July 1987
 *
 *  This code is freely distributable and is blessed by its author for
 *  inclusion, in this form or any other, into Amiga programs,
 *  commercial or non-commercial.  If this is done, no credit must be
 *  given to me (although I wouldn't mind).
 */

/* This value should be added to the Height field of the Menu structure */
/* if a title is supplied in the MenuName field.                        */

#define POPTITLEHEIGHT 10

/* These flags will go in the Flags field of the Menu structure         */

#define POPVERIFY 0x0002L  /* for possible future expansion */
#define POPRELEASE 0x0004L  /* for possible future expansion */
#define POPTIDY 0x0008L
#define POPPOINTREL 0x0010L
#define POPWINREL 0x0020L
#define POPREMEMBER 0x0040L
#define POPUSED 0x0080L
#define POPMOVEPOINTER 0x0200L /* for possible future expansion */
#define POPLEFTBUTTON 0x1000L
#define POPRIGHTBUTTON 0x2000L
#define POPTRIGGERDOWN 0x4000L
#define POPTRIGGERUP 0x8000L
