;/*
SC DATA=NEAR NOSTKCHK LINK NOICON CreaterTwist.c
quit
*/

#include <exec/types.h>
#include <stdio.h>

main()
{
  WORD width, deltastab;
  WORD delta,position;
  WORD takeoff;

  for(width=2; width<=320; width+=2)
    {
      printf("label_w%d:\n",width);
      delta=160; position=-1;
      takeoff=(320-width)/2;
      if((takeoff&15)==0)
        {
          if(takeoff)
            {
              if((takeoff/16)>1)
                {
                  printf(" adda.w #%d,a2\n",(((takeoff/16)-1)*2));
                }
              printf(" move.w d7,(a2)+\n");
            }
        }
      else
        {
          if(takeoff>15)
            {
              printf(" adda.w #%d,a2\n",((takeoff/16)*2));
            }
        }
      takeoff&=15;
      for(deltastab=0; deltastab<width; deltastab++)
        {
          while(delta>=0)
            {
              position++;
              delta-=width;
            }
          if(deltastab)
            {
              printf(" add.w  d7,d7\n");
            }
          printf(" or.b   %d(a3),d7\n",position);
          if((++takeoff)==16)
            {
              takeoff=0;
              printf(" move.w d7,(a2)+\n");
            }
          delta+=320;
        }
      if(takeoff)
        {
          if(takeoff<8)
            {
              printf(" lsl.w  #7,d7\n");
              takeoff+=7;
            }
          if(takeoff==15)
            {
              printf(" add.w  d7,d7\n");
            }
          else
            {
              printf(" lsl.w  #%d,d7\n",(16-takeoff));
            }
          printf(" move.w d7,(a2)\n");
        }
      else
        {
          printf(" move.w #0,(a2)\n");
        }
      printf(" rts\n");
    }
}