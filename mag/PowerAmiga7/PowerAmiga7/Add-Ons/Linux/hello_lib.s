# gcc hello_lib.s -o hello_lib
# ./hello_lib

.globl main
main:

.text
	pea buffer      /* data in stack */ 
	jbsr printf     /* printf */
	addq.l #4,%sp   /* remove old data from stack */
	rts             /* exit */

.data
buffer:	.string	"hello amigos from amiga linux\n"

