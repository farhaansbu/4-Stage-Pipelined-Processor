library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity forwarding_unit_tb is
end forwarding_unit_tb;

architecture behavioral of forwarding_unit_tb is

    -- Signals for forwarding unit
    signal rs1_addr : std_logic_vector(4 downto 0);
    signal rs2_addr : std_logic_vector(4 downto 0);
    signal rs3_addr : std_logic_vector(4 downto 0);
    signal rd_addr : std_logic_vector(4 downto 0);
    signal instruction_type : std_logic_vector(1 downto 0);
    signal forward : std_logic_vector(2 downto 0);

begin

    -- Instantiation of Forwarding Unit
    uut : entity forwarding_unit
    port map (
        rs1_addr => rs1_addr,
        rs2_addr => rs2_addr,
        rs3_addr => rs3_addr,
        rd_addr => rd_addr,
        instruction_type => instruction_type,
        forward => forward
    );

    -- Stimulus process
    stimulus : process
    begin
        -- Test Load Instruction forwarding
        instruction_type <= "00";
        rd_addr <= "00001";
        rs1_addr <= "00001";
        rs2_addr <= "00000";
        rs3_addr <= "00000";
        wait for 20 ns;
        
        -- Test R4 Instruction forwarding
        instruction_type <= "01";
        rd_addr <= "00010";
        rs1_addr <= "00011";
        rs2_addr <= "00001";
        rs3_addr <= "00010";
        wait for 20 ns;
        
        -- Test R3 Instruction forwarding
        instruction_type <= "10";
        rd_addr <= "00101";
        rs1_addr <= "00111";
        rs2_addr <= "00101";
        rs3_addr <= "00000";
        wait for 20 ns;

        -- End simulation
        wait;
    end process;

end behavioral;