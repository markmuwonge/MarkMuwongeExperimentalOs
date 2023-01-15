use16

;;;;;;;;;;;;;S;;;;;;;;;;;;;;;;;
CHECK_GRAPHICS_SUPPORT: ;check that the graphics adapter's 6845/6845 compatible CRTC (cathode ray tube controller) supports colour ref. the indispensable pc hardware book 3rd edition p.g. 1045/1046
	pusha
	
	mov ah, 0x12
	mov bl, 0x10
	int 0x10 ;ref. the indispensable pc hardware book 3rd edition p.g. 424/425
	cmp bh, 0
	je CHECK_GRAPHICS_SUPPORT_RETURN_ONE
	jmp CHECK_GRAPHICS_SUPPORT_RETURN_MINUS_ONE
CHECK_GRAPHICS_SUPPORT_RETURN_ONE:
	push 1
	jmp CHECK_GRAPHICS_SUPPORT_END
CHECK_GRAPHICS_SUPPORT_RETURN_MINUS_ONE:
	push -1
CHECK_GRAPHICS_SUPPORT_END:
	add sp, 2
	popa
	
	sub sp, 18
	pop ax
	add sp, 16
	
	ret
;;;;;;;;;;;;;E;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;S;;;;;;;;;;;;;;;;;
CLEAR_SCREEN:
	pusha
	
	mov ah, 0
	mov al, [0x449]  ;current video mode. ref. the undocumented pc 2nd edition p.g. 238, the indispensable pc hardware book 3rd edition p.g. 1081
	xor al, 00000000b ;clear display buffer while maintaining current video mode ref. the undocumented pc 2nd edition p.g. 396
	
	int 0x10
	
	
	
	popa
	
	ret
;;;;;;;;;;;;;E;;;;;;;;;;;;;;;;;