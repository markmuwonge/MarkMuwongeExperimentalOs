#include "../inc/types.h"
#include "../inc/x86.h"
#include "../inc/string.h"
#include "../inc/constants.h"


static void print_string(char* string);
static uint16_t get_active_crt_controller_cursor_video_memory_character_offset(uint8_t active_crt_controller_cursor_position_low_byte, uint8_t active_crt_controller_cursor_position_high_byte );
static uint8_t get_active_crt_controller_cursor_position_low_byte();
static uint8_t get_active_crt_controller_cursor_position_high_byte();
static void select_crt_controller_internal_register(uint8_t register_number);
static uint16_t get_active_crt_controller_io_port_base_address();
static uint16_t get_active_crt_controller_data_io_port_address();
static uint16_t get_active_crt_controller_cursor_row_number(uint16_t active_crt_controller_cursor_video_memory_character_offset);
static uint16_t get_active_crt_controller_video_coloumn_count();
static uint8_t get_active_crt_controller_video_row_count();
static void clear_row(uint16_t active_crt_controller_cursor_row_number);
static char* get_row_pointer(uint16_t active_crt_controller_cursor_row_number);
static void clear_page();
static uint16_t get_total_number_of_characters_per_page();
static void move_active_crt_controller_cursor(uint8_t position_high_byte, uint8_t position_low_byte);

void print_line(char* message){
	
	print_string(message);
	
	uint16_t active_crt_controller_cursor_video_memory_character_offset = get_active_crt_controller_cursor_video_memory_character_offset(
																			get_active_crt_controller_cursor_position_low_byte(),
																			get_active_crt_controller_cursor_position_high_byte()
	);
	
	// check if cursor is on the last row - if it is dont move cursor to the next line, if it isn't move cursor to the next line after print
	if (get_active_crt_controller_video_row_count() != get_active_crt_controller_cursor_row_number(active_crt_controller_cursor_video_memory_character_offset) + 1){
			while (1){
				if (active_crt_controller_cursor_video_memory_character_offset% get_active_crt_controller_video_coloumn_count() != 0){
					active_crt_controller_cursor_video_memory_character_offset+=1;
				}
				else{
					move_active_crt_controller_cursor(active_crt_controller_cursor_video_memory_character_offset >> 8, active_crt_controller_cursor_video_memory_character_offset & 0xFF);
					break;
				}		
			}
	}
}

static void print_string(char* string){
	
	uint16_t active_crt_controller_cursor_video_memory_character_offset = get_active_crt_controller_cursor_video_memory_character_offset(
																			get_active_crt_controller_cursor_position_low_byte(),
																			get_active_crt_controller_cursor_position_high_byte()
	); 
	
	uint16_t active_crt_controller_cursor_row_number = get_active_crt_controller_cursor_row_number(active_crt_controller_cursor_video_memory_character_offset);
	
	// if the cursor is on the last row and not at the first column
	if ((active_crt_controller_cursor_row_number + 1) == get_active_crt_controller_video_row_count() && (active_crt_controller_cursor_video_memory_character_offset% get_active_crt_controller_video_coloumn_count()) != 0){	
		clear_page();
		move_active_crt_controller_cursor(0,0);
		active_crt_controller_cursor_video_memory_character_offset = 0;
		active_crt_controller_cursor_row_number = 0;
	}
	
	clear_row(active_crt_controller_cursor_row_number);
	
	char* row_pointer = get_row_pointer(active_crt_controller_cursor_row_number);
	
	uint16_t total_number_of_characters_per_line = get_active_crt_controller_video_coloumn_count(); 
	
	uint32_t string_length = get_string_length(string);
	
	if (string_length > total_number_of_characters_per_line){
		string_length = total_number_of_characters_per_line;
	}
	
	for (int i = 0; i < string_length; i++){
		*(row_pointer + (i * 2)) = *(string + i); //string character
		*((row_pointer + 1) + (i * 2)) = STANDARD_OUT_COLOUR_CODE;  //attribute/colour	
		
		move_active_crt_controller_cursor((active_crt_controller_cursor_video_memory_character_offset + i) >> 8, (active_crt_controller_cursor_video_memory_character_offset + i) & 0xFF);
	}
}

static uint16_t get_active_crt_controller_cursor_video_memory_character_offset(uint8_t active_crt_controller_cursor_position_low_byte, uint8_t active_crt_controller_cursor_position_high_byte ){
	// In teletype/text mode (mode 3) an on screen character is represented by 2 bytes in video memory (addressed starting at 0xB8000) - ascii code byte and attribute/colour byte  (cursor points only to character byte)
	uint16_t active_crt_controller_cursor_video_memory_character_offset = active_crt_controller_cursor_position_high_byte << 8; // combine cursor high & low 
	return active_crt_controller_cursor_video_memory_character_offset |= active_crt_controller_cursor_position_low_byte;
}

static uint8_t get_active_crt_controller_cursor_position_low_byte(){
	select_crt_controller_internal_register(15); 
	uint8_t active_crt_controller_cursor_position_low_byte = io_byte_in(get_active_crt_controller_data_io_port_address());
	return active_crt_controller_cursor_position_low_byte;
}

static uint8_t get_active_crt_controller_cursor_position_high_byte(){
	select_crt_controller_internal_register(14); 
	uint8_t active_crt_controller_cursor_position_high_byte = io_byte_in(get_active_crt_controller_data_io_port_address());
	return active_crt_controller_cursor_position_high_byte;
}

static void select_crt_controller_internal_register(uint8_t register_number){
	io_byte_out(get_active_crt_controller_io_port_base_address(), register_number);
}

static uint16_t get_active_crt_controller_io_port_base_address(){
	uint16_t* active_crt_controller_io_port_base_address_pointer = 0x463; 
	uint16_t active_crt_controller_io_port_base_address = *active_crt_controller_io_port_base_address_pointer; //crtc io port base address aka crtc index/address register
	return active_crt_controller_io_port_base_address;
}

static uint16_t get_active_crt_controller_data_io_port_address(){
	uint16_t active_crt_controller_data_io_port_address = get_active_crt_controller_io_port_base_address() + 1;
	return active_crt_controller_data_io_port_address;

}

static uint16_t get_active_crt_controller_cursor_row_number(uint16_t active_crt_controller_cursor_video_memory_character_offset){
	return active_crt_controller_cursor_video_memory_character_offset / get_active_crt_controller_video_coloumn_count(); //row numbers starting from 0
}

static uint16_t get_active_crt_controller_video_coloumn_count(){
	uint16_t* active_crt_controller_video_coloumn_count_pointer = 0x44A; 
	uint16_t active_crt_controller_video_coloumn_count = *active_crt_controller_video_coloumn_count_pointer; //number of characters that can fit on a column
	return active_crt_controller_video_coloumn_count;
}

static uint8_t get_active_crt_controller_video_row_count(){
	uint8_t* active_crt_controller_video_row_count_pointer = 0x484; 
	uint8_t active_crt_controller_video_row_count = *active_crt_controller_video_row_count_pointer; 
	return active_crt_controller_video_row_count + 1;
}

static void clear_row(uint16_t active_crt_controller_cursor_row_number){
	//row numbers starting from 0
	char* row_pointer = get_row_pointer(active_crt_controller_cursor_row_number);
	
	uint16_t total_number_of_characters_per_line = get_active_crt_controller_video_coloumn_count();
	
	for (int i = 0; i < total_number_of_characters_per_line; i++){
		*(row_pointer + (i * 2)) = SPACE_CHARACTER_ASCII_CODE; //space character
		*((row_pointer + 1) + (i * 2)) = STANDARD_OUT_COLOUR_CODE;  //attribute/colour
	}
}

static char* get_row_pointer(uint16_t active_crt_controller_cursor_row_number){
	return COLOURED_TELETYPE_VIDEO_MODE_CONTENT_MEMORY_ADDRESS + (active_crt_controller_cursor_row_number * (get_active_crt_controller_video_coloumn_count() * 2)); 
}

static void clear_page(){
	uint16_t total_number_of_characters_per_page = get_total_number_of_characters_per_page();
	for (int i = 0; i < total_number_of_characters_per_page; i++){
		char* pointer = COLOURED_TELETYPE_VIDEO_MODE_CONTENT_MEMORY_ADDRESS + (i * 2); 
		*pointer = SPACE_CHARACTER_ASCII_CODE; //space character
		pointer += 1;
		*pointer = STANDARD_OUT_COLOUR_CODE; //attribute/colour
	}
}

static uint16_t get_total_number_of_characters_per_page(){
	uint16_t total_number_of_characters_per_page = get_active_crt_controller_video_coloumn_count() * get_active_crt_controller_video_row_count();
	return total_number_of_characters_per_page;
}

static void move_active_crt_controller_cursor(uint8_t position_high_byte, uint8_t position_low_byte){
	select_crt_controller_internal_register(14);  //selecting CRTC 6845 cursor (offset from start of video ram area) high register 
	io_byte_out(get_active_crt_controller_data_io_port_address(), position_high_byte);
	
	select_crt_controller_internal_register(15);
	io_byte_out(get_active_crt_controller_data_io_port_address(), position_low_byte);
}

/* REFERENCES */
//the indispensable pc hardware book 3rd edition p.g. 1055, 1058, 1066, 1069, 1088, 1094, 1098
//the undocumented pc 2nd edition p.g. 260, 279, 486
//motorola 6845 datasheet p.g. 11