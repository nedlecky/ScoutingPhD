LIBRARY ieee ;
USE ieee.std_logic_1164.all ;
USE ieee.std_logic_unsigned.all ;

ENTITY alu IS
	PORT (	s 		: IN 	STD_LOGIC_VECTOR(2 DOWNTO 0) ;
			A, B	: IN 	STD_LOGIC_VECTOR(3 DOWNTO 0) ;
			F 		: OUT 	STD_LOGIC_VECTOR(3 DOWNTO 0) ) ;
END alu ;

ARCHITECTURE Behavior OF alu IS	
BEGIN
	PROCESS ( s, A, B )
	BEGIN
		CASE s IS
			WHEN "000" =>
				F <= "0000" ;
			WHEN "001" =>
				F <= B - A ;
			WHEN "010" =>
				F <= A - B ;
			WHEN "011" =>
				F <= A + B ;
			WHEN "100" =>
				F <= A XOR B ;
			WHEN "101" =>
				F <= A OR B ;
			WHEN "110" =>
				F <= A AND B ;
			WHEN OTHERS =>
				F <= "1111" ;
		END CASE ;
	END PROCESS ;
END Behavior ;
