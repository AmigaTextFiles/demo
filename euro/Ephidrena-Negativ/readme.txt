Negativ Prosess by Ephidrena

Amiga Aga 060 demo 

Note: Requires about 1,8mb of chipram, boot from
cli before starting the demo to avoid issues.

Cheetah got the idea for the new music format (volume x 8-bit)
Loaderror coded and did some graphics  
Frequent did the music  


Frequent speaking:

The tune was made last year as a part of a mini album.
Original version is more than five minutes long and had
to be shortened and rearranged. The new sound player
by Loaderror with 8 bit noise reduced next to nothing,
makes it a bit ironical to use such a glitchy track 
but at least the glitch and noise are as clear as intended.

In short: IDM/House with 5/4 pace, constructed with
Propellerhead Reason rewired to Ableton Live. Rendered
in 96Khz/24 bit resolution and antialiased down to 16 bit
before converted to the custom format. 



Tech rant:

A custom 8-bit + Amiga channel volume modulation player
which reduces noise considerably compared to standard
8-bit. It also doesn't lose any volume which is the 
problem with the usual 14-bit audio modes.
Not sure how many bits we can say it is?
We'd like to say it is 11-bit which is just like vinyl. 

Several bitplane modulo effects for stretching the screen
in various ways. The noise effect is also implemented
using bitplane modulos to select different lines of noise
per scanline.

Hires table ball using "non square texels" and vertical 
stretch. Although it is color cycling, I'd like to think 
that the color cycling is less obvious this time because
of the "non square texels".

The Neon-Copperbars are back again.
Now with 3d engine like flexibility so one can 
create copper bar objects and scenes. In the end
the scenes turned out rather simple. Maybe more later.

Aga sub-pixel scroll with weird bugs that make it look
different on Amiga and UAE. Ended scrolling pretty fast
so the subpixel stuff doesn't show. Will fix in final.

"Curl noise" dots. A bit like in an earlier ephidrena
demo, but now less lazy by being realtime and in planar mode. 
There is double buffered dirty tracking of star positions 
to write as little as possible to the dreadfully slow chip ram.
One thing I like about this routine is that culling against 
two sides of the screen can be done with one comparison if 
treating the coordinates as unsigned. Maybe it is standard
for all other amiga coders :) 

As usual most ideas didn't get in because when coding you
spend your time getting cross eyed over a few nemesis bugs
that pop up during the course of the demo creation.

Stuff you can't see which got implemented:

24-bit to ham8 converter in the demo.

Ham8 VHS distort which was pretty cool, but no time
to make good graphics for it.
  
Object loader for .obj files. I don't have Lightwave anymore
so needed to load something from Blender. However no 
objects to show. Maybe because of using Blender?

pgm format picture loader.


