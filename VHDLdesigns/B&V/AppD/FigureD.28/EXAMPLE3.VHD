LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all ;

ENTITY example3 IS
	PORT (	Clock, Reset 	: IN 		STD_LOGIC ;
			Data 			: IN 		STD_LOGIC_VECTOR(3 DOWNTO 0) ;
			RegSum 			: BUFFER 	STD_LOGIC_VECTOR(3 DOWNTO 0) ) ;
END example3 ;

ARCHITECTURE Behavior OF example3 IS
	SIGNAL Sum : STD_LOGIC_VECTOR(3 DOWNTO 0) ;
	COMPONENT Reg4
		PORT (	clock 	: IN 	STD_LOGIC;
				q 		: OUT 	STD_LOGIC_VECTOR (3 DOWNTO 0) ;
				aclr 	: IN 	STD_LOGIC ;
				data 	: IN 	STD_LOGIC_VECTOR (3 DOWNTO 0) ) ;
	END COMPONENT ;
BEGIN
	Sum <= Data + RegSum ;
	R1: Reg4 PORT MAP ( Clock, RegSum, Reset, Sum ) ;
END Behavior ;
