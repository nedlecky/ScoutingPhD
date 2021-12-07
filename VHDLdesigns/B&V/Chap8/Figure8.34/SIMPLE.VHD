LIBRARY ieee ;
USE ieee.std_logic_1164.all ;

ENTITY simple IS
	PORT (	Clock, Resetn, w 	: IN 	STD_LOGIC ;
			z					: OUT 	STD_LOGIC ) ;
END simple ;

ARCHITECTURE Behavior OF simple IS
	TYPE State_TYPE IS (A, B, C) ;
	ATTRIBUTE ENUM_ENCODING 				: STRING ;
	ATTRIBUTE ENUM_ENCODING OF State_type 	: TYPE IS "00 01 11" ;
	SIGNAL y_present, y_next : State_type ;
BEGIN
	PROCESS ( w, y_present )
	BEGIN
		CASE y_present IS
			WHEN A =>
				IF w = '0' THEN
					y_next <= A ;
				ELSE
					y_next <= B ;
				END IF ;
			WHEN B =>
				IF w = '0' THEN
					y_next <= A ;
				ELSE
					y_next <= C ;
				END IF ;
			WHEN C =>
				IF w = '0' THEN
					y_next <= A ;
				ELSE
					y_next <= C ;
				END IF ;
		END CASE ;
	END PROCESS ;

	PROCESS (Clock, Resetn)
	BEGIN
		IF Resetn = '0' THEN
			y_present <= A ;
		ELSIF (Clock'EVENT AND Clock = '1') THEN
			y_present <= y_next ;
		END IF ;
	END PROCESS ;

	z <= '1' WHEN y_present = C ELSE '0' ;
END Behavior ;
