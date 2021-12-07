--------------------------------------------------------------------------
-- Simple Robot Control Program
--------------------------------------------------------------------------
library IEEE;
use  IEEE.STD_LOGIC_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY robot_ctl IS
	PORT(
		clock_1KHz	: IN STD_LOGIC;
		reset		: IN STD_LOGIC;
		fwdrev		: IN STD_LOGIC;
		direction	: IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		speed		: IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		right_out	: OUT STD_LOGIC;
		left_out	: OUT STD_LOGIC;
		fwd_out		: OUT STD_LOGIC;
		rev_out		: OUT STD_LOGIC );
END robot_ctl;

ARCHITECTURE a OF robot_ctl IS

	TYPE SpeedArrayType     is array ( 0 to 7 ) of STD_LOGIC_VECTOR(15 downto 0);
	TYPE DirectionArrayType is array ( 0 to 3 ) of STD_LOGIC_VECTOR( 15 downto 0);
	TYPE STATE_TYPE IS ( stop2, stopfwd1, stoprev1, forward, pauseF, reverse, pauseR );

	SIGNAL DirectionArray : DirectionArrayType;
	SIGNAL SpeedArray     : SpeedArrayType;
	SIGNAL state          : STATE_TYPE;

	SIGNAL y_left_out, y_right_out 		: STD_LOGIC_VECTOR(  15 downto 0 );
	SIGNAL y_fwd_out, y_rev_out    		: STD_LOGIC_VECTOR( 15 downto 0 );
	SIGNAL DirectionCount          		: INTEGER RANGE 0 TO  15;
	SIGNAL SpeedCount              		: INTEGER RANGE 0 TO 15;
	SIGNAL int_speed, old_speed		    : STD_LOGIC_VECTOR( 2 downto 0 );
	SIGNAL counter                 		: INTEGER RANGE 0 TO 255;

BEGIN

	PROCESS ( clock_1Khz, reset )
	BEGIN
		IF reset = '0' THEN
			state          <= stop2;
			DirectionCount <= 0;
			SpeedCount     <= 0;
			counter        <= 0;
		ELSIF clock_1Khz'EVENT AND clock_1Khz = '1' THEN
			CASE state IS
				WHEN forward =>
					IF fwdrev = '1' AND int_speed /= "000" THEN
					   state <= forward;
					ELSE
					   state <= PauseF;
					END IF;
				WHEN pauseF =>
					IF int_speed = "000" THEN
					   state <= stopfwd1;
					ELSE 
	                   state <= reverse;
					END IF;
				WHEN reverse =>
					IF  fwdrev = '0' AND int_speed /= "000" THEN
						state <= reverse;
					ELSE
						state <= pauseR;
					END IF;
				WHEN pauseR =>
					IF int_speed = "000" THEN
					   state <= stoprev1;
					ELSE 
	                   state <= forward;
					END IF;
				WHEN stopfwd1 =>
					IF counter > 254 THEN
						state   <= stop2;
					ELSE
						counter <= counter + 1;
						state   <= stopfwd1;
					END IF;
				WHEN stoprev1 =>
					IF counter > 125 THEN
						state   <= stop2;
					ELSE
						counter <= counter + 1;
						state   <= stoprev1;
					END IF;
				WHEN stop2 =>
					counter <= 0;
					IF int_speed = "000" THEN
						state <= stop2;
					ELSIF fwdrev = '1' THEN
						state <= forward;
					ELSE
						state <= reverse;
					END IF;
			END CASE;

			DirectionCount <= DirectionCount + 1;
			SpeedCount     <= SpeedCount     + 1;

		END IF;
	END PROCESS;

--	int_speed <= "000" WHEN ( radio_lt = '1' OR radio_rt = '1' OR radio_fwd = '1' OR radio_bk = '1' ) ELSE tmp;
 
	PROCESS( direction )
	BEGIN
		IF direction(2) = '1' THEN
       		y_left_out  <= DirectionArray( CONV_INTEGER( direction(1 DOWNTO 0) ) );
			y_right_out <= DirectionArray( 0 );
		ELSE
			y_left_out  <= DirectionArray( 0 );
	   		y_right_out <= DirectionArray( CONV_INTEGER( direction(1 DOWNTO 0) ) ); 
		END IF;
	END PROCESS;

	PROCESS( speed )
	BEGIN
		old_speed <= int_speed;
		int_speed <= speed;
	END PROCESS;

--	PROCESS( speed )
--	BEGIN
--		old_speed <= tmp;
--		tmp       <= speed;
--	END PROCESS;

	WITH state SELECT
		y_fwd_out 	<=	SpeedArray( CONV_INTEGER(int_speed) )  WHEN forward,
					  	SpeedArray(           0             )  WHEN pauseF,
					  	SpeedArray(           0             )  WHEN reverse,
					  	SpeedArray(           0             )  WHEN pauseR,
					  	SpeedArray(           0             )  WHEN stopfwd1,
					  	SpeedArray(           7             )  WHEN stoprev1,
					  	SpeedArray(           0             )  WHEN stop2;

	WITH state SELECT
		y_rev_out 	<=	SpeedArray(           0             )  WHEN forward,
					  	SpeedArray(           0             )  WHEN pauseF,
					  	SpeedArray( CONV_INTEGER(int_speed) )  WHEN reverse,
					  	SpeedArray(           0             )  WHEN pauseR,
					  	SpeedArray(           7             )  WHEN stopfwd1,
					  	SpeedArray(           0             )  WHEN stoprev1,
					  	SpeedArray(           0             )  WHEN stop2;

	left_out  <= y_left_out(  DirectionCount  );
	right_out <= y_right_out( DirectionCount  );
	fwd_out   <= y_fwd_out(     SpeedCount    );
	rev_out   <= y_rev_out(     SpeedCount    );

	DirectionArray(0) <= "0000000000000000";
	DirectionArray(1) <= "0110111110111111";
	DirectionArray(2) <= "0111111011111101";
	DirectionArray(3) <= "1111111111111111";

	SpeedArray(0)     <= "0000000000000000";
	SpeedArray(1)     <= "0000000000000011";
	SpeedArray(2)     <= "0000000000000111";
	SpeedArray(3)     <= "0000000000001111";
	SpeedArray(4)     <= "0000000000011111";
	SpeedArray(5)     <= "0000000000111111";
	SpeedArray(6)     <= "0000000001111111";
	SpeedArray(7)     <= "1111111111111111";

END a;

