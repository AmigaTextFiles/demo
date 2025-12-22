# A very pathetic makefile...

CC = gcc
CFLAGS += -funsigned-char

lib: obj
	ar rc cool_mzx.a pt.o cool_mzx.o sd_dsp16.o sd_main.o sd_mix.o sd_ns.o
	ranlib cool_mzx.a

obj:
	$(CC) $(CFLAGS) -c cool_mzx.c
	$(CC) $(CFLAGS) -c pt.c
	$(CC) $(CFLAGS) -c sd_dsp16.c
	$(CC) $(CFLAGS) -c sd_main.c
	$(CC) $(CFLAGS) -c sd_mix.c
	$(CC) $(CFLAGS) -c sd_ns.c

clean:
	delete #?.o
	delete #?.a
