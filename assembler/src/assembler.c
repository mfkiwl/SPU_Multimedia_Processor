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
 *  - instr: The instruction read
 * 
 * Returns: 
 *  - 0: If line was read successfully 
 *  - 1: If failure or EOF
*/
int 
getInstr(char *instr, size_t size) {
    /* Read Instruction line from stdin. */
    if((getline(&instr, &size, stdin)) == EOF) return 1;

    return 0;
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
    char *token;

    /* Get Instruction name */
    if(!(token = strtok(instr, " "))) return 1; // Return Error if Empty String

    /* Search for Instruction Structure given the Insruction Name */
    /* Find Instruction */
    for(int i = 0; i < TOTAL_INSR; i++)
        printf("%d:%s\n", i+1, isa_instr[i].instr_name);
    /* Find Instruction Format given the Instruction Name */
    //switch(enum in instr table) {

    //}
    
    while((token = strtok(NULL, ", "))) {
       // printf("%s ", token);
    }

    return 0;
}
