--------------------------------------------------------------------------------
-- Company: Stony Brook University
-- Engineer: Wilmer Suarez
--
-- Create Date: 03/22/2019
-- Design Name: SPU Core Testbench
-- Tool versions: Vivado v2018.3 (64-bit)
-- Description:
--     Test All Instructions 
--------------------------------------------------------------------------------
------------------ LIBRARIES --------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.COMPONENTS_PACKAGE.ALL; -- SPU Core Components

-------------------- ENTITY DEFINITION --------------------
entity even_odd_pipes_TB is
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
end even_odd_pipes_TB;

-------------------- ARCHITECTURE DEFINITION --------------------
architecture behavioral of even_odd_pipes_TB is
signal CLK : STD_LOGIC;
signal EVEN_OPCODE : STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0) := (others => '0'); 
signal RA_EVEN_ADDR : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0'); 
signal RB_EVEN_ADDR : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0'); 
signal RC_EVEN_ADDR : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0'); 
signal EVEN_REG_DEST : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0');
signal EVEN_RI7 : STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0) := (others => '0');   
signal EVEN_RI10 : STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0) := (others => '0');
signal EVEN_RI16 : STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0) := (others => '0');
signal ODD_OPCODE : STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0) := (others => '0'); 
signal RA_ODD_ADDR : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0');  
signal RB_ODD_ADDR : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0');  
signal RC_ODD_ADDR : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0');  
signal ODD_REG_DEST : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0'); 
signal ODD_RI7 : STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0) := (others => '0');  
signal ODD_RI10 : STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0) := (others => '0'); 
signal ODD_RI16 : STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0) := (others => '0'); 
signal ODD_RI18 : STD_LOGIC_VECTOR((RI18_WIDTH-1) downto 0) := (others => '0');
signal RESULT_PACKET_EVEN_OUT : RESULT_PACKET := ((others => '0'), (others => '0'), '0', 0); 
signal RESULT_PACKET_ODD_OUT : RESULT_PACKET := ((others => '0'), (others => '0'), '0', 0);  
-------------------- CLOCK --------------------
constant CLK_PERIOD : TIME := 10ns;
begin    
    -------------------- INSTANTIATE UNIT UNDER TEST --------------------
    UUT : SPU_CORE_TOP_MODULE port map (
        CLK => CLK,
        EVEN_OPCODE => EVEN_OPCODE,
        RA_EVEN_ADDR => RA_EVEN_ADDR,
        RB_EVEN_ADDR => RB_EVEN_ADDR,
        RC_EVEN_ADDR => RC_EVEN_ADDR,
        EVEN_REG_DEST => EVEN_REG_DEST,
        EVEN_RI7 => EVEN_RI7, 
        EVEN_RI10 => EVEN_RI10,
        EVEN_RI16 => EVEN_RI16,
        ODD_OPCODE => ODD_OPCODE,
        RA_ODD_ADDR => RA_ODD_ADDR,
        RB_ODD_ADDR => RB_ODD_ADDR,
        RC_ODD_ADDR => RC_ODD_ADDR,
        ODD_REG_DEST => ODD_REG_DEST,
        ODD_RI7 => ODD_RI7,
        ODD_RI10 => ODD_RI10,
        ODD_RI16 => ODD_RI16,
        ODD_RI18 => ODD_RI18,
        RESULT_PACKET_EVEN_OUT => RESULT_PACKET_EVEN_OUT,
        RESULT_PACKET_ODD_OUT => RESULT_PACKET_ODD_OUT
    );
    -------------------- CLK GENERATION PROCESS --------------------
    CLK <= not CLK after CLK_PERIOD/2;

    -------------------- SPU CORE PROCESS --------------------
    SIMULUS_PROC : process
    begin         
        -- Add Word
        EVEN_OPCODE <= STD_LOGIC_VECTOR(to_unsigned(192, OPCODE_WIDTH));
        RA_EVEN_ADDR <= STD_LOGIC_VECTOR(to_unsigned(0, ADDR_WIDTH));
        RB_EVEN_ADDR <= STD_LOGIC_VECTOR(to_unsigned(1, ADDR_WIDTH));
        EVEN_REG_DEST <= STD_LOGIC_VECTOR(to_unsigned(3, ADDR_WIDTH));
        
        -- Load Quadword (a-form)
        ODD_OPCODE <= STD_LOGIC_VECTOR(to_unsigned(97, OPCODE_WIDTH)); 
        ODD_REG_DEST <= STD_LOGIC_VECTOR(to_unsigned(4, ADDR_WIDTH));
        ODD_RI16 <= STD_LOGIC_VECTOR(to_unsigned(1024, RI16_WIDTH));
        
        wait for CLK_PERIOD;
        
        -- Add Word Immediate
        EVEN_OPCODE <= STD_LOGIC_VECTOR(to_unsigned(28, OPCODE_WIDTH));
        RA_EVEN_ADDR <= STD_LOGIC_VECTOR(to_unsigned(0, ADDR_WIDTH));
        RB_EVEN_ADDR <= STD_LOGIC_VECTOR(to_unsigned(1, ADDR_WIDTH));
        EVEN_REG_DEST <= STD_LOGIC_VECTOR(to_unsigned(3, ADDR_WIDTH));
        
        -- Load Quadword (a-form)
        ODD_OPCODE <= STD_LOGIC_VECTOR(to_unsigned(97, OPCODE_WIDTH)); 
        ODD_REG_DEST <= STD_LOGIC_VECTOR(to_unsigned(4, ADDR_WIDTH));
        ODD_RI16 <= STD_LOGIC_VECTOR(to_unsigned(1024, RI16_WIDTH));
        
        wait for CLK_PERIOD;
        
        wait;
    end process;
end behavioral;
