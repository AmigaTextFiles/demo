#include "Ptreplay.H"
#include "PtreplayProtos.H"
#include "PtreplayPragmas.H"
struct Library *PTReplayBase;
struct Module *Mod = NULL;
BYTE SigBit;

void play_init(char *module)
{
if(PTReplayBase = (struct Library *) OpenLibrary("ptreplay.library",0L))
	{
	if(Mod = PTLoadModule(module))
		{
		SigBit=AllocSignal(-1);
		PTInstallBits(Mod, SigBit, -1, -1, -1);
		PTPlay(Mod);
		}
	}
}

void play_pos(int pos)
{
PTStop(Mod);
PTPlay(Mod);
PTSetPos(Mod, pos);
}

void play_fade(int time)
{
PTStartFade(Mod,1);
}

void play_end(void)
{
PTStop(Mod);
FreeSignal(SigBit);
PTUnloadModule(Mod);
CloseLibrary(PTReplayBase);
}
