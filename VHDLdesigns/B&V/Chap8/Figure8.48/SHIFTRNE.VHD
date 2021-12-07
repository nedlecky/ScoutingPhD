LIBRARY ieee ;
USE ieee.std_logic_1164.all ;

-- left-to-right shift register with parallel load and enable
ENTITY shiftrne IS
	GENERIC ( N : INTEGER := 4 ) ;
	PORT ( 	R 		: IN 		STD_LOGIC_VECTOR(N-1 DOWNTO 0) ;
			L, E, w : IN 		STD_LOGIC ;
			Clock 	: IN 		STD_LOGIC ;
			Q 		: BUFFER 	STD_LOGIC_VECTOR(N-1 DOWNTO 0) ) ;
END shiftrne ;

ARCHITECTURE Behavior OF shiftrne IS	
BEGIN
	PROCESS
	BEGIN
		WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		IF E = '1' THEN
			IF L = '1' THEN
				Q <= R ;
			ELSE
				Genbits: FOR i IN 0 TO N-2 LOOP
					Q(i) <= Q(i+1) ;
				END LOOP ;
				Q(N-1) <= w ;
			END IF ;
		END IF ;
	END PROCESS ;
END Behavior ;
