LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY example2 IS
	PORT (	x1, x2, x3, x4, x5, x6, x7 	: IN	STD_LOGIC ;
			f							: OUT 	STD_LOGIC ) ;
END example2 ;

ARCHITECTURE LogicFunc OF example2 IS
BEGIN
	f <= 	(x1 AND x3 AND NOT x6) OR
			(x1 AND x4 AND x5 AND NOT x6) OR
			(x2 AND x3 AND x7) OR
			(x2 AND x4 AND x5 AND x7) ;
END LogicFunc ;
