SRCS = main.c

CFLAGS=$(shell sdl-config --cflags) -g -O3
LDFLAGS=$(shell sdl-config --libs) -lGLU -lGL -g -O3

main: $(SRCS:.c=.o)
	$(CC) -o $@ $< $(LDFLAGS)
	cat $(SRCS) | tr -d " \n\t" | wc -c

syn: syn.o
	$(CC) -o $@ $< $(LDFLAGS)
