-- Classic Full Adder

-- University of Vermont
-- EE 231: Digital Computer Design I Spring 2002
-- Dr. Ned Lecky

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY fa IS
	PORT
	(
		x,y,cin	: IN	STD_LOGIC;
		s,cout	: OUT	STD_LOGIC
	);
	
END fa;

ARCHITECTURE arch OF fa IS
BEGIN
	s <= x xor y xor cin;
	cout <= (x and y) or (x and cin) or (y and cin);
END arch;

