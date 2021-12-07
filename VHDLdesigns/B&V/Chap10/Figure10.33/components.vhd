LIBRARY ieee;
USE ieee.std_logic_1164.all;

PACKAGE components IS

	COMPONENT mux2to1 -- 2-to-1 multiplexer
		PORT (	w0, w1	: IN	STD_LOGIC ;
				s		: IN	STD_LOGIC ;
				f		: OUT 	STD_LOGIC );
	END COMPONENT ;

	COMPONENT muxdff -- DFF with 2-to-1 mux on the D input
		PORT (	D0, D1, Sel, Clock	: IN	STD_LOGIC ;
				Q		  			: OUT	STD_LOGIC );
	END COMPONENT;

	COMPONENT regne  -- N-bit register with enable
		GENERIC ( N : INTEGER := 4 ) ;
		PORT (	R					: IN	STD_LOGIC_VECTOR(N-1 DOWNTO 0) ;
				Resetn, E, Clock	: IN	STD_LOGIC ;
				Q		  			: OUT	STD_LOGIC_VECTOR(N-1 DOWNTO 0) ) ;
	END COMPONENT ;
	
	COMPONENT shiftlne  -- right-to-left shift register w. parallel load and enable
		GENERIC ( N : INTEGER := 4 ) ;
		PORT (	R				: IN		STD_LOGIC_VECTOR(N-1 DOWNTO 0) ;
				L, E, w, Clock	: IN		STD_LOGIC ;
				Q		  		: BUFFER	STD_LOGIC_VECTOR(N-1 DOWNTO 0) ) ;
	END COMPONENT ;

	COMPONENT shiftrne  -- left-to-right shift register w. parallel load and enable
		GENERIC ( N : INTEGER := 4 ) ;
		PORT (	R				: IN		STD_LOGIC_VECTOR(N-1 DOWNTO 0) ;
				L, E, w, Clock	: IN		STD_LOGIC ;
				Q		  		: BUFFER	STD_LOGIC_VECTOR(N-1 DOWNTO 0) ) ;
	END COMPONENT ;

	COMPONENT downcnt -- down-counter, counts from intial_count-1 downto 0
		GENERIC	( initial_count : INTEGER := 8 ) ;
		PORT (	Clock, E, L	: IN		STD_LOGIC ;
				Q			: BUFFER 	INTEGER RANGE 0 TO initial_count-1 ) ;
	END COMPONENT ;

END components ;



