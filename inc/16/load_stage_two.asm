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
	cmp ax, 0
	jz load_stage_two_err

	;find stage2.bin in root dir
	push WORD SECTOR_LOADING_BUFFER_ADDRESS
	push WORD load_stage_two_taget_file_name
	call file_exists_in_root_directory_sector
	add sp, 4
	cmp ax, 0
	jz root_dir_file_name_not_found
	jmp root_dir_file_name_found

root_dir_file_name_not_found:
	inc BYTE [ROOT_DIR_SECTOR_NUMBER]
	jmp load_stage_two_find_loop

root_dir_file_name_found:
	;check fat (optional) - really only need to load first sector of stage 2, if it spans more than 1 sector let stage 2 load it
	;get stage2 sector
	;load stage 2 sector at


	popa
	mov ax,1
	jmp load_stage_two_end
load_stage_two_err:
	popa
	xor ax, ax


load_stage_two_end:
	ret

include 'inc/16/set_root_directory_sector_number.asm'
include 'inc/16/set_root_directory_size_in_sectors.asm'
include 'inc/16/lba_to_chs.asm'
include 'inc/16/load_sectors_chs.asm'
include 'inc/16/file_exists_in_root_directory_sector.asm'


load_stage_two_taget_file_name: db 'STAGE2  BIN'

