# A very pathetic makefile...

COPT += -funsigned-char

lib: obj
	ar rc cool_mzx.a pt*.o cool*.o sd*.o
	ranlib cool_mzx.a

obj:
	$(CC) $(COPT) -c *.c

clean:
	rm *.o *.a
