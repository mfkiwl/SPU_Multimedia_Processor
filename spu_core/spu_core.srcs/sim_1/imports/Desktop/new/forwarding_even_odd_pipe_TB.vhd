----------------------------------------------------------------------------------
---- Company: Stony Brook University
---- Engineer: Wilmer Suarez
----
---- Create Date: 03/22/2019
---- Design Name: SPU Core Testbench
---- Tool versions: Vivado v2018.3 (64-bit)
---- Description:
----     Test All Instructions 
----------------------------------------------------------------------------------
-------------------- LIBRARIES --------------------
--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;
--use work.COMPONENTS_PACKAGE.ALL; -- SPU Core Components

---------------------- ENTITY DEFINITION --------------------
--entity forwarding_even_odd_pipe_TB is
--generic (
--    OPCODE_WIDTH  : NATURAL := 11;   -- Maximum bit-width of Even and Odd Opcodes
--    INSTR_WIDTH   : NATURAL := 1024; -- Bit-width of Instruction Block
--    DATA_WIDTH    : NATURAL := 128;  -- Bit-width of the Register Data
--    ADDR_WIDTH    : NATURAL := 7;    -- Bit-width of the Register Addresses 
--    LS_ADDR_WIDTH : NATURAL := 15;   -- Bit-width of the Local Store Addresses
--    RI7_WIDTH     : NATURAL := 7;    -- Immediate 7-bit format
--    RI10_WIDTH    : NATURAL := 10;   -- Immediate 10-bit format
--    RI16_WIDTH    : NATURAL := 16;   -- Immediate 16-bit format
--    RI18_WIDTH    : NATURAL := 18    -- Immediate 18-bit format
--);
--end forwarding_even_odd_pipe_TB;

---------------------- ARCHITECTURE DEFINITION --------------------
--architecture behavioral of forwarding_even_odd_pipe_TB is

---------------------- CLOCK --------------------
--constant CLK_PERIOD : TIME := 10ns;
--begin    
--    -------------------- INSTANTIATE UNIT UNDER TEST --------------------
--    UUT : forwarding_macro_circuits port map (
  
--    );
    
--    -------------------- INSTANTIATE UNIT UNDER TEST --------------------
--    UUT : even_odd_pipes port map (
  
--    );
    
--    -------------------- CLK GENERATION PROCESS --------------------
--    CLK <= not CLK after CLK_PERIOD/2;

--    -------------------- SPU CORE PROCESS --------------------
--    SIMULUS_PROC : process
--    begin
        
--        wait;
--    end process;
--end behavioral;
