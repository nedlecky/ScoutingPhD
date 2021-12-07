-- 8-Puzzle Cell Squares
-- J.E. Lecky 10-99

library ieee;
use ieee.std_logic_1164.all;
entity square2 is port(
	clk:	in std_logic;
	clr:	in std_logic;
	reinit:	in std_logic;
	rand:	in std_logic_vector(1 downto 0);
	goal:	in std_logic_vector(3 downto 0);
	init:	in std_logic_vector(3 downto 0);
	in0:	in std_logic_vector(3 downto 0);
	in1:	in std_logic_vector(3 downto 0);
	clr0:	out std_logic;
	clr1:	out std_logic;
	output:	buffer std_logic_vector(3 downto 0);
	match:	out std_logic);
end;

architecture square2_arch of square2 is
	signal next_output:	std_logic_vector(3 downto 0);
begin
	match <= '1' when output=goal else '0';

	process(output,rand) begin
		clr0 <= '0';
		clr1 <= '0';
		if output="0000" then
			if rand(1)='0' then
				next_output <= in0;
				clr0 <= '1';
			else
				next_output <= in1;
				clr1 <= '1';
			end if;
		end if;
	end process;

	process(clk) begin
		wait until rising_edge(clk);
		if reinit='1' then
			output <= init;
		elsif clr='1' then
			output <= "0000";
		else
			if output="0000" then output <= next_output; end if;
		end if;
	end process;
end;
 

