-- Latchff
-- Demo showing simple latches and D-flops

-- University of Vermont
-- EE 231: Digital Computer Design I Spring 2002
-- Dr. Ned Lecky

library ieee;
use ieee.std_logic_1164.all;
entity latchff is
	port
	(
		d			: in	std_logic;
		clk			: in	std_logic;
		q			: out	std_logic_vector(4 downto 0)
	);
	
end latchff;

architecture a of latchff is
begin
	-- latch with if
	process (d,clk)
	begin
		if clk='1' then
			q(0)<=d;
		end if;
	end process;

	-- latch with wait
	process
	begin
		wait until clk='1';
		q(1)<=d;
	end process;

	-- dflop with if and clk'event
	process (clk)
	begin
		if clk'event and clk='1' then
			q(2)<=d;
		end if;
	end process;

	-- dflop with if and rising_edge
	process
	begin
		if rising_edge(clk) then
			q(3)<=d;
		end if;
	end process;

	-- dflop with wait
	process
	begin
		wait until rising_edge(clk);
		q(4)<=d;
	end process;

end a;

