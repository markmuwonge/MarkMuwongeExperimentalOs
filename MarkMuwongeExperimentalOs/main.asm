format binary
include 'general/data/fasm/symbolic-constants.inc'
org ORIGIN_ADDRESS
use16

include '16-bit/code/fasm/real-mode-stage-one.asm'
include '16-bit/data/fasm/sector-loading-memory-locations.inc'
include '16-bit/code/fasm/sector-loading.asm'

times (SECTOR_SIZE - 2)-($-$$) db 0x0 ;end of logical sector 0

dw BOOT_SECTOR_MAGIC_NUMBER
include '16-bit/code/fasm/real-mode-stage-two.asm'
include '16-bit/code/fasm/memory-map.asm'
include '16-bit/code/fasm/a20-line.asm'
include '16-bit/code/fasm/kernel-loader.asm'
include 'general/data/fasm/global-descriptor-table.inc'
include '16-bit/data/fasm/kernel-loader-memory-locations.inc'

use32
include '32-bit/code/fasm/protected-mode-stage-one.asm'