--
--
-- CPLD Tain VHDL Module - Train Control State Machine for Altera University Board 
-- Uses Flex 10K20 Device
--
-- VGA output displays train and switch state
-- Students supply train_control state machine (tcontrol.vhd) to control train
-- PB1 is run/stop 
-- PB2 is reset 
-- Sw0..3 is trainB speed
-- Sw7..4 is trainA speed
-- SensorX are track sensors for train, train near=1 (inputs for state machine)
-- SwitchX are track switches, Sw=0 connects to outside track
-- TrackX select power source A=0 or B=1 for track segment
-- DirX selects direction: 00-stop  01-counterclockwise  10-clockwise
-- Note: Screen blinks when trains crash or go through switch in wrong direction
--
--                -----------Sw3--------------
--                | T1         \T4        T1 |
--                |     -------|-------      |
--                |     | T3   |   T3 |      |
--                |     |      | S5   |      |
--             S1 |   S2|             | S3   | S4
--                |     \     T2      /      |
--                ------Sw1---------Sw2-------
--
--                       Track Layout
--
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;
LIBRARY lpm;
USE lpm.lpm_components.ALL;


ENTITY train IS

Generic(ADDR_WIDTH: integer := 12; DATA_WIDTH: integer := 1);

   PORT( SIGNAL PB1, PB2, Clock : in std_logic;
        SIGNAL LSB_a, LSB_b, LSB_c, LSB_d, LSB_e, LSB_f, LSB_g, LSB_dp,
        	MSB_a, MSB_b, MSB_c, MSB_d, MSB_e, MSB_f, MSB_g, MSB_dp : out std_logic;               
        SIGNAL Red,Green,Blue : out std_logic;
        SIGNAL Horiz_sync,Vert_sync : out std_logic;
        SIGNAL MOUSE_DATA: in std_logic;
        SIGNAL MOUSE_CLK : in std_logic;
        SIGNAL Flex_Switch_1, Flex_Switch_2, Flex_Switch_3, Flex_Switch_4: in std_logic;
        SIGNAL Flex_Switch_5, Flex_Switch_6, Flex_Switch_7, Flex_Switch_8: in std_logic;
	-- Output All Train control state machine I/Os
		SIGNAL o_sensor1, o_sensor2, o_sensor3, o_sensor4, o_sensor5 : out std_logic;
		SIGNAL o_switch1, o_switch2, o_switch3 :  out std_logic;
		SIGNAL o_dirA1, o_dirA0, o_dirB1, o_dirB0:  out std_logic;
		SIGNAL o_track1, o_track2, o_track3, o_track4 : out std_logic;
        SIGNAL o_clock, o_reset : out std_logic);
  
		
END train;

architecture behavior of train is

COMPONENT Tcontrol
PORT(reset, clock, sensor1, sensor2, sensor3, sensor4, sensor5: in std_logic;
     switch1, switch2, switch3: out std_logic;
     track1, track2, track3, track4: out std_logic;
     DirA, DirB : out std_logic_vector(1 DOWNTO 0));
END COMPONENT;

SIGNAL speed_A, speed_B: std_logic_vector(3 DOWNTO 0);
SIGNAL switch, switch_sync, cycle_count: std_logic_vector(7 DOWNTO 0);
SIGNAL speed_signal_A, speed_signal_B, train_run, train_stop, reset: std_logic;


-- Train Signals for virtual train display
SIGNAL trainArow, trainAcol: std_logic_vector(6 DOWNTO 0);
SIGNAL next_trainArow, next_trainAcol: std_logic_vector(6 DOWNTO 0);
SIGNAL next_trainBrow, next_trainBcol: std_logic_vector(6 DOWNTO 0);
SIGNAL old_trainArow, old_trainAcol: std_logic_vector(6 DOWNTO 0);
SIGNAL old2_trainArow, old2_trainAcol: std_logic_vector(6 DOWNTO 0);
SIGNAL trainBrow, trainBcol: std_logic_vector(6 DOWNTO 0);
SIGNAL old_trainBrow, old_trainBcol: std_logic_vector(6 DOWNTO 0);
SIGNAL old2_trainBrow, old2_trainBcol: std_logic_vector(6 DOWNTO 0);
SIGNAL col_adjustA, row_adjustA: std_logic_vector(6 DOWNTO 0);
SIGNAL col_adjustB, row_adjustB: std_logic_vector(6 DOWNTO 0);
SIGNAL C10A,C30A,C40A,C50A,C70A,R10A,R30A,R70A,R4xA,R5xA,T1,T2,T3,T4: boolean;
SIGNAL C10B,C30B,C40B,C50B,C70B,R10B,R30B,R70B,R4xB,R5xB: boolean;
SIGNAL crash, crashA, crashB, second: std_logic;
SIGNAL sensor, old_sensor: std_logic_vector(4 DOWNTO 0);

-- Train Signals for state machine control
SIGNAL sensor1, sensor2, sensor3, sensor4, sensor5 : std_logic;
SIGNAL switch1, switch2, switch3 :  std_logic;
SIGNAL DirA, DirB:  std_logic_vector(1 DOWNTO 0);
SIGNAL track1, track2, track3, track4 : std_logic;

-- Video Display Signals   
SIGNAL rom_address: std_logic_vector(11 DOWNTO 0);
SIGNAL H_count,V_count: std_logic_vector(9 DOWNTO 0);
SIGNAL F_count: std_logic_vector(4 DOWNTO 0);
SIGNAL Color_count: std_logic_vector(3 DOWNTO 0);
SIGNAL data: std_logic_vector(0 DOWNTO 0);
SIGNAL Red_Data, Green_Data, Blue_Data, we, slow_clock: std_logic;
SIGNAL Red_Mux_Data, Green_Mux_Data, Blue_Mux_Data: std_logic;
SIGNAL Red_Display_Data, Green_Display_Data, Blue_Display_Data, display_item, Power_on: std_logic;

-- Signals for Video Memory for Pixel Data
SIGNAL address: std_logic_vector(13 DOWNTO 0);
SIGNAL col_address, row_address: std_logic_vector(6 DOWNTO 0);
SIGNAL pixel_col_count, pixel_row_count: std_logic_vector(5 DOWNTO 0);
SIGNAL rom_output: std_logic_vector(0 DOWNTO 0);

-- Signals for LED Display
SIGNAL LSB,MSB: std_logic_vector(3 DOWNTO 0);
SIGNAL LSB_7SEG,MSB_7SEG: std_logic_vector(6 DOWNTO 0);

-- Signals for Push buttons
SIGNAL PB1_sync, PB2_sync, PB2_Single_Pulse, PB1_Single_Pulse: std_logic; 
SIGNAL PB2_debounced, PB1_debounced, PB2_debounced_Sync, PB1_debounced_Sync: std_logic; 
SIGNAL PB1_debounced_delay, PB2_debounced_delay, Debounce_clock: std_logic;
SIGNAL SHIFT_PB1, SHIFT_PB2: std_logic_vector(3 DOWNTO 0);

constant H_max : std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(799,10); 
-- 799 is max horiz count
constant V_max : std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(524,10); 
-- 524 is max vert count
SIGNAL video_on, video_on_H, video_on_V: std_logic;

BEGIN           
------------------------------------------------------------------------------
-- 64 by 64 by 1 video rom for pixel background data
--
back_rom: lpm_rom

      GENERIC MAP (lpm_widthad => ADDR_WIDTH,
        lpm_outdata => "UNREGISTERED",
        lpm_address_control => "UNREGISTERED",
        lpm_file => "train.mif",
         lpm_width => DATA_WIDTH)
-- Reads in mif file for initial data - train track background
     
PORT MAP (address => rom_address(11 DOWNTO 0), q => rom_output);

CONTROL: Tcontrol
-- Use Student supplied module for Train control
 port map( reset => reset, clock => slow_clock,
           sensor1 => sensor1, sensor2 => sensor2,
           sensor3 => sensor3, sensor4 => sensor4,
           sensor5 => sensor5,
           switch1 => switch1, switch2 => switch2,
           switch3 => switch3,
           track1 => track1, track2 => track2,
           track3 => track3, track4 => track4,
           DirA => DirA, DirB => DirB);


-- Copy state machine I/Os to FLEX chip output pins for use by logic analyzer
o_sensor1 <= sensor1;     
o_sensor2 <= sensor2;     
o_sensor3 <= sensor3;     
o_sensor4 <= sensor4;     
o_sensor5 <= sensor5;     
o_switch1 <= switch1;
o_switch2 <= switch2;
o_switch3 <= switch3;
o_track1 <= track1;		
o_track2 <= track2;		
o_track3 <= track3;		
o_track4 <= track4;
o_dirA1 <= DirA(1);
o_dirA0 <= DirA(0);
o_dirB1 <= DirB(1);
o_dirB0 <= DirB(0);
o_clock <= slow_clock;
o_reset <= reset;

		
-- Colors for pixel data on video SIGNAL
-- address video_ram for pixel background color data
-- IF display_item='1' use display data instead of background
Red_Mux_Data <= rom_output(0) When display_item='0' else red_display_data;
Green_Mux_Data <= rom_output(0) When display_item='0' else green_display_data;
Blue_Mux_Data <= '1' When display_item='0' else blue_display_data;

Red_Data <=  (Red_Mux_Data xor (Crash and Second));
Green_Data <= (Green_Mux_Data xor (Crash and Second));
Blue_Data <= Blue_Mux_Data;

rom_address(11 DOWNTO 6) <= row_address(6 DOWNTO 1);
rom_address(5 DOWNTO 0) <= col_address(6 DOWNTO 1);

reset <= PB2_Debounced_SYNC;
slow_clock <= Debounce_Clock;


Red <=   Red_Data and video_on;
Green <= Green_Data and video_on;
Blue <=  Blue_Data and video_on;

-- video_on turns off pixel data when not in the view area
video_on <= video_on_H and video_on_V;
Power_on <='0';

-- Combine Flex Dip Switch Inputs into Switch vector
Switch <= Flex_Switch_8 & Flex_Switch_7 & Flex_Switch_6 & Flex_Switch_5 &
          Flex_Switch_4 & Flex_Switch_3 & Flex_Switch_2 & Flex_Switch_1;

-- Controls Speed of TrainA with input from Flex Switches 7..4
SPEED_TRAINA: PROCESS 
BEGIN
  WAIT UNTIL (slow_clock'Event) and (slow_clock='1');
if Speed_A = Switch_Sync(7 DOWNTO 4) THEN
 Speed_A <="0000"; 
 Speed_Signal_A <='1';
ELSE
 Speed_A <= Speed_A + 1;
 Speed_Signal_A <='0';
END IF;
END PROCESS SPEED_TRAINA;

SPEED_TRAINB: PROCESS 
BEGIN
  WAIT UNTIL (slow_clock'Event) and (slow_clock='1');
if Speed_B = Switch_Sync(3 DOWNTO 0) THEN
 Speed_B <="0000"; 
 Speed_Signal_B <='1';
ELSE
 Speed_B <= Speed_B + 1;
 Speed_Signal_B <= '0';
END IF;
END PROCESS SPEED_TRAINB;

-- Makes PB1 the Train Run/Step Button
PAUSE_TRAIN: PROCESS (PB1_DEBOUNCED_SYNC)
BEGIN
  WAIT UNTIL (PB1_DEBOUNCED_SYNC'Event) and (PB1_DEBOUNCED_SYNC='1');
    Train_Run <= Not Train_Run;
    Old_sensor <= Sensor;
End PROCESS PAUSE_TRAIN;

Sensor <= Sensor5 & Sensor4 & Sensor3 & Sensor2 & Sensor1;

-- Stops Train only at Sensor Change for Single Step
STEP_TRAIN: PROCESS (slow_clock)
BEGIN
  WAIT UNTIL (slow_clock'event) and (slow_clock = '1');
   IF Train_run = '1' THEN Train_stop <= '1'; ELSE
   IF (Sensor /= Old_Sensor) THEN 
    Train_stop <= '0';
   END IF;
   END IF;
End PROCESS STEP_TRAIN;

-- Move Train

-- Generate boolean signals for each track segment
-- to determine train's current location

C10A <= (trainAcol(6 DOWNTO 1) = "001000");
C30A <= (trainAcol(6 DOWNTO 1) = "011000");
C40A <= (trainAcol(6 DOWNTO 1)= "100000");
C50A <= (trainAcol(6 DOWNTO 1) = "101000");
C70A <= (trainAcol(6 DOWNTO 1) = "111000");
R10A <= (trainArow(6 DOWNTO 1) = "001000");
R30A <= (trainArow(6 DOWNTO 1) = "011000");
R4xA <= (trainArow(6 DOWNTO 4) = "100");
R5xA <= (trainArow(6 DOWNTO 4) = "101");
R70A <= (trainArow(6 DOWNTO 1) = "111000");

C10B <= (trainBcol(6 DOWNTO 1) = "001000");
C30B <= (trainBcol(6 DOWNTO 1) = "011000");
C40B <= (trainBcol(6 DOWNTO 1)= "100000");
C50B <= (trainBcol(6 DOWNTO 1) = "101000");
C70B <= (trainBcol(6 DOWNTO 1) = "111000");
R10B <= (trainBrow(6 DOWNTO 1) = "001000");
R30B <= (trainBrow(6 DOWNTO 1) = "011000");
R4xB <= (trainBrow(6 DOWNTO 4) = "100");
R5xB <= (trainBrow(6 DOWNTO 4) = "101");
R70B <= (trainBrow(6 DOWNTO 1) = "111000");

T1 <= (track1 = '1');
T2 <= (track2 = '1');
T3 <= (track3 = '1');
T4 <= (track4 = '1');

Next_TrainAcol <= TrainAcol + col_adjustA;
Next_TrainArow <= TrainArow + row_adjustA;
Next_TrainBcol <= TrainBcol + col_adjustB;
Next_TrainBrow <= TrainBrow + row_adjustB;
Crash <= CrashA or CrashB;

MOVE_TRAINA: PROCESS
BEGIN 
   WAIT UNTIL (slow_clock'Event) and (slow_clock = '1');
IF reset='1' or trainArow = "0000000" THEN
 trainArow <= "0010000";
 trainAcol <= "0100000";
 old_trainArow <= "0010000";
 old_trainAcol <= "0100010";
 col_adjustA <= "0000000";
 row_adjustA <= "0000000";
 crashA <='0';
ELSE

IF (trainArow=trainBrow) and (trainAcol=trainBcol) THEN 
 crashA <='1';
END IF;

IF (Speed_Signal_A = '1') and (crash='0')  and (Train_stop = '1') THEN

Old2_TrainAcol <= Old_TrainAcol;
Old2_TrainArow <= Old_TrainArow;
Old_TrainAcol <= TrainAcol;
Old_TrainArow <= TrainArow;
TrainAcol <= Next_TrainAcol;
TrainArow <= Next_TrainArow;
-----------------------------------------------------------
-- Track 1
IF R10A and not(C10A) and not(C70A) and not(C40A) THEN
-- is train moving counterclockwise?
 IF (not(T1) and DirA(0)='1') or (T1 and DirB(0)='1') THEN
  col_adjustA <= "1111111";
  row_adjustA <= "0000000";
 ELSE
-- train is moving clockwise
  IF (not(T1) and DirA(1)='1') or (T1 and DirB(1)='1') THEN
   col_adjustA <= "0000001";
   row_adjustA <= "0000000";
  ELSE
   col_adjustA <= "0000000";
   row_adjustA <= "0000000";
  END IF;
 END IF;
ELSE

IF R10A and C10A THEN
-- is train moving counterclockwise?
 IF (not(T1) and DirA(0)='1') or (T1 and DirB(0)='1') THEN
  col_adjustA <= "0000000";
  row_adjustA <= "0000001";
 ELSE
-- train is moving clockwise
 IF (not(T1) and DirA(1)='1') or (T1 and DirB(1)='1') THEN
  col_adjustA <= "0000001";
  row_adjustA <= "0000000";
 ELSE
  col_adjustA <= "0000000";
  row_adjustA <= "0000000";
 END IF;
 END IF;
ELSE

-- Switch 3 Location
IF R10A and C40A THEN
 IF Switch3 = '0' THEN
-- Switch connected to outside track
-- is train moving counterclockwise?
 IF (not(T1) and DirA(0)='1') or (T1 and DirB(0)='1') THEN
  col_adjustA <= "1111111";
  row_adjustA <= "0000000";
-- crash if going wrong way into switch
  IF old_trainArow > "0010000" THEN crashA <= '1'; END IF;
 ELSE
-- train is moving clockwise
 IF (not(T1) and DirA(1)='1') or (T1 and DirB(1)='1') THEN
  col_adjustA <= "0000001";
  row_adjustA <= "0000000";
 ELSE
  col_adjustA <= "0000000";
  row_adjustA <= "0000000";
 END IF;
 END IF;
ELSE
-- Switch connected to inside track
-- is train moving counterclockwise?
 IF (not(T1) and DirA(0)='1') or (T1 and DirB(0)='1') THEN
  col_adjustA <= "1111111";
  row_adjustA <= "0000000";
-- crash if going wrong way into switch
  IF old_trainAcol > "1000001" THEN crashA <= '1'; END IF;
 ELSE
-- train is moving clockwise
 IF (not(T1) and DirA(1)='1') or (T1 and DirB(1)='1') THEN
  col_adjustA <= "0000000";
  row_adjustA <= "0000001";
 ELSE
  col_adjustA <= "0000000";
  row_adjustA <= "0000000";
 END IF;
 END IF;
 END IF;
ELSE

IF R10A and C70A THEN
-- is train moving counterclockwise?
 IF (not(T1) and DirA(0)='1') or (T1 and DirB(0)='1') THEN
  col_adjustA <= "1111111";
  row_adjustA <= "0000000";
 ELSE
-- train is moving clockwise
 IF (not(T1) and DirA(1)='1') or (T1 and DirB(1)='1') THEN
  col_adjustA <= "0000000";
  row_adjustA <= "0000001";
 ELSE
  col_adjustA <= "0000000";
  row_adjustA <= "0000000";
 END IF;
 END IF;
ELSE

IF C10A and not(R10A) and not(R70A) THEN
-- is train moving counterclockwise?
 IF (not(T1) and DirA(0)='1') or (T1 and DirB(0)='1') THEN
  col_adjustA <= "0000000";
  row_adjustA <= "0000001";
 ELSE
-- train is moving clockwise
 IF (not(T1) and DirA(1)='1') or (T1 and DirB(1)='1') THEN
  col_adjustA <= "0000000";
  row_adjustA <= "1111111";
 ELSE
  col_adjustA <= "0000000";
  row_adjustA <= "0000000";
 END IF;
 END IF;
ELSE

IF C10A and R70A THEN
-- is train moving counterclockwise?
 IF (not(T1) and DirA(0)='1') or (T1 and DirB(0)='1') THEN
  col_adjustA <= "0000001";
  row_adjustA <= "0000000";
 ELSE
-- train is moving clockwise
 IF (not(T1) and DirA(1)='1') or (T1 and DirB(1)='1') THEN
  col_adjustA <= "0000000";
  row_adjustA <= "1111111";
 ELSE
  col_adjustA <= "0000000";
  row_adjustA <= "0000000";
 END IF;
 END IF;
ELSE

IF C70A and not(R70A) and not(R10A) THEN
-- is train moving counterclockwise?
 IF (not(T1) and DirA(0)='1') or (T1 and DirB(0)='1') THEN
  col_adjustA <= "0000000";
  row_adjustA <= "1111111";
 ELSE
-- train is moving clockwise
 IF (not(T1) and DirA(1)='1') or (T1 and DirB(1)='1') THEN
  col_adjustA <= "0000000";
  row_adjustA <= "0000001";
 ELSE
  col_adjustA <= "0000000";
  row_adjustA <= "0000000";
 END IF;
 END IF;
ELSE

-- Track 2 When col>=30 and <=50 else Track 1
IF R70A and not(C10A) and not(C70A) and not(C30A) and not(C50A) THEN
 IF trainAcol >= "0110000" and trainAcol <= "1010001" THEN
-- Track 2 region
-- is train moving counterclockwise?
 IF (not(T2) and DirA(0)='1') or (T2 and DirB(0)='1') THEN
  col_adjustA <= "0000001";
  row_adjustA <= "0000000";
 ELSE
-- train is moving clockwise
 IF (not(T2) and DirA(1)='1') or (T2 and DirB(1)='1') THEN
  col_adjustA <= "1111111";
  row_adjustA <= "0000000";
 ELSE
  col_adjustA <= "0000000";
  row_adjustA <= "0000000";
 END IF;
 END IF;
ELSE

-- Track 1 region
-- is train moving counterclockwise?
 IF (not(T1) and DirA(0)='1') or (T1 and DirB(0)='1') THEN
  col_adjustA <= "0000001";
  row_adjustA <= "0000000";
 ELSE
-- train is moving clockwise
 IF (not(T1) and DirA(1)='1') or (T1 and DirB(1)='1') THEN
  col_adjustA <= "1111111";
  row_adjustA <= "0000000";
 ELSE
  col_adjustA <= "0000000";
  row_adjustA <= "0000000";
 END IF;
 END IF;
END IF;
ELSE

IF R70A and C70A THEN
-- is train moving counterclockwise?
 IF (not(T1) and DirA(0)='1') or (T1 and DirB(0)='1') THEN
  col_adjustA <= "0000000";
  row_adjustA <= "1111111";
 ELSE
-- train is moving clockwise
 IF (not(T1) and DirA(1)='1') or (T1 and DirB(1)='1') THEN
  col_adjustA <= "1111111";
  row_adjustA <= "0000000";
 ELSE
  col_adjustA <= "0000000";
  row_adjustA <= "0000000";
 END IF;
 END IF;
ELSE

-- Switch 1 Location
IF R70A and C30A THEN
 IF Switch1 = '0' THEN
-- Switch connected to outside track
-- is train moving counterclockwise?
 IF (not(T2) and DirA(0)='1') or (T2 and DirB(0)='1') THEN
  col_adjustA <= "0000001";
  row_adjustA <= "0000000";
-- crash if going wrong way into switch
  IF old_trainArow < "1110000" THEN crashA <= '1'; END IF;
 ELSE
-- train is moving clockwise
 IF (not(T2) and DirA(1)='1') or (T2 and DirB(1)='1') THEN
  col_adjustA <= "1111111";
  row_adjustA <= "0000000";
 ELSE
  col_adjustA <= "0000000";
  row_adjustA <= "0000000";
 END IF;
 END IF;
ELSE
-- Switch connected to inside track
-- is train moving counterclockwise?
 IF (not(T2) and DirA(0)='1') or (T2 and DirB(0)='1') THEN
  col_adjustA <= "0000001";
  row_adjustA <= "0000000";
 -- crash if going wrong way into switch
  IF old_trainAcol < "0110000" THEN crashA <= '1'; END IF;
ELSE
-- is train moving counterclockwise?
 IF (not(T2) and DirA(1)='1') or (T2 and DirB(1)='1') THEN
  col_adjustA <= "0000000";
  row_adjustA <= "1111111";
-- crash if going wrong way into switch
  IF old2_trainAcol(6 DOWNTO 1) < "011000" THEN crashA <= '1'; END IF;
 ELSE
  col_adjustA <= "0000000";
  row_adjustA <= "0000000";
 END IF;
 END IF;
 END IF;
ELSE

-- Switch 2 Location
IF R70A and C50A THEN
 IF Switch2 = '0' THEN
-- Switch connected to outside track
-- is train moving counterclockwise?
 IF (not(T2) and DirA(0)='1') or (T2 and DirB(0)='1') THEN
  col_adjustA <= "0000001";
  row_adjustA <= "0000000";
 ELSE
-- train is moving clockwise
 IF (not(T2) and DirA(1)='1') or (T2 and DirB(1)='1') THEN
  col_adjustA <= "1111111";
  row_adjustA <= "0000000";
-- crash if going wrong way into switch
  IF old_trainArow < "1110000" THEN crashA <= '1'; END IF;
 ELSE
  col_adjustA <= "0000000";
  row_adjustA <= "0000000";
 END IF;
 END IF;
ELSE
-- Switch connected to inside track
-- is train moving counterclockwise?
 IF (not(T2) and DirA(0)='1') or (T2 and DirB(0)='1') THEN
  col_adjustA <= "0000000";
  row_adjustA <= "1111111";
 ELSE
-- train is moving clockwise
 IF (not(T2) and DirA(1)='1') or (T2 and DirB(1)='1') THEN
  col_adjustA <= "1111111";
  row_adjustA <= "0000000";
-- crash if going wrong way into switch
  IF old_trainAcol > "1010001" THEN crashA <= '1'; END IF;
 ELSE
  col_adjustA <= "0000000";
  row_adjustA <= "0000000";
 END IF;
 END IF;
 END IF;
ELSE

------------------------------------------------------------
-- Track 3
IF C30A and not(R70A) and not(R30A) THEN
-- is train moving counterclockwise?
 IF (not(T3) and DirA(0)='1') or (T3 and DirB(0)='1') THEN
  col_adjustA <= "0000000";
  row_adjustA <= "0000001";
 ELSE
-- train is moving clockwise
 IF (not(T3) and DirA(1)='1') or (T3 and DirB(1)='1') THEN
  col_adjustA <= "0000000";
  row_adjustA <= "1111111";
 ELSE
  col_adjustA <= "0000000";
  row_adjustA <= "0000000";
 END IF;
 END IF;
ELSE

IF C30A and R30A THEN
-- is train moving counterclockwise?
 IF (not(T3) and DirA(0)='1') or (T3 and DirB(0)='1') THEN
  col_adjustA <= "0000000";
  row_adjustA <= "0000001";
 ELSE
--  train is moving clockwise
 IF (not(T3) and DirA(1)='1') or (T3 and DirB(1)='1') THEN
  col_adjustA <= "0000001";
  row_adjustA <= "0000000";
 ELSE
  col_adjustA <= "0000000";
  row_adjustA <= "0000000";
 END IF;
 END IF;
ELSE

IF R30A and not(C50A) and not(C30A) and not(C40A) THEN
-- is train moving counterclockwise?
 IF (not(T3) and DirA(0)='1') or (T3 and DirB(0)='1') THEN
  col_adjustA <= "1111111";
  row_adjustA <= "0000000";
 ELSE
--  train is moving clockwise
 IF (not(T3) and DirA(1)='1') or (T3 and DirB(1)='1') THEN
  col_adjustA <= "0000001";
  row_adjustA <= "0000000";
 ELSE
  col_adjustA <= "0000000";
  row_adjustA <= "0000000";
 END IF;
 END IF;
ELSE
 
IF R30A and C40A THEN
-- Tracks cross which way was train moving?
IF Old_TrainArow /= "0110000" or TrainArow(0)='1' THEN
-- N/S Track
-- is train moving counterclockwise?
 IF (not(T4) and DirA(0)='1') or (T4 and DirB(0)='1') THEN
  col_adjustA <= "0000000";
  row_adjustA <= "1111111";
 ELSE
-- train is moving clockwise
 IF (not(T4) and DirA(1)='1') or (T4 and DirB(1)='1') THEN
  col_adjustA <= "0000000";
  row_adjustA <= "0000001";
 ELSE
  col_adjustA <= "0000000";
  row_adjustA <= "0000000";
 END IF;
 END IF;
ELSE
-- E/W Track
-- is train moving counterclockwise?
 IF (not(T3) and DirA(0)='1') or (T3 and DirB(0)='1') THEN
  col_adjustA <= "1111111";
  row_adjustA <= "0000000";
 ELSE
--  train is moving clockwise
 IF (not(T3) and DirA(1)='1') or (T3 and DirB(1)='1') THEN
  col_adjustA <= "0000001";
  row_adjustA <= "0000000";
 ELSE
  col_adjustA <= "0000000";
  row_adjustA <= "0000000";
 END IF;
 END IF;
END IF;
ELSE


IF C50A and not(R70A) and not(R30A) THEN
-- is train moving counterclockwise?
 IF (not(T3) and DirA(0)='1') or (T3 and DirB(0)='1') THEN
  col_adjustA <= "0000000";
  row_adjustA <= "1111111";
 ELSE
-- train is moving clockwise
 IF (not(T3) and DirA(1)='1') or (T3 and DirB(1)='1') THEN
  col_adjustA <= "0000000";
  row_adjustA <= "0000001";
 ELSE
  col_adjustA <= "0000000";
  row_adjustA <= "0000000";
 END IF;
 END IF;
ELSE

IF C50A and R30A THEN
-- is train moving counterclockwise?
 IF (not(T3) and DirA(0)='1') or (T3 and DirB(0)='1') THEN
  col_adjustA <= "1111111";
  row_adjustA <= "0000000";
 ELSE
-- train is moving clockwise
 IF (not(T3) and DirA(1)='1') or (T3 and DirB(1)='1') THEN
  col_adjustA <= "0000000";
  row_adjustA <= "0000001";
 ELSE
  col_adjustA <= "0000000";
  row_adjustA <= "0000000";
 END IF;
 END IF;
ELSE

--------------------------------------------------------------------------
-- Track 4
IF C40A and not(R10A) THEN
-- is train moving counterclockwise?
 IF (not(T4) and DirA(0)='1') or (T4 and DirB(0)='1') THEN
  col_adjustA <= "0000000";
  row_adjustA <= "1111111";
 ELSE
-- train is moving clockwise
 IF (not(T4) and DirA(1)='1') or (T4 and DirB(1)='1') THEN
  col_adjustA <= "0000000";
  row_adjustA <= "0000001";
  IF trainArow > "1010000" THEN CrashA <= '1'; END IF;
 ELSE
  col_adjustA <= "0000000";
  row_adjustA <= "0000000";
 END IF;
 END IF;
ELSE
 col_adjustA <= "0000000";
 row_adjustA <= "0000000";
END IF;
END IF;
END IF;
END IF;
END IF;
END IF;
END IF;
END IF;
END IF;
END IF;
END IF;
END IF;
END IF;
END IF;
END IF;
END IF;
END IF;
END IF;
END IF;
END IF;

End PROCESS MOVE_TRAINA;


-----------------------------------------------------------
-- Move Train B
MOVE_TRAINB: PROCESS
BEGIN
 
   WAIT UNTIL (slow_clock'Event) and (slow_clock = '1') ;
IF reset='1' or trainBrow = "0000000" THEN
 trainbrow <= "1000000";
 trainbcol <= "0110000";
 old_trainbrow <= "1000010";
 old_trainbcol <= "0110000";
 col_adjustB <= "0000000";
 row_adjustB <= "0000000";
 crashB <= '0';
ELSE
IF (trainArow=trainBrow) and (trainAcol=trainBcol) THEN 
 crashB <='1';
END IF;

IF (Speed_Signal_B = '1') and (crash='0') and (Train_stop ='1') THEN

Old2_TrainBcol <= Old_TrainBcol;
Old2_TrainBrow <= Old_TrainBrow;
Old_TrainBcol <= TrainBcol;
Old_TrainBrow <= TrainBrow;
TrainBcol <= Next_TrainBcol;
TrainBrow <= Next_TrainBrow;
-----------------------------------------------------------
-- Track 1
IF R10B and not(C10B) and not(C70B) and not(C40B) THEN
-- is train moving counterclockwise?
 IF (not(T1) and DirA(0)='1') or (T1 and DirB(0)='1') THEN
  col_adjustB <= "1111111";
  row_adjustB <= "0000000";
 ELSE
-- train is moving clockwise
  IF (not(T1) and DirA(1)='1') or (T1 and DirB(1)='1') THEN
   col_adjustB <= "0000001";
   row_adjustB <= "0000000";
  ELSE
   col_adjustB <= "0000000";
   row_adjustB <= "0000000";
  END IF;
 END IF;
ELSE

IF R10B and C10B THEN
-- is train moving counterclockwise?
 IF (not(T1) and DirA(0)='1') or (T1 and DirB(0)='1') THEN
  col_adjustB <= "0000000";
  row_adjustB <= "0000001";
 ELSE
-- train is moving clockwise
 IF (not(T1) and DirA(1)='1') or (T1 and DirB(1)='1') THEN
  col_adjustB <= "0000001";
  row_adjustB <= "0000000";
 ELSE
  col_adjustB <= "0000000";
  row_adjustB <= "0000000";
 END IF;
 END IF;
ELSE

-- Switch 3 Location
IF R10B and C40B THEN
 IF Switch3 = '0' THEN
-- Switch connected to outside track
-- is train moving counterclockwise?
 IF (not(T1) and DirA(0)='1') or (T1 and DirB(0)='1') THEN
  col_adjustB <= "1111111";
  row_adjustB <= "0000000";
-- crash if going wrong way into switch
  IF old_trainBrow > "0010000" THEN crashB <= '1'; END IF;
 ELSE
-- train is moving clockwise
 IF (not(T1) and DirA(1)='1') or (T1 and DirB(1)='1') THEN
  col_adjustB <= "0000001";
  row_adjustB <= "0000000";
 ELSE
  col_adjustB <= "0000000";
  row_adjustB <= "0000000";
 END IF;
 END IF;
ELSE
-- Switch connected to inside track
-- is train moving counterclockwise?
 IF (not(T1) and DirA(0)='1') or (T1 and DirB(0)='1') THEN
  col_adjustB <= "1111111";
  row_adjustB <= "0000000";
-- crash if going wrong way into switch
  IF old_trainBcol > "1000000" THEN crashB <= '1'; END IF;
 ELSE
-- train is moving clockwise
 IF (not(T1) and DirA(1)='1') or (T1 and DirB(1)='1') THEN
  col_adjustB <= "0000000";
  row_adjustB <= "0000001";
 ELSE
  col_adjustB <= "0000000";
  row_adjustB <= "0000000";
 END IF;
 END IF;
 END IF;
ELSE

IF R10B and C70B THEN
-- is train moving counterclockwise?
 IF (not(T1) and DirA(0)='1') or (T1 and DirB(0)='1') THEN
  col_adjustB <= "1111111";
  row_adjustB <= "0000000";
 ELSE
-- train is moving clockwise
 IF (not(T1) and DirA(1)='1') or (T1 and DirB(1)='1') THEN
  col_adjustB <= "0000000";
  row_adjustB <= "0000001";
 ELSE
  col_adjustB <= "0000000";
  row_adjustB <= "0000000";
 END IF;
 END IF;
ELSE

IF C10B and not(R10B) and not(R70B) THEN
-- is train moving counterclockwise?
 IF (not(T1) and DirA(0)='1') or (T1 and DirB(0)='1') THEN
  col_adjustB <= "0000000";
  row_adjustB <= "0000001";
 ELSE
-- train is moving clockwise
 IF (not(T1) and DirA(1)='1') or (T1 and DirB(1)='1') THEN
  col_adjustB <= "0000000";
  row_adjustB <= "1111111";
 ELSE
  col_adjustB <= "0000000";
  row_adjustB <= "0000000";
 END IF;
 END IF;
ELSE

IF C10B and R70B THEN
-- is train moving counterclockwise?
 IF (not(T1) and DirA(0)='1') or (T1 and DirB(0)='1') THEN
  col_adjustB <= "0000001";
  row_adjustB <= "0000000";
 ELSE
-- train is moving clockwise
 IF (not(T1) and DirA(1)='1') or (T1 and DirB(1)='1') THEN
  col_adjustB <= "0000000";
  row_adjustB <= "1111111";
 ELSE
  col_adjustB <= "0000000";
  row_adjustB <= "0000000";
 END IF;
 END IF;
ELSE

IF C70B and not(R70B) and not(R10B) THEN
-- is train moving counterclockwise?
 IF (not(T1) and DirA(0)='1') or (T1 and DirB(0)='1') THEN
  col_adjustB <= "0000000";
  row_adjustB <= "1111111";
 ELSE
-- train is moving clockwise
 IF (not(T1) and DirA(1)='1') or (T1 and DirB(1)='1') THEN
  col_adjustB <= "0000000";
  row_adjustB <= "0000001";
 ELSE
  col_adjustB <= "0000000";
  row_adjustB <= "0000000";
 END IF;
 END IF;
ELSE

-- Track 2 When col>=30 and <=50 else Track 1
IF R70B and not(C10B) and not(C70B) and not(C30B) and not(C50B) THEN
 IF trainBcol >= "0110000" and trainBcol <= "1010001" THEN
-- Track 2 region
-- is train moving counterclockwise?
 IF (not(T2) and DirA(0)='1') or (T2 and DirB(0)='1') THEN
  col_adjustB <= "0000001";
  row_adjustB <= "0000000";
 ELSE
-- train is moving clockwise
 IF (not(T2) and DirA(1)='1') or (T2 and DirB(1)='1') THEN
  col_adjustB <= "1111111";
  row_adjustB <= "0000000";
 ELSE
  col_adjustB <= "0000000";
  row_adjustB <= "0000000";
 END IF;
 END IF;
ELSE

-- Track 1 region
-- is train moving counterclockwise?
 IF (not(T1) and DirA(0)='1') or (T1 and DirB(0)='1') THEN
  col_adjustB <= "0000001";
  row_adjustB <= "0000000";
 ELSE
-- train is moving clockwise
 IF (not(T1) and DirA(1)='1') or (T1 and DirB(1)='1') THEN
  col_adjustB <= "1111111";
  row_adjustB <= "0000000";
 ELSE
  col_adjustB <= "0000000";
  row_adjustB <= "0000000";
 END IF;
 END IF;
END IF;
ELSE

IF R70B and C70B THEN
-- is train moving counterclockwise?
 IF (not(T1) and DirA(0)='1') or (T1 and DirB(0)='1') THEN
  col_adjustB <= "0000000";
  row_adjustB <= "1111111";
 ELSE
-- train is moving clockwise
 IF (not(T1) and DirA(1)='1') or (T1 and DirB(1)='1') THEN
  col_adjustB <= "1111111";
  row_adjustB <= "0000000";
 ELSE
  col_adjustB <= "0000000";
  row_adjustB <= "0000000";
 END IF;
 END IF;
ELSE

-- Switch 1 Location
IF R70B and C30B THEN
 IF Switch1 = '0' THEN
-- Switch connected to outside track
-- is train moving counterclockwise?
 IF (not(T2) and DirA(0)='1') or (T2 and DirB(0)='1') THEN
  col_adjustB <= "0000001";
  row_adjustB <= "0000000";
-- crash if going wrong way into switch
  IF old_trainBrow < "1110000" THEN crashB <= '1'; END IF;
 ELSE
-- train is moving clockwise
 IF (not(T2) and DirA(1)='1') or (T2 and DirB(1)='1') THEN
  col_adjustB <= "1111111";
  row_adjustB <= "0000000";
 ELSE
  col_adjustB <= "0000000";
  row_adjustB <= "0000000";
 END IF;
 END IF;
ELSE
-- Switch connected to inside track
-- is train moving counterclockwise?
 IF (not(T2) and DirA(0)='1') or (T2 and DirB(0)='1') THEN
  col_adjustB <= "0000001";
  row_adjustB <= "0000000";
 ELSE
-- is train moving counterclockwise?
 IF (not(T2) and DirA(1)='1') or (T2 and DirB(1)='1') THEN
  col_adjustB <= "0000000";
  row_adjustB <= "1111111";
-- crash if going wrong way into switch
  IF old_trainBcol < "0110000" THEN crashB <= '1'; END IF;
 ELSE
  col_adjustB <= "0000000";
  row_adjustB <= "0000000";
 END IF;
 END IF;
 END IF;
ELSE

-- Switch 2 Location
IF R70B and C50B THEN
 IF Switch2 = '0' THEN
-- Switch connected to outside track
-- is train moving counterclockwise?
 IF (not(T2) and DirA(0)='1') or (T2 and DirB(0)='1') THEN
  col_adjustB <= "0000001";
  row_adjustB <= "0000000";
 ELSE
-- train is moving clockwise
 IF (not(T2) and DirA(1)='1') or (T2 and DirB(1)='1') THEN
  col_adjustB <= "1111111";
  row_adjustB <= "0000000";
 -- crash if going wrong way into switch
  IF old_trainBrow < "1110000" THEN crashB <= '1'; END IF;
ELSE
  col_adjustB <= "0000000";
  row_adjustB <= "0000000";
 END IF;
 END IF;
ELSE
-- Switch connected to inside track=1
-- is train moving counterclockwise?
 IF (not(T2) and DirA(0)='1') or (T2 and DirB(0)='1') THEN
  col_adjustB <= "0000000";
  row_adjustB <= "1111111";
 ELSE
-- train is moving clockwise
 IF (not(T2) and DirA(1)='1') or (T2 and DirB(1)='1') THEN
  col_adjustB <= "1111111";
  row_adjustB <= "0000000";
-- crash if going wrong way into switch
  IF old_trainBcol > "1010001" THEN crashB <= '1';  END IF;
 ELSE
  col_adjustB <= "0000000";
  row_adjustB <= "0000000";
 END IF;
 END IF;
 END IF;
ELSE

------------------------------------------------------------
-- Track 3
IF C30B and not(R70B) and not(R30B) THEN
-- is train moving counterclockwise?
 IF (not(T3) and DirA(0)='1') or (T3 and DirB(0)='1') THEN
  col_adjustB <= "0000000";
  row_adjustB <= "0000001";
 ELSE
-- train is moving clockwise
 IF (not(T3) and DirA(1)='1') or (T3 and DirB(1)='1') THEN
  col_adjustB <= "0000000";
  row_adjustB <= "1111111";
 ELSE
  col_adjustB <= "0000000";
  row_adjustB <= "0000000";
 END IF;
 END IF;
ELSE

IF C30B and R30B THEN
-- is train moving counterclockwise?
 IF (not(T3) and DirA(0)='1') or (T3 and DirB(0)='1') THEN
  col_adjustB <= "0000000";
  row_adjustB <= "0000001";
 ELSE
--  train is moving clockwise
 IF (not(T3) and DirA(1)='1') or (T3 and DirB(1)='1') THEN
  col_adjustB <= "0000001";
  row_adjustB <= "0000000";
 ELSE
  col_adjustB <= "0000000";
  row_adjustB <= "0000000";
 END IF;
 END IF;
ELSE

IF R30B and not(C50B) and not(C30B) and not(C40B) THEN
-- is train moving counterclockwise?
 IF (not(T3) and DirA(0)='1') or (T3 and DirB(0)='1') THEN
  col_adjustB <= "1111111";
  row_adjustB <= "0000000";
 ELSE
--  train is moving clockwise
 IF (not(T3) and DirA(1)='1') or (T3 and DirB(1)='1') THEN
  col_adjustB <= "0000001";
  row_adjustB <= "0000000";
 ELSE
  col_adjustB <= "0000000";
  row_adjustB <= "0000000";
 END IF;
 END IF;
ELSE
 
IF R30B and C40B THEN
-- Tracks cross which way was train moving?
IF Old_TrainBrow /= "0110000" or TrainBrow(0)='1'  THEN
-- N/S Track
-- is train moving counterclockwise?
 IF (not(T4) and DirA(0)='1') or (T4 and DirB(0)='1') THEN
  col_adjustB <= "0000000";
  row_adjustB <= "1111111";
 ELSE
-- train is moving clockwise
 IF (not(T4) and DirA(1)='1') or (T4 and DirB(1)='1') THEN
  col_adjustB <= "0000000";
  row_adjustB <= "0000001";
 ELSE
  col_adjustB <= "0000000";
  row_adjustB <= "0000000";
 END IF;
 END IF;
ELSE
-- E/W Track
-- is train moving counterclockwise?
 IF (not(T3) and DirA(0)='1') or (T3 and DirB(0)='1') THEN
  col_adjustB <= "1111111";
  row_adjustB <= "0000000";
 ELSE
--  train is moving clockwise
 IF (not(T3) and DirA(1)='1') or (T3 and DirB(1)='1') THEN
  col_adjustB <= "0000001";
  row_adjustB <= "0000000";
 ELSE
  col_adjustB <= "0000000";
  row_adjustB <= "0000000";
 END IF;
 END IF;
END IF;
ELSE


IF C50B and not(R70B) and not(R30B) THEN
-- is train moving counterclockwise?
 IF (not(T3) and DirA(0)='1') or (T3 and DirB(0)='1') THEN
  col_adjustB <= "0000000";
  row_adjustB <= "1111111";
 ELSE
-- train is moving clockwise
 IF (not(T3) and DirA(1)='1') or (T3 and DirB(1)='1') THEN
  col_adjustB <= "0000000";
  row_adjustB <= "0000001";
 ELSE
  col_adjustB <= "0000000";
  row_adjustB <= "0000000";
 END IF;
 END IF;
ELSE

IF C50B and R30B THEN
-- is train moving counterclockwise?
 IF (not(T3) and DirA(0)='1') or (T3 and DirB(0)='1') THEN
  col_adjustB <= "1111111";
  row_adjustB <= "0000000";
 ELSE
-- train is moving clockwise
 IF (not(T3) and DirA(1)='1') or (T3 and DirB(1)='1') THEN
  col_adjustB <= "0000000";
  row_adjustB <= "0000001";
 ELSE
  col_adjustB <= "0000000";
  row_adjustB <= "0000000";
 END IF;
 END IF;
ELSE

--------------------------------------------------------------------------
-- Track 4
IF C40B and not(R10B) THEN
-- is train moving counterclockwise?
 IF (not(T4) and DirA(0)='1') or (T4 and DirB(0)='1') THEN
  col_adjustB <= "0000000";
  row_adjustB <= "1111111";
 ELSE
-- train is moving clockwise
 IF (not(T4) and DirA(1)='1') or (T4 and DirB(1)='1') THEN
  col_adjustB <= "0000000";
  row_adjustB <= "0000001";
-- Check for end of Track 4
  IF trainBrow > "1010000" THEN CrashB <= '1'; END IF;
 ELSE
  col_adjustB <= "0000000";
  row_adjustB <= "0000000";
 END IF;
 END IF;
ELSE
 col_adjustB <= "0000000";
 row_adjustB <= "0000000";
END IF;
END IF;
END IF;
END IF;
END IF;
END IF;
END IF;
END IF;
END IF;
END IF;
END IF;
END IF;
END IF;
END IF;
END IF;
END IF;
END IF;
END IF;
END IF;
END IF;

End PROCESS MOVE_TRAINB;

-- Compute Track Sensor Values
COMPUTE_SENSOR: PROCESS
BEGIN

 IF (C10A and R5xA) OR  (C10B and R5xB) THEN
  sensor1 <= '1';
 ELSE
  sensor1 <= '0';
 END IF;
 
 IF (C30A and R5xA) OR (C30B and R5xB) THEN
  sensor2 <= '1';
 ELSE
  sensor2 <= '0';
 END IF;

 IF (C50A and R5xA) OR (C50B and R5xB) THEN
  sensor3 <= '1';
 ELSE
  sensor3 <= '0';
 END IF;

 IF (C70A and R5xA) OR (C70B and R5xB) THEN
  sensor4 <= '1';
 ELSE
  sensor4 <= '0';
 END IF;

 IF (R4xA and C40A) OR (R4xB and C40B) THEN
  sensor5 <= '1';
 ELSE
  sensor5 <= '0';
 END IF;

End PROCESS COMPUTE_SENSOR;

-- Display Sensor, Switch, and Train
TRAIN_DISPLAY: PROCESS
BEGIN
Wait UNTIL(Clock'Event) and (Clock='1');

-- Display Train
-- Train A
IF ((trainAcol(6 DOWNTO 1) = col_address(6 DOWNTO 1)) and 
   (trainArow(6 DOWNTO 1) = row_address(6 DOWNTO 1))) THEN
     display_item <= '1';
     red_display_data <= '0';
     green_display_data <='0';
     blue_display_data <= '0';
else


IF ((old_trainAcol(6 DOWNTO 1) = col_address(6 DOWNTO 1)) and 
   (old_trainArow(6 DOWNTO 1) = row_address(6 DOWNTO 1))) THEN
     display_item <= '1';
     red_display_data <= '0';
     green_display_data <='0';
     blue_display_data <= '0';
else

IF ((old2_trainAcol(6 DOWNTO 1) = col_address(6 DOWNTO 1)) and 
   (old2_trainArow(6 DOWNTO 1) = row_address(6 DOWNTO 1))) THEN
     display_item <= '1';
     red_display_data <= '0';
     green_display_data <='0';
     blue_display_data <= '0';
else

-- Train B
IF ((trainBcol(6 DOWNTO 1) = col_address(6 DOWNTO 1)) and 
   (trainBrow(6 DOWNTO 1) = row_address(6 DOWNTO 1))) THEN
     display_item <= '1';
     red_display_data <= '1';
     green_display_data <='0';
     blue_display_data <= '0';
else

IF ((old_trainBcol(6 DOWNTO 1) = col_address(6 DOWNTO 1)) and 
   (old_trainBrow(6 DOWNTO 1) = row_address(6 DOWNTO 1))) THEN
     display_item <= '1';
     red_display_data <= '1';
     green_display_data <='0';
     blue_display_data <= '0';
else

IF ((old2_trainBcol(6 DOWNTO 1) = col_address(6 DOWNTO 1)) and 
   (old2_trainBrow(6 DOWNTO 1) = row_address(6 DOWNTO 1))) THEN
     display_item <= '1';
     red_display_data <= '1';
     green_display_data <='0';
     blue_display_data <= '0';
else



-- Display Switch
-- switch 3 display
IF row_address(6 DOWNTO 1) = "000110" and
   col_address(6 DOWNTO 1) = "100000" THEN
      display_item <= '1';
  IF switch3 = '0' THEN
     red_display_data <= '0';
     green_display_data <='1';
     blue_display_data <= '0';
    else
     red_display_data <= '1';
     green_display_data <='0';
     blue_display_data <= '0';
    END IF;
else

-- switch 2 display
IF row_address(6 DOWNTO 1) = "111010" and
   col_address(6 DOWNTO 1) = "101000" THEN
     display_item <= '1';
    IF switch2 = '0' THEN
     red_display_data <= '0';
     green_display_data <='1';
     blue_display_data <= '0';
    else
     red_display_data <= '1';
     green_display_data <='0';
     blue_display_data <= '0';
    END IF;
else

-- switch 1 display
IF row_address(6 DOWNTO 1) = "111010" and
   col_address(6 DOWNTO 1) = "011000" THEN
     display_item <= '1';
    IF switch1 = '0' THEN
     red_display_data <= '0';
     green_display_data <='1';
     blue_display_data <= '0';
    else
     red_display_data <= '1';
     green_display_data <='0';
     blue_display_data <= '0';
    END IF;
else

-- sensor display
-- sensor 5
IF row_address(6 DOWNTO 1) = "011100" and
   col_address(6 DOWNTO 1) = "100100" THEN
      display_item <= '1';
   IF sensor5 = '0' THEN
     red_display_data <= '0';
     green_display_data <='1';
     blue_display_data <= '0';
    else
     red_display_data <= '1';
     green_display_data <='0';
     blue_display_data <= '0';
    END IF;
else

-- sensor 1
IF row_address(6 DOWNTO 1) = "110000" and
  col_address(6 DOWNTO 1) = "000100" THEN
    display_item <= '1';
    IF sensor1 = '0' THEN
     red_display_data <= '0';
     green_display_data <='1';
     blue_display_data <= '0';
    else
     red_display_data <= '1';
     green_display_data <='0';
     blue_display_data <= '0';
    END IF;
   else

-- sensor 2
IF row_address(6 DOWNTO 1) = "110000" and
   col_address(6 DOWNTO 1) = "010100" THEN
    display_item <= '1';
    IF sensor2 = '0' THEN
     red_display_data <= '0';
     green_display_data <='1';
     blue_display_data <= '0';
    else
     red_display_data <= '1';
     green_display_data <='0';
     blue_display_data <= '0';
    END IF;
   else

-- sensor 3
IF row_address(6 DOWNTO 1) = "110000" and
   col_address(6 DOWNTO 1) = "101100" THEN
    display_item <= '1';
    IF sensor3 = '0' THEN
     red_display_data <= '0';
     green_display_data <='1';
     blue_display_data <= '0';
    else
     red_display_data <= '1';
     green_display_data <='0';
     blue_display_data <= '0';
    END IF;
  else

-- sensor 4
IF row_address(6 DOWNTO 1) = "110000" and
   col_address(6 DOWNTO 1) = "111011" THEN
    display_item <= '1';
    IF sensor4 = '0' THEN
     red_display_data <= '0';
     green_display_data <='1';
     blue_display_data <= '0';
    else
     red_display_data <= '1';
     green_display_data <='0';
     blue_display_data <= '0';
    END IF;
-- no items to display use memory for backgound colors
  else
   display_item <='0';
  END IF;
END IF;
END IF;
END IF;
END IF;
END IF;
END IF;
END IF;
END IF;
END IF;
END IF;
END IF;
END IF;
END IF;
End PROCESS TRAIN_DISPLAY;

--Generate Horizontal and Vertical Timing Signals for Video Signal
VIDEO_DISPLAY: PROCESS
BEGIN

Wait UNTIL(Clock'Event) and (Clock='1');
IF Power_on = '1' THEN
 H_count <= CONV_STD_LOGIC_VECTOR(0,10);
 V_count <= CONV_STD_LOGIC_VECTOR(0,10);
 Video_on_H <= '0';
 Video_on_V <= '0';
ELSE
-- H_count counts pixels (640 + extra time for sync signals)
--
--   <-Clock out RGB Pixel Row Data ->   <-H Sync->
--   ------------------------------------__________--------
--   0                           640   659       755    799
--
IF (H_count >= H_max) THEN
   H_count <= "0000000000";
ELSE
   H_count <= H_count + "0000000001";
END IF;

--Generate Horizontal Sync Signal
IF (H_count <= CONV_STD_LOGIC_VECTOR(755,10)) and (H_count >= CONV_STD_LOGIC_VECTOR(659,10)) THEN
   Horiz_Sync <= '0';
ELSE
   Horiz_Sync <= '1';
END IF;

--V_count counts rows of pixels (480 + extra time for sync signals)
--
--  <---- 480 Horizontal Syncs (pixel rows) -->  ->V Sync<-
--  -----------------------------------------------_______------------
--  0                                       480    493-494          524
--
IF (V_count >= V_max) and (H_count >= CONV_STD_LOGIC_VECTOR(699,10)) THEN
   V_count <= "0000000000";
ELSE IF (H_count = CONV_STD_LOGIC_VECTOR(699,10)) THEN
   V_count <= V_count + "0000000001";
END IF;
END IF;

-- Generate Vertical Sync Signal
IF (V_count <= CONV_STD_LOGIC_VECTOR(494,10)) and (V_count >= CONV_STD_LOGIC_VECTOR(493,10)) THEN
   Vert_Sync <= '0';
   Debounce_CLock <= '0';
ELSE
   Vert_Sync <= '1';
   Debounce_Clock <= '1';
END IF;



-- Generate Video on Screen Signals for Pixel Data
-- Generate row and col address for 5 by 4 superpixel to map into 64 by 64 video memory
--
IF (H_count <= CONV_STD_LOGIC_VECTOR(639,10)) THEN
   video_on_H <= '1';
IF pixel_col_count < CONV_STD_LOGIC_VECTOR(4,6) THEN
   pixel_col_count <= pixel_col_count + '1';
ELSE
   pixel_col_count <= "000000";
   col_address <= col_address + '1';
END IF;
ELSE
   video_on_H <= '0';
   pixel_col_count <= "000000";
   col_address <= "0000000";
END IF;

IF(H_COUNT = CONV_STD_LOGIC_VECTOR(641,10)) THEN
    pixel_row_count <= pixel_row_count + '1';
IF (pixel_row_count = CONV_STD_LOGIC_VECTOR(3,6)) THEN
   pixel_row_count <= "000000";
   row_address <= row_address + '1';
END IF;
END IF;

IF (V_count <= CONV_STD_LOGIC_VECTOR(479,10)) THEN
   video_on_V <= '1';
ELSE
   video_on_V <= '0';
   pixel_row_count <= "000000";
   row_address <= "0000000";
END IF;


IF (V_count = CONV_STD_LOGIC_VECTOR(0,10)) and (H_count = CONV_STD_LOGIC_VECTOR(0,10)) THEN
IF (F_count = CONV_STD_LOGIC_VECTOR(30,5)) THEN
   F_count <= "00000";
   second <= not second;
ELSE 
   F_count <= F_count + "00001";
END IF;
END IF;
END IF;


END PROCESS VIDEO_DISPLAY;

-- Connections to LED Display Segments
MSB_dp <= PB2_DEBOUNCED_SYNC;
LSB_dp <= PB1_DEBOUNCED_SYNC;
MSB <= Track4 & Track3 & Track2 & Track1;
LSB <= DirA & DirB;

MSB_a <= NOT MSB_7SEG(6);
MSB_b <= NOT MSB_7SEG(5);
MSB_c <= NOT MSB_7SEG(4);
MSB_d <= NOT MSB_7SEG(3);
MSB_e <= NOT MSB_7SEG(2);
MSB_f <= NOT MSB_7SEG(1);
MSB_g <= NOT MSB_7SEG(0);

LSB_a <= NOT LSB_7SEG(6);
LSB_b <= NOT LSB_7SEG(5);
LSB_c <= NOT LSB_7SEG(4);
LSB_d <= NOT LSB_7SEG(3);
LSB_e <= NOT LSB_7SEG(2);
LSB_f <= NOT LSB_7SEG(1);
LSB_g <= NOT LSB_7SEG(0);

LED_DISPLAY: PROCESS  (MSB,LSB)
-- BCD to 7 Segment Decoders for LED Displays
BEGIN
CASE MSB IS
        WHEN "0000" =>
            MSB_7SEG <= "1111110";
        WHEN "0001" =>
            MSB_7SEG <= "0110000";
        WHEN "0010" =>
            MSB_7SEG <= "1101101";
        WHEN "0011" =>
            MSB_7SEG <= "1111001";
        WHEN "0100" =>
            MSB_7SEG <= "0110011";
        WHEN "0101" =>
            MSB_7SEG <= "1011011";
        WHEN "0110" =>
            MSB_7SEG <= "1011111";
        WHEN "0111" =>
            MSB_7SEG <= "1110000";
        WHEN "1000" =>
            MSB_7SEG <= "1111111";
        WHEN "1001" =>
            MSB_7SEG <= "1111011"; 
        WHEN "1010" =>
            MSB_7SEG <= "1110111";
        WHEN "1011" =>
            MSB_7SEG <= "0011111";
        WHEN "1100" =>
            MSB_7SEG <= "1001110";
        WHEN "1101" =>
            MSB_7SEG <= "0111101"; 
        WHEN "1110" =>
            MSB_7SEG <= "1001111";
        WHEN "1111" =>
            MSB_7SEG <= "1000111";
	WHEN OTHERS =>
            MSB_7SEG <= "0000001";
END CASE;

CASE LSB IS
        WHEN "0000" =>
            LSB_7SEG <= "1111110";
        WHEN "0001" =>
            LSB_7SEG <= "0110000";
        WHEN "0010" =>
            LSB_7SEG <= "1101101";
        WHEN "0011" =>
            LSB_7SEG <= "1111001";
        WHEN "0100" =>
            LSB_7SEG <= "0110011";
        WHEN "0101" =>
            LSB_7SEG <= "1011011";
        WHEN "0110" =>
            LSB_7SEG <= "1011111";
        WHEN "0111" =>
            LSB_7SEG <= "1110000";
        WHEN "1000" =>
            LSB_7SEG <= "1111111";
        WHEN "1001" =>
            LSB_7SEG <= "1111011"; 
        WHEN "1010" =>
            LSB_7SEG <= "1110111";
        WHEN "1011" =>
            LSB_7SEG <= "0011111";
        WHEN "1100" =>
            LSB_7SEG <= "1001110";
        WHEN "1101" =>
            LSB_7SEG <= "0111101"; 
        WHEN "1110" =>
            LSB_7SEG <= "1001111";
        WHEN "1111" =>
            LSB_7SEG <= "1000111";
	WHEN OTHERS =>
            LSB_7SEG <= "0000001";
END CASE;

END PROCESS LED_DISPLAY;


-- Sync extenal pushbutton inputs to chip clock
PUSH_BUTTON: PROCESS (clock)
BEGIN
  WAIT UNTIL (clock'event) and (clock='1');
PB1_Sync <= NOT PB1;
PB2_Sync <= NOT PB2;
Switch_Sync <= Switch;
PB1_DEBOUNCED_SYNC <= PB1_DEBOUNCED;
PB2_DEBOUNCED_SYNC <= PB2_DEBOUNCED;
END PROCESS PUSH_BUTTON;

-- Debounce Button: Filters out mechanical bounce for around 80Ms.
-- Debounce clock uses Vert_Sync timing signal (16Ms) to save hardware
-- for clock prescaler
DEBOUNCE_BUTTON1: PROCESS (debounce_clock)
BEGIN
  WAIT UNTIL (debounce_clock'event) and (debounce_clock='1');
  SHIFT_PB1(2 DOWNTO 0) <= SHIFT_PB1(3 DOWNTO 1);
  SHIFT_PB1(3) <= PB1_Sync;
  IF SHIFT_PB1(3 DOWNTO 0)="1111" THEN
    PB1_DEBOUNCED <= '1';
  ELSE 
    PB1_DEBOUNCED <= '0';
  END IF;
END PROCESS DEBOUNCE_BUTTON1;

DEBOUNCE_BUTTON2: PROCESS (debounce_clock)
BEGIN
  WAIT UNTIL (debounce_clock'event) and (debounce_clock='1');
  SHIFT_PB2(2 DOWNTO 0) <= SHIFT_PB2(3 DOWNTO 1);
-- use switch 0 since PB2 broken on my board
  SHIFT_PB2(3) <= PB2_Sync;
  IF SHIFT_PB2(3 DOWNTO 0)="1111" THEN
    PB2_DEBOUNCED <= '1';
  ELSE 
    PB2_DEBOUNCED <= '0';
  END IF;
END PROCESS DEBOUNCE_BUTTON2;

SINGLE_PULSE_PB1: PROCESS (Clock)
BEGIN
  WAIT UNTIL (CLOCK'event) and (CLOCK='1');
  IF RESET='1' THEN
  PB1_SINGLE_PULSE <='0';
  PB1_DEBOUNCED_DELAY <= '1';
  ELSE
-- Generates Single Clock Cycle Pulse When Switch Hit
-- No matter how long switch is held down
  IF PB1_DEBOUNCED_SYNC = '1' AND PB1_DEBOUNCED_DELAY = '0' THEN
   PB1_SINGLE_PULSE <= '1';
  ELSE
   PB1_SINGLE_PULSE <= '0';
  END IF;
  PB1_DEBOUNCED_DELAY <= PB1_DEBOUNCED_SYNC;
 END IF;
END PROCESS SINGLE_PULSE_PB1;

SINGLE_PULSE_PB2: PROCESS (Clock)
BEGIN
  WAIT UNTIL (CLOCK'event) and (CLOCK='1');
   IF RESET='1' THEN
    PB2_SINGLE_PULSE <='0';
    PB2_DEBOUNCED_DELAY <= '1';
   ELSE
    PB2_DEBOUNCED_DELAY <= PB2_DEBOUNCED_SYNC;
-- Generates Single Clock Cycle Pulse When Switch Hit
-- No matter how long switch is held down
    IF PB2_DEBOUNCED_SYNC = '1' AND PB2_DEBOUNCED_DELAY = '0' THEN
     PB2_SINGLE_PULSE <= '1';
    ELSE
     PB2_SINGLE_PULSE <= '0';
    END IF;
  END IF;
END PROCESS SINGLE_PULSE_PB2;


END behavior;

