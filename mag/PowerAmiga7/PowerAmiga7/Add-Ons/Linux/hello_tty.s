# as hello_tty.s -o hello_tty.o
# ld hello_tty.o -o hello_tty
# ./hello_tty

.globl _start
_start:

.text

    movl #5,%d0        /* open */
    movl #dev_tty,%d1  /* file need for open */
    movl #0xc02,%d2    /* open read & write */
    trap #0

    movl %d0,%d1       /* descriptor on open file */ 
    
    movl #buffer,%d2   /* data   */
    movl #30,%d3       /* length */
    movl #4,%d0        /* syscall 'write' */
    trap #0            /* interrupt */

    movl #1,%d0        /* syscall 'exit' */
    trap #0            /* interrupt */
    
.data
buffer:	.string	"hello amigos from amiga linux\n"
dev_tty: .string "/dev/tty1"
    