LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.ALL;

ENTITY DFFs IS
	PORT( 				-- Input Signals	
	 	 D, Clock, Reset, Enable 	: IN STD_LOGIC;
             			-- Output Signals
	 	 Q1, Q2, Q3, Q4 			: OUT STD_LOGIC);
END DFFs;

ARCHITECTURE behavior OF DFFs IS
BEGIN
					-- Positive edge triggered D flip-flop
					-- If WAIT is used no sensitivity list is used
 	PROCESS
	BEGIN
		WAIT UNTIL (Clock'EVENT AND Clock='1'); 
		Q1 <= D;
	END PROCESS;

				-- Positive edge triggered D flip-flop 
				--	with synchronous reset
 	PROCESS
	BEGIN
		WAIT UNTIL (Clock'EVENT AND Clock='1');
		IF reset = '1' 
		THEN Q2 <= '0'; 
		ELSE Q2 <= D; END IF;
	END PROCESS;

				-- Positive edge triggered D flip-flop with 
				--	asynchronous reset
 	PROCESS (Reset,Clock)
	BEGIN
		IF reset = '1' THEN 
			Q3 <= '0'; 
		ELSIF (clock'EVENT AND clock='1') THEN
			Q3 <= D;
		END IF;
	END PROCESS;

				-- Positive edge triggered D flip-flop with 
				--	asynchronous reset and enable
 	PROCESS (Reset,Clock)
	BEGIN
		IF reset = '1' THEN 
			Q4 <= '0'; 
		ELSIF (clock'EVENT AND clock='1') THEN
			IF Enable = '1' THEN Q4 <= D; END IF;
		END IF;
	END PROCESS;

END behavior;

