LIBRARY ieee ; 
USE ieee.std_logic_1164.all ; 
USE ieee.std_logic_unsigned.all ; 

ENTITY count4 IS 
	 PORT ( Resetn	 	: IN 	STD_LOGIC ; 
			E, Clock 	: IN 	STD_LOGIC ; 
			Q 			: OUT 	STD_LOGIC_VECTOR (3 DOWNTO 0) ) ;
END count4 ;

ARCHITECTURE Behavior OF count4 IS 
	SIGNAL Count : STD_LOGIC_VECTOR (3 DOWNTO 0) ; 
BEGIN
	PROCESS ( Clock, Resetn )
	BEGIN 
		IF Resetn = '0' THEN 
			Count <= "0000" ; 
		ELSIF (Clock'EVENT AND Clock = '1') THEN 
			IF E = '1' THEN
				Count <= Count + 1 ;
			END IF ;
		END IF ;
	END PROCESS ;
	Q <= Count ; 
END Behavior ;
