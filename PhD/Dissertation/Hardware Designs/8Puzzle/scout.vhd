library ieee;
use ieee.std_logic_1164.all;
use work.Sreg_pkg.all;
use work.Areg_pkg.all;
use work.GC_pkg.all;
use work.NS_pkg.all;
use work.PA_pkg.all;
use work.LFSR8_pkg.all;

entity Scout is port(
	Sinit:		in std_logic_vector(35 downto 0);
	Ainit:		in std_logic_vector(7 downto 0);
	clk:		in std_logic;
	load:		in std_logic;
	result:		out boolean;
	a0:		out std_logic);
end;

architecture archScout of Scout is
	signal SBus: std_logic_vector(35 downto 0);
	signal SBusNext: std_logic_vector(35 downto 0);
	signal ABus: std_logic_vector(7 downto 0);
	signal ABusNext: std_logic_vector(7 downto 0);
	signal randBus: std_logic_vector(7 downto 0);
	begin
	lfsr8: LFSR8 port map (clk=>clk,rand=>randBus);
	gc: GC port map (S=>Sbus,result=>result);
	sreg: Sreg port map (SIn=>SBusNext,SLoad=>Sinit,SOut=>SBus,clk=>clk,le=>load);
	areg: Areg port map (AIn=>ABusNext,ALoad=>Ainit,AOut=>ABus,clk=>clk,le=>load);
	pa: PA port map (random=>randBus,SIn=>SBus,AIn=>ABus,AOut=>ABusNext);
	ns: NS port map (SIn=>SBus,SOut=>SBusNext,AIn=>ABusNext);
	a0 <= ABus(0);
	
end;

library ieee;
use ieee.std_logic_1164.all;
package GC_pkg is
	component GC port(
		S: 	in std_logic_vector(35 downto 0);
		result:	out boolean);
	end component;
end;
