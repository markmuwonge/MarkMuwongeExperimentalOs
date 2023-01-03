#REQUIRES mingw32-make, github.com/lordmilko/i6860elf-tools, Tiny C Compiler, Fasm
BOCHS_DISK_NAME = 10MB.img
BOCHS_DISK_DIR = "C:\Users\mark\Documents\BOCHS\DISK"
KERNEL_LOADER_C_SOURCE_FILES = $(wildcard 32-bit/code/c/kernel-loader/*.c)
KERNEL_LOADER_C_OBJECT_FILES = $(KERNEL_LOADER_C_SOURCE_FILES:.c=.o) #gets all the c source files with ext '.c' and substrings the ext of c source files to .o
PRE_KERNEL_LOADER_BOCHS_DISK_SIZE_LENGTH = 2048
BOCHS_DISK_SIZE_FINAL = 10485760
#####################S########################
all: preclean dist/${BOCHS_DISK_NAME} release
#####################E########################

#####################S########################
preclean:
	if exist dist rmdir /s /Q dist
	if exist $(BOCHS_DISK_DIR)\${BOCHS_DISK_NAME} del $(BOCHS_DISK_DIR)\${BOCHS_DISK_NAME}
	mkdir dist
#####################E########################

#####################S########################
dist/main.bin: main.asm
	fasm $< $@
	
32-bit/code/c/kernel-loader/%.o: 32-bit/code/c/kernel-loader/%.c
	tcc -o $@ -c $^ 
	move $(subst /,\,${CURDIR}\$@) ${CURDIR}\dist
	
dist/kernel-loader.elf: ${KERNEL_LOADER_C_OBJECT_FILES}
	${i686-elf-ld} -Ttext 0x9000 -e kernel_loader_main $(subst /,\,$(subst 32-bit/code/c/kernel-loader/,${CURDIR}\dist\,$^)) -o $(subst /,\,${CURDIR}\$@)
	
dist/${BOCHS_DISK_NAME}: dist/main.bin dist/kernel-loader.elf
	type NUL > $@
	@type $(subst /,\,${CURDIR}\$<) >> $(subst /,\,${CURDIR}\$@)
	trunc $(subst /,\,${CURDIR}\$@) ${PRE_KERNEL_LOADER_BOCHS_DISK_SIZE_LENGTH}
	@type $(subst /,\,${CURDIR}\$(word 2,$^)) >> $(subst /,\,${CURDIR}\$@)
	trunc $(subst /,\,${CURDIR}\$@) ${BOCHS_DISK_SIZE_FINAL}
	
#####################E########################

#####################S########################
release: dist/${BOCHS_DISK_NAME}
	move $(subst /,\,${CURDIR}\$<) $(BOCHS_DISK_DIR)
	rmdir /s /Q dist
#####################E########################


#References
# https://stackoverflow.com/questions/3220277/what-do-the-makefile-symbols-and-mean
# https://unix.stackexchange.com/questions/579332/whats-the-difference-between-percent-vs-asterisk-star-makefile-prerequisite