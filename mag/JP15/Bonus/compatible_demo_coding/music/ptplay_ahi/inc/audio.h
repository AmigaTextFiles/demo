
#ifndef _AUDIO_H
#define _AUDIO_H

#include "global.h"

#include <devices/ahi.h>
#include <devices/audio.h>
#include <exec/tasks.h>

typedef void (*FILLFUNC)(APTR, BYTE*, BYTE*, LONG, LONG, LONG, LONG, LONG);

struct AHIAudioBuffer
{
	struct AHISampleInfo sampleInfo;
	LONG soundNum;
};

struct AHIDev
{
	struct AHIAudioBuffer buffer[2];
	struct Library *ahiBase;
	struct AHIRequest *ahiReq;
	struct AHIAudioCtrl *ahiCtrl;
	struct Hook soundHook;
	ULONG modeID;
};

typedef struct Audio
{
	struct Message iniMsg;			/* initial packet to child */

	global *global;					/* global ptr */

	struct MsgPort *msgPort;		/* device I/O port */
	struct Process *childProc;		/* child process */
	APTR procEntry;					/* a compatibility issue, don't ask */
	WORD devOpen;					/* device opened successully? */
	BYTE playSig;					/* control signal; owned by child */
	BYTE exitSig;					/* control signal; owned by parent */

	ULONG flags;
	FILLFUNC fillFunc;
	APTR fillData;

	LONG numSmp;					/* samples per frame */
	LONG mixFreq;					/* internal mixing frequency */
	LONG outFreq;					/* output frequency */
	LONG fScale;					/* mixing/output */
	LONG bitDepth;					/* bits per sample (8/16) */
	LONG numChan;					/* number of channels */
	LONG bufLen;					/* bytes per frame */

	APTR doub[2];					/* master doublebuffer switch */

	union
	{
		struct AHIDev ahi;

	} dev;

} audio;

#define AFL_PLAY			0x0001
#define AFL_EXIT			0x0002
#define AFL_START			0x0004
#define AFL_STOP			0x0008
#define AFL_REFILL			0x0010

LIBAPI LONG InitAudio(global *g, audio *a);
LIBAPI void ExitAudio(global *g, audio *a);
LIBAPI void PlayAudio(global *g, audio *a, BOOL play);
LIBAPI void SetAudioFunc(global *g, audio *a, FILLFUNC func, APTR data);

#endif
