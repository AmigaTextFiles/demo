+-----------------------------------+
|                                   |
|            *Knarkzilla*           |
|                                   |
|                 by                |
|                                   |
|             Ephidrena             |
|        Loonies Focus Design       |
|             Kvasigen              |
|                                   |
|                At                 |
|                                   |
|          Revision 2019            |
|                                   |
| Code      Loaderror / Ephidrena   |
| Graphics  Farfar    / Loonies,FD  |
| Music     Eladamri  / Kvasigen    |
|                                   |
| QA        Frequent  / Ephidrena   |
| C2P       Kalms     / Tbl         |
| LUT-tool  Booster   / Loonies,FD  |
|                                   |
| Images in the intro borrowed from |
| Amis Cope by Satori. Go watch it! |
|                                   |
| #dinosaurz #tunnelz #electro #303 |
| #lazerz #nukez #astronaut #plasma |
+-----------------------------------+

Requires about 1,5mb of chipram. Boot 
from cli before starting the demo to 
avoid issues.

Greetings:
Adapt, ADA, Boozombies, Carl. B, 
Cocoon, Darklite, Desire, Dekadence, 
DHS, Dreamweb, Elude, Excess, Extream,
Focus Design, Fuse, Ghosttown, Haujobb, 
Gwem, Hoaxers, Kewlers, Lemon, Loonies, 
Mankind, Mawi, Mystic Bytes, Nature, 
Ninjadev, Ozone, Potion, Pacific, Paraguay, 
Playpsyco, Portal Process, RNO, Satori, 
Scarab, Scoopex, Software Failure, Spaceballs, 
Spookysys, The Black Lotus, Traktor, 
Tulou, Unique and forgotten.

Some words about the effects:

Perhaps the most interesting effects 
here is the per scanline color 
cycling and the angle based normal 
maps.

The color cycling makes use of 
per-line copper changes so that some 
of the luts have a few thousand color 
indices to cycle through as opposed
to just 256 which would be standard
color cycling. All the LUTs except 
the face is implemented using this 
technique. 

To create the LUTs a vector-quantizer 
was made. That reduces a truecolor 
LUT to a reduced LUT much in the same 
fashion as reducing an image from 
24-bit to 256 colors.

(However with a lot of code to
eliminate horizontal artefacts and
other nuisances that happen when
changing colors in each scanline.)

This was a complicated effect that in 
the end doesn't look that good 
compared to just having a chunky 
256-color lut effect, however it 
is fast, resolution independent
and true color capable. I believe it 
can be improved further in the future

Another interesting technique is the 
angle based normal maps used for the 
monster objects. This technique was 
invented by El Sondro/Ephidrena who 
is supposed to do be doing graphics.

Many of you are probably aware of 
normalmaps from games. This effect
made its breakthrough in Doom 3.

However the traditional normalmaps
are relatively expensive requiring
a dot product per pixel to get some
lame lighting. The angle based
normalmaps require 2 lookups in the 
polyfiller and you can have an
env as the texture for a more 
interesting look. 

If you want to find out how these
work in more detail come visit me
in Shanghai and buy me a beer.
