-- TOP_FLEX module
--
-- Flex - Mips Implementation
-- Uses VGA to Display Data 
-- PB1 is clock for Mips
-- PB2 is synchronous reset for Mips
-- i.e. must clock (hit PB1) while holding down PB2 for reset
-- PC is also displayed on 7 Segment Display
-- Flex Switch 3 is reverse video
--
--
-- VHDL synthesis and simulation model of MIPS single clock cycle machine
-- as described in chapter 5 of Patterson and Hennessey
-- VHDL Submodules Ifetch,Control,Idecode,Execute and Dmemory
-- become different pipeline stages in chapter 6.  The code 
-- for each of these VHDL modules in in *.VHD files
--
-- NOTE: Full 32-bit instructions are used. The Data paths were limited
-- to 8 bits to speed synthesis and simulation for student projects.
-- Registers are limited to 8 bits and $R0..$R7 only
-- Program memory limited to locations 0..7 and Data to locations 0..1
-- Register contain register address on reset.  Data memory
-- is initialized to 55 AA for program on reset
-- Use top_spim module to simulate MIPS without video display hardware
--
-- Jim Hamblen, Georgia Tech School of ECE
--

library IEEE;
use  IEEE.STD_LOGIC_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;
LIBRARY lpm;
USE lpm.lpm_components.ALL;


entity top_flex is

Generic(ADDR_WIDTH: integer := 12; DATA_WIDTH: integer := 1);

   port( signal PB1, PB2, Clock : in std_logic;
        signal LSB_a, LSB_b, LSB_c, LSB_d, LSB_e, LSB_f, LSB_g, LSB_dp,
        MSB_a, MSB_b, MSB_c, MSB_d, MSB_e, MSB_f, MSB_g, MSB_dp : out std_logic;               
        signal Red,Green,Blue : out std_logic;
        signal Horiz_sync,Vert_sync : out std_logic;
        signal MOUSE_DATA: in std_logic;
        signal MOUSE_CLK : in std_logic;
        signal Flex_Switch_1, Flex_Switch_2, Flex_Switch_3, Flex_Switch_4: in std_logic;
        signal Flex_Switch_5, Flex_Switch_6, Flex_Switch_7, Flex_Switch_8: in std_logic);
       
		
		
end top_flex;

architecture behavior of top_flex is

   component Ifetch

   port(Instruction: out std_logic_vector(31 downto 0);
        PCadd : out  std_logic_vector(7 downto 0);
        Addresult : in std_logic_vector(7 downto 0);
        Branch : in std_logic;
        clock,reset : in std_logic;
        Zero : in std_logic;
        PCout : out std_logic_vector(7 downto 0));

   end component;

   component Idecode

   port(rr1d_bus : out std_logic_vector(7 downto 0);
        rr2d_bus : out std_logic_vector(7 downto 0);
        Instruction : in std_logic_vector(31 downto 0);
        wrd_bus : in std_logic_vector(7 downto 0);
        RegWrite : in std_logic;
        RegDst : in std_logic;
        Extend : out std_logic_vector(7 downto 0);
        clock,reset: in std_logic);

	end component;



   component control


   port( Op : in std_logic_vector(5 downto 0);
                RegDst : out std_logic;
                ALUSrc : out std_logic;
                MemtoReg : out std_logic;
                RegWrite : out std_logic;
                MemRead : out std_logic;
                MemWrite : out std_logic;
                Branch : out std_logic;
                ALUop0 : out std_logic;
                ALUop1 : out std_logic;
                clock: in std_logic);
	
	 end component;

   component  Execute


   port(Readdata1 : in std_logic_vector(7 downto 0);
                Readdata2 : in std_logic_vector(7 downto 0);
                Extend : in std_logic_vector(7 downto 0);
                Func_op : in std_logic_vector(5 downto 0);
                ALUOp0 : in std_logic;
                ALUOp1 : in std_logic; 
                ALUSrc : in std_logic;
                Zero : out std_logic;
                ALUResult : out std_logic_vector(7 downto 0);
                ADDResult : out std_logic_vector(7 downto 0);
                PCadd : in std_logic_vector(7 downto 0);
                clock: in std_logic);

	end component;

   component dmemory

   port(rd_bus : out std_logic_vector(7 downto 0);
        ra_bus : in std_logic_vector(7 downto 0);
        wd_bus : in std_logic_vector(7 downto 0);
        wadd_bus : in std_logic_vector(7 downto 0);
        MemRead, Memwrite, MemtoReg : in std_logic;
        clock,reset: in std_logic);

   end component;

   signal PCadd, PC :  std_logic_vector(7 downto 0);
   signal rr1d_bus : std_logic_vector(7 downto 0);
   signal rr2d_bus : std_logic_vector(7 downto 0);
   signal Extend : std_logic_vector(7 downto 0);
   signal Addresult : std_logic_vector(7 downto 0);
   signal ALUresult : std_logic_vector(7 downto 0);
   signal Branch : std_logic;
   signal Zero : std_logic;
   signal wrd_bus : std_logic_vector(7 downto 0);
   signal RegWrite : std_logic;
   signal RegDst :  std_logic;
   signal ALUSrc :  std_logic;
   signal MemtoReg :  std_logic;
   signal MemRead :  std_logic;
   signal MemWrite :  std_logic;
   signal ALUop :  std_logic_vector(1 downto 0);
   signal MIPS_Inst: std_logic_vector(31 downto 0);
   signal MIPS_Clock, Reset: std_logic;

-- Video Display Signals
signal H_count,V_count: std_logic_vector(9 Downto 0);
signal F_count: std_logic_vector(4 Downto 0);
signal Color_count: std_logic_vector(3 Downto 0);
signal Red_Data, Green_Data, Blue_Data, Power_On, Rev_video : std_logic;

-- Signals for Video ROM Memory for Pixel Data
signal rom_address: std_logic_vector(8 Downto 0);
signal sum_address: std_logic_vector(6 Downto 0);
signal rom_data: std_logic_vector(7 Downto 0);
signal col_address, row_address: std_logic_vector(5 Downto 0);
signal pixel_col_count, pixel_row_count: std_logic_vector(5 Downto 0);
signal rom_mux_output: std_logic;
signal format_address: std_logic_vector(5 downto 0);
signal format_data: std_logic_vector(5 downto 0);
-- Signals for LED Display
signal LSB,MSB: std_logic_vector(3 Downto 0);
signal LSB_7SEG,MSB_7SEG: std_logic_vector(6 Downto 0);

-- Signals for Push buttons
signal PB1_sync, PB2_sync, PB2_Single_Pulse, PB1_Single_Pulse: std_logic; 
signal PB2_debounced, PB1_debounced, PB2_debounced_Sync, PB1_debounced_Sync: std_logic; 
signal PB1_debounced_delay, PB2_debounced_delay, Debounce_clock: std_logic;
signal SHIFT_PB1, SHIFT_PB2: std_logic_vector(3 Downto 0);
signal switch, switch_sync: std_logic_vector(7 Downto 0);


constant H_max : std_logic_vector(9 Downto 0) := CONV_STD_LOGIC_VECTOR(799,10); 
-- 799 is max horiz count
constant V_max : std_logic_vector(9 Downto 0) := CONV_STD_LOGIC_VECTOR(524,10); 
-- 524 is max vert count
signal video_on, video_on_H, video_on_V: std_logic;
begin

-- Small 8 by 8 Character Genrator ROM for Video Display
 tiny_char_gen_rom: lpm_rom
      GENERIC MAP ( lpm_widthad => 9,
        lpm_numwords => "512",
        lpm_outdata => "UNREGISTERED",
        lpm_address_control => "UNREGISTERED",
-- Reads in mif file for character generator data 
         lpm_file => "tcgrom.mif",
         lpm_width => 8)
      PORT MAP ( address => rom_address, q => rom_data);


-- Character Format ROM for Video Display
-- Displays constant format character data
-- on left side of Display area
 format_rom: lpm_rom
      GENERIC MAP ( lpm_widthad => 6,
        lpm_numwords => "60",
        lpm_outdata => "UNREGISTERED",
        lpm_address_control => "UNREGISTERED",
-- Reads in mif file for data display format
         lpm_file => "format.mif",
         lpm_width => 6)
      PORT MAP ( address => format_address, q => format_data);


---------------------------------------------------------------------------------------
-- MIPS structural model - contains processor module interconnections
-- Code for each module is in *.VHD files
--
   IFE : Ifetch

   port map (Instruction => MIPS_Inst,
        PCadd => PCadd,
	    Addresult => Addresult,
	    Branch => Branch,
        clock => mips_clock,  reset => reset,
	    Zero => Zero,
	    PCout => PC);

   ID : Idecode

   port map (rr1d_bus => rr1d_bus,
        rr2d_bus => rr2d_bus,
        Instruction => MIPS_Inst,
        wrd_bus => wrd_bus,
	    RegWrite => RegWrite,
	    RegDst => RegDst,
	    Extend => Extend,
        clock => mips_clock,  reset => reset);

   CTL:   control

   port map ( Op => MIPS_Inst(31 downto 26),
		RegDst => RegDst,
		ALUSrc => ALUSrc,
		MemtoReg => MemtoReg,
		RegWrite => RegWrite,
		MemRead => MemRead,
		MemWrite => MemWrite,
		Branch => Branch,
		ALUop0 => ALUop(0),
		ALUop1 => ALUop(1),
                clock => mips_clock);

   EXE:  Execute


   port map (Readdata1 => rr1d_bus,
             Readdata2 => rr2d_bus,
		     Extend => Extend,
             Func_op => MIPS_Inst(5 downto 0),
		     ALUOp0 => ALUop(0),
		     ALUOp1 => ALUop(1), 
		     ALUSrc => ALUSrc,
		     Zero => Zero,
             ALUResult => ALUResult,
		     ADDResult => ADDResult,
		     PCadd => PCadd,
             clock => mips_clock);

   MEM:  dmemory

   port map (rd_bus => wrd_bus,
	         ra_bus => ALUResult,
	         wd_bus => rr2d_bus,
             wadd_bus => ALUResult,
	         MemRead => MemRead, 
	         Memwrite => MemWrite, 
	         MemtoReg => MemtoReg,
             clock => mips_clock,  reset => reset);
 

 
------------------------------------------------------------------------------

-- Reset and Clock Signal for MIPS processor
Reset <=  PB2_Debounced_Sync;
Mips_clock <= PB1_Debounced_Sync;

-- Colors for pixel data on video signal
-- address video_rom for pixel color data
-- Switch 2 or Rev_Video will reverse video
Red_Data <= not ((rom_mux_output xor Switch_Sync(2)) xor Rev_video);
Green_Data <= not ((rom_mux_output xor Switch_Sync(2)) xor Rev_video);
Blue_Data <= '1';



-- Display 8 by 8 font with 16 by 16 pixel array
-- Step through rows for each character pattern
rom_address(2 Downto 0) <= pixel_row_count(3 Downto 1);

-- Mux to pick off correct rom data bit from 8-bit word
-- for on screen character generation
rom_mux_output <= rom_data ( (CONV_INTEGER(NOT pixel_col_count(3 downto 1))));

-- The RGB signal pins to the VGA monitor
Red <=   Red_Data and video_on;
Green <= Green_Data and video_on;
Blue <=  Blue_Data and video_on;

-- video_on turns off pixel data when not in the view area
video_on <= video_on_H and video_on_V;

-- Combine Flex Dip Switch Inputs into Switch vector
Switch <= Flex_Switch_8 & Flex_Switch_7 & Flex_Switch_6 & Flex_Switch_5 &
          Flex_Switch_4 & Flex_Switch_3 & Flex_Switch_2 & Flex_Switch_1;

-- This process generates the signals needed for a Video Display
--It Generates Horizontal and Vertical Timing Signals for Video the Signal
--It also counts pixel rows and columns to provide addresses for the
--process that generates the data for the Video Signal

VIDEO_DISPLAY: Process
Begin

Wait until(Clock'Event) and (Clock='1');
If Power_on = '0' Then
 H_count <= CONV_STD_LOGIC_VECTOR(654,10);
 V_count <= CONV_STD_LOGIC_VECTOR(493,10);
 Video_on_H <= '0';
 Video_on_V <= '0';
 Power_On <= '1';
Else
-- H_count counts pixels (640 + extra time for sync signals)
--
--   <-Clock out RGB Pixel Row Data ->   <-H Sync->
--   ------------------------------------__________--------
--   0                           640   659       755    799
--
If (H_count >= H_max) then
   H_count <= To_Stdlogicvector(B"0000000000");
Else
   H_count <= H_count + To_Stdlogicvector(B"0000000001");
End if;

--Generate Horizontal Sync Signal
If (H_count <= CONV_STD_LOGIC_VECTOR(755,10)) and (H_count >= CONV_STD_LOGIC_VECTOR(659,10)) Then
   Horiz_Sync <= '0';
ELSE
   Horiz_Sync <= '1';
End if;

--V_count counts rows of pixels (480 + extra time for sync signals)
--
--  <---- 480 Horizontal Syncs (pixel rows) -->  ->V Sync<-
--  -----------------------------------------------_______------------
--  0                                       480    493-494          524
--
If (V_count >= V_max) and (H_count >= CONV_STD_LOGIC_VECTOR(699,10)) then
   V_count <= To_Stdlogicvector(B"0000000000");
Else If (H_count = CONV_STD_LOGIC_VECTOR(699,10)) Then
   V_count <= V_count + To_Stdlogicvector(B"0000000001");
End if;
End if;

-- Generate Vertical Sync Signal
If (V_count <= CONV_STD_LOGIC_VECTOR(494,10)) and (V_count >= CONV_STD_LOGIC_VECTOR(493,10)) Then
   Vert_Sync <= '0';
   Debounce_CLock <= '0';
ELSE
   Vert_Sync <= '1';
   Debounce_Clock <= '1';
End if;



-- Generate Video on Screen Signals for Pixel Data
-- Generate row and col address for 16 by 16 font
--
If (H_count <= CONV_STD_LOGIC_VECTOR(639,10)) Then
   video_on_H <= '1';
If pixel_col_count < CONV_STD_LOGIC_VECTOR(15,6) Then
   pixel_col_count <= pixel_col_count + '1';
Else
   pixel_col_count <= "000000";
   col_address <= col_address + '1';
End if;
ELSE
   video_on_H <= '0';
   pixel_col_count <= "000000";
   col_address <= "000000";
End if;

IF(H_COUNT = CONV_STD_LOGIC_VECTOR(641,10)) Then
    pixel_row_count <= pixel_row_count + '1';
If (pixel_row_count = CONV_STD_LOGIC_VECTOR(15,6)) THEN
   pixel_row_count <= "000000";
   row_address <= row_address + '1';
End if;
End if;

If (V_count <= CONV_STD_LOGIC_VECTOR(479,10)) Then
   video_on_V <= '1';
ELSE
   video_on_V <= '0';
   pixel_row_count <= "000000";
   row_address <= "000000";
End if;


If (V_count = CONV_STD_LOGIC_VECTOR(0,10)) and (H_count = CONV_STD_LOGIC_VECTOR(0,10)) then
If (F_count = CONV_STD_LOGIC_VECTOR(30,5)) then
   F_count <= To_Stdlogicvector(B"00000");
Else 
   F_count <= F_count + To_Stdlogicvector(B"00001");
End if;
End if;
End if;

end process VIDEO_DISPLAY;


-- Address for Constant Character Data ROM
format_address(1 Downto 0) <= Col_address(1 Downto 0);
format_address(5 Downto 2) <= Row_address(4 Downto 1);

-- This Process Provides Character Data for Video Display
-- by generating addresses for the Character Generator ROM
-- using row address and col address provided by the Video 
-- Display process 

VIDEO_DISPLAY_DATA: process
begin
  wait until (clock'event) and (clock='1');
-- Reverse Video for Title at top of screen
If (row_address <= "00011") Then rev_video <= '1'; 
ELSE rev_video <= '0';
End if;
If (row_address(0)='0')  or
   (col_address < "001000") or (col_address >"010101") 
-- Blank characters on Edges and alternating lines
Then rom_address(8 Downto 3) <= "100000";
Else 
If ((col_address >= "001000") and (col_address <= "001011")) Then
-- Constant Character Area from ROM
 rom_address(8 Downto 3) <= format_data;
 Else
-- Couple of Spaces
 If (col_address = "001100") or (col_address = "001101") 
-- Blank on Top and Bottom line of Display Area  
 or (row_address < "00010") or (row_address > "11011")
 Then rom_address(8 Downto 3) <= "100000";
 
Else

-- Numeric Data From Simulation
-- Display Values in Hex
  CASE  row_address(4 Downto 1) IS
	WHEN  "0001"  =>
-- Print "Computer" on first line of data display area
 	    If col_address = "001110" 
         Then rom_address(8 Downto 3) <= "000011";
        End if;
	    If col_address = "001111" 
         Then rom_address(8 Downto 3) <= "001111" ;
        End if;
	    If col_address = "010000" 
         Then rom_address(8 Downto 3) <= "001101" ;
        End if;
	    If col_address = "010001" 
         Then rom_address(8 Downto 3) <= "010000" ;
        End if;
	    If col_address = "010010" 
         Then rom_address(8 Downto 3) <= "010101" ;
        End if;
	    If col_address = "010011" 
         Then rom_address(8 Downto 3) <= "010100" ;
        End if;
	    If col_address = "010100" 
         Then rom_address(8 Downto 3) <= "000101" ;
        End if;
	    If col_address = "010101" 
         Then rom_address(8 Downto 3) <= "010010" ;
        End if;
	WHEN  "0010" =>
	    If col_address = "010100" 
 -- Selects Hex Character Address with 4-bit value from signal
        Then rom_address(8 Downto 3) <= "11" & PC(7 Downto 4);
        Else If col_address = "010101" 
  -- Selects Hex Character Address with 4-bit value from signal
        Then rom_address(8 Downto 3) <= "11" & PC(3 Downto 0);
        Else
         rom_address(8 Downto 3) <= "110000";
        End if;
        End if;
	WHEN  "0011"  =>
	    If col_address = "001110" 
 -- Selects Hex Character Address with 4-bit value from signal
         Then rom_address(8 Downto 3) <= "11" & MIPS_Inst(31 Downto 28);
        End if;
	    If col_address = "001111" 
         Then rom_address(8 Downto 3) <= "11" & MIPS_Inst(27 Downto 24);
        End if;
	    If col_address = "010000" 
         Then rom_address(8 Downto 3) <= "11" & MIPS_Inst(23 Downto 20);
        End if;
	    If col_address = "010001" 
         Then rom_address(8 Downto 3) <= "11" & MIPS_Inst(19 Downto 16);
        End if;
	    If col_address = "010010" 
         Then rom_address(8 Downto 3) <= "11" & MIPS_Inst(15 Downto 12);
        End if;
	    If col_address = "010011" 
         Then rom_address(8 Downto 3) <= "11" & MIPS_Inst(11 Downto 8);
        End if;
	    If col_address = "010100" 
         Then rom_address(8 Downto 3) <= "11" & MIPS_Inst(7 Downto 4);
        End if;
	    If col_address = "010101" 
         Then rom_address(8 Downto 3) <= "11" & MIPS_Inst(3 Downto 0);
        End if;
	WHEN   "0100"  =>
	    If col_address = "010100" 
  -- Selects Hex Character Address with 4-bit value from signal
        Then rom_address(8 Downto 3) <= "11" & rr1d_bus(7 Downto 4);
        Else If col_address = "010101" 
         Then rom_address(8 Downto 3) <= "11" & rr1d_bus(3 Downto 0);
        Else
         rom_address(8 Downto 3) <= "110000";
        End if;
        End if;
	WHEN   "0101"  =>
	    If col_address = "010100" 
  -- Selects Hex Character Address with 4-bit value from signal
        Then rom_address(8 Downto 3) <= "11" & rr2d_bus(7 Downto 4);
        Else If col_address = "010101" 
         Then rom_address(8 Downto 3) <= "11" & rr2d_bus(3 Downto 0);
        Else
         rom_address(8 Downto 3) <= "110000";
        End if;
        End if;
	WHEN   "0110"  =>
	    If col_address = "010100" 
 -- Selects Hex Character Address with 4-bit value from signal
        Then rom_address(8 Downto 3) <= "11" & ALUresult(7 Downto 4);
        Else If col_address = "010101" 
         Then rom_address(8 Downto 3) <= "11" & ALUresult(3 Downto 0);
        Else
         rom_address(8 Downto 3) <= "110000";
        End if;
        End if;
	WHEN   "0111"  =>
	    If col_address = "010100" 
  -- Selects Hex Character Address with 4-bit value from signal
        Then rom_address(8 Downto 3) <= "11" & wrd_bus(7 Downto 4);
        Else If col_address = "010101" 
         Then rom_address(8 Downto 3) <= "11" & wrd_bus(3 Downto 0);
        Else
         rom_address(8 Downto 3) <= "110000";
        End if;
        End if;
	WHEN   "1000"  =>
	    If col_address = "001110" 
-- Select "0" or "1" character address
        Then rom_address(8 Downto 3) <= "11000" & Branch;
        Else
         rom_address(8 Downto 3) <= "100000";
        End if;
	WHEN   "1001"  =>
	    If col_address = "001110" 
-- Select "0" or "1" character address
         Then rom_address(8 Downto 3) <= "11000" & Zero;
        Else
         rom_address(8 Downto 3) <= "100000";
        End if;
	WHEN   "1010"  =>
	    If col_address = "001110" 
 -- Select "0" or "1" character address
        Then rom_address(8 Downto 3) <= "11000" & Memread;
        Else
         rom_address(8 Downto 3) <= "100000";
        End if;
	WHEN   "1011"  =>
	    If col_address = "001110" 
 -- Select "0" or "1" character address
        Then rom_address(8 Downto 3) <= "11000" & Memwrite;
        Else
         rom_address(8 Downto 3) <= "100000";
        End if;
	WHEN   "1100"  =>
	    If col_address = "001110" 
 -- Select Up arrow or Down arrow character address
        Then rom_address(8 Downto 3) <= "0111" & MIPS_Clock & "0";
        Else
         rom_address(8 Downto 3) <= "100000";
        End if;
	WHEN   "1101"  =>
	    If col_address = "001110" 
 -- Select Up arrow or Down arrow character address
         Then rom_address(8 Downto 3) <= "0111" & Reset & "0";
        Else
         rom_address(8 Downto 3) <= "100000";
        End if;
	WHEN OTHERS =>
      rom_address(8 Downto 3) <= "100000";
  END CASE;
  end if;
 end if;
end if;
end process VIDEO_DISPLAY_DATA;

-- Values to Display in 7Seg LEDs
MSB_dp <= NOT MIPS_CLOCK;
LSB_dp <= NOT RESET;
MSB <= PC (7 Downto 4);
LSB <= PC (3 Downto 0);

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

LED_DISPLAY: process  (MSB,LSB)
-- BCD to 7 Segment Decoders for LED Displays
begin
CASE MSB IS
        WHEN "0000" =>
            MSB_7SEG <= "1111110";
        WHEN "0001" =>
            MSB_7SEG <= To_StdLogicVector(B"0110000");
        WHEN "0010" =>
            MSB_7SEG <= To_StdLogicVector(B"1101101");
        WHEN "0011" =>
            MSB_7SEG <= To_StdLogicVector(B"1111001");
        WHEN "0100" =>
            MSB_7SEG <= To_StdLogicVector(B"0110011");
        WHEN "0101" =>
            MSB_7SEG <= To_StdLogicVector(B"1011011");
        WHEN "0110" =>
            MSB_7SEG <= To_StdLogicVector(B"1011111");
        WHEN "0111" =>
            MSB_7SEG <= To_StdLogicVector(B"1110000");
        WHEN "1000" =>
            MSB_7SEG <= To_StdLogicVector(B"1111111");
        WHEN "1001" =>
            MSB_7SEG <= To_StdLogicVector(B"1111011"); 
        WHEN "1010" =>
            MSB_7SEG <= To_StdLogicVector(B"1110111");
        WHEN "1011" =>
            MSB_7SEG <= To_StdLogicVector(B"0011111");
        WHEN "1100" =>
            MSB_7SEG <= To_StdLogicVector(B"1001110");
        WHEN "1101" =>
            MSB_7SEG <= To_StdLogicVector(B"0111101"); 
        WHEN "1110" =>
            MSB_7SEG <= To_StdLogicVector(B"1001111");
        WHEN "1111" =>
            MSB_7SEG <= To_StdLogicVector(B"1000111");
	WHEN OTHERS =>
            MSB_7SEG <= To_StdLogicVector(B"0000001");
END CASE;

CASE LSB IS
        WHEN "0000" =>
            LSB_7SEG <= To_StdLogicVector(B"1111110");
        WHEN "0001" =>
            LSB_7SEG <= To_StdLogicVector(B"0110000");
        WHEN "0010" =>
            LSB_7SEG <= To_StdLogicVector(B"1101101");
        WHEN "0011" =>
            LSB_7SEG <= To_StdLogicVector(B"1111001");
        WHEN "0100" =>
            LSB_7SEG <= To_StdLogicVector(B"0110011");
        WHEN "0101" =>
            LSB_7SEG <= To_StdLogicVector(B"1011011");
        WHEN "0110" =>
            LSB_7SEG <= To_StdLogicVector(B"1011111");
        WHEN "0111" =>
            LSB_7SEG <= To_StdLogicVector(B"1110000");
        WHEN "1000" =>
            LSB_7SEG <= To_StdLogicVector(B"1111111");
        WHEN "1001" =>
            LSB_7SEG <= To_StdLogicVector(B"1111011"); 
        WHEN "1010" =>
            LSB_7SEG <= To_StdLogicVector(B"1110111");
        WHEN "1011" =>
            LSB_7SEG <= To_StdLogicVector(B"0011111");
        WHEN "1100" =>
            LSB_7SEG <= To_StdLogicVector(B"1001110");
        WHEN "1101" =>
            LSB_7SEG <= To_StdLogicVector(B"0111101"); 
        WHEN "1110" =>
            LSB_7SEG <= To_StdLogicVector(B"1001111");
        WHEN "1111" =>
            LSB_7SEG <= To_StdLogicVector(B"1000111");
	WHEN OTHERS =>
            LSB_7SEG <= To_StdLogicVector(B"0000001");
END CASE;

end process LED_DISPLAY;


-- Sync extenal pushbutton inputs to chip clock
PUSH_BUTTON: process (clock)
begin
  wait until (clock'event) and (clock='1');
PB1_Sync <= NOT PB1;
PB2_Sync <= NOT PB2;
Switch_Sync <= Switch;
PB1_DEBOUNCED_SYNC <= PB1_DEBOUNCED;
PB2_DEBOUNCED_SYNC <= PB2_DEBOUNCED;
end process PUSH_BUTTON;

-- Debounce Button: Filters out mechanical bounce for around 80Ms.
-- Debounce clock uses Vert_Sync timing signal (16Ms) to save hardware
-- for clock prescaler
DEBOUNCE_BUTTON1: process (debounce_clock)
begin
  wait until (debounce_clock'event) and (debounce_clock='1');
  SHIFT_PB1(2 Downto 0) <= SHIFT_PB1(3 Downto 1);
  SHIFT_PB1(3) <= PB1_Sync;
  If SHIFT_PB1(3 Downto 0)="1111" THEN
    PB1_DEBOUNCED <= '1';
  ELSE 
    PB1_DEBOUNCED <= '0';
  End if;
end process DEBOUNCE_BUTTON1;

DEBOUNCE_BUTTON2: process (debounce_clock)
begin
  wait until (debounce_clock'event) and (debounce_clock='1');
  SHIFT_PB2(2 Downto 0) <= SHIFT_PB2(3 Downto 1);
  SHIFT_PB2(3) <= PB2_Sync;
  If SHIFT_PB2(3 Downto 0)="1111" THEN
    PB2_DEBOUNCED <= '1';
  ELSE 
    PB2_DEBOUNCED <= '0';
  End if;
end process DEBOUNCE_BUTTON2;

SINGLE_PULSE_PB1: process (Clock)
begin
  wait until (CLOCK'event) and (CLOCK='1');
  If POWER_ON='0' Then
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
 End if;
end process SINGLE_PULSE_PB1;


SINGLE_PULSE_PB2: process (Clock)
begin
  wait until (CLOCK'event) and (CLOCK='1');
   If POWER_ON='0' Then
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
  End if;
end process SINGLE_PULSE_PB2;


end behavior;

