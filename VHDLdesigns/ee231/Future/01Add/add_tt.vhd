-- PairAdd from Truth Table
-- Truth Tables and VHDL code portions generated automatically
-- Dr. Ned Lecky

LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

ENTITY add_tt IS
	PORT
	(
		a,b,cin		: IN	STD_LOGIC;
		co,s		: OUT	STD_LOGIC
	);
	
END add_tt;

ARCHITECTURE a OF add_tt IS
	SIGNAL composite : std_logic_vector(2 downto 0);
BEGIN
	composite <= a & b & cin;
	with conv_integer(composite)select
        co <= '1' when 3|5|6|7,
        '0' when others;

	with conv_integer(composite)select
        s <= '1' when 1|2|4|7,
        '0' when others;

END a;


