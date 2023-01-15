#include "types.h"
uint8_t io_byte_in(uint16_t port){

	uint8_t data;

	asm volatile(
		"mov %1, %%dx;" //double percentage to signify literal register name, single percentage for operand (either output register operand or input operand)
		"in %%dx, %0"
		: "=r" (data) //output register operand (0) (must be prefixed by '='. r means let compiler choose which register for 'data')
		:"m" (port) //input operand (1) ('m' means 'dx' register will get its value from memory. If 'r' was used 'dx' will get its value from a register)
		:"dx" //clobber (registers notify compiler that these registers are used so it doesn't assume that the values it left there will still be there following this inline assembly section)
	); 
	
	return data;
}

void io_byte_out(uint16_t port, uint8_t data){
	asm volatile(
		"mov %0, %%al;"
		"mov %1, %%dx;"
		"out %%al , %%dx"
		:
		: "m" (data), "m" (port)
		:"dx", "ax"
		
	);
}

void io_in_four_byte_to_address(uint16_t port, void *destination_address, uint32_t repeat_count){
	asm volatile(
		"mov %0, %%ecx;"
		"mov %1, %%edi;"
		"mov %2, %%dx;"
		"cld;"
		"repnz insl"
		:
		: "m" (repeat_count), "m" (destination_address), "m" (port)
		
	);
}
/* REFERENCES */
//https://www.ibiblio.org/gferg/ldp/GCC-Inline-Assembly-HOWTO.html#ss5.4
// https://www.codeproject.com/Articles/15971/Using-Inline-Assembly-in-C-C
// https://stackoverflow.com/questions/26456510/what-does-asm-volatile-do-in-c
// https://stackoverflow.com/questions/46137148/gnu-assembler-syntax-for-in-and-out-instructions
// NOTE - inline assembly uses AT&T syntax - https://csiflabs.cs.ucdavis.edu/~ssdavis/50/att-syntax.htm