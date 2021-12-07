library ieee;
use ieee.std_logic_1164.all;
use work.dflop_pkg.all;

entity Areg is port(
	AIn:		in std_logic_vector(7 downto 0);
	ALoad:		in std_logic_vector(7 downto 0);
	clk,le:		in std_logic;
	AOut:		out std_logic_vector(7 downto 0));
end;

architecture archAreg of Areg is
	begin
	d0: dflop port map(d=>AIn(0),clk=>clk,le=>le,ld=>ALoad(0),q=>AOut(0));
	d1: dflop port map(d=>AIn(1),clk=>clk,le=>le,ld=>ALoad(1),q=>AOut(1));
	d2: dflop port map(d=>AIn(2),clk=>clk,le=>le,ld=>ALoad(2),q=>AOut(2));
	d3: dflop port map(d=>AIn(3),clk=>clk,le=>le,ld=>ALoad(3),q=>AOut(3));
	d4: dflop port map(d=>AIn(4),clk=>clk,le=>le,ld=>ALoad(4),q=>AOut(4));
	d5: dflop port map(d=>AIn(5),clk=>clk,le=>le,ld=>ALoad(5),q=>AOut(5));
	d6: dflop port map(d=>AIn(6),clk=>clk,le=>le,ld=>ALoad(6),q=>AOut(6));
	d7: dflop port map(d=>AIn(7),clk=>clk,le=>le,ld=>ALoad(7),q=>AOut(7));
end;

library ieee;
use ieee.std_logic_1164.all;
package Areg_pkg is
	component Areg port(
	AIn:		in std_logic_vector(7 downto 0);
	ALoad:		in std_logic_vector(7 downto 0);
	clk,le:		in std_logic;
	AOut:		out std_logic_vector(7 downto 0));
	end component;
end;
