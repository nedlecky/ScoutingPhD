-- Latch-ff
-- Demo showing simple latches and D-flops
-- None of these outputs latch except for z(5)

-- University of Vermont
-- EE 231: Digital Computer Design I Spring 2002
-- Dr. Ned Lecky

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity latch-ff is
	port
	(
		d			: in	std_logic;
		clk			: in	std_logic;
		q			: out	std_logic_vector(5 downto 0)
	);
	
end latch-ff;

architecture a of latch-ff is
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
	process
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

