#
# Makefile for TIDY, using MorphOS SDK (gcc 2.95.3)
#

CFLAGS =	-c						\
		-pipe						\
		-O2						\
		-Wall						\
		-noixemul

PRG =		tidy
LIBS =		-noixemul
CC =		gcc
LD =		gcc

.c.o:
	${CC} ${CFLAGS} $< -o $@

SRC =	access.c	attrs.c		istack.c		\
	parser.c	tags.c		entities.c		\
	lexer.c		pprint.c	clean.c			\
	localize.c	config.c	alloc.c			\
	attrask.c	attrdict.c	attrget.c		\
	buffio.c	fileio.c	streamio.c		\
	tagask.c	tmbstr.c	utf8.c			\
	tidylib.c	tidy.c

OBJ =	$(SRC:.c=.o)

$(PRG): $(OBJ)
	${LD} -o $(PRG) $(OBJ) $(LIBS)

clean:
	rm -fv *.o $(PRG)
