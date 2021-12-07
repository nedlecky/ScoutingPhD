library IEEE;
use IEEE.STD_LOGIC_1164.all;

ENTITY st_mach IS

	PORT(clk, reset						: IN	STD_LOGIC;
		Input1, Input2		: IN	STD_LOGIC;
		Output1	: OUT	STD_LOGIC);

END st_mach;

ARCHITECTURE A OF st_mach IS
-- Enumerated Data Type for State
	TYPE STATE_TYPE IS (state_A, state_B, state_C);
	SIGNAL state: STATE_TYPE;
BEGIN
	PROCESS (reset, clk)
	BEGIN
		IF reset = '1' THEN
-- Reset State
			state <= state_A;
		ELSIF clk'EVENT AND clk = '1' THEN
-- Define State Transistions in Case Statement
			CASE state IS
				WHEN state_A =>
					IF Input1 = '0' THEN
						state <= state_B;
					ELSE
						state <= state_C;
					END IF;
				WHEN state_B =>
						state <= state_C;
				WHEN state_C =>
					IF Input2 = '1' THEN
						state <= state_A;
					END IF;

			END CASE;
		END IF;
	END PROCESS;
-- Define State Machine Outputs
	WITH state SELECT
		Output1 	<=	'0'	WHEN state_A,
						'1'	WHEN state_B,
						'0'	WHEN state_C;
END a;

