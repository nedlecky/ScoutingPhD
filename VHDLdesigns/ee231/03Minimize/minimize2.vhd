-- 03Minimize Example
-- See how MP2 does with Don't Cares
-- Answer; not well!
-- See Fig. 4.15 [B&V]

-- University of Vermont
-- EE 231: Digital Computer Design I Spring 2002
-- Dr. Ned Lecky

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY minimize2 is
	PORT
	(
		x			: IN	std_logic_vector(1 to 4);
		f1,f2,f3,f4	: OUT	std_logic
	);
END minimize2;

ARCHITECTURE arch OF minimize2 IS
BEGIN
	-- just define 1s
	WITH conv_integer(x) SELECT
		f1 <=	'1' WHEN	2|4|5|6|10,
				'0' WHEN others;
	-- define 1s and DCs
	WITH conv_integer(x) SELECT
		f2 <=	'1' WHEN	2|4|5|6|10,
				'-' WHEN	12|13|14|15,
				'0' WHEN others;
	-- define 1s and 0s
	WITH conv_integer(x) SELECT
		f3 <=	'1' WHEN	2|4|5|6|10,
				'0' WHEN	0|1|3|7|8|9|11,
				'-' WHEN others;
	-- explicitly decide what to do with DCs
	-- only this one actually minimizes properly!
	WITH conv_integer(x) SELECT
		f4 <=	'1' WHEN	2|4|5|6|10,
				'1' WHEN	12|13|14,
				'0' WHEN others;
END arch;

