PROTECTED_MODE_STAGE_ONE:
	mov ax, GLOBAL_DESCRIPTOR_TABLE_DATA_SEGMENT_DESCRIPTOR - GLOBAL_DESCRIPTOR_TABLE_START
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov fs, ax
	mov gs, ax
	
	
	mov eax, [KERNEL_LOADER_ELF_FILE_FIRST_SECTOR_LOAD_LOCATION + 24]
	mov bl, [DRIVE_ID]
	movzx ebx, bl
	push ebx
	call eax
	add esp, 4
	
	jmp $