--------------------------------------------------------------------------------
-- Company: Stony Brook University
-- Engineer: Wilmer Suarez
--
-- Create Date: 03/19/2019
-- Design Name: Forwarding Macro/Circuits
-- Tool versions: Vivado v2018.3 (64-bit)
-- Description:
--     Tests the data forwarding between the Forwarding Macro and Forwarding
--     Circuits.
--         - When one operand has a dependency
--         - When multiple operands depend on the same data
--         - When multple operands depend on different data 
--
--     Tests the Shifting of the results through the pipes and their outputs.
--------------------------------------------------------------------------------
-------------------- LIBRARIES --------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.COMPONENTS_PACKAGE.ALL; -- SPU Core Components

-------------------- ENTITY DEFINITION --------------------
entity forwarding_macro_circuits_TB is
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
end forwarding_macro_circuits_TB;

-------------------- ARCHITECTURE DEFINITION --------------------
architecture behavioral of forwarding_macro_circuits_TB is
-------------------- INPUTS --------------------
signal CLK : STD_LOGIC := '1';
signal EVEN_OPCODE : STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0) := (others=>'0');
signal ODD_OPCODE : STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0) := (others=>'0');
signal RESULT_PACKET_EVEN_IN : RESULT_PACKET := ((others => '0'), (others => '0'), '0', 0); 
signal RESULT_PACKET_ODD_IN : RESULT_PACKET := ((others => '0'), (others => '0'), '0', 0);  
signal RA_EVEN_DATA : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others=>'0'); 
signal RB_EVEN_DATA : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others=>'0'); 
signal RC_EVEN_DATA : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others=>'0'); 
signal RA_ODD_DATA : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others=>'0'); 
signal RB_ODD_DATA : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others=>'0'); 
signal RC_ODD_DATA : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others=>'0');
signal EVEN_REG_DEST : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0');
signal ODD_REG_DEST : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0');
signal RA_EVEN_ADDR : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0'); 
signal RB_EVEN_ADDR : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0'); 
signal RC_EVEN_ADDR : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0'); 
signal RA_ODD_ADDR : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0'); 
signal RB_ODD_ADDR : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0'); 
signal RC_ODD_ADDR : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0'); 
signal EVEN_RI7 : STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0) := (others => '0');      
signal EVEN_RI10 : STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0) := (others => '0');    
signal EVEN_RI16 : STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0) := (others => '0');    
signal ODD_RI7 : STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0) := (others => '0');     
signal ODD_RI10 : STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0) := (others => '0');     
signal ODD_RI16 : STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0) := (others => '0');    
signal ODD_RI18 : STD_LOGIC_VECTOR((RI18_WIDTH-1) downto 0) := (others => '0'); 
-------------------- OUTPUTS --------------------
signal RA_EVEN_DATA_OUT_FM : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others=>'0'); 
signal RB_EVEN_DATA_OUT_FM : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others=>'0'); 
signal RC_EVEN_DATA_OUT_FM : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others=>'0'); 
signal RA_ODD_DATA_OUT_FM : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others=>'0');  
signal RB_ODD_DATA_OUT_FM : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others=>'0'); 
signal RC_ODD_DATA_OUT_FM : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0) := (others=>'0'); 
signal RESULT_PACKET_EVEN_OUT_FM : RESULT_PACKET := ((others => '0'), (others => '0'), '0', 0); 
signal RESULT_PACKET_ODD_OUT_FM : RESULT_PACKET := ((others => '0'), (others => '0'), '0', 0); 
signal EVEN_RI7_OUT_FM : STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0) := (others => '0');  
signal EVEN_RI10_OUT_FM : STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0) := (others => '0'); 
signal EVEN_RI16_OUT_FM : STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0) := (others => '0');
signal ODD_RI7_OUT_FM : STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0) := (others => '0'); 
signal ODD_RI10_OUT_FM : STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0) := (others => '0'); 
signal ODD_RI16_OUT_FM : STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0) := (others => '0'); 
signal ODD_RI18_OUT_FM : STD_LOGIC_VECTOR((RI18_WIDTH-1) downto 0) := (others => '0');  
signal EVEN_REG_DEST_OUT_FM : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0');  
signal ODD_REG_DEST_OUT_FM : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0) := (others => '0');  
signal EVEN_OPCODE_OUT_FM : STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0) := (others=>'0');
signal ODD_OPCODE_OUT_FM : STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0) := (others=>'0');
-------------------- DELAY --------------------
constant CLK_PERIOD : TIME := 10ns;
begin
    -------------------- INSTANTIATE UNIT UNDER TEST --------------------
    UUT : forwarding_macro_circuits port map (
        CLK => CLK,
        EVEN_OPCODE => EVEN_OPCODE,
        ODD_OPCODE => ODD_OPCODE,
        RESULT_PACKET_EVEN_IN => RESULT_PACKET_EVEN_IN,
        RESULT_PACKET_ODD_IN => RESULT_PACKET_ODD_IN,
        RA_EVEN_DATA => RA_EVEN_DATA,
        RB_EVEN_DATA => RB_EVEN_DATA,
        RC_EVEN_DATA => RC_EVEN_DATA,
        RA_ODD_DATA => RA_ODD_DATA,
        RB_ODD_DATA => RB_ODD_DATA,
        RC_ODD_DATA => RC_ODD_DATA,
        EVEN_REG_DEST => EVEN_REG_DEST,
        ODD_REG_DEST => ODD_REG_DEST,
        RA_EVEN_ADDR => RA_EVEN_ADDR,
        RB_EVEN_ADDR => RB_EVEN_ADDR,
        RC_EVEN_ADDR => RC_EVEN_ADDR,
        RA_ODD_ADDR => RA_ODD_ADDR,
        RB_ODD_ADDR => RB_ODD_ADDR,
        RC_ODD_ADDR => RC_ODD_ADDR,
        EVEN_RI7 => EVEN_RI7,
        EVEN_RI10 => EVEN_RI10,
        EVEN_RI16 => EVEN_RI16,
        ODD_RI7 => ODD_RI7,
        ODD_RI10 => ODD_RI10, 
        ODD_RI16 => ODD_RI16,
        ODD_RI18 => ODD_RI18,
        RA_EVEN_DATA_OUT_FM => RA_EVEN_DATA_OUT_FM,
        RB_EVEN_DATA_OUT_FM => RB_EVEN_DATA_OUT_FM,
        RC_EVEN_DATA_OUT_FM => RC_EVEN_DATA_OUT_FM,     
        RA_ODD_DATA_OUT_FM => RA_ODD_DATA_OUT_FM,
        RB_ODD_DATA_OUT_FM => RB_ODD_DATA_OUT_FM,
        RC_ODD_DATA_OUT_FM => RC_ODD_DATA_OUT_FM,
        RESULT_PACKET_EVEN_OUT_FM => RESULT_PACKET_EVEN_OUT_FM,
        RESULT_PACKET_ODD_OUT_FM => RESULT_PACKET_ODD_OUT_FM,
        EVEN_RI7_OUT_FM => EVEN_RI7_OUT_FM,
        EVEN_RI10_OUT_FM => EVEN_RI10_OUT_FM,
        EVEN_RI16_OUT_FM => EVEN_RI16_OUT_FM, 
        ODD_RI7_OUT_FM => ODD_RI7_OUT_FM,
        ODD_RI10_OUT_FM => ODD_RI10_OUT_FM, 
        ODD_RI16_OUT_FM => ODD_RI16_OUT_FM,
        ODD_RI18_OUT_FM => ODD_RI18_OUT_FM,
        EVEN_REG_DEST_OUT_FM => EVEN_REG_DEST_OUT_FM,
        ODD_REG_DEST_OUT_FM => ODD_REG_DEST_OUT_FM,
        EVEN_OPCODE_OUT_FM => EVEN_OPCODE_OUT_FM,
        ODD_OPCODE_OUT_FM => ODD_OPCODE_OUT_FM
    );
    
    -------------------- CLK GENERATION PROCESS --------------------
    CLK <= not CLK after CLK_PERIOD/2;

    -------------------- FORWARDING MACRO/CIRCUITS STIMULUS PROCESS --------------------
    SIMULUS_PROC : process
        -- Even Pipe "Result" --
        variable RESULT_EVEN_PACKET : RESULT_PACKET := (
            -- BABE
            STD_LOGIC_VECTOR(to_unsigned(47806, DATA_WIDTH)), STD_LOGIC_VECTOR(to_unsigned(14, ADDR_WIDTH)), '1', 4
        );
        -- Odd Pipe "Result" --
        variable RESULT_ODD_PACKET : RESULT_PACKET := (
            -- DEED
            STD_LOGIC_VECTOR(to_unsigned(57069, DATA_WIDTH)), STD_LOGIC_VECTOR(to_unsigned(15, ADDR_WIDTH)), '1', 6
        );
    begin 
        ----- Instruction Data Coming In -----
        -- EVEN --
        RA_EVEN_DATA <= STD_LOGIC_VECTOR(to_unsigned(57005, DATA_WIDTH)); -- DEAD
        RB_EVEN_DATA <= STD_LOGIC_VECTOR(to_unsigned(12586990, DATA_WIDTH)); -- C0FFEE
        RC_EVEN_DATA <= STD_LOGIC_VECTOR(to_unsigned(61453, DATA_WIDTH)); -- F00D
        -- ODD --
        RA_ODD_DATA <= STD_LOGIC_VECTOR(to_unsigned(48879, DATA_WIDTH)); -- BEEF
        RB_ODD_DATA <= STD_LOGIC_VECTOR(to_unsigned(64206, DATA_WIDTH)); -- FACE
        RC_ODD_DATA <= STD_LOGIC_VECTOR(to_unsigned(65261, DATA_WIDTH)); -- FEED
        
        ----- IMMEDIATES IN -----
        EVEN_RI7 <= STD_LOGIC_VECTOR(to_unsigned(2, RI7_WIDTH));
        EVEN_RI10 <= STD_LOGIC_VECTOR(to_unsigned(4, RI10_WIDTH));
        EVEN_RI16 <= STD_LOGIC_VECTOR(to_unsigned(6, RI16_WIDTH));
        ODD_RI7 <= STD_LOGIC_VECTOR(to_unsigned(8, RI7_WIDTH));
        ODD_RI10 <= STD_LOGIC_VECTOR(to_unsigned(10, RI10_WIDTH));
        ODD_RI16 <= STD_LOGIC_VECTOR(to_unsigned(12, RI16_WIDTH));
        ODD_RI18 <= STD_LOGIC_VECTOR(to_unsigned(14, RI18_WIDTH)); 
        
        ----- PIPE "RESULTS" -----
        RESULT_PACKET_EVEN_IN <= RESULT_EVEN_PACKET;
        RESULT_PACKET_ODD_IN <= RESULT_ODD_PACKET;
        
        ----- OPCODES IN -----
        EVEN_OPCODE <= STD_LOGIC_VECTOR(to_unsigned(123, OPCODE_WIDTH));
        ODD_OPCODE <= STD_LOGIC_VECTOR(to_unsigned(1234, OPCODE_WIDTH));
        
        ----- REG DEST IN -----
        EVEN_REG_DEST <= STD_LOGIC_VECTOR(to_unsigned(10, ADDR_WIDTH));
        ODD_REG_DEST <= STD_LOGIC_VECTOR(to_unsigned(20, ADDR_WIDTH));
        
        ----- TEST DATA FORWARDING -----
        RA_EVEN_ADDR <= STD_LOGIC_VECTOR(to_unsigned(6, ADDR_WIDTH));
        RB_EVEN_ADDR <= STD_LOGIC_VECTOR(to_unsigned(6, ADDR_WIDTH));
        RC_ODD_ADDR <= STD_LOGIC_VECTOR(to_unsigned(4, ADDR_WIDTH));
        
        ----- Test Result Packet Shifting -----
        wait for CLK_PERIOD*8;
    
        wait;
    end process;
end behavioral;
