--------------------------------------------------------------------------------
-- Company: Stony Brook University
-- Engineer: Wilmer Suarez
--
-- Create Date: 03/16/2019
-- Design Name: Local Store Testbench
-- Tool versions: Vivado v2018.3 (64-bit)
-- Description:
--     - Testing 16-Byte loads and Stores to Local Store.
--     - Testing 128-Byte block reads used by the Instruction Cache.
--------------------------------------------------------------------------------
-------------------- LIBRARIES --------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.COMPONENTS_PACKAGE.ALL; -- SPU Core Components

-------------------- ENTITY DEFINITION --------------------
entity local_store_TB is
generic (
    STORAGE_SIZE : NATURAL := 2048;  -- Block number
    ADDR_WIDTH : NATURAL := 15;      -- Bit-width of the SRAM Addresses 
    DATA_WIDTH : NATURAL := 128;     -- Bit-width of the Data
    INSTR_WIDTH : NATURAL := 1024    -- Bit-width of Instruction Block
);
end local_store_TB;

-------------------- ARCHITECTURE DEFINITION --------------------
architecture behavioral of local_store_TB is
----- INPUTS -----
signal WE : STD_LOGIC := '0'; 
signal RIB : STD_LOGIC := '0'; 
signal ADDR : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0');   
signal DATA_IN : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others => '0');
----- OUTPUTS -----
signal DATA_OUT : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others => '0');     
signal INSTR_BLOCK_OUT : STD_LOGIC_VECTOR((INSTR_WIDTH-1) downto 0) := (others => '0');
-------------------- DELAY --------------------
constant DELAY : TIME := 10ns;
begin
    -------------------- INSTANTIATE UNIT UNDER TEST --------------------
    UUT : local_store port map (
        WE => WE,
        RIB => RIB,
        ADDR => ADDR,
        DATA_IN => DATA_IN,
        DATA_OUT => DATA_OUT,
        INSTR_BLOCK_OUT => INSTR_BLOCK_OUT
    );

    -------------------- LOCAL STORE STIMULUS PROCESS --------------------
    SIMULUS_PROC : process
    begin 
        ----- Hold Reset for 50ns -----
        wait for DELAY*5;
        
        ----- Write to Data Section & Read -----
        WE <= '1'; -- Enable Write Enable Control Signal
        ADDR <= STD_LOGIC_VECTOR(to_unsigned(1024, ADDR'length));
        DATA_IN <= x"DEAD_BEEF_DEAF_DEED_FACE_CAFE_DEED_C0DE";
        wait for DELAY;
        
        ----- Read Test -----
        WE <= '0'; -- Disable Write Enable Control Signal
        wait for DELAY;
        
        ----- Write to Instruction Section & Read Instructin Block -----
        WE <= '1'; -- Enable Write Enable Control Signal
        ADDR <= STD_LOGIC_VECTOR(to_unsigned(0, ADDR'length));
        DATA_IN <= x"DEAD_BEEF_DEAF_DEED_FACE_CAFE_DEED_C0DE";  -- 1st Block: First 16 "Instructions"
        wait for DELAY;
        ADDR <= STD_LOGIC_VECTOR(to_unsigned(8, ADDR'length));
        DATA_IN <= x"F00D_C0FFEE_DAD_A_FADE_FEED_BABE_ABED_AD"; -- 2nd Block: Next 16 "Instructions"
        wait for DELAY;
        ADDR <= STD_LOGIC_VECTOR(to_unsigned(9, ADDR'length));
        DATA_IN <= x"DEAD_BEEF_DEAF_DEED_FACE_CAFE_DEED_C0DE";  -- 2nd Block: Next 16 "Instructions"
        wait for DELAY;
        WE <= '0'; -- Disable Write Enable Control Signal
        RIB <= '1'; -- Read the first 128-Byte 
        wait for DELAY;
        RIB <= '0';
        wait for DELAY;
        RIB <= '1'; -- Read the first 128-Byte 
        wait for DELAY;
        RIB <= '0';
        wait for DELAY;
        
        wait;
    end process;
end behavioral;
		