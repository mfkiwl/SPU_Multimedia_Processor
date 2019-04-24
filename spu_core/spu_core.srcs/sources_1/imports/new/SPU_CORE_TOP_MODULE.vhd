--------------------------------------------------------------------------------
-- Company: Stony Brook University
-- Engineer: Wilmer Suarez
--
-- Create Date: 03/22/2019
-- Design Name: SPU Core 
-- Tool versions: Vivado v2018.3 (64-bit)
--------------------------------------------------------------------------------
-------------------- LIBRARIES --------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.COMPONENTS_PACKAGE.ALL; -- Contains result_packet Record

-------------------- ENTITY DEFINITION --------------------
entity SPU_CORE_TOP_MODULE is
port (
    -------------------- INPUTS --------------------
    CLK : in STD_LOGIC; -- System Wide Synchronous Clock
    EVEN_OPCODE   : in STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0); -- Even Pipe Opcode
    RA_EVEN_ADDR  : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);   -- Even Pipe RA Register Address
    RB_EVEN_ADDR  : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);   -- Even Pipe RB Register Address
    RC_EVEN_ADDR  : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);   -- Even Pipe RC Register Address
    EVEN_REG_DEST : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);   -- Even Write back Address (RT)
    EVEN_RI7      : in STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0);    -- Even Immediate RI7
    EVEN_RI10     : in STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0);   -- Even Immediate RI10
    EVEN_RI16     : in STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0);   -- Even Immediate RI16
    ODD_OPCODE    : in STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0); -- Even Pipe Opcode
    RA_ODD_ADDR   : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);   -- Odd Pipe RA Register Address
    RB_ODD_ADDR   : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);   -- Odd Pipe RB Register Address
    RC_ODD_ADDR   : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);   -- Odd Pipe RC Register Address
    ODD_REG_DEST  : in STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);   -- Odd Write back Address (RT)
    ODD_RI7       : in STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0);    -- Odd Immediate RI7
    ODD_RI10      : in STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0);   -- Odd Immediate RI10
    ODD_RI16      : in STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0);   -- Odd Immediate RI16
    ODD_RI18      : in STD_LOGIC_VECTOR((RI18_WIDTH-1) downto 0);   -- Odd Immediate RI18
    LS_DATA_IN    : in STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);   -- 16-Byte data from Local Store
    -------------------- OUTPUTS --------------------
    RESULT_PACKET_EVEN_OUT : out RESULT_PACKET_EVEN := ((others => '0'), (others => '0'), '0', 0); -- Even Pipe Result Packet to Write Back Stage 
    RESULT_PACKET_ODD_OUT  : out RESULT_PACKET_ODD  := ((others => '0'), (others => '0'), '0', 0); -- Odd Pipe Result Packet to Write Back Stage 
    LS_WE_OUT_EOP          : out STD_LOGIC          := '0'; -- Local Store Write Enable
    LS_RIB_OUT_EOP         : out STD_LOGIC          := '0'; -- Local Store Read Instruction Block Flag
    LS_DATA_OUT_EOP        : out STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)    := (others => '0'); -- Local Store Data IN
    LS_ADDR_OUT_EOP        : out STD_LOGIC_VECTOR((ADDR_WIDTH_LS-1) downto 0) := (others => '0')  -- Local Store Addr IN
);
end SPU_CORE_TOP_MODULE;

-------------------- ARCHITECTURE DEFINITION --------------------
architecture behavioral of SPU_CORE_TOP_MODULE is
-------------------- REGISTER FILE -> FORWARDING MACRO SIGNALS --------------------
signal EVEN_OPCODE_OUT_RF   : STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0);
signal ODD_OPCODE_OUT_RF    : STD_LOGIC_VECTOR((OPCODE_WIDTH-1) downto 0);
signal RA_EVEN_DATA_OUT_RF  : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);
signal RB_EVEN_DATA_OUT_RF  : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);
signal RC_EVEN_DATA_OUT_RF  : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);
signal RA_ODD_DATA_OUT_RF   : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);
signal RB_ODD_DATA_OUT_RF   : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);
signal RC_ODD_DATA_OUT_RF   : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);
signal RA_EVEN_ADDR_OUT_RF  : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);
signal RB_EVEN_ADDR_OUT_RF  : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);
signal RC_EVEN_ADDR_OUT_RF  : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);
signal RA_ODD_ADDR_OUT_RF   : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);
signal RB_ODD_ADDR_OUT_RF   : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);
signal RC_ODD_ADDR_OUT_RF   : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);
signal EVEN_RI7_OUT_RF      : STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0);
signal EVEN_RI10_OUT_RF     : STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0);
signal EVEN_RI16_OUT_RF     : STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0);
signal ODD_RI7_OUT_RF       : STD_LOGIC_VECTOR((RI7_WIDTH-1) downto 0);
signal ODD_RI10_OUT_RF      : STD_LOGIC_VECTOR((RI10_WIDTH-1) downto 0);
signal ODD_RI16_OUT_RF      : STD_LOGIC_VECTOR((RI16_WIDTH-1) downto 0);
signal ODD_RI18_OUT_RF      : STD_LOGIC_VECTOR((RI18_WIDTH-1) downto 0);
signal EVEN_REG_DEST_OUT_RF : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);
signal ODD_REG_DEST_OUT_RF  : STD_LOGIC_VECTOR((ADDR_WIDTH-1) downto 0);
-------------------- FORWARDING CIRCUITS -> REGISTER FILE SIGNALS --------------------
signal RESULT_PACKET_EVEN_OUT_FC : RESULT_PACKET_EVEN;
signal RESULT_PACKET_ODD_OUT_FC  : RESULT_PACKET_ODD;
-------------------- LOCAL STORE -> EVEN ODD PIPES SIGNALS --------------------
signal DATA_OUT_LS                : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0);  
signal INSTR_BLOCK_OUT_LS         : STD_LOGIC_VECTOR((INSTR_WIDTH_LS-1) downto 0);
begin
--======================================= INSTRUCTION FETCH STAGE ========================================--

    
--============================================= DECODE STAGE =============================================--


--======================================= DEPENDENCY & ISSUE STAGE =======================================--


--========================================= REGISTER FETCH STAGE =========================================--
    RF_STAGE : REGISTER_FETCH_STAGE port map ( 
        CLK              => CLK,
        EVEN_OPCODE_RF   => EVEN_OPCODE,
        ODD_OPCODE_RF    => ODD_OPCODE,  
        RA_EVEN_ADDR_RF  => RA_EVEN_ADDR, 
        RB_EVEN_ADDR_RF  => RB_EVEN_ADDR,
        RC_EVEN_ADDR_RF  => RC_EVEN_ADDR,   
        RA_ODD_ADDR_RF   => RA_ODD_ADDR,
        RB_ODD_ADDR_RF   => RB_ODD_ADDR,
        RC_ODD_ADDR_RF   => RC_ODD_ADDR,
        EVEN_RI7_RF      => EVEN_RI7,  
        EVEN_RI10_RF     => EVEN_RI10,   
        EVEN_RI16_RF     => EVEN_RI16,     
        ODD_RI7_RF       => ODD_RI7,       
        ODD_RI10_RF      => ODD_RI10,      
        ODD_RI16_RF      => ODD_RI16,      
        ODD_RI18_RF      => ODD_RI18,     
        EVEN_REG_DEST_RF => EVEN_REG_DEST, 
        ODD_REG_DEST_RF  => ODD_REG_DEST,
        RESULT_PACKET_EVEN_IN_FC => RESULT_PACKET_EVEN_OUT_FC,   
        RESULT_PACKET_ODD_IN_FC  => RESULT_PACKET_ODD_OUT_FC,
        -------------------- OUTPUTS --------------------
        EVEN_OPCODE_OUT_RF   => EVEN_OPCODE_OUT_RF,
        ODD_OPCODE_OUT_RF    => ODD_OPCODE_OUT_RF,
        RA_EVEN_DATA_OUT_RF  => RA_EVEN_DATA_OUT_RF,
        RB_EVEN_DATA_OUT_RF  => RB_EVEN_DATA_OUT_RF,
        RC_EVEN_DATA_OUT_RF  => RC_EVEN_DATA_OUT_RF, 
        RA_ODD_DATA_OUT_RF   => RA_ODD_DATA_OUT_RF,
        RB_ODD_DATA_OUT_RF   => RB_ODD_DATA_OUT_RF,
        RC_ODD_DATA_OUT_RF   => RC_ODD_DATA_OUT_RF,
        RA_EVEN_ADDR_OUT_RF  => RA_EVEN_ADDR_OUT_RF,
        RB_EVEN_ADDR_OUT_RF  => RB_EVEN_ADDR_OUT_RF,
        RC_EVEN_ADDR_OUT_RF  => RC_EVEN_ADDR_OUT_RF,
        RA_ODD_ADDR_OUT_RF   => RA_ODD_ADDR_OUT_RF,
        RB_ODD_ADDR_OUT_RF   => RB_ODD_ADDR_OUT_RF, 
        RC_ODD_ADDR_OUT_RF   => RC_ODD_ADDR_OUT_RF, 
        EVEN_RI7_OUT_RF      => EVEN_RI7_OUT_RF, 
        EVEN_RI10_OUT_RF     => EVEN_RI10_OUT_RF, 
        EVEN_RI16_OUT_RF     => EVEN_RI16_OUT_RF,
        ODD_RI7_OUT_RF       => ODD_RI7_OUT_RF, 
        ODD_RI10_OUT_RF      => ODD_RI10_OUT_RF,
        ODD_RI16_OUT_RF      => ODD_RI16_OUT_RF, 
        ODD_RI18_OUT_RF      => ODD_RI18_OUT_RF,
        EVEN_REG_DEST_OUT_RF => EVEN_REG_DEST_OUT_RF,
        ODD_REG_DEST_OUT_RF  => ODD_REG_DEST_OUT_RF
    );
  
--========================================= EXECUTION & WRITEBACK STAGES =========================================--
    EXE_STAGE : EXECUTION_STAGE port map (
        -------------------- INPUTS --------------------
        CLK                   => CLK, 
        EVEN_OPCODE_EXE   => EVEN_OPCODE_OUT_RF,
        ODD_OPCODE_EXE    => ODD_OPCODE_OUT_RF,
        RA_EVEN_DATA_EXE  => RA_EVEN_DATA_OUT_RF,
        RB_EVEN_DATA_EXE  => RB_EVEN_DATA_OUT_RF,
        RC_EVEN_DATA_EXE  => RC_EVEN_DATA_OUT_RF,
        RA_ODD_DATA_EXE   => RA_ODD_DATA_OUT_RF,
        RB_ODD_DATA_EXE   => RB_ODD_DATA_OUT_RF,
        RC_ODD_DATA_EXE   => RC_ODD_DATA_OUT_RF,
        RA_EVEN_ADDR_EXE  => RA_EVEN_ADDR_OUT_RF,
        RB_EVEN_ADDR_EXE  => RB_EVEN_ADDR_OUT_RF,
        RC_EVEN_ADDR_EXE  => RC_EVEN_ADDR_OUT_RF,
        RA_ODD_ADDR_EXE   => RA_ODD_ADDR_OUT_RF,
        RB_ODD_ADDR_EXE   => RB_ODD_ADDR_OUT_RF,
        RC_ODD_ADDR_EXE   => RC_ODD_ADDR_OUT_RF,
        EVEN_RI7_EXE      => EVEN_RI7_OUT_RF,
        EVEN_RI10_EXE     => EVEN_RI10_OUT_RF,
        EVEN_RI16_EXE     => EVEN_RI16_OUT_RF,
        ODD_RI7_EXE       => ODD_RI7_OUT_RF,
        ODD_RI10_EXE      => ODD_RI10_OUT_RF,
        ODD_RI16_EXE      => ODD_RI16_OUT_RF,
        ODD_RI18_EXE      => ODD_RI18_OUT_RF,
        EVEN_REG_DEST_EXE => EVEN_REG_DEST_OUT_RF,
        ODD_REG_DEST_EXE  => ODD_REG_DEST_OUT_RF,
        LS_DATA_IN        => LS_DATA_IN,
        -------------------- OUTPUTS --------------------
        RESULT_PACKET_EVEN_OUT_FC => RESULT_PACKET_EVEN_OUT_FC,
        RESULT_PACKET_ODD_OUT_FC  => RESULT_PACKET_ODD_OUT_FC,
        LS_WE_OUT_EOP   => LS_WE_OUT_EOP,
        LS_RIB_OUT_EOP  => LS_RIB_OUT_EOP,
        LS_DATA_OUT_EOP => LS_DATA_OUT_EOP,
        LS_ADDR_OUT_EOP => LS_ADDR_OUT_EOP
    );
    
    ----- OUTPUT RESULT PACKETS -----
    RESULT_PACKET_EVEN_OUT <= RESULT_PACKET_EVEN_OUT_FC;
    RESULT_PACKET_ODD_OUT  <= RESULT_PACKET_ODD_OUT_FC;
end behavioral;
