-- 03Minimize Example
-- See how MP2 does at 5-variable minimization
-- See Fig. 4.8 [B&V]

-- University of Vermont
-- EE 231: Digital Computer Design I Spring 2002
-- Dr. Ned Lecky

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY minimize1 is
	PORT
	(
		x		: IN	std_logic_vector(1 to 5);
		f1		: OUT	std_logic
	);
END minimize1;

ARCHITECTURE arch OF minimize1 IS
BEGIN
	WITH conv_integer(x) SELECT
		f1 <=	'1' WHEN	4|5|6|7|12|13|14|15|17|18|19|26|27,
				'0' WHEN others;
END arch;

