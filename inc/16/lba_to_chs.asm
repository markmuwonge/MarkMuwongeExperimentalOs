lba_to_chs:
	pusha
	mov bp, sp

	xor dx, dx
	mov ax, [bp + 16 + 2] ;lba
	div WORD [ORIGIN_ADDRESS+BPB_SecPerTrk_IDX]

	push ax ; ;lba_to_chs_TEMP (bp-2)
	inc dx;
	push dx; lba_to_chs_SECTOR (bp-4)

	xor dx, dx
	mov ax, [bp - 2] ;lba_to_chs_TEMP
	div WORD [ORIGIN_ADDRESS+BPB_NumHeads_IDX]
	push dx ;lba_to_chs_HEAD (bp-6)
	push ax ; lba_to_chs_CYLINDER (bp-8)

	add sp, 8
	popa
	sub sp, 24

	;floppy - 2 heads, 80 cylinders/tracks, 18 sectors per cylinder; 8 bits is enough high order byte will be 0 for the 3 registers below
	pop ax ;lba_to_chs_CYLINDER
	pop bx ;lba_to_chs_HEAD
	pop cx ;lba_to_chs_SECTOR
	add sp,18
	ret


;Ref https://wiki.osdev.org/Disk_access_using_the_BIOS_(INT_13h)