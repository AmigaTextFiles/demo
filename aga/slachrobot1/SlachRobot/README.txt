
 Don't panic !

 What is it ?

 It is a first public release (01/09/2005) of the Slach Robot.

 The Slach Robot is a plugin to add to the demo script engine karate
 ( http://www.k-fighter.net ) on amiga computers. It was done
 by vic ferry AKA krabob/mankind (www.m4nkind.com)

 Fortunately, you got the main engine in this package, including the
 Robot.Fx plugin. You also need an amiga with AREXX installed on the system,
 and the narrator.device stuffs from workbench 2.0 working.

 To run a slach robot:

  -1.First click on one of the Blue icons, it throws a robot screen.
   A happy robot face will be display. Don't panic ! He is still silent.

 -2.then use Amiga+M or click on the upper right of the window, to come
   back to workbench. You see the robot has also opened a CLI output.

 -3. click on one of the icons below: they are dos script, feeding
    the robot with one or another artificial intelligence...(mf...)

 -4. go back to the robot screen. you can quit it with esc key.
   just watch him telling you absurdities with lips synchronisation.
   what an actor !!! Hours of enjoyment !


 So did you understand something ? no ? Well, actually, the karate
 demo script engine plugin interface appeared to be open enough to
 accept some AmigaOS stuff like arexx and the narrator speaking device.

 The robot face is drawn by the k3d engine , using a Lightwave object model
 to define its face. Karate 's 3D engine also know effects to make face morphs.

 The robot's intelligence is managed by an "effect" provided by robot.Fx:
 ("ProcessRobot"), and a constructor <HRobot> can create a robot brain.

 Karate cinematic parameter plugin interface was used to build parameters
 that manages the eye movement according to the IA.

 the narrator device was used by the IA to make the robot speak. Actually, it
 natively allows to redirect lips synchronisation. this was redirected
 to karate cinematic parameters (and to face morph, in real time of course).

 Arexx was perfect to stand for the robot stimuli that enter the application,
 and could be also used as output from the robot. (It was one time
 though that through AREXX, the slach robot could be put on a IRC client,
 and through it, invade the world.)

    rx send english sentence
    -> add a sentence to the robot

    rx time minimum maximum
    I don't remember, but it changes the time lapse possible
    between 2 sentences.

 The slach robot was build with a real iron body and played live
 at the slach party5 in france, August 2004, and at the barcelona party%11,
 october 2004.

 A "fast contest" about redrawing the robot face was launch at the slach,
 resulting all the skins you see here. (some others are in data/ )

 Sources of the plugin are included anyway... enjoy all that and have fun !
 Karate makes it possible (tm)

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

