// g++ -o sdlmusicplayer sdlmusicplayer.c -lSDL_mixer -lsmpeg -lvorbisfile -lvorbis -logg -lSDL -lSDLmain -lpthread -lauto  -ISDK:Local/clib2/include/SDL -Isdk:Local/common/include/SDL/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <SDL.h>
#include <SDL_mixer.h>
#include <proto/dos.h>
#include <proto/exec.h>
#include <sys/time.h>

struct XYMessage {
    struct Message xy_Msg;
    int           xy_X;
};

Mix_Music *music = NULL;

int getTimeWithStatus(int status)
///
{
    static int startSec = 0;

    struct timeval t;
    int sec, usec;


    gettimeofday((struct timeval *)&t,NULL);

    if(status == 1)
    {
        startSec = t.tv_sec;
    }

    sec = (t.tv_sec - startSec)*100;
    usec = t.tv_usec/10000;
    return sec+usec;
}
///

int getTime()
///
{
    return getTimeWithStatus(-1);
}
///

void musicDone();
void musicReplay();

int main(int argc, char **argv) {

  double a = sqrt((double)4.00);

  SDL_Surface *screen;
  SDL_Event event;
  int done = 0;

  int audio_rate = 22050;
  Uint16 audio_format = AUDIO_S16; /* 16-bit stereo */
  int audio_channels = 2;
  int audio_buffers = 4096;
  struct MsgPort *xyport;
  struct XYMessage *xymsg;
  ULONG portsig, usersig, signal;
  BOOL ABORT = FALSE;

  SDL_Init(SDL_INIT_AUDIO);

  if(Mix_OpenAudio(audio_rate, audio_format, audio_channels, audio_buffers)) {
    printf("Unable to open audio!\n");
    exit(1);
  }

  Mix_QuerySpec(&audio_rate, &audio_format, &audio_channels);

  music = Mix_LoadMUS(argv[1]);
  if(!music)
  {
    fprintf(stderr,"Mix_LoadMUS(%s): %s\n", argv[1],Mix_GetError());
    // this might be a critical error...
    musicDone();
    Mix_CloseAudio();
    SDL_Quit();
    return 0;
  }

  if ((xyport = IExec->CreatePort("xyport", 0)) == NULL)
  {
    printf("Couldn't create 'xyport'\n");
    musicDone();
    Mix_CloseAudio();
    SDL_Quit();
    return 0;
  }

  portsig = 1 << xyport->mp_SigBit;       
  usersig = SIGBREAKF_CTRL_C;

  printf("Musicplayer started.  CTRL-C to abort.\n");

  signal = IExec->Wait(portsig | usersig);             


  if (signal & usersig)                                    
  {
    while(xymsg = (struct XYMessage *)IExec->GetMsg(xyport))    
        IExec->ReplyMsg((struct Message *)xymsg);
    IExec->DeletePort(xyport);
    exit(1);
  }

  if (signal & portsig)  
  {                      

    while(xymsg = (struct XYMessage *)IExec->GetMsg(xyport))        
    {

      Mix_PlayMusic(music, 0);


      xymsg->xy_X = getTime();
        IExec->ReplyMsg((struct Message *)xymsg);
    }
  }


    Mix_HookMusicFinished(musicReplay);

/*if(!Mix_RegisterEffect(MIX_CHANNEL_POST, noEffect, NULL, NULL)) {
    printf("Mix_RegisterEffect: %s\n", Mix_GetError());
} */

  while(music) {

    xymsg = (struct XYMessage *)IExec->GetMsg(xyport);
    if(xymsg)
    {
        IExec->ReplyMsg((struct Message *)xymsg);
        Mix_HookMusicFinished(musicDone);
        while(!Mix_FadeOutMusic(3000) && Mix_PlayingMusic()) {
            // wait for any fades to complete
            SDL_Delay(100);
        }
        //musicDone();
    }
    /* So we don't hog the CPU */
    SDL_Delay(50);
  }

    IExec->DeletePort(xyport);


  /* This is the cleaning up part */
  Mix_CloseAudio();
  SDL_Quit();

}

void musicReplay()
{
  Mix_PlayMusic(music, 0);
  Mix_HookMusicFinished(musicReplay);
}

void musicDone()
{
  Mix_HaltMusic();
  Mix_FreeMusic(music);
  music = NULL;
}
