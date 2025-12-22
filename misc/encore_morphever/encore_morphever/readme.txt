MORPHEVER by ENCORE

version 1.3.0 (September 14th, 2023)

Demo for MorphOS PowerPC.

The demo was shown in the Wild competition
at the Decrunch 2022 party 
(October 21st - 23rd, 2022, Wroclaw/Poland).

code, engine, design, gfx 2D, gfx 3D, anim
MDW

music, design
Skyrunner

(C) 2022-2023 ENCORE

Contact:  
e-mail: encore@amiga.pl
twitter: @encoregames

Requirements: 
hardware: PowerPC CPU, 3D accelerator
software: MorphOS 3.18, 3D drivers

Official video (1080p, 60FPS) with the demo: 
https://youtu.be/Cy_qmzKN1vM


-------- history --------

ver.1.3.0 (September 14th, 2023)
 - Engine updated to version 4.7.0.
 - Demo code adapted to new engine requirements.
 - Added function for save report to a file (MoerBoer's suggestion).
 - Fixed memory leak in the Launcher.
 - Fixed handling of help CLI argument.
 - Fixed disabling/enabling a screen blanker.
 - Fixed artifacts visible on the Report screen and 
   the Encore Logo part (thanks: Alexco for the bug-report 
   and tests, Bigfoot for the solution).

ver. 1.2.0 (Januaary 2nd, 2023)
 - Engine updated to version 4.5.0.
 - Added option for play music loaded in to memory 
   or streamed from the file.
 - Performance improvements and bugfixes.
 - Fixed order of demo parts in the report.
 - Modified text and update mechanism of the end scroll.
 - Modified GUI of the Launcher.
 - Compiled with MorphOS 3.16 SDK and GCC 11.

ver 1.1.0 (November 10th, 2022)
 - Engine updated to version 4.4.0.
 - Reduced VRAM usage (fixed preloading textures).
 - Reduced RAM consumption (music is played from file instead 
   of data in memory). Now the demo should work on Efika.
 - Now the demo works correctly on TinyGL from MorphOS 3.17
   (doesn't require update TinyGL to beta versions).
 - Reduced CPU usage of end part (optimized rendering the scroll).
 - Small modifications in text of the end scroll.

ver. 1.0.0 (October 22nd, 2022)
 - The first public version released at the Decrunch 2022 party.
