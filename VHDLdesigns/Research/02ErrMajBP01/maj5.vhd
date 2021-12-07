-- 5-input Majority Gate
-- Dr. Ned Lecky

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY maj5 IS
	PORT
	(
		x1,x2,x3,x4,x5	: in	std_logic;
		y				: out	std_logic
	);
	
END maj5;

ARCHITECTURE a OF maj5 IS
	signal inputs : std_logic_vector(4 downto 0);
BEGIN
	inputs <= x1&x2&x3&x4&x5;
	with conv_integer(inputs) select
        y <=	'0' when 0|1|2|3|4|5|6|8|9|10|12|16|17|18|20|24,
				'1' when others;
end a;

