-- 8-Puzzle Cell Squares
-- J.E. Lecky 10-99

library ieee;
use ieee.std_logic_1164.all;
entity square3 is port(
	clk:	in std_logic;
	clr:	in std_logic;
	reinit:	in std_logic;
	rand:	in std_logic_vector(1 downto 0);
	goal:	in std_logic_vector(3 downto 0);
	init:	in std_logic_vector(3 downto 0);
	in0:	in std_logic_vector(3 downto 0);
	in1:	in std_logic_vector(3 downto 0);
	in2:	in std_logic_vector(3 downto 0);
	clr0:	out std_logic;
	clr1:	out std_logic;
	clr2:	out std_logic;
	output:	buffer std_logic_vector(3 downto 0);
	match:	out std_logic);
end;

architecture square3_arch of square3 is
begin
	match <= '1' when output=goal else '0';
	process(clk) begin
		if rising_edge(clk) then
			clr0 <= '0';
			clr1 <= '0';
			clr2 <= '0';
			if reinit='1' then
				output <= init;
			elsif clr='1' then
				output <= "0000";
			elsif output="0000" then
				if rand="00" then
					output <= in0;
					clr0 <= '1';
				elsif rand="01" then
					output <= in1;
					clr1 <= '1';
				else
					output <= in2;
					clr2 <= '1';
				end if;
			end if;
		end if;
	end process;
end;

