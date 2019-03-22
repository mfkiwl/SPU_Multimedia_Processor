-------------------- LIBRARIES --------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-------------------- PACKAGE DECLARATION --------------------
package SPU_CORE_ISA_PACKAGE is
----- COMPONENT CONSTANTS -----
--constant OPCODE_WIDTH : NATURAL := 11; -- Maximum bit-width of Even and Odd Opcodes
--constant TOTAL_INSTR : NATURAL := 68;  -- Total Number of Instructions in ISA
-- EXECUTION UNIT LATENCIES --
constant SIMPLE_FIXED_1_L : NATURAL := 2;
constant SIMPLE_FIXED_2_L : NATURAL := 4;
constant SINGE_PRECISION_FP_L : NATURAL := 6;
constant SINGE_PRECISION_I_L : NATURAL := 7;
constant BYTE_L : NATURAL := 4;
constant PERMUTE_L : NATURAL := 4;
constant LOCAL_STORE_L : NATURAL := 6;
constant BRANCH_L : NATURAL := 4;
constant NOP_L : NATURAL := 0;

-- Execution Units --
--type EXE_UNIT is (SIMPLE_FIXED_1, SIMPLE_FIXED_2, SINGE_PRECISION, BYTE, PERMUTE, LOCAL_STORE, BRANCH, CONTROL);
--type FORMAT is (RR, RRR, RI7, RI10, RI16, RI18);

------- INSTRUCTION STRUCTURE -----
--type INSTR is record
--    OPCODE : STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0); -- Instruction Op-code
--    UNIT : EXE_UNIT;  -- Execution Unit Type
--    FORMAT : FORMAT;  -- Instruction Format
--    LATENCY : NATURAL; -- Execution Pipe Latency
--end record INSTR;
---- ARRAY OF ALL INSTRUCTIONS IN ISA --
--type ISA is array (0 to (TOTAL_INSTR-1)) of INSTR; 
--signal ISA_TABLE : ISA := (
--    -------------------- SIMPLE FIXED 1 --------------------
--    (x"C0", SIMPLE_FIXED_1, RR, SIMPLE_FIXED_1_L),   -- Add Word
--    (x"1C", SIMPLE_FIXED_1, RI10, SIMPLE_FIXED_1_L), -- Add Word Immediate
--    (x"40", SIMPLE_FIXED_1, RR, SIMPLE_FIXED_1_L),   -- Subtract from Word
--    (x"FC", SIMPLE_FIXED_1, RI10, SIMPLE_FIXED_1_L),  -- Subtract from Word Immediate
--    (x"2A5", SIMPLE_FIXED_1, RR, SIMPLE_FIXED_1_L),  -- Count Leading Zeros
--    (x"C1", SIMPLE_FIXED_1, RR, SIMPLE_FIXED_1_L),   -- AND
--    (x"2C1", SIMPLE_FIXED_1, RR, SIMPLE_FIXED_1_L),  -- AND with Complement
--    (x"14", SIMPLE_FIXED_1, RI10, SIMPLE_FIXED_1_L), -- AND Word Immediate
--    (x"41", SIMPLE_FIXED_1, RR, SIMPLE_FIXED_1_L),   -- OR
--    (x"2C9", SIMPLE_FIXED_1, RR, SIMPLE_FIXED_1_L),  -- OR with Complement
--    (x"4", SIMPLE_FIXED_1, RI10, SIMPLE_FIXED_1_L),  -- OR Word Immediate
--    (x"1F0", SIMPLE_FIXED_1, RR, SIMPLE_FIXED_1_L),  -- OR Across
--    (x"241", SIMPLE_FIXED_1, RR, SIMPLE_FIXED_1_L),  -- Exclusive OR
--    (x"C9", SIMPLE_FIXED_1, RR, SIMPLE_FIXED_1_L),   -- NAND
--    (x"49", SIMPLE_FIXED_1, RR, SIMPLE_FIXED_1_L),   -- NOR
--    (x"3C0", SIMPLE_FIXED_1, RR, SIMPLE_FIXED_1_L),  -- Compare Equal Word
--    (x"7C", SIMPLE_FIXED_1, RI10, SIMPLE_FIXED_1_L), -- Compare Equal Word Immediate
--    (x"240", SIMPLE_FIXED_1, RR, SIMPLE_FIXED_1_L),  -- Compare Greater Than Word
--    (x"4C", SIMPLE_FIXED_1, RI10, SIMPLE_FIXED_1_L), -- Compare Greater Than Word Immediate
--    (x"2C0", SIMPLE_FIXED_1, RR, SIMPLE_FIXED_1_L),  -- Compare Logical Greater Than Word
--    (x"5C", SIMPLE_FIXED_1, RI10, SIMPLE_FIXED_1_L), -- Compare Logical Greater Than Word Immediate
--    -------------------- SIMPLE FIXED 2 --------------------
--    (x"7B", SIMPLE_FIXED_2, RI7, SIMPLE_FIXED_2_L),  -- Shift Left Word Immediate
--    (x"8C", SIMPLE_FIXED_2, RI7, SIMPLE_FIXED_2_L),  -- Rotate Halfword Immediate
--    (x"78", SIMPLE_FIXED_2, RI7, SIMPLE_FIXED_2_L),  -- Rotate Word Immediate
--    -------------------- FLOATING POINT INSTRUCTIONS --------------------
--    (x"2C4", SINGE_PRECISION, RR, SINGE_PRECISION_FP_L),  -- Floating Add
--    (x"2C5", SINGE_PRECISION, RR, SINGE_PRECISION_FP_L),  -- Floating Subtract
--    (x"2C6", SINGE_PRECISION, RR, SINGE_PRECISION_FP_L),  -- Floating Multiply
--    (x"E", SINGE_PRECISION, RRR, SINGE_PRECISION_FP_L),   -- Floating Multiply and Add
--    (x"D", SINGE_PRECISION, RRR, SINGE_PRECISION_FP_L),   -- Floating Negative Multiply and Subtract
--    (x"F", SINGE_PRECISION, RRR, SINGE_PRECISION_FP_L),   -- Floating Multiply and Subtract
--    (x"3C2", SINGE_PRECISION, RR, SINGE_PRECISION_FP_L),  -- Floating Compare Equal
--    (x"3CA", SINGE_PRECISION, RR, SINGE_PRECISION_FP_L),  -- Floating Compare Magnitude Equal
--    (x"2C2", SINGE_PRECISION, RR, SINGE_PRECISION_FP_L),  -- Floating Compare Greater Than
--    (x"2CA", SINGE_PRECISION, RR, SINGE_PRECISION_FP_L),  -- Floating Compare Magnitude Greater Than
--    -------------------- FLOATING POINT INTEGER INSTRUCTIONS --------------------
--    (x"3C4", SINGE_PRECISION, RR, SINGE_PRECISION_I_L),  -- Multiply
--    (x"3CC", SINGE_PRECISION, RR, SINGE_PRECISION_I_L),  -- Multiply Unsigned
--    (x"74", SINGE_PRECISION, RI10, SINGE_PRECISION_I_L), -- Multiply Immediate
--    (x"75", SINGE_PRECISION, RI10, SINGE_PRECISION_I_L), -- Multiply Unsigned Immediate
--    (x"C", SINGE_PRECISION, RRR, SINGE_PRECISION_I_L),   -- Multiply and Add
--    (x"3C5", SINGE_PRECISION, RR, SINGE_PRECISION_I_L),  -- Multiply High
--    (x"3CE", SINGE_PRECISION, RR, SINGE_PRECISION_I_L),  -- Multiply High High Unsigned
--    -------------------- BYTE INSTRUCTIONS --------------------
--    (x"2B4", BYTE, RR, BYTE_L), -- Count Ones in Bytes
--    (x"D3", BYTE, RR, BYTE_L),  -- Average Bytes
--    (x"53", BYTE, RR, BYTE_L),  -- Absolute Differences of Bytes
--    (x"253", BYTE, RR, BYTE_L), -- Sum Bytes into Halfwords
--    -------------------- LOCAL STORE INSTRUCTIONS --------------------
--    (x"61", LOCAL_STORE, RI16, LOCAL_STORE_L), -- Load Quadword (a–form)
--    (x"34", LOCAL_STORE, RI10, LOCAL_STORE_L), -- Load Quadword (d-form)
--    (x"24", LOCAL_STORE, RI10, LOCAL_STORE_L), -- Store Quadword (d-form)
--    (x"51", LOCAL_STORE, RI16, LOCAL_STORE_L), -- Store Quadword (a-form)
--    (x"23", LOCAL_STORE, RR, LOCAL_STORE_L),   -- Read Instruction Block
--    (x"82", LOCAL_STORE, RI16, LOCAL_STORE_L), -- Immediate Load Half Word Upper
--    (x"81", LOCAL_STORE, RI16, LOCAL_STORE_L), -- Immediate Load Word
--    (x"21", LOCAL_STORE, RI18, LOCAL_STORE_L), -- Immediate load Address
--    (x"C1", LOCAL_STORE, RI16, LOCAL_STORE_L), -- Immediate OR Halfword Lower
--    -------------------- PERMUTE INSTRUCTIONS --------------------
--    (x"1FB", PERMUTE, RI7, PERMUTE_L), -- Shift Left Quadword by Bits Immediate
--    (x"1FF", PERMUTE, RI7, PERMUTE_L), -- Shift Left Quadword by Bytes Immediate
--    (x"1FC", PERMUTE, RI7, PERMUTE_L), -- Rotate Quadword by Bytes Immediate
--    (x"1F8", PERMUTE, RI7, PERMUTE_L), -- Rotate Quadword by Bits Immediate
--    -------------------- BRANCH INSTRUCTIONS --------------------
--    (x"64", BRANCH, RI16, BRANCH_L), -- Branch Relative
--    (x"60", BRANCH, RI16, BRANCH_L), -- Branch Absolute
--    (x"1A8", BRANCH, RR, BRANCH_L),  -- Branch Indirect
--    (x"42", BRANCH, RI16, BRANCH_L), -- Branch If Not Zero Word
--    (x"40", BRANCH, RI16, BRANCH_L), -- Branch If Zero Word
--    (x"128", BRANCH, RR, BRANCH_L),  -- Branch Indirect If Zero
--    (x"129", BRANCH, RI7, BRANCH_L), -- Branch Indirect If Not Zero
--    -------------------- CONTROL INSTRUCTIONS --------------------
--    (x"0", CONTROL, RR, SIMPLE_FIXED_1_L),  -- Stop and Signal
--    (x"1", CONTROL, RR, SIMPLE_FIXED_1_L),  -- Nop (Load)
--    (x"201", CONTROL, RR, SIMPLE_FIXED_1_L) -- Nop (Execute)
--);
end package SPU_CORE_ISA_PACKAGE;
