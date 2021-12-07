-- Test Function to train
-- Dr. Ned Lecky

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY targetfunc IS
	PORT
	(
		x				: IN	std_logic_vector(4 downto 0);
		y				: OUT	std_logic
	);
	
END targetfunc ;

ARCHITECTURE a OF targetfunc IS
begin
	y <= (x(0) and not x(1)) or (x(2) and x(4) and x(1));-- or (x(3));-- and x(0));
end a;
