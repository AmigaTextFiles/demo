#ifndef _TRACKERPACKER_H
#define _TRACKERPACKER_H

extern void tp_init(void);
extern void tp_end(void);
__far extern uint32_t tp_vbr;
__far extern uint8_t* tp_data;
__far extern uint8_t* tp_samples;
__far extern uint16_t tp_line;
__far extern bool tp_triggered[];

#endif
