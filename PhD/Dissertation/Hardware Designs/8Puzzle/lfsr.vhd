library ieee;
use ieee.std_logic_1164.all;
use work.numeric_std.all;

entity LFSR8 is port(
	clock,reset:	in std_logic;
	enable,load:	in std_logic;
	loadData:	in bit_vector(7 downto 0);
	val:		buffer bit_vector(7 downto 0));
end;

architecture archLFSR8 of LFSR8 is
	signal newbit: bit;
begin
count: process(clock,reset)
	begin
	if (reset='1') then
		val<="00000001";
	elsif (clock'event and clock='1') then
		if(enable='1') then
			if (load='1') then
				val<=loadData;
			else
				newbit<=val(0) xor val(4) xor val(5) xor val(7);
				val<=val sll 1;
				val(0)<=newbit;
			end if;
		end if;
	end if;
	end process;
end;

library ieee;
use ieee.std_logic_1164.all;
package LFSR8_pkg is
	component LFSR8 port(
	clock,reset:	in std_logic;
	enable,load:	in std_logic;
	loadData:	in bit_vector(7 downto 0);
	val:		buffer bit_vector(7 downto 0));
	end component;
end;
