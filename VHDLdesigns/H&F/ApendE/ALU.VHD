library IEEE;
use  IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all,IEEE.STD_LOGIC_UNSIGNED.all;

entity ALU is
   port( 	ALU_control		: in std_logic_vector(2 downto 0);
			Ainput, Binput	: in std_logic_vector(15 downto 0);
			Clock			: in std_logic;
			Shift_output 	: out std_logic_vector(15 downto 0));
end ALU;

architecture RTL of ALU is
signal ALU_output: std_logic_vector(15 downto 0);
begin
	process (ALU_Control, Ainput, Binput)
	begin
		case ALU_Control(2 downto 1) is
			when "00" => ALU_output <= Ainput + Binput;
			when "01" => ALU_output <= Ainput - Binput;
			when "10" => ALU_output <= Ainput and Binput;
			when "11" => ALU_output <= Ainput or Binput;
			when others => ALU_output <= "0000000000000000";
		end case;
	end process;
  	process
	begin
	 	wait until rising_edge(Clock);
	 	if ALU_control(0) = '1' then
			Shift_output <= ALU_output(14 downto 0) & "0";
	 	else 
			Shift_output <= ALU_output;
	 	end if;
  	end process;
end RTL;

