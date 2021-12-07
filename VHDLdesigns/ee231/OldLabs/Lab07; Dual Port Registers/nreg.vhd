-- An N-bit Write-enabled Register
-- John E. Lecky 2/16/98

library ieee;
use ieee.std_logic_1164.all;
use work.dflop_pkg.all;

entity nreg is generic( n: integer := 4);
	port(
	d:	in std_logic_vector(n-1 downto 0);
	q:	buffer std_logic_vector(n-1 downto 0);
	clk,en:	in std_logic);
end;

architecture nreg_arch of nreg is
	begin
	dn: for i in 0 to n-1 generate
		dn: dflop port map(d=>d(i),q=>q(i),en=>en,clk=>clk);
	end generate;
end;

library ieee;
use ieee.std_logic_1164.all;
package nreg_pkg is
	component nreg generic( n: integer := 4);
	port(
	d:	in std_logic_vector(n-1 downto 0);
	q:	buffer std_logic_vector(n-1 downto 0);
	clk,en:	in std_logic);
	end component;
end;