#REQUIRES mingw32-make, github.com/lordmilko/i6860elf-tools, Tiny C Compiler, Fasm, Trunc (Developer: bjorck)
BOCHS_DISK_NAME = 10MB.img
BOCHS_DISK_DIR = "C:\Users\mark\Documents\BOCHS\DISK"

KERNEL_C_SOURCE_FILES = $(wildcard 32-bit/code/c/kernel/*.c)
KERNEL_C_SOURCE_FILES += $(wildcard 32-bit/code/c/kernel/**/*.c)
KERNEL_C_OBJECT_FILES = $(KERNEL_C_SOURCE_FILES:.c=.o) #gets all the c source files with ext '.c' and substrings the ext of c source files to .o



SECTOR_SIZE = 512

BOCHS_DISK_SIZE_FINAL = 10485760

#####################S########################
all: clean dist/${BOCHS_DISK_NAME} release
#####################E########################

#####################S########################
clean:
	if exist dist rmdir /s /Q dist
	if exist $(BOCHS_DISK_DIR)\${BOCHS_DISK_NAME} del $(BOCHS_DISK_DIR)\${BOCHS_DISK_NAME}
	mkdir dist
#####################E########################

#####################S########################
dist/main.bin: main.asm
	fasm $< $@
	
%.o: %.c
	tcc -o $@ -c $^ 
	move $(subst /,\,${CURDIR}\$@) ${CURDIR}\dist
	
dist/kernel.elf: ${KERNEL_C_OBJECT_FILES} 
	${i686-elf-ld} -Ttext 0x9000 -e kernel_main $(subst /,\,$(addprefix ${CURDIR}\dist\, $(notdir $^))) -o $(subst /,\,${CURDIR}\$@)
	
dist/${BOCHS_DISK_NAME}: dist/main.bin dist/kernel.elf
	type NUL > $@
	
	@type $(subst /,\,${CURDIR}\$<) >> $(subst /,\,${CURDIR}\$@)
	
	$(call round_file_bytes_to_nearest_sector,$(subst /,\,${CURDIR}\$@))
	 
	@type $(subst /,\,${CURDIR}\$(word 2,$^)) >> $(subst /,\,${CURDIR}\$@)
	
	$(call round_file_bytes_to_nearest_sector,$(subst /,\,${CURDIR}\$@))
	
	trunc $(subst /,\,${CURDIR}\$@) ${BOCHS_DISK_SIZE_FINAL}
#####################E########################

#####################S########################
release: dist/${BOCHS_DISK_NAME}
	move $(subst /,\,${CURDIR}\$<) $(BOCHS_DISK_DIR)
	rmdir /s /Q dist
#####################E########################

#####################S########################
define round_file_bytes_to_nearest_sector
	powershell -command \
	"$$fileSize=(Get-Item -Path $(1)).length; \
	$$sectorSize=${SECTOR_SIZE}; \
	$$func={if ($$fileSize % $$sectorSize -eq 0){return 0}else{return $$sectorSize}}; \
	$$bytesRoundedUpToNearestSector=$$fileSize - $$fileSize % $$sectorSize + (& $$func); \
	trunc $(1) $$bytesRoundedUpToNearestSector"
endef
#####################E########################

#References
# https://stackoverflow.com/questions/3220277/what-do-the-makefile-symbols-and-mean
# https://unix.stackexchange.com/questions/579332/whats-the-difference-between-percent-vs-asterisk-star-makefile-prerequisite
# https://stackoverflow.com/questions/38116385/how-can-i-round-up-to-the-nearest-multiple-of-the-specified-number
# https://stackoverflow.com/questions/43051813/invoking-a-function-indirectly-via-a-variable-containing-the-function-name
# https://ss64.com/ps/syntax-scriptblock.html
# https://shellgeek.com/powershell-get-file-size/#:~:text=Use%20the%20Get%2DItem%20cmdlet,KB%2C%20and%20MB%20in%20PowerShell.
# https://til.hashrocket.com/posts/k3kjqxtppx-escape-dollar-sign-on-makefiles
# https://stackoverflow.com/questions/38086542/break-long-dependencies-in-makefile-into-several-lines
# https://superuser.com/questions/1080239/run-powershell-command-from-cmd
# https://coderwall.com/p/cezf6g/define-your-own-function-in-a-makefile
# https://stackoverflow.com/questions/59446839/get-filename-from-in-makefile