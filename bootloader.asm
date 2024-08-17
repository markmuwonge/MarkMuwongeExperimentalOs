format binary
use16

include 'inc/constant.inc'

org BOOTLOADER_ORIGIN_ADDRESS



init:
	sti ;disable hardware interrupts
	xor ax, ax
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov sp, ORIGIN_ADDRESS

	; ensure cs is 0 (bios may have changed it) - real mode: CS:0x07c0, IP:0x0000 == CS:0x0000, IP:0x7c00 
	jmp 0000:main

main:
	push dx
	call correct_loaded_boot_sec
	
	call load_stage_two
	pop dx

	jmp STAGE2_LOAD_ADDRESS


halt:
	hlt
	jmp halt


include 'inc/buffer.inc'
include 'inc/16/correct_loaded_boot_sec.asm'
include 'inc/16/load_stage_two.asm'