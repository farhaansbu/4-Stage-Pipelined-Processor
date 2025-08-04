library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity register_file_tb is
end register_file_tb;

architecture behavior of register_file_tb is 
    -- Component Declaration for the Unit Under Test (UUT)
    component register_file
    port(
         clk : in  std_logic;
         reset : in  std_logic;
         register_write : in  std_logic;
         read_addr1 : in  std_logic_vector(4 downto 0);
         read_addr2 : in  std_logic_vector(4 downto 0);
         read_addr3 : in  std_logic_vector(4 downto 0);
         write_addr : in  std_logic_vector(4 downto 0);
         write_data : in  std_logic_vector(127 downto 0);
         read_data1 : out  std_logic_vector(127 downto 0);
         read_data2 : out  std_logic_vector(127 downto 0);
         read_data3 : out  std_logic_vector(127 downto 0)
        );
    end component;

    --Inputs
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal register_write : std_logic := '0';
    signal read_addr1 : std_logic_vector(4 downto 0) := (others => '0');
    signal read_addr2 : std_logic_vector(4 downto 0) := (others => '0');
    signal read_addr3 : std_logic_vector(4 downto 0) := (others => '0');
    signal write_addr : std_logic_vector(4 downto 0) := (others => '0');
    signal write_data : std_logic_vector(127 downto 0) := (others => '0');

    --Outputs
    signal read_data1 : std_logic_vector(127 downto 0);
    signal read_data2 : std_logic_vector(127 downto 0);
    signal read_data3 : std_logic_vector(127 downto 0);

    -- Clock period definitions
    constant clk_period : time := 10 ns;

begin
    -- Instantiate the Unit Under Test (UUT)
    uut: register_file port map (
        clk => clk,
        reset => reset,
        register_write => register_write,
        read_addr1 => read_addr1,
        read_addr2 => read_addr2,
        read_addr3 => read_addr3,
        write_addr => write_addr,
        write_data => write_data,
        read_data1 => read_data1,
        read_data2 => read_data2,
        read_data3 => read_data3
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
    begin
        -- Hold reset state for 100 ns
        reset <= '1';
        wait for 100 ns;
        reset <= '0';
        wait for clk_period*2;

        -- Write to register 1
        register_write <= '1';
        write_addr <= "00001";
        write_data <= x"11111111111111111111111111111111";
        wait for clk_period;

        -- Write to register 2
        write_addr <= "00010";
        write_data <= x"22222222222222222222222222222222";
        wait for clk_period;

        -- Write to register 3
        write_addr <= "00011";
        write_data <= x"33333333333333333333333333333333";
        wait for clk_period;

        register_write <= '0';

        -- Read from registers 1, 2, and 3
        read_addr1 <= "00001";
        read_addr2 <= "00010";
        read_addr3 <= "00011";
        wait for clk_period;

        -- Check if the read values match the written values
        assert read_data1 = x"11111111111111111111111111111111" report "Read from register 1 failed" severity error;
        assert read_data2 = x"22222222222222222222222222222222" report "Read from register 2 failed" severity error;
        assert read_data3 = x"33333333333333333333333333333333" report "Read from register 3 failed" severity error;

        -- Test reset
        reset <= '1';
        wait for clk_period;
        reset <= '0';

        -- Read from registers again to verify reset
        wait for clk_period;
        assert read_data1 = x"00000000000000000000000000000000" report "Reset failed for register 1" severity error;
        assert read_data2 = x"00000000000000000000000000000000" report "Reset failed for register 2" severity error;
        assert read_data3 = x"00000000000000000000000000000000" report "Reset failed for register 3" severity error;

        wait;
    end process;
end;
