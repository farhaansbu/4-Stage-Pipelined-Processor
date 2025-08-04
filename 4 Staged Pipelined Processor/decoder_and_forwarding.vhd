-------------------------------------------------------------------------------
--
-- Description : Decoder, Forwarding Unit, and Mux
--
-------------------------------------------------------------------------------

--{{ Section below this comment is automatically maintained
--    and may be overwritten
--{entity {multimedia_alu} architecture {behavioral}}  
 
	
--------------------------------Decoder-------------------------------------
library ieee;
use ieee.std_logic_1164.all;  
use ieee.numeric_std.all;	 

entity decoder is 
	port(
		instruction: in std_logic_vector(24 downto 0);
		instruction_type: out std_logic_vector(1 downto 0);
		rs3_addr: out std_logic_vector(4 downto 0);
		rs2_addr: out std_logic_vector(4 downto 0);
		rs1_addr: out std_logic_vector(4 downto 0);
		rd_addr: out std_logic_vector(4 downto 0)
	);
	
end decoder; 

architecture behavioral of decoder is
begin
	process(instruction)
	begin	   
		
		-- Figure out instruction type 
		
		-- Load
		if (instruction(24) = '0') then    
			
			-- Set instruction type
			instruction_type <= "00";	
			-- Get rs1 and rd
			rs1_addr <= instruction(4 downto 0);
			rd_addr <= instruction(4 downto 0);
			
			-- Set others to 0
			rs2_addr <= "00000";
			rs3_addr <= "00000";
		
		-- R4 Instruction
		elsif (instruction(23) = '0') then
			
			-- Set instruction type
			instruction_type <= "01";			
			
			-- Get rs3, rs2, rs1, rd addresses
			rs3_addr <= instruction(19 downto 15);
			rs2_addr <= instruction(14 downto 10);
			rs1_addr <= instruction(9 downto 5);
			rd_addr <= instruction(4 downto 0);
		
		-- R3 Instruction Type
		else			
			
			-- Set instruction type
			instruction_type <= "10";
			
			-- Get rs2, rs1, rd addresses  
			rs2_addr <= instruction(14 downto 10);
			rs1_addr <= instruction(9 downto 5);
			rd_addr <= instruction(4 downto 0);	 
			
			-- Set rs3 addr to 0
			rs3_addr <= "00000";
			
		end if;
		
	end process;
end behavioral;	  


--------------------------------Forwarding Unit------------------------------------- 
library ieee;
use ieee.std_logic_1164.all;  
use ieee.numeric_std.all;	 

entity forwarding_unit is  
	port(				  
		rs1_addr: in std_logic_vector(4 downto 0);
		rs2_addr: in std_logic_vector(4 downto 0);
		rs3_addr: in std_logic_vector(4 downto 0);
		rd_addr: in std_logic_vector(4 downto 0);
		instruction_type: in std_logic_vector(1 downto 0);
		forward: out std_logic_vector(2 downto 0)
	);
end forwarding_unit;

architecture behavioral of forwarding_unit is
begin
	process(rs1_addr, rs2_addr, rs3_addr, rd_addr, instruction_type)
	begin	   
		
		forward <= "000";
		-- Figure out instruction type 
		
		-- Load
		if (instruction_type = "00") then   
			if (rd_addr = rs1_addr) then 
				forward(0) <= '1';
			end if;
			
		-- R4
		elsif (instruction_type = "01") then
			
			if (rd_addr = rs1_addr) then
				forward(0) <= '1';
			end if;	  
			
			if (rd_addr = rs2_addr) then  
				forward(1) <= '1';
			end if;	 
			
			if (rd_addr = rs3_addr) then 
				forward(2) <= '1';
			end if;
				
			
		-- R3
		else  
			
			if (rd_addr = rs1_addr) then
				forward(0) <= '1';
			end if;	  
			
			if (rd_addr = rs2_addr) then  
				forward(1) <= '1';
			end if;		
			
		end if;
		
	end process;
end behavioral;	 


--------------------------------Forwarding Mux-------------------------------------	  

library ieee;
use ieee.std_logic_1164.all;  
use ieee.numeric_std.all;	 

entity forwarding_mux is
	port( 
		rs1_in: in std_logic_vector(127 downto 0);
		rs2_in: in std_logic_vector(127 downto 0);
		rs3_in: in std_logic_vector(127 downto 0);
		forwarded_data: in std_logic_vector(127 downto 0);
		forwarding_signal: in std_logic_vector(2 downto 0);
		rs1_out: out std_logic_vector(127 downto 0);
		rs2_out: out std_logic_vector(127 downto 0);
		rs3_out: out std_logic_vector(127 downto 0)
	);
end forwarding_mux;	  

architecture behavioral of forwarding_mux is
begin
	process(rs1_in, rs2_in, rs3_in, forwarded_data, forwarding_signal)
	begin
		rs1_out <= rs1_in;
		rs2_out <= rs2_in;
		rs3_out <= rs3_in; 
		
		if (forwarding_signal(2) = '1')	then
			rs3_out <= forwarded_data;
		end if;
		
		if (forwarding_signal(1) = '1') then
			rs2_out <= forwarded_data;
		end if;
		
		if (forwarding_signal(0) = '1') then
			rs1_out <= forwarded_data;
		end if;
		
	end process;
end behavioral;
	

