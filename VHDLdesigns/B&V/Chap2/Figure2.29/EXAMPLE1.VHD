ENTITY example1 IS 
	PORT ( 	x1, x2, x3 	: IN 	BIT ; 
				f 		: OUT 	BIT ) ; 
END example1 ; 

ARCHITECTURE LogicFunc OF example1 IS 
BEGIN   
	f <= (x1 AND x2) OR (NOT x2 AND x3) ; 
END LogicFunc ; 
