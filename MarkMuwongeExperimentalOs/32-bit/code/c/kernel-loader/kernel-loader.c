#define KERNEL_ELF_FILE_FIRST_SECTOR_LOAD_LOCATION 0x1000 //usable 'conventional memory' according to osdev memory map

int global_drive_id;

void kernel_loader_main(int driveId){
	global_drive_id = driveId;
	//find the second ELF magic number in the image (the kernel elf file)
	

	
	// int kernelElfFileLogicalSectorNumber = get_kernel_elf_file_logical_sector_number();
	// if (kernelElfFileLogicalSectorNumber == -1) goto error_occurred;
	//
	//get sector number of kernel elf file 
	//can find a library to parse elf file
error_occurred:
	while (1){
		
	}
}

// int get_kernel_elf_file_logical_sector_number(){
	//can finda library to read in sector?
	// int kernelElfFileLogicalSectorNumber = -1;
	// int currentSectorNumber = 0;
	// int elfFileMagicNumbersEncountered = 0;
	
	// read_sector(KERNEL_ELF_FILE_FIRST_SECTOR_LOAD_LOCATION, currentSectorNumber);
	
	
	// return kernelElfFileLogicalSectorNumber;
// }
