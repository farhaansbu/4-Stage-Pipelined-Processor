library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity decoder_tb is
end decoder_tb;

architecture behavioral of decoder_tb is

    -- Signals for decoder
    signal instruction : std_logic_vector(24 downto 0);
    signal instruction_type : unsigned(1 downto 0);	
    signal rs3_addr : std_logic_vector(4 downto 0);
    signal rs2_addr : std_logic_vector(4 downto 0);
    signal rs1_addr : std_logic_vector(4 downto 0);
    signal rd_addr : std_logic_vector(4 downto 0);

begin

    -- Instantiation of Decoder
    uut : entity decoder
    port map (
        instruction => instruction,
        instruction_type => instruction_type,
        rs3_addr => rs3_addr,
        rs2_addr => rs2_addr,
        rs1_addr => rs1_addr,
        rd_addr => rd_addr
    );

    -- Stimulus process
    stimulus : process
    begin
        -- Test Load Instruction
        instruction <= "0001000000000000000100010";
        wait for 20 ns;

        -- Test R4 Instruction
        instruction <= "1000000001000100001100010";
        wait for 20 ns;
        

        -- Test R3 Instruction        
        instruction <= "1100000010001000011000001";
        wait for 20 ns;

        -- End simulation
        wait;
    end process;

end behavioral;