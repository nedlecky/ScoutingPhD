		-- Include Libraries for standard logic data types
LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.all;

		-- Entity name normally the same as file name
ENTITY multiplexer IS

		-- Port declaration - declares module inputs and outputs
   PORT( -- Input Signals	
			A, B, Mux_Control 						: IN std_logic;
		 -- Output Signals
			Mux_Out1, Mux_Out2, Mux_Out3, Mux_Out4 	: OUT std_logic);

END multiplexer;

		-- defines internal module architecture
ARCHITECTURE behavior OF multiplexer IS
BEGIN
		-- selected signal assignment statement
	Mux_Out1 <= A WHEN Mux_Control = '0' ELSE B;
		
		-- With Select Statement
	WITH mux_control SELECT
		Mux_Out2 <= A WHEN '0',
					B WHEN '1',
					A WHEN OTHERS;

		-- Process must declare a sensitivity list
		-- Sensitivity list includes all signals which can change the outputs
	PROCESS (A,B,Mux_Control)
	BEGIN
		-- Statements inside a process execute in sequential order
		
		-- IF THEN ELSE statement
		IF Mux_Control = '0' THEN Mux_Out3 <= A; 
			ELSE Mux_out3 <= B; END IF;
		
		-- CASE statement
		CASE Mux_Control IS
			WHEN '0' =>
			    Mux_Out4 <= A;
			WHEN '1' =>
				Mux_Out4 <= B;
			-- OTHERS case required, STD_LOGIC has values other than "0" or "1"	
			WHEN OTHERS =>
				Mux_Out4 <= A;
		END CASE;
		
	END PROCESS;

END behavior;

