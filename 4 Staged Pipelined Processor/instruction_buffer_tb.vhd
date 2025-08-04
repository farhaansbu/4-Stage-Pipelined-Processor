library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;
use std.textio.all;

entity instruction_buffer_tb is
end instruction_buffer_tb;

architecture behavior of instruction_buffer_tb is 
    -- Component Declaration for the Unit Under Test (UUT)
    component instruction_buffer
    port(
         clk : in  std_logic;
         program_counter : in  integer;
         instruction_in : in  std_logic_vector(24 downto 0);
         instruction_out : out  std_logic_vector(24 downto 0)
        );
    end component;

    --Inputs
    signal clk : std_logic := '0';
    signal program_counter : integer := 0;
    signal instruction_in : std_logic_vector(24 downto 0) := (others => '0');

    --Outputs
    signal instruction_out : std_logic_vector(24 downto 0);

    -- Clock period definitions
    constant clk_period : time := 10 ns;

begin
    -- Instantiate the Unit Under Test (UUT)
    uut: instruction_buffer port map (
        clk => clk,
        program_counter => program_counter,
        instruction_in => instruction_in,
        instruction_out => instruction_out
    );

    -- Clock process definitions
    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;
-- Stimulus process
    stim_proc: process
        file input_file: text open read_mode is "instructions.txt";
        variable line_content: line;
        variable instruction: std_logic_vector(24 downto 0);
    begin
        -- Hold reset state for 100 ns
        wait for 100 ns;

        while not endfile(input_file) loop
            readline(input_file, line_content);
            read(line_content, instruction);

            wait until rising_edge(clk);
            instruction_in <= instruction;

            wait for clk_period;
            program_counter <= program_counter + 1;
        end loop;

        file_close(input_file);
        wait;
    end process;
end;
