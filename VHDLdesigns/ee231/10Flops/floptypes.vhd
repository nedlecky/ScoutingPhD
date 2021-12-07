-- Floptypes
-- Demo showing simple flops

-- University of Vermont
-- EE 231: Digital Computer Design I Spring 2002
-- Dr. Ned Lecky

library ieee;
use ieee.std_logic_1164.all;
entity floptypes is
	port
	(
		d				: in	std_logic;
		clk				: in	std_logic;
		s,r				: in	std_logic;
		clear			: in	std_logic;
		sclear,spreset	: in	std_logic;
		q				: out	std_logic_vector(7 downto 0)
	);
	
end floptypes;

architecture a of floptypes is
begin
	-- sr latch
	process (s,r)
	begin
		if s='1' then
			q(0)<='1';
		elsif r='1' then
			q(0)<='0';
		end if;
	end process;

	-- gated sr latch
	process (clk)
	begin
		if clk='1' then
			if s='1' then
				q(1)<='1';
			elsif r='1' then
				q(1)<='0';
			end if;
		end if;
	end process;

	-- gated d latch
	process (clk)
	begin
		if clk='1' then
			q(2)<=d;
		end if;
	end process;

	-- master-slave d flop
	process (clk)
		variable masterq : std_logic;
	begin
		-- event-based
--		if clk'event and clk='0' then
--			masterq:=d;
--		end if;
--		if clk'event and clk='1' then
--			q(3)<=masterq;
--		end if;
		-- latch-based
		if clk='1' then
			masterq:=d;
		end if;
		if clk='0' then
			q(3)<=masterq;
		end if;
	end process;

	-- Edge-triggered d flop
	process (clk)
	begin
		if clk'event and clk='1' then
			q(4)<=d;
		end if;
	end process;

	-- ET d flop with async clear
	process (clk,clear)
	begin
		if clear='1' then q(5) <= '0';
		elsif clk'event and clk='1' then
			q(5)<=d;
		end if;
	end process;
	
	-- master-slave or ET d flop with async clear and sync clear and preset
	process (clk,clear)
	begin
		if clear='1' then q(7) <= '0';
		elsif clk'event and clk='1' then
			if sclear='1' then q(7)<='0';
			elsif spreset='1' then q(7)<='1';
			else q(7)<=d;
			end if;
		end if;
	end process;
end a;

