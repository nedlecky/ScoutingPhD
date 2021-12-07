-- 04Decomptest Example
-- Is the XOR implementation correct?
-- It may be superior!

-- University of Vermont
-- EE 231: Digital Computer Design I Spring 2002
-- Dr. Ned Lecky

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY decomptest is
	PORT
	(
		x1,x2,x3,x4,x5		: IN	STD_LOGIC;
		f,g					: OUT	STD_LOGIC
	);
END decomptest;

ARCHITECTURE arch OF decomptest IS
	signal concat: std_logic_vector(4 downto 0);
BEGIN
	concat <= x1 & x2 & x3 & x4 & x5;

	-- Right from Fig. 4.28
	WITH concat SELECT
		f <=	'0' WHEN	"01000"|
							"11000"|
							"10000"|
							"00010"|
							"01110"|
							"11110"|
							"10110"|
							"00100"|
							"00001"|
							"01001"|
							"11001"|
							"10001"|
							"00111"|
							"01111"|
							"11111"|
							"10111",
				'1' WHEN others;

	-- My XOR decomposition
	g <= (x3 xor x4) xor ((not x1) and (not x2) and (not x5));
END arch;

