load_stage_two:	
	pusha
	mov bp, sp

	call set_root_directory_sector_number
	call set_root_directory_size_in_sectors
	
load_stage_two_find_loop:
	;loop from sector 'root_dir_sector_number' to (('root_dir_sector_number' + 'root_dir_sector_size_in_sectors') - 1) to find stage 2
	movzx ax, [ROOT_DIR_SECTOR_NUMBER]
	movzx bx, [ROOT_DIR_SIZE_IN_SECTORS]
	cmp ax, bx
	jz load_stage_two_err ;couldn't find stage_two

	push  ax
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

	;find stage2.bin in root dir
	push WORD SECTOR_LOADING_BUFFER_ADDRESS
	push WORD load_stage_two_taget_file_name
	call file_exists_in_root_directory_sector
	add sp, 4
	cmp ax, -1 ;11 on fail or root dir entry index
	jz root_dir_file_name_not_found
	jmp root_dir_file_name_found

root_dir_file_name_not_found:
	inc BYTE [ROOT_DIR_SECTOR_NUMBER]
	jmp load_stage_two_find_loop

root_dir_file_name_found:

	mov cx, FAT12_ROOT_DIR_ENTRY_BYTE_SIZE
	mul cx ;dx:ax holds the start offset of root dir entry (only paying attention to ax -> 1 sector can only hold a max start offset of 480)
	mov bx, ax ; moving start offset of root dir entry to bx - can't dereference ax

	mov bx, [bx + SECTOR_LOADING_BUFFER_ADDRESS + FAT12_ROOT_DIR_ENTRY_FIRST_DATA_CLUSTER_IDX]; 1st stage two data cluster number in bx
	sub bx, 2; data cluster numbers start at 2. REF Microsoft FAT Specification August 30 2005 pg.16. (Prefer starting data cluster numbers from zero)

	;consider sectors per cluster
	xor dx, dx
	xor ax, ax
	movzx ax, [ORIGIN_ADDRESS + BPB_SecPerClus_IDX]
	mul bx ;dx:(ax) relative to the start of the data section, ax holds the sector number representing stage 2's first sector

	mov cl, [ROOT_DIR_SECTOR_NUMBER]
	add cl, [ROOT_DIR_SIZE_IN_SECTORS] ;cl holds the sector number of the data section relative to the start of the FAT
	movzx cx, cl
	add cx, ax ;cx holds the sector number of stage 2 relative to the start of the FAT
	
	push cx
	call lba_to_chs
	add sp, 2

	push ax ;cylinder
	push bx ;head
	push cx ;sector
	push WORD STAGE2_LOAD_ADDRESS
	push WORD 1 ; sector count
	push WORD [bp + 16 + 2] ;drive number
	call load_sectors_chs
	add sp, 12
	

	popa
load_stage_two_end:
	ret

include 'inc/16/set_root_directory_sector_number.asm'
include 'inc/16/set_root_directory_size_in_sectors.asm'
include 'inc/16/lba_to_chs.asm'
include 'inc/16/load_sectors_chs.asm'
include 'inc/16/file_exists_in_root_directory_sector.asm'

load_stage_two_taget_file_name: db 'STAGE2  BIN'

load_stage_two_err:
	jmp $

