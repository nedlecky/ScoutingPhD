LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY arbiter IS
	PORT ( 	Clock, Resetn 	: IN 	STD_LOGIC ;
			r 				: IN 	STD_LOGIC_VECTOR(1 TO 3) ;
			g 				: OUT 	STD_LOGIC_VECTOR(1 TO 3) ) ;
END arbiter ;

ARCHITECTURE Behavior OF arbiter IS
	TYPE State_type IS (Idle, gnt1, gnt2, gnt3) ;
	SIGNAL y : State_type ;
BEGIN
	PROCESS ( Resetn, Clock )
	BEGIN
		IF Resetn = '0' THEN y <= Idle ;
		ELSIF (Clock'EVENT AND Clock = '1') THEN
			CASE y IS
				WHEN Idle =>
					IF r(1) = '1' THEN y <= gnt1 ;
					ELSIF r(2) = '1' THEN y <= gnt2 ;
					ELSIF r(3) = '1' THEN y <= gnt3 ;
					ELSE y <= Idle ;
					END IF ;
				WHEN gnt1 =>
					IF r(1) = '1' THEN y <= gnt1 ;
					ELSE y <= Idle ;
					END IF ;
				WHEN gnt2 =>
					IF r(2) = '1' THEN y <= gnt2 ;
					ELSE y <= Idle ;
					END IF ;
				WHEN gnt3 =>
					IF r(3) = '1' THEN y <= gnt3 ;
					ELSE y <= Idle ;
					END IF ;
			END CASE ;
		END IF ;
	END PROCESS ;

	PROCESS( y )
	BEGIN
		IF y = gnt1 THEN g(1) <= '1' ;
		ELSIF y = gnt2 THEN g(2) <= '1' ;
		ELSIF y = gnt3 THEN g(3) <= '1' ;
		END IF ;
	END PROCESS ;
END Behavior ;
