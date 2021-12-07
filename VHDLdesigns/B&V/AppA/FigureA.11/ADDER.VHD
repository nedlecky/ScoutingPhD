LIBRARY ieee ;
USE ieee.std_logic_1164.all ;
USE ieee.std_logic_signed.all ;

ENTITY adder IS
	PORT ( 	Cin 	: IN 	STD_LOGIC ;
			X, Y	: IN 	STD_LOGIC_VECTOR(3 DOWNTO 0) ;
			S 		: OUT 	STD_LOGIC_VECTOR(3 DOWNTO 0) ;
			Cout 	: OUT 	STD_LOGIC ) ;
END adder ;

ARCHITECTURE Behavior OF adder IS	
	SIGNAL Sum : STD_LOGIC_VECTOR(4 DOWNTO 0) ;
BEGIN
	Sum <= ('0' & X) + Y + Cin ;
	S <= Sum(3 DOWNTO 0) ;
	Cout <= Sum(4) ;
END Behavior ;
