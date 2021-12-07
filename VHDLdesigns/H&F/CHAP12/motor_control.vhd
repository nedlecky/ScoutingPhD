LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.ALL;
USE  IEEE.STD_LOGIC_ARITH.ALL;
USE  IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY motor_control IS
	PORT       (clock_1khz			: IN	STD_LOGIC;
		lmotor_dir, rmotor_dir		: IN STD_LOGIC;
		lmotor_speed, rmotor_speed	: IN STD_LOGIC;
		lmotor, rmotor		: OUT	STD_LOGIC);
END motor_control;

ARCHITECTURE a OF motor_control IS
	SIGNAL count_motor: STD_LOGIC_VECTOR( 4 DOWNTO 0 ); 
BEGIN
	PROCESS
	       BEGIN
				-- Count_motor is a 20ms  timer
		WAIT UNTIL clock_1Khz'EVENT AND clock_1Khz = '1';
			IF count_motor /=19 THEN
			        count_motor <= count_motor + 1;
			ELSE
			        count_motor <= "00000";
			END IF;
			IF count_motor >= 17 AND count_motor < 18 THEN
				-- Don't generate any pulse for speed = 0
				IF lmotor_speed = '0' THEN 
				        lmotor <= '0'; 
				ELSE
				        lmotor <= '1';
				END IF;
				IF rmotor_speed = '0' THEN 
				        rmotor <= '0'; 
				ELSE
				        rmotor <= '1';
				END IF;
				-- Generate a 1 or 2ms pulse for each motor
				-- depending on direction
				-- reverse directions between the two motors because
				-- of servo mounting on the UP1-bot base
			ELSIF count_motor >=18 AND count_motor <19 THEN
				IF lmotor_speed /= '0' THEN
				        CASE lmotor_dir IS
					-- FORWARD
					WHEN '0' =>
					  	lmotor <= '1';
					-- REVERSE
					WHEN '1' =>
						lmotor <= '0';
					WHEN OTHERS => NULL;
					END CASE;
				ELSE
					lmotor <= '0';
				END IF;
				IF rmotor_speed /= '0' THEN
				        CASE rmotor_dir IS
					-- FORWARD
					WHEN '1' =>
					   	rmotor <= '1';
					-- REVERSE
					WHEN '0' =>
						rmotor <= '0';
					WHEN OTHERS => NULL;
					END CASE;
				ELSE
					rmotor <= '0';
				END IF;
			ELSE
				lmotor <= '0';
				rmotor <= '0';
			END IF;
	END PROCESS;
END a;

