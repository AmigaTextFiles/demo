
                                (` [] |` {'
                                productions

                             F R O S T B Y T E
                              at midwinter 99

   PREFACE..............................................................

     Finally, Core Productions winning contribution at the Midwinter `99
     democompetition. The promised unfinished part did unfortunately not
     make it due to heavy load from university studies. Too bad, because
     motioncaptured data looks very cool :-)  The demo is in other words
     exactly as shown in the compo.

   INSTALL..............................................................

     Unpack to a directory of your choice, where a "frostbyte"-directory
     will be created:
       FROSTBYTE/
         DATA/              - data for demo
         SHOULD_BE_IN_LIBS/ - xpkmaster.library and sublib, put in LIBS:
         FROSTBYTE.EXE      - change dir to here (PROGDIR:) and run this

     The demo will need _two_ timers!! Close any program using any timer
     (like executive) before running Frostbyte. Xpkmaster is also needed
     and an (old) version is included. AGA is not needed, thanks to RTG.
     To use RTG functionality, rtgmaster.library must be installed (not
     included). About 5Mbyte of memory and a 020 is required minimum.

     Tested on  A1200/030'50 AGA
                A4000/040'33+604'180 Permedia2
                A4000/060'50 AGA
                UAE/020'25 TNT

   COMMANDLINE..........................................................

     Available commandlineparameters are listed here. There are two main
     modes: custom-AGA and RTG. Even though RTG also supports AGA, it is
     a different mode from the built-in custom-AGA. Built-in AGA is also
     faster in most cases. RTG could atleast in theory work in ECS-mode,
     but it would be pretty useless.

     > Default is AGA mode and PAL screen.
     > If you own a graphicscard, do not forget to give the "RTG" swith!

        RTG-Mode:             RTG

        Custom AGA-Screen:    NTSC | MULTISCAN | MULTISCAN2

        RTG-Compatibility:    MODFIX

     MODFIX corrects a problem with AGA under RTG. Very few c2p-modules
     in rtgmaster.library support different modulos of source and
     destination buffer so modfix fixes that, but at a lower framerate.

     Only synchronous c2p-modules work (usually CPU-only c2p). A rather
     good one is "cpu040" (works on 020/030 as well, but may change in
     newer versions of rtgmaster).

     If running the demo in a Workbench-window, you must also use MODFIX
     and only 8bits screens are allowed (rtgmaster should take care of
     that, but it doesn't, maybe in the future).

     When using rtgmaster, remember that holding down shift-key will
     bring up the rtg-screenmode requester if you once saved a setting.

     All in all, rtgmaster is pretty cool since the exact same code is
     used for aga-display and rtg-display. Easy to program for both!
     Just call CopyRtgBlit() and graphics will be shown on ECS, AGA,
     Cybervision, Permedia2, TNT... etc. depending on what hardware the
     user has got.

   CREDITS..............................................................

     All coding, graphics and design by Andreas 'Icon' Lindquist and
     Lennart 'Houbba' Marklund. Music by Torbjörn 'Megaodi' Enqvist.
     The Player6.1a by Sahara Surfers and others.

      Core Productions    -    cp@acc.umu.se    -    www.acc.umu.se/~cp

                           . o O  © o ® e  O o .
