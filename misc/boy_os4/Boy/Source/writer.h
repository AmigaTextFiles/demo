
#ifndef WRITER_H
#define WRITER_H

#define WR_CENTER 1
#define WR_RIGHT 2
#define WR_GAP 0.13
#define WR_SPACE 0.3

#define WR_LU 1
#define WR_LL 2
#define WR_RU 4
#define WR_RL 8
#define WR_BLINK 16
#define WR_BG 32

struct wr_event
{
    int startb,endb,
        ctr,flags;
    char *text;
};

int writer_init(char *fontname);
void writer(char *text,int flags,int render);
void writers_update(int tid,int beat2,int pink);

#endif
