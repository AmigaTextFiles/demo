CC = gcc
LD = gcc
CFLAGS = `sdl-config --cflags` 
RM   = /bin/rm -f
OBJS = sinusfont.o 
PROG = sinusfont

.PHONY: clean
all: $(PROG)
$(PROG): $(OBJS)
	$(LD) `sdl-config --libs` $(OBJS) -o $(PROG) -lSDL -lSDL_ttf
sinusfont.o: sinusfont.c
	$(CC) -c sinusfont.c $(CFLAGS)
clean:
	$(RM) *~ $(OBJS) $(PROG)
