--------------------------------------------------------------------------------
-- Company: Stony Brook University
-- Engineer: Wilmer Suarez
--
-- Create Date: 04/09/2019
-- Design Name: Register Fetch Stage
-- Tool versions: Vivado v2018.3 (64-bit)
--------------------------------------------------------------------------------
-------------------- LIBRARIES --------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.COMPONENTS_PACKAGE.ALL; -- Contains result_packet Record
use work.SPU_CORE_ISA_PACKAGE.ALL;
use work.CONSTANTS_PACKAGE.ALL;

-------------------- ENTITY DEFINITION --------------------
entity REGISTER_FETCH_STAGE is
port (
    -------------------- INPUTS --------------------
    CLK              : in STD_LOGIC; 
    PC_IN            : in STD_LOGIC_VECTOR((LS_INSTR_SECTION_SIZE - 1) downto 0); -- Current value of the PC 
    EVEN_OPCODE_RF   : in STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0); 
    ODD_OPCODE_RF    : in STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0); 
    RA_EVEN_ADDR_RF  : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);
    RB_EVEN_ADDR_RF  : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); 
    RC_EVEN_ADDR_RF  : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); 
    RA_ODD_ADDR_RF   : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); 
    RB_ODD_ADDR_RF   : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); 
    RC_ODD_ADDR_RF   : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); 
    EVEN_RI7_RF      : in STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0);  
    EVEN_RI10_RF     : in STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0);
    EVEN_RI16_RF     : in STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0);
    ODD_RI7_RF       : in STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0); 
    ODD_RI10_RF      : in STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0); 
    ODD_RI16_RF      : in STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0);
    ODD_RI18_RF      : in STD_LOGIC_VECTOR((RI18_WIDTH-1) downto 0);
    EVEN_REG_DEST_RF : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); 
    ODD_REG_DEST_RF  : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);
    RESULT_PACKET_EVEN_IN_FC : in RESULT_PACKET_EVEN;
    RESULT_PACKET_ODD_IN_FC  : in RESULT_PACKET_ODD;  
    -------------------- OUTPUTS --------------------
    PC_OUT_RF            : out STD_LOGIC_VECTOR((LS_INSTR_SECTION_SIZE - 1) downto 0) := (others => '0'); -- Current value of the PC
    PREV_IN_EVEN         : out PREV_DATA := ((others => 'U'), TRUE);
    PREV_IN_ODD          : out PREV_DATA := ((others => 'U'), TRUE);
    PREV_OUT_EVEN        : out PREV_DATA := ((others => 'U'), TRUE);
    PREV_OUT_ODD         : out PREV_DATA := ((others => 'U'), TRUE);
    EVEN_OPCODE_OUT_RF   : out STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0) := "00000000001"; 
    ODD_OPCODE_OUT_RF    : out STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0) := "01000000001";
    RA_EVEN_DATA_OUT_RF  : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)   := (others => '0');
    RB_EVEN_DATA_OUT_RF  : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)   := (others => '0');
    RC_EVEN_DATA_OUT_RF  : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)   := (others => '0');
    RA_ODD_DATA_OUT_RF   : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)   := (others => '0');
    RB_ODD_DATA_OUT_RF   : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)   := (others => '0');
    RC_ODD_DATA_OUT_RF   : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)   := (others => '0');
    RA_EVEN_ADDR_OUT_RF  : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0');
    RB_EVEN_ADDR_OUT_RF  : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0');
    RC_EVEN_ADDR_OUT_RF  : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0');
    RA_ODD_ADDR_OUT_RF   : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0');
    RB_ODD_ADDR_OUT_RF   : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0');
    RC_ODD_ADDR_OUT_RF   : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0');
    EVEN_RI7_OUT_RF      : out STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0)    := (others => '0');
    EVEN_RI10_OUT_RF     : out STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0)   := (others => '0');
    EVEN_RI16_OUT_RF     : out STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0)   := (others => '0');
    ODD_RI7_OUT_RF       : out STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0)    := (others => '0');
    ODD_RI10_OUT_RF      : out STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0)   := (others => '0');
    ODD_RI16_OUT_RF      : out STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0)   := (others => '0');
    ODD_RI18_OUT_RF      : out STD_LOGIC_VECTOR((RI18_WIDTH-1) downto 0)   := (others => '0');
    EVEN_REG_DEST_OUT_RF : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0');
    ODD_REG_DEST_OUT_RF  : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0')
);
end REGISTER_FETCH_STAGE;

-------------------- ARCHITECTURE DEFINITION --------------------
architecture behavioral of REGISTER_FETCH_STAGE is
signal EVEN_OPCODE_OUT   : STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0) := (others => '0'); 
signal ODD_OPCODE_OUT    : STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0) := (others => '0');
signal EVEN_REG_DEST_OUT : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0');
signal ODD_REG_DEST_OUT  : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0');
begin
    ----- OUTPUT CURRENT PC TO PIPES -----
    PC_OUT_RF <= PC_IN;
    
    ----- OUTPUT OPCODE AND REGISTER DESTINATION DATA TO FORWARDING CIRCUITS -----
    EVEN_OPCODE_OUT_RF   <= EVEN_OPCODE_OUT;
    ODD_OPCODE_OUT_RF    <= ODD_OPCODE_OUT;
    EVEN_REG_DEST_OUT_RF <= EVEN_REG_DEST_OUT;
    ODD_REG_DEST_OUT_RF  <= ODD_REG_DEST_OUT;

    ----- SEND CURRENT INSTRUCTION DATA TO DEPENDENCY STAGE -----
    PREV_IN_EVEN.DONT_CHECK <= TRUE when EVEN_OPCODE_RF = "00000000001" else FALSE; 
    PREV_IN_EVEN.REG_DEST   <= EVEN_REG_DEST_RF;
    PREV_IN_ODD.DONT_CHECK  <= TRUE when ODD_OPCODE_RF = "01000000001" else FALSE; 
    PREV_IN_ODD.REG_DEST    <= ODD_REG_DEST_RF;
    
    ----- SEND PREVIOUS INSTRUCTION DATA TO DEPENDENCY STAGE -----
    PREV_OUT_EVEN.DONT_CHECK <= TRUE when EVEN_OPCODE_OUT = "00000000001" else FALSE; 
    PREV_OUT_EVEN.REG_DEST   <= EVEN_REG_DEST_OUT;
    PREV_OUT_ODD.DONT_CHECK  <= TRUE when ODD_OPCODE_OUT = "01000000001" else FALSE; 
    PREV_OUT_ODD.REG_DEST    <= ODD_REG_DEST_OUT;

    -------------------- INSTANTIATE REGISTER FILE --------------------
    rf : register_file port map (
        -------------------- INPUTS --------------------
        CLK              => CLK,
        RW_EVEN_RF       => RESULT_PACKET_EVEN_IN_FC.RW,
        RW_ODD_RF        => RESULT_PACKET_ODD_IN_FC.RW,
        EVEN_OPCODE_RF   => EVEN_OPCODE_RF,
        ODD_OPCODE_RF    => ODD_OPCODE_RF,  
        RA_EVEN_ADDR_RF  => RA_EVEN_ADDR_RF, 
        RB_EVEN_ADDR_RF  => RB_EVEN_ADDR_RF,
        RC_EVEN_ADDR_RF  => RC_EVEN_ADDR_RF,
        EVEN_WB_ADDR_RF  => RESULT_PACKET_EVEN_IN_FC.REG_DEST,  
        EVEN_WB_DATA_RF  => RESULT_PACKET_EVEN_IN_FC.RESULT,   
        RA_ODD_ADDR_RF   => RA_ODD_ADDR_RF,
        RB_ODD_ADDR_RF   => RB_ODD_ADDR_RF,
        RC_ODD_ADDR_RF   => RC_ODD_ADDR_RF,
        ODD_WB_ADDR_RF   => RESULT_PACKET_ODD_IN_FC.REG_DEST,  
        ODD_WB_DATA_RF   => RESULT_PACKET_ODD_IN_FC.RESULT, 
        EVEN_RI7_RF      => EVEN_RI7_RF,  
        EVEN_RI10_RF     => EVEN_RI10_RF,   
        EVEN_RI16_RF     => EVEN_RI16_RF,     
        ODD_RI7_RF       => ODD_RI7_RF,       
        ODD_RI10_RF      => ODD_RI10_RF,      
        ODD_RI16_RF      => ODD_RI16_RF,      
        ODD_RI18_RF      => ODD_RI18_RF,     
        EVEN_REG_DEST_RF => EVEN_REG_DEST_RF, 
        ODD_REG_DEST_RF  => ODD_REG_DEST_RF,  
        -------------------- OUTPUTS --------------------
        EVEN_OPCODE_OUT_RF   => EVEN_OPCODE_OUT,
        ODD_OPCODE_OUT_RF    => ODD_OPCODE_OUT,
        RA_EVEN_DATA_OUT_RF  => RA_EVEN_DATA_OUT_RF,
        RB_EVEN_DATA_OUT_RF  => RB_EVEN_DATA_OUT_RF,
        RC_EVEN_DATA_OUT_RF  => RC_EVEN_DATA_OUT_RF, 
        RA_ODD_DATA_OUT_RF   => RA_ODD_DATA_OUT_RF,
        RB_ODD_DATA_OUT_RF   => RB_ODD_DATA_OUT_RF,
        RC_ODD_DATA_OUT_RF   => RC_ODD_DATA_OUT_RF,
        RA_EVEN_ADDR_OUT_RF  => RA_EVEN_ADDR_OUT_RF,
        RB_EVEN_ADDR_OUT_RF  => RB_EVEN_ADDR_OUT_RF,
        RC_EVEN_ADDR_OUT_RF  => RC_EVEN_ADDR_OUT_RF,
        RA_ODD_ADDR_OUT_RF   => RA_ODD_ADDR_OUT_RF,
        RB_ODD_ADDR_OUT_RF   => RB_ODD_ADDR_OUT_RF, 
        RC_ODD_ADDR_OUT_RF   => RC_ODD_ADDR_OUT_RF, 
        EVEN_RI7_OUT_RF      => EVEN_RI7_OUT_RF, 
        EVEN_RI10_OUT_RF     => EVEN_RI10_OUT_RF, 
        EVEN_RI16_OUT_RF     => EVEN_RI16_OUT_RF,
        ODD_RI7_OUT_RF       => ODD_RI7_OUT_RF, 
        ODD_RI10_OUT_RF      => ODD_RI10_OUT_RF,
        ODD_RI16_OUT_RF      => ODD_RI16_OUT_RF, 
        ODD_RI18_OUT_RF      => ODD_RI18_OUT_RF,
        EVEN_REG_DEST_OUT_RF => EVEN_REG_DEST_OUT,
        ODD_REG_DEST_OUT_RF  => ODD_REG_DEST_OUT
    );
end behavioral;