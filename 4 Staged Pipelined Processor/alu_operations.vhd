-------------------------------------------------------------------------------
--
-- Title       : multimedia_alu
-- Design      : multimedia-alu
-- Author      : fk200iqgod@hotmail.com
-- Company     : Stony Brook University
--
-------------------------------------------------------------------------------
--
-- File        : C:/Users/fk200/Desktop/ESE 345/VHDL/project_part_1/multimedia-alu/src/alu_operations.vhd
-- Generated   : Wed Oct 23 15:26:42 2024
-- From        : Interface description file
-- By          : ItfToHdl ver. 1.0
--
-------------------------------------------------------------------------------
--
-- Description : Project Part 1- All multimedia ALU functions
--
-------------------------------------------------------------------------------

--{{ Section below this comment is automatically maintained
--    and may be overwritten
--{entity {multimedia_alu} architecture {behavioral}}

library ieee;
use ieee.std_logic_1164.all;  
use ieee.numeric_std.all;

entity multimedia_alu is
	port(
	instruction: in bit_vector(24 downto 0);
	rs1: in bit_vector(127 downto 0);
	rs2: in bit_vector(127 downto 0);
	rs3: in bit_vector(127 downto 0);
	rd : out bit_vector(127 downto 0)
	);
end multimedia_alu;

--}} End of automatically maintained section
															
architecture behavioral of multimedia_alu is   

----------------------------- Helper functions ------------------------------------

function bits_to_int (bits: in bit_vector) return integer is		  

	variable temp: bit_vector(bits'range);
	variable result: integer := 0;	 
	
begin
	if bits(bits'left) = '1' then
	--negative number
		temp := not bits;
	else
		temp := bits;
	end if;

	for index in bits'range loop
		-- sign bit of temp = '0'
		result := result * 2 + bit'pos(temp(index));
	end loop;
	if bits(bits'left) = '1' then
		result := (-result) - 1;
	end if;
	return result;
end bits_to_int;	  

function bits_to_natural (bits: in bit_vector) return natural is	  

	variable result: natural := 0;	

begin
	for index in bits'range loop
		result := result * 2 + bit'pos(bits(index));
	end loop;
	return result;
end bits_to_natural;		 


procedure int_to_bits (int: in integer; bits : out bit_vector) is
	variable temp: integer;
	variable result: bit_vector(bits'range);
begin
	if int < 0 then
		temp := -(int+1);
	else
		temp:= int;
	end if;
	
	for index in bits'reverse_range loop
		result(index) := bit'val(temp rem 2); temp := temp/2;
	end loop;
	if int < 0 then
		result := not result;
		result(bits'left):= '1';
	end if;
	bits := result;
end int_to_bits; 


--------------------PROCEDURES FOR EACH OPERATION------------------------------------------	 
	
-----------------Load Immediate---------------------------------------
procedure load_immediate (rs1, load_index, immediate: in bit_vector; rd: out bit_vector) is	
	-- rs1 has rd, rs2 has 16-bit immediate, rs3 has load index
	variable index : natural;
	
begin
	
	-- Get index
	index := bits_to_natural(load_index);
	
	--Read rd	
	rd := rs1;		  
	
	-- Load immediate
	rd( ((index * 16) + 15)	downto (index * 16)) :=	immediate;
	
end load_immediate;	



--------------------R4 Instruction Type- multiply and add/subtract-----------------------------------------	  
procedure r4_instruction (rs1, rs2, rs3: in signed(127 downto 0);
						specs: in unsigned(2 downto 0); 	
						rd: out bit_vector(127 downto 0)) is	   

variable size :	integer := 32 + (32 * to_integer(unsigned(specs(2 downto 2))));
variable factor1 : signed(size/2 - 1 downto 0);	  
variable factor2: signed(size/2 - 1 downto 0);
variable term: signed(size - 1 downto 0);
variable product: signed(size - 1 downto 0);
variable result: signed(size downto 0);
variable current_lower_index : integer;

constant MAX_32 : signed(31 downto 0) := X"7FFFFFFF";
constant MIN_32 : signed(31 downto 0) := X"80000000";
constant MAX_64 : signed(63 downto 0) := X"7FFFFFFFFFFFFFFF";
constant MIN_64 : signed(63 downto 0) := X"8000000000000000";

begin										
	
	-- For each pack of size 'size' (32 or 64) in 127-bit registers loop
	for i in 0 to 3 - 2 * to_integer(unsigned(specs(2 downto 2))) loop
		
		-- Calculate lower index
		current_lower_index := (i * size + (size/2 * to_integer(unsigned(specs(0 downto 0)))));	 
		
		-- Get current factors
		factor1 := rs3(current_lower_index + (size/2) - 1 downto current_lower_index); 
		factor2 := rs2(current_lower_index + (size/2) - 1 downto current_lower_index);	 
		
		-- Compute multiplication
		product := factor1 * factor2;			
		
		-- Get addition/subtraction term
		term := rs1((i * size) + size - 1 downto i * size);	 
		
		-- If we are subtracting -- 
		if (specs(1) = '1') then
			result := resize(term, size + 1) - resize(product, size + 1); 
			
		-- If we are adding -- 
		else
			result := resize(term, size + 1) + resize(product, size + 1);
		end if;	   
		
		-- Saturation For Long -- 
		if (size = 64) then
			if (result > MAX_64) then
				rd((i * size) + size - 1 downto i * size) := to_bitvector(std_logic_vector(MAX_64));
			elsif (result < MIN_64) then
				rd((i * size) + size - 1 downto i * size) := to_bitvector(std_logic_vector(MIN_64)); 
			else
				rd((i * size) + size - 1 downto i * size) := to_bitvector(std_logic_vector(resize(result, size)));
		  	end if;	
			  
		-- Saturation For Int -- 
		else
			if (result > MAX_32) then
				rd((i * size) + size - 1 downto i * size) := to_bitvector(std_logic_vector(MAX_32));
			elsif (result < MIN_32) then
				rd((i * size) + size - 1 downto i * size) := to_bitvector(std_logic_vector(MIN_32)); 
			else
				rd((i * size) + size - 1 downto i * size) := to_bitvector(std_logic_vector(resize(result, size)));	
			end if;	  
		end if;
					
	end loop;
end r4_instruction;


------------------------------------R3 Instructions --------------------------------------------------

------------------- SLHI
procedure shift_left_halfword_immediate (rs1: in bit_vector(127 downto 0); shift: in bit_vector(3 downto 0); 
										 rd: out bit_vector(127 downto 0))  is

variable shift_amt : natural := bits_to_natural(shift);
variable lower_index : integer;	 
variable halfword : bit_vector(15 downto 0);

begin
	
	-- for each halfword
	for i in 0 to 7 loop
		lower_index := i * 16; 
		-- read halfword in rs1
		halfword := rs1(lower_index + 15 downto lower_index);
		-- shift amount
		for j in 0 to shift_amt - 1 loop  
			-- shift each value in halfword
			for k in 15 downto 1 loop 
				halfword(k) := halfword(k - 1);
			end loop;
			-- set LSB to 0
			halfword(0) := '0';
		end loop;
		
		-- place result in destination register
		rd(lower_index + 15 downto lower_index) := halfword;
	end loop;

end shift_left_halfword_immediate;


------------------- AU
procedure add_word_unsigned (rs1, rs2: in unsigned(127 downto 0); rd: out bit_vector(127 downto 0)) is

variable sum: unsigned(31 downto 0);  
variable lower_index: integer;

begin
	-- for each pack of 32-bits
	for i in 0 to 3 loop 
		lower_index := i * 32;
		
		-- add word
		sum := rs1(lower_index + 31 downto lower_index) + rs2(lower_index + 31 downto lower_index);
		
		-- store result
		rd(lower_index + 31 downto lower_index) := to_bitvector(std_logic_vector(sum));
		
	end loop;
end add_word_unsigned; 	

-----------------------CNT1H
procedure count_ones_in_halfwords (rs1: in bit_vector(127 downto 0); rd: out bit_vector(127 downto 0)) is
variable count: integer := 0;
variable lower_index : integer;

begin
	for i in 0 to 7 loop	  
		lower_index := i * 16;
		count := 0;
		for j in 15 downto 0 loop
			if (rs1(lower_index + j) = '1') then   
				count := count + 1;
			end if;
		end loop;
		rd(lower_index + 15 downto lower_index) := to_bitvector(std_logic_vector(to_unsigned(count, 16)));
	end loop;
	
end count_ones_in_halfwords;


------------------- AHS
procedure add_halfword_saturated (rs1, rs2: in signed(127 downto 0); rd: out bit_vector(127 downto 0)) is  

constant max : signed(15 downto 0) := X"7FFF"; 
constant min : signed(15 downto 0) := X"8000";

variable sum: signed(16 downto 0);  
variable lower_index: integer;

begin
	-- for each pack of 16-bits
	for i in 0 to 7 loop 
		lower_index := i * 16;
		
		-- add word
		sum := resize(rs1(lower_index + 15 downto lower_index), 17) + resize(rs2(lower_index + 15 downto lower_index), 17);
		
		-- saturation
		if (sum > max) then
			rd(lower_index + 15 downto lower_index) := to_bitvector(std_logic_vector(max));
		
		elsif (sum < min) then
			rd(lower_index + 15 downto lower_index) := to_bitvector(std_logic_vector(min));
		
		else
			rd(lower_index + 15 downto lower_index) := to_bitvector(std_logic_vector(resize(sum, 16)));
			
		end if;
		
	end loop;
end add_halfword_saturated;


----------------------AND
procedure logic_and (rs1, rs2: in bit_vector(127 downto 0); rd : out bit_vector(127 downto 0)) is
begin
    rd := rs1 and rs2;
end logic_and;

----------------------BCW-
procedure broadcast_word (rs1: in bit_vector(127 downto 0); rd : out bit_vector(127 downto 0)) is  

variable word : bit_vector(31 downto 0) := rs1(31 downto 0);

begin
	for i in 0 to 3 loop
		rd((32 * i) + 31 downto 32 * i) := word;
	end loop;

end broadcast_word;


---------------------MAXWS
procedure max_signed_word(rs1, rs2: in signed(127 downto 0); rd: out bit_vector(127 downto 0)) is  

variable lower_index : integer;

begin
	
	-- for each word
	for i in 0 to 3 loop
		lower_index := i * 32;
		
		-- find and store maximum 
		if (rs1(lower_index + 31 downto lower_index) > rs2(lower_index + 31 downto lower_index)) then
			rd(lower_index + 31 downto lower_index) := to_bitvector(std_logic_vector(rs1(lower_index + 31 downto lower_index)));
		else
			rd(lower_index + 31 downto lower_index) := to_bitvector(std_logic_vector(rs2(lower_index + 31 downto lower_index)));
		end if;
		
	end loop;
	
end max_signed_word;   


---------------------MINWS
procedure min_signed_word(rs1, rs2: in signed(127 downto 0); rd: out bit_vector(127 downto 0)) is  

variable lower_index : integer;

begin
	
	-- for each word
	for i in 0 to 3 loop
		lower_index := i * 32;
		
		-- find and store minimum 
		if (rs1(lower_index + 31 downto lower_index) < rs2(lower_index + 31 downto lower_index)) then
			rd(lower_index + 31 downto lower_index) := to_bitvector(std_logic_vector(rs1(lower_index + 31 downto lower_index)));
		else
			rd(lower_index + 31 downto lower_index) := to_bitvector(std_logic_vector(rs2(lower_index + 31 downto lower_index)));
		end if;
		
	end loop;
	
end min_signed_word;
	

----------------------MLHU
procedure multiply_low_unsigned (rs1, rs2: in unsigned(127 downto 0); rd : out bit_vector(127 downto 0)) is

variable lower_index : integer;
variable product : unsigned(31 downto 0);

begin					  
	
	-- for each word (32 bits)
	for i in 0 to 3 loop   
		lower_index := i * 32;
		
		-- compute multiplication
		product := rs1(lower_index + 15 downto lower_index) * rs2(lower_index + 15 downto lower_index);	
		-- store result
		rd(lower_index + 31 downto lower_index) := to_bitvector(std_logic_vector(product));
		
	end loop;
	
end multiply_low_unsigned;


-------------------MLHCU
procedure multiply_low_constant_unsigned (rs1: in unsigned(127 downto 0); const_value : in unsigned(4 downto 0);
											rd : out bit_vector(127 downto 0)) is

variable lower_index : integer;
variable product : unsigned(31 downto 0);

begin					  
	
	-- for each word (32 bits)
	for i in 0 to 3 loop   
		lower_index := i * 32;
		
		-- compute multiplication
		product := resize(rs1(lower_index + 15 downto lower_index) * const_value, 32);	
		-- store result
		rd(lower_index + 31 downto lower_index) := to_bitvector(std_logic_vector(product));
		
	end loop;
	
end multiply_low_constant_unsigned;	


---------------------OR
procedure logic_or (rs1, rs2: in bit_vector(127 downto 0); rd : out bit_vector(127 downto 0)) is
begin
    rd := rs1 or rs2;
end logic_or;


---------------------CLZH
procedure count_leading_zeroes (rs1 : in bit_vector(127 downto 0); rd : out bit_vector(127 downto 0)) is 

variable lower_index : integer;
variable count : integer;

begin
	-- for each halfword (16 bits)
	for i in 0 to 7 loop
		lower_index := i * 16; 
		count := 0; 
		-- for each bit (starting from MSB)
		for j in 15 downto 0 loop  
			-- if we encounter a 1, stop counting 
			if (rs1(lower_index + j) = '1') then
				exit;
			-- else, we saw 0, so increment count
			else
				count := count + 1;
			end if;
		end loop; 
		--store count
		rd(lower_index + 15 downto lower_index) := to_bitvector(std_logic_vector(to_unsigned(count, 16)));	
	end loop;
end count_leading_zeroes;


-----------------------RLH
procedure rotate_left_bits (rs1, rs2: in bit_vector(127 downto 0); rd: out bit_vector(127 downto 0)) is	

variable lower_index : integer;
variable halfword : bit_vector(15 downto 0);  
variable msb : bit_vector(0 downto 0); 
variable rotate_count : natural;

begin
	-- for each halfword (16 bits)
	for i in 0 to 7 loop 
		lower_index := i * 16;
		-- calculate rotate_amount
		rotate_count := bits_to_natural(rs2(lower_index + 3 downto lower_index));	
		-- copy halfword
		halfword := rs1(lower_index + 15 downto lower_index);
		
		-- rotate 
		for j in 0 to rotate_count - 1 loop	
			-- save MSB of word
			msb := halfword(15 downto 15); 
			-- for each bit in word, shift left
			for k in 15 downto 1 loop
				halfword(k) := halfword(k - 1);
			end loop; 
			-- move MSB of word to the end
			halfword(0 downto 0) := msb;
		end loop; 
		rd(lower_index + 15 downto lower_index) := halfword;
	end loop;
	
end rotate_left_bits;


-----------------------SFWU
procedure subtract_word_unsigned (rs1, rs2: in unsigned(127 downto 0); rd: out bit_vector(127 downto 0)) is

variable difference: unsigned(31 downto 0);  
variable lower_index: integer;

begin
	-- for each pack of 32-bits
	for i in 0 to 3 loop 
		lower_index := i * 32;
		
		-- subtract word
		difference := rs2(lower_index + 31 downto lower_index) - rs1(lower_index + 31 downto lower_index);
		
		-- store result
		rd(lower_index + 31 downto lower_index) := to_bitvector(std_logic_vector(difference));
		
	end loop;
end subtract_word_unsigned;	



------------------------SFHS
procedure subtract_halfword_saturated (rs1, rs2: in signed(127 downto 0); rd: out bit_vector(127 downto 0)) is  

constant max : signed(15 downto 0) := X"7FFF"; 
constant min : signed(15 downto 0) := X"8000";

variable difference: signed(16 downto 0);  
variable lower_index: integer;

begin
	-- for each pack of 16-bits
	for i in 0 to 7 loop 
		lower_index := i * 16;
		
		-- subtract word
		difference := resize(rs2(lower_index + 15 downto lower_index), 17) - resize(rs1(lower_index + 15 downto lower_index), 17);
		
		-- saturation
		if (difference > max) then
			rd(lower_index + 15 downto lower_index) := to_bitvector(std_logic_vector(max));
		
		elsif (difference < min) then
			rd(lower_index + 15 downto lower_index) := to_bitvector(std_logic_vector(min));
		
		else
			rd(lower_index + 15 downto lower_index) := to_bitvector(std_logic_vector(resize(difference, 16)));
			
		end if;
		
	end loop;
end subtract_halfword_saturated;


---------------------------- Architecture Body -------------------------------------

begin									 
	process(rs1, rs2, rs3, instruction)		   
	
	variable rd_p : bit_vector(127 downto 0);	
	
	begin	
		-- Figure out instruction type 
		
		-- Load
		if (instruction(24) = '0') then   
			load_immediate(rs1, instruction(23 downto 21), instruction(20 downto 5), rd_p);
			rd <= rd_p;
		
		-- R4 Instruction Type (Multiply-add/subtract) 
		elsif (instruction(23) = '0') then	 
			r4_instruction(signed(to_stdlogicvector(rs1)), signed(to_stdlogicvector(rs2)),
			signed(to_stdlogicvector(rs3)), unsigned(to_stdlogicvector(instruction(22 downto 20))), rd_p);
			rd <= rd_p;
		   
		-- R3 Instruction Type
		else
			
			--SLHI
			if (instruction(18 downto 15) = "0001") then 
				shift_left_halfword_immediate(rs1, instruction(13 downto 10), rd_p);
				rd <= rd_p;
			
			-- AU
			elsif (instruction(18 downto 15) = "0010") then
				add_word_unsigned(unsigned(to_stdlogicvector(rs1)), unsigned(to_stdlogicvector(rs2)), rd_p);
				rd <= rd_p;
			
			--CNT1H
			elsif (instruction(18 downto 15) = "0011") then
				count_ones_in_halfwords(rs1, rd_p);
				rd <= rd_p;	 
				
			-- AHS
			elsif (instruction(18 downto 15) = "0100") then	
				add_halfword_saturated(signed(to_stdlogicvector(rs1)), signed(to_stdlogicvector(rs2)), rd_p);
				rd <= rd_p;
			
			--AND
			elsif (instruction(18 downto 15) = "0101") then
				logic_and(rs1, rs2, rd_p);
				rd <= rd_p;
			
			--BCW
			elsif (instruction(18 downto 15) = "0110") then	 
				broadcast_word(rs1, rd_p);
				rd <= rd_p;	
				
			--MAXWS
			elsif (instruction(18 downto 15) = "0111") then	 
				max_signed_word(signed(to_stdlogicvector(rs1)), signed(to_stdlogicvector(rs2)), rd_p);
				rd <= rd_p;
				
			--MINWS
			elsif (instruction(18 downto 15) = "1000") then	 
				min_signed_word(signed(to_stdlogicvector(rs1)), signed(to_stdlogicvector(rs2)), rd_p);
				rd <= rd_p;
				
			--MLHU
			elsif (instruction(18 downto 15) = "1001") then
				multiply_low_unsigned(unsigned(to_stdlogicvector(rs1)), unsigned(to_stdlogicvector(rs2)), rd_p);
				rd <= rd_p;	
			
			--MLHCU
			elsif (instruction(18 downto 15) = "1010") then	
				multiply_low_constant_unsigned(unsigned(to_stdlogicvector(rs1)), 
											   unsigned(to_stdlogicvector(instruction(14 downto 10))), rd_p);
				rd <= rd_p;
				
			--OR
			elsif (instruction(18 downto 15) = "1011") then
				logic_or(rs1, rs2, rd_p);
				rd <= rd_p;	
				
			--CLZH
			elsif (instruction(18 downto 15) = "1100") then
				count_leading_zeroes(rs1, rd_p);
				rd <= rd_p;	
			
			--RLH
			elsif (instruction(18 downto 15) = "1101") then
				rotate_left_bits(rs1, rs2, rd_p);
				rd <= rd_p;
				
			--SFWU
			elsif (instruction(18 downto 15) = "1110") then
				subtract_word_unsigned(unsigned(to_stdlogicvector(rs1)), unsigned(to_stdlogicvector(rs2)), rd_p);
				rd <= rd_p;
				
			--SFHS
			elsif (instruction(18 downto 15) = "1111") then
				subtract_halfword_saturated(signed(to_stdlogicvector(rs1)), signed(to_stdlogicvector(rs2)), rd_p);
				rd <= rd_p;	
			
			--NOP
			else
				null;
				
			end if;	  
			
		end if;
	end process;
			    

end behavioral;	 




