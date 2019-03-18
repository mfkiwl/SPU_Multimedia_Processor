--------------------------------------------------------------------------------
-- Company: Stony Brook University
-- Engineer: Wilmer Suarez
--
-- Create Date: 03/10/2019
-- Design Name: Local Store
-- Tool versions: Vivado v2018.3 (64-bit)
-- Description:
--     Local storage memory used to hold the code and data.
--     It is a 32 kB - Byte Addressable Single port SRAM. 
--     16B of data can be Stored or Read at a time using Load/Store Instructions.
--     When the Instruction Line buffer is empty a 128-Byte block is read and sent
--     directly to the buffer. 
--     The first half of the Local Store stores the code (starting at address 0)
--     The second half stores the data (starting at address 2048)
--------------------------------------------------------------------------------
-------------------- LIBRARIES --------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-------------------- ENTITY DEFINITION --------------------
entity local_store is
generic (
    STORAGE_SIZE : INTEGER := 2048;  -- Block number
    ADDR_WIDTH : INTEGER := 15;      -- Bit-width of the SRAM Addresses 
    DATA_WIDTH : INTEGER := 128;     -- Bit-width of the Data
    INSTR_WIDTH : INTEGER := 1024    -- Bit-width of Instruction Block
);
port (
    -------------------- INPUTS --------------------
    WE : in STD_LOGIC;  -- Write Enable Control Signal
    RIB : in STD_LOGIC; -- Read Instruction Block Control Signal
    ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);    -- LS read/write Address
    DATA_IN : in STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0); -- Data to write into LS
    -------------------- OUTPUTS --------------------
    DATA_OUT : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);        -- 16-Byte Data Read 
    INSTR_BLOCK_OUT : out STD_LOGIC_VECTOR((INSTR_WIDTH-1) downto 0) -- 128-Byte Data Read (32 Instructions)
);
end local_store;

-------------------- ARCHITECTURE DEFINITION --------------------
architecture behavioral of local_store is
-- 2kB x 16-byte block Storage --
-- Local Store Data Section Start Address: 0x400 -- 
-- Local Store Data Section Final Address: 0x780 --
type sram_type is array (0 to (STORAGE_SIZE - 1)) of std_logic_vector ((DATA_WIDTH-1) downto 0);
signal SRAM : sram_type := (others => (others => '0'));
-- Current Instruction Block Address --
signal INSTRUCTION_BLOCK_ADDR : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0');
begin
    -------------------- OUTPUT DATA -------------------- 
    DATA_OUT <= SRAM(to_integer(unsigned(ADDR)));
     
    -------------------- LOCAL STORE PROCESS --------------------
    LOCAL_STORE_PROC : process(RIB, ADDR, DATA_IN) is
    begin
        -- Output 128-Byte Block --
        if (RIB = '1') then
            INSTR_BLOCK_OUT <= SRAM(to_integer(unsigned(INSTRUCTION_BLOCK_ADDR)))   & -- 4 Instruction
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
        
        -- Write Data -- 
        if (WE = '1') then
            SRAM(to_integer(unsigned(ADDR))) <= DATA_IN;
        end if;
    end process LOCAL_STORE_PROC;
end behavioral;
		