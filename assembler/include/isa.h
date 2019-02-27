#ifndef ISA_H
#define ISA_H

/* Max number of characters in an Instruction name */
#define MAX_INSTR_NM 7

/* Total number of instructions in the ISA */
#define TOTAL_INSR 68

/* Instructin Formats */
#define MAX_INSTR_RR 35     // RR-Type
#define MAX_INSTR_RRR 4     // RRR-Type
#define MAX_INSTR_RI7 8     // RI7-Type
#define MAX_INSTR_RI10 11   // RI10-Type
#define MAX_INSTR_RI16 9    // RI16-Type
#define MAX_INSTR_RI18 1    // RI18-Type

/* RR Format Instructions Table */
typedef struct {
    struct {
        const unsigned op: 11;    // Op-code
        unsigned RA: 7;           // Operand Register A
        unsigned RB: 7;           // Operand Register B
        unsigned RT: 7;           // Operand Register T
    };
    const char instr_name[MAX_INSTR_NM+1]; 
} RR;
extern RR RR_instr[MAX_INSTR_RR];

/* RRR Format Instructions Table */
typedef struct {
    struct {
        const unsigned op: 4;   // Op-code
        unsigned RA: 7;         // Operand Register A
        unsigned RB: 7;         // Operand Register B
        unsigned RC: 7;         // Operand Register C
        unsigned RT: 7;         // Operand Register T
    };
    const char instr_name[MAX_INSTR_NM+1];
} RRR;
extern RRR RRR_instr[MAX_INSTR_RRR];

/* RI7 Format Instructions Table */
typedef struct {
    struct {
        const unsigned op: 11;  // Op-code
        unsigned I7: 7;         // Operand Immediate 7 bits
        unsigned RA: 7;         // Operand Register A
        unsigned RT: 7;         // Operand Register T
    };
    const char instr_name[MAX_INSTR_NM+1];
} RI7;
extern RI7 RI7_instr[MAX_INSTR_RI7];

/* RI10 Format Instructions Table */
typedef struct {
    struct {
        const unsigned op: 8;   // Op-code
        unsigned I10: 10;       // Operand Immediate 10 bits
        unsigned RA: 7;         // Operand Register A
        unsigned RT: 7;         // Operand Register T
    };
    const char instr_name[MAX_INSTR_NM+1]; 
} RI10;
extern RI10 RI10_instr[MAX_INSTR_RI10];

/* RI16 Format Instructions Table */
typedef struct {
    struct {
        const unsigned op: 9;   // Op-code
        unsigned I16: 16;       // Operand Immediate 16 bits
        unsigned RT: 7;         // Operand Register T
    };
    const char instr_name[MAX_INSTR_NM+1];
} RI16;
extern RI16 RI16_instr[MAX_INSTR_RI16];

/* RI18 Format Instructions Table */
typedef struct {
    struct {
        const unsigned op: 7;   // Op-code
        unsigned I18: 18;       // Operand Immediate 18 bits
        unsigned RT: 7;         // Operand Register T
    };
    const char instr_name[MAX_INSTR_NM+1];
} RI18;
RI18 RI18_instr[MAX_INSTR_RI18];

/* ISA - Instruction Table */

#endif /* ISA_H */
