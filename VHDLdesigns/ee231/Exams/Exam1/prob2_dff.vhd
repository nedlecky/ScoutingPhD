-- Exam 1 Problem 2A: DFF

library ieee;
use ieee.std_logic_1164.all;

entity prob2_dff is
	port
	(
		d,clk	:	in	std_logic;
		q,qbar	:	out	std_logic
	);
end prob2_dff;

architecture arch of prob2_dff is
	signal qint : std_logic;
begin
	process(clk)
	begin
		if rising_edge(clk) then
			qint <= d;
		end if;
		q <= qint;
		qbar <= not qint;
	end process;
end arch;
