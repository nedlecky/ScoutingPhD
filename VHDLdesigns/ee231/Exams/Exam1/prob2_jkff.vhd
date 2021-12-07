-- Exam 1 Problem 2A: JKFF; Uses DFF

library ieee;
use ieee.std_logic_1164.all;

entity prob2_jkff is
	port
	(
		j,k,clk	:	in	std_logic;
		q,qbar	:	out	std_logic
	);
end prob2_jkff;

architecture arch of prob2_jkff is
	component prob2_dff is
		port
		(
			d,clk	:	in	std_logic;
			q,qbar	:	out	std_logic
		);
	end component;
	signal d,qff,qbarff:	std_logic;
begin
	d <= (j and qbarff) or (not k and qff);
	ff1: prob2_dff port map (d,clk,qff,qbarff);
	q <= qff;
	qbar <= qbarff;
end arch;
