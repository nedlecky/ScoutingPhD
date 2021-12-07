--------------------------------------------------------------------------
-- Simple Robot Control Program
--------------------------------------------------------------------------
-- Left is left IR sensor -   1=object to left
-- Right is rigth IR sensor - 1=object to right
-- Lmotor_dir    1=forward 0=reverse
-- Rmotor_dir    1=forward 0=reverse
-- Lmotor_speed   111=fast 000=slow
-- Rmotor_speed   111=fast 000=slow
--
library IEEE;
use  IEEE.STD_LOGIC_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY my_ctl IS
	PORT(
		clock_10hz, clock_1hz, left, right, pb0, pb1: IN	STD_LOGIC;
		lmotor_speed, rmotor_speed		: OUT	STD_LOGIC_VECTOR(2 downto 0);
		lmotor_dir, rmotor_dir			: OUT	STD_LOGIC);
END my_ctl;

ARCHITECTURE a OF my_ctl IS

	TYPE STATE_TYPE IS (forward, forward2, turn1,turn2, obstacle);
	SIGNAL state: STATE_TYPE;
	SIGNAL pb_hit : STD_LOGIC;
	SIGNAL timer: STD_LOGIC_VECTOR(7 DOWNTO 0);

BEGIN
-- hit pb1 to start robot and pb0 to stop or reset
	PROCESS (pb0, pb1)
		BEGIN
			IF pb0 = '0' THEN pb_hit <= '0';
			ELSIF pb1'EVENT and pb1 = '1' THEN
-- pbhit powers up a zero and will be high only after pushbutton is hit
-- this is used to disable motors until pushbutton is hit
-- the other pushbutton turns off motors
-- this makes it easier to handle robot during download
				pb_hit <= '1';
			END IF;
	END PROCESS;

-- sets motor speed to zero until pushbutton is hit to start motors
	lmotor_speed <= "000" WHEN pb_hit = '0' ELSE "111";
	rmotor_speed <= "000" WHEN pb_hit = '0' ELSE "111";

-- State Machine to Control Robot

	PROCESS (clock_10hz, pb1)
	BEGIN
-- Hit pb1 to reset state machine
		IF pb1 = '0' THEN
			state <= forward;
		ELSIF clock_10hz'EVENT AND clock_10hz = '1' THEN
			CASE state IS
-- Move Forward for Three Seconds
				WHEN forward =>
					IF NOT( LEFT='1' OR RIGHT='1') THEN
						state <= forward2;
-- reset interval timer
						timer <= "00000000";
					ELSE
						state <= obstacle;
					END IF;

				WHEN forward2 =>
					IF NOT(LEFT='1' OR RIGHT='1') THEN
						IF timer > 30 THEN
							state <= turn1;
						ELSE
-- wait for three second interval
-- 3 seconds will be a count of 30 with a 10Hz clock
							timer <= timer + 1;
							state <= forward2;
						END IF;
					ELSE
						state <= obstacle;
					END IF;

-- the two turn states do a 180 degree turn
				WHEN turn1 =>
					IF NOT(LEFT='1' OR RIGHT='1') THEN
						state <= turn2;
-- reset interval timer
						timer <= "00000000";
					ELSE
						state <= obstacle;
					END IF;
				WHEN turn2 =>
					IF NOT(LEFT='1' OR RIGHT='1') THEN
-- rotate for 2.4 seconds on robots with small wheels 
-- rotate for 1.5 seconds on robots with big wheels
						IF timer < 15 THEN
							state <= turn2;
							timer <= timer + 1;
						ELSE
							state <= forward;
						END IF;
					ELSE
						state <= obstacle;
					END IF;

-- go to this state if an obstacle is encountered
				WHEN obstacle =>
					IF (LEFT='1' OR RIGHT='1') THEN
						state <= obstacle;
					ELSE
						state <= forward;
					END IF;
			END CASE;
		END IF;
	END PROCESS;

-- specify outputs of state machine
	WITH state SELECT
		lmotor_dir 	<=	'1'	WHEN	forward,
						'1'	WHEN	forward2,
						'1'	WHEN	turn1,
						'1'	WHEN	turn2,
-- simple way to avoid obstacles
-- when a sensor indicates an obstacles it turns away from obstacle
						NOT right	WHEN	obstacle;

	WITH state SELECT
		rmotor_dir 	<=	'1'	WHEN	forward,
						'1'	WHEN	forward2,
						'0'	WHEN	turn1,
						'0'	WHEN	turn2,
-- simple way to avoid obstacles
-- when a sensor indicates an obstacles it turns away from obstacle
						NOT left	WHEN	obstacle;

END a;

