#define KERNEL_ELF_FILE_FIRST_SECTOR_LOAD_LOCATION 0x1000 //usable 'conventional memory' according to osdev memory map
#include "../inc/types.h"
#include "../inc/x86.h"
 
uint16_t global_hard_disk_controller_io_port_base_address; //https://stackoverflow.com/questions/14588767/where-in-memory-are-my-variables-stored-in-c

static int8_t get_kernel_elf_file_logical_sector_number();

void kernel_loader_main(uint16_t hard_disk_controller_io_port_base_address){ 
	global_hard_disk_controller_io_port_base_address = hard_disk_controller_io_port_base_address;
	
	int8_t kernel_elf_file_logical_sector_number = get_kernel_elf_file_logical_sector_number();
	if (kernel_elf_file_logical_sector_number == -1) goto error_occurred; 
	
	
	

	
	//
	//get sector number of kernel elf file 
	//can find a library to parse elf file
error_occurred:
	while (1){
		
	}
}

static int8_t get_kernel_elf_file_logical_sector_number(){ //https://stackoverflow.com/questions/558122/what-is-a-static-function-in-c
	int8_t kernel_elf_file_logical_sector_number = -1;
	
	//wait
	uint8_t data = io_byte_in(global_hard_disk_controller_io_port_base_address + 7);
	
	
	//can finda library to read in sector?
	// int kernelElfFileLogicalSectorNumber = -1;
	// int currentSectorNumber = 0;
	// int elfFileMagicNumbersEncountered = 0;
	
	// read_sector(KERNEL_ELF_FILE_FIRST_SECTOR_LOAD_LOCATION, currentSectorNumber);
	
	
	// return kernelElfFileLogicalSectorNumber;
	return kernel_elf_file_logical_sector_number;
}
