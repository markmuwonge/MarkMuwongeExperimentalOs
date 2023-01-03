use16
include '../../data/fasm/a20-line-constants.inc'
;;;;;;;;;;;;S;;;;;;;;;;;;
ENABLE_A20_LINE_MAIN:
	pusha
	
	cli
	
	call PRINT_AND_GET_A20_LINE_STATUS
	cmp ax, 0 ;if a20 line status is disabled, enable it and print status again
	je CALL_ENABLE_A20_LINE_AND_PRINT_STATUS
	jmp A20_LINE_ROUTINES_DONE
CALL_ENABLE_A20_LINE_AND_PRINT_STATUS:
	call ENABLE_A20_LINE
	
	push BOOT_SECTOR_MAGIC_NUMBER ;reseting boot sector magic number to how it was before
	call ALTER_BOOT_SECTOR_MAGIC_NUMBER
	add sp, 2
	
	call PRINT_AND_GET_A20_LINE_STATUS
	
A20_LINE_ROUTINES_DONE:	
	popa
	ret
;;;;;;;;;;;;E;;;;;;;;;;;;

;;;;;;;;;;;;;S;;;;;;;;;;;;;;;;;	
PRINT_AND_GET_A20_LINE_STATUS:
	pusha
	
	call GET_A20_LINE_STATUS ;returns 0 in eax for disabled (BOOT_SECTOR_MAGIC_NUMBER found) or 1 for enabled or .
	mov bx, ax
	
	push ALTERED_BOOT_SECTOR_MAGIC_NUMBER
	call ALTER_BOOT_SECTOR_MAGIC_NUMBER
	add sp, 2
	call GET_A20_LINE_STATUS ;if it finds the BOOT_SECTOR_MAGIC_NUMBER again sfter altering it in the bootsector, a20 is enabled
	
	cmp bx, ax
	je PRINT_AND_GET_A20_LINE_STATUS_PUSH_ONE
	push 0
	jmp CALL_PRINT_A20_STATUS
PRINT_AND_GET_A20_LINE_STATUS_PUSH_ONE:
	push 1

CALL_PRINT_A20_STATUS:
	call PRINT_A20_STATUS 
	add sp, 2 ;sp is now pointing to the last 16 bit register pushed by pusha (di)
	
	popa ;increments stack pointer by 16
	
	;get back A20_LINE_STATUS value ( it's at sp-16 - 2)
	
	sub sp, 18
	pop ax ; A20_LINE_STATUS value in ax
	
	add sp, 16

	ret
;;;;;;;;;;;;;E;;;;;;;;;;;;;;;;;		

;;;;;;;;;;;;;S;;;;;;;;;;;;;;;;;	
GET_A20_LINE_STATUS:
	pusha
	

	mov ax, 0xFFFF
	mov ds, ax
	
	mov ax, 0x10 ; at this point [ds:ax] should point to address 100000 if A20 is enabled or 00000 if not enabled
	
	add ax, ORIGIN_ADDRESS +  BOOT_SECTOR_MAGIC_NUMBER_OFFSET ; if A20 is disabled, [ds:ax] should point to address (0x7DFE). If a20 is enabled , [ds:ax] should point to address (0x107DFE)
	
	mov bx, ax 
	mov bx, [ds:bx] ;(doesn't work if ax is used for offset)
	cmp bx, BOOT_SECTOR_MAGIC_NUMBER
	
	popa 
	
	je A20_LINE_DISABLED ;assuming wrap around. However could still trigger when A20 line is enabled if there is BOOT_SECTOR_MAGIC_NUMBER at 0x107DFE
	mov ax, 1
	jmp GET_A20_LINE_STATUS_END
A20_LINE_DISABLED:
	mov ax, 0
GET_A20_LINE_STATUS_END:	
	ret
;;;;;;;;;;;;;E;;;;;;;;;;;;;;;;;	

;;;;;;;;;;;;;S;;;;;;;;;;;;;;;;;	
ALTER_BOOT_SECTOR_MAGIC_NUMBER:
	pusha
	
	mov ax, 0
	mov ds, ax
	
	mov bp, sp
	add bp, 16
	
	mov si, [ds:bp + 2] ;address
	sub bp, 16
	
	
	
	mov word [ds:ORIGIN_ADDRESS +  BOOT_SECTOR_MAGIC_NUMBER_OFFSET ], si
	
	popa
	ret

;;;;;;;;;;;;;E;;;;;;;;;;;;;;;;;	

;;;;;;;;;;;;;S;;;;;;;;;;;;;;;;;	
PRINT_A20_STATUS:
	pusha
	
	mov bp, sp
	add bp, 16
	
	mov ax, [bp + 2]
	sub bp, 16
	
	cmp ax, 1
	je PUSH_A20_LINE_ENABLED_MESSAGE_ADDRESS
	push A20_LINE_DISABLED_MESSAGE
	jmp PRINT_A20_LINE_ENABLED_MESSAGE
PUSH_A20_LINE_ENABLED_MESSAGE_ADDRESS:
	push A20_LINE_ENABLED_MESSAGE
PRINT_A20_LINE_ENABLED_MESSAGE:
	call PRINT_NULL_TERMINATED_TEXT
	add sp, 2
	popa
	ret
;;;;;;;;;;;;;E;;;;;;;;;;;;;;;;;	

;;;;;;;;;;;;;S;;;;;;;;;;;;;;;;;	
PRINT_NULL_TERMINATED_TEXT:
	pusha
	
	mov ax, 0
	mov ds, ax
	
	mov bp, sp
	add bp, 16
	
	mov si, [bp + 2]
	sub bp, 16
	
	mov ah, 0x0E
	mov bh, 0
	
PRINT_NULL_TERMINATED_TEXT_LOOP:
	cmp byte [si], 0
	je PRINT_NULL_TERMINATED_TEXT_END
	
	mov al, [si]
	int 0x10
	
	inc si
	jmp PRINT_NULL_TERMINATED_TEXT_LOOP
PRINT_NULL_TERMINATED_TEXT_END:
	popa
	ret
;;;;;;;;;;;;;E;;;;;;;;;;;;;;;;;	

;;;;;;;;;;;;;S;;;;;;;;;;;;;;;;;
;the 8042 keyboard controller is slow compared to the processor...
;therefore waiting before commands take effect is necessary
ENABLE_A20_LINE:
	pusha
	
	call GET_8042_KEYBOARD_CONTROLLER_INPUT_READY_STATUS
	cmp ax, 0
	je ENABLE_A20_LINE_END
	
	push 0xD0 ;command to 'read from output port'
	call SEND_8042_KEYBOARD_CONTROLLER_COMMAND
	add sp, 2

	call GET_8042_KEYBOARD_CONTROLLER_OUTPUT_READY_STATUS 
	cmp ax, 0
	je ENABLE_A20_LINE_END
	
	call GET_8042_KEYBOARD_CONTROLLER_OUTPUT_DATA ;returns output data in al
	mov bl, al ;save output data
	
	call GET_8042_KEYBOARD_CONTROLLER_INPUT_READY_STATUS
	cmp ax, 0
	je ENABLE_A20_LINE_END
	
	push 0xD1 ;command to 'write to output port'
	call SEND_8042_KEYBOARD_CONTROLLER_COMMAND
	add sp, 2
	
	call GET_8042_KEYBOARD_CONTROLLER_INPUT_READY_STATUS
	cmp ax, 0
	je ENABLE_A20_LINE_END
	
	or bl, 2 ;set bit 1 to 1 to enable a20 line
	push bx
	call SET_8042_KEYBOARD_CONTROLLER_OUTPUT_DATA
	add sp, 2
	
	call GET_8042_KEYBOARD_CONTROLLER_OUTPUT_READY_STATUS ;used to wait for above command to take effect

	
	
ENABLE_A20_LINE_END:	
	popa
	ret
;;;;;;;;;;;;;E;;;;;;;;;;;;;;;;;	

;;;;;;;;;;;;;S;;;;;;;;;;;;;;;;;
GET_8042_KEYBOARD_CONTROLLER_INPUT_READY_STATUS:
	pusha
	mov cx, 0 ;timeout counter for loop instruction
GET_8042_KEYBOARD_CONTROLLER_INPUT_READY_STATUS_LOOP:
	in al, 0x64
	and al, 2 ;if bit 1 is 0, 8042 keyboard controller is ready for input (input buffer empty)
	jz GET_8042_KEYBOARD_CONTROLLER_INPUT_READY_STATUS_PUSH_ONE
	loop  GET_8042_KEYBOARD_CONTROLLER_INPUT_READY_STATUS_LOOP
	push 0
	jmp GET_8042_KEYBOARD_CONTROLLER_INPUT_READY_STATUS_END
GET_8042_KEYBOARD_CONTROLLER_INPUT_READY_STATUS_PUSH_ONE:
	push 1
GET_8042_KEYBOARD_CONTROLLER_INPUT_READY_STATUS_END:
	add sp, 2
	popa
	
	sub sp, 18
	pop ax
	add sp, 16
	
	ret
;;;;;;;;;;;;;E;;;;;;;;;;;;;;;;;	

;;;;;;;;;;;;;S;;;;;;;;;;;;;;;;;
GET_8042_KEYBOARD_CONTROLLER_OUTPUT_READY_STATUS:
	pusha
	mov cx, 0 ;timeout counter for loop instruction
GET_8042_KEYBOARD_CONTROLLER_OUTPUT_READY_STATUS_LOOP:
	in al, 0x64
	and al, 1 ;if bit 0 is 1, 8042 keyboard controller is ready for output (output buffer full)
	jnz GET_8042_KEYBOARD_CONTROLLER_OUTPUT_READY_STATUS_PUSH_ONE
	loop  GET_8042_KEYBOARD_CONTROLLER_OUTPUT_READY_STATUS_LOOP
	push 0
	jmp GET_8042_KEYBOARD_CONTROLLER_OUTPUT_READY_STATUS_END
GET_8042_KEYBOARD_CONTROLLER_OUTPUT_READY_STATUS_PUSH_ONE:
	push 1
GET_8042_KEYBOARD_CONTROLLER_OUTPUT_READY_STATUS_END:
	add sp, 2
	popa
	
	sub sp, 18
	pop ax
	add sp, 16
	
	ret
;;;;;;;;;;;;;E;;;;;;;;;;;;;;;;;	

;;;;;;;;;;;;;S;;;;;;;;;;;;;;;;;
SEND_8042_KEYBOARD_CONTROLLER_COMMAND:
	pusha
	
	mov bp, sp
	
	mov ax, 0
	mov ds, ax
	
	mov al, [ds:bp+16+2]
	out 0x64, al
	
	popa
	ret
;;;;;;;;;;;;;E;;;;;;;;;;;;;;;;;	

;;;;;;;;;;;;;S;;;;;;;;;;;;;;;;;
GET_8042_KEYBOARD_CONTROLLER_OUTPUT_DATA:
	in al, 0x60
	ret
;;;;;;;;;;;;;E;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;S;;;;;;;;;;;;;;;;;
SET_8042_KEYBOARD_CONTROLLER_OUTPUT_DATA:
	pusha
	
	mov bp, sp
	
	mov ax, 0
	mov ds, ax
	
	
	mov ax, [ds:bp+16+2]
	out 0x60, al
	
	popa
	ret
;;;;;;;;;;;;;E;;;;;;;;;;;;;;;;;

