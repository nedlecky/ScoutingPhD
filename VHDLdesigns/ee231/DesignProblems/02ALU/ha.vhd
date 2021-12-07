-- Classic Half Adder

-- University of Vermont
-- EE 231: Digital Computer Design I Spring 2002
-- Dr. Ned Lecky

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY ha IS
	PORT
	(
		x,y	: IN	STD_LOGIC;
		s,c	: OUT	STD_LOGIC
	);
	
END ha;

ARCHITECTURE arch OF ha IS
BEGIN
	s <= x xor y;
	c <= x and y;
END arch;

