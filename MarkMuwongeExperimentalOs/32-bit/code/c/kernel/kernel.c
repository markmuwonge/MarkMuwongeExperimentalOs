int kernel_main(){
	//organize memory space -
	//move memory map to first byte in memory (how to know when memory map has finished? - go back and put a notable value like 0x99 following the final byte of the memory map?)
	//after memory the  global descriptor table should follow
	//set up and load interrupt descriptor table after global descriptor table
	
	while(1){}
	
	
	return 0;
}

// #define KERNEL_ELF_FILE_FIRST_SECTOR_LOAD_LOCATION 0x1000 //usable 'conventional memory' according to osdev memory map
// #define DISK_SECTOR_SIZE_IN_BYTES 512

// #include "../inc/types.h"
// #include "../inc/x86.h"
 
// uint16_t global_hard_disk_controller_io_port_base_address; //https://stackoverflow.com/questions/14588767/where-in-memory-are-my-variables-stored-in-c

// static int8_t get_kernel_elf_file_logical_sector_number();
// void wait_for_hard_disk_controller_ready_signal();

// void kernel_loader_main(uint16_t hard_disk_controller_io_port_base_address){ 
	// global_hard_disk_controller_io_port_base_address = hard_disk_controller_io_port_base_address;
	
	// int8_t kernel_elf_file_logical_sector_number = get_kernel_elf_file_logical_sector_number();
	// if (kernel_elf_file_logical_sector_number == -1) goto error_occurred; 
	
	
	

	
	
	// get sector number of kernel elf file 
	// can find a library to parse elf file
// error_occurred:
	// while (1){
		
	// }	

// }


// static int8_t get_kernel_elf_file_logical_sector_number(){ //https://stackoverflow.com/questions/558122/what-is-a-static-function-in-c
	// int8_t kernel_elf_file_logical_sector_number = -1;
	// uint32_t logical_sector_number_to_check = 0; //logical sector number/Logical Block Address to check
	// number of elf headers passed ( pass the first on which is kernel loader , the next one is the kernel )
	// wait_for_hard_disk_controller_ready_signal();
	
	// io_byte_out(global_hard_disk_controller_io_port_base_address + 2, 1);  //Specify want 1 sector from drive connected to 1st ata/ide controller (src. the undocumented pc 2nd edition p.g. 632)
	// io_byte_out(global_hard_disk_controller_io_port_base_address + 3, logical_sector_number_to_check); //;specify low 8 bits of logical Block Address (src. the undocumented pc 2nd edition p.g. 632)
	// io_byte_out(global_hard_disk_controller_io_port_base_address + 4, logical_sector_number_to_check >> 8 ); //bits 8-15 of of LBA (src. the undocumented pc 2nd edition p.g. 632)
	// io_byte_out(global_hard_disk_controller_io_port_base_address + 5, logical_sector_number_to_check >> 0x10 ); // ;bits 16-23 of of LBA (src. the undocumented pc 2nd edition p.g. 633)
	// io_byte_out(global_hard_disk_controller_io_port_base_address + 6, (logical_sector_number_to_check >> 0x18) | 0xE0); //;bits 24-27 of LBA take up bits 0-3 of register at port 0x1F6. bits 4-7 of register 0xE for master drive or 0xF for slave (src. the undocumented pc 2nd edition p.g. 634, IDE CABLE - NOTE THE THREE INTERFACES - 1 to connecto motherboard, 1 to master drive and 1 optionally for the slave drive. Look at 1f6 register - can toggle bit 6 whether to use CHS addressing when set to zero or LBA when set to 1 src. The indispensable PC Hardware Book edition 3 p.g. 891 )
	// io_byte_out(global_hard_disk_controller_io_port_base_address + 7, 0x20); //read sectors command (src. the undocumented pc 2nd edition p.g. 636)
	
	// wait_for_hard_disk_controller_ready_signal();
	
	// io_in_four_byte_to_address(global_hard_disk_controller_io_port_base_address, KERNEL_ELF_FILE_FIRST_SECTOR_LOAD_LOCATION, DISK_SECTOR_SIZE_IN_BYTES /4); //note - insl reads 4 bytes at a time
	
	
		
	// return kernel_elf_file_logical_sector_number;
// }

// void wait_for_hard_disk_controller_ready_signal(){
	// wait for ready signal from hard disk controller (i.e. that it isn't currently preparing to send/receive data)
	// hard disk controller io port base address + 7 for the command/status register of the hard disks ata/dide controller (whether it's command or status depends on whether reading or writing to it) 
	// in this case it acts as a status register due to in instruction src. (src. the undocumented pc 2nd edition p.g. 624)
	// ;Drive ready has bit 6 set in the return value of io_byte_in. Bitwise and the return data value with 0xC0 and ensure that the result is 0x40...
	// ...- signifies that the controller isn't busy and drive is ready to respond to commands (src. the undocumented pc 2nd edition p.g. 634)
	// while ((io_byte_in(global_hard_disk_controller_io_port_base_address + 7) & 0xC0) != 0x40){
		
	// }
// }




