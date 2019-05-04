--------------------------------------------------------------------------------
-- Company: Stony Brook University
-- Engineer: Wilmer Suarez

-- Create Date: 05/03-5/2019
-- Design Name: Dependency Issue Stage
-- Tool versions: Vivado v2018.3 (64-bit)
--------------------------------------------------------------------------------
-------------------- LIBRARIES --------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.COMPONENTS_PACKAGE.ALL;
use work.SPU_CORE_ISA_PACKAGE.ALL; -- Contains all instructions in ISA
use work.CONSTANTS_PACKAGE.ALL;

entity DEPENDENCY_ISSUE_STAGE is
port (
    -------------------- INPUTS --------------------
    CLK               : in STD_LOGIC; -- System Wide Synchronous Clock
    PC_IN             : in STD_LOGIC_VECTOR((LS_INSTR_SECTION_SIZE - 1) downto 0);  -- Current value of the PC 
    INSTR_EVEN_IN     : in INSTR_DATA; -- Even Instruction data from Decode Stage
    INSTR_ODD_IN      : in INSTR_DATA; -- Odd Instruction data from Decode Stage
    -------------------- OUTPUTS --------------------
    PC_OUT            : out STD_LOGIC_VECTOR((LS_INSTR_SECTION_SIZE - 1) downto 0); -- Current value of the PC
    EVEN_OPCODE_DEP   : out STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0);
    ODD_OPCODE_DEP    : out STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0); 
    RA_EVEN_ADDR_DEP  : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);
    RB_EVEN_ADDR_DEP  : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); 
    RC_EVEN_ADDR_DEP  : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); 
    RA_ODD_ADDR_DEP   : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); 
    RB_ODD_ADDR_DEP   : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); 
    RC_ODD_ADDR_DEP   : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); 
    EVEN_RI7_DEP      : out STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0);  
    EVEN_RI10_DEP     : out STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0);
    EVEN_RI16_DEP     : out STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0);
    ODD_RI7_DEP       : out STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0); 
    ODD_RI10_DEP      : out STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0); 
    ODD_RI16_DEP      : out STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0);
    ODD_RI18_DEP      : out STD_LOGIC_VECTOR((RI18_WIDTH-1) downto 0);
    EVEN_REG_DEST_DEP : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); 
    ODD_REG_DEST_DEP  : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)    
);
end DEPENDENCY_ISSUE_STAGE;

-------------------- ARCHITECTURE DEFINITION --------------------
architecture behavioral of DEPENDENCY_ISSUE_STAGE is
begin
    -------------------- DEPENDENCY STAGE PROCESS --------------------
    DEP_PROC : process(CLK)
    begin
        if(rising_edge(CLK)) then
            
        end if;
    end process DEP_PROC;
    
end behavioral;
