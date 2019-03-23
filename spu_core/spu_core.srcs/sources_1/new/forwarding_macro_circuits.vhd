--------------------------------------------------------------------------------
-- Company: Stony Brook University
-- Engineer: Wilmer Suarez
--
-- Create Date: 03/18/2019
-- Design Name: Forwarding Macro/Circuits
-- Tool versions: Vivado v2018.3 (64-bit)
-- Description:
--     The Forwarding Macro sends the correct operands from the Register File
--     to the Even and Odd pipes. It uses the pipe Forwarding Circuits to 
--     handle the data dependencies that arise.
--
--     Forwarding Circuits shift the results of the execution units
--     through the pipeline stages. 
--     If the Forwarding Macro signals the Circuits to resolve a dependency,
--     the corresponding result packet is sent to the Forwarding Macro to be 
--     used by the dependant instruction.
--------------------------------------------------------------------------------
-------------------- LIBRARIES --------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.COMPONENTS_PACKAGE.ALL; -- Contains result_packet Record

-------------------- ENTITY DEFINITION --------------------
entity forwarding_macro_circuits is
generic (
    FC_DEPTH : NATURAL := 7;      -- Forwarding Circuit Length
    DATA_WIDTH : NATURAL := 128;  -- Bit-width of the Register Data
    OPCODE_WIDTH : NATURAL := 11; -- Maximum bit-width of Even and Odd Opcodes
    ADDR_WIDTH : NATURAL := 7;    -- Bit-width of the Register Addresses 
    RI7_WIDTH : NATURAL := 7;     -- Immediate 7-bit format
    RI10_WIDTH : NATURAL := 10;   -- Immediate 10-bit format
    RI16_WIDTH : NATURAL := 16;   -- Immediate 16-bit format
    RI18_WIDTH : NATURAL := 18    -- Immediate 18-bit format
);
port (
    -------------------- INPUTS --------------------
    CLK : in STD_LOGIC := '0'; -- System Wide Synchronous Clock
    EVEN_OPCODE : in STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0) := (others=>'0');
    ODD_OPCODE : in STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0) := (others=>'0');
    RESULT_PACKET_EVEN_IN : in RESULT_PACKET := ((others => '0'), (others => '0'), '0', 0); -- Result Packet from Even Execution Units 
    RESULT_PACKET_ODD_IN : in RESULT_PACKET := ((others => '0'), (others => '0'), '0', 0);  -- Result Packet from Odd Execution Units
    RA_EVEN_DATA : in STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others=>'0'); -- Even Pipe RA Data
    RB_EVEN_DATA : in STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others=>'0'); -- Even Pipe RB Data
    RC_EVEN_DATA : in STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others=>'0'); -- Even Pipe RC Data    
    RA_ODD_DATA : in STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others=>'0');  -- Odd Pipe RA Data
    RB_ODD_DATA : in STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others=>'0');  -- Odd Pipe RB Data
    RC_ODD_DATA : in STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others=>'0');  -- Odd Pipe RC Data
    EVEN_REG_DEST : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0');  -- Even Write back Address (RT)
    ODD_REG_DEST : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0');  -- Odd Write back Address (RT)
    ----- FOR FORWARDING CIRCUITS ----- 
    RA_EVEN_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0'); -- Even Pipe RA Register Address
    RB_EVEN_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0'); -- Even Pipe RB Register Address
    RC_EVEN_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0'); -- Even Pipe RC Register Address
    RA_ODD_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0');  -- Odd Pipe RA Register Address
    RB_ODD_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0');  -- Odd Pipe RB Register Address
    RC_ODD_ADDR : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0');  -- Odd Pipe RC Register Address
    ----- IMMEDIATES IN -----
    EVEN_RI7 : in STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0) := (others => '0');      -- Even Immediate RI7
    EVEN_RI10 : in STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0) := (others => '0');    -- Even Immediate RI10
    EVEN_RI16 : in STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0) := (others => '0');    -- Even Immediate RI16
    ODD_RI7 : in STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0) := (others => '0');      -- Odd Immediate RI7
    ODD_RI10 : in STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0) := (others => '0');     -- Odd Immediate RI10
    ODD_RI16 : in STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0) := (others => '0');     -- Odd Immediate RI16
    ODD_RI18 : in STD_LOGIC_VECTOR((RI18_WIDTH-1) downto 0) := (others => '0');     -- Odd Immediate RI18
    -------------------- OUTPUTS --------------------
    RA_EVEN_DATA_OUT_FM : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others=>'0'); -- Even Pipe RA Data
    RB_EVEN_DATA_OUT_FM : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others=>'0'); -- Even Pipe RB Data
    RC_EVEN_DATA_OUT_FM : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others=>'0'); -- Even Pipe RC Data    
    RA_ODD_DATA_OUT_FM : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others=>'0');  -- Odd Pipe RA Data
    RB_ODD_DATA_OUT_FM : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others=>'0');  -- Odd Pipe RB Data
    RC_ODD_DATA_OUT_FM : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others=>'0');  -- Odd Pipe RC Data
    RESULT_PACKET_EVEN_OUT_FM : out RESULT_PACKET := ((others => '0'), (others => '0'), '0', 0); -- Even Pipe Result Packet to Write Back Stage 
    RESULT_PACKET_ODD_OUT_FM : out RESULT_PACKET := ((others => '0'), (others => '0'), '0', 0);  -- Odd Pipe Result Packet to Write Back Stage 
    ----- OUTPUTS FOR EXECUTION UNIT -----
    EVEN_RI7_OUT_FM : out STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0) := (others => '0');   -- Even Immediate RI7
    EVEN_RI10_OUT_FM : out STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0) := (others => '0'); -- Even Immediate RI10
    EVEN_RI16_OUT_FM : out STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0) := (others => '0'); -- Even Immediate RI16
    ODD_RI7_OUT_FM : out STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0) := (others => '0');   -- Odd Immediate RI7
    ODD_RI10_OUT_FM : out STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0) := (others => '0');  -- Odd Immediate RI10
    ODD_RI16_OUT_FM : out STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0) := (others => '0');  -- Odd Immediate RI16
    ODD_RI18_OUT_FM : out STD_LOGIC_VECTOR((RI18_WIDTH-1) downto 0) := (others => '0');  -- Odd Immediate RI18
    EVEN_REG_DEST_OUT_FM : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0');  -- Even Write back Address (RT)
    ODD_REG_DEST_OUT_FM : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0');  -- Odd Write back Address (RT)
    EVEN_OPCODE_OUT_FM : out STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0) := (others=>'0');
    ODD_OPCODE_OUT_FM : out STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0) := (others=>'0')
);
end forwarding_macro_circuits;

-------------------- ARCHITECTURE DEFINITION --------------------
architecture behavioral of forwarding_macro_circuits is
----- Forwarding Circuit Array Type -----
type FC is array (0 to (FC_DEPTH-1)) of RESULT_PACKET;

----- Even Pipe Forwarding Circuit -----
-- Initialize all Even Packets to 0 --
signal EVEN_PIPE_FC : FC := (others =>((others => '0'), (others => '0'), '0', 0));
-- For Testbench --
--signal EVEN_PIPE_FC : FC := (
--    -- ABC
--    (STD_LOGIC_VECTOR(to_unsigned(2748, DATA_WIDTH)), STD_LOGIC_VECTOR(to_unsigned(1, ADDR_WIDTH)), '1', 4),
--    -- DEF
--    (STD_LOGIC_VECTOR(to_unsigned(3567, DATA_WIDTH)), STD_LOGIC_VECTOR(to_unsigned(2, ADDR_WIDTH)), '1', 4),
--    -- DEAF
--    (STD_LOGIC_VECTOR(to_unsigned(57007, DATA_WIDTH)), STD_LOGIC_VECTOR(to_unsigned(6, ADDR_WIDTH)), '1', 4),
--    -- ABE
--    (STD_LOGIC_VECTOR(to_unsigned(2750, DATA_WIDTH)), STD_LOGIC_VECTOR(to_unsigned(4, ADDR_WIDTH)), '1', 4),
--    -- B00
--    (STD_LOGIC_VECTOR(to_unsigned(2816, DATA_WIDTH)), STD_LOGIC_VECTOR(to_unsigned(5, ADDR_WIDTH)), '1', 4),
--    -- FACED
--    (STD_LOGIC_VECTOR(to_unsigned(1027309, DATA_WIDTH)), STD_LOGIC_VECTOR(to_unsigned(6, ADDR_WIDTH)), '1', 4),
--    -- F00
--    (STD_LOGIC_VECTOR(to_unsigned(3840, DATA_WIDTH)), STD_LOGIC_VECTOR(to_unsigned(7, ADDR_WIDTH)), '1', 4)
--);

----- Odd Pipe Forwarding Circuit -----
-- Initialize all Odd Packets to 0 --
signal ODD_PIPE_FC : FC := (others =>((others => '0'), (others => '0'), '0', 0));
--signal ODD_PIPE_FC : FC := (
--    -- FED
--    (STD_LOGIC_VECTOR(to_unsigned(4077, DATA_WIDTH)), STD_LOGIC_VECTOR(to_unsigned(8, ADDR_WIDTH)), '1', 4),
--    -- CBA
--    (STD_LOGIC_VECTOR(to_unsigned(3258, DATA_WIDTH)), STD_LOGIC_VECTOR(to_unsigned(6, ADDR_WIDTH)), '1', 4),
--    -- CAC
--    (STD_LOGIC_VECTOR(to_unsigned(3244, DATA_WIDTH)), STD_LOGIC_VECTOR(to_unsigned(10, ADDR_WIDTH)), '1', 4),
--    -- C00B
--    (STD_LOGIC_VECTOR(to_unsigned(49163, DATA_WIDTH)), STD_LOGIC_VECTOR(to_unsigned(11, ADDR_WIDTH)), '1', 4),
--    -- D00D
--    (STD_LOGIC_VECTOR(to_unsigned(53261, DATA_WIDTH)), STD_LOGIC_VECTOR(to_unsigned(12, ADDR_WIDTH)), '1', 4),
--    -- CEE
--    (STD_LOGIC_VECTOR(to_unsigned(3310, DATA_WIDTH)), STD_LOGIC_VECTOR(to_unsigned(13, ADDR_WIDTH)), '1', 4),
--    -- FADE
--    (STD_LOGIC_VECTOR(to_unsigned(64222, DATA_WIDTH)), STD_LOGIC_VECTOR(to_unsigned(16, ADDR_WIDTH)), '1', 4)
--);

----- Checks the Forwarding Circuits for Dependencies -----
function check_dep(EVEN_FC : FC; -- Even Forwarding Circuit
                   ODD_FC : FC;  -- Odd Forwarding Circuit
                   ADDR : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);  -- Register Address being Evaluated
                   DATA_IN : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)) -- Data from Register File
                   return STD_LOGIC_VECTOR is
    variable DATA_OUT : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0); -- Data to be Forwarded
    variable I_FC : NATURAL := 0; -- Forwarding Circuit Index of Data
    variable found : BOOLEAN := false; -- Found a dependency?
begin
    DATA_OUT := DATA_IN; -- Initialize DATA_OUT to the Data from Register File
    ----- Check Even Forwarding Circuit -----
    while(I_FC < (FC_DEPTH-1)) loop  
        if (EVEN_FC(I_FC).REG_DEST = ADDR) then
            DATA_OUT := EVEN_FC(I_FC).RESULT;
            exit;
        end if;
        I_FC := I_FC + 1; -- Go to next Result Packet
    end loop;
    
    ----- Check Odd Forwarding Circuit -----
    for i in 0 to (FC_DEPTH-1) loop  
        if (ODD_FC(i).REG_DEST = ADDR) then
            if (i < I_FC) then
                DATA_OUT := ODD_FC(i).RESULT; -- Update Forwarded Data
            end if;
            exit;
        end if;
    end loop;
    
    -- Forwarded Data --
    return DATA_OUT;
end function check_dep;
begin
    -------------------- OUTPUT INSTRUCTION DATA --------------------
    EVEN_REG_DEST_OUT_FM <= EVEN_REG_DEST;
    ODD_REG_DEST_OUT_FM <= ODD_REG_DEST;
    EVEN_OPCODE_OUT_FM <= EVEN_OPCODE;
    ODD_OPCODE_OUT_FM <= ODD_OPCODE;
    
    -------------------- OUTPUT IMMEDIATE DATA --------------------
    EVEN_RI7_OUT_FM <= EVEN_RI7;
    EVEN_RI10_OUT_FM <= EVEN_RI10;
    EVEN_RI16_OUT_FM <= EVEN_RI16;
    ODD_RI7_OUT_FM <= ODD_RI7;
    ODD_RI10_OUT_FM <= ODD_RI10;
    ODD_RI16_OUT_FM <= ODD_RI16;
    ODD_RI18_OUT_FM <= ODD_RI18;
    
    -------------------- EVEN FC SHIFTING PROCESS --------------------
    FC_EVEN_PROC : process (CLK) is
    begin
        if (RISING_EDGE(CLK))  then
            -- Shift Contents of Even Pipe to Corresponding Next "Stage" --
            EVEN_PIPE_FC(1 to 6) <= EVEN_PIPE_FC(0 to 5);
            EVEN_PIPE_FC(0) <= RESULT_PACKET_EVEN_IN; -- Insert New Result Packet
            
            -- Send oldest Even Result Packet to Write Back Stage --
            RESULT_PACKET_EVEN_OUT_FM <= EVEN_PIPE_FC(6);
        end if;
    end process FC_EVEN_PROC;
    
    -------------------- ODD FC SHIFTING PROCESS --------------------
    FC_ODD_PROC : process (CLK) is
    begin
        if (RISING_EDGE(CLK))  then
            -- Shift Contents of Odd Pipe to Corresponding Next "Stage" --
            ODD_PIPE_FC(1 to 6) <= ODD_PIPE_FC(0 to 5);
            ODD_PIPE_FC(0) <= RESULT_PACKET_ODD_IN; -- Insert New Result Packet
            
            -- Send oldest Odd Result Packet to Write Back Stage --
            RESULT_PACKET_ODD_OUT_FM <= ODD_PIPE_FC(6);
        end if;
    end process FC_ODD_PROC;
  
    -------------------- FORWARDING MACRO PROCESS --------------------
    ----- CHECK FOR DEPENDENCIES -----
    FORWARDING_PROC : process (RA_EVEN_DATA, RB_EVEN_DATA, RC_EVEN_DATA, RA_ODD_DATA,
                               RB_ODD_DATA, RC_ODD_DATA, RA_EVEN_DATA, RB_EVEN_DATA, 
                               RC_EVEN_DATA, RA_ODD_DATA, RB_ODD_DATA, RC_ODD_DATA, 
                               EVEN_RI7, EVEN_RI10, EVEN_RI16, ODD_RI7, ODD_RI10, 
                               ODD_RI16, ODD_RI18) is
    begin    
        ----- Check Forwarding Circuits for Dependencies and Update Output Regiser Data -----
        RA_EVEN_DATA_OUT_FM <= check_dep(EVEN_PIPE_FC, ODD_PIPE_FC, RA_EVEN_ADDR, RA_EVEN_DATA);
        RB_EVEN_DATA_OUT_FM <= check_dep(EVEN_PIPE_FC, ODD_PIPE_FC, RB_EVEN_ADDR, RB_EVEN_DATA);
        RC_EVEN_DATA_OUT_FM <= check_dep(EVEN_PIPE_FC, ODD_PIPE_FC, RC_EVEN_ADDR, RC_EVEN_DATA);
        RA_ODD_DATA_OUT_FM <= check_dep(EVEN_PIPE_FC, ODD_PIPE_FC, RA_ODD_ADDR, RA_ODD_DATA);
        RB_ODD_DATA_OUT_FM <= check_dep(EVEN_PIPE_FC, ODD_PIPE_FC, RB_ODD_ADDR, RB_ODD_DATA);
        RC_ODD_DATA_OUT_FM <= check_dep(EVEN_PIPE_FC, ODD_PIPE_FC, RC_ODD_ADDR, RC_ODD_DATA);
    end process FORWARDING_PROC;
end behavioral;
		