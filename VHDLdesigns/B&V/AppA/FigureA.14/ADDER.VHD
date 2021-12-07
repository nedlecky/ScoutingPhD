LIBRARY ieee ; 
USE ieee.std_logic_1164.all ; 
USE work.fulladd_package.all ; 

ENTITY adder IS 
	PORT ( 	Cin 	: IN 	STD_LOGIC ; 
			X, Y 	: IN	STD_LOGIC_VECTOR(3 DOWNTO 0) ; 
			S 		: OUT 	STD_LOGIC_VECTOR(3 DOWNTO 0) ; 
			Cout 	: OUT	STD_LOGIC ) ; 
END adder ; 

ARCHITECTURE Structure OF adder IS 
	SIGNAL C : STD_LOGIC_VECTOR(0 TO 4) ; 
BEGIN 
	C(0) <= Cin ; 
	Generate_label:  
	FOR i IN 0 TO 3 GENERATE 
		bit: fulladd PORT MAP ( C(i), X(i), Y(i), S(i), C(i+1) ) ; 
	END GENERATE ; 
	Cout <= C(4) ;  
END Structure ;
