-- pairadd_vhdl.vhd
-- PairAdd using VHDL '+' operator
-- Dr. Ned Lecky

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity pairadd_vhdl IS
	port
	(
		a,b			: in	std_logic_vector(1 downto 0);
		c			: in	std_logic;
		s			: out	std_logic_vector(2 downto 0)
	);
	
end pairadd_vhdl;

architecture a of pairadd_vhdl is
begin
	s <= a + b + c;
end a;

