LIBRARY ieee ;
USE ieee.std_logic_1164.all ;

ENTITY serial IS
	GENERIC ( length : INTEGER := 8 ) ;
	PORT (	Clock 	: IN 		STD_LOGIC ;
			Reset 	: IN 		STD_LOGIC ;
			A, B 	: IN 		STD_LOGIC_VECTOR(length-1 DOWNTO 0) ;
			Sum 	: BUFFER 	STD_LOGIC_VECTOR(length-1 DOWNTO 0) );
END serial ;

ARCHITECTURE Behavior OF serial IS
	COMPONENT shiftrne
		GENERIC ( N : INTEGER := 4 ) ;
		PORT (	R 		: IN 		STD_LOGIC_VECTOR(N-1 DOWNTO 0) ;
				L, E, w : IN 		STD_LOGIC ;
				Clock 	: IN 		STD_LOGIC ;
				Q 		: BUFFER 	STD_LOGIC_VECTOR(N-1 DOWNTO 0) ) ;
	END COMPONENT ;

	SIGNAL QA, QB, Null_in : STD_LOGIC_VECTOR(length-1 DOWNTO 0) ;
	SIGNAL s, Low, High, Run : STD_LOGIC ;
	SIGNAL Count : INTEGER RANGE 0 TO length ;
	TYPE State_type IS (G, H) ;
	SIGNAL y : State_type ;
BEGIN
	Low <= '0' ; High <= '1' ;
	ShiftA:	shiftrne	GENERIC MAP (N => length)
		PORT MAP ( A, Reset, High, Low, Clock, QA ) ;
	ShiftB:	shiftrne 	GENERIC MAP (N => length)
		PORT MAP ( B, Reset, High, Low, Clock, QB ) ;
	AdderFSM: PROCESS ( Reset, Clock )
	BEGIN
		IF Reset = '1' THEN
			y <= G ;
		ELSIF Clock'EVENT AND Clock = '1' THEN
			CASE y IS
				WHEN G =>
					IF QA(0) = '1' AND QB(0) = '1' THEN y <= H ;
					ELSE y <= G ;
					END IF ;
				WHEN H =>
					IF QA(0) = '0' AND QB(0) = '0' THEN y <= G ;
					ELSE y <= H ;
					END IF ;
			END CASE ;
		END IF ;
	END PROCESS AdderFSM ;

	WITH y SELECT
		s <=	QA(0) XOR QB(0) WHEN G,
				NOT ( QA(0) XOR QB(0) ) WHEN H ;
	Null_in <= (OTHERS => '0') ;
	ShiftSum: shiftrne 	GENERIC MAP ( N => length )
		PORT MAP ( Null_in, Reset, Run, s, Clock, Sum ) ;
	Stop: PROCESS
	BEGIN
		WAIT UNTIL (Clock'EVENT AND Clock = '1') ;
		IF Reset = '1' THEN
			Count <= length ;
		ELSIF Run = '1' THEN
			Count <= Count -1 ;
		END IF ;
	END PROCESS ;
	Run <= '0' WHEN Count = 0 ELSE '1' ;  -- stops counter and ShiftSum
END Behavior ;
