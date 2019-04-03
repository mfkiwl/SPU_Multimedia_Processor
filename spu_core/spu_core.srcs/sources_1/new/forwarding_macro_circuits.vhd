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
--     the corresponding result is sent to the Forwarding Macro to be 
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
    
    DATA_WIDTH   : NATURAL := 128; -- Bit-width of the Register Data
    OPCODE_WIDTH : NATURAL := 11;  -- Maximum bit-width of Even and Odd Opcodes
    ADDR_WIDTH   : NATURAL := 7;   -- Bit-width of the Register Addresses 
    RI7_WIDTH    : NATURAL := 7;   -- Immediate 7-bit format
    RI10_WIDTH   : NATURAL := 10;  -- Immediate 10-bit format
    RI16_WIDTH   : NATURAL := 16;  -- Immediate 16-bit format
    RI18_WIDTH   : NATURAL := 18   -- Immediate 18-bit format
);
port (
    -------------------- INPUTS --------------------
    CLK                   : in STD_LOGIC := '0'; -- System Wide Synchronous Clock
    EVEN_OPCODE_FM        : in STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0); -- Even Opcode
    ODD_OPCODE_FM         : in STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0); -- Odd Opcode
    RA_EVEN_DATA_FM       : in STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0); -- Even Pipe RA Data
    RB_EVEN_DATA_FM       : in STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0); -- Even Pipe RB Data
    RC_EVEN_DATA_FM       : in STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0); -- Even Pipe RC Data    
    RA_ODD_DATA_FM        : in STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0); -- Odd Pipe RA Data
    RB_ODD_DATA_FM        : in STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0); -- Odd Pipe RB Data
    RC_ODD_DATA_FM        : in STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0); -- Odd Pipe RC Data
    RA_EVEN_ADDR_FM       : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); -- Even Pipe RA Register Address
    RB_EVEN_ADDR_FM       : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); -- Even Pipe RB Register Address
    RC_EVEN_ADDR_FM       : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); -- Even Pipe RC Register Address
    RA_ODD_ADDR_FM        : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); -- Odd Pipe RA Register Address
    RB_ODD_ADDR_FM        : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); -- Odd Pipe RB Register Address
    RC_ODD_ADDR_FM        : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); -- Odd Pipe RC Register Address
    EVEN_RI7_FM           : in STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0);  -- Even Immediate RI7
    EVEN_RI10_FM          : in STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0); -- Even Immediate RI10
    EVEN_RI16_FM          : in STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0); -- Even Immediate RI16
    ODD_RI7_FM            : in STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0);  -- Odd Immediate RI7
    ODD_RI10_FM           : in STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0); -- Odd Immediate RI10
    ODD_RI16_FM           : in STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0); -- Odd Immediate RI16
    ODD_RI18_FM           : in STD_LOGIC_VECTOR((RI18_WIDTH-1) downto 0); -- Odd Immediate RI18
    EVEN_REG_DEST_FM      : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); -- Even Write back Address (RT)
    ODD_REG_DEST_FM       : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0); -- Odd Write back Address (RT)
    ----- FORWARDING CIRCUIT INPUTS -----
    RESULT_PACKET_EVEN_FC : in RESULT_PACKET_EVEN; -- Result Packet from Even Execution Units 
    RESULT_PACKET_ODD_FC  : in RESULT_PACKET_ODD;  -- Result Packet from Odd Execution Units
    -------------------- OUTPUTS --------------------
    RA_EVEN_DATA_OUT_FM   : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)   := (others => '0'); -- Even Pipe RA Data
    RB_EVEN_DATA_OUT_FM   : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)   := (others => '0'); -- Even Pipe RB Data
    RC_EVEN_DATA_OUT_FM   : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)   := (others => '0'); -- Even Pipe RC Data    
    RA_ODD_DATA_OUT_FM    : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)   := (others => '0'); -- Odd Pipe RA Data
    RB_ODD_DATA_OUT_FM    : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)   := (others => '0'); -- Odd Pipe RB Data
    RC_ODD_DATA_OUT_FM    : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)   := (others => '0'); -- Odd Pipe RC Data
    EVEN_RI7_OUT_FM       : out STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0)    := (others => '0'); -- Even Immediate RI7
    EVEN_RI10_OUT_FM      : out STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0)   := (others => '0'); -- Even Immediate RI10
    EVEN_RI16_OUT_FM      : out STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0)   := (others => '0'); -- Even Immediate RI16
    ODD_RI7_OUT_FM        : out STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0)    := (others => '0'); -- Odd Immediate RI7
    ODD_RI10_OUT_FM       : out STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0)   := (others => '0'); -- Odd Immediate RI10
    ODD_RI16_OUT_FM       : out STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0)   := (others => '0'); -- Odd Immediate RI16
    ODD_RI18_OUT_FM       : out STD_LOGIC_VECTOR((RI18_WIDTH-1) downto 0)   := (others => '0'); -- Odd Immediate RI18
    EVEN_OPCODE_OUT_FM    : out STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0) := (others => '0'); -- Even Opcode
    ODD_OPCODE_OUT_FM     : out STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0) := (others => '0'); -- Odd Opcode
    EVEN_REG_DEST_OUT_FM  : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0'); -- Even Write back Address (RT)
    ODD_REG_DEST_OUT_FM   : out STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0)   := (others => '0'); -- Odd Write back Address (RT)
    ----- FORWARDING CIRCUIT OUTPUTS ----- 
    RESULT_PACKET_EVEN_OUT_FC : out RESULT_PACKET_EVEN := ((others => '0'), (others => '0'), '0', 0); -- Even Pipe Result Packet to Write Back Stage 
    RESULT_PACKET_ODD_OUT_FC  : out RESULT_PACKET_ODD  := ((others => '0'), (others => '0'), '0', 0)  -- Odd Pipe Result Packet to Write Back Stage 
);
end forwarding_macro_circuits;

-------------------- ARCHITECTURE DEFINITION --------------------
architecture behavioral of forwarding_macro_circuits is
begin
    -------------------- OUTPUT INSTRUCTION DATA --------------------
    EVEN_REG_DEST_OUT_FM <= EVEN_REG_DEST_FM;
    ODD_REG_DEST_OUT_FM  <= ODD_REG_DEST_FM;
    EVEN_OPCODE_OUT_FM   <= EVEN_OPCODE_FM;
    ODD_OPCODE_OUT_FM    <= ODD_OPCODE_FM;
    
    -------------------- OUTPUT IMMEDIATE DATA --------------------
    EVEN_RI7_OUT_FM  <= EVEN_RI7_FM;
    EVEN_RI10_OUT_FM <= EVEN_RI10_FM;
    EVEN_RI16_OUT_FM <= EVEN_RI16_FM;
    ODD_RI7_OUT_FM   <= ODD_RI7_FM;
    ODD_RI10_OUT_FM  <= ODD_RI10_FM;
    ODD_RI16_OUT_FM  <= ODD_RI16_FM;
    ODD_RI18_OUT_FM  <= ODD_RI18_FM;
    
    -------------------- EVEN FC SHIFTING PROCESS --------------------
    FC_EVEN_PROC : process (CLK) is
    begin
        if (RISING_EDGE(CLK))  then
            -- Shift Contents of Even Pipe to Corresponding Next "Stage" --
            EVEN_PIPE_FC(1 to 6) <= EVEN_PIPE_FC(0 to 5);
            -- Insert New Result Packet --
            EVEN_PIPE_FC(0) <= RESULT_PACKET_EVEN_FC; 
            
            -- Send oldest Even Result Packet to Write Back Stage --
            RESULT_PACKET_EVEN_OUT_FC <= EVEN_PIPE_FC(6);
        end if;
    end process FC_EVEN_PROC;
    
    -------------------- ODD FC SHIFTING PROCESS --------------------
    FC_ODD_PROC : process (CLK) is
    begin
        if (RISING_EDGE(CLK))  then
            -- Shift Contents of Odd Pipe to Corresponding Next "Stage" --
            ODD_PIPE_FC(1 to 6) <= ODD_PIPE_FC(0 to 5);
            -- Insert New Result Packet --
            ODD_PIPE_FC(0) <= RESULT_PACKET_ODD_FC; 
          
            -- Send oldest Odd Result Packet to Write Back Stage --
            RESULT_PACKET_ODD_OUT_FC <= ODD_PIPE_FC(6);
        end if;
    end process FC_ODD_PROC;
    
    -------------------- FORWARDING MACRO PROCESS --------------------
    ----- CHECK FOR DEPENDENCIES -----
    FORWARDING_PROC : process (RA_EVEN_DATA_FM, RB_EVEN_DATA_FM, RC_EVEN_DATA_FM, RA_ODD_DATA_FM,
                               RB_ODD_DATA_FM, RC_ODD_DATA_FM, RA_EVEN_DATA_FM, RB_EVEN_DATA_FM, 
                               RC_EVEN_DATA_FM, RA_ODD_DATA_FM, RB_ODD_DATA_FM, RC_ODD_DATA_FM, 
                               EVEN_RI7_FM, EVEN_RI10_FM, EVEN_RI16_FM, ODD_RI7_FM, ODD_RI10_FM, 
                               ODD_RI16_FM, ODD_RI18_FM, EVEN_OPCODE_FM, ODD_OPCODE_FM, RA_EVEN_ADDR_FM,
                               RB_EVEN_ADDR_FM, RC_EVEN_ADDR_FM, RA_ODD_ADDR_FM, RB_ODD_ADDR_FM, RC_ODD_ADDR_FM) is
    begin    
        ----- Check Forwarding Circuits for Dependencies and Update Output Regiser Data -----
        RA_EVEN_DATA_OUT_FM <= check_dep(EVEN_PIPE_FC, ODD_PIPE_FC, RA_EVEN_ADDR_FM, RA_EVEN_DATA_FM);
        RB_EVEN_DATA_OUT_FM <= check_dep(EVEN_PIPE_FC, ODD_PIPE_FC, RB_EVEN_ADDR_FM, RB_EVEN_DATA_FM);
        RC_EVEN_DATA_OUT_FM <= check_dep(EVEN_PIPE_FC, ODD_PIPE_FC, RC_EVEN_ADDR_FM, RC_EVEN_DATA_FM);
        RA_ODD_DATA_OUT_FM  <= check_dep(EVEN_PIPE_FC, ODD_PIPE_FC, RA_ODD_ADDR_FM, RA_ODD_DATA_FM);
        RB_ODD_DATA_OUT_FM  <= check_dep(EVEN_PIPE_FC, ODD_PIPE_FC, RB_ODD_ADDR_FM, RB_ODD_DATA_FM);
        RC_ODD_DATA_OUT_FM  <= check_dep(EVEN_PIPE_FC, ODD_PIPE_FC, RC_ODD_ADDR_FM, RC_ODD_DATA_FM);
    end process FORWARDING_PROC;
end behavioral;
		