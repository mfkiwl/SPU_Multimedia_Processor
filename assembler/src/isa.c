#include "isa.h"

/* ISA - Instruction Table */
isa isa_instr[TOTAL_INSTR] = {
    {.instr_name = "lqa", .bf.RI16_bf.op = 0x61, .f = RI16},       // Load Quadword (a-form)
    {.instr_name = "lqd", .bf.RI10_bf.op = 0x34, .f = RI10},       // Load Quadword (d-form)
    {.instr_name = "stqd", .bf.RI10_bf.op = 0x24, .f = RI10},      // Store Quadword (d-form)
    {.instr_name = "stqa", .bf.RI16_bf.op = 0x51, .f = RI16},      // Store Quadword (a-form)  
    {.instr_name = "rib", .bf.RR_bf.op = 0x23, .f = RR},           // Read Instruction Block
    {.instr_name = "ilhu", .bf.RI16_bf.op = 0x82, .f = RI16},      // Immediate Load Halfword Upper
    {.instr_name = "il", .bf.RI16_bf.op = 0x81, .f = RI16},        // Immediate Load Word
    {.instr_name = "ila", .bf.RI18_bf.op = 0x21, .f = RI18},       // Immediate Load Address  
    {.instr_name = "iohl", .bf.RI16_bf.op = 0xC1, .f = RI16},      // Immediate OR Halfword Lower 
    {.instr_name = "a", .bf.RR_bf.op = 0xC0, .f = RR},             // Add Word 
    {.instr_name = "ai", .bf.RI10_bf.op = 0x1C, .f = RI10},        // Add Word Immediate 
    {.instr_name = "sf", .bf.RR_bf.op = 0x40, .f = RR},            // Subtract from Word
    {.instr_name = "sfi", .bf.RI10_bf.op = 0xFC, .f = RI10},        // Subtract from Word Immediate    
    {.instr_name = "clz", .bf.RR_bf.op = 0x2A5, .f = RR},          // Count Leading Zeros
    {.instr_name = "and", .bf.RR_bf.op = 0xC1, .f = RR},           // And
    {.instr_name = "andc", .bf.RR_bf.op = 0x2C1, .f = RR},         // And with Complement
    {.instr_name = "andi", .bf.RI10_bf.op = 0x14, .f = RI10},      // And Word Immediate 
    {.instr_name = "or", .bf.RR_bf.op = 0x41, .f = RR},            // Or
    {.instr_name = "orc", .bf.RR_bf.op = 0x2C9, .f = RR},          // Or with Complement
    {.instr_name = "ori", .bf.RI10_bf.op = 0x4, .f = RI10},        // Or Word Immediate  
    {.instr_name = "orx", .bf.RR_bf.op = 0x1f0, .f = RR},          // Or Across
    {.instr_name = "xor", .bf.RR_bf.op = 0x241, .f = RR},          // Exclusive Or  
    {.instr_name = "nand", .bf.RR_bf.op = 0xC9, .f = RR},          // Nand
    {.instr_name = "nor", .bf.RR_bf.op = 0x49, .f = RR},           // Nor                   
    {.instr_name = "ceq", .bf.RR_bf.op = 0x3C0, .f = RR},          // Compare Equal Word
    {.instr_name = "ceqi", .bf.RI10_bf.op = 0x7C, .f = RI10},      // Compare Equal Word Immediate
    {.instr_name = "cgt", .bf.RR_bf.op = 0x240, .f = RR},          // Compare Greater Than Word
    {.instr_name = "cgti", .bf.RI10_bf.op = 0x4C, .f = RI10},      // Compare Greater Than Word Immediate 
    {.instr_name = "clgt", .bf.RR_bf.op = 0x2C0, .f = RR},         // Compare Logical Greater Than Word
    {.instr_name = "clgti", .bf.RI10_bf.op = 0x5C, .f = RI10},     // Compare Logical Greater Than Word Immediate          
    {.instr_name = "mpy", .bf.RR_bf.op = 0x3C4, .f = RR},          // Multiply  
    {.instr_name = "mpyu", .bf.RR_bf.op = 0x3CC, .f = RR},         // Multiply Unsigned 
    {.instr_name = "mpyi", .bf.RI10_bf.op = 0x74, .f = RI10},      // Multiply Immediate
    {.instr_name = "mpyui", .bf.RI10_bf.op = 0x75, .f = RI10},     // Multiply Unsigned Immediate
    {.instr_name = "mpya", .bf.RRR_bf.op = 0xC, .f = RRR},         // Multiply and Add 
    {.instr_name = "mpyh", .bf.RR_bf.op = 0x3C5, .f = RR},         // Multiply High
    {.instr_name = "mpyhhu", .bf.RR_bf.op = 0x3CE, .f = RR},       // Multiply High High Unsigned
    {.instr_name = "cntb", .bf.RR_bf.op = 0x2B4, .f = RR},         // Count Ones in Bytes
    {.instr_name = "avgb", .bf.RR_bf.op = 0xD3, .f = RR},          // Average Bytes
    {.instr_name = "absdb", .bf.RR_bf.op = 0x53, .f = RR},         // Absolute Differences of Bytes
    {.instr_name = "sumb", .bf.RR_bf.op = 0x253, .f = RR},         // Sum Bytes into Halfwords
    {.instr_name = "shlqbii", .bf.RI7_bf.op = 0x1FB, .f = RI7},    // Shift Left Quadword by Bits Immediate 
    {.instr_name = "shlqbyi", .bf.RI7_bf.op = 0x1FF, .f = RI7},    // Shift Left Quadword by Bytes Immediate 
    {.instr_name = "rotqbyi", .bf.RI7_bf.op = 0x1FC, .f = RI7},    // Rotate Quadword by Bytes Immediate
    {.instr_name = "rotqbii", .bf.RI7_bf.op = 0x1F8, .f = RI7},    // Rotate Quadword by Bits Immediate
    {.instr_name = "shli", .bf.RI7_bf.op = 0x7B, .f = RI7},        // Shift Left Word Immediate
    {.instr_name = "rothi", .bf.RI7_bf.op = 0x8C, .f = RI7},       // Rotate Halfword Immediate
    {.instr_name = "roti", .bf.RI7_bf.op = 0x78, .f = RI7},        // Rotate Word Immediate
    {.instr_name = "br", .bf.RI16_bf.op = 0x64, .f = RI16},        // Branch Relative
    {.instr_name = "bra", .bf.RI16_bf.op = 0x60, .f = RI16},       // Branch Absolute 
    {.instr_name = "bi", .bf.RR_bf.op = 0x1A8, .f = RR},           // Branch Indirect
    {.instr_name = "brnz", .bf.RI16_bf.op = 0x42, .f = RI16},      // Branch If Not Zero Word
    {.instr_name = "brz", .bf.RI16_bf.op = 0x40, .f = RI16},       // Branch If Zero Word
    {.instr_name = "biz", .bf.RR_bf.op = 0x128, .f = RR},          // Branch Indirect If Zero
    {.instr_name = "binz", .bf.RI7_bf.op = 0x129, .f = RI7},       // Branch Indirect If Not Zero
    {.instr_name = "fa", .bf.RR_bf.op = 0x2C4, .f = RR},           // Floating Add
    {.instr_name = "fs", .bf.RR_bf.op = 0x2C5, .f = RR},           // Floating Subtract
    {.instr_name = "fm", .bf.RR_bf.op = 0x2C6, .f = RR},           // Floating Multiply
    {.instr_name = "fma", .bf.RRR_bf.op = 0xE, .f = RRR},          // Floating Multiply and Add
    {.instr_name = "fnms", .bf.RRR_bf.op = 0xD, .f = RRR},         // Floating Negative Multiply and Subtract
    {.instr_name = "fms", .bf.RRR_bf.op = 0xF, .f = RRR},          // Floating Multiply and Subtract
    {.instr_name = "fceq", .bf.RR_bf.op = 0x3C2, .f = RR},         // Floating Compare Equal 
    {.instr_name = "fcmeq", .bf.RR_bf.op = 0x3CA, .f = RR},        // Floating Compare Magnitude Equal 
    {.instr_name = "fcgt", .bf.RR_bf.op = 0x2C2, .f = RR},         // Floating Compare Greater Than 
    {.instr_name = "fcmgt", .bf.RR_bf.op = 0x2CA, .f = RR},        // Floating Compare Magnitude Greater Than
    {.instr_name = "stop", .bf.RR_bf.op = 0x0, .f = RR},           // Stop and Signal
    {.instr_name = "lnop", .bf.RR_bf.op = 0x1, .f = RR},           // No Operation (Load) 
    {.instr_name = "nop", .bf.RR_bf.op = 0x201, .f = RR}           // No Operation (Execute)
};
