--
--
-- State machine to control trains
--
--

LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;


ENTITY Tcontrol IS
	PORT(reset, clock, sensor1, sensor2		: IN std_logic;
		sensor3, sensor4, sensor5			: IN std_logic;
     	switch1, switch2, switch3			: OUT std_logic;
     	track1, track2, track3, track4		: OUT std_logic;
     	dirA, dirB 							: OUT std_logic_vector(1 DOWNTO 0));
END Tcontrol;


ARCHITECTURE a OF Tcontrol IS
	TYPE STATE_TYPE IS (ABout,Ain,Bin,Astop,Bstop);
	SIGNAL state						: STATE_TYPE;
    SIGNAL sensor12, sensor13, sensor24	: std_logic_vector(1 DOWNTO 0);

BEGIN
	PROCESS (clock)
	BEGIN
				-- Reset to this state
		IF reset = '1' THEN
			state <= ABout;
		ELSIF clock'EVENT AND clock = '1' THEN
				-- Case statement to determine next state
			CASE state IS
				WHEN ABout =>
					CASE Sensor12 IS
						WHEN "00" => state <= About;
						WHEN "01" => state <= Bin;
						WHEN "10" => state <= Ain;
						WHEN "11" => state <= Ain;
						WHEN OTHERS => state <= ABout;
					END CASE;

				WHEN Ain =>
					CASE Sensor24 IS
						WHEN "00" => state <= Ain;
						WHEN "01" => state <= ABout;
						WHEN "10" => state <= Bstop;
						WHEN "11" => state <= ABout;
						WHEN OTHERS => state <= ABout;
					END CASE;

				WHEN Bin =>
					CASE Sensor13 IS
						WHEN "00" => state <= Bin;
						WHEN "01" => state <= ABout;
						WHEN "10" => state <= Astop;
						WHEN "11" => state <= About;
						WHEN OTHERS => state <= ABout;
					END CASE;

				WHEN Astop =>
					IF Sensor3 = '1' THEN
						state <= Ain;
                    ELSE
                        state <= Astop;
					END IF;

				WHEN Bstop =>
					IF Sensor4 = '1' THEN
						state <= Bin;
                    ELSE
                        state <= Bstop;
					END IF;

			END CASE;
		END IF;
	END PROCESS;

			-- combine bits for case statements above
			-- "&" operator combines bits
	sensor12 <= sensor1 & sensor2;
	sensor13 <= sensor1 & sensor3;
	sensor24 <= sensor2 & sensor4;

	
				-- These outputs do not depend on the state
	Track1  <= '0';
    Track4  <= '0';
    Switch3 <= '0';

				-- Outputs that depend on state
	WITH state SELECT
		Track3 	<=	'1'	WHEN ABout,
					'1'	WHEN Ain,
					'1'	WHEN Bin,
                	'1' WHEN Astop,
                	'1' WHEN Bstop;
	WITH state SELECT
		Track2	<=	'0'	WHEN ABout,
					'0'	WHEN Ain,
					'1'	WHEN Bin,
                	'1' WHEN Astop,
                	'0' WHEN Bstop;
	WITH state SELECT
		Switch1 <=	'0'	WHEN ABout,
					'0'	WHEN Ain,
					'1'	WHEN Bin,
                	'1' WHEN Astop,
                	'0' WHEN Bstop;
	WITH state SELECT
		Switch2 <=	'0'	WHEN ABout,
					'0'	WHEN Ain,
					'1'	WHEN Bin,
                	'1' WHEN Astop,
                	'0' WHEN Bstop;
	WITH state SELECT
		DirA 	<=	"01" WHEN ABout,
					"01" WHEN Ain,
					"01" WHEN Bin,
                	"00" WHEN Astop,
                	"01" WHEN Bstop;
	WITH state SELECT
		DirB 	<=	"01" WHEN ABout,
					"01" WHEN Ain,
					"01" WHEN Bin,
                	"01" WHEN Astop,
                	"00" WHEN Bstop;
END a;


