#include <exec/types.h>
#include <clib/exec_protos.h>
#include <pragmas/exec_pragmas.h>
#include <dos/dos.h>
#include <proto/dos.h>
#include <stdio.h>
#include <stdlib.h>

#include <libraries/ptreplay.h>
#include <clib/ptreplay_protos.h>
#include <pragmas/ptreplay_pragmas.h>

struct Library *PTReplayBase;
struct Module *Mod = NULL;


int main(int argc, char **argv)
{

    if(argc > 2)
        { printf("only one module can be\n");exit(0);};
    if(argc < 2)
        { printf("wrong name\n");exit(0);};

    PTReplayBase = OpenLibrary("ptreplay.library",0L);
    Mod = PTLoadModule(argv[1]);
    PTPlay(Mod);


    while(1)
    {
       if(Wait(SIGBREAKF_CTRL_C | 0))
        {break;};
    };


    PTFade(Mod,1);
    PTStop(Mod);
    PTUnloadModule(Mod);
    CloseLibrary(PTReplayBase);
}
