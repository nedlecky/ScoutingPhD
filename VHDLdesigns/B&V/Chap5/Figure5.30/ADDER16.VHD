LIBRARY ieee ;
USE ieee.std_logic_1164.all ;
USE ieee.std_logic_arith.all ;

ENTITY adder16 IS
	PORT (	Cin 			: IN 	STD_LOGIC ;
			X, Y 			: IN 	SIGNED(15 DOWNTO 0) ;
			S 				: OUT 	SIGNED(15 DOWNTO 0) ;
			Cout, Overflow 	: OUT 	STD_LOGIC ) ;
END adder16 ;

ARCHITECTURE Behavior OF adder16 IS    
	SIGNAL Sum : SIGNED(16 DOWNTO 0) ;
BEGIN
	Sum <= ('0' & X) + Y + Cin ;
	S <= Sum(15 DOWNTO 0) ;
	Cout <= Sum(16) ;
	Overflow <= Sum(16) XOR X(15) XOR Y(15) XOR Sum(15) ;
END Behavior ;
