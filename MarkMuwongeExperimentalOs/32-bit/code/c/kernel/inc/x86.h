#ifndef MARK_MUWONGE_EXPERIMENTAL_OS_INC_X86_H
#define MARK_MUWONGE_EXPERIMENTAL_OS_INC_X86_H

#include "../inc/types.h"

uint8_t io_byte_in(uint16_t port);
void io_byte_out(uint16_t port, uint8_t data);
void io_in_four_byte_to_address(uint16_t port, void *destination_address, uint32_t repeat_count);

#endif /* !MARK_MUWONGE_EXPERIMENTAL_OS_INC_X86_H */