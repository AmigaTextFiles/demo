
#include <string.h>
#include "wavefront.h"
#include "gl_render.h"
#include "writer.h"
#include <SDL_opengl.h>

SCENE fnt;

int writer_init(char *fontname)
{
    if(load_scene(&fnt,fontname))
        return(-1);
    return(0);
}

void writer(char *text,int flags,int render)
{
    int n;
    char cha[2]=" ";
    OBJ *o;
    float   w=0,lm=0.0,rm=0.0,miny=1000,maxy=-1000,y,r;

    // We need the width
    for(n=0;n<strlen(text);n++)
    {
        cha[0]=text[n];
        if(cha[0]==' ')
            w+=WR_SPACE;
        else
        {
            o=find_object(&fnt,cha);
            if(o)
            {
                if(n!=0)
                    w+=WR_GAP;
                w+=o->bx[1];
                if(o->by[0]<miny)
                    miny=o->by[0];
                if(o->by[1]>maxy)
                    maxy=o->by[1];
            }
        }
    }

    if(flags&WR_CENTER)
        glTranslatef(-w/2,0,0);
    if(flags&WR_RIGHT)
    {
        glTranslatef(-w,0,0);
        rm=1.5;
    }
    else
        lm=1.5;

    // Draw a bg plaque for text
    if(flags&WR_BG)
    {
        for(n=0;n<2;n++)
        {
            if(n)
                glColor3f(1,1,1);
            else
                glColor3f(0,0,0);
            glPushMatrix();
            if(!n)
                glTranslatef(0.04,-0.06,0);
    
            r=(maxy-miny)/2.0+0.24;
            glBegin(GL_POLYGON);
            for(y=0;y<=M_PI*2;y+=0.2)
                glVertex3f(w+rm+cos(y)*r,(maxy+miny)/2+sin(y)*r,-0.05);
            glEnd();
    
            glBegin(GL_POLYGON);
            for(y=0;y<=M_PI*2;y+=0.2)
                glVertex3f(-lm+cos(y)*r,(maxy+miny)/2+sin(y)*r,-0.05);
            glEnd();
    
            glBegin(GL_QUADS);
            glVertex3f(-lm,miny-0.24,-0.05);
            glVertex3f(w+rm,miny-0.24,-0.05);
            glVertex3f(w+rm,maxy+0.24,-0.05);
            glVertex3f(-lm,maxy+0.24,-0.05);
            glEnd();

            glPopMatrix();
        }
    }

    for(n=0;n<strlen(text);n++)
    {
        cha[0]=text[n];
        if(cha[0]==' ')
            glTranslatef(WR_SPACE,0,0);
        else
        {
            o=find_object(&fnt,cha);
            if(o)
            {
                if(n!=0)
                    glTranslatef(WR_GAP,0,0);
                render_object(&fnt,o,render);
                glTranslatef(o->bx[1],0,0);
            }
        }
    }
}

void writers_update(int tid,int beat2,int pink)
{
    int n,align=0,beat=beat2/2;
    static struct wr_event events1[]={ // Writer list
    {10,14, -1,WR_RL, "the fiture crew"},
    {14,18, -1,WR_RL, "is pulling"},
    {18,22, -1,WR_RL, "the strings"},
    {22,26, -1,WR_RL, "so..."},

    {48,52, -1,WR_LL+WR_BG, "let me tell you"},
    {52,56, -1,WR_LL+WR_BG, "some facts about"},
    {56,60, -1,WR_LL+WR_BG, "the life of a man"},
    {60,64, -1,WR_LL+WR_BG, "as it should be."},

    {68,72, -1,WR_LU+WR_BLINK+WR_BG, "big bucks, son"},
    {72,76, -1,WR_LU+WR_BLINK+WR_BG, "that's what counts"},
    {76,80, -1,WR_LU+WR_BLINK+WR_BG, "loads of dough"},
    {80,84, -1,WR_LU+WR_BLINK+WR_BG, "it makes you feel"},
    {84,88, -1,WR_LU+WR_BLINK+WR_BG, "just a little bit"},
    {88,92, -1,WR_LU+WR_BLINK+WR_BG, "special."},

    {96,104, -1,WR_RU+WR_BLINK+WR_BG, "get connected"},
    {104,112, -1,WR_RU+WR_BLINK+WR_BG, "with the right"},
    {112,120, -1,WR_RU+WR_BLINK+WR_BG, "kind of people"},
    {120,128, -1,WR_RU+WR_BLINK+WR_BG, "skyrocket your career"},

    {128,132, -1,WR_LL, "don't let nobody"},
    {132,136, -1,WR_LL, "push you around."},
    {136,140, -1,WR_LL, "got that, son"},
    {140,144, -1,WR_LL, "you're in control."},
    {144,148, -1,WR_LL, "you tell them."},
    {148,152, -1,WR_LL, "you the cheese,"},
    {152,156, -1,WR_LL, "you the man,"},
    {156,160, -1,WR_LL, "no time for losers"},

    {168,172, -1,WR_RU, "women, hell yeah..."},
    {172,176, -1,WR_RU, "you know, boy"},
    {176,180, -1,WR_RU, "treat 'em like trash"},
    {180,184, -1,WR_RU, "and they'll be"},
    {184,188, -1,WR_RU, "at your feet"},

    {192,196, -1,WR_RU, "a man's got his needs"},
    {196,200, -1,WR_RU, "so go and play, son"},
    {200,204, -1,WR_RU, "just don't get"},
    {204,208, -1,WR_RU, "yourself hooked."},
    {208,212, -1,WR_RU, "above all,"},
    {212,216, -1,WR_RU, "business is business."},

    {224,228, -1,WR_LL+WR_BLINK+WR_BG, "get a gun"},
    {232,236, -1,WR_LL+WR_BLINK+WR_BG, "or better, get two."},
    {240,244, -1,WR_LL+WR_BLINK+WR_BG, "nobody stands"},
    {248,252, -1,WR_LL+WR_BLINK+WR_BG, "in your way"},

    {260,264, -1,WR_LU+WR_BLINK+WR_BG, "you're so far"},
    {264,268, -1,WR_LU+WR_BLINK+WR_BG, "above this hellhole."},
    {268,272, -1,WR_LU+WR_BLINK+WR_BG, "set yourself"},
    {272,276, -1,WR_LU+WR_BLINK+WR_BG, "a goal, reach it"},
    {276,280, -1,WR_LU+WR_BLINK+WR_BG, "and the big city"},
    {280,284, -1,WR_LU+WR_BLINK+WR_BG, "will be yours."},

    {288,296, -1,WR_LU+WR_BLINK+WR_BG, "...and the big city"},
    {296,304, -1,WR_LU+WR_BLINK+WR_BG, "will be yours."},

    {328,332, -1,WR_LL+WR_BG+WR_BLINK, "the men behind"},
    {332,336, -1,WR_LL+WR_BG+WR_BLINK, "the scenes."},
    {336,344, -1,WR_LL+WR_BG+WR_BLINK, "marq"},
    {344,348, -1,WR_LL+WR_BG, "in code and gfx"},
    {352,356, -1,WR_LL+WR_BG+WR_BLINK, "and"},
    {356,364, -1,WR_LL+WR_BG+WR_BLINK, "roz"},
    {364,368, -1,WR_LL+WR_BG, "in music"},

    {392,396, -1,WR_LU, "hello to our"},
    {396,400, -1,WR_LU, "business partners..."},

    {404,412, -1,WR_LU, "ananasmurska"},
    {412,420, -1,WR_LU, "bandwagon"},
    {420,428, -1,WR_LU, "byterapers"},
    {428,436, -1,WR_LU, "coma"},
    {436,444, -1,WR_LU, "dcs"},
    {444,452, -1,WR_LU, "dekadence"},
    {452,460, -1,WR_LU, "halcyon"},
    {460,468, -1,WR_LU, "immersion"},
    {468,476, -1,WR_LU, "pkp"},
    {476,484, -1,WR_LU, "rno"},
    {484,492, -1,WR_LU, "unique"},
    {492,500, -1,WR_LU, "wamma"},
    {500,508, -1,WR_LU, "zenon"},

    {-1,0, -1,0, ""}
    },

    events_pink[]={ // Writer list for -pink
    {10,14, -1,WR_RL, "the fiture crew"},
    {14,18, -1,WR_RL, "is pulling down"},
    {18,22, -1,WR_RL, "her strings"},
    {22,26, -1,WR_RL, "so..."},

    {48,52, -1,WR_LL+WR_BG, "let me tell you"},
    {52,56, -1,WR_LL+WR_BG, "some facts about"},
    {56,60, -1,WR_LL+WR_BG, "the life of a man"},
    {60,64, -1,WR_LL+WR_BG, "with his hot lady."},

    {68,72, -1,WR_LU+WR_BLINK+WR_BG, "yeah, i like 'em"},
    {72,76, -1,WR_LU+WR_BLINK+WR_BG, "big and juicy"},
    {76,80, -1,WR_LU+WR_BLINK+WR_BG, "nothing like"},
    {80,84, -1,WR_LU+WR_BLINK+WR_BG, "some of that"},
    {84,88, -1,WR_LU+WR_BLINK+WR_BG, "good ol'"},
    {88,92, -1,WR_LU+WR_BLINK+WR_BG, "lovemaking"},

    {96,104, -1,WR_RU+WR_BLINK+WR_BG, "you know that feeling,"},
    {104,112, -1,WR_RU+WR_BLINK+WR_BG, "at times you"},
    {112,120, -1,WR_RU+WR_BLINK+WR_BG, "just got to"},
    {120,128, -1,WR_RU+WR_BLINK+WR_BG, "get some"},

    {128,132, -1,WR_LL, "mmm, baby..."},
    {132,136, -1,WR_LL, "treat me rough"},
    {136,140, -1,WR_LL, "treat me nice"},
    {140,144, -1,WR_LL, "just like that..."},
    {144,148, -1,WR_LL, "tonight's just"},
    {148,152, -1,WR_LL, "for the two of us,"},
    {152,156, -1,WR_LL, "so get your"},
    {156,160, -1,WR_LL, "pretty ass here"},

    {168,172, -1,WR_RU, "a true man"},
    {172,176, -1,WR_RU, "of the world"},
    {176,180, -1,WR_RU, "sure knows how to"},
    {180,184, -1,WR_RU, "treat her lady."},
    {184,188, -1,WR_RU, "don't rush to it"},

    {192,196, -1,WR_RU, "no, son..."},
    {196,200, -1,WR_RU, "you'll have to"},
    {200,204, -1,WR_RU, "make her hot"},
    {204,208, -1,WR_RU, "little by little,"},
    {208,212, -1,WR_RU, "kissing, cuddling,"},
    {212,216, -1,WR_RU, "make her go wild."},

    {224,228, -1,WR_LL+WR_BLINK+WR_BG, "sometimes"},
    {232,236, -1,WR_LL+WR_BLINK+WR_BG, "you're on top"},
    {240,244, -1,WR_LL+WR_BLINK+WR_BG, "sometimes"},
    {248,252, -1,WR_LL+WR_BLINK+WR_BG, "you take turns"},

    {260,264, -1,WR_LU+WR_BLINK+WR_BG, "lips on lips"},
    {264,268, -1,WR_LU+WR_BLINK+WR_BG, "skin on skin"},
    {268,272, -1,WR_LU+WR_BLINK+WR_BG, "let me take you"},
    {272,276, -1,WR_LU+WR_BLINK+WR_BG, "to the top."},
    {276,280, -1,WR_LU+WR_BLINK+WR_BG, "when i'm done, honey,"},
    {280,284, -1,WR_LU+WR_BLINK+WR_BG, "you'll ask for more"},

    {288,296, -1,WR_LU+WR_BLINK+WR_BG, "...when i'm done"},
    {296,304, -1,WR_LU+WR_BLINK+WR_BG, "you'll beg for more"},

    {328,332, -1,WR_LL+WR_BG+WR_BLINK, "meet the"},
    {332,336, -1,WR_LL+WR_BG+WR_BLINK, "daddies..."},
    {336,344, -1,WR_LL+WR_BG+WR_BLINK, "marq"},
    {344,348, -1,WR_LL+WR_BG, "the smooth fingers"},
    {352,356, -1,WR_LL+WR_BG+WR_BLINK, "and"},
    {356,364, -1,WR_LL+WR_BG+WR_BLINK, "roz"},
    {364,368, -1,WR_LL+WR_BG, "the soul stallion"},

    {392,396, -1,WR_LU, "thanks for all the"},
    {396,400, -1,WR_LU, "sweet moments..."},

    {408,416, -1,WR_LU, "barry white"},
    {416,424, -1,WR_LU, "eternal erection"},
    {424,432, -1,WR_LU, "funkadelic"},
    {432,440, -1,WR_LU, "isaac hayes"},
    {440,448, -1,WR_LU, "james brown"},
    {448,456, -1,WR_LU, "marvin gaye"},
    {456,464, -1,WR_LU, "natalie portman"},
    {464,472, -1,WR_LU, "penelope cruz"},
    {472,480, -1,WR_LU, "ron jeremy"},
    {480,488, -1,WR_LU, "samantha fox"},
    {488,496, -1,WR_LU, "stevie wonder"},
    {496,504, -1,WR_LU, "ziyi zhang"},

    {-1,0, -1,0, ""}
    },
    *events;

    if(pink)
        events=events_pink;
    else
        events=events1;

    glDisable(GL_DEPTH_TEST);
    for(n=0;events[n].startb!=-1;n++)
    {
        align=0;
        if(beat>=events[n].startb && beat<events[n].endb)
        {
            glLoadIdentity(); // Corner placement
            if(events[n].flags&WR_LU)
                glTranslatef(-12.5,7.8,-20);
            if(events[n].flags&WR_LL)
                glTranslatef(-12.5,-9.2,-20);
            if(events[n].flags&WR_RL)
            {
                glTranslatef(12.5,-9.2,-20);
                align=WR_RIGHT;
            }
            if(events[n].flags&WR_RU)
            {
                glTranslatef(12.5,7.8,-20);
                align=WR_RIGHT;
            }

            if(events[n].flags&WR_BLINK && beat2&1) // Blinking
                continue;
            if(events[n].flags&WR_BG)
                align+=WR_BG;
            writer(events[n].text,align,RENDER_NORMAL+RENDER_NOLIGHTS);
        }
    }

    glDisable(GL_CULL_FACE);
}
