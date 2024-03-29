;;NOTE - CODE DEPENDANT ON KERNEL ELF FILE STARTING AT A SECTOR BOUNDARY i.e. an address divisible by 512d

;;;;;;;;;;;;;S;;;;;;;;;;;;;;;;;
GET_KERNEL_ELF_FILE_LOGICAL_SECTOR_NUMBER:
	pusha
	mov bp, sp
	mov bx, 0 ;logical sector counter
GET_KERNEL_ELF_FILE_LOGICAL_SECTOR_NUMBER_LOOP:
	
	push bx ;logical sector to start from
	push 0 ;destination segment start 
	push KERNEL_ELF_FILE_FIRST_SECTOR_LOAD_LOCATION ;destination offset start 
	push 1 ;number of sectors
	call LOAD_SECTORS_EXTENDED
	add sp, 8
	
	cmp ax, 0
	jl GET_KERNEL_ELF_FILE_LOGICAL_SECTOR_NUMBER_RETURN_MINUS_ONE
	
	inc bx
	
	cmp dword [KERNEL_ELF_FILE_FIRST_SECTOR_LOAD_LOCATION], 0x464c457f
	jne GET_KERNEL_ELF_FILE_LOGICAL_SECTOR_NUMBER_LOOP
	
	dec bx
	push bx
	jmp GET_KERNEL_ELF_FILE_LOGICAL_SECTOR_NUMBER_END

GET_KERNEL_ELF_FILE_LOGICAL_SECTOR_NUMBER_RETURN_MINUS_ONE:
	push -1
	jmp GET_KERNEL_ELF_FILE_LOGICAL_SECTOR_NUMBER_END
GET_KERNEL_ELF_FILE_LOGICAL_SECTOR_NUMBER_END:
	add sp, 2
	popa
	
	sub sp, 18
	pop ax
	add sp, 16
	
	ret
;;;;;;;;;;;;;E;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;S;;;;;;;;;;;;;;;;;
LOAD_KERNEL_ELF_FILE_SEGMENTS:
	pushad
	
	mov ebp, esp
	
	mov ebx, 0; program header table entry index
	
	mov cx, [KERNEL_ELF_FILE_FIRST_SECTOR_LOAD_LOCATION+44] ;number of program header table entries
	movzx ecx, cx
	
	mov si, [KERNEL_ELF_FILE_LOGICAL_SECTOR_NUMBER]
	movzx esi, si ;esi holds the KERNEL_ELF_FILE_LOGICAL_SECTOR_NUMBER 
	
ELF_FILE_PROGRAM_HEADER_TABLE_ENTRY_LOOP:
	cmp ecx, ebx ;check whether the number of program header table entries & the current program header table entry index is the same
	je ELF_FILE_PROGRAM_HEADER_TABLE_ENTRY_LOOP_RETURN_ZERO	;if number of program header table entries & the current program header table entry index the same - done
	
	mov edx, 0
	
	mov ax, [KERNEL_ELF_FILE_FIRST_SECTOR_LOAD_LOCATION+42] ;program header table entry size
	movzx eax, ax
	
	; after multiplication, edx:eax holds the target program header table entry's offset relative to the start of program header table
	mul ebx
	
	; after addition, edx:eax holds the target program header table entry offset relative to the start of elf file
	add eax, [KERNEL_ELF_FILE_FIRST_SECTOR_LOAD_LOCATION+28]  ;the program header table offset within the elf file is added to the target program header table entry's offset relative to the start of program header table
	
	; after division, edx:eax holds offset:logical sector number of target program header table entry as if the elf file were located starting from offset 0 on disk
	push dword SECTOR_SIZE
	div dword [ebp - 4]
	add esp, 4

	; after addition edx:eax holds the offset:logical sector number of target program header table entry on disk
	add eax, esi
	
	; load sector where the program header table entry resides into memory
	push ax ;logical sector to start from
	push 0 ;destination segment start 
	push KERNEL_LOADER_BUFFER_LOAD_LOCATION ;destination offset start 
	push 1 ;number of sectors
	call LOAD_SECTORS_EXTENDED
	add sp, 8
	
	cmp ax, 0 
	jl LOAD_KERNEL_ELF_FILE_SEGMENTS_RETURN_MINUS_ONE ;error loading sector where the program header table entry resides into memory
	
	add edx, KERNEL_LOADER_BUFFER_LOAD_LOCATION ;make edx hold the address of the target program header table entry that was just loaded into memory
	cmp dword [edx], 1 ; check that target program header table entry refers to a loadable segment 
	jne ELF_FILE_PROGRAM_HEADER_TABLE_ENTRY_LOOP_TRIGGER_NEXT_INTERATION ;the target program header table entry doesn't refer to a loadable segment, skip to the the next program header table entry 
	
	push dword [edx + 4] ;target program header table entry p_offset  
	pop dword [TARGET_PROGRAM_HEADER_TABLE_ENTRY_P_OFFSET]
	
	push dword [edx + 8] ;target program header table entry p_vaddr
	pop dword [TARGET_PROGRAM_HEADER_TABLE_ENTRY_P_VADDR]
	
	push dword [edx + 16] ;target program header table entry p_filesz
	pop dword [TARGET_PROGRAM_HEADER_TABLE_ENTRY_P_FILESZ]
	
	push dword [edx + 20] ;target program header table entry p_memsz
	pop dword [TARGET_PROGRAM_HEADER_TABLE_ENTRY_P_MEMSZ]
	
	cmp dword [TARGET_PROGRAM_HEADER_TABLE_ENTRY_P_FILESZ], 0 ;check if target program header table entry p_filesz is zero
	je ZERO_SIZE_TARGET_PROGRAM_HEADER_TABLE_ENTRY_P_FILESZ_ACTION
	jmp NON_ZERO_SIZE_TARGET_PROGRAM_HEADER_TABLE_ENTRY_P_FILESZ_ACTION
	
ZERO_SIZE_TARGET_PROGRAM_HEADER_TABLE_ENTRY_P_FILESZ_ACTION:
	cmp dword [TARGET_PROGRAM_HEADER_TABLE_ENTRY_P_MEMSZ], 0
	je ELF_FILE_PROGRAM_HEADER_TABLE_ENTRY_LOOP_TRIGGER_NEXT_INTERATION ;no segement data bytes required to be loaded into memory according to target program header table entry p_memsz
	
	; put target program header table entry's p_memsz number of 'pad' bytes at address pointed to by target program header table entry's p_vaddr
	mov eax, [TARGET_PROGRAM_HEADER_TABLE_ENTRY_P_VADDR]
	mov edx, [TARGET_PROGRAM_HEADER_TABLE_ENTRY_P_MEMSZ]
ZERO_SIZE_TARGET_PROGRAM_HEADER_TABLE_ENTRY_P_FILESZ_ACTION_PAD_LOOP:
	cmp edx, 0 ;once the number of 'pad' bytes to add reaches 0 jump out of loop ready for dealing with the next program header table entry
	je ELF_FILE_PROGRAM_HEADER_TABLE_ENTRY_LOOP_TRIGGER_NEXT_INTERATION
	
	mov byte [eax], 0x0 ;move a 'pad' byte to address pointed to at by eax
	
	inc eax ;eax to hold address of next location of pad byte
	dec edx ;decrement the number of 'pad' bytes to be added
	jmp ZERO_SIZE_TARGET_PROGRAM_HEADER_TABLE_ENTRY_P_FILESZ_ACTION_PAD_LOOP
	
NON_ZERO_SIZE_TARGET_PROGRAM_HEADER_TABLE_ENTRY_P_FILESZ_ACTION:
	; GOAL -read in the sector containing the target program header table entry segment data to KERNEL_LOADER_BUFFER_LOAD_LOCATION...
	;...then put target program header table entry's p_memsz number of bytes from KERNEL_LOADER_BUFFER_LOAD_LOCATION to at address pointed to by target program header table entry's p_vaddr

	cmp dword [TARGET_PROGRAM_HEADER_TABLE_ENTRY_P_MEMSZ], 0
	je ELF_FILE_PROGRAM_HEADER_TABLE_ENTRY_LOOP_TRIGGER_NEXT_INTERATION ;no segement data bytes required to be loaded into memory according to target program header table entry p_memsz
	
	cmp dword  [TARGET_PROGRAM_HEADER_TABLE_ENTRY_P_FILESZ], 1 ;a program table entry with segment data (on disk) with a size of 1 byte can't span more than 1 sector (the DATA_SECTOR_SPAN_LOOP routine code doesn't need to run)
	jne GREATER_THAN_ONE_BYTE_SIZE_TARGET_PROGRAM_HEADER_TABLE_ENTRY_P_FILESZ_ACTION
ONE_BYTE_SIZE_TARGET_PROGRAM_HEADER_TABLE_ENTRY_P_FILESZ_ACTION:
	mov ax, 1
	jmp SET_TARGET_PROGRAM_HEADER_TABLE_ENTRY_SEGEMENT_SECTOR_COUNT
	
GREATER_THAN_ONE_BYTE_SIZE_TARGET_PROGRAM_HEADER_TABLE_ENTRY_P_FILESZ_ACTION:
	; find out how many sectors the target program header table entry segment data spans (on file) over 
	push dword [TARGET_PROGRAM_HEADER_TABLE_ENTRY_P_FILESZ] ;counter that decrements (starting at the file size of the target program header table entry segment data) - [ebp - 4]
	push dword 0 ;offset from p_offset  - [ebp - 8]
	push dword SECTOR_SIZE  ;- [ebp - 12]
	push dword 1 ;number of sectors needed to occupy program header table entry segment data - [ebp - 16]
PROGRAM_HEADER_TABLE_ENTRY_SEGMENT_DATA_SECTOR_SPAN_LOOP:
	cmp dword [ebp - 4], 0 ;when the counter reaches zero end loop (every byte of the target program header table entry segment data has been accounted for)
	je PROGRAM_HEADER_TABLE_ENTRY_SEGMENT_DATA_SECTOR_SPAN_LOOP_END
	
	mov edx, 0
	
	mov eax, [TARGET_PROGRAM_HEADER_TABLE_ENTRY_P_OFFSET] 
	add eax, [ebp - 8];
	div dword [ebp - 12]
	
	;after the division, edx:eax holds remainder:quotient where a reamainder of 0 indicates the offset eax previously pointed to a byte within the table entry segment data at the start of a sector 
	
	cmp edx, 0
	je INCREMNT_NUMBER_OF_OCCUPYING_SECTORS
	jmp SKIP_INCREMNT_NUMBER_OF_OCCUPYING_SECTORS
INCREMNT_NUMBER_OF_OCCUPYING_SECTORS:
	inc dword [ebp - 16];
	
SKIP_INCREMNT_NUMBER_OF_OCCUPYING_SECTORS:	
	dec dword [ebp - 4]; dec counter
	inc dword [ebp - 8]; inc offset from p_offset
	jmp PROGRAM_HEADER_TABLE_ENTRY_SEGMENT_DATA_SECTOR_SPAN_LOOP
PROGRAM_HEADER_TABLE_ENTRY_SEGMENT_DATA_SECTOR_SPAN_LOOP_END:
	pop dword eax ;eax holds number of sectors the target program header table entry segment data spans (on file)
	add esp, 12

SET_TARGET_PROGRAM_HEADER_TABLE_ENTRY_SEGEMENT_SECTOR_COUNT:
	mov word [TARGET_PROGRAM_HEADER_TABLE_ENTRY_SEGEMENT_SECTOR_COUNT], ax ;#sectors the target program header table entry segment data spans over

	mov edx, 0
	
	; after division, edx:eax holds offset:sector where the program header table segment data is located as if the elf file were located starting from offset 0 on disk
	mov eax, [TARGET_PROGRAM_HEADER_TABLE_ENTRY_P_OFFSET] ; target program header table entry p_offset
	push dword SECTOR_SIZE
	div dword [ebp - 4]
	add esp, 4
	
	; after addition edx:eax holds the offset:logical sector number of target program header table entry segment data on disk
	add eax, esi
	
	; load sector/s where the program header table entry segment data resides into memory
	push ax ;logical sector to start from
	push 0 ;destination segment start 
	push KERNEL_LOADER_BUFFER_LOAD_LOCATION ;destination offset start 
	push word [TARGET_PROGRAM_HEADER_TABLE_ENTRY_SEGEMENT_SECTOR_COUNT] ;number of sectors 
	call LOAD_SECTORS_EXTENDED
	add sp, 8
	
	cmp ax, 0 
	jl LOAD_KERNEL_ELF_FILE_SEGMENTS_RETURN_MINUS_ONE ;error loading sector where the program header table entry segment data  resides into memory
	
	; edx holds offset to the program header table entry segment data within the sector it's in. adding KERNEL_LOADER_BUFFER_LOAD_LOCATION makes edx hold the program header table entry segment data starting address
	add edx, KERNEL_LOADER_BUFFER_LOAD_LOCATION
	xchg esi, eax ;need esi for movsb instruction so put the KERNEL_ELF_FILE_LOGICAL_SECTOR_NUMBER temporarily in eax
	mov esi, edx ;copy start location
	
	xchg ecx, edx; need ecx for movsb instruction so put the number of program header table entries temporarily in edx
	mov ecx, [TARGET_PROGRAM_HEADER_TABLE_ENTRY_P_MEMSZ] ;copy length
	
	mov edi, [TARGET_PROGRAM_HEADER_TABLE_ENTRY_P_VADDR] ;copy destination
	
	cld ;clear direction flag - to ensure si and di get incremented. If direction flag is set (with std isntruction) they will get decremented
	
	rep movsb ;repeat 'movsb' instruction ecx number of times - move (copy) byte at ds:esi to es:di. ecx gets decremented each time, si and di get incremented each time (as per cld instruction above)
	
	xchg esi, eax ;put KERNEL_ELF_FILE_LOGICAL_SECTOR_NUMBER back in esi ready for next loop interation
	xchg ecx, edx ;put number of program header table entries back in ecx ready for next loop interation
	
ELF_FILE_PROGRAM_HEADER_TABLE_ENTRY_LOOP_TRIGGER_NEXT_INTERATION:
	inc ebx ;increment program header table entry index
	jmp ELF_FILE_PROGRAM_HEADER_TABLE_ENTRY_LOOP
LOAD_KERNEL_ELF_FILE_SEGMENTS_RETURN_MINUS_ONE:
	push -1
	jmp ELF_FILE_PROGRAM_HEADER_TABLE_ENTRY_LOOP_END
ELF_FILE_PROGRAM_HEADER_TABLE_ENTRY_LOOP_RETURN_ZERO:
	push 0
ELF_FILE_PROGRAM_HEADER_TABLE_ENTRY_LOOP_END:
	add sp, 2
	popad
	
	sub sp, 34
	pop ax
	add sp, 32
	
	ret
;;;;;;;;;;;;;E;;;;;;;;;;;;;;;;;