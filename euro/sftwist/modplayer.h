/* C definitions for using the 'modplayer.a' and 'mod8player.a'
   play-routines of OctaMED V2.00 and MED V3.20 */

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

/* If "libproto.h" has been loaded, we don't define the "modplayer.a"
   functions. */
#ifndef MEDPLAYER_LIBPROTO
#ifdef LATTICE
/* In 'modplayer.a' */
LONG __asm InitPlayer(void);
void __asm RemPlayer(void);
void __asm PlayModule(register __a0 struct MMD0 *);
void __asm ContModule(register __a0 struct MMD0 *);
void __asm StopPlayer(void);
void __asm SetTempo(register __d0 UWORD);
/* In 'loadmod.a' */
struct MMD0 * __asm LoadModule(register __a0 char *);
/*void __asm RelocModule(register __a0 struct MMD0 *);*/
void RelocModule(register struct MMD0 *);
void __asm UnLoadModule(register __a0 struct MMD0 *);
/* These are the definitions for the 8-channel OctaMED routines,
   in 'mod8player.a' (not provided with MED). */
LONG __asm InitPlayer8(void);
void __asm RemPlayer8(void);
void __asm PlayModule8(register __a0 struct MMD0 *);
void __asm ContModule8(register __a0 struct MMD0 *);
void __asm StopPlayer8(void);
#endif

/* If you're playing multi-modules, set the 'modnum' variable to the
   number of the song you want to play before calling PlayModule(). */

#ifdef LATTICE_50
extern UWORD far modnum;

/* 'modnum8' is the equivalent in 'mod8player' */

extern UWORD far modnum8;
#else
extern UWORD modnum,modnum8; /* for less intelligent compilers */
#endif

#endif // MEDPLAYER_LIBPROTO

/* This is the main module structure */
struct MMD0 {
	ULONG	id;			/* "MMD0" */
	ULONG	modlen;			/* module length (in bytes) */
	struct	MMD0song *song;		/* pointer to MMD0song */
	ULONG	songlen;		/* length of song (not currently used) */
	struct	MMD0block **blockarr;	/* pointer to pointers of blocks */
	ULONG	blockarrlen;		/* length... */
	struct	Soitin **smplarr;	/* pointer to pointers of samples */
	ULONG	smplarrlen;		/* len.. */
	struct	MMD0exp *expdata;	/* pointer to expansion data */
	ULONG	expsize;		/* lenght again.. */
/* The following values are used by the play routine */
	UWORD	pstate;			/* the state of the player */
	UWORD	pblock;			/* current block */
	UWORD	pline;			/* current line */
	UWORD	pseqnum;		/* current # of playseqlist */
	WORD	actplayline;		/* OBSOLETE!! DON'T TOUCH! */
	UBYTE	counter;		/* delay between notes */
	UBYTE	extra_songs;		/* number of additional songs, see
					   expdata->nextmod */
};

/* These are the structures for future expansions */

struct InstrExt {	/* This struct only for data required for playing */
/* NOTE: THIS STRUCTURE MAY GROW IN THE FUTURE, TO GET THE CORRECT SIZE,
   EXAMINE mmd0->expdata->s_ext_entrsz */
	UBYTE hold;
	UBYTE decay;
	UBYTE suppress_midi_off;	/* 1 = suppress, 0 = don't */
	UBYTE pad0;			/* This may be used in the future... */
};

struct MMDInstrInfo {
	UBYTE	name[40];
	UBYTE	pad0;	/* two pads? */
	UBYTE	pad1;
};

struct MMD0exp {
	struct MMD0 *nextmod;		/* for multi-modules */
	struct InstrExt *exp_smp;	/* pointer to an array of InstrExts */
	UWORD  s_ext_entries;		/* # of InstrExts in the array */
	UWORD  s_ext_entrsz;		/* size of an InstrExt structure */
	UBYTE  *annotxt;		/* 0-terminated message string */
	ULONG  annolen;			/* length (including the 0-byte) */
/* MED V3.20 data below... */
	struct MMDInstrInfo *iinfo;	/* "secondary" InstrExt for info,
					that has no affection on output */
	UWORD  i_ext_entries;		/* # of MMDInstrInfos */
	UWORD  i_ext_entrsz;		/* size of one */
	ULONG  jumpmask;		/* jumpmask for Topi (aaaarrrgh!!!) */
	UWORD  *rgbtable;		/* pointer to 8 UWORD values */
	UBYTE  channelsplit[4];	/* for OctaMED only (non-zero = NOT splitted) */
/* leave these to zero! */
	struct NotationInfo *n_info;	/* OctaMED notation editor info data */
/* This are still left, they must be 0 at the moment. */
	ULONG  reserved2[10]; /* better have enough of these... */
};

/* Info for each instrument (mmd0->song.sample[xx]) */

struct MMD0sample {
	UWORD rep,replen;	/* repeat/repeat length */
	UBYTE midich;		/* midi channel for curr. instrument */
	UBYTE midipreset;	/* midi preset (1 - 128), 0 = no preset */
	UBYTE svol;		/* default volume */
	BYTE strans;		/* sample transpose */
};

/* The song structure (mmd0->song) */

struct MMD0song {
	struct MMD0sample sample[63];	/* info for each instrument */
	UWORD	numblocks;		/* number of blocks in this song */
	UWORD	songlen;		/* number of playseq entries */
	UBYTE	playseq[256];		/* the playseq list */
	UWORD	deftempo;		/* default tempo */
	BYTE	playtransp;		/* play transpose */
	UBYTE	flags;			/* flags (see below) */
	UBYTE	reserved;		/* for future expansion */
	UBYTE	tempo2;			/* 2ndary tempo (delay betw. notes) */
	UBYTE	trkvol[16];		/* track volume */
	UBYTE	mastervol;		/* master volume */
	UBYTE	numsamples;		/* number of instruments */
}; /* length = 788 bytes */

 /* FLAGS of the above structure */
#define	FLAG_FILTERON	0x1	/* hardware low-pass filter */
#define	FLAG_JUMPINGON	0x2	/* jumping.. */
#define	FLAG_JUMP8TH	0x4	/* jump 8th.. */
#define	FLAG_INSTRSATT	0x8	/* instruments are attached (sng+samples)
				   used only in saved MED-songs */
#define	FLAG_VOLHEX	0x10	/* volumes are represented as hex */
#define FLAG_STSLIDE	0x20	/* no effects on 1st timing pulse (STS) */
#define FLAG_8CHANNEL	0x40	/* OctaMED 8 channel song, examine this bit
				   to find out which routine to use */
/* flags in struct NotationInfo */
#define NFLG_FLAT 1
#define NFLG_3_4  2

struct NotationInfo {
	UBYTE n_of_sharps;	/* number of #'s (or b's) */
	UBYTE flags;		/* flags (see above) */
	WORD  trksel[5];	/* selected track for each preset (-1 = none) */
	UBYTE trkshow[16];	/* which tracks to show (bit 0 = for preset 0,
				bit 1 for preset 1 and so on..) */
	UBYTE trkghost[16];	/* ghosted tracks (like trkshow[]) */
	BYTE  notetr[63];   	/* -24 - +24 (if bit #6 is negated, hidden) */
	UBYTE pad;	/* perhaps info about future extensions */
};
