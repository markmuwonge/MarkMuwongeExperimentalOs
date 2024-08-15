disk_ext_present:
   pusha
   mov bp, sp
   
   mov ah, 0x41
   mov dl, [bp + 16 + 2]
   mov bx, 0x55aa
   int 0x13
   popa
   xor ax, ax
   jc disk_ext_present_end
   inc ax
disk_ext_present_end:
	ret
