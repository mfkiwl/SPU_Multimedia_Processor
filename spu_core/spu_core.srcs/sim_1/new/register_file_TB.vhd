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

-------------------- ENTITY DEFINITION --------------------
entity register_file_TB is
generic (
   ADDR_WIDTH : INTEGER := 7;  -- Bit-width of the Register Addresses 
   DATA_WIDTH : INTEGER := 128 -- Bit-width of the Register Data
);
end register_file_TB;

-------------------- ARCHITECTURE DEFINITION --------------------
architecture behavioral of register_file_TB is
----- COMPONENT DECLERATION OF UUT -----
component register_file 
    port (
        CLK : in STD_LOGIC;
        RW_EVEN : in STD_LOGIC;
        RW_ODD : in STD_LOGIC;
        RA_EVEN_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);
        RB_EVEN_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);
        RC_EVEN_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);
        EVEN_WB_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);
        EVEN_WB_DATA_IN : in STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);
        RA_ODD_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); 
        RB_ODD_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);
        RC_ODD_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);
        ODD_WB_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);
        ODD_WB_DATA_IN : in STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);
        RA_EVEN_DATA_OUT : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0); 
        RB_EVEN_DATA_OUT : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);
        RC_EVEN_DATA_OUT : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);
        RA_ODD_DATA_OUT : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);  
        RB_ODD_DATA_OUT : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0); 
        RC_ODD_DATA_OUT : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)  
    );
end component;

----- INPUTS -----
signal CLK : STD_LOGIC := '1';
signal RW_EVEN : STD_LOGIC := '0';
signal RW_ODD : STD_LOGIC := '0';
signal RA_EVEN_ADDR : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0');
signal RB_EVEN_ADDR : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0');
signal RC_EVEN_ADDR : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0');
signal EVEN_WB_ADDR : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0');
signal EVEN_WB_DATA_IN : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others => '0');
signal RA_ODD_ADDR : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0'); 
signal RB_ODD_ADDR : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0');
signal RC_ODD_ADDR : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0');
signal ODD_WB_ADDR : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0');
signal ODD_WB_DATA_IN : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others => '0');
----- OUTPUTS -----
signal RA_EVEN_DATA_OUT : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0); 
signal RB_EVEN_DATA_OUT : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);
signal RC_EVEN_DATA_OUT : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);
signal RA_ODD_DATA_OUT : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);  
signal RB_ODD_DATA_OUT : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0); 
signal RC_ODD_DATA_OUT : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);  
----- CLOCK PERIOD -----
constant CLK_PERIOD : TIME := 10ns;
begin
    -------------------- INSTANTIATE UNIT UNDER TEST --------------------
    UUT : register_file port map (
        CLK => CLK,
        RW_EVEN => RW_EVEN,
        RW_ODD => RW_ODD,
        RA_EVEN_ADDR => RA_EVEN_ADDR,
        RB_EVEN_ADDR => RB_EVEN_ADDR,
        RC_EVEN_ADDR => RC_EVEN_ADDR,
        EVEN_WB_ADDR => EVEN_WB_ADDR,
        EVEN_WB_DATA_IN => EVEN_WB_DATA_IN,
        RA_ODD_ADDR => RA_ODD_ADDR,
        RB_ODD_ADDR => RB_ODD_ADDR,
        RC_ODD_ADDR => RC_ODD_ADDR,
        ODD_WB_ADDR => ODD_WB_ADDR,
        ODD_WB_DATA_IN => ODD_WB_DATA_IN,
        RA_EVEN_DATA_OUT => RA_EVEN_DATA_OUT,
        RB_EVEN_DATA_OUT => RB_EVEN_DATA_OUT,
        RC_EVEN_DATA_OUT => RC_EVEN_DATA_OUT,
        RA_ODD_DATA_OUT => RA_ODD_DATA_OUT,
        RB_ODD_DATA_OUT => RB_ODD_DATA_OUT,
        RC_ODD_DATA_OUT => RC_ODD_DATA_OUT
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
        RW_ODD <= '1'; -- Enable Odd Register WriteControl Signal
        while (ri < (DATA_WIDTH-1)) loop
            EVEN_WB_ADDR <= STD_LOGIC_VECTOR(to_unsigned(ri, EVEN_WB_ADDR'length));
            EVEN_WB_DATA_IN <= STD_LOGIC_VECTOR(to_unsigned(ri, EVEN_WB_DATA_IN'length));
            ri := ri + 1;
            wait for CLK_PERIOD;
            ODD_WB_ADDR <= STD_LOGIC_VECTOR(to_unsigned(ri, ODD_WB_ADDR'length));
            ODD_WB_DATA_IN <= STD_LOGIC_VECTOR(to_unsigned(ri, ODD_WB_DATA_IN'length));
            ri := ri + 1;
            wait for CLK_PERIOD;
        end loop;
        wait for CLK_PERIOD;
        
        ----- Read Test -----
        RW_EVEN <= '0'; -- Disable Even Register Write Control Signal
        RW_ODD <= '0'; -- Disable Odd Register WriteControl Signal
        wait for CLK_PERIOD;
        -- Read Initial Values --
        RA_EVEN_ADDR <= STD_LOGIC_VECTOR(to_unsigned(0, RA_EVEN_ADDR'length));
        RB_EVEN_ADDR <= STD_LOGIC_VECTOR(to_unsigned(1, RB_EVEN_ADDR'length));
        RC_EVEN_ADDR <= STD_LOGIC_VECTOR(to_unsigned(2, RC_EVEN_ADDR'length));
        RA_ODD_ADDR <= STD_LOGIC_VECTOR(to_unsigned(3, RA_ODD_ADDR'length));
        RB_ODD_ADDR <= STD_LOGIC_VECTOR(to_unsigned(4, RB_ODD_ADDR'length));
        RC_ODD_ADDR <= STD_LOGIC_VECTOR(to_unsigned(5, RC_ODD_ADDR'length));
        wait for CLK_PERIOD;
        
        ----- Write Random Data to Arbitrary Register -----
        RW_EVEN <= '1'; -- Enable Even Register Write Control Signal
        RW_ODD <= '0'; -- Disable Odd Register WriteControl Signal
        EVEN_WB_ADDR <= STD_LOGIC_VECTOR(to_unsigned(78, EVEN_WB_ADDR'length));
        EVEN_WB_DATA_IN <= x"DEAD_BEEF_DEAF_DEED_FACE_CAFE_DEED_C0DE";
        wait for CLK_PERIOD;
        
        ----- Read the Arbitrary Register -----
        RW_EVEN <= '0'; -- Disable Even Register Write Control Signal
        RW_ODD <= '0'; -- Disable Odd Register WriteControl Signal
        EVEN_WB_ADDR <= STD_LOGIC_VECTOR(to_unsigned(0, EVEN_WB_ADDR'length));
        wait for CLK_PERIOD;
        RA_EVEN_ADDR <= STD_LOGIC_VECTOR(to_unsigned(78, RA_EVEN_ADDR'length));
        wait for CLK_PERIOD;
        
        ----- Test Data Forwarding -----
        RW_EVEN <= '0'; -- Disable Even Register Write Control Signal
        RW_ODD <= '1'; -- Enable Odd Register WriteControl Signal
        RC_ODD_ADDR <= STD_LOGIC_VECTOR(to_unsigned(77, RC_ODD_ADDR'length));  -- Reading Register 77
        ODD_WB_ADDR <= STD_LOGIC_VECTOR(to_unsigned(77, EVEN_WB_ADDR'length)); -- Writing Register 77
        ODD_WB_DATA_IN <= x"F00D_C0FFEE_DAD_A_FADE_FEED_BABE_ABED_AD";
        wait for CLK_PERIOD;
        RW_EVEN <= '0'; -- Disable Even Register Write Control Signal
        RW_ODD <= '0'; -- Disable Odd Register WriteControl Signal
        wait for CLK_PERIOD;
        
        wait;
    end process;
end behavioral;
		