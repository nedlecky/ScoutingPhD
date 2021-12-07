LIBRARY ieee ; 
USE ieee.std_logic_1164.all ; 

ENTITY NANDn IS
	GENERIC ( n : INTEGER := 4 ) ;
	PORT (	X 	: IN 	STD_LOGIC_VECTOR(1 TO n) ;
			f	: OUT 	STD_LOGIC ) ;
END NANDn ;

ARCHITECTURE Behavior OF NANDn IS
	SIGNAL Tmp : STD_LOGIC_VECTOR(1 TO n) ;
BEGIN
	Tmp <= (OTHERS => '1') ;
	f <= '0' WHEN X = Tmp ELSE '1' ;
END Behavior ;
