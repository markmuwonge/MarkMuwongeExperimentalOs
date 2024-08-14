load_stage_two:	
	pusha
	mov bp, sp

	;not utlizing disk ext
	cmp BYTE [DISK_EXT_PRESENT], 1
	jz load_stage_two_err

	; get number of reserved sectors starting from sector 0
	mov bx, [ORIGIN_ADDRESS + BPB_RsvdSecCnt_IDX]

	; get number of fats
	movzx ax, [ORIGIN_ADDRESS+BPB_NumFATs_IDX]

	; BPB_NumFATs * BPB_FATSz16 = total fat sectors in dx:ax
	;only considering ax - total fat sectors wont be greater than 65535
	mul WORD [ORIGIN_ADDRESS+BPB_FATSz16_IDX]

	;root dir sector number in bx
	add bx, ax
	 

	;get root directory size in sectors (ax)
	mov ax, [ORIGIN_ADDRESS+BPB_RootEntCnt_IDX]
	mov cx, FAT12_ROOT_DIR_ENTRY_BYTE_SIE
	mul cx
	;will not produce remainder. Ref pg.8 Microsoft FAT Specification August 30 2005 (BPB_RootEntCnt)
	div WORD [ORIGIN_ADDRESS+BPB_BytsPerSec_IDX]

	push  bx
	call lba_to_chs
	add sp, 2

	push ax ;cylinder
	push bx ;head
	push cx ;sector
	push WORD SECTOR_LOADING_BUFFER_ADDRESS
	push WORD 1 ; sector count
	push WORD [bp + 16 + 2] ;drive number
	call load_sectors_chs
	add sp, 12
	cmp ax, 0
	jz load_stage_two_err

	;find stage2.bin in root dir
	


	popa
	mov ax,1
	jmp load_stage_two_end
load_stage_two_err:
	popa
	mov ax, 0


load_stage_two_end:
	ret


include 'inc/16/lba_to_chs.asm'
include 'inc/16/load_sectors_chs.asm'


load_stage_two_taget_file_name: db 'STAGE2  BIN'