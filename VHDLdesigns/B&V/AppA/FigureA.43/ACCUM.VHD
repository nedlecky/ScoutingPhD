LIBRARY ieee ;
USE ieee.std_logic_1164.all ;
USE work.components.all ;

ENTITY accum IS
	GENERIC ( k : INTEGER := 8 ) ;
	PORT ( 	Resetn, Clock 	: IN 		STD_LOGIC ; 
			X				: IN 		STD_LOGIC_VECTOR(k-1 DOWNTO 0) ; 
			Result 			: BUFFER 	STD_LOGIC_VECTOR(k-1 DOWNTO 0) ) ;
END accum ;

ARCHITECTURE Structure OF accum IS 
	SIGNAL Sum : STD_LOGIC_VECTOR(k-1 DOWNTO 0) ;
	SIGNAL C : STD_LOGIC_VECTOR(3 DOWNTO 0) ;
	SIGNAL Zero_bit, Cout, Stop : STD_LOGIC ;
BEGIN
	Zero_bit <= '0' ;
	adder: addern
		GENERIC MAP ( n => k )
		PORT MAP ( Zero_bit, X, Result, Sum, Cout ) ;
	reg: regne
		GENERIC MAP ( n => k )
		PORT MAP ( Sum, Resetn, Stop, Clock, Result ) ;
	Counter: count4
		PORT MAP ( Clock, Resetn, Stop, C ) ;
	NANDgate: NANDn
		PORT MAP ( C, Stop ) ;
END Structure ;
