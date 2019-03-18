-------------------- LIBRARIES --------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-------------------- PACKAGE DECLARATION --------------------
package COMPONENTS_PACKAGE is
----- COMPONENT CONSTANTS -----
constant ADDR_WIDTH_RF : INTEGER := 7;       -- Bit-width of the Register Addresses 
constant DATA_WIDTH_RF : INTEGER := 128;     -- Bit-width of the Register Data
constant ADDR_WIDTH_LS : INTEGER := 15;      -- Bit-width of the SRAM Addresses 
constant DATA_WIDTH_LS : INTEGER := 128;     -- Bit-width of the Data
constant INSTR_WIDTH_LS : INTEGER := 1024;   -- Bit-width of Instruction Block

----- REGISTER FILE COMPONENT -----
component register_file 
    port (
        CLK : in STD_LOGIC;
        RW_EVEN : in STD_LOGIC;
        RW_ODD : in STD_LOGIC;
        RA_EVEN_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH_RF-1) downto 0);
        RB_EVEN_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH_RF-1) downto 0);
        RC_EVEN_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH_RF-1) downto 0);
        EVEN_WB_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH_RF-1) downto 0);
        EVEN_WB_DATA_IN : in STD_LOGIC_VECTOR((DATA_WIDTH_RF-1) downto 0);
        RA_ODD_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH_RF-1) downto 0); 
        RB_ODD_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH_RF-1) downto 0);
        RC_ODD_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH_RF-1) downto 0);
        ODD_WB_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH_RF-1) downto 0);
        ODD_WB_DATA_IN : in STD_LOGIC_VECTOR((DATA_WIDTH_RF-1) downto 0);
        RA_EVEN_DATA_OUT : out STD_LOGIC_VECTOR((DATA_WIDTH_RF-1) downto 0); 
        RB_EVEN_DATA_OUT : out STD_LOGIC_VECTOR((DATA_WIDTH_RF-1) downto 0);
        RC_EVEN_DATA_OUT : out STD_LOGIC_VECTOR((DATA_WIDTH_RF-1) downto 0);
        RA_ODD_DATA_OUT : out STD_LOGIC_VECTOR((DATA_WIDTH_RF-1) downto 0);  
        RB_ODD_DATA_OUT : out STD_LOGIC_VECTOR((DATA_WIDTH_RF-1) downto 0); 
        RC_ODD_DATA_OUT : out STD_LOGIC_VECTOR((DATA_WIDTH_RF-1) downto 0)  
    );
end component;

----- LOCAL STORE COMPONENT -----
component local_store 
    port (
        WE : in STD_LOGIC; 
        RIB : in STD_LOGIC; 
        ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH_LS-1) downto 0);    
        DATA_IN : in STD_LOGIC_VECTOR((DATA_WIDTH_LS-1) downto 0);
        DATA_OUT : out STD_LOGIC_VECTOR((DATA_WIDTH_LS-1) downto 0);     
        INSTR_BLOCK_OUT : out STD_LOGIC_VECTOR((INSTR_WIDTH_LS-1) downto 0)  
    );
end component;

end package COMPONENTS_PACKAGE;
