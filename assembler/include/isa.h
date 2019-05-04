#ifndef ISA_H
#define ISA_H

/* Total number of Instructions */
#define TOTAL_INSTR 68

/* Instructin Formats */
typedef enum {
    RR,   // RR-Type
    RRR,  // RRR-Type
    RI7,  // RI7-Type
    RI10, // RI10-Type
    RI16, // RI16-Type
    RI18  // RI18-Type
} format;

/* Binary Instruction Arrangement */
typedef union {
    struct {
        unsigned RT:  7; // Operand Register T
        unsigned RA:  7; // Operand Register A
        unsigned RB:  7; // Operand Register B
        const unsigned op: 11; // Unique Instruction Op-code
    } RR_bf;
    struct {
        unsigned RA: 7;
        unsigned RB: 7;
        unsigned RC: 7; // Operand Register C
        unsigned RT: 7;
        const unsigned op: 4;
    } RRR_bf;
    struct {
        unsigned RT:   7;
        unsigned RA:   7;
        unsigned RI7:  7; // Operand Immediate 7 bits
        const unsigned op: 11;
    } RI7_bf;
    struct {
        unsigned RT:    7;
        unsigned RA:    7;
        unsigned RI10: 10; // Operand Immediate 10 bits
        const unsigned op: 8;  
    } RI10_bf;
    struct {
        unsigned RT:    7;
        unsigned RI16: 16; // Operand Immediate 16 bits
        const unsigned op: 9;
    } RI16_bf;
    struct {
        unsigned RT:    7;
        unsigned RI18: 18; // Operand Immediate 18 bits
        const unsigned op: 7;
    } RI18_bf;
    unsigned instr; // Full 32-bit Instruction
} bin_format;

/* ISA - Instruction Table */
typedef struct {
    const format f;         /* Instruction format */
    const char *instr_name; /* Instruction Name */
    bin_format bf;          /* Instruction Binary Arrangement */
} isa;
extern isa isa_instr[TOTAL_INSTR];

#endif /* ISA_H */
