********************************************************

	JABBERWOCKY TEXTURE MAPPER

********************************************************



NO WARRANTIES ARE TAKEN FOR ANYTHING!


Welcome to another texture mapping demo.

The executables are texmap and texmap020. Feel free to copy
this package, but you may only copy it in the complete package
and without any profit.
The textures must be in directory tex which has to be in the same dir
as texmap.


What is special about this demo?
--------------------------------
I managed to include a ground, transparent and scrolling walls and
soft camera movement. Heavy stuff enough, but please notice that
perspective is correctly taken into account while mapping the walls.
Many demos just scale in x direction but at large walls you will
see that it doesn't work properly. But, out of this all, this piece
of code is booooring slow. I have to apologize. But see chapter
future works. I hope you have an 040 and enjoy this litte program. :-)



Moving
------

Cursor up:       move forward
Cursor down:     move backward
Cursor right:    turn right
Cursor left:     turn left

Left Alt+
   Cursor right  move right
   Cursor left   move left

Left Shift + cursor keys speed up

ESC              leave program

F1 - F9          scale window ( f1: 64 x 32    f9: 320 x 160)



System requirements:
-------------------

Processor: all, 68030+ recommended
FPU:	   none
Memory:    512 KB
This program needs the math.library.


Future works
------------

I came to a point with this engine where I can't speed it up
anymore. So I decided to put this demo out and rewrite the
complete engine. If you notice by the memory usage, this
program does use NO precalculated tables. The next one will
and it will use about 1.5 MB RAM therefore ;). This package has
no floating point calculations in kernel and it doesn't use 
math coprocessor. The same does the next. (I developed this
no_floating_point version from the beginnign). This results in
ugly processor divisions und multiplications. That is one of
the causes for the slowness.

I will now work together with some other amiga 'freaks'. We
intend to build a special copper version to get the A1200
flying ;) And, if possible, we try to take ALL advantages
we can take from a given configuration.

The source code is written in C and coding it in assembler
might speed it up about 30%-40% I think.

I will insist on a bitmap orientated Program like this demo is,
because on 030 and more you get simply more details at a con-
siderable speed. Maybe, I write special versions for graphic
cards (long live EGS :) but first I have to optimize the code
(the chunky 2 planar conversion needs just about 20% of the
total rendering time per frame) and then we can take advantage
of chunky graphic cards. Not to forget to write a game ;-)

... happy mapping!


Oliver Groth            =:-)
Lilienthalstr. 115   
85077 Manching          Tel.: ++49 (0) 8459 / 30034
Germany			E-mail: c9077@rrzc1.rz.uni-regensburg.de

****************************************************************  
