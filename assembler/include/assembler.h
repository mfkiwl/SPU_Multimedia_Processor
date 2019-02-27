#ifndef ASSEMBLER_H
#define ASSEMBLER_H

/* Maximum number of characters in an Instruction Line */
#define MAX_INSTR_LEN 100
// TODO: FIGURE OUT HOW MUCH THIS SHOULD BE ^

/*
 * Parameter(s):
 *  - bytes_read: number of bytes read 
 * 
 * Returns: 
 *  - String: An Instruction
*/
char* 
getInstr(int *bytes_read);

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
