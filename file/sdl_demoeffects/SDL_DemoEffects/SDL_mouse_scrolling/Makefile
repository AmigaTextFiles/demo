CC = g++
LD = g++
CFLAGS = -Wall -Isdk:local/newlib/include/SDL 
LDFLAGS = -lSDL_image -lpng -ljpeg -lz -lSDL -lauto -lpthread
RM   = /bin/rm -f
OBJS = scrolling.o 
PROG = scrolling
VERS = 0.1.0

.PHONY: clean distclean
all: $(PROG)
$(PROG): $(OBJS)
	$(LD) $(LDFLAGS) -s -o $(PROG) $(OBJS)
scrolling.o: scrolling.cpp
	$(CC) $(CFLAGS) -O2 -c scrolling.cpp 
clean:
	$(RM) *~ $(OBJS) $(PROG)
.PHONY: clean
