-- Test Function to train
-- Dr. Ned Lecky

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY targetfunc3 IS
	PORT
	(
		x				: IN	std_logic_vector(4 downto 0);
		y				: OUT	std_logic
	);
	
END targetfunc3 ;

ARCHITECTURE a OF targetfunc3 IS
begin
	y <= 	'0';
--			(not x(0) and x(1) and x(2))
--			or (x(1) and not x(3) and x(4))
--			or (not x(1) and x(2) and not x(3) and x(4))
--			or (x(0) and not x(1) and x(4));
--			or (x(0) and x(1) and x(2) and x(3) and x(4));
end a;
