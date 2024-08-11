disk_ext_present:
   pusha
   mov bp, sp
   
   mov ah, 0x41
   mov dl, [bp + 16 + 2]
   mov bx, 0x55aa
   int 0x13
   popa
   jc disk_ext_present_n
   mov ax, 1
   jmp disk_ext_present_end
disk_ext_present_n:
	mov ax, 0
disk_ext_present_end:
	ret
