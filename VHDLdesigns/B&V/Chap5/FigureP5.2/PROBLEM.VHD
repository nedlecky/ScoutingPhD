LIBRARY ieee ; 
USE ieee.std_logic_1164.all ; 

ENTITY problem IS
	PORT ( 	Input 	: IN 	STD_LOGIC_VECTOR(3 DOWNTO 0) ;
			Output 	: OUT 	STD_LOGIC_VECTOR(3 DOWNTO 0) ) ;
END problem ;

ARCHITECTURE LogicFunc OF problem IS
BEGIN
	WITH Input SELECT
		Output <=	"0001" WHEN "0101",
					"0010" WHEN "0110",
					"0011" WHEN "0111",
					"0010" WHEN "1001",
					"0100" WHEN "1010",
					"0110" WHEN "1011",
					"0011" WHEN "1101",
					"0110" WHEN "1110",
					"1001" WHEN "1111",
					"0000" WHEN OTHERS ;
END LogicFunc ;
