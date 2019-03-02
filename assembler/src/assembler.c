#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "assembler.h"
#include "isa.h"
#include "sort.h"

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
 * Details: Output the Instruction binary data to stdout
 * 
 * Parameter(s):
 *  - instr_data: Binary data to output
*/
void 
output_data(unsigned instr_data) {

}   

/* 
 * Details: Comparater function used for qsort and bsearch.
 * Compares the String Instructions names in the isa_instr table.
 * 
 * Parameter(s):
 *  - p1: Pointer to 1st isa Struct being compared
 *  - p2: Pointer to 2nd isa Struct being compared
 * 
 * Returns: 
 *  - 0: p1 == p2
 *  - < 0: The stopping character in p1 was less than the stopping character in p2
 *  - > 0: The stopping character in p1 was greater than the stopping character in p2
*/
int 
cmp(const void *p1, const void *p2) {
    return strcmp(((isa *)p1)->instr_name, ((isa *)p2)->instr_name);
}

/*
 * Details: Read the Operand String, convert them
 * to unsigned integer and fill the necessary values 
 * needed for the RR format Instruction.
*/
static void
RR_proc(isa *instr_ptr) {
    char *token;
    
    /* Take care of special cases */
    if(!strcmp(instr_ptr->instr_name, "bi")) {
        /* Read Operand RA */
        if(!(token = strtok(NULL, " ,"))) return;   
        instr_ptr->bf.RR_bf.RA = (unsigned)strtol(token, NULL, 0);      

        return;
    } else if(!strcmp(instr_ptr->instr_name, "stop") ||
              !strcmp(instr_ptr->instr_name, "lnop") ||
              !strcmp(instr_ptr->instr_name, "nop")) {
        return; // These Instructions does not take any arguments
    }

    /* Read Operand RT */
    if(!(token = strtok(NULL, " ,"))) return;   
    instr_ptr->bf.RR_bf.RT = (unsigned)strtol(token, NULL, 0);

    /* Read Operand RA */
    if(!(token = strtok(NULL, " ,"))) return;   
    instr_ptr->bf.RR_bf.RA = (unsigned)strtol(token, NULL, 0);

    /* Read Operand RB */
    if(!(token = strtok(NULL, " ,"))) return;   
    instr_ptr->bf.RR_bf.RB = (unsigned)strtol(token, NULL, 0);

    printf("0x%X", instr_ptr->bf.instr);
}

/*
 * Details: Read the Operand String, convert them
 * to unsigned integer and fill the necessary values 
 * needed for the RRR format Instruction.
*/
static void
RRR_proc(isa *instr_ptr) {
    char *token;

    /* Read Operand RT */
    if(!(token = strtok(NULL, " ,"))) return;   
    instr_ptr->bf.RRR_bf.RT = (unsigned)strtol(token, NULL, 0);

    /* Read Operand RA */
    if(!(token = strtok(NULL, " ,"))) return;   
    instr_ptr->bf.RRR_bf.RA = (unsigned)strtol(token, NULL, 0);

    /* Read Operand RB */
    if(!(token = strtok(NULL, " ,"))) return;   
    instr_ptr->bf.RRR_bf.RB = (unsigned)strtol(token, NULL, 0);

    /* Read Operand RC */
    if(!(token = strtok(NULL, " ,"))) return;   
    instr_ptr->bf.RRR_bf.RC = (unsigned)strtol(token, NULL, 0);

    printf("0x%X", instr_ptr->bf.instr);
}

/*
 * Details: Read the Operand String, convert them
 * to unsigned integer and fill the necessary values 
 * needed for the RI7 format Instruction.
*/
static void
RI7_proc(isa *instr_ptr) {
    char *token;

    /* Read Operand RT */
    if(!(token = strtok(NULL, " ,"))) return;   
    instr_ptr->bf.RI7_bf.RT = (unsigned)strtol(token, NULL, 0);

    /* Read Operand RA */
    if(!(token = strtok(NULL, " ,"))) return;   
    instr_ptr->bf.RI7_bf.RA = (unsigned)strtol(token, NULL, 0);

    /* Read Operand I7 */
    if(!(token = strtok(NULL, " ,"))) return;   
    instr_ptr->bf.RI7_bf.RI7 = (unsigned)strtol(token, NULL, 0);

    printf("0x%X", instr_ptr->bf.instr);
}

/*
 * Details: Read the Operand String, convert them
 * to unsigned integer and fill the necessary values 
 * needed for the RI10 format Instruction.
*/
static void
RI10_proc(isa *instr_ptr) {
    char *token;

    /* Take care of special cases */
    if(!strcmp(instr_ptr->instr_name, "lqd") || 
       !strcmp(instr_ptr->instr_name, "stqd")) {
        /* Read Operand RT */
        if(!(token = strtok(NULL, " ,"))) return;   
        instr_ptr->bf.RI10_bf.RT = (unsigned)strtol(token, NULL, 0);

        /* Read Operand I10 */
        if(!(token = strtok(NULL, " ,"))) return;   
        instr_ptr->bf.RI10_bf.RI10 = (unsigned)strtol(token, NULL, 0);

        /* Read Operand RA */
        if(!(token = strtok(NULL, " ,()"))) return;   
        instr_ptr->bf.RI10_bf.RA = (unsigned)strtol(token, NULL, 0);        

        return;
    }

    /* Read Operand RT */
    if(!(token = strtok(NULL, " ,"))) return;   
    instr_ptr->bf.RI10_bf.RT = (unsigned)strtol(token, NULL, 0);

    /* Read Operand RA */
    if(!(token = strtok(NULL, " ,"))) return;   
    instr_ptr->bf.RI10_bf.RA = (unsigned)strtol(token, NULL, 0);

    /* Read Operand I10 */
    if(!(token = strtok(NULL, " ,"))) return;   
    instr_ptr->bf.RI10_bf.RI10 = (unsigned)strtol(token, NULL, 0);

    printf("0x%X", instr_ptr->bf.instr);
}

/*
 * Details: Read the Operand String, convert them
 * to unsigned integer and fill the necessary values 
 * needed for the RI16 format Instruction.
*/
static void
RI16_proc(isa *instr_ptr) {
    char *token;

    /* Take care of special cases */
    if(!strcmp(instr_ptr->instr_name, "br") || 
       !strcmp(instr_ptr->instr_name, "bra")) {
        /* Read Operand I16 */
        if(!(token = strtok(NULL, " ,"))) return;   
        instr_ptr->bf.RI16_bf.RI16 = (unsigned)strtol(token, NULL, 0);

        return;
    }

    /* Read Operand RT */
    if(!(token = strtok(NULL, " ,"))) return;   
    instr_ptr->bf.RI16_bf.RT = (unsigned)strtol(token, NULL, 0);

    /* Read Operand I16 */
    if(!(token = strtok(NULL, " ,"))) return;   
    instr_ptr->bf.RI16_bf.RI16 = (unsigned)strtol(token, NULL, 0);

    printf("0x%X", instr_ptr->bf.instr);
}

/*
 * Details: Read the Operand String, convert them
 * to unsigned integer and fill the necessary values 
 * needed for the RI18 format Instruction.
*/
static void
RI18_proc(isa *instr_ptr) {
    char *token;
    
    /* Read Operand RT */
    if(!(token = strtok(NULL, " ,"))) return;   
    instr_ptr->bf.RI18_bf.RT = (unsigned)strtol(token, NULL, 0);

    /* Read Operand I18 */
    if(!(token = strtok(NULL, " ,"))) return;   
    instr_ptr->bf.RI18_bf.RI18 = (unsigned)strtol(token, NULL, 0);

    printf("0x%X", instr_ptr->bf.instr);
}

/*
 * Details: Parses the instrution line retrieved using strtok
 * and outputs the binary code representing it.
 * 
 * Parameter(s):
 *  - instr: instruction line String
 *  - dbata: Binary data to output
 * 
 * Returns: 
 *  - 0: Successfully parsed String
 *  - 1: Error
*/
int
parse_line(char *instr, unsigned *bdata) {
    char *token;
    /*
        Intermediary isa Structure to hold the name 
        of the Instruction during search
    */
    isa target; 
    isa *instr_ptr; // Points to Instruction Structure currently being processed

    /* Get Instruction name */
    if(!(token = strtok(instr, " "))) return 1; // Return Error if Empty String
    
    /* Search for Instruction Structure given the Insruction Name */
    /* Find Instruction */
    target.instr_name = token;
    instr_ptr = (isa *)bsearch(&target, isa_instr, TOTAL_INSTR, 
                sizeof(isa), cmp);

    /* Get Instruction Operands accodring to Instruction format */
    switch(instr_ptr->f) {
        case RR:
            RR_proc(instr_ptr);
            break;
        case RRR:
            RRR_proc(instr_ptr);
            break;
        case RI7:
            RI7_proc(instr_ptr);
            break;
        case RI10:
            RI10_proc(instr_ptr);
            break;
        case RI16:
            RI16_proc(instr_ptr);
            break;
        case RI18:
            RI18_proc(instr_ptr);
            break;
    }

    return 0;
}
