LIBRARY ieee ;
USE ieee.std_logic_1164.all ;

ENTITY rege IS
	PORT (	R, Resetn, E, Clock	: IN 		STD_LOGIC ;
			Q 					: BUFFER 	STD_LOGIC ) ;
END rege ;

ARCHITECTURE Behavior OF rege IS	
BEGIN
	PROCESS ( Resetn, Clock )
	BEGIN
		IF Resetn = '0' THEN
			Q <= '0' ;
		ELSIF Clock'EVENT AND Clock = '1' THEN
			IF E = '1' THEN
				Q <= R ;
			ELSE
				Q <= Q ;
			END IF ;
		END IF ;
	END PROCESS ;
END Behavior ;
