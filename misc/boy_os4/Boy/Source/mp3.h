/*
    mpglib wrapper routines for SDL. As simple as they get.
    - Marq
*/

#ifndef MP3_H
#define MP3_H

#include <math.h>

#define MP3_FREQ 44100
#define MP3_BUFSIZE 8192
#define MP3_AUDIOBUF 1024

int mp3_init(void);             /* Init sound system */
int mp3_load(char *name);       /* Load mp3 file     */
void mp3_get(void *data,int len); /* Play from memory  */
void mp3_play(void);            /* Start playing     */
void mp3_stop(void);            /* Stop playing      */
int mp3_pos(void);              /* Number of samples played         */
int mp3_time(void);             /* Minutes*100+seconds since start  */

extern float mp3_floatbuf[];
extern int mp3_floatvals;

#endif
