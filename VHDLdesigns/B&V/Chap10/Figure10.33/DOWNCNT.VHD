LIBRARY ieee ;
USE ieee.std_logic_1164.ALL ;

ENTITY downcnt IS
	GENERIC	( initial_count : INTEGER := 16 ) ;
	PORT	(	Clock, E, L	: IN		STD_LOGIC ;
				Q			: BUFFER 	INTEGER RANGE 0 TO initial_count-1 ) ;
END downcnt ;

ARCHITECTURE Behavior OF downcnt IS
BEGIN
	PROCESS
	BEGIN
		WAIT UNTIL (Clock'EVENT AND Clock = '1') ;
		IF E = '1' THEN
			IF L = '1' THEN
				Q <= initial_count-1 ;
			ELSE
				Q <= Q - 1 ;
			END IF ;
		END IF ;
	END PROCESS;
END Behavior ;

