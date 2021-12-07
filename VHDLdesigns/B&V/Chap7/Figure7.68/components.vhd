LIBRARY ieee ;
USE ieee.std_logic_1164.all ;

PACKAGE components IS

	COMPONENT regn -- register
		GENERIC ( N : INTEGER := 8 ) ;
		PORT ( 	R 			: IN 	STD_LOGIC_VECTOR(N-1 DOWNTO 0) ;
				Rin, Clock 	: IN 	STD_LOGIC ;
				Q 			: OUT 	STD_LOGIC_VECTOR(N-1 DOWNTO 0) ) ;
	END COMPONENT ;

	COMPONENT shiftr -- left-to-right shift register with async reset
		GENERIC (	K : INTEGER := 4 ) ;
		PORT	( 	Resetn, Clock, w	: IN 		STD_LOGIC ;
					Q 					: BUFFER 	STD_LOGIC_VECTOR(1 TO K) ) ;
	END component ;

END components ;
