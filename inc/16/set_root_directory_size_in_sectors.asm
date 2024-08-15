set_root_directory_size_in_sectors:
	pusha

	;get root directory size in sectors (ax)
	mov ax, [ORIGIN_ADDRESS+BPB_RootEntCnt_IDX]
	mov cx, FAT12_ROOT_DIR_ENTRY_BYTE_SIZE
	mul cx
	;will not produce remainder. Ref pg.8 Microsoft FAT Specification August 30 2005 (BPB_RootEntCnt)
	div WORD [ORIGIN_ADDRESS+BPB_BytsPerSec_IDX]
	mov [ROOT_DIR_SIZE_IN_SECTORS], al
	popa
	ret