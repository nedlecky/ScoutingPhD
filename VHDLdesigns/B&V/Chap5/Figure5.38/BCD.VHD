LIBRARY ieee ;
USE ieee.std_logic_1164.all ;
USE ieee.std_logic_unsigned.all ;

ENTITY BCD IS
	PORT (	X, Y 	: IN 	STD_LOGIC_VECTOR(3 DOWNTO 0) ;
			S 		: OUT 	STD_LOGIC_VECTOR(4 DOWNTO 0) ) ;
END BCD ;

ARCHITECTURE Behavior OF BCD IS
	SIGNAL Z : STD_LOGIC_VECTOR(4 DOWNTO 0) ;
	SIGNAL Adjust : STD_LOGIC ;
BEGIN
	Z <= ('0' & X) + Y ;
	Adjust <= '1' WHEN Z > 9 ELSE '0' ;
	S <= Z WHEN (Adjust = '0') ELSE Z + 6 ;
END Behavior ;
