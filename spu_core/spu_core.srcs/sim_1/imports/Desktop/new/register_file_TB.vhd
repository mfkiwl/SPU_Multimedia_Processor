--------------------------------------------------------------------------------
-- Company: Stony Brook University
-- Engineer: Wilmer Suarez
--
-- Create Date: 03/10/2019
-- Design Name: Register File Testbench
-- Tool versions: Vivado v2018.3 (64-bit)
-- Description:
--     - Testing reading and writing to the Register File.
--     - Testing forwarding functionality. 
--------------------------------------------------------------------------------
-------------------- LIBRARIES --------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; 
use work.COMPONENTS_PACKAGE.ALL; -- SPU Core Components

-------------------- ENTITY DEFINITION --------------------
entity register_file_TB is
generic (
   ADDR_WIDTH   : NATURAL := 7;   -- Bit-width of the Register Addresses 
   DATA_WIDTH   : NATURAL := 128; -- Bit-width of the Register Data
   OPCODE_WIDTH : NATURAL := 11;  -- Maximum Bit-width of Opcode
   RI7_WIDTH    : NATURAL := 7;   -- Immediate 7-bit format
   RI10_WIDTH   : NATURAL := 10;  -- Immediate 10-bit format
   RI16_WIDTH   : NATURAL := 16;  -- Immediate 16-bit format
   RI18_WIDTH   : NATURAL := 18   -- Immediate 18-bit format
);
end register_file_TB;

-------------------- ARCHITECTURE DEFINITION --------------------
architecture behavioral of register_file_TB is
-------------------- INPUTS --------------------
signal CLK     : STD_LOGIC := '1';    
signal RW_EVEN : STD_LOGIC := '0';
signal RW_ODD  : STD_LOGIC := '0'; 
signal EVEN_OPCODE  : STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0) := (others => '0');
signal RA_EVEN_ADDR : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0');
signal RB_EVEN_ADDR : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0'); 
signal RC_EVEN_ADDR : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0'); 
signal EVEN_WB_ADDR : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0'); 
signal EVEN_WB_DATA : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)   := (others => '0');
signal ODD_OPCODE   : STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0) := (others => '0');
signal RA_ODD_ADDR  : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0');  
signal RB_ODD_ADDR  : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0');  
signal RC_ODD_ADDR  : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0'); 
signal ODD_WB_ADDR  : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0');  
signal ODD_WB_DATA  : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)   := (others => '0');
signal EVEN_RI7  : STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0)  := (others => '0');     
signal EVEN_RI10 : STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0) := (others => '0');  
signal EVEN_RI16 : STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0) := (others => '0');  
signal ODD_RI7   : STD_LOGIC_VECTOR((RI18_WIDTH-1) downto 0) := (others => '0');     
signal ODD_RI10  : STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0) := (others => '0');
signal ODD_RI16  : STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0) := (others => '0');    
signal ODD_RI18  : STD_LOGIC_VECTOR((RI18_WIDTH-1) downto 0) := (others => '0');
signal EVEN_REG_DEST : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0');
signal ODD_REG_DEST  : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0'); 
-------------------- OUTPUTS --------------------
signal EVEN_OPCODE_OUT  : STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0) := (others => '0'); 
signal RA_EVEN_DATA_OUT : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)   := (others => '0'); 
signal RB_EVEN_DATA_OUT : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)   := (others => '0'); 
signal RC_EVEN_DATA_OUT : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)   := (others => '0');
signal ODD_OPCODE_OUT   : STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0) := (others => '0'); 
signal RA_ODD_DATA_OUT  : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)   := (others => '0'); 
signal RB_ODD_DATA_OUT  : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)   := (others => '0'); 
signal RC_ODD_DATA_OUT  : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)   := (others => '0'); 
signal RA_EVEN_ADDR_OUT : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0'); 
signal RB_EVEN_ADDR_OUT : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0'); 
signal RC_EVEN_ADDR_OUT : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0'); 
signal RA_ODD_ADDR_OUT  : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0'); 
signal RB_ODD_ADDR_OUT  : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0');  
signal RC_ODD_ADDR_OUT  : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0'); 
signal EVEN_RI7_OUT  : STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0)  := (others => '0');     
signal EVEN_RI10_OUT : STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0) := (others => '0');   
signal EVEN_RI16_OUT : STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0) := (others => '0');    
signal ODD_RI7_OUT   : STD_LOGIC_VECTOR((RI18_WIDTH-1) downto 0) := (others => '0');      
signal ODD_RI10_OUT  : STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0) := (others => '0');    
signal ODD_RI16_OUT  : STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0) := (others => '0');   
signal ODD_RI18_OUT  : STD_LOGIC_VECTOR((RI18_WIDTH-1) downto 0) := (others => '0'); 
signal EVEN_REG_DEST_OUT : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0'); 
signal ODD_REG_DEST_OUT  : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0');  
----- CLOCK PERIOD -----
constant CLK_PERIOD : TIME := 10ns;
begin
    -------------------- INSTANTIATE UNIT UNDER TEST --------------------
    UUT : register_file port map (
        CLK     => CLK,
        RW_EVEN => RW_EVEN,
        RW_ODD  => RW_ODD,
        EVEN_OPCODE  => EVEN_OPCODE,
        RA_EVEN_ADDR => RA_EVEN_ADDR,
        RB_EVEN_ADDR => RB_EVEN_ADDR,
        RC_EVEN_ADDR => RC_EVEN_ADDR,
        EVEN_WB_ADDR => EVEN_WB_ADDR,
        EVEN_WB_DATA => EVEN_WB_DATA,
        ODD_OPCODE   => ODD_OPCODE,
        RA_ODD_ADDR  => RA_ODD_ADDR,
        RB_ODD_ADDR  => RB_ODD_ADDR,
        RC_ODD_ADDR  => RC_ODD_ADDR,
        ODD_WB_ADDR  => ODD_WB_ADDR,
        ODD_WB_DATA  => ODD_WB_DATA,
        EVEN_RI7  => EVEN_RI7, 
        EVEN_RI10 => EVEN_RI10,
        EVEN_RI16 => EVEN_RI16,
        ODD_RI7   => ODD_RI7,
        ODD_RI10  => ODD_RI10,
        ODD_RI16  => ODD_RI16,
        ODD_RI18  => ODD_RI18,
        EVEN_REG_DEST => EVEN_REG_DEST,
        ODD_REG_DEST  => ODD_REG_DEST,
        EVEN_OPCODE_OUT  => EVEN_OPCODE_OUT,
        RA_EVEN_DATA_OUT => RA_EVEN_DATA_OUT,
        RB_EVEN_DATA_OUT => RB_EVEN_DATA_OUT,
        RC_EVEN_DATA_OUT => RC_EVEN_DATA_OUT,
        ODD_OPCODE_OUT   => ODD_OPCODE_OUT,
        RA_ODD_DATA_OUT  => RA_ODD_DATA_OUT,
        RB_ODD_DATA_OUT  => RB_ODD_DATA_OUT,
        RC_ODD_DATA_OUT  => RC_ODD_DATA_OUT,
        RA_EVEN_ADDR_OUT => RA_EVEN_ADDR_OUT,
        RB_EVEN_ADDR_OUT => RB_EVEN_ADDR_OUT,
        RC_EVEN_ADDR_OUT => RC_EVEN_ADDR_OUT,
        RA_ODD_ADDR_OUT  => RA_ODD_ADDR_OUT,
        RB_ODD_ADDR_OUT  => RB_ODD_ADDR_OUT,
        RC_ODD_ADDR_OUT  => RC_ODD_ADDR_OUT,
        EVEN_RI7_OUT  => EVEN_RI7_OUT,
        EVEN_RI10_OUT => EVEN_RI10_OUT,
        EVEN_RI16_OUT => EVEN_RI16_OUT,
        ODD_RI7_OUT   => ODD_RI7_OUT,
        ODD_RI10_OUT  => ODD_RI10_OUT,
        ODD_RI16_OUT  => ODD_RI16_OUT,
        ODD_RI18_OUT  => ODD_RI18_OUT,
        EVEN_REG_DEST_OUT => EVEN_REG_DEST_OUT,
        ODD_REG_DEST_OUT  => ODD_REG_DEST_OUT
    );
    
    -------------------- CLK GENERATION PROCESS --------------------
    CLK <= not CLK after CLK_PERIOD/2;

    -------------------- REGISTER FILE STIMULUS PROCESS --------------------
    SIMULUS_PROC : process
        variable ri : INTEGER := 0; -- Regiser Index
    begin 
        ----- Hold Reset for 50ns -----
        wait for CLK_PERIOD*5;
        
        ----- Fill All Registers -----
        RW_EVEN <= '1'; -- Enable Even Register Write Control Signal
        RW_ODD  <= '1'; -- Enable Odd Register WriteControl Signal
        while (ri < (DATA_WIDTH-1)) loop
            EVEN_WB_ADDR <= STD_LOGIC_VECTOR(to_unsigned(ri, EVEN_WB_ADDR'length));
            EVEN_WB_DATA <= STD_LOGIC_VECTOR(to_unsigned(ri, EVEN_WB_DATA'length));
            ri := ri + 1;
            wait for CLK_PERIOD;
            ODD_WB_ADDR <= STD_LOGIC_VECTOR(to_unsigned(ri, ODD_WB_ADDR'length));
            ODD_WB_DATA <= STD_LOGIC_VECTOR(to_unsigned(ri, ODD_WB_DATA'length));
            ri := ri + 1;
            wait for CLK_PERIOD;
        end loop;
        wait for CLK_PERIOD;
        
        ----- Read Test -----
        RW_EVEN <= '0'; -- Disable Even Register Write Control Signal
        RW_ODD  <= '0'; -- Disable Odd Register WriteControl Signal
        wait for CLK_PERIOD;
        -- Read Initial Values --
        RA_EVEN_ADDR <= STD_LOGIC_VECTOR(to_unsigned(0, RA_EVEN_ADDR'length));
        RB_EVEN_ADDR <= STD_LOGIC_VECTOR(to_unsigned(1, RB_EVEN_ADDR'length));
        RC_EVEN_ADDR <= STD_LOGIC_VECTOR(to_unsigned(2, RC_EVEN_ADDR'length));
        RA_ODD_ADDR  <= STD_LOGIC_VECTOR(to_unsigned(3, RA_ODD_ADDR'length));
        RB_ODD_ADDR  <= STD_LOGIC_VECTOR(to_unsigned(4, RB_ODD_ADDR'length));
        RC_ODD_ADDR  <= STD_LOGIC_VECTOR(to_unsigned(5, RC_ODD_ADDR'length));
        wait for CLK_PERIOD;
        
        ----- Write Random Data to Arbitrary Register -----
        RW_EVEN <= '1'; -- Enable Even Register Write Control Signal
        RW_ODD  <= '0'; -- Disable Odd Register WriteControl Signal
        EVEN_WB_ADDR <= STD_LOGIC_VECTOR(to_unsigned(78, EVEN_WB_ADDR'length));
        EVEN_WB_DATA <= x"DEAD_BEEF_DEAF_DEED_FACE_CAFE_DEED_C0DE";
        wait for CLK_PERIOD;
        
        ----- Read the Arbitrary Register -----
        RW_EVEN <= '0'; -- Disable Even Register Write Control Signal
        RW_ODD  <= '0'; -- Disable Odd Register WriteControl Signal
        EVEN_WB_ADDR <= STD_LOGIC_VECTOR(to_unsigned(0, EVEN_WB_ADDR'length));
        wait for CLK_PERIOD;
        RA_EVEN_ADDR <= STD_LOGIC_VECTOR(to_unsigned(78, RA_EVEN_ADDR'length));
        wait for CLK_PERIOD;
        
        ----- Test Data Forwarding -----
        RW_EVEN <= '0'; -- Disable Even Register Write Control Signal
        RW_ODD  <= '1'; -- Enable Odd Register WriteControl Signal
        RC_ODD_ADDR <= STD_LOGIC_VECTOR(to_unsigned(77, RC_ODD_ADDR'length));  -- Reading Register 77
        ODD_WB_ADDR <= STD_LOGIC_VECTOR(to_unsigned(77, EVEN_WB_ADDR'length)); -- Writing Register 77
        ODD_WB_DATA <= x"F00D_C0FFEE_DAD_A_FADE_FEED_BABE_ABED_AD";
        wait for CLK_PERIOD;
        RW_EVEN <= '0'; -- Disable Even Register Write Control Signal
        RW_ODD  <= '0'; -- Disable Odd Register WriteControl Signal
        wait for CLK_PERIOD;
        
        wait;
    end process;
end behavioral;
		