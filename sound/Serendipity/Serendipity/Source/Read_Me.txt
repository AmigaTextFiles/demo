Serendipity Source Code
-----------------------

Serendipity was created using Devpac 3.04, and you should be able
to compile it yourself extremely easily if you are using the same software.

If you are using another assembler you may need to fiddle around a bit. I haven't
used anything like PhxAss myself, so I'm afraid I can't offer any assistance.

The files:

    Serendipity.s     -     Main source code.

    Bitmaps/          -     The bitmaps which are loaded in at compile time.

    IFF_Pics/         -     These are not required for compilation. These are
                            simply the IFF pictures before they were converted
                            into Bitmaps.

    GenAm.opts        -     The Devpac options file that I used for compilation.

    powerpacker_lib.i
    ppbase.i          -     Includes that handle Powerpacker unpacking of modules.


Note: The music modules are loaded at run-time from PROGDIR:. So make sure that
you place your generated executable in the same directory as the music modules.

 (of course, feel free to alter the paths used if you desire)

This source code is freely distributable, as long as no modifications are made to it
in any way. Please do not use any of it in your own releases without asking us first.

(c) Copyright 1994, 1998 Tristan Greaves.

E-mail: tmg296@ecs.soton.ac.uk
