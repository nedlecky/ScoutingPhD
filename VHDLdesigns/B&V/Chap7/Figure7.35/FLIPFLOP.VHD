LIBRARY ieee ;
USE ieee.std_logic_1164.all ;
LIBRARY altera ; 
USE altera.maxplus2.all ; 

ENTITY flipflop IS 
	PORT ( 	D, Clock 		: IN 	STD_LOGIC ; 
			Resetn, Presetn	: IN 	STD_LOGIC ; 
			Q 				: OUT 	STD_LOGIC ) ; 
END flipflop ; 

ARCHITECTURE Structure OF flipflop IS 
BEGIN
	dff_instance: dff PORT MAP ( D, Clock, Resetn, Presetn, Q ) ; 
END Structure ;
