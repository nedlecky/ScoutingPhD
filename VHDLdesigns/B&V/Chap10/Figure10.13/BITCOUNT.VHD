LIBRARY ieee ;
USE ieee.std_logic_1164.all ;
LIBRARY work ;
USE work.components.shiftrne ;

ENTITY bitcount IS
	PORT(	Clock, Resetn	: IN 		STD_LOGIC ;
			LA, s			: IN 		STD_LOGIC ;
			Data 			: IN 		STD_LOGIC_VECTOR(7 DOWNTO 0) ;
			B 				: BUFFER 	INTEGER RANGE 0 to 8 ;
			Done 			: OUT 		STD_LOGIC ) ;
END bitcount ;

ARCHITECTURE Behavior OF bitcount IS
	TYPE State_type IS ( S1, S2, S3 ) ;
	SIGNAL y : State_type ;
	SIGNAL A : STD_LOGIC_VECTOR(7 DOWNTO 0) ;
	SIGNAL z, EA, LB, EB, low : STD_LOGIC ;
BEGIN
	FSM_transitions: PROCESS ( Resetn, Clock )
	BEGIN
		IF Resetn = '0' THEN
			y <= S1 ;
		ELSIF (Clock'EVENT AND Clock = '1') THEN
			CASE y IS
				WHEN S1 =>
					IF s = '0' THEN y <= S1 ; ELSE y <= S2 ; END IF ;
				WHEN S2 =>
					IF z = '0' THEN y <= S2 ; ELSE y <= S3 ; END IF ;
				WHEN S3 =>
					IF s = '1' THEN y <= S3 ; ELSE y <= S1 ; END IF ;
			END CASE ;
		END IF ;
	END PROCESS ;

	FSM_outputs: PROCESS ( y, s, A(0), z )
	BEGIN
		EA <= '0' ; LB <= '0' ; EB <= '0' ; Done <= '0' ;
		CASE y IS
			WHEN S1 =>
				LB <= '1' ; EB <= '1' ;
				IF s = '0' AND LA = '1' THEN EA <= '1' ; 
				ELSE EA <= '0' ; END IF ;
			WHEN S2 =>
				EA <= '1' ;
				IF A(0) = '1' THEN EB <= '1' ; ELSE EB <= '0' ; END IF ;
			WHEN S3 =>
				Done <= '1' ;
		END CASE ;
	END PROCESS ;

	-- The datapath circuit is described below
	upcount: PROCESS ( Resetn, Clock )
	BEGIN
		IF Resetn = '0' THEN
			B <= 0 ;
		ELSIF (Clock'EVENT AND Clock = '1') THEN
			IF EB = '1' THEN
				IF LB = '1' THEN
					B <= 0 ;
				ELSE
					B <= B + 1 ;
				END IF ;
			END IF ;
		END IF;
	END PROCESS;

	low <= '0' ;
	ShiftA: shiftrne GENERIC MAP ( N => 8 )
		PORT MAP ( Data, LA, EA, low, Clock, A ) ;
	z <= '1' WHEN A = "00000000" ELSE '0' ;			
END Behavior ;
