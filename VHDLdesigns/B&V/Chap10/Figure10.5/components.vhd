LIBRARY ieee ;
USE ieee.std_logic_1164.all ;

PACKAGE components IS
	-- 2-to-1 multiplexer
	COMPONENT mux2to1 
		PORT (	w0, w1 	: IN 	STD_LOGIC ;
				s 		: IN 	STD_LOGIC ;
				f 		: OUT 	STD_LOGIC );
	END COMPONENT ;

	-- D flip-flop with 2-to-1 multiplexer connected to D
	COMPONENT muxdff
		PORT (	D0, D1, Sel, Clock 	: IN 	STD_LOGIC ;
				Q 					: OUT 	STD_LOGIC );
	END COMPONENT ;

	-- n-bit register with enable
	COMPONENT regne  
		GENERIC ( N : INTEGER := 4 ) ;
		PORT (	R 			: IN 	STD_LOGIC_VECTOR(N-1 DOWNTO 0) ;
				Resetn 		: IN 	STD_LOGIC ;
				E, Clock 	: IN 	STD_LOGIC ;
				Q 			: OUT 	STD_LOGIC_VECTOR(N-1 DOWNTO 0) ) ;
	END COMPONENT ;

	-- n-bit right-to-left shift register with parallel load and enable
	COMPONENT shiftlne  
		GENERIC ( N : INTEGER := 4 ) ;
		PORT (	R 			: IN 		STD_LOGIC_VECTOR(N-1 DOWNTO 0) ;
				L, E, w		: IN 		STD_LOGIC ;
				Clock		: IN 		STD_LOGIC ;
				Q 			: BUFFER 	STD_LOGIC_VECTOR(N-1 DOWNTO 0) ) ;
	END COMPONENT ;

	-- n-bit left-to-right shift register with parallel load and enable
	COMPONENT shiftrne  
		GENERIC ( N : INTEGER := 4 ) ;
		PORT (	R 		: IN 		STD_LOGIC_VECTOR(N-1 DOWNTO 0) ;
				L, E, w	: IN 		STD_LOGIC ;
				Clock	: IN 		STD_LOGIC ;
				Q 		: BUFFER 	STD_LOGIC_VECTOR(N-1 DOWNTO 0) ) ;
	END COMPONENT ;

	-- up-counter that counts from 0 to modulus-1
	COMPONENT upcount  
		GENERIC	(	modulus 	: INTEGER := 8 ) ;
		PORT	( 	Resetn 		: IN 		STD_LOGIC ;
					Clock, E, L : IN 		STD_LOGIC ;
					R 			: IN 		INTEGER RANGE 0 TO modulus-1 ;
					Q 			: BUFFER 	INTEGER RANGE 0 TO modulus-1 ) ;
	END COMPONENT ;

	-- down-counter that counts from modulus-1 down to 0
	COMPONENT downcnt 
		GENERIC	( modulus : INTEGER := 8 ) ;
		PORT (	Clock, E, L	: IN 		STD_LOGIC ;
				Q 			: BUFFER 	INTEGER RANGE 0 TO modulus-1 ) ;
	END COMPONENT ;

END components ;
