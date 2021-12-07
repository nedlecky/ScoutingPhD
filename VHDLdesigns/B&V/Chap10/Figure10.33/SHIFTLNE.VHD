LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY shiftlne IS  -- right-to-left shift register w. parallel load and enable
	GENERIC ( N : INTEGER := 4 ) ;
	PORT(	R				: IN		STD_LOGIC_VECTOR(N-1 DOWNTO 0) ;
			L, E, w, Clock	: IN		STD_LOGIC ;
			Q		  		: BUFFER	STD_LOGIC_VECTOR(N-1 DOWNTO 0) ) ;
END shiftlne ;

ARCHITECTURE Behavior OF shiftlne IS	
BEGIN
	PROCESS
   	BEGIN
		WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		IF E = '1' THEN
			IF L = '1' THEN
				Q <= R ;
			ELSE
				Q(0) <= w ;
				Genbits: FOR i IN 1 TO N-1 LOOP
					Q(i) <= Q(i-1) ;
				END LOOP ;
			END IF ;
		END IF ;
	END PROCESS ;
END Behavior ;


