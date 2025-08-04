library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity pipeline_tb is
end pipeline_tb;

architecture behavioral of pipeline_tb is

    -- Clock signal
    signal clk : std_logic := '0';
    
    -- Signals for IF/ID register
    signal instruction_d_ifid : std_logic_vector(24 downto 0);
    signal instruction_q_ifid : std_logic_vector(24 downto 0);
    
    -- Signals for ID/EX register
    signal instruction_d_idex : std_logic_vector(24 downto 0);
    signal instruction_q_idex : std_logic_vector(24 downto 0);
    signal rs1_addr_d : std_logic_vector(4 downto 0);
    signal rs2_addr_d : std_logic_vector(4 downto 0);
    signal rs3_addr_d : std_logic_vector(4 downto 0);
    signal rsd_addr_d : std_logic_vector(4 downto 0);
    signal instruction_type_d : unsigned(1 downto 0);
    signal rs1_data_d : std_logic_vector(127 downto 0);
    signal rs2_data_d : std_logic_vector(127 downto 0);
    signal rs3_data_d : std_logic_vector(127 downto 0);
    signal rs1_addr_q : std_logic_vector(4 downto 0);
    signal rs2_addr_q : std_logic_vector(4 downto 0);
    signal rs3_addr_q : std_logic_vector(4 downto 0);
    signal rsd_addr_q : std_logic_vector(4 downto 0);
    signal instruction_type_q : unsigned(1 downto 0);
    signal rs1_data_q : std_logic_vector(127 downto 0);
    signal rs2_data_q : std_logic_vector(127 downto 0);
    signal rs3_data_q : std_logic_vector(127 downto 0);
    
    -- Signals for EX/WB register
    signal rsd_addr_d_exwb : std_logic_vector(4 downto 0);
    signal rsd_data_d_exwb : std_logic_vector(127 downto 0);
    signal rsd_addr_q_exwb : std_logic_vector(4 downto 0);
    signal rsd_data_q_exwb : std_logic_vector(127 downto 0);
    
begin

    -- Clock generation
    clk_process : process
    begin
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
    end process;

    -- Instantiation of IF/ID register
    if_id_inst : entity if_id_reg
    port map (
        instruction_d => instruction_d_ifid,
        clk => clk,
        instruction_q => instruction_q_ifid
    );

    -- Instantiation of ID/EX register
    id_ex_inst : entity id_ex_reg
    port map (
        clk => clk,
        instruction_d => instruction_d_idex,
        rs1_addr_d => rs1_addr_d,
        rs2_addr_d => rs2_addr_d,
        rs3_addr_d => rs3_addr_d,
        rsd_addr_d => rsd_addr_d,
        instruction_type_d => instruction_type_d,
        rs1_data_d => rs1_data_d,
        rs2_data_d => rs2_data_d,
        rs3_data_d => rs3_data_d,
        instruction_q => instruction_q_idex,
        rs1_addr_q => rs1_addr_q,
        rs2_addr_q => rs2_addr_q,
        rs3_addr_q => rs3_addr_q,
        rsd_addr_q => rsd_addr_q,
        instruction_type_q => instruction_type_q,
        rs1_data_q => rs1_data_q,
        rs2_data_q => rs2_data_q,
        rs3_data_q => rs3_data_q
    );

    -- Instantiation of EX/WB register
    ex_wb_inst : entity ex_wb_reg
    port map (
        clk => clk,
        rsd_addr_d => rsd_addr_d_exwb,
        rsd_data_d => rsd_data_d_exwb,
        rsd_addr_q => rsd_addr_q_exwb,
        rsd_data_q => rsd_data_q_exwb
    );

    -- Stimulus process
    stimulus : process
    begin
        -- Initial values
        instruction_d_ifid <= "0000000000000000000000000";
        instruction_d_idex <= "0000000000000000000000000";
        rs1_addr_d <= "00000";
        rs2_addr_d <= "00000";
        rs3_addr_d <= "00000";
        rsd_addr_d <= "00000";
        instruction_type_d <= "00";
        rs1_data_d <= (others => '0');
        rs2_data_d <= (others => '0');
        rs3_data_d <= (others => '0');
        rsd_addr_d_exwb <= "00000";
        rsd_data_d_exwb <= (others => '0');
        
        wait for 20 ns;
        
        -- Apply some stimulus
        instruction_d_ifid <= "0000000000000000000000001";
        instruction_d_idex <= "0000000000000000000000010";
        rs1_addr_d <= "00001";
        rs2_addr_d <= "00010";
        rs3_addr_d <= "00011";
        rsd_addr_d <= "00100";
        instruction_type_d <= "01";
        rs1_data_d <= x"00000000000000000000000000000001";
        rs2_data_d <= x"00000000000000000000000000000010";
        rs3_data_d <= x"00000000000000000000000000000011";
        rsd_addr_d_exwb <= "00101";
        rsd_data_d_exwb <= x"00000000000000000000000000000100";
        
        wait for 20 ns;
        
        -- Change the stimulus
        instruction_d_ifid <= "0000000000000000000000011";
        instruction_d_idex <= "0000000000000000000000100";
        rs1_addr_d <= "00010";
        rs2_addr_d <= "00011";
        rs3_addr_d <= "00100";
        rsd_addr_d <= "00101";
        instruction_type_d <= "10";
        rs1_data_d <= x"00000000000000000000000000000101";
        rs2_data_d <= x"00000000000000000000000000000110";
        rs3_data_d <= x"00000000000000000000000000000111";
        rsd_addr_d_exwb <= "00110";
        rsd_data_d_exwb <= x"00000000000000000000000000001000";
        
        wait for 20 ns;
        
        -- Final stimulus
        instruction_d_ifid <= "0000000000000000000000101";
        instruction_d_idex <= "0000000000000000000000110";
        rs1_addr_d <= "00011";
        rs2_addr_d <= "00100";
        rs3_addr_d <= "00101";
        rsd_addr_d <= "00110";
        instruction_type_d <= "11";
        rs1_data_d <= x"00000000000000000000000000001001";
        rs2_data_d <= x"00000000000000000000000000001010";
        rs3_data_d <= x"00000000000000000000000000001011";
        rsd_addr_d_exwb <= "00111";
        rsd_data_d_exwb <= x"00000000000000000000000000001100";
        
        wait for 40 ns;

        -- End simulation
        wait;
    end process;

end behavioral;