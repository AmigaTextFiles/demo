
 Again a spread of the public karate engine
 you can also upload on www.k-fighter.net

 This is spread Number 6 (01.09.2005) !!!
            www.k-fighter.net
                                         |_
                                 /_________|
                         ________\         |m4nkind _ _
                  _ _____\        \--      |¯¯¯¯¯¯¯¯///
 .::::    /|/¯¯:       |                            ¯ ¯¯|¯¯¯ ¯  :¯¯\|\    ::::.
 :: °\   / |/¯¯   _____  [ Karate Demo-Script Fighter ]          ¯¯\| \   /° ::
 `___'__/  /     /    /_____________________________________________\  \__`___'
 / .____8 /____ /    /__    \ ____    \ ____    \          / ______/ \ 8____. \
/ / :8/  / |: |/    /: |\.   \|: |\    \|: |\.   \___  ___/   __>___  \  \8: \ \
\ \/ /__/  |  /   _/|  |_\    \  |/   _/|  |_\    \ |  |  \.        \  \__\ \/ /
 \__/__/   |__\.   \|__| /    /__|\.   \|__| /    / |  |   \_\.     /   \__\__/
 //|   | ======\____/===/____/=====\____/===/____/==|  |======\____/=== |   |\\
 \\|   |            ___                             |                   |   |//
  ¯| : |    _______/  / ________    |  |__________________________      | : |¯
   |   |   / _____/\ / / ______/___ |  |         / ______/____    \     |   |
   |   |  /   __> |¯¯|/  \__  ||: |_|  |___  ___/   __>___|: |\    \    |   |
   |___|  \.   \  |  |\.   |  ||   _   |  |  |  \.        \  |/   _/    |___|
    | |    \.  /  |__| \____  ||  | |__|  |  |   \_\.     /__|\.   \_    | |
    `::' ===\_/============|__||  |=======|  |======\____/=====\____/== `::'
                               |             |
           _  __ _ ____|__                          _ __|____ _ __  _
                         /________/--      |________\\\
                                 /_________|bLa.2oo2¯ ¯
                                 \         |_
                                           |

 So this is version 1.2.

 YOU CAN spread. Works,suggestions and most of all BUGG REPORTS
 are welcome !!! krabob@free.fr

 Karate is a demo Script engine used to run demo on
 a lot of amiga, from 68030 aga with no FPU to
 68060 or UAE amiga with Cybergraphics. it uses
 simple text scripts to define the whole demo. it's xml-HTML
 like.
----------------------------------------------------------------------------------
---- Differences between spread 6 and spread5: ---


 In the pack:
    - k3d.Fx was extended and a new directory Tutorial_3D2 was created
        With tutorial 3D12 to 3D15, explaining new render functions
        like bump mapping and Lightwave3D scene reading.
        A bunch of nice things to see and many ways to improve
        your state of the art productions.

    - Tutorial C06_PlayScriptLink was added in Tutorial_C.
       It provides a way to do automatic chaining between parts.

 In the code:

    - new commandline parameter: "nmt" (no mouse test): mouse click
      will not quit the demo, only key "esc" will be able to quit.
      For interested people, Plugin interact.Fx had been added,
      but is not actually commented in a tutorial. It will be done
      in a future special interact plugin package. ( Use commandline "c"
      to ask for interact.Fx functions and parameters if you are curious).

    - The spline builtin functions (spl,splmod, and ktable) was again
      recoded to be able to apply 3D scene cinematics in a more powerful way.
      It implies that you should not mix the new K3D.Fx with an
      older Karate executable.


---- Differences between spread 5 and spread4 (07 2004): ---

 In the pack:
    - added <imgempty> image constructor and <auxrect> rectangle constructor.
      It provides a way to do 'Texture Rendering', and a lot of other tricks.
      Karate's capacities to do strange effect are multiplied by 100 !!! (at least.)
      it's in tutorial D04.

    - added some more effect in k3d.fx , it is explained in tutorial
      3D09 , 3D10 , 3D11

 In the code:
    -  Corrected a bug on the texture mapping that was not
      doing well when UV mapping was more than 128 pixel wide on a triangle.

    - in the 3D: In some rectangle conditions, it wasn't possible to change the fov
      focale length AND the rectangle. Corrected.

    - put some useless muls.l dx,dy:dz asm instruction to garbage,
      and did some optimisations.. let me say it: AMIGA is back !
      yes,and k3d.Fx is faster.

    - The whole plugin interface has been recoded: now ".Fx" plugins
      are no more shared libraries but real code chunks. Karate could
      crash if differents version where run one after the others.
      this will be no more the case starting with this version.
      devkit for plugins is done and downloadable on the website.

---- Differences between spread 4(20/03/2004) and spread3: ---

 In the pack:
    - the k3d.Fx first version has been added, providing a full
       3D engine with many features !
       A complete directory for 3D tutorials was also added.

    - parameter BounceOn added, it's like bounce but it bounces on and on.

 In the code:
    - The angles passed to SetCamCoord and some stuffs had changed:
      Consider now 1.0 = Pi = 180°. It means you will have
      to make minor modifications to your previous scripts.
      I swear it will never change again :-).

    - minor corrections. text parser has partially been rewritten and
      now use less memory. A bug was found in dbm.fx, and it seems ok now.

    - The plugins interface has changed: it means you can't mix
     old .Fx with new karate and vice versa. If you launch an old karate
     demo, then a new karate version just after, use command 'avail flush'
     between, to avoid old '.library' persistence.
     BUT NOW CONSIDER IT IS FINAL. Whole Karate Source code and a plugin
     devkit may be released in the coming month.


---- Differences between spread 3(05 2003) and spread 2: ----

In the pack:

    - karate68k now works on morphos systems.
      Note that the example using sound will not work in the
      corresponding drivers does not. (need AHI and dbplayer.library
      for digibooster,and p61 module hit paula directly.)

    - about possible screen errors at opening:
      if you use a TFT screen and have some screen mode available
      that wouldn't display on such screens, be aware karate can choose
      one of these modes when parameters w=width and h=height are used.
      if these happen, change the asked resolution to one that fit your screen,
      or try to disable the undisplayable modes in your video
      driver configuration, or more simply, don't use w= and h=,
      then a ASL screen mode requester will open it.

    - if you use a Picasso system, karate was reported to work perfectly.
      Nevertheless the CGX emulation seems to not find some mode requested.
      if this happens, erase w=width and h=height in the command lines,
      an ASL screen mode requester will open so you can choose a
      8bit screen mode by yourself.(then asl shouldn't provide something
      else than 8bit picasso modes, but sadly it does.)

    - New sprite image animation features, and image stoping and blitting
      features was added too.

    - MultiZoom and MultizoomLight effect has been commented.

    - MapRect effect has been commented.
      It provides a simple 256x256 image deformation effect.

    - as almost noone understood the colortable image color-remap trick,
      a new constructor for it, <computecolortable> has been implemented, using a
      image label as input palette ONLY to compute the color table.
      the result will be the same, no more need to "remap" a 24 bit image.
      but it takes a lot more cpu when starting:
        <computecolortable> tablelabel | imagelabel |0|255|255|255
        </computecolortable>

      BE WARNED: colortable are necessary for ALL color operation
      like motion blur, radial blur, but also spritetable or spritelight.
      and IF YOU USE DIFFERENT PALETTES, YOU MUST DO DIFFERENT COLORTABLE.

In the codes:

    - aft, aftmod, spl and splmod table parameters have been
      recoded in asm, using no fpu libs floats anymore, and are buggless.
      B05_TableParam tutorial has been finished to show splines differences
      with aft.

    - sprites ( all fx ) have been recoded faster and if sprite image have
      256 pixel width, a special optimisation avoid multiplication-by-line.
      this is far faster for displaytext effects.

    - enormous optimisations have been done on deformation fx (twirl, warper),
      now far more usable on 68030 amigas.

    - some silly bugs removed.

---- Difference between spread 2(28.09.2002) and spread 1(june): ----

In the pack:

    - the <INCLUDE> exemple/tutorial has been written (C04 + C04b)

    - the ground <fx> ( D01 ) and tunnel <fx> ( D02 ) exemple+tutorial: DONE.

    - powerful ( D03 ) exemple of combination with camera

    - the boot startup script ( C05 ): exemple and tutorial done.

In the codes:

    - currently support the undocumented "strange interactivity" commands.
        more about this in a special pack.

    - added builtin fx: "SetCamTarget", some kind of "SetCamCoord" (D03).

Bugs corrected:

    - dbplayer.library from aminet was not included in previous package !!!
        you must have it in libs: to use dbm musics.
        if the use of DBM musics crash your amiga, try to select a less
        strange AHI default mode.

----------------------------------------------------------------------------------
 DOCUMENTATION:

 It is as "open" as possible: you can add effects (and object types
 used by these effects) in plugins modules (in fact shared libs in directory Fx)
 And the whole sources will be spread for any use.
 (more effects will come in the future.)


 Here are a serie a Tutorial to learn the language, which is
 a very convenient language.
 You can execute each script as a demo or look what's inside for learning.


 To explain a bit:
 the text langage describe the data used in the demo, using tags:

 <KIMG> imagelabel | path/image.iff  </KIMG>

 ie: this will build an image usable by effects....

 then it defines the parts of the demos (<KPART>...</KPART>) , which contain a serial of
 effects (<Fx>...</fx>) that are put on the screen in the order they were writen in the part,
 like "layers".
 then the parts are mounted in the desired order with a <KSCRIPT>...</KSCRIPT>
 and a KScript can stand for the script of the whole demo.
 everything is non-case-sensitive.
 The great thing with karate is that if an error occur in anywhere in the script,
 you get a very clear error message, giving you the line, the faulty text file,
  and the reason why it failed, so you will never stay on an error a long time with karate.


 Anyway, here is a serial of tutorial to help you learn the karate, and
 discover how powerful it is. There are only a few effects available at this time,
 but you will be astonished to see all you can do with a few things.
 As effects stands in Plugins in the directory Fx, no doubt karate will soon
 be able to manage any effects, and more !!!

 Open the first Tutorial directory, You have 2 icons for each exemple:
 one launch the demonstration with a simple shell script that execute a command like:

 Karate s=TutorialA/A01_MinimalExample.txt w=320 h=240

 it's a way to launch karate with a script. note it's possible to choose any resolution.
 the second icon open the script text in multiview.

  By the way , what are the options of karate ?

  w=320         set the resolution to play this demo. (width, height)
  h=240
  s=script.txt  the script yo play
  c             just type Karate c and you will get the whole configuration check.
                this is usefull to know the list of all effects available,
                it also prints the parameter list asked by each effects.

  b=bootscript.txt (not needed) see high level tutorial to use this !!

--------------------------------------------------------------------

 note for coders: You have noticed i use amigaos datatypes to read images.
    it is possible since you open the object, do a "proclayout" and
    get the bitmap generated with a readpixelarray8...

    I have much more trouble with animation.datatypes : I tried a long
    time to do the same thing, and it only works for the 1st image (frame).
    I can't manage make the image change to the other frames !!!
    maybe anim DT don't want to change frame unless the object has been
    "attached" (I can be wrong) note I have v44.
    If someone can help, -> krabob@free.fr
      I would be glad having these sprites moving with "animbrushes" :-)

 --------------------------------------------------------------

 Francophone people:

 Voilà le pack béta de karate.
 je prepare une série de tutoriaux (une 40aine de script au final)
 ya 2 icones pour chacun: 1 lance la demo, l'autre affiche le script
qui lui correspond.




