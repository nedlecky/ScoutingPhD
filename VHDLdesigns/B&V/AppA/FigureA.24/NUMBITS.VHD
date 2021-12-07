LIBRARY ieee ; 
USE ieee.std_logic_1164.all ; 

ENTITY Numbits IS 
	PORT ( 	X 		: IN 	STD_LOGIC_VECTOR(1 TO 3) ; 
			Count 	: OUT 	INTEGER RANGE 0 TO 3 ) ; 
END Numbits ; 

ARCHITECTURE Behavior OF Numbits IS	
BEGIN
	 PROCESS ( X ) -- count the number of bits in X equal to 1 
		VARIABLE TMP : INTEGER ;
	BEGIN 
		Tmp := 0 ; 
		FOR i IN 1 TO 3 LOOP 
			IF X(i) = '1' THEN 
				Tmp := Tmp + 1 ; 
			END IF ; 
		END LOOP ; 
		Count <= Tmp ; 
	END PROCESS ; 
END Behavior ; 
