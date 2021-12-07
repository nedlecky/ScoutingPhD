-- Register01
-- Simple register example

-- University of Vermont
-- EE 231: Digital Computer Design I Spring 2002
-- Dr. Ned Lecky

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity register01 is
	port
	(
		d			: in	std_logic_vector(7 downto 0);	-- external load inputs
		clk			: in	std_logic;						-- clock
		aclear		: in	std_logic;						-- async clear
		sload		: in	std_logic;						-- sync load from d
		sclear		: in	std_logic;						-- sync clear
		sincr		: in	std_logic;						-- sync increment
		q			: out	std_logic_vector(7 downto 0)	-- outputs
	);
	
end register01;

architecture a of register01 is
begin
	-- register with some smarts
	process (clk,aclear)
		variable qi : std_logic_vector(7 downto 0);
	begin
		if aclear='1' then qi := (others => '0');
		elsif clk'event and clk='1' then
			if sclear='1' then qi:=(others=>'0');
			elsif sincr='1' then qi:=qi+1;
			elsif sload='1' then qi:=d;
			end if;
		end if;
		q<=qi;
	end process;
end a;

