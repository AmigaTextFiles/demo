CC = gcc
CFLAGS = -Wall `sdl-config --cflags` -ggdb
LIBS = -lm `sdl-config --libs`
NAME = wave4k
SRC = wave4k.c
OBJ = $(SRC:.c=.o)
RM = rm -f

all: $(NAME)

$(NAME): $(OBJ)
	@$(CC) $(CFLAGS) $(OBJ) -o $(NAME) $(LIBS)

.c.o:
	@$(CC) -c $(CFLAGS) $<

clean:
	@$(RM) *~ \#* *\#
	@$(RM) *.o

distclean: clean
	@$(RM) $(NAME)
