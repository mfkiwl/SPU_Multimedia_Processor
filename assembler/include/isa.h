#ifndef ISA_H
#define ISA_H

/* Total number of Instructions */
#define TOTAL_INSR 68

/* Instructin Formats */
typedef enum {
    RR,     // RR-Type
    RRR,    // RRR-Type
    RI7,    // RI7-Type
    RI10,   // RI10-Type
    RI16,   // RI16-Type
    RI18    // RI18-Type
} format;

/* ISA - Instruction Table */
typedef struct {
    /* Instruction format */
    const format f;
    /* Instruction Opcode */
    const unsigned op;
    /* Instruction Name */
    const char *instr_name; 
} isa;
extern isa isa_instr[TOTAL_INSR];

#endif /* ISA_H */
