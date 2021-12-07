library ieee;
use ieee.std_logic_1164.all;

entity GC is port(
	S:		in std_logic_vector(35 downto 0);
	result:		out boolean);
end;

architecture archGC of GC is
	begin
	result <= (S="000100100011100000000100011101100101");
end;

library ieee;
use ieee.std_logic_1164.all;
package GC_pkg is
	component GC port(
		S: 	in std_logic_vector(35 downto 0);
		result:	out boolean);
	end component;
end;
 
