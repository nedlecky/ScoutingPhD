-- straight-on 4 bit adder

LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

ENTITY quadadd_vhdlop IS

	PORT
	(
		a,b		: IN	std_logic_vector(3 downto 0);
		cin		: IN	std_logic;
		s		: OUT	std_logic_vector(3 downto 0);
		cout	: OUT	std_logic
	);
	
END quadadd_vhdlop ;

ARCHITECTURE a OF quadadd_vhdlop IS
	SIGNAL	fullsum : std_logic_vector(4 downto 0);
BEGIN
	fullsum <= a+b+cin;
	s <= fullsum(3 downto 0);
	cout <= fullsum(4);
END a;

