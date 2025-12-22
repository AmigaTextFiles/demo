
                          _______ _   _     _
_    _ _¸..¸ _ _____     |                                    ::  .
    ,æ½÷×¤¤¤×ðæ,    |    |__ _  _             ..|¸¸¸,  .      ::    .    .
  ,ß¤'        `¤ð   |               .::::::::::::¼ð¥          ::  .   :
 ¡Ð´           ¸ß ¥¤···.       __ .::::::::::::::½° %¾ ·   :: ::  . : .. :
Æß'  _   _·..æ¤°____|   :     |  (¿¡&:       ···:!  ¼½ :   :: ::  : .:··:.
::                 .... :     |   ¤ð§::..       |·  %¼ ¡   :: ::  .::.  .:
·:       ________.:____::  .:::%#æ,  |::::..    |   ¾½ |   :·_::__:. ··:·
 ::     |       ,ß¼    £: ::  |___¥__| ···:::::.!¸  ¢¼ |  |½ð ØÇ   ¤¼,
  ::..  |   ¸¸, `ð%æ,,x©: ::      : ..    . ···::#ð, ¤®::::¤  Ð§
   ··::::ßð¢¤´    `°¤°'~| ::·:::::·.:::.... ..  .ß®Ð___|··|   ½¼¾¾¼½¾¾¼¼%
        |               | ::      :::::::::::::::::·      |________ __ _   _
        .               ! ::    .:::::::::······
                        · ::
                        . ::
                          ::



   Hello there! First of all: thanks to scout for his merge-op,thanks
to Jarno for the player. You make my life easier... 

   And advise!!! Are you coding on Mac (especially through Shapeshifter)?
We (Peskanov/Zaborra/Capsule and Opps!/Capsule) are coding a 3d game
for Amiga and Mac. 
If you are interested in exchange knowledge/tools for Mac, please e-mail
us to:   

          malemana@nexo.es  
 
   Now, what about some coding-talking?
As I said, Quicktro is a fast work using my 3D routines for an 
Amiga/McIntosh game. Yeah! Using 3d-game-routines for demomaking is sooooo 
lame!! But at least I tried to add some still unseen ideas . 
   A quick review:

 - The intro. This is a noise generator, made with a modified blur and
   the help of a side effect from the C2P. Any bitmap will be dissolved 
   into white noise in some frames. The letters are texure mapped vectors.
   Also, I included a palette degradation along the Y axis, afecting 
   all 16 colors.
 
 - The tunnel. the screen is a Ham-6 hires screen, but is 1x1. I take
   the red-green colors from pair pixels and the red-blue colors from
   odd pixels. That is: r1g1r1b1 - r2g2r2b2 - ....  becomes r1g1r2b2.
   This generates color alias, but if you see the demo on composite
   output, a lot of alias dissapears.
   An oddity: the C64 fanatic has 668 polygons. Strange eh? We thinked 
   in taking out two of them!
   No more to say, except: C64 WILL LIVE FOREVER. AND AMIGA TOO.
   
 - The Space station. I put this scene asked by my friends. I tried to 
   make this more interesting adding 40 cubes. The space station comes
   from an object collection. It consist of 2242 triangles. The cubes
   have 480 triangles (I only work with triangles).
   The screen is Ham-6, SuperHires. This is true 1x1. The C2P takes a 
   minimum of 1.5 frames for 56320 pixels(352x160,overscan rules!),
   on 030 no blitter.
   The galleon is an object from imagine. 4489 triangles, with environment
   mapping. Looks so slow, that nobody likes it! But well, if you are 
   coding a 3d-engine, you have something to improve.
 
 - And the torus line. I expect you like this one, because it was a hard
   work to do! The screen is Ham 8 - true 1x1. The C2P takes about 1.5
   frames for 44000(352x125) on 030 no blitter; but it has some restrictions.
   I have had to do an ugly trick to avoid the extreme DMA restriction.
   On blizzard 1240 and blizzard 1260 the C2P is slower. Don't ask me, ask
   phase 5 about the shitty chip memory acces on these boards... If you 
   are coding routines which are critical about chip memory access on 030,
   try them on these blizzards, you can find problems. On Cyberstorm 
   series it's ok.
   

And that's all! I expect you enjoyed my codework! (maybe you will enjoy  
if you run it on 040 or 060, as was intended).
I will try to do some original effects for the forthcoming capsule demo,
phase one (at least more original than those ones).

 



                                          Peskanov / Capsule 1997


