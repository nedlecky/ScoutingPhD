-- n-bit VHDL Adder
-- Just let the VHDL '+' operator synthesize
-- What gets synthesized?  The LPM module!

-- University of Vermont
-- EE 231: Digital Computer Design I Spring 2002
-- Dr. Ned Lecky

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

-- NOTE: You must use std_logic_unsigned or signed here.
-- VHDL will interpret your std_logic_vectors accordingly

ENTITY addervhdl IS
	GENERIC
	(
		width : integer := 16
	);
	PORT
	(
		x,y	: IN	STD_LOGIC_VECTOR(width-1 downto 0);
		s	: OUT	STD_LOGIC_VECTOR(width downto 0)
	);
END addervhdl;

ARCHITECTURE a OF addervhdl IS
BEGIN
	s <= x + y;
END a;

