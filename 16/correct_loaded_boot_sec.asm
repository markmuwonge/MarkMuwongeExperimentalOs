correct_loaded_boot_sec:
	;ensuring boot sector corresponds to detected hardware
	pusha
	mov bp, sp

	mov ah, 8
	mov dl, [bp + 16 + 2]
	push es
	int 0x13 ; REF: pg. 496, 504 The Undocumented PC Second Edition Frankvan_Gilluwe, Ralph Brown's interrupt list
	pop es
	jc _popa

	and cl, 00111111b; sector per track
	xor ch, ch ; FAT12 BPB_SecPerTrk value is 2 bytes
	mov [ORIGIN_ADDRESS + BPB_SecPerTrk_IDX], cx 

	inc dh ; REF: https://en.wikipedia.org/wiki/INT_13H#INT_13h_AH=08h:_Read_Drive_Parameters
	mov dl, dh
	xor dh, dh
	mov  [ORIGIN_ADDRESS + BPB_NumHeads_IDX], dx
_popa:
	popa
	jc correct_loaded_boot_sec_err
	mov ax,1
	jmp correct_loaded_boot_sec_end
correct_loaded_boot_sec_err:
	mov ax, 0
correct_loaded_boot_sec_end:
	ret



