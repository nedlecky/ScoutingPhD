library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity run3x3 is
	port
	(
		clk:	in std_logic;
		reset:	in std_logic;
		d_best:	out integer range 0 to 63;
		init:	in std_logic_vector(35 downto 0);
		solved:	out std_logic
	);
end run3x3;

architecture p3x3_arch of run3x3 is
	component p3x3 is
		port
		(
			clk:	in std_logic;
			reinit:	in std_logic;
			init:	in std_logic_vector(35 downto 0);
			solved:	out std_logic
		);
	end component;
	signal reinit:	std_logic;
	signal solve:	std_logic_vector(3 downto 0);
	signal best:	integer range 0 to 63;
	signal depth:	integer range 0 to 63;
	type stateType is(s_trapped,s_start,s_reinit,s_seek);
	signal state:	stateType;
begin
	p0: p3x3 port map (clk,reinit,init,solve(0));
	p1: p3x3 port map (clk,reinit,init,solve(1));
	p2: p3x3 port map (clk,reinit,init,solve(2));
	p3: p3x3 port map (clk,reinit,init,solve(3));

	process
	begin
		wait until rising_edge(clk);
		if reset='1' then
			state <= s_start;
		else
		case state is
			when s_trapped =>
				best <= 0;
				solved <= '0';
			when s_start =>
				best <= 40;
				solved <= '0';
				state <= s_reinit;
			when s_reinit =>
				depth <= 0;
				state <= s_seek;
			when s_seek =>
				if solve(0)='1' or solve(1)='1' or solve(2)='1' or solve(3)='1' then
					best <= depth;
					state <= s_reinit;
					solved <= '1';
					-- must record solution!
				elsif depth>best then
					state <= s_reinit;
				else
					depth <= depth + 1;
				end if;
			when others =>
				state <= s_start;
		end case;
		end if;
	end process;

	reinit <= '1' when state=s_reinit else '0';
	d_best <= best;
		
end p3x3_arch;

