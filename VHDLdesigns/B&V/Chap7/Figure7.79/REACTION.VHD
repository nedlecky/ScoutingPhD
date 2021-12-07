LIBRARY ieee ;
USE ieee.std_logic_1164.all ;

ENTITY reaction IS
	PORT (	c9, Reset 		: IN 		STD_LOGIC ;
			w, Pushn 		: IN 		STD_LOGIC ;
			LEDn 			: OUT 		STD_LOGIC ;
			Digit1, Digit0 	: BUFFER	STD_LOGIC_VECTOR(1 TO 7) ) ;
END reaction ;

ARCHITECTURE Behavior OF reaction IS
	COMPONENT BCDcount
		PORT ( 	Clock 		: IN 		STD_LOGIC ;
				Clear, E 	: IN 		STD_LOGIC ;
				BCD1, BCD0	: BUFFER 	STD_LOGIC_VECTOR(3 DOWNTO 0) ) ;
	END COMPONENT ;
	COMPONENT seg7
		PORT ( 	bcd 	: IN 	STD_LOGIC_VECTOR(3 DOWNTO 0) ;
				leds 	: OUT 	STD_LOGIC_VECTOR(1 TO 7) ) ;
	END COMPONENT ;
	SIGNAL LED : STD_LOGIC ;
	SIGNAL BCD1, BCD0 : STD_LOGIC_VECTOR(3 DOWNTO 0) ;
BEGIN
	flipflop: PROCESS
	BEGIN
		WAIT UNTIL c9'EVENT AND c9 = '1' ;
		IF Pushn = '0' THEN
			LED <= '0' ;
		ELSIF w = '1' THEN
			LED <= '1' ;
		END IF ;
	END PROCESS ;
	
	LEDn <= NOT LED ;
	counter: BCDcount PORT MAP ( c9, Reset, LED, BCD1, BCD0 ) ;
	seg1 : seg7 PORT MAP ( BCD1, Digit1 ) ;
	seg0 : seg7 PORT MAP ( BCD0, Digit0 ) ;
END Behavior ;
