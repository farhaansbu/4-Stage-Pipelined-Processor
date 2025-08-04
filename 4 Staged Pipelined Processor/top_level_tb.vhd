library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all; 
use std.textio.all;

entity multimedia_unit_tb is
end multimedia_unit_tb;

architecture testbench of multimedia_unit_tb is
	signal write_enable : std_logic;
    signal reset           : std_logic;
    signal clk             : std_logic;
    signal program_counter : integer := 0;
    signal instruction_in  : std_logic_vector(24 downto 0);
    
    -- Component under test
    component multimedia_unit
        port ( 
		write_enable : in std_logic;
            reset           : in std_logic;
            clk             : in std_logic;
            program_counter : in integer;
            instruction_in  : in std_logic_vector(24 downto 0)
        );
    end component;

    -- Clock generation process
    constant clk_period : time := 10 ns;
  

   file input_file: text open read_mode is "instructions.txt";
    
begin
    -- Instantiate the multimedia_unit
    uut: multimedia_unit
	port map (
		write_enable => write_enable,
            reset           => reset,
            clk             => clk,
            program_counter => program_counter,
            instruction_in  => instruction_in
        );
		
	
    -- Clock process
	process

		begin
    	wait for 100 ns; -- Initial delay
    	loop
        	clk <= '0';
        	wait for clk_period/2;
       	 clk <= '1';
        	wait for clk_period/2;
    	end loop;
	end process;


    -- Stimulus process
    stimulus: process
    begin
        -- Apply reset
        reset <= '1';
        wait for 1 ns;
        reset <= '0';
        
        -- Finish the simulation
        wait for 10 ns;
        wait;
    end process;
	
	process
    variable line_in : line;
    variable instruction : std_logic_vector(24 downto 0);
    variable pc : integer := 0;	
	
	begin
	
	write_enable <= '1';
	
    while not endfile(input_file) loop
        readline(input_file, line_in);
        read(line_in, instruction);

        -- Set program counter and instruction input
        program_counter <= pc;
        instruction_in <= instruction;

        wait for 10 ns; -- Allow time for the instruction to be stored

        pc := pc + 1;
    end loop;

    file_close(input_file);
	write_enable <= '0';
	
	program_counter <= 0;
	wait for 45 ns;	
	program_counter <= 1;
	
	loop
        	
        	wait for clk_period/2;
       	 
        	wait for clk_period/2;	   
		
		program_counter  <= program_counter + 1;
		
    	end loop;
	
    wait;
end process;
end testbench;