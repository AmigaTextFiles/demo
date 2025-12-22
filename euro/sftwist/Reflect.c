;/*
SC DATA=NEAR NOSTKCHK LINK NOICON Reflect.c
quit
*/

#include <exec/types.h>
#include <stdio.h>

main()
{
  UWORD loop1,loop2,value1,value2;

  for(loop1=0;loop1!=256;loop1++)
    {
      value1=loop1; value2=0;
      for(loop2=0;loop2!=8;loop2++)
        {
          value2=(value2*2)+(value1&1);
          value1/=2;
        }
      printf("%d,",value2);
    }
}