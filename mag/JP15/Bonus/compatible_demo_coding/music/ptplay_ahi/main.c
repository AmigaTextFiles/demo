#include "inc/global.h"
#include "inc/audio.h"
#include "inc/ptplay.h"

#include <string.h>
#include <exec/memory.h>
#include <proto/exec.h>

#include <stdio.h>
#include <stdlib.h>



/**************************************************************************
**
**	render
*/

struct PlayData
{
	global *global;
	pt_mod_s *mod;
};

static void render(struct PlayData *play, BYTE *buf1, BYTE *buf2, LONG offs, 
	LONG numsmp, LONG scale, LONG depth, LONG chans)
{
	ULONG flags = play->mod->flags;

	pt_render(play->mod, buf1, buf2, offs, numsmp, scale, depth, chans);

	if (play->global->args[ARG_SONGEND])
	{
		if ((flags ^ play->mod->flags) & MODF_SONGEND)
		{
			play->mod->flags &= ~MODF_SONGEND;
			Signal((struct Task *) play->global->self, SIGBREAKF_CTRL_D);
		}
	}
}


/**************************************************************************
**
**	main
*/

int main(int argc, char **argv)
{


    LONG freq = 44100;
    LONG vol = 100;
    LONG args[ARG_NUM];

    BYTE *modbuf;
    FILE *fp_filename;
    long int file_size;
	
    LONG res;
    pt_mod_s *pmod;

    ULONG sig;
	struct PlayData pdata;
    int c;

    global gdata;
    audio adata;

    global *g = &gdata;
    audio *a = &adata;


// read module to buffer

    if((fp_filename = fopen(argv[1],"rb")) == NULL)
     { printf("can't open file\n");exit(0);};

    fseek (fp_filename,0,SEEK_END);
    file_size = ftell(fp_filename);
    fseek (fp_filename,0, SEEK_SET);

    printf("filesize is: %d\n",file_size);

    modbuf=malloc(file_size);if(modbuf==NULL){printf("sorry, can't malloc\n");goto panic;};

    fread(modbuf,file_size,1,fp_filename);

    fclose(fp_filename);

// init of module


    InitGlobal(g);

    memset(args, 0, sizeof(args));
	args[ARG_VOLUME] = (LONG) &vol;
	args[ARG_FREQ] = (LONG) &freq;
	g->args = args;

    InitAudio(g,a);

    pmod = pt_init(modbuf, file_size, a->mixFreq);
    if(!pmod) {printf("bad file?\n");goto panic;};


			
    pmod->mastervolume = *(LONG *) g->args[ARG_VOLUME] * 256 / 100;
	if (g->args[ARG_NOLED]) pmod->flags &= ~MODF_ALLOWFILTER;

	pdata.global = g;
	pdata.mod = pmod;
	SetAudioFunc(g, a, (FILLFUNC) render, &pdata);


//Playdata !!

			
    PlayAudio(g, a, TRUE);


    while(1)
    {
       if(Wait(SIGBREAKF_CTRL_C | 0))
        {break;};
    };




  PlayAudio(g, a, FALSE);
  pt_free(pmod);

panic:

  free(modbuf);

  ExitAudio(g,a);
  ExitGlobal(g);
  exit(0);

}

