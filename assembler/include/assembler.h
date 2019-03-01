#ifndef ASSEMBLER_H
#define ASSEMBLER_H

/* Maximum number of characters in an Instruction Line */
#define MAX_INSTR_LEN 100
// TODO: FIGURE OUT HOW MUCH THIS SHOULD BE ^

/*
 * Parameter(s):
 *  - bytes_read: number of bytes read 
 *  - instr: The instruction read
 * 
 * Returns: 
 *  - 0: If line was read successfully 
 *  - 1: If failure or EOF
*/
int 
getInstr(char *instr, size_t size);

/*
 * Parameter(s):
 *  - instr: instruction line String
 * 
 * Returns: 
 *  - 0: Successfully parsed String
 *  - 1: Error
*/
int
parse_line(char *instr);

#endif /* ASSEMBLER_H */
