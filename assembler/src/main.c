#include <stdio.h>
#include <stdlib.h>
#include "assembler.h"
#include "sort.h" 

/*
 * Program reads, from a file passed to stdin, Cell
 * SPU Instructions and outputs to a file, the binary 
 * data in the format associated with each instruction.
*/
int main() {
    size_t size = MAX_INSTR_LEN; // Maximum size of Instruction String
    char* instr =  instr = (char *) malloc(size + 1); // Instruction String (+1 for String null-terminator)
    /* Sort Instruction Array */
    sort_instr();

    for(;;) {
        /* Get next Instruction Line */ 
        if((getInstr(instr, size))) break; // EOF reached 

        /* Skip comments */
        if(instr[0] == '#') continue;

        /* Parse the read Instruction String and Output the Binary data */
        if(parse_line(instr)) {
            puts("Empty String!");
            free(instr);
            return EXIT_FAILURE;
        }
    }
    /* Free the instruction line buffer */
    free(instr);

    /* If End of File reached */
    if(feof(stdin)) 
        return EXIT_SUCCESS;
    else if(ferror(stdin))
        return EXIT_FAILURE;  
    
    return EXIT_FAILURE;
}