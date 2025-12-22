all: sotb


sotb: main.o
	gcc `sdl-config --cflags --libs` main.o -o sotb -lSDL

main.o: main.c
	gcc -c `sdl-config --cflags --libs` main.c

clean:
	rm -f main.o sotb
