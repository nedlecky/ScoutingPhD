-- Classic Full Adder

-- University of Vermont
-- EE 231: Digital Computer Design I Spring 2002
-- Dr. Ned Lecky

library ieee;
use ieee.std_logic_1164.all;

entity fa is
	port
	(
		x,y,cin	: in	std_logic;
		s,cout	: out	std_logic
	);
	
end fa;

architecture arch of fa is
begin
	s <= x xor y xor cin;
	cout <= (x and y) or (x and cin) or (y and cin);
end arch;

