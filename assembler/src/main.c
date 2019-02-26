#include <stdio.h>
#include <stdlib.h>
#include "assembler.h"

/*
 * Program reads, from a file passed to stdin, Cell
 * SPU Instructions and outputs to a file, the binary 
 * data associated with each instruction.
*/
int main(int argc, char **argv) {
    /* Get Instructions */
    //while(!MAX_NUMBER_OF_INSTRUCTIONS) { //
        char* instr = getInstr();
    //}

    // Dont forget to free instr when done outputting all. 

    free(instr);
    return EXIT_SUCCESS;    
}