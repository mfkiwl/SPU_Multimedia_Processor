--------------------------------------------------------------------------------
-- Company: Stony Brook University
-- Engineer: Wilmer Suarez
--
-- Create Date: 03/21/2019
-- Design Name: Even & Odd Pipe Testbench
-- Tool versions: Vivado v2018.3 (64-bit)
-- Description:
--     Tests that the Instructions are properly executed.
--------------------------------------------------------------------------------
-------------------- LIBRARIES --------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.COMPONENTS_PACKAGE.ALL; -- SPU Core Components

-------------------- ENTITY DEFINITION --------------------
entity even_odd_pipes_TB is
generic (
    ADDR_WIDTH    : NATURAL := 7;    -- Bit-width of the Register Addresses 
    LS_ADDR_WIDTH : NATURAL := 15;   -- Bit-width of the Local Store Addresses
    INSTR_WIDTH   : NATURAL := 1024; -- Bit-width of Instruction Block
    DATA_WIDTH    : NATURAL := 128;  -- Bit-width of the Register Data
    OPCODE_WIDTH  : NATURAL := 11;   -- Maximum bit-width of Even and Odd Opcodes
    RI7_WIDTH     : NATURAL := 7;    -- Immediate 7-bit format
    RI10_WIDTH    : NATURAL := 10;   -- Immediate 10-bit format
    RI16_WIDTH    : NATURAL := 16;   -- Immediate 16-bit format
    RI18_WIDTH    : NATURAL := 18;   -- Immediate 18-bit format
    EXT_WIDTH     : NATURAL := 32    -- Length of Extended Immediates
);
end even_odd_pipes_TB;

-------------------- ARCHITECTURE DEFINITION --------------------
architecture behavioral of even_odd_pipes_TB is
-------------------- EVEN_ODD_PIPES SIGNALS --------------------
-------------------- INPUTS --------------------
signal CLK       : STD_LOGIC := '1';
signal EVEN_RI7  : STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0)  := (others => '0');  
signal EVEN_RI10 : STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0) := (others => '0');
signal EVEN_RI16 : STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0) := (others => '0');
signal ODD_RI7   : STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0)  := (others => '0');  
signal ODD_RI10  : STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0) := (others => '0');
signal ODD_RI16  : STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0) := (others => '0');
signal ODD_RI18  : STD_LOGIC_VECTOR((RI18_WIDTH-1) downto 0) := (others => '0');
signal EVEN_REG_DEST : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0'); 
signal ODD_REG_DEST  : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0'); 
signal RA_EVEN_DATA  : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others=>'0'); 
signal RB_EVEN_DATA  : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others=>'0');
signal RC_EVEN_DATA  : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others=>'0');    
signal RA_ODD_DATA   : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others=>'0'); 
signal RB_ODD_DATA   : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others=>'0'); 
signal RC_ODD_DATA   : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others=>'0'); 
signal EVEN_OPCODE   : STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0)  := (others=>'0');
signal ODD_OPCODE    : STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0)  := (others=>'0');
signal LOCAL_STORE_DATA : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others => '0'); 
-------------------- OUTPUTS --------------------
signal WE_OUT  : STD_LOGIC := '0'; 
signal RIB_OUT : STD_LOGIC := '0';
signal LS_DATA_OUT        : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)    := (others => '0'); 
signal LOCAL_STORE_ADDR   : STD_LOGIC_VECTOR((LS_ADDR_WIDTH-1) downto 0) := (others => '0');
signal RESULT_PACKET_EVEN_OUT : RESULT_PACKET_EVEN := ((others => '0'), (others => '0'), '0', 0);   
signal RESULT_PACKET_ODD_OUT  : RESULT_PACKET_ODD  := ((others => '0'), (others => '0'), '0', 0);    
-------------------- LOCAL STORE SIGNALS --------------------
----- INPUTS -----
signal WE      : STD_LOGIC := '0'; 
signal RIB     : STD_LOGIC := '0'; 
signal ADDR    : STD_LOGIC_VECTOR((LS_ADDR_WIDTH-1) downto 0) := (others => '0');   
signal DATA_IN : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)    := (others => '0');
----- OUTPUTS -----
signal DATA_OUT        : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)  := (others => '0');     
signal INSTR_BLOCK_OUT : STD_LOGIC_VECTOR((INSTR_WIDTH-1) downto 0) := (others => '0');
-------------------- CLOCK --------------------
constant CLK_PERIOD : TIME := 10ns;
begin
    -------------------- INSTANTIATE EVEN & ODD PIPE --------------------
    eop : even_odd_pipes port map (
        CLK       => CLK,
        EVEN_RI7_EOP  => EVEN_RI7,
        EVEN_RI10_EOP => EVEN_RI10,
        EVEN_RI16_EOP => EVEN_RI16,
        EVEN_REG_DEST_EOP => EVEN_REG_DEST, 
        ODD_RI7_EOP   => ODD_RI7,
        ODD_RI10_EOP  => ODD_RI10,
        ODD_RI16_EOP  => ODD_RI16,
        ODD_RI18_EOP  => ODD_RI18,
        ODD_REG_DEST_EOP  => ODD_REG_DEST, 
        RA_EVEN_DATA_EOP  => RA_EVEN_DATA, 
        RB_EVEN_DATA_EOP  => RB_EVEN_DATA,
        RC_EVEN_DATA_EOP  => RC_EVEN_DATA,    
        RA_ODD_DATA_EOP   => RA_ODD_DATA, 
        RB_ODD_DATA_EOP   => RB_ODD_DATA, 
        RC_ODD_DATA_EOP   => RC_ODD_DATA,
        EVEN_OPCODE_EOP   => EVEN_OPCODE,
        ODD_OPCODE_EOP    => ODD_OPCODE,
        LOCAL_STORE_DATA_EOP   => DATA_OUT,
        RESULT_PACKET_EVEN_OUT_EOP => RESULT_PACKET_EVEN_OUT,  
        RESULT_PACKET_ODD_OUT_EOP  => RESULT_PACKET_ODD_OUT
    );
    
    -------------------- CLK GENERATION PROCESS --------------------
    CLK <= not CLK after CLK_PERIOD/2;

    -------------------- EVEN & ODD PIPES PROCESS --------------------
    SIMULUS_PROC : process
    begin         
        ----- Test the Add Word Instruction  -----
        EVEN_OPCODE <= "-------" & "1100";
        
        ODD_OPCODE <= "01000000001";
        
        wait;
    end process;
end behavioral;
