LIBRARY ieee ; 
USE ieee.std_logic_1164.all ; 

ENTITY latch IS 
	PORT ( 	D, clk 	: IN 	STD_LOGIC ; 
			Q 		: OUT 	STD_LOGIC ) ; 
END latch ;

ARCHITECTURE Behavior OF latch IS    
BEGIN
	PROCESS ( D, clk ) 
	BEGIN
		IF clk = '1' THEN 
			Q <= D ; 
		END IF ; 
	END PROCESS ; 
END Behavior ; 
