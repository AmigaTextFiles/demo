# as hello_sys.s -o hello_sys.o
# ld hello_sys.o -o hello_sys
# ./hello_sys

.globl _start
_start:

.text

    movl #1,%d1        /* stdout */
    movl #buffer,%d2   /* data   */
    movl #30,%d3       /* length */
    movl #4,%d0        /* syscall 'write' */
    trap #0            /* interrupt */

    movl #1,%d0        /* syscall 'exit' */
    trap #0            /* interrupt */
    
.data
buffer:	.string	"hello amigos from amiga linux\n"

    