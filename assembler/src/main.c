#include <stdio.h>
#include <stdlib.h>
#include "assembler.h"
#include "sort.h" 
#include "isa.h"

/*
 * Program reads, from a file passed to stdin, Cell
 * SPU ASM Instructions and, outputs to a file, the binary 
 * data in the format associated with each instruction.
*/
int main() {
    char *instr = (char *)malloc(MAX_INSTR_LEN); // Instruction String
    unsigned *bdata = NULL; // Binary Data 

    /* Sort Instruction Table */
    sort_instr();

    for(;;) {
        /* Get next Instruction Line */ 
        if((getInstr(instr, MAX_INSTR_LEN))) break; // EOF reached 

        /* Skip comments */
        if(instr[0] == '#') continue;

        /* Parse the obtained Instruction String */
        if(parse_line(instr, &bdata)) {
            puts("Empty String!");
            free(instr);
            return EXIT_FAILURE;
        }

        /* Output the Binary data */
        output_data(bdata);
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
