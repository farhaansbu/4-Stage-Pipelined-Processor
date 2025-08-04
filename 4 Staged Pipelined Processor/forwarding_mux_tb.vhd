library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity forwarding_mux_tb is
end forwarding_mux_tb;

architecture behavioral of forwarding_mux_tb is

    -- Signals for forwarding mux
    signal rs1_in : std_logic_vector(127 downto 0);
    signal rs2_in : std_logic_vector(127 downto 0);
    signal rs3_in : std_logic_vector(127 downto 0);
    signal forwarded_data : std_logic_vector(127 downto 0);
    signal forwarding_signal : std_logic_vector(2 downto 0);
    signal rs1_out : std_logic_vector(127 downto 0);
    signal rs2_out : std_logic_vector(127 downto 0);
    signal rs3_out : std_logic_vector(127 downto 0);

begin

    -- Instantiation of Forwarding Mux
    uut : entity forwarding_mux
    port map (
        rs1_in => rs1_in,
        rs2_in => rs2_in,
        rs3_in => rs3_in,
        forwarded_data => forwarded_data,
        forwarding_signal => forwarding_signal,
        rs1_out => rs1_out,
        rs2_out => rs2_out,
        rs3_out => rs3_out
    );

    -- Stimulus process
    stimulus : process
    begin
        -- Test forwarding none
        rs1_in <= (others => '0');
        rs2_in <= (others => '1');
        rs3_in <= (others => '0');
        forwarded_data <= (others => '1');
        forwarding_signal <= "000";
        wait for 20 ns;

        -- Test forwarding to rs1
        forwarding_signal <= "001";
        wait for 20 ns;

        -- Test forwarding to rs2
        forwarding_signal <= "010";
        wait for 20 ns;

        -- Test forwarding to rs3
        forwarding_signal <= "100";
        wait for 20 ns;

        -- Test forwarding to rs1 and rs2
        forwarding_signal <= "011";
        wait for 20 ns;

        -- Test forwarding to rs2 and rs3
        forwarding_signal <= "110";
        wait for 20 ns;

        -- Test forwarding to rs1 and rs3
        forwarding_signal <= "101";
        wait for 20 ns;

        -- Test forwarding to all
        forwarding_signal <= "111";
        wait for 20 ns;

        -- End simulation
        wait;
    end process;

end behavioral;