-------------------------------------------------------------------------------
--
-- Description : Pipeline Registers
--
-------------------------------------------------------------------------------

--{{ Section below this comment is automatically maintained
--    and may be overwritten
--{entity {multimedia_alu} architecture {behavioral}}  
 
	
-------------------------------- IF/ID -----------------------------------
library ieee;
use ieee.std_logic_1164.all;  
use ieee.numeric_std.all;

entity if_id_reg is 
	port(
		instruction_d : in std_logic_vector(24 downto 0); 
		clk : in std_logic;
	  	instruction_q : out std_logic_vector(24 downto 0)
	);
	
end if_id_reg;

architecture behavioral of if_id_reg is			   
begin
    process(clk)		 
    begin 	 
		if rising_edge(clk) then 
			instruction_q <= instruction_d;
		end if;
	end process;
end behavioral;		   


-------------------------------- ID/EX -----------------------------------

library ieee;
use ieee.std_logic_1164.all;  
use ieee.numeric_std.all;

entity id_ex_reg is 
	port(  		
	
	-- Inputs
	clk : in std_logic;	 
	
	instruction_d : in std_logic_vector(24 downto 0);
	rs1_addr_d: in std_logic_vector(4 downto 0);   
	rs2_addr_d: in std_logic_vector(4 downto 0);  
	rs3_addr_d: in std_logic_vector(4 downto 0);  
	rsd_addr_d: in std_logic_vector(4 downto 0);   
	instruction_type_d: in std_logic_vector(1 downto 0);
	rs1_data_d: in std_logic_vector(127 downto 0);  
	rs2_data_d: in std_logic_vector(127 downto 0);  
	rs3_data_d: in std_logic_vector(127 downto 0);  
	
 	-- Outputs
	instruction_q : out std_logic_vector(24 downto 0);
	rs1_addr_q: out std_logic_vector(4 downto 0);   
	rs2_addr_q: out std_logic_vector(4 downto 0);  
	rs3_addr_q: out std_logic_vector(4 downto 0);  
	rsd_addr_q: out std_logic_vector(4 downto 0);   
	instruction_type_q: out std_logic_vector(1 downto 0);
	rs1_data_q: out std_logic_vector(127 downto 0);  
	rs2_data_q: out std_logic_vector(127 downto 0);  
	rs3_data_q: out std_logic_vector(127 downto 0)  
	
	);
	
end id_ex_reg;

architecture behavioral of id_ex_reg is			   
begin
    process(clk)		 
    begin 	 
		if rising_edge(clk) then 
			instruction_q <= instruction_d;
			rs1_addr_q <= rs1_addr_d;
			rs2_addr_q <= rs2_addr_d;
			rs3_addr_q <= rs3_addr_d;  
			rsd_addr_q <= rsd_addr_d;
			instruction_type_q <= instruction_type_d;
			rs1_data_q <= rs1_data_d;
			rs2_data_q <= rs2_data_d;
			rs3_data_q <= rs3_data_d;
		end if;
	end process;
end behavioral;



-------------------------------- EX/WB-----------------------------------
library ieee;
use ieee.std_logic_1164.all;  
use ieee.numeric_std.all;

entity ex_wb_reg is 
	port(				
		clk : in std_logic;
		rd_addr_d : in std_logic_vector(4 downto 0); 
		rd_data_d : in std_logic_vector(127 downto 0);  
		
		rd_addr_q : out std_logic_vector(4 downto 0);
		rd_data_q : out std_logic_vector(127 downto 0) 
	);
	
end ex_wb_reg;

architecture behavioral of ex_wb_reg is			   
begin
    process(clk)		 
    begin 	 
		if rising_edge(clk) then 
			rd_addr_q <= rd_addr_d;
			rd_data_q <= rd_data_d; 
		end if;
	end process;
end behavioral;		


		 
		  
		  
		 