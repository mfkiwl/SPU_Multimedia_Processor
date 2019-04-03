--------------------------------------------------------------------------------
-- Company: Stony Brook University
-- Engineer: Wilmer Suarez
--
-- Create Date: 03/22/2019
-- Design Name: SPU Core 
-- Tool versions: Vivado v2018.3 (64-bit)
--------------------------------------------------------------------------------
-------------------- LIBRARIES --------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.COMPONENTS_PACKAGE.ALL; -- Contains result_packet Record

-------------------- ENTITY DEFINITION --------------------
entity SPU_CORE_TOP_MODULE is
generic (
    OPCODE_WIDTH  : NATURAL := 11;   -- Maximum bit-width of Even and Odd Opcodes
    INSTR_WIDTH   : NATURAL := 1024; -- Bit-width of Instruction Block
    DATA_WIDTH    : NATURAL := 128;  -- Bit-width of the Register Data
    ADDR_WIDTH    : NATURAL := 7;    -- Bit-width of the Register Addresses 
    LS_ADDR_WIDTH : NATURAL := 15;   -- Bit-width of the Local Store Addresses
    RI7_WIDTH     : NATURAL := 7;    -- Immediate 7-bit format
    RI10_WIDTH    : NATURAL := 10;   -- Immediate 10-bit format
    RI16_WIDTH    : NATURAL := 16;   -- Immediate 16-bit format
    RI18_WIDTH    : NATURAL := 18    -- Immediate 18-bit format
);
port (
    -------------------- INPUTS --------------------
    CLK : in STD_LOGIC; -- System Wide Synchronous Clock
    ----- EVEN PIPE INPUT SIGNALS -----
    EVEN_OPCODE   : in STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0); -- Even Pipe Opcode
    RA_EVEN_ADDR  : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);   -- Even Pipe RA Register Address
    RB_EVEN_ADDR  : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);   -- Even Pipe RB Register Address
    RC_EVEN_ADDR  : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);   -- Even Pipe RC Register Address
    EVEN_REG_DEST : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);   -- Even Write back Address (RT)
    EVEN_RI7      : in STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0);    -- Even Immediate RI7
    EVEN_RI10     : in STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0);   -- Even Immediate RI10
    EVEN_RI16     : in STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0);   -- Even Immediate RI16
    ----- ODD PIPE INPUT SIGNALS -----
    ODD_OPCODE    : in STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0); -- Even Pipe Opcode
    RA_ODD_ADDR   : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);   -- Odd Pipe RA Register Address
    RB_ODD_ADDR   : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);   -- Odd Pipe RB Register Address
    RC_ODD_ADDR   : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);   -- Odd Pipe RC Register Address
    ODD_REG_DEST  : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);   -- Odd Write back Address (RT)
    ODD_RI7       : in STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0);    -- Odd Immediate RI7
    ODD_RI10      : in STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0);   -- Odd Immediate RI10
    ODD_RI16      : in STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0);   -- Odd Immediate RI16
    ODD_RI18      : in STD_LOGIC_VECTOR((RI18_WIDTH-1) downto 0);   -- Odd Immediate RI18
    -------------------- OUTPUTS --------------------
    RESULT_PACKET_EVEN_OUT : out RESULT_PACKET_EVEN := ((others => '0'), (others => '0'), '0', 0); -- Even Pipe Result Packet to Write Back Stage 
    RESULT_PACKET_ODD_OUT  : out RESULT_PACKET_ODD  := ((others => '0'), (others => '0'), '0', 0)  -- Odd Pipe Result Packet to Write Back Stage 
);
end SPU_CORE_TOP_MODULE;

-------------------- ARCHITECTURE DEFINITION --------------------
architecture behavioral of SPU_CORE_TOP_MODULE is
-------------------- REGISTER FILE -> FORWARDING MACRO SIGNALS --------------------
signal EVEN_OPCODE_OUT_RF   : STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0);
signal ODD_OPCODE_OUT_RF    : STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0);
signal RA_EVEN_DATA_OUT_RF  : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);
signal RB_EVEN_DATA_OUT_RF  : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);
signal RC_EVEN_DATA_OUT_RF  : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);
signal RA_ODD_DATA_OUT_RF   : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);
signal RB_ODD_DATA_OUT_RF   : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);
signal RC_ODD_DATA_OUT_RF   : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);
signal RA_EVEN_ADDR_OUT_RF  : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);
signal RB_EVEN_ADDR_OUT_RF  : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);
signal RC_EVEN_ADDR_OUT_RF  : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);
signal RA_ODD_ADDR_OUT_RF   : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);
signal RB_ODD_ADDR_OUT_RF   : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);
signal RC_ODD_ADDR_OUT_RF   : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);
signal EVEN_RI7_OUT_RF      : STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0);
signal EVEN_RI10_OUT_RF     : STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0);
signal EVEN_RI16_OUT_RF     : STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0);
signal ODD_RI7_OUT_RF       : STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0);
signal ODD_RI10_OUT_RF      : STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0);
signal ODD_RI16_OUT_RF      : STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0);
signal ODD_RI18_OUT_RF      : STD_LOGIC_VECTOR((RI18_WIDTH-1) downto 0);
signal EVEN_REG_DEST_OUT_RF : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);
signal ODD_REG_DEST_OUT_RF  : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);
-------------------- FORWARDING MACRO -> EVEN ODD PIPES SIGNALS --------------------
signal RA_EVEN_DATA_OUT_FM  : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);
signal RB_EVEN_DATA_OUT_FM  : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);
signal RC_EVEN_DATA_OUT_FM  : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);
signal RA_ODD_DATA_OUT_FM   : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);
signal RB_ODD_DATA_OUT_FM   : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);
signal RC_ODD_DATA_OUT_FM   : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);
signal EVEN_RI7_OUT_FM      : STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0);
signal EVEN_RI10_OUT_FM     : STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0);
signal EVEN_RI16_OUT_FM     : STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0);
signal ODD_RI7_OUT_FM       : STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0);  
signal ODD_RI10_OUT_FM      : STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0);
signal ODD_RI16_OUT_FM      : STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0);  
signal ODD_RI18_OUT_FM      : STD_LOGIC_VECTOR((RI18_WIDTH-1) downto 0);  
signal EVEN_OPCODE_OUT_FM   : STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0);
signal ODD_OPCODE_OUT_FM    : STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0);
signal EVEN_REG_DEST_OUT_FM : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); 
signal ODD_REG_DEST_OUT_FM  : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); 
signal RESULT_PACKET_EVEN_OUT_FC  : RESULT_PACKET_EVEN;
signal RESULT_PACKET_ODD_OUT_FC   : RESULT_PACKET_ODD;
-------------------- EVEN ODD PIPES -> FORWARDING CIRCUITS SIGNALS --------------------
signal RESULT_PACKET_EVEN_OUT_EOP : RESULT_PACKET_EVEN;
signal RESULT_PACKET_ODD_OUT_EOP  : RESULT_PACKET_ODD;
-------------------- EVEN ODD PIPES -> LOCAL STORE SIGNALS --------------------
signal LS_WE_OUT_EOP              : STD_LOGIC;
signal LS_RIB_OUT_EOP             : STD_LOGIC;
signal LS_DATA_OUT_EOP            : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);
signal LS_ADDR_OUT_EOP            : STD_LOGIC_VECTOR((LS_ADDR_WIDTH-1) downto 0);
-------------------- LOCAL STORE -> EVEN ODD PIPES SIGNALS --------------------
signal DATA_OUT_LS                : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);  
signal INSTR_BLOCK_OUT_LS         : STD_LOGIC_VECTOR((INSTR_WIDTH-1) downto 0);
begin
    -------------------- INSTANTIATE REGISTER FILE --------------------
    rf :register_file port map (
        -------------------- INPUTS --------------------
        CLK              => CLK,
        RW_EVEN_RF       => RESULT_PACKET_EVEN_OUT_FC.RW,
        RW_ODD_RF        => RESULT_PACKET_ODD_OUT_FC.RW,
        EVEN_OPCODE_RF   => EVEN_OPCODE,
        ODD_OPCODE_RF    => ODD_OPCODE,  
        RA_EVEN_ADDR_RF  => RA_EVEN_ADDR, 
        RB_EVEN_ADDR_RF  => RB_EVEN_ADDR,
        RC_EVEN_ADDR_RF  => RC_EVEN_ADDR,
        EVEN_WB_ADDR_RF  => RESULT_PACKET_EVEN_OUT_FC.REG_DEST,  
        EVEN_WB_DATA_RF  => RESULT_PACKET_EVEN_OUT_FC.RESULT,   
        RA_ODD_ADDR_RF   => RA_ODD_ADDR,
        RB_ODD_ADDR_RF   => RB_ODD_ADDR,
        RC_ODD_ADDR_RF   => RC_ODD_ADDR,
        ODD_WB_ADDR_RF   => RESULT_PACKET_ODD_OUT_FC.REG_DEST,  
        ODD_WB_DATA_RF   => RESULT_PACKET_ODD_OUT_FC.RESULT, 
        EVEN_RI7_RF      => EVEN_RI7,  
        EVEN_RI10_RF     => EVEN_RI10,   
        EVEN_RI16_RF     => EVEN_RI16,     
        ODD_RI7_RF       => ODD_RI7,       
        ODD_RI10_RF      => ODD_RI10,      
        ODD_RI16_RF      => ODD_RI16,      
        ODD_RI18_RF      => ODD_RI18,     
        EVEN_REG_DEST_RF => EVEN_REG_DEST, 
        ODD_REG_DEST_RF  => ODD_REG_DEST,  
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
    
    -------------------- INSTANTIATE FORWARDING MACRO/CIRCUIT --------------------
    fwc : forwarding_macro_circuits port map (
        ----- INPUTS -----
        CLK              => CLK,
        EVEN_OPCODE_FM   => EVEN_OPCODE_OUT_RF,     
        ODD_OPCODE_FM    => ODD_OPCODE_OUT_RF,     
        RA_EVEN_DATA_FM  => RA_EVEN_DATA_OUT_RF,    
        RB_EVEN_DATA_FM  => RB_EVEN_DATA_OUT_RF,    
        RC_EVEN_DATA_FM  => RC_EVEN_DATA_OUT_RF,     
        RA_ODD_DATA_FM   => RA_ODD_DATA_OUT_RF,  
        RB_ODD_DATA_FM   => RB_ODD_DATA_OUT_RF,     
        RC_ODD_DATA_FM   => RC_ODD_DATA_OUT_RF,
        RA_EVEN_ADDR_FM  => RA_EVEN_ADDR_OUT_RF,
        RB_EVEN_ADDR_FM  => RB_EVEN_ADDR_OUT_RF, 
        RC_EVEN_ADDR_FM  => RC_EVEN_ADDR_OUT_RF, 
        RA_ODD_ADDR_FM   => RA_ODD_ADDR_OUT_RF, 
        RB_ODD_ADDR_FM   => RB_ODD_ADDR_OUT_RF,
        RC_ODD_ADDR_FM   => RC_ODD_ADDR_OUT_RF,
        EVEN_RI7_FM      => EVEN_RI7_OUT_RF,
        EVEN_RI10_FM     => EVEN_RI10_OUT_RF,
        EVEN_RI16_FM     => EVEN_RI16_OUT_RF,
        ODD_RI7_FM       => ODD_RI7_OUT_RF,
        ODD_RI10_FM      => ODD_RI10_OUT_RF,
        ODD_RI16_FM      => ODD_RI16_OUT_RF,
        ODD_RI18_FM      => ODD_RI18_OUT_RF,  
        EVEN_REG_DEST_FM => EVEN_REG_DEST_OUT_RF, 
        ODD_REG_DEST_FM  => ODD_REG_DEST_OUT_RF,
        RESULT_PACKET_EVEN_FC     => RESULT_PACKET_EVEN_OUT_EOP,
        RESULT_PACKET_ODD_FC      => RESULT_PACKET_ODD_OUT_EOP,
        ----- OUTPUTS -----
        RA_EVEN_DATA_OUT_FM       => RA_EVEN_DATA_OUT_FM,
        RB_EVEN_DATA_OUT_FM       => RB_EVEN_DATA_OUT_FM,
        RC_EVEN_DATA_OUT_FM       => RC_EVEN_DATA_OUT_FM,
        RA_ODD_DATA_OUT_FM        => RA_ODD_DATA_OUT_FM,
        RB_ODD_DATA_OUT_FM        => RB_ODD_DATA_OUT_FM,
        RC_ODD_DATA_OUT_FM        => RC_ODD_DATA_OUT_FM, 
        EVEN_RI7_OUT_FM           => EVEN_RI7_OUT_FM,
        EVEN_RI10_OUT_FM          => EVEN_RI10_OUT_FM, 
        EVEN_RI16_OUT_FM          => EVEN_RI16_OUT_FM, 
        ODD_RI7_OUT_FM            => ODD_RI7_OUT_FM,
        ODD_RI10_OUT_FM           => ODD_RI10_OUT_FM,
        ODD_RI16_OUT_FM           => ODD_RI16_OUT_FM, 
        ODD_RI18_OUT_FM           => ODD_RI18_OUT_FM, 
        EVEN_OPCODE_OUT_FM        => EVEN_OPCODE_OUT_FM,
        ODD_OPCODE_OUT_FM         => ODD_OPCODE_OUT_FM, 
        EVEN_REG_DEST_OUT_FM      => EVEN_REG_DEST_OUT_FM,
        ODD_REG_DEST_OUT_FM       => ODD_REG_DEST_OUT_FM,
        RESULT_PACKET_EVEN_OUT_FC => RESULT_PACKET_EVEN_OUT_FC,
        RESULT_PACKET_ODD_OUT_FC  => RESULT_PACKET_ODD_OUT_FC
    );
    
    -------------------- INSTANTIATE EVEN & ODD PIPES --------------------
    eop : even_odd_pipes port map (
        ----- INPUTS -----
        CLK => CLK,
        EVEN_RI7_EOP         => EVEN_RI7_OUT_FM, 
        EVEN_RI10_EOP        => EVEN_RI10_OUT_FM,   
        EVEN_RI16_EOP        => EVEN_RI16_OUT_FM, 
        EVEN_REG_DEST_EOP    => EVEN_REG_DEST_OUT_FM,
        ODD_RI7_EOP          => ODD_RI7_OUT_FM,    
        ODD_RI10_EOP         => ODD_RI10_OUT_FM,  
        ODD_RI16_EOP         => ODD_RI16_OUT_FM,    
        ODD_RI18_EOP         => ODD_RI18_OUT_FM,    
        ODD_REG_DEST_EOP     => ODD_REG_DEST_OUT_FM, 
        RA_EVEN_DATA_EOP     => RA_EVEN_DATA_OUT_FM,
        RB_EVEN_DATA_EOP     => RB_EVEN_DATA_OUT_FM,
        RC_EVEN_DATA_EOP     => RC_EVEN_DATA_OUT_FM,
        RA_ODD_DATA_EOP      => RA_ODD_DATA_OUT_FM,
        RB_ODD_DATA_EOP      => RB_ODD_DATA_OUT_FM,
        RC_ODD_DATA_EOP      => RC_ODD_DATA_OUT_FM,
        EVEN_OPCODE_EOP      => EVEN_OPCODE_OUT_FM,
        ODD_OPCODE_EOP       => ODD_OPCODE_OUT_FM,
        LOCAL_STORE_DATA_EOP => DATA_OUT_LS,
        -------------------- OUTPUTS --------------------
        LS_WE_OUT_EOP              => LS_WE_OUT_EOP,
        LS_RIB_OUT_EOP             => LS_RIB_OUT_EOP,
        LS_DATA_OUT_EOP            => LS_DATA_OUT_EOP,
        LS_ADDR_OUT_EOP            => LS_ADDR_OUT_EOP,
        RESULT_PACKET_EVEN_OUT_EOP => RESULT_PACKET_EVEN_OUT_EOP,
        RESULT_PACKET_ODD_OUT_EOP  => RESULT_PACKET_ODD_OUT_EOP
    );
    
    ------------------ INSTANTIATE UNIT UNDER TEST --------------------
    ls : local_store port map (
        ----- INPUTS -----
        WE_LS      => LS_WE_OUT_EOP,  
        RIB_LS     => LS_RIB_OUT_EOP,
        ADDR_LS    => LS_ADDR_OUT_EOP,
        DATA_IN_LS => LS_DATA_OUT_EOP,
        ----- OUTPUTS -----
        DATA_OUT_LS        => DATA_OUT_LS,    
        INSTR_BLOCK_OUT_LS => INSTR_BLOCK_OUT_LS
    );
    
    ----- OUTPUT RESULT PACKETS -----
    RESULT_PACKET_EVEN_OUT <= RESULT_PACKET_EVEN_OUT_FC;
    RESULT_PACKET_ODD_OUT  <= RESULT_PACKET_ODD_OUT_FC;
end behavioral;
