LIBRARY ieee ;
USE ieee.std_logic_1164.all ;

PACKAGE components IS

	COMPONENT addern	-- n-bit adder
		GENERIC ( n : INTEGER := 4 ) ; 
		PORT ( 	Cin 	: IN 	STD_LOGIC ; 
				X, Y 	: IN 	STD_LOGIC_VECTOR(n-1 DOWNTO 0) ; 
				S 		: OUT 	STD_LOGIC_VECTOR(n-1 DOWNTO 0) ; 
				Cout 	: OUT 	STD_LOGIC ) ;
	END COMPONENT ;

	COMPONENT regne		-- n-bit register with enable
		GENERIC ( n : INTEGER := 4 ) ;
		PORT ( 	D			: IN 	STD_LOGIC_VECTOR(n-1 DOWNTO 0) ;
				Resetn		: IN 	STD_LOGIC ;
				E, Clock	: IN 	STD_LOGIC ;
				Q 			: OUT 	STD_LOGIC_VECTOR(n-1 DOWNTO 0) ) ;
	END COMPONENT ;

	COMPONENT count4	-- 4-bit counter with enable
		PORT ( 	Resetn		: IN 	STD_LOGIC ;
				E, Clock	: IN 	STD_LOGIC ;
				Q 			: OUT 	STD_LOGIC_VECTOR (3 DOWNTO 0) ) ;
	END COMPONENT ;

	COMPONENT NANDn		-- n-bit AND gate
		GENERIC ( n : INTEGER := 4 ) ;
		PORT ( 	X 	: IN	STD_LOGIC_VECTOR(1 TO n) ;
				f 	: OUT 	STD_LOGIC ) ;
	END COMPONENT ;

END components ;
