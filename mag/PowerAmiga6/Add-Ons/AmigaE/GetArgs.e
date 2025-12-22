/* Взятие аргументов с командной строки. Кстати, `arg' - предопределенная
E-переменная... */

PROC main()
  WriteF(IF arg[]=0 THEN 'No Args!\n' ELSE 'You wrote: \s\n',arg)
ENDPROC
