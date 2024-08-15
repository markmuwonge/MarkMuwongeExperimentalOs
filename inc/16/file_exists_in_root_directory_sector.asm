file_exists_in_root_directory_sector:
	pusha
	mov bp, sp
	push WORD 0 ;count of entries seen

	mov si, [bp + 16 + 2] ;filename
	mov di, [bp + 16 + 4] ;sector
	cld ;increment when using cmpsb

file_exists_in_root_directory_sector_loop:
	cmp WORD [bp - 2], FAT12_ROOT_DIR_ENTRIES_PER_SECTOR
	jz file_exists_in_root_directory_sector_popa
	inc WORD [bp - 2]

	mov cx, FAT12_FILE_NAME_LENGTH
	repe cmpsb
	jnz file_exists_in_root_directory_sector_prep_next_entry
	
	stc ;used to differentiate between found (set) and not found (not set)
	jmp file_exists_in_root_directory_sector_popa


file_exists_in_root_directory_sector_prep_next_entry:
	add WORD [bp + 16 + 4], FAT12_ROOT_DIR_ENTRY_BYTE_SIZE ;next root dir entry
	mov di, [bp + 16 + 4]

	mov si, [bp + 16 + 2] ;point si back to where the passed in filename is
	jmp file_exists_in_root_directory_sector_loop

file_exists_in_root_directory_sector_popa:
	;(add sp, 2) would affect the carry flag so using double inc
	inc sp
	inc sp

	popa
	jnc file_exists_in_root_directory_sector_no_match
	mov ax, 1 ; TODO - return sector offset instead of just one!!!!!!!!!!!!!!!
	jmp file_exists_in_root_directory_sector_end
file_exists_in_root_directory_sector_no_match:
	xor ax, ax

file_exists_in_root_directory_sector_end:
	clc
	ret
