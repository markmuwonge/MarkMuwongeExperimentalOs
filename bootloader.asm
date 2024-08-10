format binary
use16

include 'inc/constant.inc'

org ORIGIN_ADDRESS + 62 ;the bootloader code begins at offset 62 of the FAT12 image

init:
	mov ax, 0
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov sp, ORIGIN_ADDRESS

	; ensure cs is 0 (bios may have changed it) - real mode: CS:0x07c0, IP:0x0000 == CS:0x0000, IP:0x7c00 
	push es
	push main
	retf

main:
	jmp main


