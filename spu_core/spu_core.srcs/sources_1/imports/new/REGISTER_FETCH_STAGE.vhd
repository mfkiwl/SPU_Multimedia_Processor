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

-------------------- ENTITY DEFINITION --------------------
entity REGISTER_FETCH_STAGE is
generic (
    OPCODE_WIDTH  : NATURAL := 11;   -- Maximum bit-width of Even and Odd Opcodes
    DATA_WIDTH    : NATURAL := 128;  -- Bit-width of the Register Data
    ADDR_WIDTH    : NATURAL := 7;    -- Bit-width of the Register Addresses 
    RI7_WIDTH     : NATURAL := 7;    -- Immediate 7-bit format
    RI10_WIDTH    : NATURAL := 10;   -- Immediate 10-bit format
    RI16_WIDTH    : NATURAL := 16;   -- Immediate 16-bit format
    RI18_WIDTH    : NATURAL := 18    -- Immediate 18-bit format
);
port (
    -------------------- INPUTS --------------------
    CLK              : in STD_LOGIC; 
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
    EVEN_OPCODE_OUT_RF   : out STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0) := (others => '0'); 
    ODD_OPCODE_OUT_RF    : out STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0) := (others => '0');
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
begin
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
        EVEN_OPCODE_OUT_RF   => EVEN_OPCODE_OUT_RF,
        ODD_OPCODE_OUT_RF    => ODD_OPCODE_OUT_RF,
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
        EVEN_REG_DEST_OUT_RF => EVEN_REG_DEST_OUT_RF,
        ODD_REG_DEST_OUT_RF  => ODD_REG_DEST_OUT_RF
    );
end behavioral;