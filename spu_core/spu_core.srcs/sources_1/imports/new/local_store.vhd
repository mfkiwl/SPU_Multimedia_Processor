--------------------------------------------------------------------------------
-- Company: Stony Brook University
-- Engineer: Wilmer Suarez
--
-- Create Date: 03/10/2019
-- Design Name: Local Store
-- Tool versions: Vivado v2018.3 (64-bit)
-- Description:
--     Local storage memory used to hold the code and data.
--     It is a 32 kB, 16-Byte Addressable Single port SRAM.
--     16B of data can be Stored or Read at a time using Load/Store Instructions.
--     
--     When the Instruction Line buffer is empty a 128-Byte block is read and sent
--     to the buffer. 
--     The first half of the Local Store stores the code (starting at address 0)
--     The second half stores the data (starting at address 2048)
--------------------------------------------------------------------------------
-------------------- LIBRARIES --------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.NUMERIC_STD_UNSIGNED.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.COMPONENTS_PACKAGE.ALL; -- SPU Core Components
use work.CONSTANTS_PACKAGE.ALL;

-------------------- ENTITY DEFINITION --------------------
entity LOCAL_STORE is
    port (
        -------------------- INPUTS --------------------
        WE_LS      : in STD_LOGIC; -- Write Enable Control Signal
        RIB_LS     : in STD_LOGIC; -- Read Instruction Block Signal
        FILL       : in STD_LOGIC; -- Fill LS with Instructions Flag
        ADDR_LS    : in STD_LOGIC_VECTOR((ADDR_WIDTH_LS-1) downto 0); -- LS read/write Address
        DATA_IN_LS : in STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0); -- Data to write into LS
        SRAM_INSTR : in SRAM_TYPE; -- SRAM Instruction Data
        PC_LS      : in STD_LOGIC_VECTOR((LS_INSTR_SECTION_SIZE - 1) downto 0); -- Current PC value to be used when RIB
        -------------------- OUTPUTS --------------------
        DATA_OUT_LS        : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)  := (others => '0');   -- 16-Byte Data Read 
        INSTR_BLOCK_OUT_LS : out STD_LOGIC_VECTOR((INSTR_WIDTH_LS-1) downto 0) := (others => '0') -- 128-Byte Data Read (32 Instructions)
    );
end LOCAL_STORE;

-------------------- ARCHITECTURE DEFINITION --------------------
architecture behavioral of LOCAL_STORE is
signal SRAM : sram_type := (others => (others => '0'));
begin
    ------------------ OUTPUT DATA -------------------- 
    DATA_OUT_LS <= SRAM(to_integer(unsigned(ADDR_LS)+3)) &
                   SRAM(to_integer(unsigned(ADDR_LS)+2)) &
                   SRAM(to_integer(unsigned(ADDR_LS)+1)) &
                   SRAM(to_integer(unsigned(ADDR_LS)));
     
    ------------------ LOCAL STORE PROCESS --------------------
    LOCAL_STORE_PROC : process(RIB_LS, WE_LS, ADDR_LS, DATA_IN_LS, FILL)
    variable INDEX     : NATURAL := 0; 
    variable INSTR_i1  : NATURAL;
    variable INSTR_i2  : NATURAL;
    constant INSTR_MAX : NATURAL := 32;
    begin
        ----- Output 128-Byte Block -----
        if (RIB_LS = '1') then
            INDEX := to_integer(PC_LS); -- SRAM entry
            INSTR_i1 := 31;
            INSTR_i2 := 0;
            
            ----- Concatenate 32 Instructions (128-Bytes) -----
            for i in 0 to (INSTR_MAX-1) loop
                INSTR_BLOCK_OUT_LS(INSTR_i1 downto INSTR_i2) <= SRAM(INDEX + i);
                INSTR_i1 := INSTR_i1 + 32;
                INSTR_i2 := INSTR_i2 + 32;
            end loop;
        end if;
                
        ----- Fill Instruction Data -----
        if (FILL = '1') then
            SRAM <= SRAM_INSTR;
        end if;
                
        ----- Write Data -----
        if (WE_LS = '1') then
            SRAM(to_integer(unsigned(ADDR_LS)))   <= DATA_IN_LS((INSTR_SIZE-1) downto 0);  
            SRAM(to_integer(unsigned(ADDR_LS)+1)) <= DATA_IN_LS(63 downto 32);
            SRAM(to_integer(unsigned(ADDR_LS)+2)) <= DATA_IN_LS(95 downto 64);
            SRAM(to_integer(unsigned(ADDR_LS)+3)) <= DATA_IN_LS((DATA_WIDTH-1) downto 96);
        end if;
    end process LOCAL_STORE_PROC;
end behavioral;
		