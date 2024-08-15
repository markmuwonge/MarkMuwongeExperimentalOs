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
	;dx holds drive number
	;push dx ;REF: pg.295 The Undocumented PC Second Edition Frankvan_Gilluwe
	;call disk_ext_present
	;pop dx
	;cmp ax, 1
	;jz post_disk_ext_check
	;jmp bootloader_err

post_disk_ext_check:
	push dx
	call correct_loaded_boot_sec
	pop dx
	cmp ax, 0
	jz bootloader_err

	push dx
	call load_stage_two
	pop dx
	cmp ax, 0
	jz bootloader_err

	;jump to stage2


bootloader_err:
	hlt
	jmp bootloader_err


include 'inc/buffer.inc'
;include 'inc/16/disk_ext_present.asm'
include 'inc/16/correct_loaded_boot_sec.asm'
include 'inc/16/load_stage_two.asm'