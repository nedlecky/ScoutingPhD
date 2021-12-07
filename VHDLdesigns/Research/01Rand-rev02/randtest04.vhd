-- Random Bit Tester
-- 1's per 2^24 tests, tally and report
-- Dr. Ned Lecky
-- 4-11-2002

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity randtest04 is
	generic(
		randwidth : integer := 4
	);
	port(
		pb1,pb2					: in	std_logic;
		clk						: in	std_logic;
		clkdiv_out				: out	std_logic;
		osc0_out				: out	std_logic;
		r10_out					: out std_logic;
		r20_out					: out std_logic;
		r4_out					: out std_logic;
		lsb_a, lsb_b, lsb_c, lsb_d, lsb_e, lsb_f, lsb_g,
		lsb_dp,
		msb_a, msb_b, msb_c, msb_d, msb_e, msb_f, msb_g,
		msb_dp 					: out std_logic         
	);
end randtest04;

architecture a of randtest04 is
	component clk_div is
		port(
			clock_25Mhz				: IN	STD_LOGIC;
			clock_1MHz				: OUT	STD_LOGIC;
			clock_100KHz			: OUT	STD_LOGIC;
			clock_10KHz				: OUT	STD_LOGIC;
			clock_1KHz				: OUT	STD_LOGIC;
			clock_100Hz				: OUT	STD_LOGIC;
			clock_10Hz				: OUT	STD_LOGIC;
			clock_1Hz				: OUT	STD_LOGIC);
	end component;
	component debounce is
		port(
			pb, clock_100Hz 	: IN	STD_LOGIC;
			pb_debounced		: OUT	STD_LOGIC);
	end component;
	component dec_7seg
		port(
			hex_digit: in std_logic_vector(3 downto 0);
			segment_a, segment_b, segment_c, segment_d,
			segment_e, segment_f, segment_g : out std_logic
		);
	end component;
	signal divcnt : std_logic_vector(2 downto 0);
	signal clk1MHz,clk100Hz : std_logic;
	signal count,tally : std_logic_vector(24 downto 0);
	signal clkdiv : std_logic;
	signal pb1_debounced,pb2_debounced : std_logic;
	signal osc, r1 : std_logic_vector(7 downto 0);
	signal r2 : std_logic_vector(3 downto 0);
	signal r4 : std_logic_vector(1 downto 0);
	signal r8 : std_logic;
	signal display_sel : std_logic_vector(1 downto 0);
	signal display_drive : std_logic_vector(7 downto 0);
begin
	-- ring oscillators
	osc <= not osc;
	osc0_out <= osc(0);

	-- slow down clock to accommodate logic speed
	clock_divider: clk_div
		port map(
			clock_25MHz => clk,
			clock_1MHz => clk1MHz,
			clock_100Hz => clk100Hz);

	-- pb debouncing
	pb1_debouncer : debounce	port map(pb1,clk100Hz,pb1_debounced);
	pb2_debouncer : debounce	port map(pb2,clk100Hz,pb2_debounced);

	-- slow down clock to accommodate logic speed
	process (clk)
	begin
		wait until rising_edge(clk);
--		divcnt <= divcnt + 1;
--		if divcnt="000" then-- or divcnt="10" then
			clkdiv <= not clkdiv;
--		end if;
	end process;
	clkdiv_out <= clkdiv;

	-- grab r1 bits
	process (clkdiv)
	begin
		wait until rising_edge(clkdiv);
		r1 <= osc;
	end process;

	-- compute r2 and r4 bits
	r2(0) <= r1(0) xor r1(1);
	r2(1) <= r1(2) xor r1(3);
	r2(2) <= r1(4) xor r1(5);
	r2(3) <= r1(6) xor r1(7);
	r4(0) <= r2(0) xor r2(1);
	r4(1) <= r2(2) xor r2(3);
	r8 <= r4(0) xor r4(1);

	-- propagate some rbits to the outputs
	r10_out <= r1(0);
	r20_out <= r2(0);
	r4_out <= r4(0);
	
	-- count up 1s in test bit
	process (clkdiv)
	begin
		if rising_edge(clkdiv) then
			if pb1_debounced='1' then
				count<=(others=>'0');
				tally<=(others=>'0');
			elsif count/=x"FFFFFF" then
				if r8='1' then --r1(0)='1' then
					tally <= tally+1;
				end if;
				count <= count+1;
			end if;
		end if;
	end process;

	-- 7 segment display round robin
	process (pb1_debounced,pb2_debounced)
	begin
		if pb1_debounced='1' then
			display_sel<="00";
		elsif rising_edge(pb2_debounced) then
			if display_sel="10" then
				display_sel <= "00";
			else
				display_sel <= display_sel + 1;
			end if;
		end if;
	end process;

	-- 7 segment display multiplexing
	with display_sel select
		display_drive <=	tally(23 downto 16) when "00",
							tally(15 downto 8) when "01",
							tally(7 downto 0) when others; --"01",

	-- 7 segment displays
	msd: dec_7seg
		port map(
			hex_digit => display_drive(7 downto 4),
			segment_a => msb_a, segment_b => msb_b, segment_c => msb_c, 
			segment_d => msb_d,	segment_e => msb_e, segment_f => msb_f, 
			segment_g => msb_g
		);

	lsd: dec_7seg
		port map(
			hex_digit => display_drive(3 downto 0),
			segment_a => lsb_a, segment_b => lsb_b, segment_c => lsb_c, 
			segment_d => lsb_d,	segment_e => lsb_e, segment_f => lsb_f, 
			segment_g => lsb_g
		);
	msb_dp <= not display_sel(1);
	lsb_dp <= not display_sel(0);
end a;

