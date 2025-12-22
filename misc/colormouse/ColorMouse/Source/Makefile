# Makefile for Custom Mouse Cursor Demo
#

CFLAGS =  $(shell sdl-config --cflags)
LIBS = $(shell sdl-config --libs) -lm

cmouse: mouse.o
	$(CC) -o $@ $< $(LIBS)

clean:
	rm -f *.o cmouse
