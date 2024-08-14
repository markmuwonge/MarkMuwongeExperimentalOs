lba_to_chs:
	pusha
	mov bp, sp

	xor dx, dx
	mov ax, [bp + 16 + 2] ;lba
	div WORD [ORIGIN_ADDRESS+BPB_SecPerTrk_IDX]
	mov [lba_to_chs_TEMP], ax
	inc dx;
	mov [lba_to_chs_SECTOR], dx 

	xor dx, dx
	mov ax, [lba_to_chs_TEMP]
	div WORD [ORIGIN_ADDRESS+BPB_NumHeads_IDX]
	mov [lba_to_chs_HEAD], dx
	mov [lba_to_chs_CYLINDER], ax
	popa

	;floppy - 2 heads, 80 cylinders/tracks, 18 sectors per cylinder; 8 bits is enough high order byte will be 0 for the 3 registers below
	mov ax, [lba_to_chs_CYLINDER]
	mov bx, [lba_to_chs_HEAD]
	mov cx, [lba_to_chs_SECTOR]
	ret

lba_to_chs_TEMP:
	dw 0x90
lba_to_chs_SECTOR:
	dw 0x90
lba_to_chs_HEAD:
	dw 0x90
lba_to_chs_CYLINDER:
	dw 0x90

;Ref https://wiki.osdev.org/Disk_access_using_the_BIOS_(INT_13h)