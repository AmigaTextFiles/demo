/*
    The mp3 API for fmod (meant for Windows only)
    - Marq
*/

#include <stdio.h>
#include "mp3.h"
#include <math.h>
#include <inc/fmod.h>

float mp3_floatbuf[MP3_AUDIOBUF];
int mp3_floatvals;

static FSOUND_SAMPLE *handle;
static FSOUND_DSPUNIT *dsp;

static void * F_CALLBACKAPI audio_callback(void *origb,void *newb,int len,void *us)
{
    int maxs=len,i;
    signed short *t=newb;

    if(maxs>MP3_AUDIOBUF)
        maxs=MP3_AUDIOBUF;
    mp3_floatvals=maxs;

    for(i=0;i<maxs;i++)
        mp3_floatbuf[i]=(t[i*2]/2+t[i*2+1]/2)/32768.0;

    return(newb);
}

int mp3_init(void)
{
    int n;

    for(n=0;n<MP3_AUDIOBUF;n++)
        mp3_floatbuf[n]=0;
    mp3_floatvals=MP3_AUDIOBUF;

#ifdef __linux__
    FSOUND_SetOutput(FSOUND_OUTPUT_OSS);
#else
    FSOUND_SetOutput(FSOUND_OUTPUT_DSOUND);
#endif

    FSOUND_SetBufferSize(50);
    FSOUND_SetDriver(0);
    FSOUND_Init(44100,32,0);

    return(0);
}

int mp3_load(char *name)
{
    handle=FSOUND_Sample_Load(0,name,FSOUND_NORMAL,0,0);

    return(0);
}

void mp3_get(void *data,int len)
{
    /* Dummy for now */
}

void mp3_play(void)
{
    /* Hit it! */
    dsp=FSOUND_DSP_Create(audio_callback,FSOUND_DSP_DEFAULTPRIORITY_CLIPANDCOPYUNIT,0);
    FSOUND_DSP_SetActive(dsp,1);
    FSOUND_PlaySound(0,handle);
    FSOUND_SetPaused(0,0);
}

void mp3_stop(void)
{
    FSOUND_StopSound(0);
    FSOUND_Sample_Free(handle);
    FSOUND_Close();
}

int mp3_pos(void)
{
    return(FSOUND_GetCurrentPosition(0));
}

int mp3_time(void)
{
    int t,m,s;

    t=FSOUND_GetCurrentPosition(0)/MP3_FREQ;
    s=t%60;
    m=t/60;

    return(m*100+s);
}

/* EOF */
