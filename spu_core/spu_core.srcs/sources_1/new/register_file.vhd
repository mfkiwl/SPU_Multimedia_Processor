--------------------------------------------------------------------------------
-- Company: Stony Brook University
-- Engineer: Wilmer Suarez
--
-- Create Date: 03/08/2019
-- Design Name: Register File
-- Tool versions: Vivado v2018.3 (64-bit)
-- Description:
--     128 Entry by 128-bit Register File. Six 128-bit Reads are performed and 
--     latched. If any read adddress is the same as any of the two write back
--     addresses, the write data gets bypassed to the corresponding output
--     port (replacing the "old" data).
--------------------------------------------------------------------------------
-------------------- LIBRARIES --------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-------------------- ENTITY DEFINITION --------------------
entity register_file is
generic (
   ADDR_WIDTH : INTEGER := 7;  -- Bit-width of the Register Addresses 
   DATA_WIDTH : INTEGER := 128 -- Bit-width of the Register Data
);
port (
    -------------------- INPUTS --------------------
    CLK : in STD_LOGIC; -- Synchronous Clock
    RW_EVEN : in STD_LOGIC;  -- Even Register Write Control signal
    RW_ODD : in STD_LOGIC;  -- ODD Register Write Control signal
    ----- EVEN PIPE INPUT signalS -----
    RA_EVEN_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); -- Even Pipe RA Register Address
    RB_EVEN_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); -- Even Pipe RB Register Address
    RC_EVEN_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); -- Even Pipe RC Register Address
    EVEN_WB_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); -- Even Pipe Write Back Register Address
    EVEN_WB_DATA_IN : in STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0); -- Even Pipe Write Back Data
    ----- ODD PIPE INPUT signalS -----
    RA_ODD_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);  -- Odd Pipe RA Register Address
    RB_ODD_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);  -- Odd Pipe RB Register Address
    RC_ODD_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);  -- Odd Pipe RC Register Address
    ODD_WB_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);  -- Odd Pipe Write Back Register Address
    ODD_WB_DATA_IN : in STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);  -- Odd Pipe Write Back Data
    -------------------- OUTPUTS --------------------
    ----- EVEN PIPE OUTPUT signalS -----
    RA_EVEN_DATA_OUT : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0); -- Even Pipe RA READ Data
    RB_EVEN_DATA_OUT : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0); -- Even Pipe RB READ Data
    RC_EVEN_DATA_OUT : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0); -- Even Pipe RC READ Data
    ----- ODD PIPE OUTPUT signalS -----
    RA_ODD_DATA_OUT : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);  -- Odd Pipe RA READ Data
    RB_ODD_DATA_OUT : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);  -- Odd Pipe RB READ Data
    RC_ODD_DATA_OUT : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)   -- Odd Pipe RC READ Data
);
end register_file;

-------------------- ARCHITECTURE DEFINITION --------------------
architecture behavioral of register_file is
    -- Array of 128 Registers --
    type registers_file_type is ARRAY (0 to 127) of STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);
    signal registers : registers_file_type := (others => (others => '0')); -- Initially Zero out all registers
begin
    -------------------- REGISTER FILE PROCESS --------------------
    REG_FILE_PROC : process (CLK) is
    begin
        if (RISING_EDGE(CLK)) then
            ----- Read & Latch All Register Data Before Bypass -----
            RA_EVEN_DATA_OUT <= registers(to_integer(UNSIGNED(RA_EVEN_ADDR)));
            RB_EVEN_DATA_OUT <= registers(to_integer(UNSIGNED(RB_EVEN_ADDR)));
            RC_EVEN_DATA_OUT <= registers(to_integer(UNSIGNED(RC_EVEN_ADDR)));
            RA_ODD_DATA_OUT <= registers(to_integer(UNSIGNED(RA_ODD_ADDR)));
            RB_ODD_DATA_OUT <= registers(to_integer(UNSIGNED(RB_ODD_ADDR)));
            RC_ODD_DATA_OUT <= registers(to_integer(UNSIGNED(RC_ODD_ADDR)));
            
            if (RW_EVEN = '1') then
                ----- Write to Selected Write Back Register - EVEN -----
                registers(to_integer(UNSIGNED(EVEN_WB_ADDR))) <= EVEN_WB_DATA_IN;
                
                ----- Forward Data Coming In - EVEN WB DATA -----
                if (EVEN_WB_ADDR = RA_EVEN_ADDR) then    -- Forward EVEN WB Data to EVEN RA_OUT 
                    RA_EVEN_DATA_OUT <= EVEN_WB_DATA_IN;
                end if;
                if (EVEN_WB_ADDR = RB_EVEN_ADDR) then    -- Forward EVEN WB Data to EVEN RB_OUT 
                    RB_EVEN_DATA_OUT <= EVEN_WB_DATA_IN;
                end if;
                if (EVEN_WB_ADDR = RC_EVEN_ADDR) then    -- Forward EVEN WB Data to EVEN RC_OUT 
                    RC_EVEN_DATA_OUT <= EVEN_WB_DATA_IN;
                end if;
                if (EVEN_WB_ADDR = RA_ODD_ADDR) then  -- Forward EVEN WB Data to ODD RA_OUT 
                    RA_ODD_DATA_OUT <= EVEN_WB_DATA_IN;
                end if;
                if (EVEN_WB_ADDR = RB_ODD_ADDR) then  -- Forward EVEN WB Data to ODD RB_OUT 
                    RB_ODD_DATA_OUT <= EVEN_WB_DATA_IN;
                end if;
                if (EVEN_WB_ADDR = RC_ODD_ADDR) then  -- Forward EVEN WB Data to ODD RC_OUT 
                    RC_ODD_DATA_OUT <= EVEN_WB_DATA_IN;
                end if;
            end if;
            
            IF (RW_ODD = '1') then
                ----- Write to Selected Write Back Register - ODD -----
                registers(to_integer(UNSIGNED(ODD_WB_ADDR))) <= ODD_WB_DATA_IN;                
            
                ----- Forward Data Coming In - ODD WB DATA -----
                if (ODD_WB_ADDR = RA_EVEN_ADDR) then    -- Forward ODD WB Data to EVEN RA_OUT 
                    RA_EVEN_DATA_OUT <= ODD_WB_DATA_IN;
                end if;
                if (ODD_WB_ADDR = RB_EVEN_ADDR) then -- Forward ODD WB Data to EVEN RB_OUT 
                    RB_EVEN_DATA_OUT <= ODD_WB_DATA_IN;
                end if;
                if (ODD_WB_ADDR = RC_EVEN_ADDR) then -- Forward ODD WB Data to EVEN RC_OUT 
                    RC_EVEN_DATA_OUT <= ODD_WB_DATA_IN;
                end if;
                if (ODD_WB_ADDR = RA_ODD_ADDR) then  -- Forward ODD WB Data to ODD RA_OUT 
                    RA_ODD_DATA_OUT <= ODD_WB_DATA_IN;
                end if;
                if (ODD_WB_ADDR = RB_ODD_ADDR) then  -- Forward ODD WB Data to ODD RB_OUT 
                    RB_ODD_DATA_OUT <= ODD_WB_DATA_IN;
                end if;
                if (ODD_WB_ADDR = RC_ODD_ADDR) then  -- Forward ODD WB Data to ODD RC_OUT 
                    RC_ODD_DATA_OUT <= ODD_WB_DATA_IN;
                end if;
            end if;
        end if;
    end process REG_FILE_PROC;
end behavioral;
		