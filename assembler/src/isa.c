#include "isa.h"

/* RR-Type Instruction Table */
RR RR_instr[MAX_INSTR_RR] = {
    {.instr_name = "rib", .op = 0x03},           // Read Instruction Block
    {.instr_name = "a", .op = 0x0C0},            // Add Word 
    {.instr_name = "sf", .op = 0x040},           // Subtract from Word
    {.instr_name = "clz", .op = 0x2A5},          // Count Leading Zeros
    {.instr_name = "and", .op = 0x0C1},          // And
    {.instr_name = "andc", .op = 0x2C1},         // And with Complement
    {.instr_name = "or", .op = 0x041},           // Or
    {.instr_name = "orc", .op = 0x2C9},          // Or with Complement
    {.instr_name = "orx", .op = 0x1f0},          // Or Across
    {.instr_name = "xor", .op = 0x241},          // Exclusive Or  
    {.instr_name = "nand", .op = 0x0C9},         // Nand
    {.instr_name = "nor", .op = 0x049},          // Nor                   
    {.instr_name = "ceq", .op = 0x3C0},          // Compare Equal Word
    {.instr_name = "cgt", .op = 0x240},          // Compare Greater Than Word
    {.instr_name = "clgt", .op = 0x2C0},         // Compare Logical Greater Than Word
    {.instr_name = "mpy", .op = 0x3C4},          // Multiply  
    {.instr_name = "mpyu", .op = 0x3CC},         // Multiply Unsigned 
    {.instr_name = "mpyh", .op = 0x3C5},         // Multiply High
    {.instr_name = "mpyhhu", .op = 0x3CE},       // Multiply High High Unsigned
    {.instr_name = "cntb", .op = 0x2B4},         // Count Ones in Bytes
    {.instr_name = "avgb", .op = 0x0D3},         // Average Bytes
    {.instr_name = "absdb", .op = 0x053},        // Absolute Differences of Bytes
    {.instr_name = "sumb", .op = 0x253},         // Sum Bytes into Halfwords
    {.instr_name = "bi", .op = 0x1A8},           // Branch Indirect
    {.instr_name = "biz", .op = 0x128},          // Branch Indirect If Zero
    {.instr_name = "fa", .op = 0x2C4},           // Floating Add
    {.instr_name = "fs", .op = 0x2C5},           // Floating Subtract
    {.instr_name = "fm", .op = 0x2C6},           // Floating Multiply
    {.instr_name = "fceq", .op = 0x3C2},         // Floating Compare Equal 
    {.instr_name = "fcmeq", .op = 0x3CA},        // Floating Compare Magnitude Equal 
    {.instr_name = "fcgt", .op = 0x2C2},         // Floating Compare Greater Than 
    {.instr_name = "fcmgt", .op = 0x2CA},        // Floating Compare Magnitude Greater Than
    {.instr_name = "stop", .op = 0x0},           // Stop and Signal
    {.instr_name = "lnop", .op = 0x1},           // No Operation (Load) 
    {.instr_name = "nop", .op = 0x201}           // No Operation (Execute)
};

/* RRR-Type Instruction Table */
RRR RRR_instr[MAX_INSTR_RRR] = {
    {.instr_name = "mpya", .op = 0xC},          // Multiply and Add 
    {.instr_name = "fma", .op = 0xE},           // Floating Multiply and Add
    {.instr_name = "fnms", .op = 0xD},          // Floating Negative Multiply and Subtract
    {.instr_name = "fms", .op = 0xF}            // Floating Multiply and Subtract
};

/* RI7-Type Instruction Table */
RI7 RI7_instr[MAX_INSTR_RI7] = {
    {.instr_name = "shlqbii", .op = 0x1FB},     // Shift Left Quadword by Bits Immediate 
    {.instr_name = "shlqbyi", .op = 0x1FF},     // Shift Left Quadword by Bytes Immediate 
    {.instr_name = "rotqbyi", .op = 0x1FC},     // Rotate Quadword by Bytes Immediate
    {.instr_name = "rotqbii", .op = 0x1F8},     // Rotate Quadword by Bits Immediate
    {.instr_name = "shli", .op = 0x07B},        // Shift Left Word Immediate
    {.instr_name = "rothi", .op = 0x07C},       // Rotate Halfword Immediate
    {.instr_name = "roti", .op = 0x078},        // Rotate Word Immediate
    {.instr_name = "binz", .op = 0x129}         // Branch Indirect If Not Zero
};

/* RI10-Type Instruction Table */
RI10 RI10_instr[MAX_INSTR_RI10] = {
    {.instr_name = "lqd", .op = 0x034},        // Load Quadword (d-form)
    {.instr_name = "stqd", .op = 0x024},       // Store Quadword (d-form)
    {.instr_name = "ai", .op = 0x01C},         // Add Word Immediate 
    {.instr_name = "sfi", .op = 0x00C},        // Subtract from Word Immediate    
    {.instr_name = "andi", .op = 0x14},        // And Word Immediate 
    {.instr_name = "ori", .op = 0x04},         // Or Word Immediate  
    {.instr_name = "ceqi", .op = 0x7C},        // Compare Equal Word Immediate
    {.instr_name = "cgti", .op = 0x4C},        // Compare Greater Than Word Immediate 
    {.instr_name = "clgti", .op = 0x5C},       // Compare Logical Greater Than Word Immediate          
    {.instr_name = "mpyi", .op = 0x74},        // Multiply Immediate
    {.instr_name = "mpyui", .op = 0x75}        // Multiply Unsigned Immediate
};

/* RI16-Type Instruction Table */
RI16 RI16_instr[MAX_INSTR_RI16] = {
    {.instr_name = "lqa", .op = 0x061},        // Load Quadword (a-form)
    {.instr_name = "stqa", .op = 0x041},       // Store Quadword (a-form)  
    {.instr_name = "ilhu", .op = 0x082},       // Immediate Load Halfword Upper
    {.instr_name = "il", .op = 0x081},         // Immediate Load Word
    {.instr_name = "iohl", .op = 0x0C1},       // Immediate OR Halfword Lower 
    {.instr_name = "br", .op = 0x064},         // Branch Relative
    {.instr_name = "bra", .op = 0x060},        // Branch Absolute 
    {.instr_name = "brnz", .op = 0x042},       // Branch If Not Zero Word
    {.instr_name = "brz", .op = 0x040},        // Branch If Zero Word
    
};

/* RI18-Type Instruction Table */
RI18 RI18_instr[MAX_INSTR_RI18] = {
    {.instr_name = "ila", .op = 0x021}         // Immediate Load Address  
};
