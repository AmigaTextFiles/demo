
#include "cgm.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

static int leftof(int x1,int y1,int x2,int y2,int px,int py);
static int triangulate(int num,int *crd,int *tris,int **res);

CGM *cgm_load(char *name)
{
    CGM     *cgm;

    ELEMENT *e,*ptr;

    FILE    *s;

    char    c,
            str[100];

    int     r,g,b,
            n,i,
            flag,flag2,
            x,y,
            minx=10000,miny=10000,maxx=-10000,maxy=-10000,
            hx,hy,scale,
            cur=1,edge=1,
            fillstyle=1,
            edgestyle=1,edgewidth=1,
            ci=1;

    static int  vrt[1000],
                clut[100];  /* Lookup needed for the stupid palette system */

    cgm=malloc(sizeof(CGM));
    cgm->head=NULL;
    cgm->back=0;
    cgm->pal[0]=0;

    s=fopen(name,"rb");
    if(s==NULL)
        return(NULL);

    fscanf(s,"%s",str);     /* Is it a metafile at all? */
    if(strcmp("BEGMF",str))
        return(NULL);

    while(strcmp("colrtable",str)) /* Find color table */
        fscanf(s,"%s",str);
    fscanf(s,"%s",str);

    flag=1;
    n=0;
    while(flag) /* Read the colors */
    {
        fscanf(s,"%d%d%s",&r,&g,str);
        if(str[strlen(str)-1]==';') /* Last color? */
            flag=0;
        b=atoi(str);

        cgm->pal[ci]=(r<<16)+(g<<8)+b;
        clut[ci]=ci;
        ci++;
        n++;
    }

    flag=1;
    while(flag)    /* Scan through the drawing commands */
    {
        fscanf(s,"%s",str);

        /* Color change found */
        if(!strcmp("fillcolr",str))
        {
            fscanf(s,"%s",str);
            cur=clut[atoi(str)];
        }

        if(!strcmp("colrtable",str))
        {
            fscanf(s,"%d%d%d%d",&n,&r,&g,&b);
            flag2=-1;
            for(i=1;i<ci;i++)
                if(cgm->pal[i]==(r<<16)+(g<<8)+b)
                    flag2=i;

            if(flag2==-1) /* Add new color */
            {
                cgm->pal[ci]=(r<<16)+(g<<8)+b;
                clut[n]=ci;
                ci++;
            }
            else /* Point to some old one */
                clut[n]=flag2;
        }
    
        /* Background */
        if(!strcmp("backcolr",str))
        {
            fscanf(s,"%d%d%d",&r,&g,&b);
            cgm->back=(r<<16)+(g<<8)+b;
        }

        /* Edge color */
        if(!strcmp("linecolr",str))
        {
            fscanf(s,"%s",str);
            edge=clut[atoi(str)];
        }

        /* Edge/linewidth */
        if(!strcmp("linewidth",str) || !strcmp("edgewidth",str))
        {
            fscanf(s,"%s",str);
            edgewidth=atoi(str)/15;
        }

        /* Fill or not? */
        if(!strcmp("intstyle",str))
        {
            fscanf(s,"%s",str);
            if(str[0]=='E')
                fillstyle=0;
            if(str[0]=='S')
                fillstyle=1;
        }

        /* Edges visible or not? */
        if(!strcmp("edgevis",str))
        {
            fscanf(s,"%s",str);
            if(str[1]=='N') /* ON */
                edgestyle=1;
            if(str[1]=='F') /* OFF */
                edgestyle=0;
        }

        /* line or poly found */
        if(!strcmp("polygon",str) || !strcmp("line",str) ||
           !strcmp("rect",str))
        {
            n=c=0;
            flag2=1;
            while(flag2)    /* Go through the coords */
            {
                while(c!='(')
                    c=fgetc(s);

                fscanf(s,"%d",&x);
                fgetc(s);
                fscanf(s,"%d",&y);

                vrt[n*2]=x;
                vrt[n*2+1]=y;

                if(x>maxx) maxx=x;
                if(x<minx) minx=x;
                if(y>maxy) maxy=y;
                if(y<miny) miny=y;

                n++;

                fgetc(s);
                if((c=fgetc(s))==';')
                    break;
            }

            /* Make a polygon out of the rectangle */
            if(!strcmp("rect",str))
            {
                vrt[2*2]=vrt[1*2]; vrt[2*2+1]=vrt[1*2+1];
                vrt[1*2]=vrt[0];
                vrt[3*2]=vrt[2*2]; vrt[3*2+1]=vrt[1];
                vrt[4*2]=vrt[0]; vrt[4*2+1]=vrt[1];

                strcpy(str,"polygon");
                n=5;
            }

            e=malloc(sizeof(ELEMENT));
            e->points=n;
            e->pointsv=malloc(n*2*sizeof(int));
            memcpy(e->pointsv,vrt,n*2*sizeof(int));
            e->color=cur;
            e->linecolor=edge;
            e->linewidth=edgewidth;

            e->types=0;
            if(!strcmp("line",str) ||
               (!strcmp("polygon",str) && edgestyle && edgewidth))
                e->types+=CGM_POLYLINE;

            if(!strcmp("polygon",str) && fillstyle)
                e->types+=CGM_POLYGON;

            e->next=NULL;
            if(cgm->head==NULL)
                cgm->head=e;
            else
            {
                ptr=cgm->head;
                while(ptr->next!=NULL)
                    ptr=ptr->next;
                ptr->next=e;
            }

            /* Remove duplicate coordinate from loop */
            if(vrt[0]==vrt[(n-1)*2] && vrt[1]==vrt[(n-1)*2+1])
                n--;

            if(e->types&CGM_POLYGON)
                triangulate(n,vrt,&e->tris,&e->trisv);
        }

        if(feof(s))
            flag=0;
    }

    hx=(maxx+minx)/2;
    hy=(maxy+miny)/2;
    if(maxx-minx>maxy-miny)
        scale=(maxx-minx)/2;
    else
        scale=(maxy-miny)/2;

    ptr=cgm->head;
    while(ptr!=NULL)
    {
        for(n=0;n<ptr->points*2;n+=2)
        {
            ptr->pointsv[n]=(ptr->pointsv[n]-hx)*65536/scale;
            ptr->pointsv[n+1]=(ptr->pointsv[n+1]-hy)*65536/scale;
        }

        if(ptr->types&CGM_POLYGON)
            for(n=0;n<ptr->tris*6;n+=2)
            {
                ptr->trisv[n]=(ptr->trisv[n]-hx)*65536/scale;
                ptr->trisv[n+1]=(ptr->trisv[n+1]-hy)*65536/scale;
            }
            
        ptr=ptr->next;
    }
    cgm->colors=ci-1;

    fclose(s);
    return(cgm);
}

static int leftof(int x1,int y1,int x2,int y2,int px,int py)
{
    int nx,ny;

    x2-=x1; y2-=y1;
    px-=x1; py-=y1;
    nx=-y2; ny=x2;

    if(nx*px+ny*py>0)
        return(1);
    else
        return(0);
}

static int triangulate(int num,int *crd,int *tris,int **res)
{
    int     n,ti=0,i,empty,tmp,jam=0;

    int     *re,
            x1,y1, x2,y2, x3,y3,
            ax,ay, bx,by,
            nx,ny,
            miny,mi;

    re=malloc((num-2)*2*3*sizeof(int));
    *res=re;
    *tris=num-2;

    /* Check if clockwise */
    mi=0;
    miny=1000000;
    for(i=0;i<num;i++) /* Top vertex */
        if(crd[i*2+1]<miny)
        {
            mi=i;
            miny=crd[i*2+1];
        }

    x2=crd[mi*2]; y2=crd[mi*2+1];
    x3=crd[((mi+1)%num)*2]; y3=crd[((mi+1)%num)*2+1];
    x1=crd[(mi-1+num)%num*2]; y1=crd[(mi-1+num)%num*2+1];

    x3-=x2; y3-=y2;
    x1-=x2; y1-=y2;
    nx=-y3; ny=x3;
    if(nx*x1+ny*y1<0) /* Clockwise. Reverse them. */
    {
        for(i=0;i<num/2;i++)
        {
            tmp=crd[i*2];
            crd[i*2]=crd[num*2-2-i*2];
            crd[num*2-2-i*2]=tmp;

            tmp=crd[i*2+1];
            crd[i*2+1]=crd[num*2-2-i*2+1];
            crd[num*2-2-i*2+1]=tmp;
        }
    }

    i=0;
    while(num!=2)
    {
        x1=crd[i*2]; y1=crd[i*2+1];
        x2=crd[((i+1)%num)*2]; y2=crd[((i+1)%num)*2+1];
        x3=crd[((i+2)%num)*2]; y3=crd[((i+2)%num)*2+1];

        ax=x3-x2; ay=y3-y2;
        bx=x1-x2; by=y1-y2;

        /* <180 degrees? */
        nx=-ay;
        ny=ax;
        if(bx*nx+by*ny>0)
        {
            /* Is the triangle empty? */
            empty=1;
            for(n=0;n<num;n++)
            {
                if(n!=i && n!=(i+1)%num && n!=(i+2)%num)
                {
                    ax=crd[n*2];
                    ay=crd[n*2+1];

                    if(leftof(x1,y1,x2,y2,ax,ay) &&
                       leftof(x2,y2,x3,y3,ax,ay) &&
                       leftof(x3,y3,x1,y1,ax,ay))
                    {
                        empty=0;
                        break;
                    }
                }
            }

            if(empty) /* Add triangle */
            {
                re[ti+0]=x1;
                re[ti+1]=y1;
                re[ti+2]=x2;
                re[ti+3]=y2;
                re[ti+4]=x3;
                re[ti+5]=y3;

                for(n=(i+1)%num;n<num-1;n++) /* Remove from polygon */
                {
                    crd[n*2]=crd[n*2+2];
                    crd[n*2+1]=crd[n*2+3];
                }

                num--;
                ti+=6;
                jam++;
            }
        }

        i++;
        if(i>=num)
        {
            i=0;

            jam--; /* Are we stuck? */
            if(jam<0)
            {
                *tris=0;
                return(-1);
            }
        }
    }

    return(0);
}
