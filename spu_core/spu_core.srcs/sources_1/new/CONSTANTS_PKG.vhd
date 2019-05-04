-------------------- PACKAGE DECLARATION --------------------
package CONSTANTS_PACKAGE is
    ----- COMPONENT CONSTANTS -----
    constant ADDR_WIDTH      : NATURAL := 7;    -- Bit-width of the Register Addresses
    constant DATA_WIDTH      : NATURAL := 128;  -- Bit-width of the Register Data - Register File
    constant OPCODE_WIDTH    : NATURAL := 11;   -- Maximum Bit-width of Opcode
    constant RI7_WIDTH       : NATURAL := 7;    -- Immediate 7-bit format
    constant RI10_WIDTH      : NATURAL := 10;   -- Immediate 10-bit format
    constant RI16_WIDTH      : NATURAL := 16;   -- Immediate 16-bit format
    constant RI18_WIDTH      : NATURAL := 18;   -- Immediate 18-bit format
    constant ADDR_WIDTH_LS   : NATURAL := 4;    -- Bit-width of the SRAM Addresses - Local Store
    constant INSTR_WIDTH_LS  : NATURAL := 1024; -- Bit-width of Instruction Block - Local Store
    constant STORAGE_SIZE    : NATURAL := 2048; -- Block Amount
    constant FC_DEPTH        : NATURAL := 7+1;  -- Number of Forwarding Circuit Stages 7 + WB Stage
    constant INSTR_PAIR_SIZE : NATURAL := 64;   -- Size of instrucion pair from instruction cache
    constant CACHE_TAG_SIZE  : NATURAL := 3;    -- Size of the cache entry TAGS
    constant CACHE_HEIGHT    : NATURAL := 16;   -- Number of entries in instruction cache
    constant CACHE_SIZE      : NATURAL := 16*8; -- 16 Cache entries & 8 byte blocks
    constant INSTR_SIZE      : NATURAL := 32;   -- Size of an instruction
    constant LS_INSTR_SECTION_SIZE : NATURAL := 10; -- 10 bits (1024 instructions max in LS (in code section))

    ----- ISA CONSTANTS -----
    constant OPCODE_WIDTH_4_COUNT  : NATURAL := 4;  -- 4 bit-width Opcodes Count
    constant OPCODE_WIDTH_7_COUNT  : NATURAL := 1;  -- 7 bit-width Opcodes Count
    constant OPCODE_WIDTH_8_COUNT  : NATURAL := 11; -- 8 bit-width Opcodes Count
    constant OPCODE_WIDTH_9_COUNT  : NATURAL := 9;  -- 9 bit-width Opcodes Count
    constant OPCODE_WIDTH_11_COUNT : NATURAL := 43; -- 11 bit-width Opcodes Count
    constant TOTAL_INSTR           : NATURAL := 68; -- Total Number of Instructions in the ISA
    
    ----- EXECUTION UNIT LATENCIES -----
    constant SIMPLE_FIXED_1_L     : NATURAL := 2;
    constant SIMPLE_FIXED_2_L     : NATURAL := 4;
    constant SINGE_PRECISION_FP_L : NATURAL := 6;
    constant SINGE_PRECISION_I_L  : NATURAL := 7;
    constant BYTE_L               : NATURAL := 4;
    constant PERMUTE_L            : NATURAL := 4;
    constant LOCAL_STORE_L        : NATURAL := 6;
    constant BRANCH_L             : NATURAL := 4;
    constant NOP_L                : NATURAL := 0;
end package CONSTANTS_PACKAGE;