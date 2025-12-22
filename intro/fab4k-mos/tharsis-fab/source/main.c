#include <math.h>
#include <stdlib.h>
#include <SDL.h>
#include <SDL_opengl.h>

#define I int
#define D double
#define V glVertex2d
#define B glBegin
#define C glColor3d
#define T glTranslated
#define R glRotated
#define S(s) glScaled(s,s,s)

#define P2 (3.14159265*2)

D f=1;

typedef struct Strip {
  D l, r;
} Strip;

typedef struct Job {
  void (*f)();
  I e, b, v;
} Job;

D ran(D m)
{
  return m*((D)rand()/RAND_MAX)-m/2;
}

polygon(I N, D F, D o, D a)
{
  I i=N+1;
  D f=0;
  B(6);
  V (0,0);
  while(i--) {
    D s = (o+a*cos(f*P2/N))*sin((P2*i)/N),
      c = (o+a*cos(f*P2/N))*cos((P2*i)/N);
    V (s,c);
    f+=F;
  }
  glEnd();
} 

strip(I i, I n, D k, Strip *s)
{
  D x2=.5*k, y2= .5*k;

  B(8);

  while(1+n--) {
    glColor4d(1,0,0,.5);
    if (n<=10) glColor4d(1,0,0,n/20.);
    if (i<=100) glColor4d(1,0,0,i/200.);
    V (x2-k, y2-k);
    V (x2, y2);
    y2 += s->l * sin (P2*s->r);
    x2 += s->l * cos (P2*s->r);
    s++;
    i++;
  }
  glEnd();
}

quads(I n, D df1, D df2, D da)
{
  D a=.1,
    f1=0, f2=0,
    x1=0, y1=0,
    x2=0, y2=0;

  glColor4d (1, 0, 0,.3);
  B(8);
  V (x1, y1);
  V (x2, y2);

  for (;n--;) {
    x1 += a*sin(P2*f1);
    y1 += a*cos(P2*f1);
    x2 += a*sin(P2*f2);
    y2 += a*cos(P2*f2);
    V (x1, y1);
    V (x2, y2);
    f1+=df1;
    f2+=df2;
    a+=da;
  }
  glEnd();
}

spiral()
{
  static i=1;
  static D 
    r1=.01, r2=.015, a=0,
    da=-.0005, dr1=.002, dr2=.0022;

  r1+=dr1;
  r2+=dr2;
  a+=da;
  T (-1,-1,-.02);
  R (f*3,0,0,1);
  quads (60, r1/2, r2/2, a);

  if (!(i&31)) {
    da = -da;
    dr1 = -dr1;
    dr2 = -dr2;
  }
  i++;
}

ellipses(D f)
{
  I i;
  D d[][5]={
    0, 0, 0, 0,   2,
    1,  1, 1, 2.3, 1.6,
    0, 0, 0, 0,   1.5,
    1,  1, 0, -.3, 1.3
  }, *p=d;
  S (2);
  T (1.1,1.1,0);
  C (0,0,0);
  R (-f,0,0,1);
  polygon (180, 3, 2.1, .2);
  S (.99);
  C (1,1,.5);
  polygon (180, 3, 2.1, .2);

  for (i=4;i--;p+=5) {
    C (p[0], p[1], p[2]);
    R (p[3]*f,0,0,1);
    polygon (60, 1, p[4]*(f+100)/(f+25), .16);
  }
}

koe(D b, I n)
{
  static j[9];
  static Strip v[9][290], *s;
  I i=j[n];
  s=v[n];

  if (i>=0 && i<5) {
    I l=10;
    D dr=0, r=0;
    for (i=0;i<290;i++) {
      if (i%l==0) {
	dr=ran(.3);
	l = 10+rand()/(RAND_MAX/10);
      }
      s[i].l = (.4+ran(.1))/(10*r*r+.8);
      r = (r+dr)*.8;
      s[i].r = r<-.5?-.5:r>.5?.5:r  ;
    }
    i=0;
  }
        
  T (-3,0,0);
  C (0, 0, 0);
  S (.2);
  if(i>=0) strip (140-i, i, .5, s);
  else     strip (-350-i, 290, .5, s);
  i+=5;
  if (i>=290) i=-200;
  j[n]=i;
}

genbox()
{
  I m,i=2;

  T(-.5,-.5,-.5);
  while(i--) {
    B(6);
    for(m=384;m/=2;) 
      glVertex3d(i==!(m&33), i==!(m&24), i==!(m&6));
    glEnd();
  }
}

cube()
{
  static D v[99][7];
  static i=0, n, j=0, d;

  if (!i) {i=j=0; d=8; n = 10+rand()/(RAND_MAX/64); }
  if (i<n) {
    glNewList(3, 4864);
    glEnable(2929);
    glDepthFunc(515);
    for (;j<=i;j++) {
      v[j][0] = ran(10);
      v[j][1] = ran(10);
      v[j][2] = ran(2);
      v[j][3] = ran(1);
      v[j][4] = ran(1);
      v[j][5] = ran(1);
      v[j][6] = ran(360);
    }
    for (j=0; j<=i; j++) {
      D *u=v[j];
      glPushMatrix();
      C(0,0,0);
      T (u[0],u[1],u[2]-8);
      R (u[6],u[5],u[4],u[3]);
      genbox();
      C(0,0,0);
      S (.5);
      genbox();
      glPopMatrix();
    }
    glDisable(2929);
    glEndList();
  }
  glCallList(3);
  i+=d;
  if(i==512) d=-d;
}

cube2(D n, I i)
{
  T (0,0,-5+n/64.);
  S (5);
  for (i=10;i--;) {
    D a=.5-10*(i+1.)/(n+1);
    R (i-f/9., .2,.1,.2);
    if (i&1)    glColor4d(.6,.6,.6,a);
    else        glColor4d(.8,.8,.7,a);
    S (.9);
    glPushMatrix();
    genbox();
    glPopMatrix();
  }
}

static struct Osc {
  D a, f, df;
} os[100];

D osc(struct Osc *o, D A, D F)
{
  o->df += o->f-1;
  o->f -= P2*P2 * o->df/(F*F);
  o->f = o->f<0?0:o->f;
  o->a = (o->a+A)/2;
  return (o->f-1)*o->a;
}
  
D a, num=1;
D hammond(D p, I c)
{
  D f[9]={ 1, 3, 2, 4, 16,  12, 10, 8, 6};
  D v[9]={1,.1,0.5,0.1,0,0,0.1,0,.1};
  I j=9;
  D r=0;
  for (;j--;) {
    D x = .9+osc(&os[c+9],.1,15e4);
    r+=osc(&os[j+c], (v[j]+j*a*.1)*x, 1800/(p*f[j]));
  }
  return r;
}

#define nDs(o) 1.189207 * (1<<o)
#define nG(o)  1.498307 * (1<<o)
#define nGs(o) 1.587401 * (1<<o)
#define nAs(o) 1.781797 * (1<<o)

I t=0;
struct Chn {
  D p, v;
} ch[65][2]={
  [0]  = { {nG(1),2.5},  {nG(2),1} },
  [22] = { {nGs(1), 2.5}, {nDs(2),1.5} },
  [30] = { {nDs(1), 2.5}, {nAs(1),1}  },
};

D
play ()
{
  D r=0;
  I i,
    cp=(t/8192)&63;
  for(i=0;i<num;i++) {
    struct Chn *p=&ch[cp][i];
    r += p->v * hammond(p->p, 10*i);
    if ((p+2)->p<1) *(p+2)=*p;
  }
  return r;
}

aud(I u, short *s, I l)
{
  for (l/=2;l--;t++) {
    a = .3-.3*cos(t*2e-7)-.05*cos(t*4e-4);
    *s++ = (1<<17) * atan (play()) / P2;
    num=2-!(t&0x100000);
  }
}

Job jobs[]={
  { spiral, 10000, 600 },
  { ellipses, 10000, 400 },
  { cube, 1000 },
  { cube2, 600},
  { koe, 550,100 },
  { koe, 550,120,1 },
  { koe, 550,140,2 },
  { koe, 600,160,3 },
  { koe, 650,180,4 },
  0
};

SDL_AudioSpec as={
  .freq=44100,.format=AUDIO_S16,.channels=1,.samples=4096,.callback=aud
};

main (I q, char **p)
{
  SDL_Event e;
  Job *j;
  D d=1, w=640, h=480;

  SDL_Init(32);
  SDL_SetVideoMode(w,h, 32, 2);
  SDL_OpenAudio (&as,0);
  gluPerspective (45,w/h,5,100);
  T (0,0,-5);
  glClearColor(1,1,0,1);
  glEnable(3042);
  glBlendFunc (770,771);

  SDL_PauseAudio (0);
  while (!SDL_PollEvent (&e) || e.type!=2)
    {
      glClear (65<<8);

      for (j=jobs;j->f;j++) {
	glPushMatrix();
	if (f>=j->b && f<j->e) j->f(f-j->b,j->v);
	glPopMatrix();
      }

      SDL_GL_SwapBuffers ();
      f+=d;
      if (f>1000 || f<1) d=-d;
    }
  puts ("Fab    by    tharsis of Bliss\n"
	"for the 2004 4k compo");
}
