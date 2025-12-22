One day i looked in my oldest diskbox, and i found TechTech by
Sodan & Magician 42. But when i tested it, it didn't work so i started
to disassemble the loader to see why it didn't work. Here is why:

1. After a part has ended, they reset level 6 and level 7 interrupt
   to the addresses in ROM from kickstart 1.2. Bad!!!!

2. They loads their demo to absolut addresses. VERY bad!!!

I have now fixed both the irq and the place where they load (sections).
Code is now in Fast (Public) and gfx&sound is in Chip.

I hope everything should work now. The demo is only tested on a A4000/030
with 2Mb Chip & 4Mb Fast. If it doesnt work on another computer, contact me.

--
Johan Sassner     email: pt93js@pt.hk-r.se
Tranbarsv. 23:19
372 38 Ronneby
   Sweden

 0457-13378      Home: 0413-30155
