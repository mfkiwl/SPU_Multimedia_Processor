#include "isa.h"

/* ISA - Instruction Table */
isa isa_instr[TOTAL_INSR] = {
    {.instr_name = "lqa", .op = 0x061, .f = RI16},        // Load Quadword (a-form)
    {.instr_name = "lqd", .op = 0x034, .f = RI10},        // Load Quadword (d-form)
    {.instr_name = "stqd", .op = 0x024, .f = RI10},       // Store Quadword (d-form)
    {.instr_name = "stqa", .op = 0x041, .f = RI16},       // Store Quadword (a-form)  
    {.instr_name = "rib", .op = 0x03, .f = RR},           // Read Instruction Block
    {.instr_name = "ilhu", .op = 0x082, .f = RI16},       // Immediate Load Halfword Upper
    {.instr_name = "il", .op = 0x081, .f = RI16},         // Immediate Load Word
    {.instr_name = "ila", .op = 0x021, .f = RI18},        // Immediate Load Address  
    {.instr_name = "iohl", .op = 0x0C1, .f = RI16},       // Immediate OR Halfword Lower 
    {.instr_name = "a", .op = 0x0C0, .f = RR},            // Add Word 
    {.instr_name = "ai", .op = 0x01C, .f = RI10},         // Add Word Immediate 
    {.instr_name = "sf", .op = 0x040, .f = RR},           // Subtract from Word
    {.instr_name = "sfi", .op = 0x00C, .f = RI10},        // Subtract from Word Immediate    
    {.instr_name = "clz", .op = 0x2A5, .f = RR},          // Count Leading Zeros
    {.instr_name = "and", .op = 0x0C1, .f = RR},          // And
    {.instr_name = "andc", .op = 0x2C1, .f = RR},         // And with Complement
    {.instr_name = "andi", .op = 0x14, .f = RI10},        // And Word Immediate 
    {.instr_name = "or", .op = 0x041, .f = RR},           // Or
    {.instr_name = "orc", .op = 0x2C9, .f = RR},          // Or with Complement
    {.instr_name = "ori", .op = 0x04, .f = RI10},         // Or Word Immediate  
    {.instr_name = "orx", .op = 0x1f0, .f = RR},          // Or Across
    {.instr_name = "xor", .op = 0x241, .f = RR},          // Exclusive Or  
    {.instr_name = "nand", .op = 0x0C9, .f = RR},         // Nand
    {.instr_name = "nor", .op = 0x049, .f = RR},          // Nor                   
    {.instr_name = "ceq", .op = 0x3C0, .f = RR},          // Compare Equal Word
    {.instr_name = "ceqi", .op = 0x7C, .f = RI10},        // Compare Equal Word Immediate
    {.instr_name = "cgt", .op = 0x240, .f = RR},          // Compare Greater Than Word
    {.instr_name = "cgti", .op = 0x4C, .f = RI10},        // Compare Greater Than Word Immediate 
    {.instr_name = "clgt", .op = 0x2C0, .f = RR},         // Compare Logical Greater Than Word
    {.instr_name = "clgti", .op = 0x5C, .f = RI10},       // Compare Logical Greater Than Word Immediate          
    {.instr_name = "mpy", .op = 0x3C4, .f = RR},          // Multiply  
    {.instr_name = "mpyu", .op = 0x3CC, .f = RR},         // Multiply Unsigned 
    {.instr_name = "mpyi", .op = 0x74, .f = RI10},        // Multiply Immediate
    {.instr_name = "mpyui", .op = 0x75, .f = RI10},       // Multiply Unsigned Immediate
    {.instr_name = "mpya", .op = 0xC, .f = RRR},          // Multiply and Add 
    {.instr_name = "mpyh", .op = 0x3C5, .f = RR},         // Multiply High
    {.instr_name = "mpyhhu", .op = 0x3CE, .f = RR},       // Multiply High High Unsigned
    {.instr_name = "cntb", .op = 0x2B4, .f = RR},         // Count Ones in Bytes
    {.instr_name = "avgb", .op = 0x0D3, .f = RR},         // Average Bytes
    {.instr_name = "absdb", .op = 0x053, .f = RR},        // Absolute Differences of Bytes
    {.instr_name = "sumb", .op = 0x253, .f = RR},         // Sum Bytes into Halfwords
    {.instr_name = "shlqbii", .op = 0x1FB, .f = RI7},     // Shift Left Quadword by Bits Immediate 
    {.instr_name = "shlqbyi", .op = 0x1FF, .f = RI7},     // Shift Left Quadword by Bytes Immediate 
    {.instr_name = "rotqbyi", .op = 0x1FC, .f = RI7},     // Rotate Quadword by Bytes Immediate
    {.instr_name = "rotqbii", .op = 0x1F8, .f = RI7},     // Rotate Quadword by Bits Immediate
    {.instr_name = "shli", .op = 0x07B, .f = RI7},        // Shift Left Word Immediate
    {.instr_name = "rothi", .op = 0x07C, .f = RI7},       // Rotate Halfword Immediate
    {.instr_name = "roti", .op = 0x078, .f = RI7},        // Rotate Word Immediate
    {.instr_name = "br", .op = 0x064, .f = RI16},         // Branch Relative
    {.instr_name = "bra", .op = 0x060, .f = RI16},        // Branch Absolute 
    {.instr_name = "bi", .op = 0x1A8, .f = RR},           // Branch Indirect
    {.instr_name = "brnz", .op = 0x042, .f = RI16},       // Branch If Not Zero Word
    {.instr_name = "brz", .op = 0x040, .f = RI16},        // Branch If Zero Word
    {.instr_name = "biz", .op = 0x128, .f = RR},          // Branch Indirect If Zero
    {.instr_name = "binz", .op = 0x129, .f = RI7},        // Branch Indirect If Not Zero
    {.instr_name = "fa", .op = 0x2C4, .f = RR},           // Floating Add
    {.instr_name = "fs", .op = 0x2C5, .f = RR},           // Floating Subtract
    {.instr_name = "fm", .op = 0x2C6, .f = RR},           // Floating Multiply
    {.instr_name = "fma", .op = 0xE, .f = RRR},           // Floating Multiply and Add
    {.instr_name = "fnms", .op = 0xD, .f = RRR},          // Floating Negative Multiply and Subtract
    {.instr_name = "fms", .op = 0xF, .f = RRR},           // Floating Multiply and Subtract
    {.instr_name = "fceq", .op = 0x3C2, .f = RR},         // Floating Compare Equal 
    {.instr_name = "fcmeq", .op = 0x3CA, .f = RR},        // Floating Compare Magnitude Equal 
    {.instr_name = "fcgt", .op = 0x2C2, .f = RR},         // Floating Compare Greater Than 
    {.instr_name = "fcmgt", .op = 0x2CA, .f = RR},        // Floating Compare Magnitude Greater Than
    {.instr_name = "stop", .op = 0x0, .f = RR},           // Stop and Signal
    {.instr_name = "lnop", .op = 0x1, .f = RR},           // No Operation (Load) 
    {.instr_name = "nop", .op = 0x201, .f = RR}           // No Operation (Execute)
};
