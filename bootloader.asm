format binary
use16

include 'inc/constant.inc'

org BOOTLOADER_ORIGIN_ADDRESS



init:
	mov ax, 0
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov sp, ORIGIN_ADDRESS

	; ensure cs is 0 (bios may have changed it) - real mode: CS:0x07c0, IP:0x0000 == CS:0x0000, IP:0x7c00 
	jmp 0000:main

main:
	push dx ;REF: pg.295 The Undocumented PC Second Edition Frankvan_Gilluwe
	call disk_ext_present
	add sp, 2
	cmp ax, 0
	jz no_disk_ext
	jmp post_disk_ext_check
no_disk_ext:
	mov [DISK_EXT_PRESENT], al
post_disk_ext_check:
	push dx
	call correct_loaded_boot_sec
	add sp, 2
	cmp ax, 0
	jz bootloader_err

;TODO: load in root dir


bootloader_err:
	jmp $


include 'inc/buffer.inc'
include 'inc/16/disk_ext_present.asm'
include 'inc/16/correct_loaded_boot_sec.asm'


;BPB_RsvdSecCnt = 1
;BPB_NumFATs = 2
;BPB_FATSz16 = 3
;BPB_BytsPerSec = 512

;reservered - 1 sector
;fat - 6 sectors