
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity alu_tb is
end alu_tb;
	
architecture TB_ARCHITECTURE of alu_tb is	
	-- Stimulus signals - signals mapped to the input ports of the tested entity
	signal opcode : bit_vector(24 downto 0) := "0000000000000000001100000"; -- Set to 0 for Load Immediate
	signal rs1 : bit_vector(127 downto 0) := X"00000003_00003004_00000001_03500FFF"; -- Initial value of rs1
	signal rs2 : bit_vector(127 downto 0) := X"00000000_00000003_00000000_FFFFFFFF"; -- Example 16-bit immediate value (0x1234)
	signal rs3 : bit_vector(127 downto 0) := X"00000000_00000001_00000000_00000002"; -- Example load index (2 means third 16-bit segment)
	signal outp : bit_vector(127 downto 0); -- Output register

	constant clk_period : time := 10 ns;
	signal end_sim : boolean := false;

	

begin
	-- Unit Under Test port map
	UUT : entity multimedia_alu port map (
		instruction => opcode,
		rs1 => rs1,
		rs2 => rs2,
		rs3 => rs3,
		rd => outp
	); 
		
	-- Test process
	process		 
	-- Helper variables for dynamic position calculation
	variable load_index : integer := 0;
	variable expected_output : bit_vector(127 downto 0);
	variable temp_opcode : unsigned(1 downto 0);
    variable temp_opcode_bitvec : bit_vector(1 downto 0);


	
	begin
	   --load instruction
		if (opcode(24) = '0') then
			-- Initialize values and wait for the UUT to process
			rs1 <= (others => '0'); -- Initial state of rs1	
			rs2 <= (others => '0'); -- Initial state of rs2
			rs3 <= (others => '0'); -- Initial state of rs1	
			wait for clk_period; 
			--update rs1-rs3 cycle before it calls (each signal update is 1 before the actual function call)
			rs1 <= X"00000003_00000004_80000000_7FFFFFFF";
			rs2 <= X"00000002_00000004_00000001_00007FFF";
			rs3 <= X"00000003_00000001_00008000_00007FFF";
			-- Set opcode for "Signed Integer Multiply-Add Low with Saturation"
			opcode(24 downto 23) <= "10";
			wait for clk_period; 
		end if;
		
		--R4 instruction type
		if (opcode(24) = '1' and opcode(23) = '0') then 
			
			-- Signed Integer Multiply-Add High with Saturation
			rs1 <= X"00030000_00040000_80000000_7FFFFFFF";
			rs2 <= X"00020000_00040000_00010000_7FFF0000";
			rs3 <= X"00030000_00010000_80000000_7FFF0000";
			opcode(22 downto 20) <= "001";
        		wait for clk_period;
				
			--Signed Integer Multiply-Subtract Low with Saturation
			opcode(22 downto 20) <= "010";
			rs1 <= X"00000005_00000004_80000000_7FFFFFFF";
			rs2 <= X"00000002_00000003_00007FFF_00000001";
			rs3 <= X"00000001_00000001_00007FFF_00008000";
			wait for clk_period; 	  
				
			--Signed Integer Multiply-Subtract High with Saturation
			rs1 <= X"00000005_00000004_80000001_7FFFFFFE";
			rs2 <= X"00020000_00030000_7FFF0000_00010000";
			rs3 <= X"00010000_00010000_7FFF0000_80000000";
			opcode(22 downto 20) <= "011";
        		wait for clk_period;  
				
			--Signed Long Integer Multiply-Add Low with Saturation
			rs1 <= X"8000000000000000_7FFFFFFFFFFFFFFF";
			rs2 <= X"0000000000000001_000000007FFFFFFF";
			rs3 <= X"0000000080000000_000000007FFFFFFF";
			opcode(22 downto 20) <= "100";
        		wait for clk_period; 
				
			--Signed Long Integer Multiply-Add High with Saturation
			rs1 <= X"3000000000000000_7FFFFFFFFFFFFFFF";
			rs2 <= X"1000000000000000_7FFFFFFF00000000";
			rs3 <= X"2000000000000000_7FFFFFFF00000000";
			opcode(22 downto 20) <= "101";
        		wait for clk_period;
				
			--Signed Long Multiply-Subtract Low with Saturation
			rs1 <= X"8000000000000000_7FFFFFFFFFFFFFFF";
			rs2 <= X"000000007FFFFFFF_0000000000000001";
			rs3 <= X"000000007FFFFFFF_0000000080000000";
			opcode(22 downto 20) <= "110";
        		wait for clk_period;
				
			---Signed Long Multiply-Subtract High with Saturation
			rs1 <= X"0000000000000001_7FFFFFFFFFFFFFFF";
			rs2 <= X"0000000200000000_0000000100000000";
			rs3 <= X"0000000100000000_8000000000000000";
			opcode(22 downto 20) <= "111";
        		wait for clk_period;
				
			--set for R3 instruction type
			--SLHI
			rs1 <= X"0870_0560_0340_0002_1000_0001_ABCD_FFFF";  
			opcode(18 downto 15) <= "0001";
			opcode(24 downto 23) <= "11"; --R3 indtructions
			opcode(14 downto 10) <= "00100"; 
			wait for clk_period;
		end if;
		
		--R3 instructions
		if (opcode(24) = '1' and opcode(23) = '1') then --R3 instruction
			
			--AU
			rs1 <= X"FFFFFFFE_00000001_00001111_0000FFFF";
			rs2 <= X"00000001_00000010_00001111_0000FFFF";
			opcode(18 downto 15) <= "0010";
			wait for clk_period;
			
			--CNT1H
			rs1 <= X"00030001_00000001_00001111_0000FFFF";
			opcode(18 downto 15) <= "0011";	 			
			wait for clk_period;
			
			--AHS
			rs1 <= X"8000FFFF0010FFFE_0002000100017FFF";
			rs2 <= X"8000FFFF00A00001_0002100000007FFF";
			opcode(18 downto 15) <= "0100";
			wait for clk_period;  
			
			--AND
			rs1 <= X"0000101A0010FFFE_000200010001FFFF";
			rs2 <= X"000020C100A00EE1_000610000000FFFF";
			opcode(18 downto 15) <= "0101";
			wait for clk_period;
			
			--BCW
			rs1 <= X"0000000000000000_000000001FFFFFFF";
			opcode(18 downto 15) <= "0110";
			wait for clk_period;
			
			--MAXWS
			rs1 <= X"0000FFFF_00000100_80000000_7FFFFFFF";
			rs2 <= X"0000FFEF_00001000_00000000_1FFFFFFF";
			opcode(18 downto 15) <= "0111";
			wait for clk_period;
		
			--MINWS
			rs1 <= X"0000FFFF_00000100_80000000_7FFFFFFF";
			rs2 <= X"0000FFEF_00001000_00000000_1FFFFFFF";
			opcode(18 downto 15) <= "1000";
			wait for clk_period;
			
			--MLHU
			rs1 <= X"00000002_000000FF_00007FFF_00000001";
			rs2 <= X"00000001_000000FF_00007FFF_00008000";
			opcode(18 downto 15) <= "1001";
			wait for clk_period; 
			
			--MLHCU
			rs1 <= X"00000045_00000034_00000023_00000001";
			opcode(14 downto 10) <= "00010"	;			
			opcode(18 downto 15) <= "1010";
			wait for clk_period;
			
			--OR			
			rs1 <= X"00070000_00010000_7FFF0000_01FF0000";
			rs2 <= X"00030000_00010000_7FFF0000_03FF0000";
			opcode(18 downto 15) <= "1011";
			wait for clk_period;
			
			--CLZH
			rs1 <= X"00080000_00010000_7FFF1000_00FF8000";
			opcode(18 downto 15) <= "1100";
			wait for clk_period; 
			
			--RLH
			rs1 <= X"00080001_01000300_7FFF1000_FFFF8000";
			rs2 <= X"00040004_00000004_00040004_00040004";
			opcode(18 downto 15) <= "1101";
			wait for clk_period; 
			
			--SFWU
			rs1 <= X"00000009_7FFFFFFF_00000000_00000001";
			rs2 <= X"0000000A_7FFFFFFF_80000000_FFFFFFFF"; 
			opcode(18 downto 15) <= "1110";
			wait for clk_period;
			
			--SFHS 
			rs1 <= X"00000002_0001FFFF_00008000_7FFF7FFF";
			rs2 <= X"00000001_0002FFFF_80007FFF_80007FFF"; 
			opcode(18 downto 15) <= "1111";
			wait for clk_period;
			
        end if;
		
		opcode(24 downto 0) <= "1100000000000000000000000";
		wait for clk_period;
		
		
	-- End simulation
	end_sim <= true;
	wait;
	end process;
end TB_ARCHITECTURE;