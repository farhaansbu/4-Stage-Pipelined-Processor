-------------------------------------------------------------------------------
--
-- Description : Top-Level Entity
--
-------------------------------------------------------------------------------

--{{ Section below this comment is automatically maintained
--    and may be overwritten
--{entity {multimedia_alu} architecture {behavioral}}  
   
	
library ieee;
use ieee.std_logic_1164.all;  
use ieee.numeric_std.all;	  
use std.textio.all;
use work.all;

entity multimedia_unit is
	port(  	 
		write_enable : in std_logic;
		reset: in std_logic;
		clk : in std_logic;
		program_counter: in integer;
		instruction_in : in std_logic_vector(24 downto 0)
		
	);
end multimedia_unit;

architecture structural of multimedia_unit is	  

function to_hstring (SLV : signed) return string is
  variable L : LINE;
begin
  hwrite(L, std_logic_vector(SLV));
  return L.all;
end function to_hstring;


signal instruction_stage1 : std_logic_vector(24 downto 0);  
signal instruction_stage2 : std_logic_vector(24 downto 0);
signal instruction_stage3 : std_logic_vector(24 downto 0);

signal instruction_type_stage2 : std_logic_vector(1 downto 0);
signal rs3_addr_stage2 : std_logic_vector(4 downto 0);
signal rs2_addr_stage2 : std_logic_vector(4 downto 0);
signal rs1_addr_stage2 : std_logic_vector(4 downto 0);
signal rd_addr_stage2  : std_logic_vector(4 downto 0); 	

signal rs1_data_stage2 : std_logic_vector(127 downto 0);	
signal rs2_data_stage2 : std_logic_vector(127 downto 0);
signal rs3_data_stage2 : std_logic_vector(127 downto 0);	

signal instruction_type_stage3 : std_logic_vector(1 downto 0);
signal rs3_addr_stage3 : std_logic_vector(4 downto 0);
signal rs2_addr_stage3 : std_logic_vector(4 downto 0);
signal rs1_addr_stage3 : std_logic_vector(4 downto 0);
signal rd_addr_stage3  : std_logic_vector(4 downto 0); 	

signal rs1_data_stage3 : std_logic_vector(127 downto 0);	
signal rs2_data_stage3 : std_logic_vector(127 downto 0);
signal rs3_data_stage3 : std_logic_vector(127 downto 0);

signal rs1_data_stage3_2 : std_logic_vector(127 downto 0);	
signal rs2_data_stage3_2 : std_logic_vector(127 downto 0);
signal rs3_data_stage3_2 : std_logic_vector(127 downto 0);

signal forwarding_signal : std_logic_vector(2 downto 0);

signal write_data_stage3 : bit_vector(127 downto 0); 

signal rd_addr_stage4  : std_logic_vector(4 downto 0); 
signal write_data_stage4 : std_logic_vector(127 downto 0);


begin	
	
	instr_buffer: entity instruction_buffer port map(  
		write_enable => write_enable,
		program_counter => program_counter,
		instruction_in => instruction_in,
		
		instruction_out => instruction_stage1
		);
		
	if_id: entity if_id_reg port map(
		instruction_d => instruction_stage1,
		clk => clk,							
		
		instruction_q => instruction_stage2
		);
		
	decoder: entity decoder port map(
		instruction => instruction_stage2, 	
		
		instruction_type => instruction_type_stage2,
		rs3_addr => rs3_addr_stage2,
		rs2_addr => rs2_addr_stage2,
		rs1_addr => rs1_addr_stage2,
		rd_addr => rd_addr_stage2
		);
		
	reg_file: entity register_file port map(
		reset => reset,
		register_write => '1',
		read_addr1 => rs1_addr_stage2,
		read_addr2 => rs2_addr_stage2,
		read_addr3 => rs3_addr_stage2,
		write_addr => rd_addr_stage4,
		write_data => write_data_stage4, 
		
		read_data1 => rs1_data_stage2,
		read_data2 => rs2_data_stage2,
		read_data3 => rs3_data_stage2
		);
		
	id_ex: entity id_ex_reg port map(
		clk => clk,
		instruction_d => instruction_stage2,
		rs1_addr_d => rs1_addr_stage2, 
		rs2_addr_d => rs2_addr_stage2,
		rs3_addr_d => rs3_addr_stage2, 
		rsd_addr_d => rd_addr_stage2,
		instruction_type_d => instruction_type_stage2,
		rs1_data_d => rs1_data_stage2,
		rs2_data_d => rs2_data_stage2,
		rs3_data_d => rs3_data_stage2,
		
		instruction_q => instruction_stage3,
		rs1_addr_q => rs1_addr_stage3, 
		rs2_addr_q => rs2_addr_stage3,
		rs3_addr_q => rs3_addr_stage3, 
		rsd_addr_q => rd_addr_stage3,
		instruction_type_q => instruction_type_stage3,
		rs1_data_q => rs1_data_stage3,
		rs2_data_q => rs2_data_stage3,
		rs3_data_q => rs3_data_stage3
		);
		
	forwarding_unit: entity forwarding_unit port map(
		rs1_addr => rs1_addr_stage3,
		rs2_addr => rs2_addr_stage3,
		rs3_addr => rs3_addr_stage3,
		rd_addr => rd_addr_stage4,
		instruction_type => instruction_type_stage3,
		
		forward => forwarding_signal
		);		
		
	forwarding_mux: entity forwarding_mux port map(
		rs1_in => rs1_data_stage3,
		rs2_in => rs2_data_stage3,
		rs3_in => rs3_data_stage3,
		forwarded_data => write_data_stage4,
		forwarding_signal => forwarding_signal,
		
		rs1_out => rs1_data_stage3_2,
		rs2_out => rs2_data_stage3_2,
		rs3_out => rs3_data_stage3_2
		);
		
	alu: entity multimedia_alu port map(
		instruction => (to_bitvector(instruction_stage3)),
		rs1 => (to_bitvector(rs1_data_stage3_2)),
		rs2 => (to_bitvector(rs2_data_stage3_2)),
		rs3 => (to_bitvector(rs3_data_stage3_2)),
		
		rd => write_data_stage3
		);	
		
	ex_wb: entity ex_wb_reg port map(
		clk => clk,
		rd_addr_d => rd_addr_stage3,
		rd_data_d => to_stdlogicvector(write_data_stage3),
		
		rd_addr_q => rd_addr_stage4,
		rd_data_q => write_data_stage4
		);
		
	process(clk)   
		file output_file : text open write_mode is "results.txt";
  		variable line_out : line;  
		
		variable instruction_fetch_stage : string(1 to 47);
		variable instruction_decode_stage : string(1 to 47);
		variable instruction_decode_stage2 : string(1 to 45);
		variable instruction_execute_stage: string(1 to 48);  
		variable instruction_execute_stage2: string(1 to 59);	
		variable instruction_execute_stage3: string(1 to 39);  
		variable instruction_writeback_stage : string(1 to 67);
	begin
		if rising_edge(clk) then
		instruction_fetch_stage := "Fetching instruction: " & to_string(instruction_stage1); 
		write(line_out, instruction_fetch_stage);
		writeline(output_file, line_out);  
		
		instruction_decode_stage := "Decoding instruction: " & to_string(instruction_stage2);	
		write(line_out, instruction_decode_stage);
		writeline(output_file, line_out);  
		
		instruction_decode_stage2 := "rs3: " & to_string(rs3_addr_stage2) & ", rs2: " & to_string(rs2_addr_stage2) & ", rs1: " & to_string(rs1_addr_stage2) & ", rd: " & to_string(rd_addr_stage2);
		write(line_out, instruction_decode_stage2);
		writeline(output_file, line_out);  
		
		instruction_execute_stage := "Executing Instruction: " & to_string(instruction_stage3);	
		write(line_out, instruction_execute_stage);
		writeline(output_file, line_out);  
		
		
		instruction_execute_stage2 := "rs3: " & to_string(rs3_addr_stage3) & ", rs2: " & to_string(rs2_addr_stage3) & ", rs1: " & to_string(rs1_addr_stage3) & ", rd (of WB stage): " & to_string(rd_addr_stage4);				  
		write(line_out, instruction_execute_stage2);
		writeline(output_file, line_out);
		
		
		instruction_execute_stage3 := "Forwarding Signal (rs3, rs2, rs1) = " & to_string(forwarding_signal);				   
		write(line_out, instruction_execute_stage3);
		writeline(output_file, line_out);  
		
		instruction_writeback_stage := "Writing register " & to_string(rd_addr_stage4) & " with value: " & to_hstring(write_data_stage4);  
		write(line_out, instruction_writeback_stage);
		writeline(output_file, line_out);  	 
		
		write(line_out, LF);
		writeline(output_file, line_out);	  
		
		write(line_out, LF);
		writeline(output_file, line_out);	
		
		
		end if;
	end process;
		
	
end structural;
	