-- 8-bit CLA Adder

-- University of Vermont
-- EE 231: Digital Computer Design I Spring 2002
-- Dr. Ned Lecky

library ieee;
use ieee.std_logic_1164.all;

entity CLA8 is
	port
	(
		x,y		: in	std_logic_vector(7 downto 0);
		cin		: in	std_logic;
		s		: out	std_logic_vector(7 downto 0);
		cout	: out	std_logic
	);
end CLA8;

architecture arch of CLA8 is
	signal c : std_logic_vector(8 downto 0);
	signal p : std_logic_vector(7 downto 0);
	signal g : std_logic_vector(7 downto 0);
begin

	-- p and g functions
	PGgen: for i in 0 to 7 generate
		p(i) <= x(i) or y(i) or c(i);
		g(i) <= x(i) and y(i);
	end generate;

	-- c bits
	c(0) <= cin;	-- carry in hookup
	c(1) <=	g(0) or
			(p(0) and c(0));
	c(2) <=	g(1) or
			(p(1) and g(0)) or
			(p(1) and p(0) and c(0));
	c(3) <=	g(2) or
			(p(2) and g(1)) or
			(p(2) and p(1) and g(0)) or
			(p(2) and p(1) and p(0) and c(0));
	c(4) <=	g(3) or
			(p(3) and g(2)) or
			(p(3) and p(2) and g(1)) or
			(p(3) and p(2) and p(1) and g(0)) or
			(p(3) and p(2) and p(1) and p(0) and c(0));
	c(5) <=	g(4) or
			(p(4) and g(3)) or
			(p(4) and p(3) and g(2)) or
			(p(4) and p(3) and p(2) and g(1)) or
			(p(4) and p(3) and p(2) and p(1) and g(0)) or
			(p(4) and p(3) and p(2) and p(1) and p(0) and c(0));
	c(6) <=	g(5) or
			(p(5) and g(4)) or
			(p(5) and p(4) and g(3)) or
			(p(5) and p(4) and p(3) and g(2)) or
			(p(5) and p(4) and p(3) and p(2) and g(1)) or
			(p(5) and p(4) and p(3) and p(2) and p(1) and g(0)) or
			(p(5) and p(4) and p(3) and p(2) and p(1) and p(0) and c(0));
	c(7) <=	g(6) or
			(p(6) and g(5)) or
			(p(6) and p(5) and g(4)) or
			(p(6) and p(5) and p(4) and g(3)) or
			(p(6) and p(5) and p(4) and p(3) and g(2)) or
			(p(6) and p(5) and p(4) and p(3) and p(2) and g(1)) or
			(p(6) and p(5) and p(4) and p(3) and p(2) and p(1) and g(0)) or
			(p(6) and p(5) and p(4) and p(3) and p(2) and p(1) and p(0) and c(0));
	c(8) <=	g(7) or
			(p(7) and g(6)) or
			(p(7) and p(6) and g(5)) or
			(p(7) and p(6) and p(5) and g(4)) or
			(p(7) and p(6) and p(5) and p(4) and g(3)) or
			(p(7) and p(6) and p(5) and p(4) and p(3) and g(2)) or
			(p(7) and p(6) and p(5) and p(4) and p(3) and p(2) and g(1)) or
			(p(7) and p(6) and p(5) and p(4) and p(3) and p(2) and p(1) and g(0)) or
			(p(7) and p(6) and p(5) and p(4) and p(3) and p(2) and p(1) and p(0) and c(0));
	cout <= c(8);	-- carry out hookup

	-- s bits
	Sgen: for i in 0 to 7 generate
		s(i) <= x(i) xor y(i) xor c(i);
	end generate;
end arch;

