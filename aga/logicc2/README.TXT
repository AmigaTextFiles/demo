LOGIC README
============


--- INSTALLING THE DEMO

Depack archives on the two disks into the same directory, which will be
the "demo directory" referred to later on.  Because the names must comply
to ISO-9660 standard (essentially, PC filenames), you must rename the
file "MUTANTTI.LIB" into "mutantti.library" -- and remember to put it all
lower case!

Example session:

  1>  cd demos:
  1>  makedir LOGIC
  1>  cd LOGIC
  1>  lha x df0:logic1
    [swap the disk]
  1>  lha x df0:logic2
  1>  rename MUTANTTI.LIB mutantti.library



--- RUNNING THE DEMO

To run LOGIC, you need the following things:

    *	2 megs CHIP is the minimum to run the demo but routines will
        work much fast with fastmem.

    *	Run the demo by executing "RUNLOGIC".  The script will make
        sure proper caches are enabled etc..  The script will make
        two assigns;  "LOGIC:" into the demo directory and an "Assign
        ADD" for "LIBS:" also to the demo directory.  (Remember to
        be in the directory when executing the script).

                1> Execute RUNLOGIC

    *   NOTE:  Make sure the VBR is set to _zero_.  Easiest way is to
        use a clean boot (IF your VBR is not normally zero).  Do this
        by booting without startup-sequence.


--- RUNNING LOGIC WITH ONLY 2 MEGS CHIP

Change "LOGIC.EXE" into "LOGICLOW.EXE" from the script (RUNLOGIC).  The
demo will not have any sounds in this version.


--- COPYRIGHTS

This production (and screenshots etc) are freely distributable but may
not be used as part of a commercial product (for example a music video)
without a written permission from the authors.

Exclusive CD distribution rights to Assembly '95 organizers.


--- NOTES

"mutantti.library" is a groce modification of "assassin.library" which was
shamelessly adapted for this demo, and this demo only.  Therefore, you will
_not_ find any further usage for the library.  Best way is to keep it in
the demo directory and use "Assign LIBS: "" ADD" to make it accessible.

"assassin.library" itself has been developed further and we will probably
release it later on.

The demo was finished in a BIG hurry, due to which it is rather strict
about the requirements.  If you have missed out something, it will most
probably either crash or flash some funny colors in a forever loop.
Running out of memory will also be revenged :).


--- CONTACT INFO


Flame:

	flame@stekt.oulu.fi
	tel:  +358 40 540 8354

Silver Eagle:

        silvere@freenet.hut.fi


---------------
Pygmy Projects.
---------------
