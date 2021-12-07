LIBRARY ieee ;
USE ieee.std_logic_1164.all ;
USE ieee.std_logic_signed.all ;
USE work.subccts.all ;

ENTITY proc IS
	PORT (	Data 		: IN 		STD_LOGIC_VECTOR(7 DOWNTO 0) ;
			Reset, w 	: IN 		STD_LOGIC ;
			Clock 		: IN 		STD_LOGIC ;
			F, Rx, Ry 	: IN 		STD_LOGIC_VECTOR(1 DOWNTO 0) ;
			Done 		: BUFFER 	STD_LOGIC ;
			BusWires 	: INOUT 	STD_LOGIC_VECTOR(7 DOWNTO 0) ) ;
END proc ;

ARCHITECTURE Behavior OF proc IS
	SIGNAL Rin, Rout : STD_LOGIC_VECTOR(0 TO 3) ;
	SIGNAL Clear, High, AddSub : STD_LOGIC ;
	SIGNAL Extern, Ain, Gin, Gout, FRin : STD_LOGIC ;
	SIGNAL Count, Zero : STD_LOGIC_VECTOR(1 DOWNTO 0) ;
	SIGNAL T, I, X, Y : STD_LOGIC_VECTOR(0 TO 3) ;
	SIGNAL R0, R1, R2, R3 : STD_LOGIC_VECTOR(7 DOWNTO 0) ;
	SIGNAL A, Sum, G : STD_LOGIC_VECTOR(7 DOWNTO 0) ;
	SIGNAL Func, FuncReg : STD_LOGIC_VECTOR(1 TO 6) ;
BEGIN
	Zero <= "00" ; High <= '1' ;
	Clear <= Reset OR Done OR (NOT w AND T(0)) ;
	counter: upcount PORT MAP (	Clear, Clock, Count ) ;
	decT: dec2to4 PORT MAP ( Count, High, T );
	Func <= F & Rx & Ry ;
	FRin <= w AND T(0) ;
	functionreg: regn GENERIC MAP ( N => 6 ) 
		PORT MAP ( Func, FRin, Clock, FuncReg ) ;
	decI: dec2to4 PORT MAP ( FuncReg(1 TO 2), High, I ) ;
	decX: dec2to4 PORT MAP ( FuncReg(3 TO 4), High, X ) ;
	decY: dec2to4 PORT MAP ( FuncReg(5 TO 6), High, Y ) ;

	Extern <= I(0) AND T(1) ;
	Done <= ((I(0) OR I(1)) AND T(1)) OR ((I(2) OR I(3)) AND T(3)) ;
	Ain <= (I(2) OR I(3)) AND T(1) ;
	Gin <= (I(2) OR I(3)) AND T(2) ;
	Gout <= (I(2) OR I(3)) AND T(3) ;
	AddSub <= I(3) ;
	RegCntl:
	FOR k IN 0 TO 3 GENERATE
		Rin(k) <= ((I(0) OR I(1)) AND T(1) AND X(k)) OR
			((I(2) OR I(3)) AND T(3) AND X(k)) ;
		Rout(k) <= (I(1) AND T(1) AND Y(k)) OR 
			((I(2) OR I(3)) AND ((T(1) AND X(k)) OR (T(2) AND Y(k)))) ;
	END GENERATE RegCntl ;
	tri_extern: trin PORT MAP ( Data, Extern, BusWires ) ;
	reg0: regn PORT MAP ( BusWires, Rin(0), Clock, R0 ) ;
	reg1: regn PORT MAP ( BusWires, Rin(1), Clock, R1 ) ;
	reg2: regn PORT MAP ( BusWires, Rin(2), Clock, R2 ) ;
	reg3: regn PORT MAP ( BusWires, Rin(3), Clock, R3 ) ;
	tri0: trin PORT MAP ( R0, Rout(0), BusWires ) ;
	tri1: trin PORT MAP ( R1, Rout(1), BusWires ) ;
	tri2: trin PORT MAP ( R2, Rout(2), BusWires ) ;
	tri3: trin PORT MAP ( R3, Rout(3), BusWires ) ;
	regA: regn PORT MAP ( BusWires, Ain, Clock, A ) ;
	alu:
	WITH AddSub SELECT
		Sum <= 	A + BusWires WHEN '0',
				A - BusWires WHEN OTHERS ;
	regG: regn PORT MAP ( Sum, Gin, Clock, G ) ;
	triG: trin PORT MAP ( G, Gout, BusWires ) ;
END Behavior ;
