-- 8-bit VHDL Adder
-- University of Vermont
-- EE 231: Digital Computer Design I Spring 2002
-- Dr. Ned Lecky

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity VHDLadd8 is
	port
	(
		x,y		: in	std_logic_vector(7 downto 0);
		cin		: in	std_logic;
		s		: out	std_logic_vector(7 downto 0);
		cout	: out	std_logic
	);
end VHDLadd8;

architecture arch of VHDLadd8 is
	signal s9:	std_logic_vector(8 downto 0);
begin
	s9 <= x + y + cin;
	s <= s9(7 downto 0);
	cout <= s9(8);
end arch;

