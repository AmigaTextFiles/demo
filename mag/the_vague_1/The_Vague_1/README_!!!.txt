                                                                              	
        .     ... .     __ _        _             _ __     . ...      .
         .... :        _)   __    _/(___    _____    (_        : ....
         :    :     _/\\   _) \__/   _ (___/  __/__   //\_     :    :
         : ...:    _)  \_ _)    )    /   (_  _)   (_ _/  (_    :... :
     . ..: :       |     \\_    \___/    _/  `    _//     |       : :.. .
           :  _    |_  _   /_____\ \_____\________\   _  _|    _  :
   . .. ...:  /    ./  \  /                        \  /  \.    \  :... .. .
             / _   |    \/ /_  T h e  v a g u E  _\ \/    |   _ \
            / /    |  __.       _    ___    _._    ___    |    \ \
           / /   ._:_.) |_______)\__/ _/___/ | \__/ __)_._:_.   \ \
           _/   _|   |  |   /  _  (_  \  (_  |  _) __)  |   |_   \_
  ___ /\___)   _\|_._|_   _/  _)  _/   \ _/  .  \_ `   _|_._|/_   (___/\ ___
  \  /             |   \_/ \__\___\______\_______/____/   |             \  /
 |\\//\            |              _ __  __ _              |            /\\//|
 | \/  \ _         |______ __________//\\__________ ______|         _ /  \/ |
 |      \/        _._..__/ \_________/  \_________/ \__.._._        \/      |
 |               _\|_||__o O_________    _________O o__||_|/_               |
 |                       \_/         \  /         \_/                       |
 |                               _ __\\//__ _                               |
 :         /\ _                       /\                       _ /\         :
 . __  _ _//\\\ _ ________ __ _ /\ _ //\\ _ /\ _ __ ________ _ ///\\_ _  __ .
 _/  \ \/ /  \\\//           \\//\\\///\\\///\\//           \\///  \ \/ /  \_
 |    \  /    \\/  _______ __  /  \\/ \/ \//  \  __ _______  \//    \  /    |
 |     \/ /||\ \  /          \/ /\ \  /\  / /\ \/          \  / /||\ \/     |
 |_      (o||O) \/              \/  \//\\/  \/              \/ (O||o)      _|
  _))     _||_                        \/                        _||_     ((_
 |        \::/         ._   _ _____     _________ _____         \::/        |
 |     _   ..       ___| \__\/   _ \_ _/   _____/ .__  \__       ..   _     |
 |_  /\\_______  /\_)           l/   \_  _    /   | /    (_/\  _______//\  _|
  (_/  \_     (_/  \_           /     (_ (_._/    |/     _/  \_)     _/  \_)
 - _ oO _))    _    /__________/      _/___|/____________\    _    ((_ Oo _ -
 _( \  /______( \  / - -------/_______\---------------- - \  / )______\  / )_
 |   \//_        \/                                        \/        _\\/   |
 |                          i.n.f.o.r.m./\.t.i.o.n                          |
 |                   - -------------------------------- -                   |
 |                                                                          |
 |                                                                          |
 | First, you must be sure that you have correctely installed  warp3d. Test |
 | it by running 'warptest' demo from archive.If you have some problem with |
 | it, you need to setup warp3d correctly,before you can run diskmag.If you |
 | have  "no  mode id"  found, or a similar problem, this means you have an |
 | incorrect setup of warp3d drivers.                                       |
 |                                                                          |
 |     _            _ __  __________________________  __ _            _     |
 |_  /\\_______  /\_)   \/                          \/   (_/\  _______//\  _|
  (_/  \_     (_/  \_         for Classic users          _/  \_)     _/  \_)
 - _ oO _))    _    / _                                _ \    _    ((_ Oo _ -
 _( \  /______( \  //\/         (A1200/A4000)          \/\\  / )______\  / )_
 |   \//_        \//______________________________________\\/        _\\/   |
 |                                                                          |
 |                                                                          |
 |                                                                          |
 | If all is ok, try to run it. If you have 'white/ grey/ anycolor' screen, |
 | problem can be (with case of mediator) in badly  ENV:Mediator/MMU value. |
 | You must  remember, that  for  68k  warp3d applications  over  mediator, |
 | ENV:Mediator/MMU must be set to YES. it possible to do some manipulation |
 | with warp3d drivers, and setup for it to  work with MMU=NO, but, in most |
 | cases it's kind of HACK, and MMU must be set to YES for 68k/warp3d apps. |
 |                                                                          |
 | If you have 'flickiring' on the screen while you use a mediator,you must |
 | set jumper WAIT to CLOSE state.                                          |
 |                                                                          |
 | Additional notes:                                                        |
 |                                                                          |
 |                                                                          |
 | 1.Engine must be run AFTER COLD REBOOT because aos3 does not have memory |
 |   protection. Many  other  apps  can  affect memory, some very important |
 |   pieces of code can be overwriten,and those things will create problems |
 |   for diskmag usage.This kind of problem without MP can't be detected'as |
 |   is', but you will see strange crash/ halt/ guru after some time :) So, |
 |   reboot is MUST.                                                        |
 |                                                                          |
 | 2.Classic users need the CORRECT ahi version.If you have some slowdowns, |
 |   you  must  update  your ahi version to the 6.0 or later. With 4.x (for |
 |   example) you will have these slowdowns.Also,with one tester's machine: |
 |   after running diskmag over ahi, music playing, and stopped/froze after |
 |   a  few  seconds. This  problem  is  solved by increasing the number of |
 |   channels.                                                              |
 |                                                                          |
 |                                                                          |
 |     _            _ __  __________________________  __ _            _     |
 |_  /\\_______  /\_)   \/                          \/   (_/\  _______//\  _|
  (_/  \_     (_/  \_     for Classic (BVision) users    _/  \_)     _/  \_)
 - _ oO _))    _    / _                                _ \    _    ((_ Oo _ -
 _( \  /______( \  //\/             (a1200)            \/\\  / )______\  / )_
 |   \//_        \//______________________________________\\/        _\\/   |
 |                                                                          |
 |                                                                          |
 | 1. Bvision have only 8mb of memory, so, best way for you: set wb mode to |
 |    640x480x8bit (or 15/16bit), reboot, and run dismag. In this  case 8mb |
 |    will be enough even for the longest articles.                         |
 |                                                                          |
 | 2. Some  testers  have  problems  with 24bit mode. And have some kind of | 
 |    'corruption'. This  is  problem  of 4.2 library which does not handle |
 |    correctly texture data with a depth  lower  then  depth of mode. Best |
 |    choice  here  -  just  use 15 / 16bit  modes, or slideback to the 4.0 |
 |    W3D_Permedia2.library while you use The Vague.                        |
 |                                                                          |
 |                                                                          |
 |                                                                          |
 |     _            _ __  __________________________  __ _            _     |
 |_  /\\_______  /\_)   \/                          \/   (_/\  _______//\  _|
  (_/  \_     (_/  \_         for MorphOS users          _/  \_)     _/  \_)
 - _ oO _))    _    / _                                _ \    _    ((_ Oo _ -
 _( \  /______( \  //\/      (Pegasos/Efika/Mac)        \/\\  / )______\  / )_
 |   \//_        \//______________________________________\\/        _\\/   |
 |                                                                          |
 |                                                                          |
 |                                                                          |
 | For morphos these kind of nuances can take place:                        |
 |                                                                          |
 | 1. if you have slowdowns, do not annoy MOS by running other applications |
 |    simultaneously (like bittorent).                                      |
 |                                                                          |
 | 2. if you have some problems with 'scissoring'(i.e some area of graphics |
 |    out of bounds and overlapping on some others areas, on  screen visual |
 |    of some kind of X/Y artefacts) it means you have old r200.library(for |
 |    example), where is was bug with scissoring. You need  get the  latest |
 |    w3d update from MOS team ("10.06.2006 - MorphOS 3D  Update release 2" |
 |    is minimum)                                                           |
 |                                                                          |
 | 3. if your mouse do not works in diskmag, then you are probably  using a |
 |    beta version of mos, in this case, use keys only or  emulate mouse by |
 |    ramiga+keys.                                                          |
 |                                                                          |
 |                                                                          |
 |     _            _ __  __________________________  __ _            _     |
 |_  /\\_______  /\_)   \/                          \/   (_/\  _______//\  _|
  (_/  \_     (_/  \_       for AmigaOS 4.x users        _/  \_)     _/  \_)
 - _ oO _))    _    / _                                _ \    _    ((_ Oo _ -
 _( \  /______( \  //\/       (A1/mA1/sam/peg2)         \/\\  / )______\  / )_
 |   \//_        \//______________________________________\\/        _\\/   |
 |                                                                          |
 |                                                                          |
 |                                                                          |
 | There are no issues. It seems tester's machines were set up correctly in |
 | all cases. However, if you do see a grimreaper, just click on ignore.    |
 |                                                                          |
 |     _            _ __  __________________________  __ _            _     |
 |_  /\\_______  /\_)   \/                          \/   (_/\  _______//\  _|
  (_/  \_     (_/  \_           for AROS users           _/  \_)     _/  \_)
 - _ oO _))    _    / _                                _ \    _    ((_ Oo _ -
 _( \  /______( \  //\/             (i386)             \/\\  / )______\  / )_
 |   \//_        \//______________________________________\\/        _\\/   |
 |                                                                          |
 |                                                                          |
 |                                                                          |
 | There are no issues. Wazp3d did the work :)                              |
 |                                                                          |
 |                                                                          |
 |     _            _ __  __________________________  __ _            _     |
 |_  /\\_______  /\_)   \/                          \/   (_/\  _______//\  _|
  (_/  \_     (_/  \_         for WinUAE users           _/  \_)     _/  \_)
 - _ oO _))    _    / _                                _ \    _    ((_ Oo _ -
 _( \  /______( \  //\/          (IBM PC:) )           \/\\  / )______\  / )_
 |   \//_        \//______________________________________\\/        _\\/   |
 |                                                                          |
 |                                                                          |
 | You  need latest version of Quarktex (warp3d to opengl wrapper). At this |
 | moment it's v.53                                                         |
 |                                                                          |
 | Best way,just use hardfile, where i already setup needed minimum,and put |
 | needed version of QuarkTex, ahi and so on.                               |
 |                                                                          |
 |                                                                          |
 |     _            _ __  __________________________  __ _            _     |
 |_  /\\_______  /\_)   \/                          \/   (_/\  _______//\  _|
  (_/  \_     (_/  \_                                    _/  \_)     _/  \_)
 - _ oO _))    _    / _      T  H  E      E  N  D      _ \    _    ((_ Oo _ -
 _( \  /______( \  //\/                                \/\\  / )______\  / )_
 |   \//_        \//______________________________________\\/        _\\/   |
 |                                                                          |
 |                                                                          |
 |  if you have any kind of problem with the engine on your configuration,  |
 |  just write at kas1e@yandex.ru , and i will  fix it shortly thereafter,  |
 |  if possible.                                                            |
 |                                                                          |
 |_                                                                        _|
 ./    _                           _  /\  _                           _    \.
 |_  /\\ _             _._         //\\//\\         _._             _ //\  _|
_ /_//\\\/__    ______( : )______/\/  \/  \/\______( : )_______   __\///\\_\ _
\/  _\/_\/ [aBHO]______ : _______            _______ : _______[-T!] \/_\/_  \/
    \/\/              (_:_)      \/\  /\  /\/      (_:_)              \/\/
                        .         _\\//\\//_         .
                                 _\   \/   /_


                                                                             
