library ieee;
use ieee.std_logic_1164.all;
use work.numeric_std.all;

entity osc is port(
	oscout:	buffer std_logic);
end;

architecture osc_arch of osc is
	signal newbit: bit;
begin
	process(oscout)
	begin
	oscout<=not oscout;
	end process;
end;
