LIBRARY ieee ;
USE ieee.std_logic_1164.all ;

ENTITY dec2to4 IS
	PORT (	w	: IN 	STD_LOGIC_VECTOR(1 DOWNTO 0) ;
			En 	: IN 	STD_LOGIC ;
			y	: OUT 	STD_LOGIC_VECTOR(0 TO 3) ) ;
END dec2to4 ;

ARCHITECTURE Behavior OF dec2to4 IS	
BEGIN
	PROCESS ( w, En )
	BEGIN
		IF En = '1' THEN
			CASE w IS
				WHEN "00" =>
					y <= "1000" ;
				WHEN "01" =>
					y <= "0100" ;
				WHEN "10" =>
					y <= "0010" ;
				WHEN OTHERS =>
					y <= "0001" ;
			END CASE ;
		ELSE
			y <= "0000" ;
		END IF ;
	END PROCESS ;
END Behavior ;
