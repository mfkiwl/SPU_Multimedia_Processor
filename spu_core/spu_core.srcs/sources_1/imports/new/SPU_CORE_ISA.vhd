-------------------- LIBRARIES --------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.CONSTANTS_PACKAGE.ALL;

-------------------- PACKAGE DECLARATION --------------------
package SPU_CORE_ISA_PACKAGE is
----- Execution Units -----
type EXE_UNIT is (SIMPLE_FIXED_1, SIMPLE_FIXED_2, SINGE_PRECISION, BYTE, PERMUTE, LOCAL_STORE, BRANCH, HALT);
type FORMAT is (RR, RRR, RI7, RI10, RI16, RI18);

----- EVEN EXECUTION UNITS RESULT PACKET -----
type result_packet_even is record
    RESULT   : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0); -- Current Instruction Execution Unit Result
    REG_DEST : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); -- Register File Destination Address
    RW       : STD_LOGIC; -- Register File Register Write Control Signal
    LATENCY  : NATURAL;   -- Latency of Current Instruction 
end record result_packet_even;

----- ODD EXECUTION UNITS RESULT PACKET -----
type result_packet_odd is record
    RESULT        : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0); -- Current Instruction Execution Unit Result
    REG_DEST      : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); -- Register File Destination Address
    RW            : STD_LOGIC; -- Register File Register Write Control Signal
    LATENCY       : NATURAL;   -- Latency of Current Instruction 
    BRANCH_FLUSH  : STD_LOGIC; -- Flush flag
    INSTR_BLOCK   : STD_LOGIC_VECTOR((INSTR_WIDTH_LS-1) downto 0); -- 32-instruction Block
    PC_BRANCH     : STD_LOGIC_VECTOR((LS_INSTR_SECTION_SIZE - 1) downto 0); -- PC target
    WRITE_CACHE   : STD_LOGIC; -- Cache write enable
end record result_packet_odd;

----- Forwarding Circuit Array Type - Even -----
type FC_EVEN is array (0 to (FC_DEPTH-1)) of result_packet_even;
    
----- Forwarding Circuit Array Type - Odd -----
type FC_ODD is array (0 to (FC_DEPTH-1)) of result_packet_odd;

----- Even Pipe Forwarding Circuit -----
signal EVEN_PIPE_FC : FC_EVEN := (others =>((others => '0'), (others => '0'), '0', 0));
----- Odd Pipe Forwarding Circuit -----
signal ODD_PIPE_FC : FC_ODD := (others =>((others => '0'), (others => '0'), '0', 0, '0', (others => '0'), (others => '0'), '0'));

----- DEPEPENDENCY CHECK FOR RF -----
type PREV_DATA is record
    REG_DEST   : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); -- Old register destinatino
    DONT_CHECK : BOOLEAN; -- Dont check the instruction? (NOP? or same one because of stall)
end record;

----- INSTRUCTION DATA -----
type INSTR_DATA is record
    OP_CODE  : STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0); -- Instruction Opcode
    UNIT     : EXE_UNIT; -- Execution Unit Type
    FORMAT   : FORMAT;   -- Instruction Format
    RA_ADDR  : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); -- RA Register File Address
    RB_ADDR  : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); -- RB Register File Address
    RC_ADDR  : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); -- RC Register File Address
    RI7      : STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0);  -- Immediate 7-bit
    RI10     : STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0); -- Immediate 10-bit
    RI16     : STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0); -- Immediate 16-bit
    RI18     : STD_LOGIC_VECTOR((RI18_WIDTH-1) downto 0); -- Immediate 18-bit
    REG_DEST : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); -- Destination Register
    INSTR    : STD_LOGIC_VECTOR((INSTR_SIZE-1) downto 0); -- Full 32-bit Instruction
end record;

----- INSTRUCTION STRUCTURE -----
type INSTR_STRUCTURE is record
    OPCODE : STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0); -- Instruction Op-code
    UNIT   : EXE_UNIT;  -- Execution Unit Type
    FORMAT : FORMAT;    -- Instruction Format
    HALT   : STD_LOGIC; -- Flag for STOP instruction
end record INSTR_STRUCTURE;

----- INSTRUCTION PAIR STRUCTURE -----
type INSTR_PAIR_STRUCTURE is record
    EVEN_S        : INSTR_STRUCTURE; -- Even Pipe Instruction
    EVEN_INSTR    : STD_LOGIC_VECTOR((INSTR_SIZE-1) downto 0); -- Full 32-bit Even Instruction
    ODD_S         : INSTR_STRUCTURE; -- Odd Pipe Instruction
    ODD_INSTR     : STD_LOGIC_VECTOR((INSTR_SIZE-1) downto 0); -- Full 32-bit Odd Instruction
    STRUCT_HAZARD : STD_LOGIC; -- Structural hazard flag
    HAZARD_E_O    : STD_LOGIC; -- Hazard in Odd or Even Pipe? 
end record INSTR_PAIR_STRUCTURE;

type ISA_4 is array (0 to (OPCODE_WIDTH_4_COUNT-1)) of INSTR_STRUCTURE; 
constant ISA_TABLE_4 : ISA_4 := (
    ("-------1100", SINGE_PRECISION, RRR, '0'), -- Multiply and Add
    ("-------1110", SINGE_PRECISION, RRR, '0'), -- Floating Multiply and Add
    ("-------1101", SINGE_PRECISION, RRR, '0'), -- Floating Negative Multiply and Subtract
    ("-------1111", SINGE_PRECISION, RRR, '0')  -- Floating Multiply and Subtract
);

constant ISA_TABLE_7: INSTR_STRUCTURE := ("----0100001", LOCAL_STORE, RI18, '0'); -- Immediate load Address

type ISA_8 is array (0 to (OPCODE_WIDTH_8_COUNT-1)) of INSTR_STRUCTURE; 
constant ISA_TABLE_8 : ISA_8 := (
    ("---00110100", LOCAL_STORE, RI10, '0'),     -- Load Quadword (d-form),
    ("---00100100", LOCAL_STORE, RI10, '0'),     -- Store Quadword (d-form)
    ("---00011100", SIMPLE_FIXED_1, RI10, '0'),  -- Add Word Immediate
    ("---00001100", SIMPLE_FIXED_1, RI10, '0'),  -- Subtract from Word Immediate
    ("---00010100", SIMPLE_FIXED_1, RI10, '0'),  -- AND Word Immediate
    ("---00000100", SIMPLE_FIXED_1, RI10, '0'),  -- OR Word Immediate
    ("---01111100", SIMPLE_FIXED_1, RI10, '0'),  -- Compare Equal Word Immediate
    ("---01001100", SIMPLE_FIXED_1, RI10, '0'),  -- Compare Greater Than Word Immediate
    ("---01011100", SIMPLE_FIXED_1, RI10, '0'),  -- Compare Logical Greater Than Word Immediate
    ("---01110100", SINGE_PRECISION, RI10, '0'), -- Multiply Immediate
    ("---01110101", SINGE_PRECISION, RI10, '0')  -- Multiply Unsigned Immediate
);

type ISA_9 is array (0 to (OPCODE_WIDTH_9_COUNT-1)) of INSTR_STRUCTURE; 
constant ISA_TABLE_9 : ISA_9 := (
    ("--001100001", LOCAL_STORE, RI16, '0'), -- Load Quadword (a-form)
    ("--001000001", LOCAL_STORE, RI16, '0'), -- Store Quadword (a-form)
    ("--010000010", LOCAL_STORE, RI16, '0'), -- Immediate Load Half Word Upper
    ("--010000001", LOCAL_STORE, RI16, '0'), -- Immediate Load Word
    ("--011000001", LOCAL_STORE, RI16, '0'), -- Immediate OR Halfword Lower
    ("--001100100", BRANCH, RI16, '0'),      -- Branch Relative
    ("--001100000", BRANCH, RI16, '0'),      -- Branch Absolute
    ("--001000010", BRANCH, RI16, '0'),      -- Branch If Not Zero Word
    ("--001000000", BRANCH, RI16, '0')       -- Branch If Zero Word
);

-- ARRAY OF ALL INSTRUCTIONS IN ISA --
type ISA_11 is array (0 to (OPCODE_WIDTH_11_COUNT-1)) of INSTR_STRUCTURE; 
constant ISA_TABLE_11 : ISA_11 := (
    ("00000100011", LOCAL_STORE, RR, '0'),     -- Read Instruction Block
    ("00011000000", SIMPLE_FIXED_1, RR, '0'),  -- Add Word
    ("00001000000", SIMPLE_FIXED_1, RR, '0'),  -- Subtract from Word
    ("01010100101", SIMPLE_FIXED_1, RR, '0'),  -- Count Leading Zeros
    ("00011000001", SIMPLE_FIXED_1, RR, '0'),  -- AND
    ("01011000001", SIMPLE_FIXED_1, RR, '0'),  -- AND with Complement
    ("00001000001", SIMPLE_FIXED_1, RR, '0'),  -- OR
    ("01011001001", SIMPLE_FIXED_1, RR, '0'),  -- OR with Complement
    ("00111110000", SIMPLE_FIXED_1, RR, '0'),  -- OR Across
    ("01001000001", SIMPLE_FIXED_1, RR, '0'),  -- Exclusive OR
    ("00011001001", SIMPLE_FIXED_1, RR, '0'),  -- NAND
    ("00001001001", SIMPLE_FIXED_1, RR, '0'),  -- NOR
    ("01111000000", SIMPLE_FIXED_1, RR, '0'),  -- Compare Equal Word
    ("01001000000", SIMPLE_FIXED_1, RR, '0'),  -- Compare Greater Than Word
    ("01011000000", SIMPLE_FIXED_1, RR, '0'),  -- Compare Logical Greater Than Word
    ("01111000100", SINGE_PRECISION, RR, '0'), -- Multiply
    ("01111001100", SINGE_PRECISION, RR, '0'), -- Multiply Unsigned
    ("01111000101", SINGE_PRECISION, RR, '0'), -- Multiply High
    ("01111001110", SINGE_PRECISION, RR, '0'), -- Multiply High High Unsigned
    ("01010110100", BYTE, RR, '0'),            -- Count Ones in Bytes
    ("00011010011", BYTE, RR, '0'),            -- Average Bytes
    ("00001010011", BYTE, RR, '0'),            -- Absolute Differences of Bytes
    ("01001010011", BYTE, RR, '0'),            -- Sum Bytes into Halfwords
    ("00110101000", BRANCH, RR, '0'),          -- Branch Indirect
    ("00100101000", BRANCH, RR, '0'),          -- Branch Indirect If Zero
    ("01011000100", SINGE_PRECISION, RR, '0'), -- Floating Add
    ("01011000101", SINGE_PRECISION, RR, '0'), -- Floating Subtract
    ("01011000110", SINGE_PRECISION, RR, '0'), -- Floating Multiply
    ("01111000010", SINGE_PRECISION, RR, '0'), -- Floating Compare Equal
    ("01111001010", SINGE_PRECISION, RR, '0'), -- Floating Compare Magnitude Equal
    ("01011000010", SINGE_PRECISION, RR, '0'), -- Floating Compare Greater Than
    ("01011001010", SINGE_PRECISION, RR, '0'), -- Floating Compare Magnitude Greater Than
    ("00000000000", HALT, RR, '1'),            -- Stop and Signal (Handled in Instruction Fetch Stage)
    ("00000000001", SIMPLE_FIXED_1, RR, '0'),  -- Nop (Load)
    ("01000000001", PERMUTE, RR, '0'),         -- Nop (Execute)
    ("00111111011", PERMUTE, RI7, '0'),        -- Shift Left Quadword by Bits Immediate
    ("00111111111", PERMUTE, RI7, '0'),        -- Shift Left Quadword by Bytes Immediate
    ("00111111100", PERMUTE, RI7, '0'),        -- Rotate Quadword by Bytes Immediate
    ("00111111000", PERMUTE, RI7, '0'),        -- Rotate Quadword by Bits Immediate
    ("00001111011", SIMPLE_FIXED_2, RI7, '0'), -- Shift Left Word Immediate
    ("00001111100", SIMPLE_FIXED_2, RI7, '0'), -- Rotate Halfword Immediate
    ("00001111000", SIMPLE_FIXED_2, RI7, '0'), -- Rotate Word Immediate
    ("00100101001", BRANCH, RI7, '0')          -- Branch Indirect If Not Zero
);
    ----- Searches for the passsed in instructions and returns the assocaited ISA structure pair -----
    function instr_search (
        INSTR : STD_LOGIC_VECTOR((INSTR_PAIR_SIZE-1) downto 0)) -- Instruction to search for
    return INSTR_PAIR_STRUCTURE;
       
    ----- Gets the data required by the Instruction format -----
    function get_instr_data (
        INSTR        : STD_LOGIC_VECTOR((INSTR_SIZE-1) downto 0);
        INSTR_STRUCT : INSTR_STRUCTURE)
    return INSTR_DATA;
    
    ----- Checks if given Instruction has dependencies in stages after the dependency stage -----
    function check_dependencies (
        INSTR         : INSTR_DATA;
        OTHER_INSTR   : INSTR_DATA;
        PREV          : PREV_DATA;
        PREV_OTHER    : PREV_DATA;
        PREV_RF       : PREV_DATA;
        PREV_RF_OTHER : PREV_DATA;
        EVEN_FC       : FC_EVEN; -- Even Forwarding Circuit
        ODD_FC        : FC_ODD)  -- Odd Forwarding Circuit
    return BOOLEAN;
    
    ----- Checks Even and Odd Pipes for dependencies -----
    function check_pipes (
        REG_ADDR : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); -- Register Address being compared
        EVEN_FC  : FC_EVEN; -- Even Forwarding Circuit
        ODD_FC   : FC_ODD)  -- Odd Forwarding Circuit
    return BOOLEAN;
end package SPU_CORE_ISA_PACKAGE;

package body SPU_CORE_ISA_PACKAGE is
    ----- Checks the Forwarding Circuits for Dependencies -----
    function instr_search(INSTR : in STD_LOGIC_VECTOR((INSTR_PAIR_SIZE-1) downto 0)) -- Instruction to search for
                          return INSTR_PAIR_STRUCTURE is
        variable INSTR_PAIR_OUT : INSTR_PAIR_STRUCTURE; 
        variable INSTR_S_1      : INSTR_STRUCTURE;
        variable INSTR_S_2      : INSTR_STRUCTURE;
        variable OPCODE_1       : STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0) := (others => '0');
        variable OPCODE_2       : STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0) := (others => '0');
    begin
        -- Initialize Instruction Pair Struct --
        INSTR_PAIR_OUT.EVEN_INSTR    := (others => '0');
        INSTR_PAIR_OUT.ODD_INSTR     := (others => '0');
        INSTR_PAIR_OUT.STRUCT_HAZARD := '0';
        INSTR_PAIR_OUT.HAZARD_E_O    := '0';
        
        ----- Check 4-bit Size Opcodes -----
        OPCODE_1 := "-------" & INSTR((INSTR_SIZE-1) downto 28);
        OPCODE_2 := "-------" & INSTR((INSTR_PAIR_SIZE-1) downto 60);
        for i in 0 to (OPCODE_WIDTH_4_COUNT-1) loop  
            if(ISA_TABLE_4(i).OPCODE = OPCODE_1) then
                INSTR_S_1 := ISA_TABLE_4(i);
            end if;
            if(ISA_TABLE_4(i).OPCODE = OPCODE_2) then
                INSTR_S_2 := ISA_TABLE_4(i);
            end if;
        end loop;
        
        ----- Check 7-bit Size Opcodes -----
        OPCODE_1 := "----" & INSTR((INSTR_SIZE-1) downto 25);
        OPCODE_2 := "----" & INSTR((INSTR_PAIR_SIZE-1) downto 57);
        if(ISA_TABLE_7.OPCODE = OPCODE_1) then
            INSTR_S_1 := ISA_TABLE_7;
        end if;
        if(ISA_TABLE_7.OPCODE = OPCODE_2) then
            INSTR_S_2 := ISA_TABLE_7;
        end if;
        
        ----- Check 8-bit Size Opcodes -----
        OPCODE_1 := "---" & INSTR((INSTR_SIZE-1) downto 24);
        OPCODE_2 := "---" & INSTR((INSTR_PAIR_SIZE-1) downto 56);
        for i in 0 to (OPCODE_WIDTH_8_COUNT-1) loop  
            if(ISA_TABLE_8(i).OPCODE = OPCODE_1) then
                INSTR_S_1 := ISA_TABLE_8(i);
            end if;
            if(ISA_TABLE_8(i).OPCODE = OPCODE_2) then
                INSTR_S_2 := ISA_TABLE_8(i);
            end if;
        end loop;
        
        ----- Check 9-bit Size Opcodes -----
        OPCODE_1 := "--" & INSTR((INSTR_SIZE-1) downto 23);
        OPCODE_2 := "--" & INSTR((INSTR_PAIR_SIZE-1) downto 55);
        for i in 0 to (OPCODE_WIDTH_9_COUNT-1) loop  
            if(ISA_TABLE_9(i).OPCODE = OPCODE_1) then
                INSTR_S_1 := ISA_TABLE_9(i);
            end if;
            if(ISA_TABLE_9(i).OPCODE = OPCODE_2) then
                INSTR_S_2 := ISA_TABLE_9(i);
            end if;
        end loop;
        
        ----- Check 11-bit Size Opcodes -----
        OPCODE_1 := INSTR((INSTR_SIZE-1) downto 21);
        OPCODE_2 := INSTR((INSTR_PAIR_SIZE-1) downto 53);
        for i in 0 to (OPCODE_WIDTH_11_COUNT-1) loop  
            if(ISA_TABLE_11(i).OPCODE = OPCODE_1) then
                INSTR_S_1 := ISA_TABLE_11(i);
            end if;
            if(ISA_TABLE_11(i).OPCODE = OPCODE_2) then
                INSTR_S_2 := ISA_TABLE_11(i);
            end if;
        end loop;
        
        ----- HANDLE PIPE ASSINGMENTS, STRUCTURAL HAZARD, & STOP -----
        if(INSTR_S_2.HALT = '1') then
            INSTR_PAIR_OUT.ODD_S := INSTR_S_2;
            INSTR_PAIR_OUT.ODD_INSTR := INSTR((INSTR_PAIR_SIZE-1) downto 32);
            INSTR_PAIR_OUT.EVEN_S := INSTR_S_1;
            INSTR_PAIR_OUT.EVEN_INSTR := INSTR((INSTR_SIZE-1) downto 0);
        elsif((INSTR_S_1.UNIT = SIMPLE_FIXED_1 OR 
            INSTR_S_1.UNIT = SIMPLE_FIXED_2    OR
            INSTR_S_1.UNIT = SINGE_PRECISION   OR
            INSTR_S_1.UNIT = BYTE)             AND 
           (INSTR_S_2.UNIT = PERMUTE           OR
            INSTR_S_2.UNIT = LOCAL_STORE       OR
            INSTR_S_2.UNIT = BRANCH)) then
               -- Even Pipe Instruction --
               INSTR_PAIR_OUT.EVEN_S := INSTR_S_1;
               INSTR_PAIR_OUT.EVEN_INSTR := INSTR((INSTR_SIZE-1) downto 0);
               -- Odd Pipe Instruction --
               INSTR_PAIR_OUT.ODD_S := INSTR_S_2;
               INSTR_PAIR_OUT.ODD_INSTR := INSTR((INSTR_PAIR_SIZE-1) downto 32);
        elsif((INSTR_S_2.UNIT = SIMPLE_FIXED_1  OR 
               INSTR_S_2.UNIT = SIMPLE_FIXED_2  OR
               INSTR_S_2.UNIT = SINGE_PRECISION OR
               INSTR_S_2.UNIT = BYTE)           AND 
              (INSTR_S_1.UNIT = PERMUTE         OR
               INSTR_S_1.UNIT = LOCAL_STORE     OR
               INSTR_S_1.UNIT = BRANCH)) then
                  -- Even Pipe Instruction --
                  INSTR_PAIR_OUT.EVEN_S := INSTR_S_2;
                  INSTR_PAIR_OUT.EVEN_INSTR := INSTR((INSTR_PAIR_SIZE-1) downto 32);
                  -- Odd Pipe Instruction --
                  INSTR_PAIR_OUT.ODD_S := INSTR_S_1;
                  INSTR_PAIR_OUT.ODD_INSTR := INSTR((INSTR_SIZE-1) downto 0);
        elsif((INSTR_S_1.UNIT = SIMPLE_FIXED_1  OR 
               INSTR_S_1.UNIT = SIMPLE_FIXED_2  OR
               INSTR_S_1.UNIT = SINGE_PRECISION OR
               INSTR_S_1.UNIT = BYTE)           AND 
              (INSTR_S_2.UNIT = SIMPLE_FIXED_1  OR
               INSTR_S_2.UNIT = SIMPLE_FIXED_2  OR
               INSTR_S_2.UNIT = SINGE_PRECISION OR 
               INSTR_S_2.UNIT = BYTE)) then
                   ----- Both Instr going to Even Pipe -----
                   INSTR_PAIR_OUT.STRUCT_HAZARD := '1';
                   INSTR_PAIR_OUT.HAZARD_E_O := '0';
                   INSTR_PAIR_OUT.EVEN_S := INSTR_S_1;
                   INSTR_PAIR_OUT.EVEN_INSTR := INSTR((INSTR_SIZE-1) downto 0);
                   INSTR_PAIR_OUT.ODD_S := INSTR_S_2;
                   INSTR_PAIR_OUT.ODD_INSTR := INSTR((INSTR_PAIR_SIZE-1) downto 32);
        elsif((INSTR_S_1.UNIT = PERMUTE     OR 
               INSTR_S_1.UNIT = LOCAL_STORE OR
               INSTR_S_1.UNIT = BRANCH)     AND 
              (INSTR_S_2.UNIT = PERMUTE     OR
               INSTR_S_2.UNIT = LOCAL_STORE OR
               INSTR_S_2.UNIT = BRANCH)) then
                   ----- Both Instr going to Odd Pipe -----
                   INSTR_PAIR_OUT.STRUCT_HAZARD := '1';
                   INSTR_PAIR_OUT.HAZARD_E_O := '1';
                   INSTR_PAIR_OUT.EVEN_S := INSTR_S_2;
                   INSTR_PAIR_OUT.EVEN_INSTR := INSTR((INSTR_PAIR_SIZE-1) downto 32);
                   INSTR_PAIR_OUT.ODD_S := INSTR_S_1;
                   INSTR_PAIR_OUT.ODD_INSTR := INSTR((INSTR_SIZE-1) downto 0);
        end if;
        
        return INSTR_PAIR_OUT;
    end function instr_search;
       
    ----- Get the data required by the Instruction format -----
    function get_instr_data(INSTR : STD_LOGIC_VECTOR((INSTR_SIZE-1) downto 0);
                            INSTR_STRUCT : INSTR_STRUCTURE)
                            return INSTR_DATA is
        variable DATA : INSTR_DATA;
    begin
        case(INSTR_STRUCT.FORMAT) is
            when RR   =>
                DATA.RA_ADDR  := INSTR(13 downto 7);
                DATA.RB_ADDR  := INSTR(20 downto 14);
                DATA.RC_ADDR  := (others => '0');
                DATA.RI7      := (others => '0');
                DATA.RI10     := (others => '0');
                DATA.RI16     := (others => '0');
                DATA.RI18     := (others => '0');
                DATA.REG_DEST := INSTR(6 downto 0);
            when RRR  =>
                DATA.RA_ADDR  := INSTR(13 downto 7);
                DATA.RB_ADDR  := INSTR(20 downto 14);
                DATA.RC_ADDR  := INSTR(6 downto 0);
                DATA.RI7      := (others => '0');
                DATA.RI10     := (others => '0');
                DATA.RI16     := (others => '0');
                DATA.RI18     := (others => '0');
                DATA.REG_DEST := INSTR(27 downto 21);
            when RI7  =>
                
                DATA.RA_ADDR  := INSTR(13 downto 7);
                DATA.RB_ADDR  := (others => '0');
                DATA.RC_ADDR  := (others => '0');
                DATA.RI7      := INSTR(20 downto 14);
                DATA.RI10     := (others => '0');
                DATA.RI16     := (others => '0');
                DATA.RI18     := (others => '0');
                DATA.REG_DEST := INSTR(6 downto 0);
            when RI10 => 
                DATA.RA_ADDR  := INSTR(13 downto 7);
                DATA.RB_ADDR  := (others => '0');
                DATA.RC_ADDR  := (others => '0');
                DATA.RI7      := (others => '0');
                DATA.RI10     := INSTR(23 downto 14);
                DATA.RI16     := (others => '0');
                DATA.RI18     := (others => '0');
                DATA.REG_DEST := INSTR(6 downto 0);
            when RI16 =>
                DATA.RA_ADDR  := (others => '0');
                DATA.RB_ADDR  := (others => '0');
                DATA.RC_ADDR  := (others => '0');
                DATA.RI7      := (others => '0');
                DATA.RI10     := (others => '0');
                DATA.RI16     := INSTR(22 downto 7);
                DATA.RI18     := (others => '0');
                DATA.REG_DEST := INSTR(6 downto 0);
            when RI18 =>
                DATA.RA_ADDR  := (others => '0');
                DATA.RB_ADDR  := (others => '0');
                DATA.RC_ADDR  := (others => '0');
                DATA.RI7      := (others => '0');
                DATA.RI10     := (others => '0');
                DATA.RI16     := (others => '0');
                DATA.RI18     := INSTR(24 downto 7);
                DATA.REG_DEST := INSTR(6 downto 0);
        end case;
        
        DATA.OP_CODE := INSTR_STRUCT.OPCODE;
        DATA.UNIT    := INSTR_STRUCT.UNIT;
        DATA.FORMAT  := INSTR_STRUCT.FORMAT;
        DATA.INSTR   := INSTR;
        
        return DATA;
    end function get_instr_data;
    
    ----- Checks if given Instruction has dependencies in stages after the dependency stage -----
    function check_dependencies(INSTR         : INSTR_DATA; -- Instruction being checked
                                OTHER_INSTR   : INSTR_DATA; -- Instruction from same pair
                                PREV          : PREV_DATA;
                                PREV_OTHER    : PREV_DATA;
                                PREV_RF       : PREV_DATA;
                                PREV_RF_OTHER : PREV_DATA;
                                EVEN_FC       : FC_EVEN; -- Even Forwarding Circuit
                                ODD_FC        : FC_ODD)  -- Odd Forwarding Circuit)
                                return BOOLEAN is
        variable DEP  : BOOLEAN; -- Dependency can or cannot be resolved
        variable SKIP : BOOLEAN;
    begin
        DEP  := FALSE;
        SKIP := FALSE;
        
        ----- RI16 and RI18 formats, and instructions with no operands do not have any dependencies ----- 
        if((INSTR.FORMAT = RI16) OR (INSTR.FORMAT = RI18) OR
           (INSTR.OP_CODE = "00000100011") OR (INSTR.OP_CODE = "00000000001") OR
           (INSTR.OP_CODE = "01000000001")) then
            SKIP := TRUE;
        else
            ----- CHECK THE INSTRUCTION PAIR -----
--            if(OTHER_INSTR.OP_CODE /= "00000000001" AND 
--               OTHER_INSTR.OP_CODE /= "01000000001" AND 
--               OTHER_INSTR.OP_CODE /= "01000000001") then
--                if(INSTR.REG_DEST = OTHER_INSTR.REG_DEST) then
--                    DEP := TRUE;
--                end if;
--            end if;
            
            ----- CHECK PREV_EVEN -----
            if(NOT PREV.DONT_CHECK) then
                if(INSTR.REG_DEST = PREV.REG_DEST) then
                    DEP := TRUE;
                end if;
            end if;
            
            ----- CHECK PREV_ODD -----
            if(NOT PREV_OTHER.DONT_CHECK) then
                if(INSTR.REG_DEST = PREV_OTHER.REG_DEST) then
                    DEP := TRUE;
                end if;
            end if;
            
            ----- CHECK PREV_EVEN_RF -----
            if(NOT PREV_RF.DONT_CHECK) then
                if(INSTR.REG_DEST = PREV_RF.REG_DEST) then
                    DEP := TRUE;
                end if;
            end if;
            
            ----- CHECK PREV_ODD_RF -----
            if(NOT PREV_RF_OTHER.DONT_CHECK) then
                if(INSTR.REG_DEST = PREV_RF_OTHER.REG_DEST) then
                    DEP := TRUE;
                end if;
            end if;
        end if;
        
        ----- CHECK FOR DEPENDENCIES IN PIPES -----
        if((NOT DEP) AND (NOT SKIP)) then
            case(INSTR.FORMAT) is
                when RR =>
                    -- Search for RA Dependency --
                    if(check_pipes(INSTR.RA_ADDR, EVEN_FC, ODD_FC)) then
                        DEP := TRUE;
                    end if;
                    -- Search for RB Dependency --
                    if(check_pipes(INSTR.RB_ADDR, EVEN_FC, ODD_FC)) then
                        DEP := TRUE;
                    end if;
                when RRR =>
                    -- Search for RA Dependency --
                    if(check_pipes(INSTR.RA_ADDR, EVEN_FC, ODD_FC)) then
                        DEP := TRUE;
                    end if;
                    
                    -- Search for RB Dependency --
                    if(check_pipes(INSTR.RB_ADDR, EVEN_FC, ODD_FC)) then
                        DEP := TRUE;
                    end if;
                    
                    -- Search for RC Dependency --
                    if(check_pipes(INSTR.RC_ADDR, EVEN_FC, ODD_FC)) then
                        DEP := TRUE;
                    end if;
                when RI7 =>
                    -- Search for RA Dependency --
                    if(check_pipes(INSTR.RA_ADDR, EVEN_FC, ODD_FC)) then
                        DEP := TRUE;
                    end if;
                when RI10 =>
                    -- Search for RA Dependency --
                    if(check_pipes(INSTR.RA_ADDR, EVEN_FC, ODD_FC)) then
                        DEP := TRUE;
                    end if;
                when others =>
                    -- Do nothing
            end case; 
        end if;
        
        return DEP;
    end function check_dependencies;
    
    ----- Checks Even and Odd Pipes for dependencies -----
    function check_pipes (REG_ADDR : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); -- Register Address being compared
                          EVEN_FC  : FC_EVEN; -- Even Forwarding Circuit
                          ODD_FC   : FC_ODD)  -- Odd Forwarding Circuit
                          return BOOLEAN is
        variable DEP        : BOOLEAN := FALSE;
        variable INDEX_EVEN : NATURAL := 0;
        variable INDEX_ODD  : NATURAL := 0;
        variable I_FC       : NATURAL := 0;  -- Forwarding Circuit Index of Data
    begin
        INDEX_EVEN := 0;
        INDEX_ODD  := 0;
        DEP := FALSE;
        
        ----- Check Even Pipe -----
        while(I_FC < (FC_DEPTH-2)) loop  
            if (EVEN_FC(I_FC).REG_DEST = REG_ADDR) then
                INDEX_EVEN := I_FC; -- Update Even dependent instruction index
                exit;
            end if;
            I_FC := I_FC + 1;
        end loop;
        
        ----- Check Odd Pipe -----
        for i in 0 to (FC_DEPTH-2) loop  
            if (ODD_FC(i).REG_DEST = REG_ADDR) then
                if (i < I_FC) then
                    INDEX_ODD := i; -- Update Odd dependent instruction index
                end if;
                exit;
            end if;
        end loop;
        
        ----- Handle Latencies -----
        if(INDEX_ODD < INDEX_EVEN) then
            if((ODD_FC(INDEX_ODD).LATENCY - (INDEX_ODD+1)) > 1) then
                DEP := TRUE;
            end if;
        else 
            if((EVEN_FC(INDEX_EVEN).LATENCY - (INDEX_EVEN+1)) > 1) then
                DEP := TRUE;
            end if;
        end if;
        
        return DEP;
    end function check_pipes;
end package body SPU_CORE_ISA_PACKAGE;
