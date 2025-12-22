
Welcome to "AnimTRAC!" v1.0a, (c)opyright 1997 Martin Edwards.
-----------------------------------------------------------------------------
(In the red corner, animations of one resolution/bitplanes/palette.
 In the blue corner..)


Token legal jargon..
-----------------------------------------------------------------------------
"AnimTRAC"   is Public Domain..
"AnimTRACsc" is NOT Public Domain (script-compiler)..
"CBF"        is Public Domain..
"RBF"        is Public Domain..


Instead of the usual documentation/readme, Dash will be asking dip-s**t
questions to get the reader/potential-user interested..

Fire away, Dash!

- Okaz, what is AnimTRAC!?

  Super effort that!
  The true genius that you are will register that in your head as
                                                Animation Tracker..

- Too right, what's a Tracker?

  Another word for sequencer, as in a music making program like OctaMED(tm)..

- So why not call it SuperHyperSpecialEditionTurboAlphaZero&FriendsTracker?

  Because AnimTRAC! looks better, besides i'd hate to get on the wrong side
  of those Capcom boyz.. sheesh..

- Okay then, why does Amiga need another Animation Sequencer then, surely
  there's plenty already out there?

  Well there's jack s**t really, and they're all bollocks..

- Erm, yeah.. So why is AnimTRAC the new standard in no-frills
  Animation Sequencing?

  Well put..

- Ouw shucks..

  For a start it's just bloody marvellous..
  Everything's double-buffered,
  frames can be of any resolution and up to 8-bitplanes on AGA,
  smooth fade'ins and outs and all a'bouts,
  multi-directional scrolling on big-overscan frames,
  plays ProTrackers and/or samples in any channel at any pitch,..

- Cor! Anymore and i'll explode all over your keyboard..

  I'll give you a 5-minute breather..

  (5-mins later)
 
- But wait! There's more?

  Multiple palette's,
  edit frames in numerous ways,
  frames are loaded to fastmem unless specified,
  optional-instant viewing of frames in chipmem,
  and most of all, a piss-easy syntax.. (and it's just version 1.0)

- Any free steak-knives then?

  HELL NO! I want you to be the next budding Eric-Schwartzy animator,
  not some crazy steak-knife-throwing-freak(tm). 
  
- Sorry. So how does the Dash go about using this thing then?

  Your an ascii-character Dash, you can't use anything..
  Anyway, there's no memory wasting cluttered gui to get in your way..
  All you need is your CEd equivalent text-editor and start typing..

- But i have no fingers..

  Well pull them out of your a**e!

- Say theoretically, the great Dash whisks up this great super-stonking
  animation/demo but everyone reads my script and just changes the
  filenames and mess it all up and shake it all about and, and..?
  That would really piss me off! or something.. er..

  No worries! Just send me all your money and i'll send you back your very
  own registered-copy of the "AnimTRAC script-compiler" which will convert
  your ascii-scripts into binary-scripts, for which some reason are much
  smaller (must be missing some vital bytes?). Plus you get a say in what's
  to be added/improved in future versions..

- What can possibly be improved? It sounds great as it is..
  Okay then, what if i'm watching someone's animation and it's really bad
  and i don't want to torture my shameless eyes anymore, or just want to
  prematurely-eject or something?

  Just hold Escape and when it can it'll free-up.. As for improvements,
  i wanted it to use datatypes so you could load gifs/pings etc but
  didn't understand the datatypes.library.. Couldn't use DataConvert (as
  found on the DataChrome(tm) disk) because it forgets to release half of
  it's allocated memory (chip, why oh why does it have to use chip). Damn
  gobble guts. DataChrome(tm)'s commercial right, well so it is but the file
  DataConvert has no copyrights in it unlike the DataChrome executable..

- This package sounds like it needs commentating from Graham Hughes or
  someone.. Anyway, now's about the time you scare everyone away by
  announcing it requires the amos.library?

  HELL!! NO WAY!! NOT ON YOUR NELLY!! It was written in the legendary
  Blitz Basic 2.1 (which i got for free somehow). No really, but all
  the vital-speed stuff is hand-coded (not #!&%-coded) in pure assembler..
  I luv 680x0 assembler by the way (intel's instruction set smells).. 
  Also everything is in amiga mode, and very amiga friendly (i would never
  stab amiga in the back! NOT!).

- Phew! I just hope he didn't quit reading before you could set me right..

  Well he's gone now so let's call him a dumb loser, pig-faced lump of s**t!

- Ha! Ha! Ha!

  Ho! Ho! Ho!

> Oakily doakily neighbour, howdily doodily todalily?

  NOOOOOOoooooo......!!


And now it's time for something completely different(tm).


The AnimTRAC! syntax/descriptions.. (oh joy!)
-----------------------------------------------------------------------------


loadframe frame#,"filename$"[,palette#][,chip]
---------
Loads ILBM to frame in fastmem unless you type ,chip at the end. Optional to
load it's palette..

loadbuffer frame#,"filename$"[,palette#}
----------
Loads ILBM directly to back-buffer. Loading of it's palette is optional..

loadshape shape#,"filename$"[,palette#]
---------
Loads ILBM as a shape, and it's palette if specified.. 

loadsample sample#,"filename$"
----------
Loads 8SVX sample..

loadmodule module#,"filename$"
----------
Loads ProTracker module..

loadpalette palette#,"filename$"
-----------
Loads palette..

freeframe frame#
---------
Suprisingly removes frame from memory..

freeshape shape#
---------

freesample sample#
----------

freemodule module#
----------

freepalette palette#
-----------

showframe frame#[,palette#][,chip]
---------
Copys frame to back-buffer and shows with an optional palette. If you know
the frames in chipmem you can add ,chip at the end to display it directly
from where it is instantly as the front-buffer. Be careful though because if
you do a showbuffer it will become the back-buffer and any editing will be
directed to it, forever.. (ouh hu ha)

useframe #frame
--------
Copys frame to back-buffer for use..

copyframe frame#[,chip]
---------
Copys front-buffer to specified frame.. If the frame already exists it will
be overwritten.. An optional ,chip will put it in chipmem..

showbuffer [palette#]
----------
Swaps buffers showing whatever was on the back-buffer..

doublebuffer
------------
Copys front-buffer to back-buffer..

copybuffer #frame[,chip]
----------
Same as copyframe only it copys the back-buffer instead..

drawshape #shape,xpos,ypos
---------
Draws shape on back-buffer at specified x/y coordinates..

cutshape #shape,xpos,ypos,width,height
--------
Copys specified area from back-buffer to a shape..

playsample #sample,channel[,period]
----------
Plays sample through specified channel at samples pre-set period/pitch, or
can optionally play at a different pitch..

playmodule #module
----------
Starts playing specified module..

stopmodule
----------
Stops current module from playing..

maskmodule 0-15 (%4321)
----------
When you first playmodule all channels are owned by the ProTracker player.
Any samples played will be distorted because of ProTracker hogging all the
channels. To mix a module/samples effectively you'll have to tell the
ProTracker routine to leave the channels you want to use alone. Default
mask value is 15 (%1111) which gives PT all channels. To use channels 3 and 4
for samples you will have to mask them out with a value of 3 (%0011),
%1 owned by PT..

setoffset offset
---------
Sets the brightness-offset between -255 and 255, 0 being standard..

fadeoffset offset,spd
----------
Fade offset from current to specified at what rate i.e. 1 being the slowest
and 16 being the fastest..

scrollscreen xinc,yinc,loops[,delay]
------------
Scrolls screen at how many x/y pixels a frame and how many times, 
0 does once, 1 twice etc. Also to really slow speed down add an optional
delay that takes place between each increment..

vwait [#vwaits]
-----
Stop script for how many frames/verticle-blanks. showframe and showbuffer
automatically do a vwait..

wait [#seconds]
----
Stop script for how many seconds..

leftmouse
---------
Waits until leftmouse button has been held and released before continuing..

rightmouse
----------
Same as above only rightmouse this time.. Any need for a bothmouse?

NOTE: For a quick test edit the filenames in the examples..


Possible annoyances..
-----------------------------------------------------------------------------

1.> Commands name MUST be in lower-case at present (sorry for shouting)..

2.> If command has a syntax then there MUST be only ONE space between the
    command and its syntax (sorry again)..

3.> Command can start anywhere on the line.. (flexy-bill or what)

4.> There's really only two annoyances..


Great mysteries..
-----------------------------------------------------------------------------

1.> The bible is in the non-fiction section.

2.> goto 1.> (fun for the first minute..)


Params..
-----------------------------------------------------------------------------
AnimTRAC [-p priority and/or f] filename

Default priority is set at 9. To see your animation smoothly set it to 127
as AmigaOS has a habit of ignoring your script at 9 and runs at a 
non-consistant speed (workbench doing nothing seems to be more important)..

By adding f to the params loading ILBM's is much faster but needs memory
for the file as apposed to unpacking ILBM's from disk which is slow (has no
effect when loading shapes).

NOTE: To turn off cli-output just add >NIL: at the end..


Additional questions from Dash..
-----------------------------------------------------------------------------

- How many frames/shapes/samples etc can i have?

  As much as you have memory, or up to 1000 of each (0-999)..

- Can my files be xpk-packed?

  Yes, they doodily can. You should xpk-sqsh your modules and samples
  as you gain better compression than if they were in a lha/lzx archive.
  You can xpk the ascii/bin script file aswell..

- What about GIFs/PiNGs?

  Not in this version, but there is an alternative as xpk-packing ILBM files
  is usually very poor as ILBM's are already poorly compressed in there own
  poor way. Included is my own ILBM unpacker that converts the bitplanes to
  chunky-bits, not chunky-bytes (except 8-bit offcourse). It's called
  CBF (chunky-bits format), and once you've unpacked the the ILBM you should
  then xpk-elzx/shri the file for better compression than any ILBM or GIF,
  and sometimes even PNG.

- How does AnimTRAC unpack files?

  It uses xpk and cbf externally to temp (t:). For best speed make xpk
  resident and copy CBF to ram:..

  NOTE: Low-memory users should assign t: to their hard-drive or something..

- How do i get my ILBM back from a CBF file?

  Just CBF it again and it will convert it back, as long as you
  xpk-unpacked it before hand..

- Why is CBF so god damn slow?

  Because it's working with bits, not bytes..

- What is the different between a front-buffer and a back-buffer?

  The front-buffer is what you see and the back-buffer is what you cant see,
  so you can work on it. Commands like showframe and useframe copy the frame
  to the back-buffer, and showframe will swap the buffers revealing the frame
  flicker-free (called double-buffering). The same is done when opening
  new screens for frames with a new resolution and/or more bitplanes.
  But there's only ever one screen because once the new screen is setup and
  displayed the old screen is removed..

- Do i have to send you a HUGE royalty or something?

  HELL NO! Besides, in order to view it you have to use AnimTRAC anyway.
  (i hate the royals anyway!)

- I don't understand the setoffset command..

  Whatever setoffset is set to is automatically added to the RGB's in the
  currently used palette.. So it you set it to 125 any palette's used will
  be 50% brighter, where as -125 will make any colours 50% darker.
  Intended for smooth fade-ins and outs with the fadeoffset command.
  Example: fadeoffset -255,1 will fade the offset to black slowly.. Any
  palette's used from here on will start at black, allowing you to fade a
  frame out, then fade a new frame in from black or you could setoffset to
  0 again and when you next use a palette it will be back to normal..

- When loading files, can they be on different disks and will it load them
  properly?

  Just as long as you write the volume name in with the filename.
  e.g. anim_disk2:frames/frame.xpk 
  When AnimTRAC wants the file the OS will takeover and request the volume
  in a friendly manner before returning to your script.. (if its not present)

  NOTE: volume names can have spaces..
        e.g. "bobs sick anim-disk:" or "ram disk:"


Last words..
-----------------------------------------------------------------------------
AnimTRAC!(tm) was written on an A1200 with a measly 40MB hard-drive and
4MB fastmem using Blitz Basic 2.1 (with in-built 68000 assembler).
Should work on 2.0 and up?

I'd like to thank Ron the bus-driver, for helping out a guy who was
down on his luck with no place to go.. err.. just kidding!

(EXTRACTED :-> HUGE-MUNGIS list of thank-you's to computer-users/freaks
               i don't know or whom have nothing to do with this.
               Hate to break a trend and all.. sorry.. no, REALLY!!)
               
The real reason it's Called AnimTRAC is coz it's dedicated to the guys at
"SingleTRAC(tm)", America. Who the f**k are they? Well they've made/making
the best ever PlayStation(tm) games yet. Warhawk and Twisted Metal 2 kick
serious a**e (possessers of great gameplay). Can't wait for Critical Depth..
In this paragraph also comes some advice for future Amiga-dumpers come
PC-bumpers. If you want games keep your Amiga and get a Sony PlayStation(tm)
(i'm expecting some free games real soon for this plug!). Besides, i've
had my A1200 since 1994. Why have i still got it? (and a 500 before that)


For the AnimTRAC script-compiler send either:

- 10 UK£  (soccer sux badly! rugby and cricket rulz!)
- 15 US$  (take those pads off and play rugby! your rugby commentators suck!)
- 20 NZ$  (i think this one is most preferable.. or something..)
- 20 AUS$ (who somehow kicked the springboks? only we're allowed to do that!)
- 50,000,000 YEN (self-explainatory..)

		 To: Martin Edwards,
Before October 1997: 93 Norfolk Cresent, (no time-travellers please!)
October and onwards: 32 Scott Ave,
	             Otaki,
	             North Island,
                     New Zealand.

email: ihavenonetaccountornothingsodontbotherbesidesitwouldgetreallost.co.nz

Features of the AnimTRAC script-compiler..

- Small executable (by what measures?)
- A chance to send money to someone in New Zealand for the first time
- Converts ascii-scripts to binary-scripts (suprisingly)
- Help fund the best war-game-in-progress the amiga's ever seen since Dune 2
- Get the latest word on how it's going and all that
- Some other stuff
- Thats about all really
- I'll die from starvation if you don't
- (cough! gag gag! chuck! barf! errghhhhh, hoik... gulp... yummy!)
- (fill this space)

Look! Ten great features, for so little money. It's got to be worth it.
What are you waiting for, an infomercial..
