# as keypress.s -o keypress.o
# ld keypress.o -o keypress
# ./keypress

.globl _start
_start:

        movl #1,%sp@  
	movel %sp,%d2 
	movel #0,%d3          /* FD_ZERO           */
	movel #0,%d4          /* FD_SET  	   */ 
	movl #0,%sp@(0x4)     /* strcut timeval    */  
	movl #50000,%sp@(0x8) /* strcut timeval    */    
	movl #1,%sp@(0xc)     /* strcut timeval    */  
	movl %sp,%d5          /* arguments in %d5  */
	movl #1,%d1           /* STDIN + 1         */
        movl #142,%d0         /* stscall 'select'  */
	trap #0

	cmpl #1,%d0           /* if not 'enter'    */
	bne _start            /* jmp on _start     */ 

exit:
	movl #1,%d0           /* syscall 'exit'    */
	trap #0
	




