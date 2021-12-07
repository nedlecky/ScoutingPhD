-- Exam 1 Problem 1

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity prob1 is
	port
	(
		x1,x2,x3	:	in	std_logic;
		f1,f2,f3	:	out	std_logic
	);
end prob1;

architecture arch of prob1 is
	signal x123 : std_logic_vector(2 downto 0);
begin
	f1 <= (not x2 and x3) or (not x3 and x1);

	f2 <= (x1 or x3) and (not x3 or not x2);

	x123 <= x1 & x2 & x3;

	with conv_integer(x123) select
		f3 <=	'1' when 1|4|5|6,
				'0' when others;
end arch;
