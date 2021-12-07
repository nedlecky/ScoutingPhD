-- 32-bit VHDL Adder
-- University of Vermont
-- EE 231: Digital Computer Design I Spring 2002
-- Dr. Ned Lecky

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity VHDLadd32 is
	port
	(
		x,y		: in	std_logic_vector(31 downto 0);
		cin		: in	std_logic;
		s		: out	std_logic_vector(31 downto 0);
		cout	: out	std_logic
	);
end VHDLadd32;

architecture arch of VHDLadd32 is
	signal s33:	std_logic_vector(32 downto 0);
begin
	s33 <= x + y + cin;
	s <= s33(31 downto 0);
	cout <= s33(32);
end arch;

