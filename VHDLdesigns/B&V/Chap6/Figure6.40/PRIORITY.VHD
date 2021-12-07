LIBRARY ieee ;
USE ieee.std_logic_1164.all ;

ENTITY priority IS
	PORT (	w 	: IN 	STD_LOGIC_VECTOR(3 DOWNTO 0) ;
			y	: OUT 	STD_LOGIC_VECTOR(1 DOWNTO 0) ;
			z	: OUT 	STD_LOGIC ) ;
END priority ;

ARCHITECTURE Behavior OF priority IS	
BEGIN
	PROCESS ( w )
	BEGIN
		IF w(3) = '1' THEN
			y <= "11" ;
		ELSIF w(2) = '1' THEN 
			y <= "10" ;
		ELSIF w(1) = '1' THEN
			y <= "01" ;
		ELSE
			y <= "00" ;
		END IF ;
	END PROCESS ;
	z <= '0' WHEN w = "0000" ELSE '1' ;
END Behavior ;
