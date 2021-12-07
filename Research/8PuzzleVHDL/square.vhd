-- 8-Puzzle Cell Squares
-- J.E. Lecky 10-99

library ieee;
use ieee.std_logic_1164.all;
entity square4 is port(
	clk:	in std_logic;
	clr:	in std_logic;
	reinit:	in std_logic;
	rand:	in std_logic_vector(1 downto 0);
	goal:	in std_logic_vector(3 downto 0);
	init:	in std_logic_vector(3 downto 0);
	in0:	in std_logic_vector(3 downto 0);
	in1:	in std_logic_vector(3 downto 0);
	in2:	in std_logic_vector(3 downto 0);
	in3:	in std_logic_vector(3 downto 0);
	clr0:	out std_logic;
	clr1:	out std_logic;
	clr2:	out std_logic;
	clr3:	out std_logic;
	output:	buffer std_logic_vector(3 downto 0);
	match:	out std_logic);
end;

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

architecture square4_arch of square4 is
begin
	match <= '1' when output=goal else '0';
	action: process(clk,clr,reinit) begin
		if clr='1' then
			output <= "0000";
		elsif rising_edge(clk) then
			if reinit='1' then
				output <= init;
			elsif output="0000" then
				if rand="00" then
					output <= in0;
					clr0 <= '1';
					clr1 <= '0';
					clr2 <= '0';
					clr3 <= '0';
				elsif rand="01" then
					output <= in1;
					clr0 <= '0';
					clr1 <= '1';
					clr2 <= '0';
					clr3 <= '0';
				elsif rand="10" then
					output <= in2;
					clr0 <= '0';
					clr1 <= '0';
					clr2 <= '1';
					clr3 <= '0';
				else
					output <= in3;
					clr0 <= '0';
					clr1 <= '0';
					clr2 <= '0';
					clr3 <= '1';
				end if;
			end if;
		end if;
	end process action;
end;
architecture square3_arch of square3 is
begin
	match <= '1' when output=goal else '0';
	action: process(clk,clr,reinit) begin
		if clr='1' then
			output <= "0000";
		elsif rising_edge(clk) then
			if reinit='1' then
				output <= init;
			elsif output="0000" then
				if rand="00" then
					output <= in0;
					clr0 <= '1';
					clr1 <= '0';
					clr2 <= '0';
				elsif rand="01" then
					output <= in1;
					clr0 <= '0';
					clr1 <= '1';
					clr2 <= '0';
				else
					output <= in2;
					clr0 <= '0';
					clr1 <= '0';
					clr2 <= '1';
				end if;
			end if;
		end if;
	end process action;
end;
architecture square2_arch of square2 is
begin
	match <= '1' when output=goal else '0';
	action: process(clk,clr,reinit) begin
		if clr='1' then
			output <= "0000";
		elsif rising_edge(clk) then
			if reinit='1' then
				output <= init;
			elsif output="0000" then
				if rand(1)='0' then
					output <= in0;
					clr0 <= '1';
					clr1 <= '0';
				else
					output <= in1;
					clr0 <= '0';
					clr1 <= '1';
				end if;
			end if;
		end if;
	end process action;
end;
 
library ieee;
use ieee.std_logic_1164.all;
package square_pkg is
	component square4 port(
		clk:	in std_logic;
		clr:	in std_logic;
		reinit:	in std_logic;
		rand:	in std_logic_vector(1 downto 0);
		goal:	in std_logic_vector(3 downto 0);
		init:	in std_logic_vector(3 downto 0);
		in0:	in std_logic_vector(3 downto 0);
		in1:	in std_logic_vector(3 downto 0);
		in2:	in std_logic_vector(3 downto 0);
		in3:	in std_logic_vector(3 downto 0);
		clr0:	out std_logic;
		clr1:	out std_logic;
		clr2:	out std_logic;
		clr3:	out std_logic;
		output:	buffer std_logic_vector(3 downto 0);
		match:	out std_logic);
	end component;
	component square3 port(
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
	end component;
	component square2 port(
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
	end component;
end;
 