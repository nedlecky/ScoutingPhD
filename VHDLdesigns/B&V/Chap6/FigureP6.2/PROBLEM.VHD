LIBRARY ieee ;
USE ieee.std_logic_1164.all ;

ENTITY problem IS
	PORT (	w 				: IN 	STD_LOGIC_VECTOR(1 DOWNTO 0) ;
			En 				: IN 	STD_LOGIC ;
			y0, y1, y2, y3 	: OUT 	STD_LOGIC ) ;
END problem ;

ARCHITECTURE Behavior OF problem IS	
BEGIN
	PROCESS (w, En)
	BEGIN
		y0 <= '0' ; y1 <= '0' ; y2 <= '0' ; y3 <= '0' ;
		IF En = '1' THEN
			IF w = "00" THEN y0 <= '1' ;
			ELSIF w = "01" THEN y1 <= '1' ;
			ELSIF w = "10" THEN y2 <= '1' ;
			ELSE y3 <= '1' ;
			END IF ;
		END IF ;
	END PROCESS ;
END Behavior ;
