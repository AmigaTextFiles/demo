CC = gcc
LD = gcc
CFLAGS = `sdl-config --cflags` 
LDFLAGS = `sdl-config --libs` -lSDL_ttf
RM   = /bin/rm -f
OBJS = sinusfont.o 
PROG = sinusfont

.PHONY: clean
all: $(PROG)
$(PROG): $(OBJS)
	$(LD) $(LDFLAGS) -s -o $(PROG) $(OBJS)
sinusfont.o: sinusfont.c
	$(CC) $(CFLAGS) -c sinusfont.c
clean:
	$(RM) *~ $(OBJS) $(PROG)
