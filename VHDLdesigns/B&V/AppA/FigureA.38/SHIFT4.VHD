LIBRARY ieee ;
USE ieee.std_logic_1164.all ;

ENTITY shift4 IS
	PORT (	w, Clock	: IN 	STD_LOGIC ;
			Q 			: OUT 	STD_LOGIC_VECTOR(1 TO 4) ) ;
END shift4 ;

ARCHITECTURE Behavior OF shift4 IS
	SIGNAL Sreg : STD_LOGIC_VECTOR(1 TO 4) ;
BEGIN
	PROCESS ( Clock )
	BEGIN
		IF Clock'EVENT AND Clock = '1' THEN
			Sreg(4) <= w ;
			Sreg(3) <= Sreg(4) ;
			Sreg(2) <= Sreg(3) ;
			Sreg(1) <= Sreg(2) ;	
		END IF ;
	END PROCESS ;
	Q <= Sreg ;
END Behavior ;
