LIBRARY ieee ;
USE ieee.std_logic_1164.all ;

PACKAGE components IS

	-- n-bit register with enable
	COMPONENT regne  
		GENERIC ( N : INTEGER := 4 ) ;
		PORT (	R 			: IN 	STD_LOGIC_VECTOR(N-1 DOWNTO 0) ;
				Resetn 		: IN 	STD_LOGIC ;
				E, Clock 	: IN 	STD_LOGIC ;
				Q 			: OUT 	STD_LOGIC_VECTOR(N-1 DOWNTO 0) ) ;
	END COMPONENT ;

	-- up-counter that counts from 0 to modulus-1
	COMPONENT upcount  
		GENERIC	(	modulus 	: INTEGER := 8 ) ;
		PORT	( 	Resetn 		: IN 		STD_LOGIC ;
					Clock, E, L : IN 		STD_LOGIC ;
					R 			: IN 		INTEGER RANGE 0 TO modulus-1 ;
					Q 			: BUFFER 	INTEGER RANGE 0 TO modulus-1 ) ;
	END COMPONENT ;

END components ;
