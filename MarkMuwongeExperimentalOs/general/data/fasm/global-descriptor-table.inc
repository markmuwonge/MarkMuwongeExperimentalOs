GLOBAL_DESCRIPTOR_TABLE_START:
	dq 0 ;null entry
GLOBAL_DESCRIPTOR_TABLE_CODE_SEGMENT_DESCRIPTOR:
	;LIMIT 		 - 0xFFFFF
	;BASE  		 - 0x00000000
	;ACCESS BYTE - Present Bit (1), Descriptor Privilege Level 2-Bit (00), Descriptor Type Bit (1), Executable Bit (1), Conforming Bit (0), Readable Bit (1), Accessed Bit (0)
	;FLAGS 		 - Granularity Flag Bit (1), Size Flag Bit (1), Long-Mode Code Flag Bit (0), Reserved (0)

	dw 0xFFFF ;limit 0-15 (2 bytes)
	dw 0 ;base 16-31 (2 bytes)
	db 0 ;base 32-39 (1 byte)
	db 10011010b;access byte 40-47 (1 byte)
	; db 1111b ;limit 48-51 (4 bits) joined with 4 bit flags -comment out
	; db 1100b ;flags 52-55 (4 bits) joined with 4 bit limit -comment out
	db 11001111b
	db 0 ;base 56-63 (1 byte)
GLOBAL_DESCRIPTOR_TABLE_DATA_SEGMENT_DESCRIPTOR:
	;LIMIT 		 - 0xFFFFF
	;BASE  		 - 0x00000000
	;ACCESS BYTE - Present Bit (1), Descriptor Privilege Level 2-Bit (00), Descriptor Type Bit (1), Executable Bit (0), Direction Bit (0), Writable Bit (1), Accessed Bit (0)
	;FLAGS 		 - Granularity Flag Bit (1), Size Flag Bit (1), Long-Mode Code Flag Bit (0), Reserved (0)
	
	dw 0xFFFF ;limit 0-15 (2 bytes)
	dw 0 ;base 16-31 (2 bytes)
	db 0 ;base 32-39 (1 byte)
	db 10010010b;access byte 40-47 (1 byte)
	; db 1111b ;limit 48-51 (4 bits) joined with 4 bit flags -comment out
	; db 1100b ;flags 52-55 (4 bits) joined with 4 bit limit -comment out
	db 11001111b
	db 0 ;base 56-63 (1 byte)
GLOBAL_DESCRIPTOR_TABLE_END:

GLOBAL_DESCRIPTOR_TABLE_DESCRIPTOR:
	dw GLOBAL_DESCRIPTOR_TABLE_END - GLOBAL_DESCRIPTOR_TABLE_START - 1 ;size 
	dd GLOBAL_DESCRIPTOR_TABLE_START ;start address
