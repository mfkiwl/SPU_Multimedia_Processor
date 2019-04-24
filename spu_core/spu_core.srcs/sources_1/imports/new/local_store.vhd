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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.COMPONENTS_PACKAGE.ALL; -- SPU Core Components

-------------------- ENTITY DEFINITION --------------------
entity local_store is
    port (
        -------------------- INPUTS --------------------
        WE_LS      : in STD_LOGIC; -- Write Enable Control Signal
        RIB_LS     : in STD_LOGIC; -- Read Instruction Block Signal
        FILL       : in STD_LOGIC; -- Fill LS with Instructions Flag
        ADDR_LS    : in STD_LOGIC_VECTOR((ADDR_WIDTH_LS-1) downto 0); -- LS read/write Address
        DATA_IN_LS : in STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);    -- Data to write into LS
        SRAM_INSTR : in SRAM_TYPE; -- SRAM Instruction Data
        -------------------- OUTPUTS --------------------
        DATA_OUT_LS        : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)  := (others => '0');   -- 16-Byte Data Read 
        INSTR_BLOCK_OUT_LS : out STD_LOGIC_VECTOR((INSTR_WIDTH_LS-1) downto 0) := (others => '0') -- 128-Byte Data Read (32 Instructions)
    );
end local_store;

-------------------- ARCHITECTURE DEFINITION --------------------
architecture behavioral of local_store is
signal SRAM : sram_type := (others => (others => '0'));
-- Current Instruction Block Address --
signal INSTRUCTION_BLOCK_ADDR : STD_LOGIC_VECTOR((ADDR_WIDTH_LS-1) downto 0) := (others => '0');
begin
    ------------------ OUTPUT DATA -------------------- 
    DATA_OUT_LS <= SRAM(to_integer(unsigned(ADDR_LS)));
     
    ------------------ LOCAL STORE PROCESS --------------------
    LOCAL_STORE_PROC : process(RIB_LS, WE_LS, ADDR_LS, DATA_IN_LS, FILL) 
    begin
        -- Output 128-Byte Block --
        if (RIB_LS = '1') then
            INSTR_BLOCK_OUT_LS <= SRAM(to_integer(unsigned(INSTRUCTION_BLOCK_ADDR)))   & -- 4 Instruction
                                  SRAM(to_integer(unsigned(INSTRUCTION_BLOCK_ADDR+1))) & -- 8 Instruction
                                  SRAM(to_integer(unsigned(INSTRUCTION_BLOCK_ADDR+2))) & -- 12 Instruction
                                  SRAM(to_integer(unsigned(INSTRUCTION_BLOCK_ADDR+3))) & -- 16 Instruction
                                  SRAM(to_integer(unsigned(INSTRUCTION_BLOCK_ADDR+4))) & -- 20 Instruction
                                  SRAM(to_integer(unsigned(INSTRUCTION_BLOCK_ADDR+5))) & -- 24 Instruction
                                  SRAM(to_integer(unsigned(INSTRUCTION_BLOCK_ADDR+6))) & -- 28 Instruction
                                  SRAM(to_integer(unsigned(INSTRUCTION_BLOCK_ADDR+7)));  -- 32 Instruction
        
            -- Update Instruction Block Start Address to Start of Next 128-Byte Block --
            INSTRUCTION_BLOCK_ADDR <= INSTRUCTION_BLOCK_ADDR + 8;
        end if;
        
        -- Fill Instruction Data --
        if (FILL = '1') then
            SRAM <= SRAM_INSTR;
        end if;
                
        -- Write Data -- 
        if (WE_LS = '1') then
            SRAM(to_integer(unsigned(ADDR_LS))) <= DATA_IN_LS;
        end if;
    end process LOCAL_STORE_PROC;
end behavioral;
		