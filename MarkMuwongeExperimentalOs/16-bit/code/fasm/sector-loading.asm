use16
;;;;;;;;;;;;;S;;;;;;;;;;;;;;;;;
DISK_EXTENSIONS_PRESENT:
	pusha
	
	mov bp, sp
	
	mov [DRIVE_ID], dl
	mov ah, 0x41
	mov bx, 0x55aa
	int 0x13
	jc TEST_DISK_ENTENSION_RETURN_ZERO
	jmp TEST_DISK_ENTENSION_RETURN_ONE
TEST_DISK_ENTENSION_RETURN_ZERO:
	push 0
	jmp TEST_DISK_ENTENSION_END
TEST_DISK_ENTENSION_RETURN_ONE:
	push 1
TEST_DISK_ENTENSION_END:
	add sp, 2
	popa
	
	sub sp, 18 
	pop ax
	add sp, 16
	
	
	ret
;;;;;;;;;;;;;E;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;S;;;;;;;;;;;;;;;;;
LOAD_SECTORS_EXTENDED:
	pushad
	mov bp, sp
	
	mov dl, [DRIVE_ID] 
	mov si, DISK_ADDRESS_PACKET
	mov word [si], 0x10
	
	mov ax, [bp + 32 + 2] ;number of sectors
	mov word [si + 2], ax
	
	mov ax, [bp + 32 + 4] ;destination offset start
	mov word [si + 4], ax
	
	mov ax, [bp + 32 + 6] ;destination segment start
	mov word [si + 6], ax
	
	mov ax, [bp + 32 + 8] ;low 4 bytes of starting logical sector
	movzx eax, ax
	mov dword [si + 8], eax
	
	mov dword [si + 12], 0 ;high 4 bytes of starting logical sector
	
	mov ah, 0x42
	int 0x13
	popad
	jc LOAD_SECTORS_EXTENDED_RETURN_MINUS_ONE
	jmp LOAD_SECTORS_EXTENDED_RETURN_ZERO
LOAD_SECTORS_EXTENDED_RETURN_MINUS_ONE:
	mov ax, -1
	jmp LOAD_SECTORS_EXTENDED_END
LOAD_SECTORS_EXTENDED_RETURN_ZERO:
	mov ax, 0
LOAD_SECTORS_EXTENDED_END:
	ret
;;;;;;;;;;;;;E;;;;;;;;;;;;;;;;;


