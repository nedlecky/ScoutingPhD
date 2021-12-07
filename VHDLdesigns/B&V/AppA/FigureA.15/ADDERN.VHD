LIBRARY ieee ; 
USE ieee.std_logic_1164.all ; 
USE work.fulladd_package.all ; 

ENTITY addern IS
	GENERIC ( n : INTEGER := 4 ) ; 
	PORT (	Cin 	: IN 	STD_LOGIC ; 
			X, Y	: IN 	STD_LOGIC_VECTOR(n-1 DOWNTO 0) ; 
			S		: OUT 	STD_LOGIC_VECTOR(n-1 DOWNTO 0) ; 
		Cout		: OUT 	STD_LOGIC ) ;
END addern ;

ARCHITECTURE Structure OF addern IS 
	SIGNAL C : STD_LOGIC_VECTOR(0 TO n) ;
BEGIN
	C(0) <= Cin ;
	Generate_label:  
	FOR i IN 0 TO n-1 GENERATE 
		stage: fulladd PORT MAP ( C(i), X(i), Y(i), S(i), C(i+1) ) ; 
	END GENERATE ; 
	Cout <= C(4) ;  
END Structure ;
