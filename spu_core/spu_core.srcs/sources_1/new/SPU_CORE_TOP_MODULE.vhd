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
entity spu_core_top_module is
generic (
    OPCODE_WIDTH : NATURAL := 11;  -- Maximum bit-width of Even and Odd Opcodes
    INSTR_WIDTH : NATURAL := 1024; -- Bit-width of Instruction Block
    DATA_WIDTH : NATURAL := 128;   -- Bit-width of the Register Data
    ADDR_WIDTH : NATURAL := 7;     -- Bit-width of the Register Addresses 
    LS_ADDR_WIDTH : NATURAL := 15; -- Bit-width of the Local Store Addresses
    RI7_WIDTH : NATURAL := 7;      -- Immediate 7-bit format
    RI10_WIDTH : NATURAL := 10;    -- Immediate 10-bit format
    RI16_WIDTH : NATURAL := 16;    -- Immediate 16-bit format
    RI18_WIDTH : NATURAL := 18     -- Immediate 18-bit format
);
port (
    -------------------- INPUTS --------------------
    CLK : in STD_LOGIC := '0';     -- System Wide Synchronous Clock
    ----- EVEN PIPE INPUT SIGNALS -----
    EVEN_OPCODE : in STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0) := (others => '0'); -- Even Pipe Opcode
    RA_EVEN_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0');  -- Even Pipe RA Register Address
    RB_EVEN_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0');  -- Even Pipe RB Register Address
    RC_EVEN_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0');  -- Even Pipe RC Register Address
    EVEN_REG_DEST : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0'); -- Even Write back Address (RT)
    EVEN_RI7 : in STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0) := (others => '0');   -- Even Immediate RI7
    EVEN_RI10 : in STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0) := (others => '0'); -- Even Immediate RI10
    EVEN_RI16 : in STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0) := (others => '0'); -- Even Immediate RI16
    ----- ODD PIPE INPUT SIGNALS -----
    ODD_OPCODE : in STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0) := (others => '0');  -- Even Pipe Opcode
    RA_ODD_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0');   -- Odd Pipe RA Register Address
    RB_ODD_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0');   -- Odd Pipe RB Register Address
    RC_ODD_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0');   -- Odd Pipe RC Register Address
    ODD_REG_DEST : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0');  -- Odd Write back Address (RT)
    ODD_RI7 : in STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0) := (others => '0');  -- Odd Immediate RI7
    ODD_RI10 : in STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0) := (others => '0'); -- Odd Immediate RI10
    ODD_RI16 : in STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0) := (others => '0'); -- Odd Immediate RI16
    ODD_RI18 : in STD_LOGIC_VECTOR((RI18_WIDTH-1) downto 0) := (others => '0'); -- Odd Immediate RI18
    -------------------- OUTPUTS --------------------
    RESULT_PACKET_EVEN_OUT : out RESULT_PACKET := ((others => '0'), (others => '0'), '0', 0); -- Even Pipe Result Packet to Write Back Stage 
    RESULT_PACKET_ODD_OUT : out RESULT_PACKET := ((others => '0'), (others => '0'), '0', 0)   -- Odd Pipe Result Packet to Write Back Stage 
);
end spu_core_top_module;

-------------------- ARCHITECTURE DEFINITION --------------------
architecture behavioral of spu_core_top_module is
-------------------- REGISTER FILE -> FORWARDING MACRO SIGNALS --------------------
signal EVEN_OPCODE_OUT : STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0) := (others => '0'); 
signal RA_EVEN_DATA_OUT : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others => '0'); 
signal RB_EVEN_DATA_OUT : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others => '0'); 
signal RC_EVEN_DATA_OUT : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others => '0');
signal ODD_OPCODE_OUT : STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0) := (others => '0'); 
signal RA_ODD_DATA_OUT : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others => '0'); 
signal RB_ODD_DATA_OUT : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others => '0'); 
signal RC_ODD_DATA_OUT : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others => '0'); 
signal RA_EVEN_ADDR_OUT : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0'); 
signal RB_EVEN_ADDR_OUT : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0'); 
signal RC_EVEN_ADDR_OUT : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0'); 
signal RA_ODD_ADDR_OUT : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0'); 
signal RB_ODD_ADDR_OUT : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0');  
signal RC_ODD_ADDR_OUT : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0'); 
signal EVEN_RI7_OUT : STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0) := (others => '0');     
signal EVEN_RI10_OUT : STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0) := (others => '0');   
signal EVEN_RI16_OUT : STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0) := (others => '0');    
signal ODD_RI7_OUT : STD_LOGIC_VECTOR((RI18_WIDTH-1) downto 0) := (others => '0');      
signal ODD_RI10_OUT : STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0) := (others => '0');    
signal ODD_RI16_OUT : STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0) := (others => '0');   
signal ODD_RI18_OUT : STD_LOGIC_VECTOR((RI18_WIDTH-1) downto 0) := (others => '0'); 
signal EVEN_REG_DEST_OUT : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0'); 
signal ODD_REG_DEST_OUT : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0'); 
-------------------- FORWARDING MACRO -> EVEN ODD PIPES SIGNALS --------------------
signal RA_EVEN_DATA_OUT_FM : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others=>'0'); 
signal RB_EVEN_DATA_OUT_FM : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others=>'0'); 
signal RC_EVEN_DATA_OUT_FM : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others=>'0'); 
signal RA_ODD_DATA_OUT_FM : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others=>'0');  
signal RB_ODD_DATA_OUT_FM : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others=>'0'); 
signal RC_ODD_DATA_OUT_FM : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others=>'0'); 
signal RESULT_PACKET_EVEN_OUT_FM : RESULT_PACKET := ((others => '0'), (others => '0'), '0', 0); 
signal RESULT_PACKET_ODD_OUT_FM : RESULT_PACKET := ((others => '0'), (others => '0'), '0', 0); 
signal EVEN_RI7_OUT_FM : STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0) := (others => '0');  
signal EVEN_RI10_OUT_FM : STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0) := (others => '0'); 
signal EVEN_RI16_OUT_FM : STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0) := (others => '0');
signal ODD_RI7_OUT_FM : STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0) := (others => '0'); 
signal ODD_RI10_OUT_FM : STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0) := (others => '0'); 
signal ODD_RI16_OUT_FM : STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0) := (others => '0'); 
signal ODD_RI18_OUT_FM : STD_LOGIC_VECTOR((RI18_WIDTH-1) downto 0) := (others => '0');  
signal EVEN_REG_DEST_OUT_FM : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0');  
signal ODD_REG_DEST_OUT_FM : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0');  
signal EVEN_OPCODE_OUT_FM : STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0) := (others=>'0');
signal ODD_OPCODE_OUT_FM : STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0) := (others=>'0');
-------------------- EVEN ODD PIPES -> FORWARDING CIRCUITS SIGNALS --------------------
signal LOCAL_STORE_ADDR : STD_LOGIC_VECTOR((LS_ADDR_WIDTH-1) downto 0) := (others => '0');
signal RESULT_PACKET_EVEN : RESULT_PACKET := ((others => '0'), (others => '0'), '0', 0);   
signal RESULT_PACKET_ODD : RESULT_PACKET := ((others => '0'), (others => '0'), '0', 0); 
-------------------- EVEN ODD PIPES -> LOCAL STORE SIGNALS --------------------
signal WE_OUT : STD_LOGIC := '0'; 
signal RIB_OUT : STD_LOGIC := '0';
signal LS_DATA_OUT : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others => '0'); 
-------------------- LOCAL STORE -> EVEN ODD PIPES SIGNALS --------------------
signal DATA_OUT : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others => '0');     
signal INSTR_BLOCK_OUT : STD_LOGIC_VECTOR((INSTR_WIDTH-1) downto 0) := (others => '0');
begin
    -------------------- INSTANTIATE REGISTER FILE --------------------
    rf :register_file port map (
        ----- INPUTS -----
        CLK => CLK,
        RW_EVEN => RESULT_PACKET_EVEN.RW,
        RW_ODD => RESULT_PACKET_ODD.RW,
        EVEN_OPCODE => EVEN_OPCODE,
        RA_EVEN_ADDR => RA_EVEN_ADDR,
        RB_EVEN_ADDR => RB_EVEN_ADDR,
        RC_EVEN_ADDR => RC_EVEN_ADDR,
        EVEN_WB_ADDR => RESULT_PACKET_EVEN.REG_DEST,
        EVEN_WB_DATA => RESULT_PACKET_EVEN.RESULT,
        ODD_OPCODE => ODD_OPCODE,
        RA_ODD_ADDR => RA_ODD_ADDR,
        RB_ODD_ADDR => RB_ODD_ADDR,
        RC_ODD_ADDR => RC_ODD_ADDR,
        ODD_WB_ADDR => RESULT_PACKET_ODD.REG_DEST,
        ODD_WB_DATA => RESULT_PACKET_ODD.RESULT,
        EVEN_RI7 => EVEN_RI7, 
        EVEN_RI10 => EVEN_RI10,
        EVEN_RI16 => EVEN_RI16,
        ODD_RI7 => ODD_RI7,
        ODD_RI10 => ODD_RI10,
        ODD_RI16 => ODD_RI16,
        ODD_RI18 => ODD_RI18,
        EVEN_REG_DEST => EVEN_REG_DEST,
        ODD_REG_DEST => ODD_REG_DEST,
        ----- OUTPUTS -----
        EVEN_OPCODE_OUT => EVEN_OPCODE_OUT,
        RA_EVEN_DATA_OUT => RA_EVEN_DATA_OUT,
        RB_EVEN_DATA_OUT => RB_EVEN_DATA_OUT,
        RC_EVEN_DATA_OUT => RC_EVEN_DATA_OUT,
        ODD_OPCODE_OUT => ODD_OPCODE_OUT,
        RA_ODD_DATA_OUT => RA_ODD_DATA_OUT,
        RB_ODD_DATA_OUT => RB_ODD_DATA_OUT,
        RC_ODD_DATA_OUT => RC_ODD_DATA_OUT,
        RA_EVEN_ADDR_OUT => RA_EVEN_ADDR_OUT,
        RB_EVEN_ADDR_OUT => RB_EVEN_ADDR_OUT,
        RC_EVEN_ADDR_OUT => RC_EVEN_ADDR_OUT,
        RA_ODD_ADDR_OUT => RA_ODD_ADDR_OUT,
        RB_ODD_ADDR_OUT => RB_ODD_ADDR_OUT,
        RC_ODD_ADDR_OUT => RC_ODD_ADDR_OUT,
        EVEN_RI7_OUT => EVEN_RI7_OUT,
        EVEN_RI10_OUT => EVEN_RI10_OUT,
        EVEN_RI16_OUT => EVEN_RI16_OUT,
        ODD_RI7_OUT => ODD_RI7_OUT,
        ODD_RI10_OUT => ODD_RI10_OUT,
        ODD_RI16_OUT => ODD_RI16_OUT,
        ODD_RI18_OUT => ODD_RI18_OUT,
        EVEN_REG_DEST_OUT => EVEN_REG_DEST_OUT,
        ODD_REG_DEST_OUT => ODD_REG_DEST_OUT
    );
    
    -------------------- INSTANTIATE EVEN_ODD_PIPES --------------------
    fwc : forwarding_macro_circuits port map (
        ----- INPUTS -----
        CLK => CLK,
        EVEN_OPCODE => EVEN_OPCODE_OUT,
        ODD_OPCODE => ODD_OPCODE_OUT,
        RESULT_PACKET_EVEN_IN => RESULT_PACKET_EVEN,
        RESULT_PACKET_ODD_IN => RESULT_PACKET_ODD,
        RA_EVEN_DATA => RA_EVEN_DATA_OUT,
        RB_EVEN_DATA => RB_EVEN_DATA_OUT,
        RC_EVEN_DATA => RC_EVEN_DATA_OUT,
        RA_ODD_DATA => RA_ODD_DATA_OUT,
        RB_ODD_DATA => RB_ODD_DATA_OUT,
        RC_ODD_DATA => RC_ODD_DATA_OUT,
        EVEN_REG_DEST => EVEN_REG_DEST_OUT,
        ODD_REG_DEST => ODD_REG_DEST_OUT,
        RA_EVEN_ADDR => RA_EVEN_ADDR_OUT,
        RB_EVEN_ADDR => RB_EVEN_ADDR_OUT,
        RC_EVEN_ADDR => RC_EVEN_ADDR_OUT,
        RA_ODD_ADDR => RA_ODD_ADDR_OUT,
        RB_ODD_ADDR => RB_ODD_ADDR_OUT,
        RC_ODD_ADDR => RC_ODD_ADDR_OUT,
        EVEN_RI7 => EVEN_RI7_OUT,
        EVEN_RI10 => EVEN_RI10_OUT,
        EVEN_RI16 => EVEN_RI16_OUT,
        ODD_RI7 => ODD_RI7_OUT,
        ODD_RI10 => ODD_RI10_OUT, 
        ODD_RI16 => ODD_RI16_OUT,
        ODD_RI18 => ODD_RI18_OUT,
        ----- OUTPUTS -----
        RA_EVEN_DATA_OUT_FM => RA_EVEN_DATA_OUT_FM,
        RB_EVEN_DATA_OUT_FM => RB_EVEN_DATA_OUT_FM,
        RC_EVEN_DATA_OUT_FM => RC_EVEN_DATA_OUT_FM,     
        RA_ODD_DATA_OUT_FM => RA_ODD_DATA_OUT_FM,
        RB_ODD_DATA_OUT_FM => RB_ODD_DATA_OUT_FM,
        RC_ODD_DATA_OUT_FM => RC_ODD_DATA_OUT_FM,
        RESULT_PACKET_EVEN_OUT_FM => RESULT_PACKET_EVEN_OUT_FM,
        RESULT_PACKET_ODD_OUT_FM => RESULT_PACKET_ODD_OUT_FM,
        EVEN_RI7_OUT_FM => EVEN_RI7_OUT_FM,
        EVEN_RI10_OUT_FM => EVEN_RI10_OUT_FM,
        EVEN_RI16_OUT_FM => EVEN_RI16_OUT_FM, 
        ODD_RI7_OUT_FM => ODD_RI7_OUT_FM,
        ODD_RI10_OUT_FM => ODD_RI10_OUT_FM, 
        ODD_RI16_OUT_FM => ODD_RI16_OUT_FM,
        ODD_RI18_OUT_FM => ODD_RI18_OUT_FM,
        EVEN_REG_DEST_OUT_FM => EVEN_REG_DEST_OUT_FM,
        ODD_REG_DEST_OUT_FM => ODD_REG_DEST_OUT_FM,
        EVEN_OPCODE_OUT_FM => EVEN_OPCODE_OUT_FM,
        ODD_OPCODE_OUT_FM => ODD_OPCODE_OUT_FM
    );
    
    -------------------- INSTANTIATE EVEN & ODD PIPES --------------------
    eop : even_odd_pipes port map (
        ----- INPUTS -----
        CLK => CLK,
        EVEN_RI7 => EVEN_RI7_OUT_FM,
        EVEN_RI10 => EVEN_RI10_OUT_FM,
        EVEN_RI16 => EVEN_RI16_OUT_FM,
        ODD_RI7 => ODD_RI7_OUT_FM,
        ODD_RI10 => ODD_RI10_OUT_FM,
        ODD_RI16 => ODD_RI16_OUT_FM,
        ODD_RI18 => ODD_RI18_OUT_FM,
        EVEN_REG_DEST => EVEN_REG_DEST_OUT_FM, 
        ODD_REG_DEST => ODD_REG_DEST_OUT_FM, 
        RA_EVEN_DATA => RA_EVEN_DATA_OUT_FM, 
        RB_EVEN_DATA => RB_EVEN_DATA_OUT_FM,
        RC_EVEN_DATA => RC_EVEN_DATA_OUT_FM,    
        RA_ODD_DATA => RA_ODD_DATA_OUT_FM, 
        RB_ODD_DATA => RB_ODD_DATA_OUT_FM, 
        RC_ODD_DATA => RC_ODD_DATA_OUT_FM,
        EVEN_OPCODE => EVEN_OPCODE_OUT_FM,
        ODD_OPCODE => ODD_OPCODE_OUT_FM,
        LOCAL_STORE_DATA => DATA_OUT,
        ----- OUTPUTS -----
        LOCAL_STORE_ADDR => LOCAL_STORE_ADDR,
        RESULT_PACKET_EVEN => RESULT_PACKET_EVEN,  
        RESULT_PACKET_ODD => RESULT_PACKET_ODD
    );
    
    ------------------ INSTANTIATE UNIT UNDER TEST --------------------
    ls : local_store port map (
        WE => WE_OUT,
        RIB => RIB_OUT,
        ADDR => LOCAL_STORE_ADDR,
        DATA_IN => LS_DATA_OUT,
        DATA_OUT => DATA_OUT,
        INSTR_BLOCK_OUT => INSTR_BLOCK_OUT
    );
end behavioral;
