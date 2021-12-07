LIBRARY ieee ;
USE ieee.std_logic_1164.all ;
USE ieee.std_logic_unsigned.all ;

ENTITY BCDcount IS
	PORT (	Clock 		: IN 		STD_LOGIC ;
			Clear, E 	: IN 		STD_LOGIC ;
			BCD1, BCD0	: BUFFER 	STD_LOGIC_VECTOR(3 DOWNTO 0) ) ;
END BCDcount ;

ARCHITECTURE Behavior OF BCDcount IS
BEGIN
	PROCESS ( Clock )
	BEGIN
		IF Clock'EVENT AND Clock = '1' THEN
			IF Clear = '1' THEN
				BCD1 <= "0000" ; BCD0 <= "0000" ;
			ELSIF E = '1' THEN
				IF BCD0 = "1001" THEN
					BCD0 <= "0000" ;
					IF BCD1 = "1001" THEN
						BCD1 <= "0000";
					ELSE
						BCD1 <= BCD1 + '1' ;
					END IF ;
				ELSE
					BCD0 <= BCD0 + '1' ;
				END IF ;
			END IF ;
		END IF;
	END PROCESS;
END Behavior ;
