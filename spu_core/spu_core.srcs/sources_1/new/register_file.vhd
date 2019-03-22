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
   ADDR_WIDTH : NATURAL := 7;   -- Bit-width of the Register Addresses 
   DATA_WIDTH : NATURAL := 128; -- Bit-width of the Register Data
   OPCODE_WIDTH : NATURAL := 11;-- Maximum Bit-width of Opcode
   RI7_WIDTH : NATURAL := 7;   -- Immediate 7-bit format
   RI10_WIDTH : NATURAL := 10; -- Immediate 10-bit format
   RI16_WIDTH : NATURAL := 16; -- Immediate 16-bit format
   RI18_WIDTH : NATURAL := 18  -- Immediate 18-bit format
);
port (
    -------------------- INPUTS --------------------
    CLK : in STD_LOGIC := '0';     -- System Wide Synchronous Clock
    RW_EVEN : in STD_LOGIC := '0'; -- Even Register Write Control signal
    RW_ODD : in STD_LOGIC := '0';  -- ODD Register Write Control signal
    ----- EVEN PIPE INPUT SIGNALS -----
    EVEN_OPCODE : in STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0) := (others => '0');-- Even Pipe Opcode
    RA_EVEN_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0'); -- Even Pipe RA Register Address
    RB_EVEN_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0'); -- Even Pipe RB Register Address
    RC_EVEN_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0'); -- Even Pipe RC Register Address
    EVEN_WB_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0'); -- Even Pipe Write Back Register Address
    EVEN_WB_DATA : in STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others => '0'); -- Even Pipe Write Back Data
    ----- ODD PIPE INPUT SIGNALS -----
    ODD_OPCODE : in STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0) := (others => '0'); -- Odd Pipe Opcode
    RA_ODD_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0');  -- Odd Pipe RA Register Address
    RB_ODD_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0');  -- Odd Pipe RB Register Address
    RC_ODD_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0');  -- Odd Pipe RC Register Address
    ODD_WB_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0');  -- Odd Pipe Write Back Register Address
    ODD_WB_DATA : in STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others => '0');  -- Odd Pipe Write Back Data
    ----- IMMEDIATES IN -----
    EVEN_RI7 : in STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0) := (others => '0');      -- Even Immediate RI7
    EVEN_RI10 : in STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0) := (others => '0');    -- Even Immediate RI10
    EVEN_RI16 : in STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0) := (others => '0');    -- Even Immediate RI16
    ODD_RI7 : in STD_LOGIC_VECTOR((RI18_WIDTH-1) downto 0) := (others => '0');      -- Odd Immediate RI7
    ODD_RI10 : in STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0) := (others => '0');     -- Odd Immediate RI10
    ODD_RI16 : in STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0) := (others => '0');     -- Odd Immediate RI16
    ODD_RI18 : in STD_LOGIC_VECTOR((RI18_WIDTH-1) downto 0) := (others => '0');     -- Odd Immediate RI18
    EVEN_REG_DEST : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0');-- Even Write back Address (RT)
    ODD_REG_DEST : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0'); -- Odd Write back Address (RT)
    -------------------- OUTPUTS --------------------
    ----- EVEN PIPE OUTPUT SIGNALS -----
    EVEN_OPCODE_OUT : out STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0) := (others => '0'); -- Even Pipe Opcode
    RA_EVEN_DATA_OUT : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others => '0'); -- Even Pipe RA READ Data
    RB_EVEN_DATA_OUT : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others => '0'); -- Even Pipe RB READ Data
    RC_EVEN_DATA_OUT : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others => '0'); -- Even Pipe RC READ Data
    ----- ODD PIPE OUTPUT SIGNALS -----
    ODD_OPCODE_OUT : out STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0) := (others => '0'); -- Odd Pipe Opcode
    RA_ODD_DATA_OUT : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others => '0');  -- Odd Pipe RA READ Data
    RB_ODD_DATA_OUT : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others => '0');  -- Odd Pipe RB READ Data
    RC_ODD_DATA_OUT : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others => '0');  -- Odd Pipe RC READ Data
    ----- FOR FORWARDING CIRCUITS ----- 
    RA_EVEN_ADDR_OUT : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0'); -- Even Pipe RA Register Address
    RB_EVEN_ADDR_OUT : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0'); -- Even Pipe RB Register Address
    RC_EVEN_ADDR_OUT : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0'); -- Even Pipe RC Register Address
    RA_ODD_ADDR_OUT : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0');  -- Odd Pipe RA Register Address
    RB_ODD_ADDR_OUT : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0');  -- Odd Pipe RB Register Address
    RC_ODD_ADDR_OUT : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0');  -- Odd Pipe RC Register Address
    ----- IMMEDIATES OUT -----
    EVEN_RI7_OUT : out STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0) := (others => '0');      -- Even Immediate RI7
    EVEN_RI10_OUT : out STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0) := (others => '0');    -- Even Immediate RI10
    EVEN_RI16_OUT : out STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0) := (others => '0');    -- Even Immediate RI16
    ODD_RI7_OUT : out STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0) := (others => '0');      -- Odd Immediate RI7
    ODD_RI10_OUT : out STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0) := (others => '0');     -- Odd Immediate RI10
    ODD_RI16_OUT : out STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0) := (others => '0');     -- Odd Immediate RI16
    ODD_RI18_OUT : out STD_LOGIC_VECTOR((RI18_WIDTH-1) downto 0) := (others => '0');     -- Odd Immediate RI18
    EVEN_REG_DEST_OUT : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0'); -- Even Write back Address (RT)
    ODD_REG_DEST_OUT : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0')   -- Odd Write back Address (RT)
);
end register_file;

-------------------- ARCHITECTURE DEFINITION --------------------
architecture behavioral of register_file is
    -- Array of 128 Registers --
    type registers_file_type is ARRAY (0 to 127) of STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);
    --signal registers : registers_file_type := (others => (others => '0')); -- Initially Zero out all registers
    -- For Testbench
    signal registers : registers_file_type := (
        (x"0000_BEEF_0000_DEED_0000_CAFE_0000_C0DE"),
        (x"0000_C0FF_0000_DAFA_0000_EDBA_0000_EDAD"),
        (others => '0')
    );
begin
    
    -------------------- REGISTER FILE PROCESS --------------------
    REG_FILE_PROC : process (CLK) is
    begin
        if (RISING_EDGE(CLK)) then
            -------------------- OUTPUT OPCODE --------------------
            EVEN_OPCODE_OUT <= EVEN_OPCODE;
            ODD_OPCODE_OUT <= ODD_OPCODE;
            
            -------------------- OUTPUT RT REGISTERS --------------------
            EVEN_REG_DEST_OUT <= EVEN_REG_DEST;
            ODD_REG_DEST_OUT <= ODD_REG_DEST;
            
            -------------------- OUTPUT IMMEDIATES --------------------     
            EVEN_RI7_OUT <= EVEN_RI7;     
            EVEN_RI10_OUT <= EVEN_RI10;
            EVEN_RI16_OUT <= EVEN_RI16;
            ODD_RI7_OUT <= ODD_RI7;
            ODD_RI10_OUT <= ODD_RI10;
            ODD_RI16_OUT <= ODD_RI16;
            ODD_RI18_OUT <= ODD_RI18;
            
            -------------------- OUTPUT ADDRESSES --------------------
            RA_EVEN_ADDR_OUT <= RA_EVEN_ADDR;
            RB_EVEN_ADDR_OUT <= RB_EVEN_ADDR;
            RC_EVEN_ADDR_OUT <= RC_EVEN_ADDR;
            RA_ODD_ADDR_OUT <= RA_ODD_ADDR;
            RB_ODD_ADDR_OUT <= RB_ODD_ADDR;
            RC_ODD_ADDR_OUT <= RC_ODD_ADDR;
    
            ----- Read & Latch All Register Data Before Bypass -----
            RA_EVEN_DATA_OUT <= registers(to_integer(UNSIGNED(RA_EVEN_ADDR)));
            RB_EVEN_DATA_OUT <= registers(to_integer(UNSIGNED(RB_EVEN_ADDR)));
            RC_EVEN_DATA_OUT <= registers(to_integer(UNSIGNED(RC_EVEN_ADDR)));
            RA_ODD_DATA_OUT <= registers(to_integer(UNSIGNED(RA_ODD_ADDR)));
            RB_ODD_DATA_OUT <= registers(to_integer(UNSIGNED(RB_ODD_ADDR)));
            RC_ODD_DATA_OUT <= registers(to_integer(UNSIGNED(RC_ODD_ADDR)));
            
            if (RW_EVEN = '1') then
                ----- Write to Selected Write Back Register - EVEN -----
                registers(to_integer(UNSIGNED(EVEN_WB_ADDR))) <= EVEN_WB_DATA;
                
                ----- Forward Data Coming In - EVEN WB DATA -----
                if (EVEN_WB_ADDR = RA_EVEN_ADDR) then    -- Forward EVEN WB Data to EVEN RA_OUT 
                    RA_EVEN_DATA_OUT <= EVEN_WB_DATA;
                end if;
                if (EVEN_WB_ADDR = RB_EVEN_ADDR) then    -- Forward EVEN WB Data to EVEN RB_OUT 
                    RB_EVEN_DATA_OUT <= EVEN_WB_DATA;
                end if;
                if (EVEN_WB_ADDR = RC_EVEN_ADDR) then    -- Forward EVEN WB Data to EVEN RC_OUT 
                    RC_EVEN_DATA_OUT <= EVEN_WB_DATA;
                end if;
                if (EVEN_WB_ADDR = RA_ODD_ADDR) then  -- Forward EVEN WB Data to ODD RA_OUT 
                    RA_ODD_DATA_OUT <= EVEN_WB_DATA;
                end if;
                if (EVEN_WB_ADDR = RB_ODD_ADDR) then  -- Forward EVEN WB Data to ODD RB_OUT 
                    RB_ODD_DATA_OUT <= EVEN_WB_DATA;
                end if;
                if (EVEN_WB_ADDR = RC_ODD_ADDR) then  -- Forward EVEN WB Data to ODD RC_OUT 
                    RC_ODD_DATA_OUT <= EVEN_WB_DATA;
                end if;
            end if;
            
            IF (RW_ODD = '1') then
                ----- Write to Selected Write Back Register - ODD -----
                registers(to_integer(UNSIGNED(ODD_WB_ADDR))) <= ODD_WB_DATA;                
            
                ----- Forward Data Coming In - ODD WB DATA -----
                if (ODD_WB_ADDR = RA_EVEN_ADDR) then    -- Forward ODD WB Data to EVEN RA_OUT 
                    RA_EVEN_DATA_OUT <= ODD_WB_DATA;
                end if;
                if (ODD_WB_ADDR = RB_EVEN_ADDR) then -- Forward ODD WB Data to EVEN RB_OUT 
                    RB_EVEN_DATA_OUT <= ODD_WB_DATA;
                end if;
                if (ODD_WB_ADDR = RC_EVEN_ADDR) then -- Forward ODD WB Data to EVEN RC_OUT 
                    RC_EVEN_DATA_OUT <= ODD_WB_DATA;
                end if;
                if (ODD_WB_ADDR = RA_ODD_ADDR) then  -- Forward ODD WB Data to ODD RA_OUT 
                    RA_ODD_DATA_OUT <= ODD_WB_DATA;
                end if;
                if (ODD_WB_ADDR = RB_ODD_ADDR) then  -- Forward ODD WB Data to ODD RB_OUT 
                    RB_ODD_DATA_OUT <= ODD_WB_DATA;
                end if;
                if (ODD_WB_ADDR = RC_ODD_ADDR) then  -- Forward ODD WB Data to ODD RC_OUT 
                    RC_ODD_DATA_OUT <= ODD_WB_DATA;
                end if;
            end if;
        end if;
    end process REG_FILE_PROC;
end behavioral;
		