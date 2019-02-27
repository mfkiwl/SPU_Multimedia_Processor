#include <stdio.h>
#include <stdlib.h>
#include "assembler.h"

/*
 * Program reads, from a file passed to stdin, Cell
 * SPU Instructions and outputs to a file, the binary 
 * data associated with each instruction.
*/
int main() {
    int bytes_read; // Number of bytes read in current line
    char* instr;

    while(bytes_read) {
        /* Get Instructions */ 
        if((instr = getInstr(&bytes_read)) == (char *)-1) break;// EOF reached 

        /* Skip comments */
        if(instr[0] == '#') continue;

        /* Parse the read Instruction String and Output the Binary data */
        if(parse_line(instr)) {
            puts("Empty String!");
            free(instr);
            return EXIT_FAILURE;
        }
    }

    /*  */
    free(instr);
    
    if(!ferror(stdin)) return EXIT_FAILURE;  // If failure with file

    if(!feof(stdin)) return EXIT_SUCCESS;    // Make sure EOF was reached
    
    return EXIT_FAILURE;    
}