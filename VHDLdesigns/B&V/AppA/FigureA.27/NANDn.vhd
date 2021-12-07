LIBRARY ieee ; 
USE ieee.std_logic_1164.all ; 

ENTITY NANDn IS
	GENERIC ( n : INTEGER := 4 ) ;
	PORT (	X 	: IN 	STD_LOGIC_VECTOR(1 TO n) ;
			f	: OUT 	STD_LOGIC ) ;
END NANDn ;

ARCHITECTURE Behavior OF NANDn IS
	SIGNAL Tmp : STD_LOGIC ;
BEGIN
	PROCESS ( X )
	BEGIN
		Tmp <= X(1) ;
		AND_bits: FOR i IN 2 TO n LOOP
			Tmp <= Tmp AND X(i) ;
		END LOOP AND_bits ;
		f <= NOT Tmp ;
	END PROCESS ;
END Behavior ;
