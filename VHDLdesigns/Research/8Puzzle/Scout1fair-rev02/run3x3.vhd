-- 8 Puzzle Scout Cluster
-- Scout-1
-- J.E. Lecky 5-2002

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity run3x3 is
	generic
	(
		nscouts: integer := 6
	);
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
	signal solve:	std_logic_vector(nscouts downto 1);
	signal best:	integer range 0 to 63;
	signal depth:	integer range 0 to 63;
	type stateType is(s_start,s_reinit,s_seek1,s_seek2);
	signal state:	stateType;
begin
	scout: for i in 1 to nscouts generate
		pn: p3x3 port map (clk,reinit,init,solve(i));
	end generate;

	process
		variable solved_tmp: std_logic;
	begin
		wait until rising_edge(clk);
		if reset='1' then
			state <= s_start;
		else
			case state is
				when s_start =>
					best <= 40;
					solved <= '0';
					state <= s_reinit;
				when s_reinit =>
					depth <= 0;
					state <= s_seek1;
				when s_seek1 =>
					state <= s_seek2;
				when s_seek2 =>
					state <= s_seek1;
					solved_tmp := '0';
					for i in 1 to nscouts loop
						solved_tmp := solved_tmp or solve(i);
					end loop;
					if solved_tmp='1' then
						best <= depth;
						state <= s_reinit;
						solved <= '1';
						-- must record solution!
					elsif depth>=best then
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

