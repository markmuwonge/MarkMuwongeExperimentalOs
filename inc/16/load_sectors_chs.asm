load_sectors_chs:
	pusha
	mov bp, sp
	
	push 0 ;load_sector_chs_fail_count

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
	jc load_sectors_chs_half_err
	
	add sp, 2
	popa
	jmp load_sectors_chs_end
	
load_sectors_chs_half_err:
	inc WORD [bp - 2]
	cmp WORD [bp - 2], 3
	jz load_sectors_chs_err

	;reset drive REF: Ralf Brown's Interrupt List interrupt 13, ah=2
	push ax
	push dx
	xor ah, ah
	mov dx,  [bp + 16 + 2]
	int 0x13
	pop dx
	pop ax
	jc load_sectors_chs_err
	jmp load_sectors_chs_routine


	
load_sectors_chs_end:
	ret

load_sectors_chs_err:
	jmp $