	mov ax, 0
	mov ds, ax
	mov es, ax
	
	mov sp, ORIGIN_ADDRESS
	
	call DISK_EXTENSIONS_PRESENT
	cmp ax, 0
	je $
	
	push 1 ;logical sector to start from
	push 0 ;destination segment start 
	push REAL_MODE_STAGE_TWO ;destination offset start 
	push 3 ;number of sectors 
	call LOAD_SECTORS_EXTENDED
	add sp, 8
	cmp ax, 0
	jl $
	
	jmp REAL_MODE_STAGE_TWO