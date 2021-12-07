LIBRARY ieee ;
USE ieee.std_logic_1164.ALL ;

ENTITY upcount IS
	GENERIC	(	modulus : INTEGER := 4 ) ;
	PORT	(	Resetn, Clock, E, L		: IN		STD_LOGIC ;
				R						: IN		INTEGER RANGE 0 TO modulus-1 ;
				Q						: BUFFER 	INTEGER RANGE 0 TO modulus-1 ) ;
END upcount ;

ARCHITECTURE Behavior OF upcount IS
BEGIN
upcount: PROCESS ( Resetn, Clock, L, E )
	BEGIN
		IF Resetn = '0' THEN
			Q <= 0 ;
		ELSIF (Clock'EVENT AND Clock = '1') THEN
			IF E = '1' THEN
				IF L = '1' THEN
					Q <= R ;
				ELSE
					Q <= Q + 1 ;
				END IF ;
			END IF ;
		END IF;
	END PROCESS;
END Behavior ;

