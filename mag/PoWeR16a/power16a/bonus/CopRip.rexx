
/* Copper Ripper */

OPTIONS RESULTS
parse arg filename
tab='09'x

if filename = "" then filename = 'ram:copper.s'
address command "copdis >ram:tempfile_copper"

/*---------------------------*/

open('file1','ram:tempfile_copper','R')
open('file2',filename,'W')
   do until eof('file1')
      line=readln('file1')
      if left(line,1)~='$' then line=";"||tab||line
      else
         do
            parse var line . . l.1 l.2 . l.3
            line=tab||'dc.w'||tab||l.1||','||l.2 ';'||l.3
         end
/*      say line */
      writeln('file2',line)
   end
close('file2')
close('file1')

address command 'c:delete >nil: ram:tempfile_copper'
exit

/*---------------------------*/