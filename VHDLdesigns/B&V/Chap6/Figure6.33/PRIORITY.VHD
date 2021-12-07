LIBRARY ieee ;
USE ieee.std_logic_1164.all ;

ENTITY priority IS
	PORT (	w	: IN 	STD_LOGIC_VECTOR(3 DOWNTO 0) ;
			y	: OUT 	STD_LOGIC_VECTOR(1 DOWNTO 0) ;
			z	: OUT 	STD_LOGIC ) ;
END priority ;

ARCHITECTURE Behavior OF priority IS
BEGIN
	WITH w SELECT
		y <=	"00" WHEN "0001",
				"01" WHEN "0010",
				"01" WHEN "0011",
				"10" WHEN "0100",
				"10" WHEN "0101",
				"10" WHEN "0110",
				"10" WHEN "0111",
				"11" WHEN OTHERS ;
	WITH w SELECT
		z <=	'0' WHEN "0000",
				'1' WHEN OTHERS ;
END Behavior ;
