-- Exam 1 Problem 4

library ieee;
use ieee.std_logic_1164.all;

entity prob4 is
	port
	(
		a,b		:  in std_logic_vector(1 downto 0);
		s		: out std_logic_vector(4 downto 0)
	);
end prob4;

architecture arch of prob4 is
	signal c0 : std_logic;
begin
	s(0) <= a(0) xor b(0);
	c0 <= a(0) and b(0);
	s(1) <= c0 xor a(1) xor b(1);
	s(2) <= (c0 and a(1)) or (c0 and b(1)) or (a(1) and b(1));
	s(3) <= '0';
	s(4) <= '0';
end arch;
