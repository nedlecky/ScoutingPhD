LIBRARY ieee ;
USE ieee.std_logic_1164.all ;

ENTITY implied IS
	PORT ( 	A, B 	: IN 	STD_LOGIC ;
			AeqB	: OUT 	STD_LOGIC ) ;
END implied ;

ARCHITECTURE Behavior OF implied IS	
BEGIN
	PROCESS ( A, B )
	BEGIN
		IF A = B THEN
			AeqB <= '1' ;
		END IF ;
	END PROCESS ;
END Behavior ;
