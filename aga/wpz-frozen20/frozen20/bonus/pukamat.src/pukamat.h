void fire(UBYTE *p);
void bump(UBYTE *p1,UBYTE *p2);
void rotzoom(UBYTE *p1, UBYTE *p2, float Zp, LONG Kp);
void pisteet(USHORT *p1);
void scaley(ULONG *p1, ULONG *p2);
void scalexy(ULONG *p1, ULONG *p2);
void display(UBYTE *p1, UBYTE *p2);

extern __asm ULONG MouseButton(void);
