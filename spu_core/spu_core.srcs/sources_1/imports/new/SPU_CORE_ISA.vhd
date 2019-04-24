-------------------- LIBRARIES --------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-------------------- PACKAGE DECLARATION --------------------
package SPU_CORE_ISA_PACKAGE is
----- COMPONENT CONSTANTS -----
constant OPCODE_WIDTH_4  : NATURAL := 4;  -- 4 bit-width Opcodes
constant OPCODE_WIDTH_7  : NATURAL := 7;  -- 7 bit-width Opcodes
constant OPCODE_WIDTH_8  : NATURAL := 8;  -- 8 bit-width Opcodes
constant OPCODE_WIDTH_9  : NATURAL := 9;  -- 9 bit-width Opcodes
constant OPCODE_WIDTH_11 : NATURAL := 11; -- 11 bit-width Opcodes

constant OPCODE_WIDTH_4_COUNT  : NATURAL := 4;  -- 4 bit-width Opcodes Count
constant OPCODE_WIDTH_7_COUNT  : NATURAL := 1;  -- 7 bit-width Opcodes Count
constant OPCODE_WIDTH_8_COUNT  : NATURAL := 11; -- 8 bit-width Opcodes Count
constant OPCODE_WIDTH_9_COUNT  : NATURAL := 9;  -- 9 bit-width Opcodes Count
constant OPCODE_WIDTH_11_COUNT : NATURAL := 43; -- 11 bit-width Opcodes Count

constant TOTAL_INSTR  : NATURAL := 68; -- Total Number of Instructions in the ISA
-- EXECUTION UNIT LATENCIES --
constant SIMPLE_FIXED_1_L     : NATURAL := 2;
constant SIMPLE_FIXED_2_L     : NATURAL := 4;
constant SINGE_PRECISION_FP_L : NATURAL := 6;
constant SINGE_PRECISION_I_L  : NATURAL := 7;
constant BYTE_L               : NATURAL := 4;
constant PERMUTE_L            : NATURAL := 4;
constant LOCAL_STORE_L        : NATURAL := 6;
constant BRANCH_L             : NATURAL := 4;
constant NOP_L                : NATURAL := 0;

-- Execution Units --
type EXE_UNIT is (SIMPLE_FIXED_1, SIMPLE_FIXED_2, SINGE_PRECISION, BYTE, PERMUTE, LOCAL_STORE, BRANCH, CONTROL);
type FORMAT is (RR, RRR, RI7, RI10, RI16, RI18);

----- INSTRUCTION STRUCTURE -----
type INSTR_4 is record
    OPCODE : STD_LOGIC_VECTOR((OPCODE_WIDTH_4-1) downto 0); -- Instruction Op-code
    UNIT   : EXE_UNIT; -- Execution Unit Type
    FORMAT : FORMAT;   -- Instruction Format
end record INSTR_4;

type ISA_4 is array (0 to (OPCODE_WIDTH_4_COUNT-1)) of INSTR_4; 
constant ISA_TABLE_4 : ISA_4 := (
    (x"C", SINGE_PRECISION, RRR), -- Multiply and Add
    (x"E", SINGE_PRECISION, RRR), -- Floating Multiply and Add
    (x"D", SINGE_PRECISION, RRR), -- Floating Negative Multiply and Subtract
    (x"F", SINGE_PRECISION, RRR)  -- Floating Multiply and Subtract
);

----- INSTRUCTION STRUCTURE -----
type INSTR_7 is record
    OPCODE : STD_LOGIC_VECTOR((OPCODE_WIDTH_7-1) downto 0); -- Instruction Op-code
    UNIT   : EXE_UNIT; -- Execution Unit Type
    FORMAT : FORMAT;   -- Instruction Format
end record INSTR_7;

constant ISA_TABLE_7 : INSTR_7 := (STD_LOGIC_VECTOR(to_unsigned(16#21#, OPCODE_WIDTH_7)), LOCAL_STORE, RI18); -- Immediate load Address

----- INSTRUCTION STRUCTURE -----
type INSTR_8 is record
    OPCODE : STD_LOGIC_VECTOR((OPCODE_WIDTH_8-1) downto 0); -- Instruction Op-code
    UNIT   : EXE_UNIT; -- Execution Unit Type
    FORMAT : FORMAT;   -- Instruction Format
end record INSTR_8;

type ISA_8 is array (0 to (OPCODE_WIDTH_8_COUNT-1)) of INSTR_8; 
constant ISA_TABLE_8 : ISA_8 := (
    (x"34", LOCAL_STORE, RI10),     -- Load Quadword (d-form),
    (x"24", LOCAL_STORE, RI10),     -- Store Quadword (d-form)
    (x"1C", SIMPLE_FIXED_1, RI10),  -- Add Word Immediate
    (x"0C", SIMPLE_FIXED_1, RI10),  -- Subtract from Word Immediate
    (x"14", SIMPLE_FIXED_1, RI10),  -- AND Word Immediate
    (x"04", SIMPLE_FIXED_1, RI10),  -- OR Word Immediate
    (x"7C", SIMPLE_FIXED_1, RI10),  -- Compare Equal Word Immediate
    (x"4C", SIMPLE_FIXED_1, RI10),  -- Compare Greater Than Word Immediate
    (x"5C", SIMPLE_FIXED_1, RI10),  -- Compare Logical Greater Than Word Immediate
    (x"74", SINGE_PRECISION, RI10), -- Multiply Immediate
    (x"75", SINGE_PRECISION, RI10)  -- Multiply Unsigned Immediate
);

----- INSTRUCTION STRUCTURE -----
type INSTR_9 is record
    OPCODE : STD_LOGIC_VECTOR((OPCODE_WIDTH_9-1) downto 0); -- Instruction Op-code
    UNIT   : EXE_UNIT; -- Execution Unit Type
    FORMAT : FORMAT;   -- Instruction Format
end record INSTR_9;

type ISA_9 is array (0 to (OPCODE_WIDTH_9_COUNT-1)) of INSTR_9; 
constant ISA_TABLE_9 : ISA_9 := (
    (STD_LOGIC_VECTOR(to_unsigned(16#61#, OPCODE_WIDTH_9)), LOCAL_STORE, RI16), -- Load Quadword (a–form)
    (STD_LOGIC_VECTOR(to_unsigned(16#41#, OPCODE_WIDTH_9)), LOCAL_STORE, RI16), -- Store Quadword (a-form)
    (STD_LOGIC_VECTOR(to_unsigned(16#82#, OPCODE_WIDTH_9)), LOCAL_STORE, RI16), -- Immediate Load Half Word Upper
    (STD_LOGIC_VECTOR(to_unsigned(16#81#, OPCODE_WIDTH_9)), LOCAL_STORE, RI16), -- Immediate Load Word
    (STD_LOGIC_VECTOR(to_unsigned(16#C1#, OPCODE_WIDTH_9)), LOCAL_STORE, RI16), -- Immediate OR Halfword Lower
    (STD_LOGIC_VECTOR(to_unsigned(16#64#, OPCODE_WIDTH_9)), BRANCH, RI16),      -- Branch Relative
    (STD_LOGIC_VECTOR(to_unsigned(16#60#, OPCODE_WIDTH_9)), BRANCH, RI16),      -- Branch Absolute
    (STD_LOGIC_VECTOR(to_unsigned(16#42#, OPCODE_WIDTH_9)), BRANCH, RI16),      -- Branch If Not Zero Word
    (STD_LOGIC_VECTOR(to_unsigned(16#40#, OPCODE_WIDTH_9)), BRANCH, RI16)       -- Branch If Zero Word
);

----- INSTRUCTION STRUCTURE -----
type INSTR_11 is record
    OPCODE : STD_LOGIC_VECTOR((OPCODE_WIDTH_11-1) downto 0); -- Instruction Op-code
    UNIT   : EXE_UNIT; -- Execution Unit Type
    FORMAT : FORMAT;   -- Instruction Format
end record INSTR_11;

-- ARRAY OF ALL INSTRUCTIONS IN ISA --
type ISA_11 is array (0 to (OPCODE_WIDTH_11_COUNT-1)) of INSTR_11; 
constant ISA_TABLE_11 : ISA_11 := (
    (STD_LOGIC_VECTOR(to_unsigned(16#23#, OPCODE_WIDTH_11)), LOCAL_STORE, RR),      -- Read Instruction Block
    (STD_LOGIC_VECTOR(to_unsigned(16#C0#, OPCODE_WIDTH_11)), SIMPLE_FIXED_1, RR),   -- Add Word
    (STD_LOGIC_VECTOR(to_unsigned(16#40#, OPCODE_WIDTH_11)), SIMPLE_FIXED_1, RR),   -- Subtract from Word
    (STD_LOGIC_VECTOR(to_unsigned(16#2A5#, OPCODE_WIDTH_11)), SIMPLE_FIXED_1, RR),  -- Count Leading Zeros
    (STD_LOGIC_VECTOR(to_unsigned(16#C1#, OPCODE_WIDTH_11)), SIMPLE_FIXED_1, RR),   -- AND
    (STD_LOGIC_VECTOR(to_unsigned(16#2C1#, OPCODE_WIDTH_11)), SIMPLE_FIXED_1, RR),  -- AND with Complement
    (STD_LOGIC_VECTOR(to_unsigned(16#41#, OPCODE_WIDTH_11)), SIMPLE_FIXED_1, RR),   -- OR
    (STD_LOGIC_VECTOR(to_unsigned(16#2C9#, OPCODE_WIDTH_11)), SIMPLE_FIXED_1, RR),  -- OR with Complement
    (STD_LOGIC_VECTOR(to_unsigned(16#1F0#, OPCODE_WIDTH_11)), SIMPLE_FIXED_1, RR),  -- OR Across
    (STD_LOGIC_VECTOR(to_unsigned(16#241#, OPCODE_WIDTH_11)), SIMPLE_FIXED_1, RR),  -- Exclusive OR
    (STD_LOGIC_VECTOR(to_unsigned(16#C9#, OPCODE_WIDTH_11)), SIMPLE_FIXED_1, RR),   -- NAND
    (STD_LOGIC_VECTOR(to_unsigned(16#49#, OPCODE_WIDTH_11)), SIMPLE_FIXED_1, RR),   -- NOR
    (STD_LOGIC_VECTOR(to_unsigned(16#3C0#, OPCODE_WIDTH_11)), SIMPLE_FIXED_1, RR),  -- Compare Equal Word
    (STD_LOGIC_VECTOR(to_unsigned(16#240#, OPCODE_WIDTH_11)), SIMPLE_FIXED_1, RR),  -- Compare Greater Than Word
    (STD_LOGIC_VECTOR(to_unsigned(16#2C0#, OPCODE_WIDTH_11)), SIMPLE_FIXED_1, RR),  -- Compare Logical Greater Than Word
    (STD_LOGIC_VECTOR(to_unsigned(16#3C4#, OPCODE_WIDTH_11)), SINGE_PRECISION, RR), -- Multiply
    (STD_LOGIC_VECTOR(to_unsigned(16#3CC#, OPCODE_WIDTH_11)), SINGE_PRECISION, RR), -- Multiply Unsigned
    (STD_LOGIC_VECTOR(to_unsigned(16#3C5#, OPCODE_WIDTH_11)), SINGE_PRECISION, RR), -- Multiply High
    (STD_LOGIC_VECTOR(to_unsigned(16#3CE#, OPCODE_WIDTH_11)), SINGE_PRECISION, RR), -- Multiply High High Unsigned
    (STD_LOGIC_VECTOR(to_unsigned(16#2B4#, OPCODE_WIDTH_11)), BYTE, RR),            -- Count Ones in Bytes
    (STD_LOGIC_VECTOR(to_unsigned(16#D3#, OPCODE_WIDTH_11)), BYTE, RR),             -- Average Bytes
    (STD_LOGIC_VECTOR(to_unsigned(16#53#, OPCODE_WIDTH_11)), BYTE, RR),             -- Absolute Differences of Bytes
    (STD_LOGIC_VECTOR(to_unsigned(16#253#, OPCODE_WIDTH_11)), BYTE, RR),            -- Sum Bytes into Halfwords
    (STD_LOGIC_VECTOR(to_unsigned(16#1A8#, OPCODE_WIDTH_11)), BRANCH, RR),          -- Branch Indirect
    (STD_LOGIC_VECTOR(to_unsigned(16#128#, OPCODE_WIDTH_11)), BRANCH, RR),          -- Branch Indirect If Zero
    (STD_LOGIC_VECTOR(to_unsigned(16#2C4#, OPCODE_WIDTH_11)), SINGE_PRECISION, RR), -- Floating Add
    (STD_LOGIC_VECTOR(to_unsigned(16#2C5#, OPCODE_WIDTH_11)), SINGE_PRECISION, RR), -- Floating Subtract
    (STD_LOGIC_VECTOR(to_unsigned(16#2C6#, OPCODE_WIDTH_11)), SINGE_PRECISION, RR), -- Floating Multiply
    (STD_LOGIC_VECTOR(to_unsigned(16#3C2#, OPCODE_WIDTH_11)), SINGE_PRECISION, RR), -- Floating Compare Equal
    (STD_LOGIC_VECTOR(to_unsigned(16#3CA#, OPCODE_WIDTH_11)), SINGE_PRECISION, RR), -- Floating Compare Magnitude Equal
    (STD_LOGIC_VECTOR(to_unsigned(16#2C2#, OPCODE_WIDTH_11)), SINGE_PRECISION, RR), -- Floating Compare Greater Than
    (STD_LOGIC_VECTOR(to_unsigned(16#2CA#, OPCODE_WIDTH_11)), SINGE_PRECISION, RR), -- Floating Compare Magnitude Greater Than
    (STD_LOGIC_VECTOR(to_unsigned(16#0#, OPCODE_WIDTH_11)), CONTROL, RR),           -- Stop and Signal
    (STD_LOGIC_VECTOR(to_unsigned(16#1#, OPCODE_WIDTH_11)), CONTROL, RR),           -- Nop (Load)
    (STD_LOGIC_VECTOR(to_unsigned(16#201#, OPCODE_WIDTH_11)), CONTROL, RR),         -- Nop (Execute)
    (STD_LOGIC_VECTOR(to_unsigned(16#1FB#, OPCODE_WIDTH_11)), PERMUTE, RI7),        -- Shift Left Quadword by Bits Immediate
    (STD_LOGIC_VECTOR(to_unsigned(16#1FF#, OPCODE_WIDTH_11)), PERMUTE, RI7),        -- Shift Left Quadword by Bytes Immediate
    (STD_LOGIC_VECTOR(to_unsigned(16#1FC#, OPCODE_WIDTH_11)), PERMUTE, RI7),        -- Rotate Quadword by Bytes Immediate
    (STD_LOGIC_VECTOR(to_unsigned(16#1F8#, OPCODE_WIDTH_11)), PERMUTE, RI7),        -- Rotate Quadword by Bits Immediate
    (STD_LOGIC_VECTOR(to_unsigned(16#7B#, OPCODE_WIDTH_11)), SIMPLE_FIXED_2, RI7),  -- Shift Left Word Immediate
    (STD_LOGIC_VECTOR(to_unsigned(16#7C#, OPCODE_WIDTH_11)), SIMPLE_FIXED_2, RI7),  -- Rotate Halfword Immediate
    (STD_LOGIC_VECTOR(to_unsigned(16#78#, OPCODE_WIDTH_11)), SIMPLE_FIXED_2, RI7),  -- Rotate Word Immediate
    (STD_LOGIC_VECTOR(to_unsigned(16#129#, OPCODE_WIDTH_11)), BRANCH, RI7)          -- Branch Indirect If Not Zero
);
end package SPU_CORE_ISA_PACKAGE;
