LIBRARY ieee ;
USE ieee.std_logic_1164.all ;

PACKAGE components IS
	-- n-bit left-to-right shift register with parallel load and enable
	COMPONENT shiftrne  
		GENERIC ( N : INTEGER := 4 ) ;
		PORT (	R 		: IN 		STD_LOGIC_VECTOR(N-1 DOWNTO 0) ;
				L, E, w	: IN 		STD_LOGIC ;
				Clock	: IN 		STD_LOGIC ;
				Q 		: BUFFER 	STD_LOGIC_VECTOR(N-1 DOWNTO 0) ) ;
	END COMPONENT ;

END components ;
