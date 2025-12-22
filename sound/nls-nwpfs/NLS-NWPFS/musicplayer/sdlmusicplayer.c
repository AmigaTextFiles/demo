// g++ -o sdlmusicplayer sdlmusicplayer.c -lSDL_mixer -lsmpeg -lvorbisfile -lvorbis -logg -lSDL -lSDLmain -lpthread -lauto  -ISDK:Local/clib2/include/SDL -Isdk:Local/common/include/SDL/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <SDL.h>
#include <SDL_mixer.h>
#include <proto/dos.h>
#include <proto/exec.h>
#include <sys/time.h>
#include "musicplayer.h"

struct CommandMessage {
    struct Message commandMsg;
    int           command;
};

struct Task *maintask = NULL;
LONG  mainsignum = -1;
ULONG mainsig;
ULONG portsig, usersig, signal;



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

BOOL SafePutToPort(struct Message *message, STRPTR portname)
///
{
    struct MsgPort *port;
    int i;

    IExec->Forbid();
    port = IExec->FindPort(portname);
    if (port)
    {
        //fprintf(stderr,"Port %s found!\n",portname);
        IExec->PutMsg(port, message);
        IExec->Permit();
    } 
    //else    fprintf(stderr,"Port %s not found!\n",portname);

    IExec->Permit();

    return(port ? TRUE : FALSE); /* FALSE if the port was not found */
}
///

BOOL sendmessage(char *portname, int command)
///
{
    struct MsgPort *commandreplyport;
    struct CommandMessage *commandmsg, *reply;
    int result = FALSE;
                                                       /* Using CreatePort() with no name       */
    if (commandreplyport = IExec->CreatePort(0,0))                     /* because this port need not be public. */
    {
        if (commandmsg = (struct CommandMessage *) IExec->AllocMem(sizeof(struct CommandMessage), MEMF_PUBLIC | MEMF_CLEAR))
        {
            commandmsg->commandMsg.mn_Node.ln_Type = NT_MESSAGE;                /* make up a message,        */
            commandmsg->commandMsg.mn_Length = sizeof(struct CommandMessage);        /* including the reply port. */
            commandmsg->commandMsg.mn_ReplyPort = commandreplyport;
            commandmsg->command = command;                                   /* our special message information. */

            if (SafePutToPort((struct Message *)commandmsg, portname))  /* one message to port1 wait for */
            {                                                      /*  the reply, and then exit     */
                IExec->WaitPort(commandreplyport);
                reply = (struct CommandMessage *)IExec->GetMsg(commandreplyport);
                result = TRUE;
            } else
            IExec->FreeMem(commandmsg, sizeof(struct CommandMessage));
        }
        IExec->DeletePort(commandreplyport);
    }

    return result;
}
///




void musicDone();
void musicDoneNoSignal();
void musicReplay();

int main(int argc, char **argv) {


    int audio_rate = 44100;
    Uint16 audio_format = AUDIO_S16; /* 16-bit stereo */
    int audio_channels = 2;
    int audio_buffers = 4096;
    struct MsgPort *commandport;
    struct CommandMessage *commandmsg;
    ULONG portsig, usersig, signal;
    BOOL ABORT = FALSE;


    SDL_Init(SDL_INIT_AUDIO);

    if(argc == 3)
    {
        if(Mix_OpenAudio(22050, audio_format, audio_channels, audio_buffers)) {
          printf("Unable to open audio!\n");
          exit(1);
        }
    }
    else
    {
        if(Mix_OpenAudio(audio_rate, audio_format, audio_channels, audio_buffers)) {
          printf("Unable to open audio!\n");
          exit(1);
        }
    }

    Mix_QuerySpec(&audio_rate, &audio_format, &audio_channels);

    sendmessage("musicplayerport",COMMAND_EXIT);

    if ((commandport = IExec->CreatePort("musicplayerport", 0)) == NULL)
    {
        printf("Couldn't create 'musicplayerport'\n");
        musicDone();
        exit(1);
    }

    portsig = 1 << commandport->mp_SigBit;
    usersig = SIGBREAKF_CTRL_C;


    maintask = IExec->FindTask(NULL);
    mainsignum = IExec->AllocSignal(-1);

    if(mainsignum == -1)
    {
        fprintf(stderr,"Unable to allocate signal\n");
        IExec->DeletePort(commandport);
        Mix_CloseAudio();
        SDL_Quit();
        return 0;
    }

    mainsig = 1L << mainsignum;    /* subtask can access this global */

    sendmessage("demoport",COMMAND_LOADING);

    music = Mix_LoadMUS(argv[1]);

    sendmessage("demoport",COMMAND_PLAY);

    if(!music)
    {
        fprintf(stderr,"Mix_LoadMUS(%s): %s\n", argv[1],Mix_GetError());
        musicDone();
        IExec->DeletePort(commandport);
        Mix_CloseAudio();
        SDL_Quit();
        return 0;
    }

    Mix_HookMusicFinished(musicDone);

    Mix_PlayMusic(music, 0);

    while(music) {

        signal = IExec->Wait(portsig | usersig | mainsig);

        if(signal & portsig) {
            commandmsg = (struct CommandMessage *)IExec->GetMsg(commandport);
            if(commandmsg)
            {
                int command = commandmsg->command;

                //commandmsg->command = -1;
                IExec->ReplyMsg((struct Message *)commandmsg);

                switch(command)
                {
                    case COMMAND_PAUSE:
                        if(Mix_PlayingMusic() && !Mix_PausedMusic()) Mix_PauseMusic();
                        else Mix_ResumeMusic();
                        break;
                    case COMMAND_PLAY:
                        if(!Mix_PlayingMusic()) Mix_PlayMusic(music, 0);
                        else Mix_ResumeMusic();
                        break;
                    case COMMAND_STOP:
                        Mix_HaltMusic();
                        break;
                    default:
                        if(Mix_PlayingMusic() && !Mix_PausedMusic())
                        {
                            Mix_HookMusicFinished(musicDoneNoSignal);
                            Mix_FadeOutMusic(1500);
                            while(Mix_PlayingMusic()) {
                                // wait for any fades to complete
                                SDL_Delay(100);
                            }
                        }
                        else if(Mix_PausedMusic())
                        {
                            Mix_HaltMusic();
                            if(music) Mix_FreeMusic(music);
                            music = NULL;
                        }
                        else
                        {
                            if(music) Mix_FreeMusic(music);
                            music = NULL;
                        }
                }
            }
        }
        else if (signal & usersig)
        {
            fprintf(stderr,"CTRL-C Break!\n");
            if(Mix_PlayingMusic())
            {

                Mix_HookMusicFinished(musicDone);
                Mix_FadeOutMusic(1500);
                while(Mix_PlayingMusic()) {
                    // wait for any fades to complete
                    SDL_Delay(100);
                }
            }
            //musicDone();

        }
        else break;

        //SDL_Delay(50);
    }


    IExec->FreeSignal(mainsignum);
    IExec->DeletePort(commandport);

    sendmessage("demoport",COMMAND_EXIT);


    /* This is the cleaning up part */
    Mix_CloseAudio();
    SDL_Quit();

}

void musicReplay()
{
  Mix_PlayMusic(music, 0);
  Mix_HookMusicFinished(musicReplay);
}

void musicDoneNoSignal()
{
  if(Mix_PlayingMusic()) Mix_HaltMusic();
  if(music) Mix_FreeMusic(music);
  music = NULL;
}

void musicDone()
{
  if(Mix_PlayingMusic()) Mix_HaltMusic();
  if(music) Mix_FreeMusic(music);
  music = NULL;
  IExec->Signal(maintask,mainsig);
}
