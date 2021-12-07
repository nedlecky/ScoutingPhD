-- Exam 1 Problem 3

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity prob3 is
	port
	(
		clk,reset	:	in	std_logic;
		q			:	out	integer range 0 to 15
	);
end prob3;

architecture arch of prob3 is
	signal qint : integer range 0 to 15;
begin
	process(clk,reset)
	begin
		if reset='1' then
			qint <= 7;
		elsif rising_edge(clk) then
			case qint is
				when 0 => qint <= 1;
				when 1 => qint <= 2;
				when 2 => qint <= 3;
				when 3 => qint <= 5;
				when 5 => qint <= 7;
				when 7 => qint <= 11;
				when 11 => qint <= 13;
				when 13 => qint <= 0;
				when others => qint <= 0;
			end case;
		end if;
		q <= qint;
	end process;
end arch;
