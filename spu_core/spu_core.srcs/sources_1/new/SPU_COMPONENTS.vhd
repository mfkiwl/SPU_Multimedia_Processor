-------------------- LIBRARIES --------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.SPU_CORE_ISA_PACKAGE.ALL; -- Contains all instructions in ISA

-------------------- PACKAGE DECLARATION --------------------
package COMPONENTS_PACKAGE is
----- COMPONENT CONSTANTS -----
constant ADDR_WIDTH_RF : NATURAL := 7;       -- Bit-width of the Register Addresses - Regiser File
constant DATA_WIDTH_RF : NATURAL := 128;     -- Bit-width of the Register Data - Register File
constant OPCODE_WIDTH_RF : NATURAL := 11;    -- Maximum Bit-width of Opcode
constant RI7_WIDTH_RF : NATURAL := 7;        -- Immediate 7-bit format
constant RI10_WIDTH_RF : NATURAL := 10;      -- Immediate 10-bit format
constant RI16_WIDTH_RF : NATURAL := 16;      -- Immediate 16-bit format
constant RI18_WIDTH_RF : NATURAL := 18;      -- Immediate 18-bit format
constant ADDR_WIDTH_LS : NATURAL := 15;      -- Bit-width of the SRAM Addresses - Local Store
constant DATA_WIDTH_LS : NATURAL := 128;     -- Bit-width of the Data - Local Store
constant INSTR_WIDTH_LS : NATURAL := 1024;   -- Bit-width of Instruction Block - Local Store
constant RESULT_WIDTH_FC : NATURAL := 128;   -- Bit-width of Register File WB Data - Forwarding Circuit
constant ADDR_WIDTH_FC : NATURAL := 7;       -- Bit-width of Register File Addresses - Forwarding Circuit
constant LATENCY_WIDTH_FC : NATURAL := 3;    -- Bit-width of Instruction Latency - Forwarding Circuit
constant DATA_WIDTH_FM : NATURAL := 128;     -- Bit-width of the Register Data - Forwarding Macro
constant ADDR_WIDTH_FM : NATURAL := 7;       -- Bit-width of the Register Addresses - Forwarding Circuit
constant OPCODE_WIDTH_FM : NATURAL := 11;    -- Maximum Bit-width of Opcode
constant RI7_WIDTH_FM : NATURAL := 7;        -- Immediate 7-bit format
constant RI10_WIDTH_FM : NATURAL := 10;      -- Immediate 10-bit format
constant RI16_WIDTH_FM : NATURAL := 16;      -- Immediate 16-bit format
constant RI18_WIDTH_FM : NATURAL := 18;      -- Immediate 18-bit format
constant ADDR_WIDTH_PIPE : NATURAL := 7;     -- Bit-width of the Register Addresses 
constant LS_ADDR_WIDTH_PIPE : NATURAL := 15; -- Bit-width of the Local Store Addresses
constant DATA_WIDTH_PIPE : NATURAL := 128;   -- Bit-width of the Register Data
constant OPCODE_WIDTH_PIPE : NATURAL := 11;  -- Maximum bit-width of Even and Odd Opcodes
constant RI7_WIDTH_PIPE : NATURAL := 7;      -- Immediate 7-bit format
constant RI10_WIDTH_PIPE : NATURAL := 10;    -- Immediate 10-bit format
constant RI16_WIDTH_PIPE : NATURAL := 16;    -- Immediate 16-bit format
constant RI18_WIDTH_PIPE : NATURAL := 18;    -- Immediate 18-bit format
constant OPCODE_WIDTH_TOP : NATURAL := 11;   -- Maximum bit-width of Even and Odd Opcodes
constant ADDR_WIDTH_TOP : NATURAL := 7;      -- Bit-width of Register File Addresses - Forwarding Circuit
constant RI7_WIDTH_TOP : NATURAL := 7;      -- Immediate 7-bit format
constant RI10_WIDTH_TOP : NATURAL := 10;    -- Immediate 10-bit format
constant RI16_WIDTH_TOP : NATURAL := 16;    -- Immediate 16-bit format
constant RI18_WIDTH_TOP : NATURAL := 18;    -- Immediate 18-bit format

----- EXECUTION UNIT RESULT PACKET -----
type result_packet is record
    RESULT : STD_LOGIC_VECTOR((RESULT_WIDTH_FC-1) downto 0);   -- Current Instruction Execution Unit Result
    REG_DEST : STD_LOGIC_VECTOR((ADDR_WIDTH_FC-1) downto 0);   -- Register File Destination Address
    RW : STD_LOGIC;                                            -- Register File Register Write Control Signal
    LATENCY : NATURAL; -- Latency of Current Instruction 
end record result_packet;

----- SPU CORE TOP COMPONENT -----
component SPU_CORE_TOP_MODULE 
    port (
        -------------------- INPUTS --------------------
        CLK : in STD_LOGIC;
        EVEN_OPCODE : in STD_LOGIC_VECTOR((OPCODE_WIDTH_TOP-1) downto 0) := (others => '0'); 
        RA_EVEN_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH_TOP-1) downto 0) := (others => '0'); 
        RB_EVEN_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH_TOP-1) downto 0) := (others => '0'); 
        RC_EVEN_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH_TOP-1) downto 0) := (others => '0'); 
        EVEN_REG_DEST : in STD_LOGIC_VECTOR((ADDR_WIDTH_TOP-1) downto 0) := (others => '0');
        EVEN_RI7 : in STD_LOGIC_VECTOR((RI7_WIDTH_TOP-1) downto 0) := (others => '0');   
        EVEN_RI10 : in STD_LOGIC_VECTOR((RI10_WIDTH_TOP-1) downto 0) := (others => '0');
        EVEN_RI16 : in STD_LOGIC_VECTOR((RI16_WIDTH_TOP-1) downto 0) := (others => '0');
        ODD_OPCODE : in STD_LOGIC_VECTOR((OPCODE_WIDTH_TOP-1) downto 0) := (others => '0'); 
        RA_ODD_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH_TOP-1) downto 0) := (others => '0');  
        RB_ODD_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH_TOP-1) downto 0) := (others => '0');  
        RC_ODD_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH_TOP-1) downto 0) := (others => '0');  
        ODD_REG_DEST : in STD_LOGIC_VECTOR((ADDR_WIDTH_TOP-1) downto 0) := (others => '0'); 
        ODD_RI7 : in STD_LOGIC_VECTOR((RI7_WIDTH_TOP-1) downto 0) := (others => '0');  
        ODD_RI10 : in STD_LOGIC_VECTOR((RI10_WIDTH_TOP-1) downto 0) := (others => '0'); 
        ODD_RI16 : in STD_LOGIC_VECTOR((RI16_WIDTH_TOP-1) downto 0) := (others => '0'); 
        ODD_RI18 : in STD_LOGIC_VECTOR((RI18_WIDTH_TOP-1) downto 0) := (others => '0');
        -------------------- OUTPUTS --------------------
        RESULT_PACKET_EVEN_OUT : out RESULT_PACKET := ((others => '0'), (others => '0'), '0', 0); 
        RESULT_PACKET_ODD_OUT : out RESULT_PACKET := ((others => '0'), (others => '0'), '0', 0)
    );
end component SPU_CORE_TOP_MODULE;

----- REGISTER FILE COMPONENT -----
component register_file 
    port (
        -------------------- INPUTS --------------------
        CLK : in STD_LOGIC;
        RW_EVEN : in STD_LOGIC;
        RW_ODD : in STD_LOGIC;
        EVEN_OPCODE : in STD_LOGIC_VECTOR((OPCODE_WIDTH_RF-1) downto 0);
        RA_EVEN_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH_RF-1) downto 0);
        RB_EVEN_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH_RF-1) downto 0);
        RC_EVEN_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH_RF-1) downto 0);
        EVEN_WB_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH_RF-1) downto 0);
        EVEN_WB_DATA : in STD_LOGIC_VECTOR((DATA_WIDTH_RF-1) downto 0);
        ODD_OPCODE : in STD_LOGIC_VECTOR((OPCODE_WIDTH_RF-1) downto 0);
        RA_ODD_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH_RF-1) downto 0); 
        RB_ODD_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH_RF-1) downto 0);
        RC_ODD_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH_RF-1) downto 0);
        ODD_WB_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH_RF-1) downto 0);
        ODD_WB_DATA : in STD_LOGIC_VECTOR((DATA_WIDTH_RF-1) downto 0);
        EVEN_RI7 : in STD_LOGIC_VECTOR((RI7_WIDTH_RF-1) downto 0);    
        EVEN_RI10 : in STD_LOGIC_VECTOR((RI10_WIDTH_RF-1) downto 0);   
        EVEN_RI16 : in STD_LOGIC_VECTOR((RI16_WIDTH_RF-1) downto 0);   
        ODD_RI7 : in STD_LOGIC_VECTOR((RI7_WIDTH_RF-1) downto 0);    
        ODD_RI10 : in STD_LOGIC_VECTOR((RI10_WIDTH_RF-1) downto 0);    
        ODD_RI16 : in STD_LOGIC_VECTOR((RI16_WIDTH_RF-1) downto 0);    
        ODD_RI18 : in STD_LOGIC_VECTOR((RI18_WIDTH_RF-1) downto 0);  
        EVEN_REG_DEST : in STD_LOGIC_VECTOR((ADDR_WIDTH_RF-1) downto 0);
        ODD_REG_DEST : in STD_LOGIC_VECTOR((ADDR_WIDTH_RF-1) downto 0);
        -------------------- OUTPUTS --------------------
        EVEN_OPCODE_OUT : out STD_LOGIC_VECTOR((OPCODE_WIDTH_RF-1) downto 0);
        RA_EVEN_DATA_OUT : out STD_LOGIC_VECTOR((DATA_WIDTH_RF-1) downto 0); 
        RB_EVEN_DATA_OUT : out STD_LOGIC_VECTOR((DATA_WIDTH_RF-1) downto 0);
        RC_EVEN_DATA_OUT : out STD_LOGIC_VECTOR((DATA_WIDTH_RF-1) downto 0);
        ODD_OPCODE_OUT : out STD_LOGIC_VECTOR((OPCODE_WIDTH_RF-1) downto 0);
        RA_ODD_DATA_OUT : out STD_LOGIC_VECTOR((DATA_WIDTH_RF-1) downto 0);  
        RB_ODD_DATA_OUT : out STD_LOGIC_VECTOR((DATA_WIDTH_RF-1) downto 0); 
        RC_ODD_DATA_OUT : out STD_LOGIC_VECTOR((DATA_WIDTH_RF-1) downto 0);
        RA_EVEN_ADDR_OUT : out STD_LOGIC_VECTOR((ADDR_WIDTH_RF-1) downto 0);
        RB_EVEN_ADDR_OUT : out STD_LOGIC_VECTOR((ADDR_WIDTH_RF-1) downto 0); 
        RC_EVEN_ADDR_OUT : out STD_LOGIC_VECTOR((ADDR_WIDTH_RF-1) downto 0); 
        RA_ODD_ADDR_OUT : out STD_LOGIC_VECTOR((ADDR_WIDTH_RF-1) downto 0);  
        RB_ODD_ADDR_OUT : out STD_LOGIC_VECTOR((ADDR_WIDTH_RF-1) downto 0);
        RC_ODD_ADDR_OUT : out STD_LOGIC_VECTOR((ADDR_WIDTH_RF-1) downto 0);
        EVEN_RI7_OUT : out STD_LOGIC_VECTOR((RI7_WIDTH_RF-1) downto 0);      
        EVEN_RI10_OUT : out STD_LOGIC_VECTOR((RI10_WIDTH_RF-1) downto 0);   
        EVEN_RI16_OUT : out STD_LOGIC_VECTOR((RI16_WIDTH_RF-1) downto 0);    
        ODD_RI7_OUT : out STD_LOGIC_VECTOR((RI7_WIDTH_RF-1) downto 0);     
        ODD_RI10_OUT : out STD_LOGIC_VECTOR((RI10_WIDTH_RF-1) downto 0);  
        ODD_RI16_OUT : out STD_LOGIC_VECTOR((RI16_WIDTH_RF-1) downto 0);   
        ODD_RI18_OUT : out STD_LOGIC_VECTOR((RI18_WIDTH_RF-1) downto 0);
        EVEN_REG_DEST_OUT : out STD_LOGIC_VECTOR((ADDR_WIDTH_RF-1) downto 0);
        ODD_REG_DEST_OUT : out STD_LOGIC_VECTOR((ADDR_WIDTH_RF-1) downto 0)
    );
end component register_file;

----- LOCAL STORE COMPONENT COMPONENT -----
component local_store 
    port (
        -------------------- INPUTS --------------------
        WE : in STD_LOGIC; 
        RIB : in STD_LOGIC; 
        ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH_LS-1) downto 0);    
        DATA_IN : in STD_LOGIC_VECTOR((DATA_WIDTH_LS-1) downto 0);
        -------------------- OUTPUTS --------------------
        DATA_OUT : out STD_LOGIC_VECTOR((DATA_WIDTH_LS-1) downto 0);     
        INSTR_BLOCK_OUT : out STD_LOGIC_VECTOR((INSTR_WIDTH_LS-1) downto 0)  
    );
end component local_store;

----- FORWARDING MACRO/CIRCUIS COMPONENT -----
component forwarding_macro_circuits 
    port (
        -------------------- INPUTS --------------------
        CLK : in STD_LOGIC;
        EVEN_OPCODE : in STD_LOGIC_VECTOR((OPCODE_WIDTH_FM-1) downto 0);
        ODD_OPCODE : in STD_LOGIC_VECTOR((OPCODE_WIDTH_FM-1) downto 0);
        RESULT_PACKET_EVEN_IN : in RESULT_PACKET; 
        RESULT_PACKET_ODD_IN : in RESULT_PACKET; 
        RA_EVEN_DATA : in STD_LOGIC_VECTOR((DATA_WIDTH_FM-1) downto 0);
        RB_EVEN_DATA : in STD_LOGIC_VECTOR((DATA_WIDTH_FM-1) downto 0);
        RC_EVEN_DATA : in STD_LOGIC_VECTOR((DATA_WIDTH_FM-1) downto 0);
        RA_ODD_DATA : in STD_LOGIC_VECTOR((DATA_WIDTH_FM-1) downto 0);
        RB_ODD_DATA : in STD_LOGIC_VECTOR((DATA_WIDTH_FM-1) downto 0);
        RC_ODD_DATA : in STD_LOGIC_VECTOR((DATA_WIDTH_FM-1) downto 0); 
        EVEN_REG_DEST : in STD_LOGIC_VECTOR((ADDR_WIDTH_FM-1) downto 0);
        ODD_REG_DEST : in STD_LOGIC_VECTOR((ADDR_WIDTH_FM-1) downto 0);
        RA_EVEN_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH_FM-1) downto 0);
        RB_EVEN_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH_FM-1) downto 0);
        RC_EVEN_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH_FM-1) downto 0); 
        RA_ODD_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH_FM-1) downto 0); 
        RB_ODD_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH_FM-1) downto 0);
        RC_ODD_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH_FM-1) downto 0);
        EVEN_RI7 : in STD_LOGIC_VECTOR((RI7_WIDTH_FM-1) downto 0);
        EVEN_RI10 : in STD_LOGIC_VECTOR((RI10_WIDTH_FM-1) downto 0);
        EVEN_RI16 : in STD_LOGIC_VECTOR((RI16_WIDTH_FM-1) downto 0);
        ODD_RI7 : in STD_LOGIC_VECTOR((RI7_WIDTH_FM-1) downto 0);
        ODD_RI10 : in STD_LOGIC_VECTOR((RI10_WIDTH_FM-1) downto 0);
        ODD_RI16 : in STD_LOGIC_VECTOR((RI16_WIDTH_FM-1) downto 0);
        ODD_RI18 : in STD_LOGIC_VECTOR((RI18_WIDTH_FM-1) downto 0);
        -------------------- OUTPUTS --------------------
        RA_EVEN_DATA_OUT_FM : out STD_LOGIC_VECTOR((DATA_WIDTH_FM-1) downto 0);
        RB_EVEN_DATA_OUT_FM : out STD_LOGIC_VECTOR((DATA_WIDTH_FM-1) downto 0);
        RC_EVEN_DATA_OUT_FM : out STD_LOGIC_VECTOR((DATA_WIDTH_FM-1) downto 0);    
        RA_ODD_DATA_OUT_FM : out STD_LOGIC_VECTOR((DATA_WIDTH_FM-1) downto 0);
        RB_ODD_DATA_OUT_FM : out STD_LOGIC_VECTOR((DATA_WIDTH_FM-1) downto 0);
        RC_ODD_DATA_OUT_FM : out STD_LOGIC_VECTOR((DATA_WIDTH_FM-1) downto 0);
        RESULT_PACKET_EVEN_OUT_FM : out RESULT_PACKET; 
        RESULT_PACKET_ODD_OUT_FM : out RESULT_PACKET;
        EVEN_RI7_OUT_FM : out STD_LOGIC_VECTOR((RI7_WIDTH_FM-1) downto 0);
        EVEN_RI10_OUT_FM : out STD_LOGIC_VECTOR((RI10_WIDTH_FM-1) downto 0);
        EVEN_RI16_OUT_FM : out STD_LOGIC_VECTOR((RI16_WIDTH_FM-1) downto 0);
        ODD_RI7_OUT_FM : out STD_LOGIC_VECTOR((RI7_WIDTH_FM-1) downto 0);
        ODD_RI10_OUT_FM : out STD_LOGIC_VECTOR((RI10_WIDTH_FM-1) downto 0);
        ODD_RI16_OUT_FM : out STD_LOGIC_VECTOR((RI16_WIDTH_FM-1) downto 0);
        ODD_RI18_OUT_FM : out STD_LOGIC_VECTOR((RI18_WIDTH_FM-1) downto 0);
        EVEN_REG_DEST_OUT_FM : out STD_LOGIC_VECTOR((ADDR_WIDTH_FM-1) downto 0);
        ODD_REG_DEST_OUT_FM : out STD_LOGIC_VECTOR((ADDR_WIDTH_FM-1) downto 0);
        EVEN_OPCODE_OUT_FM : out STD_LOGIC_VECTOR((OPCODE_WIDTH_FM-1) downto 0);
        ODD_OPCODE_OUT_FM : out STD_LOGIC_VECTOR((OPCODE_WIDTH_FM-1) downto 0)
    );
end component forwarding_macro_circuits;

----- EVEN & ODD PIPES COMPONENT -----
component EVEN_ODD_PIPES 
    port (
        -------------------- INPUTS --------------------
        CLK : in STD_LOGIC := '0';
        EVEN_RI7 : in STD_LOGIC_VECTOR((RI7_WIDTH_PIPE-1) downto 0);
        EVEN_RI10 : in STD_LOGIC_VECTOR((RI10_WIDTH_PIPE-1) downto 0);
        EVEN_RI16 : in STD_LOGIC_VECTOR((RI16_WIDTH_PIPE-1) downto 0);
        ODD_RI7 : in STD_LOGIC_VECTOR((RI7_WIDTH_PIPE-1) downto 0);
        ODD_RI10 : in STD_LOGIC_VECTOR((RI10_WIDTH_PIPE-1) downto 0);
        ODD_RI16 : in STD_LOGIC_VECTOR((RI16_WIDTH_PIPE-1) downto 0);
        ODD_RI18 : in STD_LOGIC_VECTOR((RI18_WIDTH_PIPE-1) downto 0);
        EVEN_REG_DEST : in STD_LOGIC_VECTOR((ADDR_WIDTH_PIPE-1) downto 0);
        ODD_REG_DEST : in STD_LOGIC_VECTOR((ADDR_WIDTH_PIPE-1) downto 0);
        RA_EVEN_DATA : in STD_LOGIC_VECTOR((DATA_WIDTH_PIPE-1) downto 0);
        RB_EVEN_DATA : in STD_LOGIC_VECTOR((DATA_WIDTH_PIPE-1) downto 0);
        RC_EVEN_DATA : in STD_LOGIC_VECTOR((DATA_WIDTH_PIPE-1) downto 0);    
        RA_ODD_DATA : in STD_LOGIC_VECTOR((DATA_WIDTH_PIPE-1) downto 0);
        RB_ODD_DATA : in STD_LOGIC_VECTOR((DATA_WIDTH_PIPE-1) downto 0);
        RC_ODD_DATA : in STD_LOGIC_VECTOR((DATA_WIDTH_PIPE-1) downto 0);
        EVEN_OPCODE : in STD_LOGIC_VECTOR((OPCODE_WIDTH_PIPE-1) downto 0);
        ODD_OPCODE : in STD_LOGIC_VECTOR((OPCODE_WIDTH_PIPE-1) downto 0);
        LOCAL_STORE_DATA : in STD_LOGIC_VECTOR((DATA_WIDTH_PIPE-1) downto 0);
        -------------------- OUTPUTS --------------------
        WE_OUT : out STD_LOGIC := '0'; 
        RIB_OUT : out STD_LOGIC := '0'; 
        LS_DATA_OUT : out STD_LOGIC_VECTOR((DATA_WIDTH_PIPE-1) downto 0) := (others => '0'); 
        LOCAL_STORE_ADDR : out STD_LOGIC_VECTOR((LS_ADDR_WIDTH_PIPE-1) downto 0);
        RESULT_PACKET_EVEN : out RESULT_PACKET;
        RESULT_PACKET_ODD : out RESULT_PACKET
    );
end component EVEN_ODD_PIPES;

end package COMPONENTS_PACKAGE;
