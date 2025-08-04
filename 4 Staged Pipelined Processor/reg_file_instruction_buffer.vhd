-------------------------------------------------------------------------------
--
-- Description : Instruction Buffer and Register File Entities
--
-------------------------------------------------------------------------------

--{{ Section below this comment is automatically maintained
--    and may be overwritten
--{entity {multimedia_alu} architecture {behavioral}}  
	
	
----------------------Register File --------------------------
library ieee;
use ieee.std_logic_1164.all;  
use ieee.numeric_std.all;

entity register_file is
    port (
        reset       : in  std_logic;
        register_write    : in  std_logic;			 
		
        read_addr1  : in  std_logic_vector(4 downto 0);
        read_addr2  : in  std_logic_vector(4 downto 0);	
		read_addr3	: in std_logic_vector(4 downto 0);	
		
        write_addr  : in  std_logic_vector(4 downto 0);
        write_data  : in  std_logic_vector(127 downto 0);
		
        read_data1  : out std_logic_vector(127 downto 0);
        read_data2  : out std_logic_vector(127 downto 0);
		read_data3  : out std_logic_vector(127 downto 0)
    );
end register_file;		  


architecture Behavioral of register_file is
    type reg_array is array (0 to 31) of std_logic_vector(127 downto 0);
begin
    process(reset, register_write, read_addr1, read_addr2, read_addr3, write_addr, write_data)		 
	  variable registers : reg_array := (others => (others => '0'));
    begin 
        if reset = '1' then
            registers := (others => (others => '0')); 
			read_data1 <= (others => '0');
    		read_data2 <= (others => '0');
			read_data3 <= (others => '0');
        elsif register_write = '1' then
            if write_addr /= "00000" then	  
				registers(to_integer(unsigned(write_addr))) := write_data; 
			end if;
		end if;
			
		read_data1 <= registers(to_integer(unsigned(read_addr1)));
    	read_data2 <= registers(to_integer(unsigned(read_addr2)));
		read_data3 <= registers(to_integer(unsigned(read_addr3)));	  			
    end process;
    
end Behavioral;	   




----------------------------Instruction Buffer -----------------------
library ieee;
use ieee.std_logic_1164.all;  
use ieee.numeric_std.all;

entity instruction_buffer is
	port(
		write_enable: in std_logic;
		program_counter: in integer;
		instruction_in : in std_logic_vector(24 downto 0);
		instruction_out : out std_logic_vector(24 downto 0)
	);		   
	
end instruction_buffer;

architecture behavioral of instruction_buffer is 
	type instruction_array is array (0 to 63) of std_logic_vector(24 downto 0);
begin
	process(program_counter, instruction_in)	
	variable instructions : instruction_array := (others => (others => '0'));
	begin
		if (write_enable = '1') then
			instructions(program_counter) := instruction_in; 
		end if;
		instruction_out <= instructions(program_counter);
			-- Increment PC in testbench
	end process;
end behavioral;
			
	
	