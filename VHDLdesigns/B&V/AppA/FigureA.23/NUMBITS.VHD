LIBRARY ieee ; 
USE ieee.std_logic_1164.all ; 

ENTITY numbits IS 
	PORT ( 	X 		: IN 		STD_LOGIC_VECTOR(1 TO 3) ; 
			Count 	: BUFFER 	INTEGER RANGE 0 TO 3 ) ; 
END numbits ; 

ARCHITECTURE Behavior OF numbits IS	 
BEGIN 
	PROCESS ( X ) -- count the number of bits in X with the value 1 
	BEGIN 
		Count <= 0 ; -- the 0 with no quotes is a decimal number 
		FOR i IN 1 TO 3 LOOP 
			IF X(i) = '1' THEN 
				Count <= Count + 1 ;
			END IF ;
		END LOOP ;
	END PROCESS ;
END Behavior ;
