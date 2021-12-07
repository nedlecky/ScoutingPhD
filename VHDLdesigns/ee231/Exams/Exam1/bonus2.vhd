-- Exam 1 Bonus2

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity bonus2 is
	port
	(
		a		:  in integer range 0 to 31;
		sqrt	: out integer range 0 to 6
	);
end bonus2;

architecture arch of bonus2 is
begin
	with a select
		sqrt <=	0	when	0,
				1	when	1|2,
				2	when	3|4|5|6,
				3	when	7|8|9|10|11|12,
				4	when	13|14|15|16|17|18|19|20,
				6	when	31,
				5 when others;
end arch;
