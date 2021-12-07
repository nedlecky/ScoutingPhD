-- Random Bit Tester
-- Can we get astable states wu S/U/H violations?
-- Dr. Ned Lecky
-- 4-2-2002

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity randtest06 is
	port(
		clk													: in	std_logic;
		pb1													: in	std_logic;
		lsb_a, lsb_b, lsb_c, lsb_d, lsb_e, lsb_f, lsb_g,
		lsb_dp,
		msb_a, msb_b, msb_c, msb_d, msb_e, msb_f, msb_g,
		msb_dp 												: out std_logic         
	);
end randtest06;

architecture a of randtest06 is
	component dec_7seg
		port(
			hex_digit: in std_logic_vector(3 downto 0);
			segment_a, segment_b, segment_c, segment_d,
			segment_e, segment_f, segment_g : out std_logic
		);
	end component;
	signal divcnt : std_logic_vector(1 downto 0);
	signal count : std_logic_vector(7 downto 0);
	signal clkdiv : std_logic;
	signal flippybits, randbits : std_logic_vector(7 downto 0);
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

	flippybits <= not flippybits;

	-- divide down clock to accommodate counter speed
	process (clk)
	begin
		wait until rising_edge(clk);
		divcnt <= divcnt + 1;
		if divcnt="00" then
			clkdiv <= not clkdiv;
		end if;
	end process;

	process (pb1)
	begin
		wait until rising_edge(pb1);
		randbits <= flippybits;
	end process;

	process (clkdiv)
	begin
		if rising_edge(clkdiv) then
			if count=randbits then
				lsb_dp <= '1';
				msb_dp <= '1';
			else
				lsb_dp <= '0';
				msb_dp <= '0';
				count <= randbits;
			end if;
		end if;
	end process;
end a;

