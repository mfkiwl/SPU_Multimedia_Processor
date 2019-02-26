#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "assembler.h"
#include "isa.h"

/*
 * Details: Read entire line (Instruction & operands).
 * 
 * Returns: String: An Instruction
*/
char* getInstr() {
    size_t size = MAX_INSTR_LEN;                 // Maximum size of Instruction String
    char *instr = malloc(size * sizeof(char));   // Instruction String

    /* Read Instruction from stdin */
    if(getline(&instr, &size, stdin) == -1) {
        printf("File empty!");
        free(instr);
        exit(1);
    }

    return (char *)instr;
}
