-- Random Bit Tester
-- This one shows a slight predisposition to 0s when a 29-bit counter, 1s with a 24 bit counter
-- ???
-- Dr. Ned Lecky
-- 4-2-2002

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity randtest03 is
	port(
		clk													: in	std_logic;
		pb1													: in	std_logic;
		lsb_a, lsb_b, lsb_c, lsb_d, lsb_e, lsb_f, lsb_g,
		lsb_dp,
		msb_a, msb_b, msb_c, msb_d, msb_e, msb_f, msb_g,
		msb_dp 												: out std_logic         
	);
end randtest03;

architecture a of randtest03 is
	component dec_7seg
		port(
			hex_digit: in std_logic_vector(3 downto 0);
			segment_a, segment_b, segment_c, segment_d,
			segment_e, segment_f, segment_g : out std_logic
		);
	end component;
	signal divcnt : std_logic_vector(1 downto 0);
	signal count : std_logic_vector(24 downto 0);
	signal clkdiv, flippybit, randbit : std_logic;
begin
	msd: dec_7seg
		port map(
			hex_digit => count(24 downto 21),
			segment_a => msb_a, segment_b => msb_b, segment_c => msb_c, 
			segment_d => msb_d,	segment_e => msb_e, segment_f => msb_f, 
			segment_g => msb_g
		);

	lsd: dec_7seg
		port map(
			hex_digit => count(20 downto 17),
			segment_a => lsb_a, segment_b => lsb_b, segment_c => lsb_c, 
			segment_d => lsb_d,	segment_e => lsb_e, segment_f => lsb_f, 
			segment_g => lsb_g
		);
	lsb_dp <= '0';
	msb_dp <= '0';

	flippybit <= not flippybit;

	-- divide down clock to 12 MHz to accommodate counter speed
	process (clk)
	begin
		wait until rising_edge(clk);
		divcnt <= divcnt + 1;
		if divcnt="00" then
			clkdiv <= not clkdiv;
		end if;
	end process;

	process (clkdiv)
	begin
		wait until rising_edge(clkdiv);
		randbit <= flippybit;
	end process;

	process (pb1,clkdiv)
	begin
		if pb1='0' then
			count<=(others=>'0');
		elsif rising_edge(clkdiv) then
			if randbit='1' then
				count <= count + 1;
			else
				count <= count - 1;
			end if;
		end if;
	end process;
end a;

