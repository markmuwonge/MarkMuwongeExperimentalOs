load_sectors_chs:
	pusha
	mov bp, sp
	

load_sectors_chs_routine:
	mov ah, 2

	mov bx, [bp + 16 + 4] ;# sectors to read
	mov al, bl

	mov bx, [bp + 16 + 12] ; cylinder
	mov ch, bl

	mov bx, [bp + 16 + 8] ; sector
	mov cl, bl

	mov bx, [bp + 16 + 10] ; head
	mov dh, bl

	mov bx, [bp + 16 + 2] ; drive
	mov dl, bl

	mov bx, [bp + 16 + 6] ;data buffer address

	
	int 0x13
	jc load_sectors_chs_err
	popa
	mov ax, 1
	jmp load_sectors_chs_err_end
	
load_sectors_chs_err:
	inc BYTE [load_sector_chs_fail_count]
	cmp BYTE [load_sector_chs_fail_count], 3
	jz load_sectors_chs_set_err_ret_val

	;reset drive REF: Ralf Brown's Interrupt List interrupt 13, ah=2
	push ax
	push dx
	mov ah, 0
	mov dx,  [bp + 16 + 2]
	int 0x13
	pop dx
	pop ax
	jc load_sectors_chs_set_err_ret_val
	jmp load_sectors_chs_routine

load_sectors_chs_set_err_ret_val:
	popa
	mov ax, 0
	
load_sectors_chs_err_end:
	ret

load_sector_chs_fail_count:
	db 0