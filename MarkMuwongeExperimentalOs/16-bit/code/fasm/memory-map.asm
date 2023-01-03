use16
;;;;;;;;;;;;;S;;;;;;;;;;;;;;;;;
SET_MEMORY_MAP:
	pushad
	
	mov bp, sp
	
	mov ebx, 0x0 ; start of memory map (memory map offset - automatically gets incremented each interrupt 0x15 call)
	mov ecx, MEMORY_MAP_ADDRESS_RANGE_DESCRIPTOR_SIZE ;how much of memory map to retrive each interrrupt 0x15 execution (20 bytes) 
	mov edi, MEMORY_MAP_LOAD_LOCATION

;;;;;;;;;;;;;S;;;;;;;;;;;;;;;;;
MEMORY_MAP_LOOP:
	mov eax, 0x0000e820
	mov edx, 0x534d4150
	int 0x15
	
	jc MEMORY_MAP_LOOP_PUSH_ZERO
	cmp ebx, 0 ;check if ebx is 0 cause if it is we are back at the start of memory map i.e. its done
	jz MEMORY_MAP_LOOP_PUSH_ONE
	
	add edi, MEMORY_MAP_ADDRESS_RANGE_DESCRIPTOR_SIZE ; point to the next 20 byte space within the buffer to fit the next 20 bytes of memory map 
	jmp MEMORY_MAP_LOOP
MEMORY_MAP_LOOP_PUSH_ZERO:
	push 0
	jmp MEMORY_MAP_LOOP_END
MEMORY_MAP_LOOP_PUSH_ONE:
	push 1
;;;;;;;;;;;;;E;;;;;;;;;;;;;;;;;
MEMORY_MAP_LOOP_END:
	add sp, 2
	popad
	
	sub sp, 34
	pop ax
	add sp, 32
	
	ret
;;;;;;;;;;;;;E;;;;;;;;;;;;;;;;;