-- Basic VHDL Template

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

LIBRARY lpm;
USE lpm.lpm_components.ALL;

ENTITY entname IS
	PORT
	(
		a	: IN	STD_LOGIC;
		f	: OUT	STD_LOGIC
	);
	
END entname;

ARCHITECTURE a OF entname IS
	SIGNAL s : std_logic;
BEGIN
	s <= a;
	f <= s;
END a;

