set_root_directory_sector_number:
	pusha

	; get number of reserved sectors starting from sector 0
	mov bx, [ORIGIN_ADDRESS + BPB_RsvdSecCnt_IDX]

	; get number of fats
	movzx ax, [ORIGIN_ADDRESS+BPB_NumFATs_IDX]

	; BPB_NumFATs * BPB_FATSz16 = total fat sectors in dx:ax
	;only considering ax - total fat sectors wont be greater than 65535
	mul WORD [ORIGIN_ADDRESS+BPB_FATSz16_IDX] ;root dir sector number in ax

	add ax, bx
	mov [ROOT_DIR_SECTOR_NUMBER], al
	popa 
	ret
