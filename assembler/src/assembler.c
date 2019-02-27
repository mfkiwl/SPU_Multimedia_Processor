#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "assembler.h"
#include "isa.h"

/*
 * Details: Read one line (Instruction & operands) using getline().
 * 
 * Parameter(s):
 *  - bytes_read: number of bytes read 
 * Returns: 
 *  - String: An Instruction
 *  - -1: If EOF reached
*/
char* 
getInstr(int *bytes_read) {
    size_t size = MAX_INSTR_LEN;      // Maximum size of Instruction String
    char *instr = malloc(size + 1);   // Instruction String (+1 for String null-terminator)

    /* Read Instruction line from stdin. */
    if((*bytes_read = getline(&instr, &size, stdin)) == -1) return (char *)-1; 

    return (char *)instr;
}

/*
 * Details:
 * 
 * Parameter(s):
 *  -
*/
static void 
output_data() {

}   

/*
 * Details: Parses the instrution line retrieved using strtok
 * and outputs the binary code representing it.
 * 
 * Parameter(s):
 *  - instr: instruction line String
 * 
 * Returns: 
 *  - 0: Successfully parsed String
 *  - 1: Error
*/
int
parse_line(char *instr) {
    char *instr_name;   // Instruction name 

    /* Get Instruction name */
    if(!(instr_name = strtok(instr, " "))) return 1; // Empty String

    //printf("instr_name: %s\n", instr_name);
    
    //while(strtok) {
       
   // }

   return 0;
}
