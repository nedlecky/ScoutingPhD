-- MIPS Execute Module  (Data ALU and Branch Address Adder)
-- 16-bit Version
-- Enhanced from Hamblen&Furman Rapid Prototyping of Digital Systems

-- Dr. John E. Lecky
-- EE231 Digital Computer Design 1
-- University of Vermont

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

entity  execute is
	port
	(
		read_data_1 	: in 	std_logic_vector(15 downto 0);
		read_data_2 	: in 	std_logic_vector(15 downto 0);
		sign_extend 	: in 	std_logic_vector(15 downto 0);
		function_opcode : in 	std_logic_vector(5 downto 0);
		r_format		: in	std_logic;
		branch			: in	std_logic;
		alusrc 			: in 	std_logic;
		zero 			: out	std_logic;
		alu_result 		: out	std_logic_vector(15 downto 0);
		add_result 		: out	std_logic_vector(7 downto 0);
		pc_plus_4 		: in 	std_logic_vector(7 downto 0)
	);
end execute;

architecture behavior of execute is
	type   alu_code is (alu_and,alu_or,alu_add,alu_sub,alu_sll,alu_srl,alu_slt);
	signal alu_ctl				: alu_code;
	signal ainput, binput 		: std_logic_vector(15 downto 0);
	signal alu_output_mux		: std_logic_vector(15 downto 0);
	signal branch_add 			: std_logic_vector(8 downto 0);
begin
	-- alu input mux
	ainput <= read_data_1;
	binput <=	read_data_2 when (alusrc = '0') 
		else	sign_extend;

	-- combinational logic to generate alu control bits
	process(function_opcode,r_format,branch)
	begin
		if r_format='1' then
			case conv_integer(function_opcode) is
				when 32|33	=> alu_ctl <= alu_add;
				when 34|35	=> alu_ctl <= alu_sub;
				when 36		=> alu_ctl <= alu_and;
				when 37		=> alu_ctl <= alu_or;
				when 0		=> alu_ctl <= alu_sll;
				when 2		=> alu_ctl <= alu_srl;
				when 42		=> alu_ctl <= alu_slt;
				when others => alu_ctl <= alu_add;
			end case;
		else
			if branch='1' then
				-- branch instructions use alu MINUS to compare
				alu_ctl <= alu_sub;
			else
				-- not r_format, not branch
				alu_ctl <= alu_add;
			end if;
		end if;
	end process;
	-- the old, scary way
	--alu_ctl(0) <= (function_opcode(0) or function_opcode(3)) and r_format;
	--alu_ctl(1) <= (not function_opcode(2)) or (not r_format);
	--alu_ctl(2) <= (function_opcode(1) and r_format) or branch;

	-- adder to compute branch address
	branch_add	<= pc_plus_4(7 downto 2) + sign_extend(7 downto 0);
	add_result 	<= branch_add(7 downto 0);

	-- the ALU itself
	process (alu_ctl, ainput, binput)
		begin
 		case alu_ctl is
			when alu_and 				=>	alu_output_mux 	<= ainput and binput; 
	   	  	when alu_or 				=>	alu_output_mux 	<= ainput or binput;
		 	when alu_add 				=>	alu_output_mux 	<= ainput + binput;
 		 	when alu_sub|alu_slt	 	=>	alu_output_mux 	<= ainput - binput;
			when alu_sll				=>  alu_output_mux  <= ainput(14 downto 0) & '0'; -- only shifts 1
			when alu_srl				=>  alu_output_mux  <= '0' & ainput(15 downto 1); -- only shifts 1
 		 	when others					=>	alu_output_mux 	<= x"0000" ;
  		end case;
	end process;

	-- select alu output- implements set if less than        
	alu_result <= x"000" & "000"  & alu_output_mux(alu_output_mux'high) when  alu_ctl = alu_slt 
				else alu_output_mux;

	-- generate zero flag
	zero <= 	'1' when (alu_output_mux=0)
				else '0';    
end behavior;

