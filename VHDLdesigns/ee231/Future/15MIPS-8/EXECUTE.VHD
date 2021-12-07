-- MIPS Execute Module  (Data ALU and Branch Address Adder)
-- 8-bit Version
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
		read_data_1 	: in 	std_logic_vector(7 downto 0);
		read_data_2 	: in 	std_logic_vector(7 downto 0);
		sign_extend 	: in 	std_logic_vector(7 downto 0);
		function_opcode : in 	std_logic_vector(5 downto 0);
		aluop 			: in 	std_logic_vector(1 downto 0);
		alusrc 			: in 	std_logic;
		zero 			: out	std_logic;
		alu_result 		: out	std_logic_vector(7 downto 0);
		add_result 		: out	std_logic_vector(7 downto 0);
		pc_plus_4 		: in 	std_logic_vector(7 downto 0)
	);
end execute;

architecture behavior of execute is
	signal ainput, binput 		: std_logic_vector(7 downto 0);
	signal alu_output_mux		: std_logic_vector(7 downto 0);
	signal branch_add 			: std_logic_vector(8 downto 0);
	signal alu_ctl				: std_logic_vector(2 downto 0);
begin
	-- alu input mux
	ainput <= read_data_1;
	binput <=	read_data_2 when (alusrc = '0') 
		else	sign_extend(7 downto 0);

	-- generate alu control bits
	alu_ctl(0) <= (function_opcode(0) or function_opcode(3)) and aluop(1);
	alu_ctl(1) <= (not function_opcode(2)) or (not aluop(1));
	alu_ctl(2) <= (function_opcode(1) and aluop(1)) or aluop(0);

	-- generate zero flag
	zero <= 	'1' when (alu_output_mux=0)
				else '0';    
						-- select alu output        
	alu_result <= "0000000"  & alu_output_mux(alu_output_mux'high) when  alu_ctl = "111" 
				else alu_output_mux;

	-- adder to compute branch address
	branch_add	<= pc_plus_4(7 downto 2) + sign_extend;
	add_result 	<= branch_add(7 downto 0);

	-- the ALU itself
	process (alu_ctl, ainput, binput)
		begin
 		case alu_ctl is
			when "000" 	=>	alu_output_mux 	<= ainput and binput; 
	   	  	when "001" 	=>	alu_output_mux 	<= ainput or binput;
		 	when "010" 	=>	alu_output_mux 	<= ainput + binput;
 		 	when "011" 	=>	alu_output_mux 	<= ainput - binput;
 		 	when "100" 	=>	alu_output_mux 	<= "00000000";
 		 	when "101" 	=>	alu_output_mux 	<= "00000000";
 		 	when "110" 	=>	alu_output_mux 	<= ainput - binput;
  		 	when "111" 	=>	alu_output_mux 	<= "00000000" ;
 		 	when others	=>	alu_output_mux 	<= "00000000" ;
  		end case;
	end process;
end behavior;

