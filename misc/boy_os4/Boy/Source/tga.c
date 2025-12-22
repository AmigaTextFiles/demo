
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

unsigned char *tga_load(char *name,int *xs,int *ys)
{
    FILE *fp;
    unsigned char *dada;
    int n,tmp,crap,x,y,xo,yo,stupid;

    fp=fopen(name,"rb");
    if(fp==NULL)
        return(NULL);

    crap=fgetc(fp); // Length of crap
    fgetc(fp);
    fgetc(fp);
    for(n=0;n<5;n++) // Colormap spec
        fgetc(fp);

    xo=fgetc(fp); // Origin
    xo+=fgetc(fp)*256;
    yo=fgetc(fp);
    yo+=fgetc(fp)*256;

    x=fgetc(fp); // Size
    x+=fgetc(fp)*256;
    y=fgetc(fp);
    y+=fgetc(fp)*256;

    dada=malloc(x*y*3);
    if(dada==NULL)
        return(NULL);

    fgetc(fp); // Pixel size - must be 24bit
    tmp=fgetc(fp);
    stupid=tmp&0x80; // Origin in upper left hand corner?

    for(n=0;n<crap;n++) // Image identification field (YEAH RITE!)
        fgetc(fp);

    // Read the data
    for(n=0;n<y;n++)
    {
        if(stupid)
            fread(&dada[n*x*3],3,x,fp);
        else
            fread(&dada[(y-n-1)*x*3],3,x,fp);
    }

    // Swap BGR to RGB in memory
    for(n=0;n<x*y;n++)
    {
        tmp=dada[n*3];
        dada[n*3]=dada[n*3+2];
        dada[n*3+2]=tmp;
    }

    fclose(fp);

    *xs=x;
    *ys=y;
    return dada;
}
