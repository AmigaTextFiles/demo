MORPHOZA by ENCORE

version 1.3.0 (September 14th, 2023)

Demo for MorphOS PowerPC.

Alpha version of the demo was shown in 
the Wild competition at the Decrunch 2017 party 
(June 2nd-4th, 2017, Wroclaw/Poland).

code, engine, design, gfx 2D, gfx 3D, anim
MDW

music, support
AceMan

(C) 2017-2023 ENCORE

Contact:
e-mail: encore@amiga.pl
twitter: @encoregames

Requirements: 
hardware: PowerPC CPU, 3D accelerator
software: MorphOS 3.18, 3D drivers

Official video (1080p, 60FPS) with the demo: 
https://youtu.be/MZu9jDC3U7A


-------- history --------

ver. 1.3.0 (September 14th, 2023)
 - Engine updated to version 4.7.0.
 - Demo code adapted to new engine requirements.
 - Added function for save report to a file (MoerBoer's suggestion).
 - Fixed memory leak in the Launcher.
 - Fixed handling of help CLI argument.
 - Fixed disabling/enabling a screen blanker.
 - Fixed artifacts visible on the Report screen (thanks: Alexco for
   bug-report and tests, Bigfoot for the solution).

ver. 1.2.0 (January 2nd, 2023)
 - Engine updated to version 4.5.1.
 - Added option for play music loaded in to memory 
   or streamed from the file.
 - Optimisation of the Greetings part for increase frame rate.
 - Fixed bugs in memory management.
 - Modified GUI of the Launcher.
 - Modified text and update mechanism of the end scroll.
 - Assets management moved to new resource manager.
 - Demo code adapted to requirements of the new engine.
 - Structure of the project adapted to the new engine.
 - Increased frequency of updating particles in the Tree scene.

ver. 1.1.0 (August 5th, 2020)
 - Encore Engine updated to version 4.2.0.
 - Demo code adapted to new engine.
 - Small refactor of resources manager.
 - Added to Launcher function for disable looping of end scroller
   (hey Cool amigaN).

ver. 1.0.0 (May 4th, 2020)
 - Final version of the demo. Most of scenes have been changed, modified,
   optimized (gfx 2D/3D, anims and code).
 - Now the demo and the engine don't require SDL and use only standard
   MorphOS components/libraries.
 - Reggae multimedia framework (instead of SDL_Mixer) plays music.
 - User can switch (RCmd+F) between scalable window and and fullscreen
   during watching the demo.
 - Fixed all known bugs.
 - Added simple Launcher which allows to set some options before 
   run the demo.
 - Encore Engine updated to the latest version (hundreds fixes, changes,
   very important refactores).
 - Added report screen at the end of demo.

ver 0.9.0 alpha (June 2nd, 2017)
 - Unfinished version released the the Decrunch 2017 party.
