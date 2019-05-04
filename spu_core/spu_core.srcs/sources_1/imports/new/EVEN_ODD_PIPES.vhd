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
use work.CONSTANTS_PACKAGE.ALL;

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
        PC_BRNCH                   : out STD_LOGIC_VECTOR((LS_INSTR_SECTION_SIZE - 1) downto 0); -- Next value of the PC when branching
        BRANCH_FLUSH               : out STD_LOGIC := '0'; -- Flush Flag when Branch mispredict
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
    begin
            ----- RESET FLUSH SIGNAL -----
            if(rising_edge(CLK)) then
                BRANCH_FLUSH <= '0';
            end if;
            
            case EVEN_OPCODE_EOP is
                -------------------- SIMPLE FIXED 1 --------------------
                when "00011000000" => -- Add Word
                    RESULT_EVEN.RESULT(31 downto 0)   <= STD_LOGIC_VECTOR(SIGNED(RA_EVEN_DATA_EOP(31 downto 0)) + SIGNED(RB_EVEN_DATA_EOP(31 downto 0)));                    
                    RESULT_EVEN.RESULT(63 downto 32)  <= STD_LOGIC_VECTOR(SIGNED(RA_EVEN_DATA_EOP(63 downto 32)) + SIGNED(RB_EVEN_DATA_EOP(63 downto 32)));                    
                    RESULT_EVEN.RESULT(95 downto 64)  <= STD_LOGIC_VECTOR(SIGNED(RA_EVEN_DATA_EOP(95 downto 64)) + SIGNED(RB_EVEN_DATA_EOP(95 downto 64)));                    
                    RESULT_EVEN.RESULT(127 downto 96) <= STD_LOGIC_VECTOR(SIGNED(RA_EVEN_DATA_EOP(127 downto 96)) + SIGNED(RB_EVEN_DATA_EOP(127 downto 96)));  
                    RESULT_EVEN.REG_DEST              <= EVEN_REG_DEST_EOP;
                    RESULT_EVEN.RW                    <= '1'; 
                    RESULT_EVEN.LATENCY               <= SIMPLE_FIXED_1_L; 
                when "---00011100" => -- Add Word Immediate
                    RESULT_EVEN.RESULT(31 downto 0)   <= STD_LOGIC_VECTOR(SIGNED(RA_EVEN_DATA_EOP(31 downto 0)) + resize(SIGNED(EVEN_RI10_EOP), EXT_WIDTH)); 
                    RESULT_EVEN.RESULT(63 downto 32)  <= STD_LOGIC_VECTOR(SIGNED(RA_EVEN_DATA_EOP(63 downto 32)) + resize(SIGNED(EVEN_RI10_EOP), EXT_WIDTH));                    
                    RESULT_EVEN.RESULT(95 downto 64)  <= STD_LOGIC_VECTOR(SIGNED(RA_EVEN_DATA_EOP(95 downto 64)) + resize(SIGNED(EVEN_RI10_EOP), EXT_WIDTH));                    
                    RESULT_EVEN.RESULT(127 downto 96) <= STD_LOGIC_VECTOR(SIGNED(RA_EVEN_DATA_EOP(127 downto 96)) + resize(SIGNED(EVEN_RI10_EOP), EXT_WIDTH));                                       
                    RESULT_EVEN.REG_DEST              <= EVEN_REG_DEST_EOP;
                    RESULT_EVEN.RW                    <= '1'; 
                    RESULT_EVEN.LATENCY               <= SIMPLE_FIXED_1_L; 
                when "00001000000" => -- Subtract from Word
                
                when "---00001100" => -- Subtract from Word Immediate
                
                when "01010100101" => -- Count Leading Zeros
                
                when "00011000001" => -- AND
                
                when "01011000001" => -- AND with Complement
                
                when "---00010100" => -- AND Word Immediate
                    
                when "00001000001" => -- OR
                
                when "01011001001" => -- OR with Complement
                
                when "---00000100" => -- OR Word Immediate
                
                when "00111110000" => -- OR Across
                
                when "01001000001" => -- Exclusive OR
                
                when "00011001001" => -- NAND
                
                when "00001001001" => -- NOR
                
                when "01111000000" => -- Compare Equal Word
                
                when "---01111100" => -- Compare Equal Word Immediate
                
                when "01001000000" => -- Compare Greater Than Word
                
                when "---01001100" => -- Compare Greater Than Word Immediate
                
                when "01011000000" => -- Compare Logical Greater Than Word
                
                when "---01011100" => -- Compare Logical Greater Than Word Immediate
                
                -------------------- SIMPLE FIXED 2 --------------------
                when "00001111011" => -- Shift Left Word Immediate
                
                when "00001111100" => -- Rotate Halfword Immediate
                    
                when "00001111000" => -- Rotate Word Immediate
                
                -------------------- FLOATING POINT INSTRUCTIONS --------------------
                when "01011000100" => -- Floating Add
                
                when "01011000101" => -- Floating Subtract
                
                when "01011000110" => -- Floating Multiply
                
                when "-------1110" => -- Floating Multiply and Add
                
                when "-------1101" => -- Floating Negative Multiply and Subtract
                
                when "-------1111" => -- Floating Multiply and Subtract
                
                when "01111000010" => -- Floating Compare Equal
                
                when "01111001010" => -- Floating Compare Magnitude Equal
                
                when "01011000010" => -- Floating Compare Greater Than
                
                when "01011001010" => -- Floating Compare Magnitude Greater Than
                
                -------------------- FLOATING POINT INTEGER INSTRUCTIONS --------------------
                when "01111000100" => -- Multiply
                
                when "01111001100" => -- Multiply Unsigned
                
                when "---01110100" => -- Multiply Immediate
                
                when "---01110101" => -- Multiply Unsigned Immediate
                
                when "-------1100" => -- Multiply and Add
                    
                when "01111000101" => -- Multiply High
                
                when "01111001110" => -- Multiply High High Unsigned
                
                -------------------- BYTE INSTRUCTIONS --------------------
                when "01010110100" => -- Count Ones in Bytes
                
                when "00011010011" => -- Average Bytes
                
                when "00001010011" => -- Absolute Differences of Bytes
                
                when "01001010011" => -- Sum Bytes into Halfwords
                
                when "00000000001" => -- NOP (Load)
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
    begin
        case ODD_OPCODE_EOP is
            -------------------- LOCAL STORE INSTRUCTIONS --------------------
            when "--001100001" => -- Load Quadword (a-form)
                LS_ADDR_OUT_EOP     <= STD_LOGIC_VECTOR(resize(UNSIGNED(ODD_RI16_EOP), ADDR_WIDTH_LS));
                RESULT_ODD.RESULT   <= LOCAL_STORE_DATA_EOP; 
                RESULT_ODD.REG_DEST <= ODD_REG_DEST_EOP; 
                RESULT_ODD.RW       <= '1'; 
                RESULT_ODD.LATENCY  <= LOCAL_STORE_L; 
            when "---00110100" => -- Load Quadword (d-form)
            
            when "---00100100" => -- Store Quadword (d-form)
            
            when "--001000001" => -- Store Quadword (a-form)
            
            when "00000100011" => -- Read Instruction Block
            
            when "--010000010" => -- Immediate Load Half Word Upper
            
            when "--010000001" => -- Immediate Load Word
            
            when "----0100001" => -- Immediate load Address
           
            when "--011000001" => -- Immediate OR Halfword Lower
            
            -------------------- PERMUTE INSTRUCTIONS --------------------
            when "00111111011" => -- Shift Left Quadword by Bits Immediate
            
            when "00111111111" => -- Shift Left Quadword by Bytes Immediate
            
            when "00111111100" => -- Rotate Quadword by Bytes Immediate
            
            when "00111111000" => -- Rotate Quadword by Bits Immediate
            
            -------------------- BRANCH INSTRUCTIONS --------------------
            when "--001100100" => -- Branch Relative
            
            when "--001100000" => -- Branch Absolute
            
            when "00110101000" => -- Branch Indirect
            
            when "--001000010" => -- Branch If Not Zero Word
            
            when "--001000000" => -- Branch If Zero Word
            
            when "00100101000" => -- Branch Indirect If Zero
            
            when "00100101001" => -- Branch Indirect If Not Zero
            
            when "01000000001" => -- NOP (Execute)
                RESULT_ODD.RESULT   <= STD_LOGIC_VECTOR(to_unsigned(0, DATA_WIDTH));
                RESULT_ODD.REG_DEST <= STD_LOGIC_VECTOR(to_unsigned(0, ADDR_WIDTH)); 
                RESULT_ODD.RW       <= '0'; 
                RESULT_ODD.LATENCY  <= NOP_L;
            when others =>
                -- Do nothing
        end case;
    end process ODD_PIPE_PROC;
end behavioral;
		