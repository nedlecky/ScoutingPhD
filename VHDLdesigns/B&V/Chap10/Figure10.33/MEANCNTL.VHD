LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY meancntl IS
	PORT (	Clock, Resetn, s, z, zz					: IN		STD_LOGIC ;
			EC, LC, Ssel, ES, LA, EB, Div, Done		: OUT		STD_LOGIC ) ;
END meancntl ;

ARCHITECTURE Behavior OF meancntl IS
	TYPE STATE_TYPE IS ( S1, S2, S3, S4, S5 ) ;
	SIGNAL y : STATE_TYPE ;
BEGIN
	FSM_transitions: PROCESS ( Resetn, Clock )
	BEGIN
		IF Resetn = '0' THEN
			y <= S1 ;
		ELSIF (Clock'EVENT AND Clock = '1') THEN
			CASE y IS
				WHEN S1 =>
					IF s = '0' THEN	y <= S1 ; ELSE y <= S2 ; END IF ;
				WHEN S2 =>
					IF z = '0' THEN y <= S2 ; ELSE y <= S3 ; END IF ;
				WHEN S3 =>
					y <= S4 ;
				WHEN S4 =>
					IF zz = '0' THEN y <= S4 ; ELSE y <= S5 ; END IF ;
				WHEN S5 =>
					IF s = '1' THEN y <= S5 ; ELSE y <= S1 ; END IF ;
			END CASE ;
		END IF ;
	END PROCESS ;
	
	FSM_outputs: PROCESS ( y, s, z, zz )
	BEGIN
		LC <= '0' ; EC <= '0' ; ES <= '0' ; LA <= '0' ; EB <= '0' ;
		Div <= '0' ; Done <= '0' ; Ssel <= '0' ;
		CASE y IS
			WHEN S1 =>
				LC <= '1' ;  EC <= '1' ; ES <= '1' ;
			WHEN S2 =>
				Ssel <= '1' ; ES <= '1' ;
				IF z = '0' THEN EC <= '1' ; ELSE EC <= '0' ; END IF ;
			WHEN S3 =>
				LA <= '1' ; EB <= '1' ;
			WHEN S4 =>
				Div <= '1' ;
			WHEN S5 =>
				Div <= '1' ; Done <= '1' ;
		END CASE ;
	END PROCESS ;
END Behavior ;




