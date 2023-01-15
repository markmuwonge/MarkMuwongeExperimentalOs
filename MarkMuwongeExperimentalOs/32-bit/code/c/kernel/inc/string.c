#include "types.h"
uint32_t get_string_length(char* string){
	uint32_t length = 0;
	
	for (uint32_t i = 0; ;i++){
		
		char string_ascii_character_code = *(string + i);
		if (string_ascii_character_code != 0){
			length+=1; 
		}else{
			break;
		}
	}
	
	return length;
}