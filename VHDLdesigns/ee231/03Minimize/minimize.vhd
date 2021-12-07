-- 03Minimize Example
-- See how MP2 does at 5-variable minimization
-- See Fig. 4.8 [B&V]

-- University of Vermont
-- EE 231: Digital Computer Design I Spring 2002
-- Dr. Ned Lecky

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY minimize is
	PORT
	(
		x		: IN	std_logic_vector(1 to 5);
		f1		: OUT	std_logic
	);
END minimize;

ARCHITECTURE arch OF minimize IS
BEGIN
	WITH conv_integer(x) SELECT
		f1 <=	'1' WHEN	27|18|13|4|5|6|7|12|14|15|17|19|26,
				'0' WHEN others;
END arch;

