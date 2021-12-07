-- 5-bit Multiplier
-- Direct implementation of [B&V] algorithm

-- University of Vermont
-- EE 231: Digital Computer Design I Spring 2002
-- Dr. Ned Lecky

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

entity multiplier is
	port
	(
		x_in,y_in	: in	signed(4 downto 0);
		f			: out	signed(9 downto 0)
	);
	
end multiplier;

architecture arch of multiplier is
	signal PP0,PP1,PP2,PP3 : signed(6 downto 0);
	signal x_sex : signed(5 downto 0);
	signal x,y : signed(4 downto 0);
begin
	process(x,y)
	begin
		-- [B&V] algorithm only works for positive multiplier (bottom number)
		-- if not, just negate both inputs and we'll get the same answer
		-- what are we multiplying?
		if y_in(4)='0' then
			x <= x_in;
			y <= y_in;
		else
			x <= -x_in;
			y <= -y_in;
		end if;

		-- signed extend x
		x_sex <= x(4) & x;

		-- first partial sum		
		if y(0)='1' then
			PP0(4 downto 0) <= x;
		else
			PP0(4 downto 0) <= "00000";
		end if;
		PP0(5) <= PP0(4); -- sign extend
		PP0(6) <= PP0(4);

		-- second partial sum
		if y(1)='1' then
			PP1(5 downto 0) <= PP0(6 downto 1) + x_sex;
		else
			PP1(5 downto 0) <= PP0(6 downto 1);
		end if;
		PP1(6) <= PP1(5); -- sign extend

		-- third partial sum
		if y(2)='1' then
			PP2(5 downto 0) <= PP1(6 downto 1) + x_sex;
		else
			PP2(5 downto 0) <= PP1(6 downto 1);
		end if;
		PP2(6) <= PP2(5); -- sign extend

		-- fourth partial sum
		if y(3)='1' then
			PP3(5 downto 0) <= PP2(6 downto 1) + x_sex;
		else
			PP3(5 downto 0) <= PP2(6 downto 1);
		end if;
		PP3(6) <= PP3(5); -- sign extend

		-- final sum
		if y(4)='1' then
			f(9 downto 4) <= PP3(6 downto 1) + x_sex;
		else
			f(9 downto 4) <= PP3(6 downto 1);
		end if;

		-- carry down lower order bits
		f(3) <= PP3(0);
		f(2) <= PP2(0);
		f(1) <= PP1(0);
		f(0) <= PP0(0);
	end process;
end arch;

