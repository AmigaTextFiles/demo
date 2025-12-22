OBJS= texture.o pathplan.o main.o chess.o animate.o glutmenu.o
CFLAGS= -mcrt=newlib -DMINIGL -O2 -Wall

chess: $(OBJS)
	$(CC) -o $@ $(OBJS) -lGL -lGLU -lglut
	strip -R.comment $@

texture.o: texture.c chess.h

pathplan.o: pathplan.c chess.h

main.o: main.c chess.h

chess.o: chess.c chess.h

animate.o: animate.c chess.h


clean:
	-delete $(OBJS)

archive: clean
	lha -r u RAM:chess_gl // chess chess.info
