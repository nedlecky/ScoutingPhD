LIBRARY ieee; 
USE ieee.std_logic_1164.all; 

ENTITY priority IS 
	PORT ( 	 req1, req2, req3 	: IN 	STD_LOGIC ; 
			 f 					: OUT 	STD_LOGIC_VECTOR(1 DOWNTO 0) ) ; 
END priority ; 

ARCHITECTURE Behavior OF priority IS	 
BEGIN 
	f <= 	"01" WHEN req1 = '1' ELSE 
			"10" WHEN req2 = '1' ELSE 
			"11" WHEN req3 = '1' ELSE 
			"00" ; 
END Behavior; 
