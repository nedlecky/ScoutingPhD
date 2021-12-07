LIBRARY ieee ;
USE ieee.std_logic_1164.all ;

ENTITY shiftn IS
	GENERIC ( N : INTEGER := 8 ) ;
	PORT (	R 		: IN 		STD_LOGIC_VECTOR(N-1 DOWNTO 0) ;
			Clock 	: IN 		STD_LOGIC ;
			L, w 	: IN 		STD_LOGIC ;
			Q 		: BUFFER 	STD_LOGIC_VECTOR(N-1 DOWNTO 0) ) ;
END shiftn ;

ARCHITECTURE Behavior OF shiftn IS	
BEGIN
	PROCESS
	BEGIN
		WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		IF L = '1' THEN
			Q <= R ;
		ELSE
			Genbits: FOR i IN 0 TO N-2 LOOP
				Q(i) <= Q(i+1) ;
			END LOOP ;
			Q(N-1) <= w ;
		END IF ;
	END PROCESS ;
END Behavior ;
