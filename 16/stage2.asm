format binary
use16

include 'inc/constant.inc'



stage_two_main:
;check if all sectors relating to stage 2 have been loaded - this one is the first one
	nop
	nop
	nop
	nop
	nop
	nop
	hlt
	jmp stage_two_main