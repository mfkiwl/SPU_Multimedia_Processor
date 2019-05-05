-------------------- LIBRARIES --------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use STD.TEXTIO.all;
use work.SPU_CORE_ISA_PACKAGE.ALL;
use work.CONSTANTS_PACKAGE.ALL;
use work.COMPONENTS_PACKAGE.ALL;

-------------------- ENTITY DEFINITION --------------------
entity ls_fill_test_TB is
end ls_fill_test_TB;

-------------------- ARCHITECTURE DEFINITION --------------------
architecture behavioral of ls_fill_test_TB is
-------------------- CLOCK --------------------
signal CLK                : STD_LOGIC := '1';
signal WE_LS              : STD_LOGIC := '0'; 
signal RIB_LS             : STD_LOGIC := '0'; 
signal FILL               : STD_LOGIC := '0';
signal ADDR_LS            : STD_LOGIC_VECTOR((ADDR_WIDTH_LS-1) downto 0)  := (others => '0');
signal DATA_IN_LS         : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)     := (others => '0');
signal SRAM_INSTR         : sram_type := (others => (others => '0'));
signal PC_LS              : STD_LOGIC_VECTOR((LS_INSTR_SECTION_SIZE - 1) downto 0) := (others => '0');
signal DATA_OUT_LS        : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others => '0');
signal INSTR_BLOCK_OUT_LS : STD_LOGIC_VECTOR((INSTR_WIDTH_LS-1) downto 0) := (others => '0');
-------------------- CLOCK --------------------
constant CLK_PERIOD : TIME := 10ns;
begin    
    ------------------ INSTANTIATE LOCAL STORE --------------------
    LS : entity work.LOCAL_STORE port map (
        ----- INPUTS -----
        WE_LS      => WE_LS,  
        RIB_LS     => RIB_LS,
        FILL       => FILL,
        ADDR_LS    => ADDR_LS,
        DATA_IN_LS => DATA_IN_LS,
        SRAM_INSTR => SRAM_INSTR,
        PC_LS      => PC_LS,
        ----- OUTPUTS -----
        DATA_OUT_LS        => DATA_OUT_LS, 
        INSTR_BLOCK_OUT_LS => INSTR_BLOCK_OUT_LS
    );
    
    -------------------- CLK GENERATION PROCESS --------------------
    CLK <= not CLK after CLK_PERIOD/2;

    -------------------- FILL LOCAL STORE PROCESS --------------------
    FILL_LS_PROC : process
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
            wait for CLK_PERIOD; -- Wait for data to be written
            FILL <= '0';
            wait for CLK_PERIOD; -- Wait for data to be written
            LS_ADDR := LS_ADDR + 1; -- Increment Address
        end loop;
        
        file_close(file_MACHINE_CODE);
        wait;
    end process FILL_LS_PROC;
end behavioral;
