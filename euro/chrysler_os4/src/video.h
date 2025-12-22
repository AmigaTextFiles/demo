/* videoklippej‰ Amigalle
  - Antti Silvast

 */


void draw_video(unsigned char * buffer, int vbl, int no, int loop, int start, int dt);
/*
 *buffer = ruutu
 vbl = laskuri (p‰ivitys 50 Hz)
 no = videoklipin numero
 loop = looppimoodi (0: forward, 1: ping pong)
 start = triggaus (0: ei mit‰‰n,
                   1: 15 framea taaksep‰in,
		   3: 15 framea eteenp‰in,
		   2: suunnanvaihdos)

*/

