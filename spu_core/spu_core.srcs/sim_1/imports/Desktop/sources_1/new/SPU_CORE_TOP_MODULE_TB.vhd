--------------------------------------------------------------------------------
-- Company: Stony Brook University
-- Engineer: Wilmer Suarez
--
-- Create Date: 03/22/2019
-- Design Name: SPU Core Testbench
-- Tool versions: Vivado v2018.3 (64-bit)
-- Description:
--    Fills Local Store with the machine code produced 
--    by the assembler and executes the corresponding instructions.
--------------------------------------------------------------------------------
-------------------- LIBRARIES --------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.all;
use IEEE.STD_LOGIC_TEXTIO.all;
use work.COMPONENTS_PACKAGE.ALL;
use work.SPU_CORE_ISA_PACKAGE.ALL;
use work.CONSTANTS_PACKAGE.ALL;

-------------------- ENTITY DEFINITION --------------------
entity SPU_CORE_TOP_MODULE_TB is
end SPU_CORE_TOP_MODULE_TB;

-------------------- ARCHITECTURE DEFINITION --------------------
architecture behavioral of SPU_CORE_TOP_MODULE_TB is
-------------------- CLOCK --------------------
signal CLK                : STD_LOGIC := '1'; 
-------------------- LOCAL STORE SIGNALS --------------------
signal FILL               : STD_LOGIC := '0';
signal SRAM_INSTR         : sram_type := (others => (others => '0'));
signal DATA_OUT_LS        : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)     := (others => '0');
signal INSTR_BLOCK_OUT_LS : STD_LOGIC_VECTOR((INSTR_WIDTH_LS-1) downto 0) := (others => '0');
-------------------- TOP MODULE SIGNALS --------------------
signal RESULT_PACKET_EVEN_OUT : RESULT_PACKET_EVEN := ((others => '0'), (others => '0'), '0', 0);
signal RESULT_PACKET_ODD_OUT  : RESULT_PACKET_ODD  := ((others => '0'), (others => '0'), '0', 0, '0', (others => '0'), (others => '0'), '0');
signal LS_PC_OUT_EXE          : STD_LOGIC_VECTOR((LS_INSTR_SECTION_SIZE - 1) downto 0) := (others => '0');
signal LS_WE_OUT_EOP          : STD_LOGIC := '0';
signal LS_RIB_OUT_EOP         : STD_LOGIC := '0';
signal LS_DATA_OUT_EOP        : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)    := (others => '0');
signal LS_ADDR_OUT_EOP        : STD_LOGIC_VECTOR((ADDR_WIDTH_LS-1) downto 0) := (others => '0');
-------------------- CLOCK PERIOD --------------------
constant CLK_PERIOD : TIME := 10ns;
begin    
    -------------------- CLK GENERATION --------------------
    CLK <= not CLK after CLK_PERIOD/2;
    
    -------------------- INSTANTIATE UNIT UNDER TEST --------------------
    UUT : SPU_CORE_TOP_MODULE port map (
        ----- INPUTS -----
        CLK            => CLK,
        INSTR_BLOCK    => INSTR_BLOCK_OUT_LS, 
        LS_DATA_IN     => DATA_OUT_LS,
        ----- OUTPUTS -----
        RESULT_PACKET_EVEN_OUT => RESULT_PACKET_EVEN_OUT,
        RESULT_PACKET_ODD_OUT  => RESULT_PACKET_ODD_OUT, 
        LS_PC_OUT_EXE          => LS_PC_OUT_EXE,
        LS_WE_OUT_EOP          => LS_WE_OUT_EOP,
        LS_RIB_OUT_EOP         => LS_RIB_OUT_EOP,
        LS_DATA_OUT_EOP        => LS_DATA_OUT_EOP,
        LS_ADDR_OUT_EOP        => LS_ADDR_OUT_EOP
    ); 
    
    ------------------ INSTANTIATE LOCAL STORE --------------------
    LS : entity work.LOCAL_STORE port map (
        ----- INPUTS -----
        WE_LS      => LS_WE_OUT_EOP,  
        RIB_LS     => LS_RIB_OUT_EOP,
        FILL       => FILL,
        ADDR_LS    => LS_ADDR_OUT_EOP,
        DATA_IN_LS => LS_DATA_OUT_EOP,
        SRAM_INSTR => SRAM_INSTR,
        PC_LS      => LS_PC_OUT_EXE,
        ----- OUTPUTS -----
        DATA_OUT_LS        => DATA_OUT_LS, 
        INSTR_BLOCK_OUT_LS => INSTR_BLOCK_OUT_LS
    );
    
    -------------------- SPU CORE PROCESS --------------------
    SIMULUS_PROC : process
        variable LINE_READ     : LINE; -- Current Line Read
        file file_MACHINE_CODE : TEXT; -- File containing Instruction machine code
        variable INSTR         : STD_LOGIC_VECTOR((INSTR_SIZE-1) downto 0) := (others => '0'); -- Instruction Read 
        variable INSTR_LINE    : STD_LOGIC_VECTOR((INSTR_SIZE-1) downto 0) := (others => '0'); -- Full LS Line of Instructions
        variable LS_ADDR       : NATURAL := 0;  -- Current LS Address
        constant machine_code  : STRING := "C:\Users\Wilmer Suarez\Desktop\SPU_Multimedia_Processor\assembler\output\data";
    begin             
        file_open(file_MACHINE_CODE, machine_code, read_mode); -- Open File
        
        ----- Read & Process the Machine Code -----
        while (not endfile(file_MACHINE_CODE)) loop
            readline(file_MACHINE_CODE, LINE_READ); -- Read next line of file (contains one instruction)
            hread(LINE_READ, INSTR);                -- Read the Instruction Line
             
            INSTR_LINE := INSTR; -- Read next Line
            
            -- Send the instruction read to the Local Store --
            FILL <= '1'; -- Allow filling of the Local Store
            SRAM_INSTR(LS_ADDR) <= INSTR_LINE;  -- Send current line to Local Store
            LS_ADDR := LS_ADDR + 1; -- Increment Address
        end loop;
        
        wait for CLK_PERIOD; -- Wait for data to be written
        FILL <= '0';
        
        file_close(file_MACHINE_CODE);
        wait;
    end process SIMULUS_PROC;
end behavioral;
