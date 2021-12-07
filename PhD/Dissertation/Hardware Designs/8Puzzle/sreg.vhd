library ieee;
use ieee.std_logic_1164.all;
use work.dflop_pkg.all;

entity Sreg is port(
	SIn:		in std_logic_vector(35 downto 0);
	SLoad:		in std_logic_vector(35 downto 0);
	clk,le:		in std_logic;
	SOut:		out std_logic_vector(35 downto 0));
end;

architecture archSreg of Sreg is
	begin
	d00: dflop port map(d=>SIn(0),clk=>clk,le=>le,ld=>SLoad(0),q=>SOut(0));
	d01: dflop port map(d=>SIn(1),clk=>clk,le=>le,ld=>SLoad(1),q=>SOut(1));
	d02: dflop port map(d=>SIn(2),clk=>clk,le=>le,ld=>SLoad(2),q=>SOut(2));
	d03: dflop port map(d=>SIn(3),clk=>clk,le=>le,ld=>SLoad(3),q=>SOut(3));		
	d04: dflop port map(d=>SIn(4),clk=>clk,le=>le,ld=>SLoad(4),q=>SOut(4));	
	d05: dflop port map(d=>SIn(5),clk=>clk,le=>le,ld=>SLoad(5),q=>SOut(5));	
	d06: dflop port map(d=>SIn(6),clk=>clk,le=>le,ld=>SLoad(6),q=>SOut(6));	
	d07: dflop port map(d=>SIn(7),clk=>clk,le=>le,ld=>SLoad(7),q=>SOut(7));	
	d08: dflop port map(d=>SIn(8),clk=>clk,le=>le,ld=>SLoad(8),q=>SOut(8));	
	d09: dflop port map(d=>SIn(9),clk=>clk,le=>le,ld=>SLoad(9),q=>SOut(9));	
	d10: dflop port map(d=>SIn(10),clk=>clk,le=>le,ld=>SLoad(10),q=>SOut(10));	
	d11: dflop port map(d=>SIn(11),clk=>clk,le=>le,ld=>SLoad(11),q=>SOut(11));	
	d12: dflop port map(d=>SIn(12),clk=>clk,le=>le,ld=>SLoad(12),q=>SOut(12));	
	d13: dflop port map(d=>SIn(13),clk=>clk,le=>le,ld=>SLoad(13),q=>SOut(13));	
	d14: dflop port map(d=>SIn(14),clk=>clk,le=>le,ld=>SLoad(14),q=>SOut(14));	
	d15: dflop port map(d=>SIn(15),clk=>clk,le=>le,ld=>SLoad(15),q=>SOut(15));	
	d16: dflop port map(d=>SIn(16),clk=>clk,le=>le,ld=>SLoad(16),q=>SOut(16));	
	d17: dflop port map(d=>SIn(17),clk=>clk,le=>le,ld=>SLoad(17),q=>SOut(17));	
	d18: dflop port map(d=>SIn(18),clk=>clk,le=>le,ld=>SLoad(18),q=>SOut(18));	
	d19: dflop port map(d=>SIn(19),clk=>clk,le=>le,ld=>SLoad(19),q=>SOut(19));	
	d20: dflop port map(d=>SIn(20),clk=>clk,le=>le,ld=>SLoad(20),q=>SOut(20));	
	d21: dflop port map(d=>SIn(21),clk=>clk,le=>le,ld=>SLoad(21),q=>SOut(21));	
	d22: dflop port map(d=>SIn(22),clk=>clk,le=>le,ld=>SLoad(22),q=>SOut(22));	
	d23: dflop port map(d=>SIn(23),clk=>clk,le=>le,ld=>SLoad(23),q=>SOut(23));	
	d24: dflop port map(d=>SIn(24),clk=>clk,le=>le,ld=>SLoad(24),q=>SOut(24));	
	d25: dflop port map(d=>SIn(25),clk=>clk,le=>le,ld=>SLoad(25),q=>SOut(25));	
	d26: dflop port map(d=>SIn(26),clk=>clk,le=>le,ld=>SLoad(26),q=>SOut(26));	
	d27: dflop port map(d=>SIn(27),clk=>clk,le=>le,ld=>SLoad(27),q=>SOut(27));	
	d28: dflop port map(d=>SIn(28),clk=>clk,le=>le,ld=>SLoad(28),q=>SOut(28));	
	d29: dflop port map(d=>SIn(29),clk=>clk,le=>le,ld=>SLoad(29),q=>SOut(29));	
	d30: dflop port map(d=>SIn(30),clk=>clk,le=>le,ld=>SLoad(30),q=>SOut(30));	
	d31: dflop port map(d=>SIn(31),clk=>clk,le=>le,ld=>SLoad(31),q=>SOut(31));	
	d32: dflop port map(d=>SIn(32),clk=>clk,le=>le,ld=>SLoad(32),q=>SOut(32));	
	d33: dflop port map(d=>SIn(33),clk=>clk,le=>le,ld=>SLoad(33),q=>SOut(33));	
	d34: dflop port map(d=>SIn(34),clk=>clk,le=>le,ld=>SLoad(34),q=>SOut(34));	
	d35: dflop port map(d=>SIn(35),clk=>clk,le=>le,ld=>SLoad(35),q=>SOut(35));	
end;

library ieee;
use ieee.std_logic_1164.all;
package Sreg_pkg is
	component Sreg port(
	SIn:		in std_logic_vector(35 downto 0);
	SLoad:		in std_logic_vector(35 downto 0);
	clk,le:		in std_logic;
	SOut:		out std_logic_vector(35 downto 0));
	end component;
end;
