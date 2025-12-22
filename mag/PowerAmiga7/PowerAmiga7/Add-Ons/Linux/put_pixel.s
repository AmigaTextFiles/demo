.text

.globl _start
_start:

# set 'graphics kd mode'

        movl #54,%d0      /* ioctl */
        movl #0,%d1       /* stdin (from) */
        movl #0x4b3a,%d2  /* kdsetmode (/usr/include/linux/kd.h) */
        movl #1,%d3       /* 1 - kd graphics mode */ 
        trap #0

# mmap(0,VMEM_SIZE,PROT_READ|PROT_WRITE,MAP_SHARED,open("/dev/fb0",O_RDWR)0);
# open:
        /* descriptor back in %d0 */
	movl #fb_dev_name,%d1     /* /dev/fb0 */
	movl #2,%d2               
        movl #0,%d3               
        movl #5,%d0                /* open */
	trap #0

# mmap
        /* arguments in stack */       
        movl #0,%sp@             /* 0 */
        movl #307200,%sp@(0x4)   /* 640x480 */ 
        movl #3,%sp@(0x8)        /* prod_read | prot write */    
        movl #1,%sp@(0xc)        /* 1 - MAP_SHARED */     
        movl %d0,%sp@(0x10)      /* descriptor */     
        movl #0,%sp@(0x14)       /* 0 */

        movl %sp,%d1             /* arguments in %d1 */
        movl #90,%d0             /* 'mmap' */  
        trap #0
        movl %d0,video_handler   /* save video handler */
        movl video_handler,%a0   /* save video handler */

# clear screen:
 
        movl #640*480-3,%d1
clear:  addl #1,%a0
	movl #0,(%a0)
	subl #1,%d1
	cmpl #1,%d1
	bne clear

# put_pixel
         
        movl video_handler,%a0
        /* chords,color (in this sample uses 'aga' chipset) */	
	addl #50026,%a0              
	movl #1,(%a0)         
	

# key-pressed:
key_pressed:
        movl #1,%sp@  
	movel %sp,%d2 
	movel #0,%d3          /* FD_ZERO            */
	movel #0,%d4          /* FD_SET  	    */ 
	movl #0,%sp@(0x4)     /* strcut timeval     */  
	movl #50000,%sp@(0x8) /* strcut timeval     */    
	movl #1,%sp@(0xc)     /* strcut timeval     */  
	movl %sp,%d5          /* arguments in %d5   */
	movl #1,%d1           /* STDIN + 1          */
        movl #142,%d0         /* stscall 'select'   */
	trap #0

	cmpl #1,%d0           /* if not 'enter'     */
	bne key_pressed       /* jmp on key_pressed */ 


# exit:
# set 'text kd mode':

       movl #54,%d0      /* ioctl */
       movl #0,%d1       /* stdin (from) */
       movl #0x4b3a,%d2  /* kdsetmode (/usr/include/linux/kd.h) */
       movl #0,%d3       /* 0 - text kd mode */ 
       trap #0
            
       movl #1,%d0        /* exit */
       trap #0

.data
fb_dev_name: .string	"/dev/fb0"
video_handler: .long 0


