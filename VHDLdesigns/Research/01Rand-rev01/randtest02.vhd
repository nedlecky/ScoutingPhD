-- Just a counter, running at 25MHz/2^21 = about 12 Hz
-- Dr. Ned Lecky
-- 4-2-2002

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity randtest02 is
	port(
		clk													: in	std_logic;
		lsb_a, lsb_b, lsb_c, lsb_d, lsb_e, lsb_f, lsb_g,
		lsb_dp,
		msb_a, msb_b, msb_c, msb_d, msb_e, msb_f, msb_g,
		msb_dp 												: out std_logic         
	);
end randtest02;

architecture a of randtest02 is
	component dec_7seg
		port(
			hex_digit: in std_logic_vector(3 downto 0);
			segment_a, segment_b, segment_c, segment_d,
			segment_e, segment_f, segment_g : out std_logic
		);
	end component;
	signal count : std_logic_vector(7 downto 0);
	signal divcount : std_logic_vector(24 downto 0);
begin
	msd: dec_7seg
		port map(
			hex_digit => count(7 downto 4),
			segment_a => msb_a, segment_b => msb_b, segment_c => msb_c, 
			segment_d => msb_d,	segment_e => msb_e, segment_f => msb_f, 
			segment_g => msb_g
		);

	lsd: dec_7seg
		port map(
			hex_digit => count(3 downto 0),
			segment_a => lsb_a, segment_b => lsb_b, segment_c => lsb_c, 
			segment_d => lsb_d,	segment_e => lsb_e, segment_f => lsb_f, 
			segment_g => lsb_g
		);
	lsb_dp <= '0';
	msb_dp <= '0';

	process (clk)
	begin
		wait until rising_edge(clk);

		if divcount(21)='1' then
			divcount<=(others=>'0');
		else
			divcount <= divcount + 1;
		end if;
	end process;

	process (clk)
	begin
		wait until rising_edge(clk);

		if divcount(21) = '1' then
			count <= count + 1;
		end if;
	end process;
end a;

