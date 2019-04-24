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
use work.COMPONENTS_PACKAGE.ALL;   -- Contains result_packet Record

-------------------- ENTITY DEFINITION --------------------
entity register_file is
port (
    -------------------- INPUTS --------------------
    ----- CONTROL SIGNALS -----
    CLK              : in STD_LOGIC; -- System Wide Synchronous Clock
    RW_EVEN_RF       : in STD_LOGIC; -- Even Register Write Control signal
    RW_ODD_RF        : in STD_LOGIC; -- ODD Register Write Control signal
    EVEN_OPCODE_RF   : in STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0); -- Even Pipe Opcode
    ODD_OPCODE_RF    : in STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0); -- Odd Pipe Opcode
    RA_EVEN_ADDR_RF  : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); -- Even Pipe RA Register Address
    RB_EVEN_ADDR_RF  : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); -- Even Pipe RB Register Address
    RC_EVEN_ADDR_RF  : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); -- Even Pipe RC Register Address
    EVEN_WB_ADDR_RF  : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); -- Even Pipe Write Back Register Address
    EVEN_WB_DATA_RF  : in STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0); -- Even Pipe Write Back Data
    RA_ODD_ADDR_RF   : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); -- Odd Pipe RA Register Address
    RB_ODD_ADDR_RF   : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); -- Odd Pipe RB Register Address
    RC_ODD_ADDR_RF   : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); -- Odd Pipe RC Register Address
    ODD_WB_ADDR_RF   : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); -- Odd Pipe Write Back Register Address
    ODD_WB_DATA_RF   : in STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0); -- Odd Pipe Write Back Data
    EVEN_RI7_RF      : in STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0);  -- Even Immediate RI7
    EVEN_RI10_RF     : in STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0); -- Even Immediate RI10
    EVEN_RI16_RF     : in STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0); -- Even Immediate RI16
    ODD_RI7_RF       : in STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0);  -- Odd Immediate RI7
    ODD_RI10_RF      : in STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0); -- Odd Immediate RI10
    ODD_RI16_RF      : in STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0); -- Odd Immediate RI16
    ODD_RI18_RF      : in STD_LOGIC_VECTOR((RI18_WIDTH-1) downto 0); -- Odd Immediate RI18
    EVEN_REG_DEST_RF : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); -- Even Write back Address (RT)
    ODD_REG_DEST_RF  : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); -- Odd Write back Address (RT)
    -------------------- OUTPUTS --------------------
    EVEN_OPCODE_OUT_RF   : out STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0) := (others => '0'); -- Even Pipe Opcode
    ODD_OPCODE_OUT_RF    : out STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0) := (others => '0'); -- Odd Pipe Opcode
    RA_EVEN_DATA_OUT_RF  : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)   := (others => '0'); -- Even Pipe RA READ Data
    RB_EVEN_DATA_OUT_RF  : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)   := (others => '0'); -- Even Pipe RB READ Data
    RC_EVEN_DATA_OUT_RF  : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)   := (others => '0'); -- Even Pipe RC READ Data
    RA_ODD_DATA_OUT_RF   : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)   := (others => '0'); -- Odd Pipe RA READ Data
    RB_ODD_DATA_OUT_RF   : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)   := (others => '0'); -- Odd Pipe RB READ Data
    RC_ODD_DATA_OUT_RF   : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)   := (others => '0'); -- Odd Pipe RC READ Data
    RA_EVEN_ADDR_OUT_RF  : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0'); -- Even Pipe RA Register Address
    RB_EVEN_ADDR_OUT_RF  : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0'); -- Even Pipe RB Register Address
    RC_EVEN_ADDR_OUT_RF  : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0'); -- Even Pipe RC Register Address
    RA_ODD_ADDR_OUT_RF   : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0'); -- Odd Pipe RA Register Address
    RB_ODD_ADDR_OUT_RF   : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0'); -- Odd Pipe RB Register Address
    RC_ODD_ADDR_OUT_RF   : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0'); -- Odd Pipe RC Register Address
    EVEN_RI7_OUT_RF      : out STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0)    := (others => '0'); -- Even Immediate RI7
    EVEN_RI10_OUT_RF     : out STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0)   := (others => '0'); -- Even Immediate RI10
    EVEN_RI16_OUT_RF     : out STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0)   := (others => '0'); -- Even Immediate RI16
    ODD_RI7_OUT_RF       : out STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0)    := (others => '0'); -- Odd Immediate RI7
    ODD_RI10_OUT_RF      : out STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0)   := (others => '0'); -- Odd Immediate RI10
    ODD_RI16_OUT_RF      : out STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0)   := (others => '0'); -- Odd Immediate RI16
    ODD_RI18_OUT_RF      : out STD_LOGIC_VECTOR((RI18_WIDTH-1) downto 0)   := (others => '0'); -- Odd Immediate RI18
    EVEN_REG_DEST_OUT_RF : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0'); -- Even Write back Address (RT)
    ODD_REG_DEST_OUT_RF  : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0')  -- Odd Write back Address (RT)
);
end register_file;

-------------------- ARCHITECTURE DEFINITION --------------------
architecture behavioral of register_file is
    -- Array of 128 Registers --
    type registers_file_type is ARRAY (0 to 127) of STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);
    --signal registers : registers_file_type := (others => (others => '0')); -- Initially Zero out all registers
    -- For Testbench --
    signal registers : registers_file_type := (
        (others => '0'),
        (x"0000_0001_0000_0001_0000_0001_0000_0001"),
        others=>(others => '0')
    );
begin
    
    -------------------- REGISTER FILE PROCESS --------------------
    REG_FILE_PROC : process (CLK) is
    begin
        if (RISING_EDGE(CLK)) then
            -------------------- OUTPUT OPCODE --------------------
            EVEN_OPCODE_OUT_RF <= EVEN_OPCODE_RF;
            ODD_OPCODE_OUT_RF  <= ODD_OPCODE_RF;
            
            -------------------- OUTPUT RT REGISTERS --------------------
            EVEN_REG_DEST_OUT_RF <= EVEN_REG_DEST_RF;
            ODD_REG_DEST_OUT_RF  <= ODD_REG_DEST_RF;
            
            -------------------- OUTPUT IMMEDIATES --------------------     
            EVEN_RI7_OUT_RF  <= EVEN_RI7_RF;     
            EVEN_RI10_OUT_RF <= EVEN_RI10_RF;
            EVEN_RI16_OUT_RF <= EVEN_RI16_RF;
            ODD_RI7_OUT_RF   <= ODD_RI7_RF;
            ODD_RI10_OUT_RF  <= ODD_RI10_RF;
            ODD_RI16_OUT_RF  <= ODD_RI16_RF;
            ODD_RI18_OUT_RF  <= ODD_RI18_RF;
            
            -------------------- OUTPUT ADDRESSES --------------------
            RA_EVEN_ADDR_OUT_RF <= RA_EVEN_ADDR_RF;
            RB_EVEN_ADDR_OUT_RF <= RB_EVEN_ADDR_RF;
            RC_EVEN_ADDR_OUT_RF <= RC_EVEN_ADDR_RF;
            RA_ODD_ADDR_OUT_RF  <= RA_ODD_ADDR_RF;
            RB_ODD_ADDR_OUT_RF  <= RB_ODD_ADDR_RF;
            RC_ODD_ADDR_OUT_RF  <= RC_ODD_ADDR_RF;
    
            ----- Read & Latch All Register Data Before Bypass -----
            RA_EVEN_DATA_OUT_RF <= registers(to_integer(UNSIGNED(RA_EVEN_ADDR_RF)));
            RB_EVEN_DATA_OUT_RF <= registers(to_integer(UNSIGNED(RB_EVEN_ADDR_RF)));
            RC_EVEN_DATA_OUT_RF <= registers(to_integer(UNSIGNED(RC_EVEN_ADDR_RF)));
            RA_ODD_DATA_OUT_RF  <= registers(to_integer(UNSIGNED(RA_ODD_ADDR_RF)));
            RB_ODD_DATA_OUT_RF  <= registers(to_integer(UNSIGNED(RB_ODD_ADDR_RF)));
            RC_ODD_DATA_OUT_RF  <= registers(to_integer(UNSIGNED(RC_ODD_ADDR_RF)));
            
            if (RW_EVEN_RF = '1') then
                ----- Write to Selected Write Back Register - EVEN -----
                registers(to_integer(UNSIGNED(EVEN_WB_ADDR_RF))) <= EVEN_WB_DATA_RF;
                
                ----- Forward Data Coming In - EVEN WB DATA -----
                if (EVEN_WB_ADDR_RF = RA_EVEN_ADDR_RF) then -- Forward EVEN WB Data to EVEN RA OUT 
                    RA_EVEN_DATA_OUT_RF <= EVEN_WB_DATA_RF;
                end if;
                if (EVEN_WB_ADDR_RF = RB_EVEN_ADDR_RF) then -- Forward EVEN WB Data to EVEN RB OUT 
                    RB_EVEN_DATA_OUT_RF <= EVEN_WB_DATA_RF;
                end if;
                if (EVEN_WB_ADDR_RF = RC_EVEN_ADDR_RF) then -- Forward EVEN WB Data to EVEN RC OUT 
                    RC_EVEN_DATA_OUT_RF <= EVEN_WB_DATA_RF;
                end if;
                if (EVEN_WB_ADDR_RF = RA_ODD_ADDR_RF) then  -- Forward EVEN WB Data to ODD RA OUT 
                    RA_ODD_DATA_OUT_RF <= EVEN_WB_DATA_RF;
                end if;
                if (EVEN_WB_ADDR_RF = RB_ODD_ADDR_RF) then  -- Forward EVEN WB Data to ODD RB OUT 
                    RB_ODD_DATA_OUT_RF <= EVEN_WB_DATA_RF;
                end if;
                if (EVEN_WB_ADDR_RF = RC_ODD_ADDR_RF) then  -- Forward EVEN WB Data to ODD RC OUT 
                    RC_ODD_DATA_OUT_RF <= EVEN_WB_DATA_RF;
                end if;
            end if;
            
            if (RW_ODD_RF = '1') then
                ----- Write to Selected Write Back Register - ODD -----
                registers(to_integer(UNSIGNED(ODD_WB_ADDR_RF))) <= ODD_WB_DATA_RF;                
            
                ----- Forward Data Coming In - ODD WB DATA -----
                if (ODD_WB_ADDR_RF = RA_EVEN_ADDR_RF) then -- Forward ODD WB Data to EVEN RA OUT 
                    RA_EVEN_DATA_OUT_RF <= ODD_WB_DATA_RF;
                end if;
                if (ODD_WB_ADDR_RF = RB_EVEN_ADDR_RF) then -- Forward ODD WB Data to EVEN RB OUT 
                    RB_EVEN_DATA_OUT_RF <= ODD_WB_DATA_RF;
                end if;
                if (ODD_WB_ADDR_RF = RC_EVEN_ADDR_RF) then -- Forward ODD WB Data to EVEN RC OUT 
                    RC_EVEN_DATA_OUT_RF <= ODD_WB_DATA_RF;
                end if;
                if (ODD_WB_ADDR_RF = RA_ODD_ADDR_RF) then  -- Forward ODD WB Data to ODD RA OUT 
                    RA_ODD_DATA_OUT_RF <= ODD_WB_DATA_RF;
                end if;
                if (ODD_WB_ADDR_RF = RB_ODD_ADDR_RF) then  -- Forward ODD WB Data to ODD RB OUT 
                    RB_ODD_DATA_OUT_RF <= ODD_WB_DATA_RF;
                end if;
                if (ODD_WB_ADDR_RF = RC_ODD_ADDR_RF) then  -- Forward ODD WB Data to ODD RC OUT 
                    RC_ODD_DATA_OUT_RF <= ODD_WB_DATA_RF;
                end if;
            end if;
        end if;
    end process REG_FILE_PROC;
end behavioral;
		