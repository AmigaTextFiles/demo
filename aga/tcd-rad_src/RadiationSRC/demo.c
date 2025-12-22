#include <clib/graphics_protos.h>
#include <clib/intuition_protos.h>
#include <clib/dos_protos.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#include "palette.h"
#include "startup.h"
#include "sound.h"
#include "demo.h"
#include "picture.h"
#include "c2p.h"
#include "dbuff.h"
#include "timer.h"
#include "turbocpy.h"
#include "mouse.h"
#include "tunnel.h"

void startdemo(void)
{
	int counter, col, running=1;
	int pos=0, yp=0, speed=1;
	int xpos=0, ypos=0;
	unsigned short scrollpos=0x0000;
	unsigned short scrollspeed=0x0504;

	int funclentable[9]={ // Testfunktionen har stort värda andra=0
									  0, 700, 900, 300, 300, 600, 600, 400, 3000};
//   int funclentable[9]={ // Innehåller längden på olika functioner...
//                           0,  000,  000, 000, 000, 000, 000, 400, 0};
								  ///// KW   RAD  PRO  TCD  TUN  CAR  ELD SCRL

	UBYTE *chunkypic=NULL;
	UBYTE *chunkypal=NULL;
	UBYTE *destchunkypal=NULL;
	UBYTE *scrollbuffer=NULL;
	UBYTE *texturebuffer=NULL;
	unsigned short *table=NULL;

/* Initiera, allokera, starta music etc. */
	if(music) playsong("data/radiation.mod");
	timerinitstart(funclentable[0]);
	chunkypic=initchunky(320, 256);
	chunkypal=initchunky(256, 3);
	destchunkypal=initchunky(256, 3);
	timerdiff(); // räknar ut fdifftime variabeln (avvikelsen)
	if(checkmouse()) running=0;

/* Kärnkraftwerket! */
	if(running&&(funclentable[1]>0))
	{
		newfunctimer(funclentable[1]);

		for(counter=0; counter<(256*3); counter++)
			chunkypal[counter]=0x00; // Ställer om hela paletten till vit!
		setpalen(chunkypal, 256);
		if(destchunkypal) loadpalette("data/powplant.pal", destchunkypal, 256);
		if(chunkypic) loadchunkypic("data/powplant.chunky", chunkypic, 320, 256);

		dbuffwaitdraw();
		c2p1x1_8_c5_bm((char *)chunkypic, screenbuffers[screennr]->sb_BitMap, 320,256, 0, 0);
		dbuffdispnew();

		for(col=255; running&&(col>=0); col--)
		{
			fadeuppal(chunkypal, destchunkypal, 256);
			setpalen(chunkypal, 256);
			if(checkmouse()) running=0;
		}

		while(running&&((funkctime=clock())<funketime))
		{
			if(checkmouse()) running=0;
		}
		timerdiff(); // räknar ut fdifftime variabeln (avvikelsen)
	}

/* Andra effekten...Vit skärm fade:as ner till Radiation... */
	if(running&&(funclentable[2]>0))
	{
		newfunctimer(funclentable[2]);
		for(counter=0; counter<(256*3); counter++)
			chunkypal[counter]=0xFF; // Ställer om hela paletten till vit!
		setpalen(chunkypal, 256);

		if(destchunkypal) loadpalette("data/radiation.pal", destchunkypal, 256);
		if(chunkypic) loadchunkypic("data/radiation.chunky", chunkypic, 320, 256);
		dbuffwaitdraw();
		c2p1x1_8_c5_bm((char *)chunkypic, screenbuffers[screennr]->sb_BitMap, 320,256, 0, 0);
		dbuffdispnew();

	 for(col=255; running&&(col>=0); col--)
		{
			fadedownpal(chunkypal, destchunkypal, 256);
			setpalen(chunkypal, 256);
			if(checkmouse()) running=0;
		}
		while(running&&((funkctime=clock())<funketime))
		{
			if(checkmouse()) running=0;
		}
		timerdiff();
	}

/* A Production By...   */
	if(running&&(funclentable[3]>0))
	{
		newfunctimer(funclentable[3]);
		dbuffwaitdraw();
		memset(chunkypic, 0x00, 320*256);
		c2p1x1_8_c5_bm((char *)chunkypic, screenbuffers[screennr]->sb_BitMap, 320,256, 0, 0);
		dbuffdispnew();

		if(chunkypal) loadpalette("data/aprodby.pal", chunkypal, 256);
		if(chunkypal) setpalen(chunkypal, 256);
//      if(destchunkypal) loadpalette("data/tcd.pal", destchunkypal, 256);
		if(chunkypic) loadchunkypic("data/aprodby.chunky", chunkypic, 320, 256);

		dbuffwaitdraw();
		c2p1x1_8_c5_bm((char *)chunkypic, screenbuffers[screennr]->sb_BitMap, 320,256, 0, 0);
		dbuffdispnew();

		while(running&&((funkctime=clock())<funketime))
		{
			if(checkmouse()) running=0;
		}
		timerdiff(); // räknar ut fdifftime variabeln (avvikelsen)
	}


/* The Camel Drivers Loggan...   */
	if(running&&(funclentable[4]>0))
	{
		newfunctimer(funclentable[4]);
		dbuffwaitdraw();
		memset(chunkypic, 0x00, 320*256);
		c2p1x1_8_c5_bm((char *)chunkypic, screenbuffers[screennr]->sb_BitMap, 320,256, 0, 0);
		dbuffdispnew();

		if(chunkypal) loadpalette("data/tcd.pal", chunkypal, 256);
		if(chunkypal) setpalen(chunkypal, 256);
//      if(destchunkypal) loadpalette("data/tcd.pal", destchunkypal, 256);
		if(chunkypic) loadchunkypic("data/tcd.chunky", chunkypic, 320, 256);

		dbuffwaitdraw();
		c2p1x1_8_c5_bm((char *)chunkypic, screenbuffers[screennr]->sb_BitMap, 320,256, 0, 0);
		dbuffdispnew();

		while(running&&((funkctime=clock())<funketime))
		{
			if(checkmouse()) running=0;
		}
		timerdiff(); // räknar ut fdifftime variabeln (avvikelsen)
	}

/* Tunneln....som suger stort!! */

	if(running&&(funclentable[5]>0))
	{
		newfunctimer(funclentable[5]);

		memset(chunkypic, 0, 320*256);
		dbuffwaitdraw();
		c2p1x1_8_c5_bm((char *)chunkypic, screenbuffers[screennr]->sb_BitMap, 320,256, 0, 0);
		dbuffdispnew();

		texturebuffer=initchunky(256, 256*2);
		if(texturebuffer) loadchunkypic("data/texture.chunky", texturebuffer, 256, 256);
		memcpy(texturebuffer+256*256, texturebuffer, 256*256);
		table=(unsigned short *)initchunky(320, 256*2);
		if(table) loadchunkypic("data/tunnel.tab", table, 320, 256*2);
		if(chunkypal) loadpalette("data/texture.pal", chunkypal, 256);
		setpalen(chunkypal, 256);

		while(running&&((funkctime=clock())<funketime))
		{
			scrollpos+=scrollspeed;
			drawtunnel(table, texturebuffer+scrollpos, chunkypic, 320*256);
			dbuffwaitdraw();
			c2p1x1_8_c5_bm((char *)chunkypic, screenbuffers[screennr]->sb_BitMap, 320,256, 0, 0);
			dbuffdispnew();
			if(checkmouse()) running=0;
		}

		if(texturebuffer) deinitchunky(256, 256*2, &texturebuffer);
		if(table) deinitchunky(320, 256*2, (UBYTE **)&table);
		texturebuffer=NULL; table=NULL;
		timerdiff();
	}

/* Kamelbild */ 
	if(running&&(funclentable[6]>0))
	{
		newfunctimer(funclentable[6]);

		for(counter=0; counter<(256*3); counter++)
		chunkypal[counter]=0xFF; // Ställer om hela paletten till vit!
		setpalen(chunkypal, 256);

		if(chunkypic) loadchunkypic("data/camel.chunky", chunkypic, 320, 256);
		dbuffwaitdraw();
		c2p1x1_8_c5_bm((char *)chunkypic, screenbuffers[screennr]->sb_BitMap, 320,256, 0, 0);
		dbuffdispnew();
		if(destchunkypal) loadpalette("data/camel.pal", destchunkypal, 256);

		for(col=255; running&&(col>=0); col--)
		{
			fadedownpal(chunkypal, destchunkypal, 256);
			setpalen(chunkypal, 256);
			if(checkmouse()) running=0;
		}
		while(running&&((funkctime=clock())<funketime))
		{
			if(checkmouse()) running=0;
		}
		timerdiff();
	}

/* FIRE!!!!!!! */

	if(running&&(funclentable[7]>0))
	{
		newfunctimer(funclentable[7]);
		memset(chunkypic, 0, 320*256);

		dbuffwaitdraw();
		c2p1x1_8_c5_bm((char *)chunkypic, screenbuffers[screennr]->sb_BitMap, 320,256, 0, 0);
		dbuffdispnew();

		if(chunkypal) loadpalette("data/fire.pal", chunkypal, 256);
		setpalen(chunkypal, 256);

		while(running&&((funkctime=clock())<funketime))
		{
			for(xpos=20; xpos<300; xpos++)
				*(chunkypic+320*254+xpos)=rand()%220+35;
			for(ypos=234; ypos<254; ypos++)
			{
				for(xpos=20; xpos<300; xpos++)
				{

					col=-7+((*(chunkypic+(ypos+1)*320+xpos-1)+
						*(chunkypic+(ypos+1)*320+xpos)+
						*(chunkypic+(ypos+1)*320+xpos+1)+
						*(chunkypic+(ypos+2)*320+xpos))/4);
							if(col<0) col=0;
							*(chunkypic+(ypos*320)+xpos)=col;
							*(chunkypic+(255-ypos)*320+xpos)=col;
				}
			}
			for(xpos=20; xpos<300; xpos++)
				*(chunkypic+320*254+xpos)=0;
			dbuffwaitdraw();
			c2p1x1_8_c5_bm((char *)chunkypic, screenbuffers[screennr]->sb_BitMap, 320,256, 0, 0);
			dbuffdispnew();
			if(checkmouse()) running=0;
		}

		if(texturebuffer) deinitchunky(64, 64, &texturebuffer);
		texturebuffer=NULL;
		timerdiff();
	}

/* Scrollen... */
	if(running&&(funclentable[8]>0))
	{
		newfunctimer(funclentable[8]);
		scrollbuffer=initchunky(320/8, 4096);
		if(scrollbuffer) loadchunkypic("data/scrolltext.raw", scrollbuffer, 320/8, 4096);
		if(chunkypic) loadchunkypic("data/endpic.chunky", chunkypic, 320, 256);
		if(chunkypal) loadpalette("data/endpic.pal", chunkypal, 256);
		maketpalette(chunkypal,35);
		setpalen(chunkypal, 256);
		dbuffwaitdraw();
		c2p1x1_8_c5_bm((char *)chunkypic, screenbuffers[screennr]->sb_BitMap, 320,256, 0, 0);
		dbuffdispnew();

		for(pos=0; running&&(pos<3840); pos++)
		{
			TurboBltBitMap(scrollbuffer, screenbuffers[1-screennr]->sb_BitMap, pos);
			WaitTOF();
			if(checkmouse()) running=0;
		}

		while(running&&((funkctime=clock())<funketime))
		{
			if(checkmouse()) running=0;
		}
		if(scrollbuffer) deinitchunky(320/8, 4096, &scrollbuffer);
		timerdiff();
	}

/* Och då var vi färdiga...Avsluta! */
	if(chunkypic) deinitchunky(320, 256, &chunkypic);
	if(chunkypal) deinitchunky(256, 3, &chunkypal);
	if(destchunkypal) deinitchunky(256, 3, &destchunkypal);

	stoptime = clock(); // The stop time is nice for the stats too...
//   printf("Running Time: %lf \n", (stoptime-starttime) / (double)CLOCKS_PER_SEC);
	if(music) stopsong();

}

/* Allmän smörja...vet inte vad det är för gammal betong... */

	//      yp=rand()%10;
	//      c2p1x1_8_c5_bm((char *)chunkypic, screenbuffers[screennr]->sb_BitMap, 320,256, 0, yp);
	//      for(counter=0; counter<(256*3); counter++)
	//            chunkypal[counter]=col; // Ställer om hela paletten till vit!
