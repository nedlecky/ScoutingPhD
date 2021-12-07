-- 32-bit CLA Adder, block 8

-- University of Vermont
-- EE 231: Digital Computer Design I Spring 2002
-- Dr. Ned Lecky

library ieee;
use ieee.std_logic_1164.all;

entity CLA32B8 is
	port
	(
		x,y		: in	std_logic_vector(31 downto 0);
		cin		: in	std_logic;
		s		: out	std_logic_vector(31 downto 0);
		cout	: out	std_logic
	);
end CLA32B8;

architecture arch of CLA32B8 is
	component CLA8 is
		port
		(
			x,y		: in	std_logic_vector(7 downto 0);
			cin		: in	std_logic;
			s		: out	std_logic_vector(7 downto 0);
			cout	: out	std_logic
		);
	end component;
	signal c : std_logic_vector(4 downto 0);
begin
	c(0) <= cin;
	-- Blocks
	BlockGen: for i in 0 to 3 generate
		clagen: CLA8
		port map(
			x((i+1)*8-1 downto i*8),
			y((i+1)*8-1 downto i*8),
			c(i),
			s((i+1)*8-1 downto i*8),
			c(i+1)
		);
	end generate;
	cout <= c(4);
end arch;

