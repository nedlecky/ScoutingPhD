LIBRARY ieee ;
USE ieee.std_logic_1164.all ;

ENTITY mealy2 IS
	PORT ( 	Clock, Resetn, w 	: IN 	STD_LOGIC ;
			z					: OUT 	STD_LOGIC ) ;
END mealy2 ;

ARCHITECTURE Behavior OF mealy2 IS
	TYPE State_type IS (A, B) ;
	SIGNAL next_y : State_type ;
	SIGNAL y : State_type ;
BEGIN
	PROCESS ( y, w )
	BEGIN
		CASE y IS
			WHEN A =>
				IF w = '0' THEN next_y <= A ;
				ELSE next_y <= B ;
				END IF ;
			WHEN B =>
				IF w = '0' THEN next_y <= A ;
				ELSE next_y <= B ;
				END IF ;
		END CASE ;
	END PROCESS ;

	PROCESS ( Resetn, Clock )
	BEGIN
		IF Resetn = '0' THEN
			y <= A ;
		ELSIF (Clock'EVENT AND Clock = '1') THEN
			y <= next_y;
		END IF ;
	END PROCESS ;

	PROCESS ( y, w )
	BEGIN
		CASE y IS
			WHEN A =>
				z <= '0' ;
			WHEN B =>
				z <= w ;
		END CASE ;
	END PROCESS ;
END Behavior ;
