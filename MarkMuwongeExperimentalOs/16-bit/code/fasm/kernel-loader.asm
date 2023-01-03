;;;;;;;;;;;;;S;;;;;;;;;;;;;;;;;
GET_KERNEL_LOADER_ELF_FILE_LOGICAL_SECTOR_NUMBER:
	pusha
	mov bp, sp
	mov bx, 0 ;logical sector counter
GET_KERNEL_LOADER_ELF_FILE_LOGICAL_SECTOR_NUMBER_LOOP:
	
	push bx ;logical sector to start from
	push 0 ;destination segment start 
	push KERNEL_LOADER_ELF_FILE_FIRST_SECTOR_LOAD_LOCATION ;destination offset start 
	push 1 ;number of sectors
	call LOAD_SECTORS_EXTENDED
	add sp, 8
	
	cmp ax, 0
	jl GET_KERNEL_LOADER_ELF_FILE_LOGICAL_SECTOR_NUMBER_RETURN_MINUS_ONE
	
	inc bx
	
	cmp dword [KERNEL_LOADER_ELF_FILE_FIRST_SECTOR_LOAD_LOCATION], 0x464c457f
	jne GET_KERNEL_LOADER_ELF_FILE_LOGICAL_SECTOR_NUMBER_LOOP
	
	dec bx
	push bx
	jmp GET_KERNEL_LOADER_ELF_FILE_LOGICAL_SECTOR_NUMBER_END

GET_KERNEL_LOADER_ELF_FILE_LOGICAL_SECTOR_NUMBER_RETURN_MINUS_ONE:
	push -1
	jmp GET_KERNEL_LOADER_ELF_FILE_LOGICAL_SECTOR_NUMBER_END
GET_KERNEL_LOADER_ELF_FILE_LOGICAL_SECTOR_NUMBER_END:
	add sp, 2
	popa
	
	sub sp, 18
	pop ax
	add sp, 16
	
	ret
;;;;;;;;;;;;;E;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;S;;;;;;;;;;;;;;;;;
LOAD_KERNEL_LOADER_ELF_FILE_SEGMENTS:
	pushad
	
	mov ebp, esp
	
	mov ebx, 0; program header table entry index
	
	mov cx, [KERNEL_LOADER_ELF_FILE_FIRST_SECTOR_LOAD_LOCATION+44] ;number of program header table entries
	movzx ecx, cx
	
	mov al, [KERNEL_LOADER_ELF_FILE_LOGICAL_SECTOR_NUMBER]
	movzx eax, al
	mov esi, eax ;esi holds the KERNEL_LOADER_ELF_FILE_LOGICAL_SECTOR_NUMBER 
	
ELF_FILE_PROGRAM_HEADER_TABLE_ENTRY_LOOP:
	cmp ecx, ebx ;check whether the number of program header table entries & the current program header table entry index is the same
	je ELF_FILE_PROGRAM_HEADER_TABLE_ENTRY_LOOP_RETURN_ZERO	;if number of program header table entries & the current program header table entry index the same - done
	
	mov edx, 0
	
	mov ax, [KERNEL_LOADER_ELF_FILE_FIRST_SECTOR_LOAD_LOCATION+42] ;program header table entry size
	movzx eax, ax
	
	; after multiplication, edx:eax holds the target program header table entry's offset relative to the start of program header table
	mul ebx
	
	; after addition, edx:eax holds the target program header table entry offset relative to the start of elf file
	add eax, [KERNEL_LOADER_ELF_FILE_FIRST_SECTOR_LOAD_LOCATION+28]  ;the program header table offset within the elf file is added to the target program header table entry's offset relative to the start of program header table
	
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
	jl LOAD_KERNEL_LOADER_ELF_FILE_SEGMENTS_RETURN_MINUS_ONE ;error loading sector where the program header table entry resides into memory
	
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
	
	;find out how many sectors the target program header table entry segment data spans over & push that value
	;Method: (p_filesz - 1)/SECTOR SIZE... then add one to the quotient... the quotient holds # sectors 
	mov edx, 0
	mov eax, [TARGET_PROGRAM_HEADER_TABLE_ENTRY_P_FILESZ]  ;target program header table entry p_filesz
	dec eax
	push dword SECTOR_SIZE 
	div dword [ebp - 4] ;SECTOR_SIZE
	add esp, 4
	
	;after the division edx:eax holds remainder:quotient
	inc eax 
	mov word [TARGET_PROGRAM_HEADER_TABLE_ENTRY_SEGEMENT_SECTOR_COUNT], ax ;#sectors the target program header table entry segment data spans over
	
	mov edx, 0
	
	; after division, edx:eax holds offset:sector where the program header table segment data is located as if the elf file were located starting from offset 0 on disk
	mov eax, [TARGET_PROGRAM_HEADER_TABLE_ENTRY_P_OFFSET] ; target program header table entry p_offset
	push dword SECTOR_SIZE
	div dword [ebp - 4]
	add esp, 4
	
	; after addition edx:eax holds the offset:logical sector number of target program header table entry segment data on disk
	add eax, esi
	
	; load sector where the program header table entry segment data resides into memory
	push ax ;logical sector to start from
	push 0 ;destination segment start 
	push KERNEL_LOADER_BUFFER_LOAD_LOCATION ;destination offset start 
	push word [TARGET_PROGRAM_HEADER_TABLE_ENTRY_SEGEMENT_SECTOR_COUNT] ;number of sectors 
	call LOAD_SECTORS_EXTENDED
	add sp, 8
	
	cmp ax, 0 
	jl LOAD_KERNEL_LOADER_ELF_FILE_SEGMENTS_RETURN_MINUS_ONE ;error loading sector where the program header table entry segment data  resides into memory
	
	mov eax, [TARGET_PROGRAM_HEADER_TABLE_ENTRY_P_FILESZ] ;p_filesz
	cmp eax, [TARGET_PROGRAM_HEADER_TABLE_ENTRY_P_MEMSZ] ;compare p_filesz with p_memsz
	je CALL_EQUAL_P_FILESZ_AND_P_MEMSZ_ACTION
	jg CALL_GREATER_P_FILESZ_THAN_P_MEMSZ_ACTION
	jl CALL_GREATER_P_MEMSZ_THANP_FILESZ_ACTION
	
CALL_EQUAL_P_FILESZ_AND_P_MEMSZ_ACTION:
	; get p_memsz or p_filesz and copy to destination addr
	
	; edx holds offset to the program header table entry segment data within the sector it's in. adding KERNEL_LOADER_BUFFER_LOAD_LOCATION makes edx hold the program header table entry segment data starting address
	add edx, KERNEL_LOADER_BUFFER_LOAD_LOCATION
	xchg esi, eax ;need esi for movsb instruction so put the KERNEL_LOADER_ELF_FILE_LOGICAL_SECTOR_NUMBER temporarily in eax
	mov esi, edx ;copy start location
	
	xchg ecx, edx; need ecx for movsb instruction so put the number of program header table entries temporarily in edx
	mov ecx, [TARGET_PROGRAM_HEADER_TABLE_ENTRY_P_MEMSZ] ;copy length
	
	mov edi, [TARGET_PROGRAM_HEADER_TABLE_ENTRY_P_VADDR] ;copy destination
	
	cld ;clear direction flag - to ensure si and di get incremented. If direction flag is set (with std isntruction) they will get decremented
	
	rep movsb ;repeat 'movsb' instruction ecx number of times - move (copy) byte at ds:esi to es:di. ecx gets decremented each time, si and di get incremented each time (as per cld instruction above)
	
	xchg esi, eax ;put KERNEL_LOADER_ELF_FILE_LOGICAL_SECTOR_NUMBER back in esi ready for next loop interation
	xchg ecx, edx ;put number of program header table entries back in ecx ready for next loop interation
	jmp ELF_FILE_PROGRAM_HEADER_TABLE_ENTRY_LOOP_TRIGGER_NEXT_INTERATION
CALL_GREATER_P_FILESZ_THAN_P_MEMSZ_ACTION:
	; from KERNEL_LOADER_BUFFER_LOAD_LOCATION copy p_memsz bytes to destination addr
	jmp LOAD_KERNEL_LOADER_ELF_FILE_SEGMENTS_RETURN_MINUS_ONE ;for now kernel loader wont be loaded if p_filesz and p_memsz are not equal
CALL_GREATER_P_MEMSZ_THANP_FILESZ_ACTION:
	;from KERNEL_LOADER_BUFFER_LOAD_LOCATION copy p_filesz then pad the rest with 0's until total bytes copied to dest addr is p_memsz
	jmp LOAD_KERNEL_LOADER_ELF_FILE_SEGMENTS_RETURN_MINUS_ONE ;for now kernel loader wont be loaded if p_filesz and p_memsz are not equal
ELF_FILE_PROGRAM_HEADER_TABLE_ENTRY_LOOP_TRIGGER_NEXT_INTERATION:
	inc ebx ;increment program header table entry index
	jmp ELF_FILE_PROGRAM_HEADER_TABLE_ENTRY_LOOP
LOAD_KERNEL_LOADER_ELF_FILE_SEGMENTS_RETURN_MINUS_ONE:
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


;;;;;;;;;;;;;S;;;;;;;;;;;;;;;;;
LOAD_ELF_PROGRAM_HEADER_TABLE_ENTRY_SEGMENT:
				; ^read program header entry into memory
	; parse program header entry and get the offset within the elf file where the segment is
	; parse program header entry and get the size of the segment
	; read in segment to memory at the defined address (pos 8d in program header)
	ret
;;;;;;;;;;;;;E;;;;;;;;;;;;;;;;;