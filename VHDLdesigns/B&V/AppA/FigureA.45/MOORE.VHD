LIBRARY ieee ; 
USE ieee.std_logic_1164.all ; 

ENTITY moore IS 
	PORT ( 	Clock 	: IN 	STD_LOGIC ;
			w 		: IN 	STD_LOGIC ; 
			Resetn 	: IN 	STD_LOGIC ;
			z 		: OUT 	STD_LOGIC ) ;
END moore ;

ARCHITECTURE Behavior OF moore IS
	TYPE State_type IS (A, B, C) ;
	SIGNAL y : State_type ;
BEGIN
	PROCESS ( Resetn, Clock )
	BEGIN
		IF Resetn = '0' THEN
			 y <= A ;
		ELSIF (Clock'EVENT AND Clock = '1') THEN
			CASE y IS
				WHEN A =>
					IF w = '0' THEN
						y <= A ;
					ELSE
						y <= B ;
					END IF ;
				WHEN B =>
					IF w = '0' THEN
						y <= A ;
					ELSE
						y <= C ;
					END IF ;
				WHEN C =>
					IF w = '0' THEN
						y <= A ;
					ELSE
						y <= C ;
					END IF ;
			END CASE ;
		END IF ;
	END PROCESS ;
    
	z <= '1' WHEN y = C ELSE '0' ;
END Behavior ;
