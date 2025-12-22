/* CAMG Chunk of an ILBM file: Reset bit 0x1000 if necessary */
/* call trace */
say " "
say "Please enter filename:"
fname=readln(stdin)
x=open('ein',fname,'r')
if x ~= "1" then do; say "File not found"; exit 10; end
b4=readch('ein',4)
say b4
if b4 ~= "FORM" then do; say "No IFF"; close 'ein'; exit 10; end
b4=readch('ein',4)
b4=readch('ein',4); say b4
if b4 ~= "ILBM" then do; say "No ILBM file"; close 'ein'; exit 10; end
fertig=1; p=12; aend=0
do while fertig=1
  ch=readch('ein',4); ll=c2d(readch('ein',4))
  p=p+8+ll; say ch || " Chunk"
  if ch=="CAMG" then
    do
    if ll~=4 then do; say "CAMG chunk length not 4:" ll; close 'ein'; exit 10; end
    c1=readch('ein',1)
    c2=readch('ein',1)
    c3=readch('ein',1)
    c4=readch('ein',1)
    b3=bittst(c3,4); if b3~=0 then aend=1
    fertig=0
    end
                else
    do
    call seek 'ein',ll,'CURRENT'
    end
  if ch = "BODY" then fertig=0
  end
close 'ein'
say " "
if aend~=0 then
  do
  say "Bit reset is necessary"
  x=open('ein',fname,'w')
  p=p-2; call seek('ein',p,'BEGIN')
  c3=bitchg(c3,4)
  writech('ein',c3)
  close 'ein'
  say "Change executed"
  end
           else
  say "No change necessary"
exit

