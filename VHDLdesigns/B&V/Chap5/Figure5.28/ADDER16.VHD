LIBRARY ieee ;
USE ieee.std_logic_1164.all ;
USE ieee.std_logic_signed.all ;

ENTITY adder16 IS
	PORT ( 	X, Y 	: IN 	STD_LOGIC_VECTOR(15 DOWNTO 0) ;
			S 		: OUT 	STD_LOGIC_VECTOR(15 DOWNTO 0) ) ;
END adder16 ;

ARCHITECTURE Behavior OF adder16 IS    
BEGIN
	S <= X + Y ;
END Behavior ;
