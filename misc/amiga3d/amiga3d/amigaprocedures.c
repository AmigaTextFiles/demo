#include <exec/types.h>
#include "threed.h"

/* #define PROCDEBUG */

universeprocedure(argc,argv)
int argc;
char *argv[];
{
    static int error;
    static int count;
    int i;

#ifdef PROCDEBUG
    printf("universeprocedure: executing universeprocedure()...\n");
#endif

    for(i=0; i<argc; i++)
    {

#ifdef PROCDEBUG
    printf("argv[%lx] = %lx\n",argc,argv[i]);
#endif
        ;
    }

    switch(argc)
    {
   case 0 : error = TRUE;  /* no objectinfopointer */
       return(error);
   case 1 : error = FALSE; /* no subroutines to execute */
       return(error);
   case 2 : count++;
       {
           struct Objectinfo ** oipp;
           int (**subp)();
           int (*sub)();

           oipp = *argv;
           subp = *(argv+1);
#ifdef PROCDEBUG
     printf("oipp = %lx; *oipp = %lx; **oipp = %lx\n",oipp,*oipp,**oipp);
     printf("subp = %lx; *subp = %lx; **subp = %lx\n",subp,*subp,**subp);
#endif
       }
       break; 
   default: break;
    }

    return(error);
}

amigaprocedure(argc,argv)
int argc;
char *argv[];
{
    static int error;
    static int count;
    int i;

#ifdef PROCDEBUG
    printf("amigaprocedure: executing amigaprocedure()...\n");
#endif

    for(i=0; i<argc; i++)
    {

#ifdef PROCDEBUG
    printf("argv[%lx] = %lx\n",argc,argv[i]);
#endif
        ;
    }

    switch(argc)
    {
   case 0 : error = TRUE;  /* no objectinfopointer */
       return(error);
   case 1 : error = FALSE; /* no subroutines to execute */
       return(error);
   case 2 : count++;
       {
           struct Objectinfo ** oipp;
           int (**subp)();
           int (*sub)();

           oipp = *argv;
           subp = *(argv+1);
#ifdef PROCDEBUG
     printf("oipp = %lx; *oipp = %lx; **oipp = %lx\n",oipp,*oipp,**oipp);
     printf("subp = %lx; *subp = %lx; **subp = %lx\n",subp,*subp,**subp);
#endif

           /* transpose objectmatrix */

           sub = *(subp+TRANSPOSE);

           (*sub)( (*oipp)->objectmatrix);

           /* yaw objectmatrix */
           
           sub = *(subp+YAW);

           (*sub)( (*oipp)->objectmatrix, SINA, COSA);

           /* pitch objectmatrix */

           sub = *(subp+PITCH);

           (*sub)( (*oipp)->objectmatrix, -SINB, COSB);

           /* transpose objectmatrix */

           sub = *(subp+TRANSPOSE);

           (*sub)( (*oipp)->objectmatrix);
           
       }
       break; 
   default: break;
    }

    return(error);
}

