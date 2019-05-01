--------------------------------------------------------------------------------
-- Company: Stony Brook University
-- Engineer: Wilmer Suarez
--
-- Create Date: 03/21/2019
-- Design Name: Even Pipe
-- Tool versions: Vivado v2018.3 (64-bit)
-- Description:
--     The Even & Odd Pipelines take input from the forwarding macro and, according
--     to the Opcode, calculates a result in the corresponding execution unit.
--
--     A Result Packet is created and sent to the Forwarding Circuits going
--     towards the Write Back stage once the result is calucalted. The only 
--     exception is the Branch Unit, which does nothing or flushes the entire system
--     (including any instrucitons that came before it) if a missprediction occurred.
--
--     Execution Units:
--         - Simple Fixed 1 Unit
--         - Simple Fixed 2 Unit
--         - Single Precision Unit
--         - Byte Unit
--         - Permute Unit
--         - Local Store Unit
--         - Branch Unit
--------------------------------------------------------------------------------
-------------------- LIBRARIES --------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.COMPONENTS_PACKAGE.ALL;
use work.SPU_CORE_ISA_PACKAGE.ALL; -- Contains all instructions in ISA

-------------------- ENTITY DEFINITION --------------------
entity even_odd_pipes is
    port (
        -------------------- INPUTS --------------------
        CLK               : in STD_LOGIC; -- System Wide Synchronous 
        EVEN_RI7_EOP      : in STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0);     -- Even Immediate RI7
        EVEN_RI10_EOP     : in STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0);    -- Even Immediate RI10
        EVEN_RI16_EOP     : in STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0);    -- Even Immediate RI16
        EVEN_REG_DEST_EOP : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);    -- Even Write back Address (RT)
        ODD_RI7_EOP       : in STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0);     -- Odd Immediate RI7
        ODD_RI10_EOP      : in STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0);    -- Odd Immediate RI10
        ODD_RI16_EOP      : in STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0);    -- Odd Immediate RI16
        ODD_RI18_EOP      : in STD_LOGIC_VECTOR((RI18_WIDTH-1) downto 0);    -- Odd Immediate RI18
        ODD_REG_DEST_EOP  : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);    -- Odd Write back Address (RT)
        RA_EVEN_DATA_EOP  : in STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);    -- Even Pipe RA Data
        RB_EVEN_DATA_EOP  : in STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);    -- Even Pipe RB Data
        RC_EVEN_DATA_EOP  : in STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);    -- Even Pipe RC Data    
        RA_ODD_DATA_EOP   : in STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);    -- Odd Pipe RA Data
        RB_ODD_DATA_EOP   : in STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);    -- Odd Pipe RB Data
        RC_ODD_DATA_EOP   : in STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);    -- Odd Pipe RC Data
        EVEN_OPCODE_EOP   : in STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0);  -- Even Instruction Opcode
        ODD_OPCODE_EOP    : in STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0);  -- Odd Instruction Opcode
        LOCAL_STORE_DATA_EOP : in STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0); -- Data from Local Store
        -------------------- OUTPUTS --------------------
        LS_WE_OUT_EOP              : out STD_LOGIC := '0'; -- Local Store Write Enable Control Signal
        LS_RIB_OUT_EOP             : out STD_LOGIC := '0'; -- Local Store Read Instruction Block Signal
        LS_DATA_OUT_EOP            : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)    := (others => '0');  -- Data to write into LS
        LS_ADDR_OUT_EOP            : out STD_LOGIC_VECTOR((ADDR_WIDTH_LS-1) downto 0) := (others => '0');  -- Local Store Address
        RESULT_PACKET_EVEN_OUT_EOP : out RESULT_PACKET_EVEN := ((others => '0'), (others => '0'), '0', 0); -- Result Packet from Even Execution Units 
        RESULT_PACKET_ODD_OUT_EOP  : out RESULT_PACKET_ODD  := ((others => '0'), (others => '0'), '0', 0)  -- Result Packet from Odd Execution Units
    );
end even_odd_pipes;

-------------------- ARCHITECTURE DEFINITION --------------------
architecture behavioral of even_odd_pipes is
----- INSTRUCTION RESULTS -----
signal RESULT_EVEN : RESULT_PACKET_EVEN := ((others => '0'), (others => '0'), '0', 0);
signal RESULT_ODD  : RESULT_PACKET_ODD  := ((others => '0'), (others => '0'), '0', 0);
constant EXT_WIDTH : NATURAL := 32; -- Length of Extended Immediates
begin

    ----- OUTPUT EVEN PIPE RESULTS -----
    RESULT_PACKET_EVEN_OUT_EOP <= RESULT_EVEN;
    
    -------------------- EVEN PIPE PROCESS --------------------
    EVEN_PIPE_PROC : process (CLK) is
    variable EVEN_OP : INTEGER; -- Integer conversion of Even Opcode
    begin
            EVEN_OP := to_integer(SIGNED(EVEN_OPCODE_EOP));
            case EVEN_OP is
                -------------------- SIMPLE FIXED 1 --------------------
                when 16#C0# =>  -- Add Word
                    RESULT_EVEN.RESULT(31 downto 0)   <= STD_LOGIC_VECTOR(SIGNED(RA_EVEN_DATA_EOP(31 downto 0)) + SIGNED(RB_EVEN_DATA_EOP(31 downto 0)));                    
                    RESULT_EVEN.RESULT(63 downto 32)  <= STD_LOGIC_VECTOR(SIGNED(RA_EVEN_DATA_EOP(63 downto 32)) + SIGNED(RB_EVEN_DATA_EOP(63 downto 32)));                    
                    RESULT_EVEN.RESULT(95 downto 64)  <= STD_LOGIC_VECTOR(SIGNED(RA_EVEN_DATA_EOP(95 downto 64)) + SIGNED(RB_EVEN_DATA_EOP(95 downto 64)));                    
                    RESULT_EVEN.RESULT(127 downto 96) <= STD_LOGIC_VECTOR(SIGNED(RA_EVEN_DATA_EOP(127 downto 96)) + SIGNED(RB_EVEN_DATA_EOP(127 downto 96)));  
                    RESULT_EVEN.REG_DEST              <= EVEN_REG_DEST_EOP;
                    RESULT_EVEN.RW                    <= '1'; 
                    RESULT_EVEN.LATENCY               <= SIMPLE_FIXED_1_L; 
                when 16#1C# =>  -- Add Word Immediate
                    RESULT_EVEN.RESULT(31 downto 0)   <= STD_LOGIC_VECTOR(SIGNED(RA_EVEN_DATA_EOP(31 downto 0)) + resize(SIGNED(EVEN_RI10_EOP), EXT_WIDTH)); 
                    RESULT_EVEN.RESULT(63 downto 32)  <= STD_LOGIC_VECTOR(SIGNED(RA_EVEN_DATA_EOP(63 downto 32)) + resize(SIGNED(EVEN_RI10_EOP), EXT_WIDTH));                    
                    RESULT_EVEN.RESULT(95 downto 64)  <= STD_LOGIC_VECTOR(SIGNED(RA_EVEN_DATA_EOP(95 downto 64)) + resize(SIGNED(EVEN_RI10_EOP), EXT_WIDTH));                    
                    RESULT_EVEN.RESULT(127 downto 96) <= STD_LOGIC_VECTOR(SIGNED(RA_EVEN_DATA_EOP(127 downto 96)) + resize(SIGNED(EVEN_RI10_EOP), EXT_WIDTH));                                       
                    RESULT_EVEN.REG_DEST              <= EVEN_REG_DEST_EOP;
                    RESULT_EVEN.RW                    <= '1'; 
                    RESULT_EVEN.LATENCY               <= SIMPLE_FIXED_1_L; 
                when 16#43# =>  -- Subtract from Word
                
                when 16#FC# =>  -- Subtract from Word Immediate
                
                when 16#2A5# => -- Count Leading Zeros
                
                when 16#C2# =>  -- AND
                
                when 16#2C1# => -- AND with Complement
                
                when 16#14# =>  -- AND Word Immediate
                
                when 16#41# =>  -- OR
                
                when 16#2C9# => -- OR with Complement
                
                when 16#4# =>   -- OR Word Immediate
                
                when 16#1F0# => -- OR Across
                
                when 16#241# => -- Exclusive OR
                
                when 16#C9# =>  -- NAND
                
                when 16#49# =>  -- NOR
                
                when 16#3C0# => -- Compare Equal Word
                
                when 16#7C# =>  -- Compare Equal Word Immediate
                
                when 16#240# => -- Compare Greater Than Word
                
                when 16#4C# =>  -- Compare Greater Than Word Immediate
                
                when 16#2C0# => -- Compare Logical Greater Than Word
                
                when 16#5C# =>  -- Compare Logical Greater Than Word Immediate
                
                -------------------- SIMPLE FIXED 2 --------------------
                when 16#7B# =>  -- Shift Left Word Immediate
                
                when 16#8C# =>  -- Rotate Halfword Immediate
                
                when 16#78# =>  -- Rotate Word Immediate
                
                -------------------- FLOATING POINT INSTRUCTIONS --------------------
                when 16#2C4# => -- Floating Add
                
                when 16#2C5# => -- Floating Subtract
                
                when 16#2C6# => -- Floating Multiply
                
                when 16#E# =>   -- Floating Multiply and Add
                
                when 16#D# =>   -- Floating Negative Multiply and Subtract
                
                when 16#F# =>   -- Floating Multiply and Subtract
                
                when 16#3C2# => -- Floating Compare Equal
                
                when 16#3CA# => -- Floating Compare Magnitude Equal
                
                when 16#2C2# => -- Floating Compare Greater Than
                
                when 16#2CA# => -- Floating Compare Magnitude Greater Than
                
                -------------------- FLOATING POINT INTEGER INSTRUCTIONS --------------------
                when 16#3C4# => -- Multiply
                
                when 16#3CC# => -- Multiply Unsigned
                
                when 16#74# =>  -- Multiply Immediate
                
                when 16#75# =>  -- Multiply Unsigned Immediate
                
                when 16#C# =>   -- Multiply and Add
                
                when 16#3C5# => -- Multiply High
                
                when 16#3CE# => -- Multiply High High Unsigned
                
                -------------------- BYTE INSTRUCTIONS --------------------
                when 16#2B4# => -- Count Ones in Bytes
                
                when 16#D3# =>  -- Average Bytes
                
                when 16#53# =>  -- Absolute Differences of Bytes
                
                when 16#253# => -- Sum Bytes into Halfwords
                
                when 16#1# =>   -- NOP (Load)
                    RESULT_EVEN.RESULT   <= STD_LOGIC_VECTOR(to_unsigned(0, DATA_WIDTH));
                    RESULT_EVEN.REG_DEST <= STD_LOGIC_VECTOR(to_unsigned(0, ADDR_WIDTH));
                    RESULT_EVEN.RW       <= '0'; 
                    RESULT_EVEN.LATENCY  <= NOP_L;
                when others =>
                    -- Do nothing
            end case;
    end process EVEN_PIPE_PROC;
    
    ----- OUTPUT EVEN PIPE RESULTS -----
    RESULT_PACKET_ODD_OUT_EOP <= RESULT_ODD;
    
    -------------------- ODD PIPE PROCESS --------------------
    ODD_PIPE_PROC : process (CLK) is
    variable ODD_OP : INTEGER; -- Integer conversion of Odd Opcode
    begin
        ODD_OP := to_integer(SIGNED(ODD_OPCODE_EOP));
        case ODD_OP is
            -------------------- LOCAL STORE INSTRUCTIONS --------------------
            when 16#61# =>  -- Load Quadword (a-form)
                LS_ADDR_OUT_EOP     <= STD_LOGIC_VECTOR(resize(UNSIGNED(ODD_RI16_EOP), ADDR_WIDTH_LS));
                RESULT_ODD.RESULT   <= LOCAL_STORE_DATA_EOP; 
                RESULT_ODD.REG_DEST <= ODD_REG_DEST_EOP; 
                RESULT_ODD.RW       <= '1'; 
                RESULT_ODD.LATENCY  <= LOCAL_STORE_L; 
            when 16#34# =>  -- Load Quadword (d-form)
            
            when 16#24# =>  -- Store Quadword (d-form)
            
            when 16#51# =>  -- Store Quadword (a-form)
            
            when 16#23# =>  -- Read Instruction Block
            
            when 16#82# =>  -- Immediate Load Half Word Upper
            
            when 16#81# =>  -- Immediate Load Word
            
            when 16#21# =>  -- Immediate load Address
            
            when 16#C1# =>  -- Immediate OR Halfword Lower
            
            -------------------- PERMUTE INSTRUCTIONS --------------------
            when 16#1FB# => -- Shift Left Quadword by Bits Immediate
            
            when 16#1FF# => -- Shift Left Quadword by Bytes Immediate
            
            when 16#1FC# => -- Rotate Quadword by Bytes Immediate
            
            when 16#1F8# => -- Rotate Quadword by Bits Immediate
            
            -------------------- BRANCH INSTRUCTIONS --------------------
            when 16#64# =>  -- Branch Relative
            
            when 16#60# =>  -- Branch Absolute
            
            when 16#1A8# => -- Branch Indirect
            
            when 16#42# =>  -- Branch If Not Zero Word
            
            when 16#40# =>  -- Branch If Zero Word
            
            when 16#128# => -- Branch Indirect If Zero
            
            when 16#129# => -- Branch Indirect If Not Zero
            
            when 16#201# => -- NOP (Execute)
                RESULT_ODD.RESULT   <= STD_LOGIC_VECTOR(to_unsigned(0, DATA_WIDTH));
                RESULT_ODD.REG_DEST <= STD_LOGIC_VECTOR(to_unsigned(0, ADDR_WIDTH)); 
                RESULT_ODD.RW       <= '0'; 
                RESULT_ODD.LATENCY  <= NOP_L;
            when others =>
                -- Do nothing
        end case;
    end process ODD_PIPE_PROC;
end behavioral;
		