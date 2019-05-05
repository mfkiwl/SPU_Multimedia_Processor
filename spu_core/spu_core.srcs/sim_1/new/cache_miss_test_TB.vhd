---------------------- LIBRARIES --------------------
--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;
--use IEEE.STD_LOGIC_TEXTIO.ALL;
--use STD.TEXTIO.all;
--use work.SPU_CORE_ISA_PACKAGE.ALL;
--use work.CONSTANTS_PACKAGE.ALL;
--use work.COMPONENTS_PACKAGE.ALL;

---------------------- ENTITY DEFINITION --------------------
--entity cache_miss_test_TB is
--generic (
--    INSTR_WIDTH     : NATURAL := 32;  -- Width of a single instruction
--    LINE_WIDTH      : NATURAL := 128; -- Width of 4 Instructions (Signle LS Line)
--    INSTR_COUNT_MAX : NATURAL := 4    -- Maximum Instruction Count per LS Line
--);
--end cache_miss_test_TB;

---------------------- ARCHITECTURE DEFINITION --------------------
--architecture behavioral of cache_miss_test_TB is
---------------------- INPUTS --------------------
--signal CLK           : STD_LOGIC := '1';
--signal FILL          : STD_LOGIC;
--signal SRAM_INSTR    : sram_type := (others => (others => '0'));
--signal LS_DATA_IN    : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)   := (others => '0');
---------------------- OUTPUTS --------------------
--signal RESULT_PACKET_EVEN_OUT : RESULT_PACKET_EVEN := ((others => '0'), (others => '0'), '0', 0); 
--signal RESULT_PACKET_ODD_OUT  : RESULT_PACKET_ODD  := ((others => '0'), (others => '0'), '0', 0);
--signal LS_WE_OUT_EOP          : STD_LOGIC          := '0'; 
--signal LS_RIB_OUT_EOP         : STD_LOGIC          := '0'; 
--signal LS_DATA_OUT_EOP        : STD_LOGIC_VECTOR((DATA_WIDTH-1) downto 0)     := (others => '0');
--signal LS_ADDR_OUT_EOP        : STD_LOGIC_VECTOR((ADDR_WIDTH_LS-1) downto 0)  := (others => '0');
--signal INSTR_BLOCK_OUT_LS     : STD_LOGIC_VECTOR((INSTR_WIDTH_LS-1) downto 0) := (others => '0');
---------------------- CLOCK --------------------
--constant CLK_PERIOD : TIME := 10ns;
--begin        
--    ------------------ INSTANTIATE LOCAL STORE --------------------
----    ls : LOCAL_STORE port map (
----        ----- INPUTS -----
----        WE_LS      => LS_WE_OUT_EOP,  
----        RIB_LS     => LS_RIB_OUT_EOP,
----        ADDR_LS    => LS_ADDR_OUT_EOP,
----        FILL       => FILL,
----        DATA_IN_LS => LS_DATA_OUT_EOP,
----        SRAM_INSTR => SRAM_INSTR,
----        ----- OUTPUTS -----
----        DATA_OUT_LS        => LS_DATA_IN, 
----        INSTR_BLOCK_OUT_LS => INSTR_BLOCK_OUT_LS
----    );
    
--    -------------------- CLK GENERATION PROCESS --------------------
--    CLK <= not CLK after CLK_PERIOD/2;

--    -------------------- FILL LOCAL STORE PROCESS --------------------
--    FILL_LS_PROC : process
--        variable LINE_READ     : line; -- Current Line Read
--        file file_MACHINE_CODE : text; -- File containing Instruction machine code
--        variable INSTR         : STD_LOGIC_VECTOR((32-1) downto 0) := (others => '0');         -- Instruction Read 
--        variable INSTR_LINE    : STD_LOGIC_VECTOR((LINE_WIDTH-1) downto 0) := (others => '0'); -- Full LS Line of Instructions
--        variable INSTR_LINE_i1 : NATURAL := 31; -- Index 1 of next instruction in LS Line
--        variable INSTR_LINE_i2 : NATURAL := 0;  -- Index 2 of next instruction in LS Line
--        variable ICOUNT        : NATURAL := 0;  -- Instruction count 
--        variable LS_ADDR       : NATURAL := 0;  -- Current LS Address
--        constant machine_code : String := "C:\Users\Wilmer Suarez\Desktop\SPU_Multimedia_Processor\assembler\output\data";
--    begin             
--        file_open(file_MACHINE_CODE, machine_code, read_mode); -- Open File
        
--        ----- Read & Process the Machine Code -----
--        while (not endfile(file_MACHINE_CODE)) loop
--            readline(file_MACHINE_CODE, LINE_READ); -- Read next line of file (contains one instruction)
--            hread(LINE_READ, INSTR);                -- Read the Instruction Line
             
--            INSTR_LINE(INSTR_LINE_i1 downto INSTR_LINE_i2) := INSTR; -- Add line read to LS Line 
            
--            INSTR_LINE_i1 := INSTR_LINE_i1 + 32; -- Update Line Index
--            INSTR_LINE_i2 := INSTR_LINE_i2 + 32;
--            ICOUNT := ICOUNT + 1; -- Increment Instruction Amount
            
--            -- Send the instruction read to the Local Store --
--            if (ICOUNT = INSTR_COUNT_MAX)  then
--                FILL <= '1'; -- Allow filling of the Local Store
--                SRAM_INSTR(LS_ADDR) <= INSTR_LINE;  -- Send current line to Local Store
--                wait for CLK_PERIOD; -- Wait for data to be written
--                FILL <= '0';
--                wait for CLK_PERIOD; -- Wait for data to be written
--                LS_ADDR := LS_ADDR + 1; -- Increment Address
--                INSTR_LINE := (others => '0'); -- Reset LS line
--                ICOUNT := 0; -- Reset Instruction Amount
--                -- Reset Instruction Indices --
--                INSTR_LINE_i1 := 31; 
--                INSTR_LINE_i2 := 0;
--            end if;
--        end loop;
        
--        -- Check for trailing instructions --
--        if (INSTR_LINE /= (INSTR_LINE'range => '0')) then
--            SRAM_INSTR(LS_ADDR) <= INSTR_LINE;
--            wait for CLK_PERIOD;  -- Wait for data to be written
--        end if;
        
--        file_close(file_MACHINE_CODE);
        
        
--        wait;
--    end process FILL_LS_PROC;
--end behavioral;
