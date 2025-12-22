/*
    The implementation of mpglib wrapper for SDL
    - Marq
*/

#include "mp3.h"
#include "mpglib/mpg123.h"
#include "mpglib/mpglib.h"
#include <stdio.h>
#include <stdlib.h>
#include <SDL.h>
#include <math.h>

static int pos,retval,allocated,bufdata,finished,filelen;
static void *biisi;
static struct mpstr mp;
static Uint8 buf[MP3_BUFSIZE],*bufptr;
float mp3_floatbuf[MP3_AUDIOBUF];
int mp3_floatvals;

static void audio_callback(void *udata,Uint8 *stream,int len)
{
    int i,done,maxx=len/4;
    signed short    *t=(short *)stream;

    if(finished)
    {
        for(i=0;i<len;i++)
            stream[i]=0;
        return;
    }

    /* Copy byte at a time and mix more if necessary */
    for(i=0;i<len;i++)
    {
        if(!bufdata)
        {
            retval=decodeMP3(&mp,NULL,0,buf,MP3_BUFSIZE,&done);
            if(retval!=MP3_OK)
                finished=1;
            bufptr=buf;
            bufdata=done;
        }

        *stream++ = *bufptr++;
        bufdata--;
        if(i%4==0)
            pos++;
    }

    /* Compile to -1..1 floats for visual effects */
    if(maxx>1024) maxx=1024;
    if(maxx>MP3_AUDIOBUF) maxx=MP3_AUDIOBUF;

    for(i=0;i<maxx;i++)
        mp3_floatbuf[i]=(t[i*2]/2+t[i*2+1]/2)/32768.0;
    mp3_floatvals=maxx;
}

int mp3_init(void)
{
    SDL_AudioSpec   spek,dummy;
    int n;

    /* SDL init */
    SDL_Init(SDL_INIT_AUDIO);
    spek.freq=MP3_FREQ;
    spek.format=AUDIO_S16SYS;
    spek.channels=2;
    spek.samples=MP3_AUDIOBUF;
    spek.callback=audio_callback;
    spek.userdata=NULL;
    if(SDL_OpenAudio(&spek,&dummy)!=0)
        return(-1);

    for(n=0;n<MP3_AUDIOBUF;n++)
        mp3_floatbuf[n]=0;
    mp3_floatvals=MP3_AUDIOBUF;

    return(0);
}

int mp3_load(char *name)
{
    FILE    *f;

    /* Read the file in */
    if((f=fopen(name,"rb"))==NULL)
        return(-1);
    fseek(f,0,SEEK_END);
    filelen=ftell(f);
    fseek(f,0,SEEK_SET);
    biisi=malloc(filelen);
    allocated=1;
    fread(biisi,1,filelen,f);
    fclose(f);

    return(0);
}

void mp3_get(void *data,int len)
{
    allocated=0;
    biisi=data;
    filelen=len;
}

void mp3_play(void)
{
    pos=0;
    finished=0;

    InitMP3(&mp);
    decodeMP3(&mp,biisi,filelen,buf,MP3_BUFSIZE,&bufdata);
    bufptr=buf;

    /* Hit it! */
    SDL_PauseAudio(0);
}

void mp3_stop(void)
{
    SDL_PauseAudio(1);
    ExitMP3(&mp);
    if(allocated)
        free(biisi);
}

int mp3_pos(void)
{

    return(pos);
}

int mp3_time(void)
{
    int t,m,s;

    t=pos/MP3_FREQ;
    s=t%60;
    m=t/60;

    return(m*100+s);
}

/* EOF */
