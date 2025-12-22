KHESHKHASH by ENCORE & SCENIC

version 2.1.0 (September 14th, 2023)

Demo for MorphOS PowerPC

The first version of the demo was shown in Amiga demo 
competition at the Mekka & Symposium 2002 party 
(March 29th - April 1st, 2002, 
Heidmarkhalle in Fallingbostel, Germany)

Remastered version created for MorphOS/PPC in 2022.

code, engine, remastered gfx3D/anim:
MDW

graphics by the gfx-group Scenic:
Caro
Critikill
Fusko
Mantra
Mime
Pix
Spark
Splif

music (original and remaster):
Jazzcat

(C) 2002-2023 ENCORE+SCENIC

Contact:  
e-mail: encore@amiga.pl
twitter: @encoregames

Requirements: 
hardware: PowerPC CPU, 3D accelerator
software: MorphOS 3.18, 3D drivers

Official video (1080p, 60FPS) with the demo: 
https://youtu.be/7-cM6VD0Xpc


-------- history --------

ver. 2.1.0 (September 14th, 2023)
 - Fixed minor bugs.
 - Engine updated to version 4.7.0.
 - Demo code adapted to new engine requirements.
 - Added function for save report to a file (MoerBoer's suggestion).
 - Modified update mechanism of the end scroll.
 - Fixed mamory leak in the Launcher.
 - Fixed handling of help CLI argument.
 - Fixed disabling/enabling a screen blanker.
 - Fixed artifacts visible on the Report screen (thanks: Alexco 
   for the bug-report and tests, Bigfoot for the solution).

ver. 2.0.0 (December 27th, 2022)
 - 100% code rewritten in C/C++ (MorphOS 3.16 SDK, GCC 11).
 - Code is based on the Encore Engine 4.5.0 (2022).
 - 3D rendering is realized in "fixed pipeline" (without using
   shaders, like in 2002).
 - Native version for MorphOS PowerPC.
 - Music remastered by Jazzcat - author of the original version.
 - All scenes, animation paths and models recreated in Blender 3D 
   and exported using Encore's plugins to files in formats 
   required by the Encore Engine.
 - Added light in the Temple part. According to info from
   Fusko - it was planned but not realized in 2002.
 - Added shadow in the Pipe part.
 - Smoke in the Pipe part now uses Encore's particles system.
 - Added rotating flares in the Good-Bad part.
 - This version of the demo uses original images, but some textures 
   were upscaled with a machine learning algorithm and adapted 
   to new requirements.
 - Fixed alpha-channels and antialias in some textures.
 - Fog per-vertex replaced by tricky pseudo fog per-pixel.
 - End scroller created in EncUIKit.
 - Added cyclical fading of background images in the End part.
 - Added Launcher which allows to select the demo parameters.
 - Now a user can switch between window and screen modes while 
   watching the demo..
 - MorphOS version of the demo uses the Reggae (MorphOS multimedia 
   framework) and allows to play music loaded into memory 
   or streamed from the file.

ver. 1.0.0 (October 22nd, 2022)
 - The first public version for AmigaPPC+3D (StormMESA) released 
   at the Mekka&Symposium 2002 party in Amiga demo compo.
