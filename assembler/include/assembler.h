#ifndef ASSEMBLER_H
#define ASSEMBLER_H

/* Maximum number of characters in an Instruction Line */
#define MAX_INSTR_LEN 35

/*
 * Parameter(s):
 *  - instr: The instruction read
 *  - size: number of bytes to read 
 * 
 * Returns: 
 *  - 0: If line was read successfully 
 *  - 1: If failure or EOF
*/
int 
getInstr(char *instr, size_t size);

/* 
 * Parameter(s):
 *  - p1: Pointer to 1st parameter being compared
 *  - p2: Pointer to 2nd parameter being compared
 * 
 * Returns: 
 *  - 0: p1 == p2
 *  - < 0: The stopping character in p1 was less than the stopping character in p2
 *  - > 0: The stopping character in p1 was greater than the stopping character in p2
*/
int 
cmp(const void *p1, const void *p2);

/*
 * Parameter(s):
 *  - instr: instruction line String
 *  - dbata: Binary data to output
 * 
 * Returns: 
 *  - 0: Successfully parsed String
 *  - 1: Error
*/
int
parse_line(char *instr, unsigned **dbata);

/*
 * Details: Output the Instruction binary data to stdout
 * 
 * Parameter(s):
 *  - instr_data: Instruction data to be output
*/
void 
output_data(unsigned *instr_data);

#endif /* ASSEMBLER_H */
