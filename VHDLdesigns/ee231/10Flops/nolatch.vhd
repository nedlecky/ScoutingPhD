-- Nolatch
-- Demo showing the subtle difference between memory and no memory
-- None of these outputs latch except for z(5)

-- University of Vermont
-- EE 231: Digital Computer Design I Spring 2002
-- Dr. Ned Lecky

library ieee;
use ieee.std_logic_1164.all;

entity nolatch is
	port
	(
		x,y			: in	std_logic;
		z			: out	std_logic_vector(5 downto 0)
	);
	
end nolatch;

architecture a of nolatch is
	signal xy : std_logic_vector(1 downto 0);
begin
	-- reasonable or gate
	z(0) <= x or y;

	-- another way, not so reasonable
	z(1) <= '1' when x='1' or y='1' else '0';

	-- or gate design as truth table
	xy <= x & y;
	with xy select
		z(2) <= '0' when "00",
				'1' when "01",
				'1' when "10",
				'1' when others; --"01",

	-- using if else
	process (x,y)
	begin
		if x='1' or y='1' then
			z(3)<='1';
		else
			z(3)<='0';
		end if;
	end process;

	-- using case
	process (x,y)
	begin
		case xy is
			when "00" =>
				z(4) <= '0';
			when others =>
				z(4) <= '1';
		end case;
	end process;

	-- PROBLEM implied latch
	-- Synthesizes as z(5) <= x + y + z(5)
	process (x,y)
	begin
		if x='1' or y='1' then
			z(5)<='1';
		end if;
	end process;

end a;

