
#include <stdlib.h>
#include <stdio.h>

unsigned char *musakki,*dd,*na_eka,*na_toka,*onnettomuus,
              *paa,*siunaus,*ukko,*ratas,*kooste,
              *chrysler;

int readfile(char *name,unsigned char **dest)
{
    FILE *f;
    long    len;

    f=fopen(name,"rb");
    if(f==NULL)
        return(1);
    fseek(f,0,SEEK_END);
    len=ftell(f);
    *dest=malloc(len);
    if(*dest==NULL)
        return(1);
    fseek(f,0,SEEK_SET);
    fread(*dest,1,len,f);
    fclose(f);

    return(0);
}

int readall(void)
{
    int val=0;

    val+=readfile("data/tehas2.mod",&musakki);
    val+=readfile("data/dd.raw",&dd);
    val+=readfile("data/na_eka.raw",&na_eka);
    val+=readfile("data/na_toka.raw",&na_toka);
    val+=readfile("data/onnettomuus.raw",&onnettomuus);

    val+=readfile("data/paa.raw",&paa);
    val+=readfile("data/siunaus.raw",&siunaus);
    val+=readfile("data/ukko.raw",&ukko);
    val+=readfile("data/ratas.raw",&ratas);
    val+=readfile("data/kooste.raw",&kooste);

    val+=readfile("data/chrysler.raw",&chrysler);
    return(val);
}
