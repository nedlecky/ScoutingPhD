LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY addern IS
	GENERIC ( n : INTEGER := 16 ) ;
	PORT (	Cin 	: IN 	STD_LOGIC ;
			A, B 	: IN 	STD_LOGIC_VECTOR(n-1 DOWNTO 0) ;
			Sum 	: OUT 	STD_LOGIC_VECTOR(n-1 DOWNTO 0) ;
			Cout 	: OUT 	STD_LOGIC ) ;
END addern ;

ARCHITECTURE Structure OF addern IS
	SIGNAL C : STD_LOGIC_VECTOR(1 TO n-1) ;
	COMPONENT fulladd
		PORT (	Cin, x, y 	: IN 	STD_LOGIC ;
				s, Cout 	: OUT 	STD_LOGIC ) ;
	END COMPONENT ;
BEGIN
	FA_0: fulladd PORT MAP ( Cin, A(0), B(0), Sum(0), C(1) ) ;
	G_1: FOR i IN 1 TO n-2 GENERATE
		FA_i: fulladd PORT MAP ( C(i), A(i), B(i), Sum(i), C(i+1) ) ;
	END GENERATE ;
	FA_n: fulladd PORT MAP ( C(n-1), A(n-1), B(n-1), Sum(n-1), Cout ) ;
END Structure ;
