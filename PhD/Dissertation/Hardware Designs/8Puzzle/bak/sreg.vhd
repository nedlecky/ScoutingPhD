library ieee;
use ieee.std_logic_1164.all;
use work.dflop_pkg.all;

entity Sreg is port(
	SIn:		in std_logic_vector(35 downto 0);
	clk,oe:		in std_logic;
	SOut:		out std_logic_vector(35 downto 0));
end;

architecture archSreg of Sreg is
	begin
	d00: dflop port map(d=>SIn(0),clk=>clk,oe=>oe,q=>SOut(0));
	d01: dflop port map(d=>SIn(1),clk=>clk,oe=>oe,q=>SOut(1));
	d02: dflop port map(d=>SIn(2),clk=>clk,oe=>oe,q=>SOut(2));
	d03: dflop port map(d=>SIn(3),clk=>clk,oe=>oe,q=>SOut(3));		
	d04: dflop port map(d=>SIn(4),clk=>clk,oe=>oe,q=>SOut(4));	
	d05: dflop port map(d=>SIn(5),clk=>clk,oe=>oe,q=>SOut(5));	
	d06: dflop port map(d=>SIn(6),clk=>clk,oe=>oe,q=>SOut(6));	
	d07: dflop port map(d=>SIn(7),clk=>clk,oe=>oe,q=>SOut(7));	
	d08: dflop port map(d=>SIn(8),clk=>clk,oe=>oe,q=>SOut(8));	
	d09: dflop port map(d=>SIn(9),clk=>clk,oe=>oe,q=>SOut(9));	
	d10: dflop port map(d=>SIn(10),clk=>clk,oe=>oe,q=>SOut(10));	
	d11: dflop port map(d=>SIn(11),clk=>clk,oe=>oe,q=>SOut(11));	
	d12: dflop port map(d=>SIn(12),clk=>clk,oe=>oe,q=>SOut(12));	
	d13: dflop port map(d=>SIn(13),clk=>clk,oe=>oe,q=>SOut(13));	
	d14: dflop port map(d=>SIn(14),clk=>clk,oe=>oe,q=>SOut(14));	
	d15: dflop port map(d=>SIn(15),clk=>clk,oe=>oe,q=>SOut(15));	
	d16: dflop port map(d=>SIn(16),clk=>clk,oe=>oe,q=>SOut(16));	
	d17: dflop port map(d=>SIn(17),clk=>clk,oe=>oe,q=>SOut(17));	
	d18: dflop port map(d=>SIn(18),clk=>clk,oe=>oe,q=>SOut(18));	
	d19: dflop port map(d=>SIn(19),clk=>clk,oe=>oe,q=>SOut(19));	
	d20: dflop port map(d=>SIn(20),clk=>clk,oe=>oe,q=>SOut(20));	
	d21: dflop port map(d=>SIn(21),clk=>clk,oe=>oe,q=>SOut(21));	
	d22: dflop port map(d=>SIn(22),clk=>clk,oe=>oe,q=>SOut(22));	
	d23: dflop port map(d=>SIn(23),clk=>clk,oe=>oe,q=>SOut(23));	
	d24: dflop port map(d=>SIn(24),clk=>clk,oe=>oe,q=>SOut(24));	
	d25: dflop port map(d=>SIn(25),clk=>clk,oe=>oe,q=>SOut(25));	
	d26: dflop port map(d=>SIn(26),clk=>clk,oe=>oe,q=>SOut(26));	
	d27: dflop port map(d=>SIn(27),clk=>clk,oe=>oe,q=>SOut(27));	
	d28: dflop port map(d=>SIn(28),clk=>clk,oe=>oe,q=>SOut(28));	
	d29: dflop port map(d=>SIn(29),clk=>clk,oe=>oe,q=>SOut(29));	
	d30: dflop port map(d=>SIn(30),clk=>clk,oe=>oe,q=>SOut(30));	
	d31: dflop port map(d=>SIn(31),clk=>clk,oe=>oe,q=>SOut(31));	
	d32: dflop port map(d=>SIn(32),clk=>clk,oe=>oe,q=>SOut(32));	
	d33: dflop port map(d=>SIn(33),clk=>clk,oe=>oe,q=>SOut(33));	
	d34: dflop port map(d=>SIn(34),clk=>clk,oe=>oe,q=>SOut(34));	
	d35: dflop port map(d=>SIn(35),clk=>clk,oe=>oe,q=>SOut(35));	
end;

library ieee;
use ieee.std_logic_1164.all;
package Sreg_pkg is
	component Sreg port(
	SIn:		in std_logic_vector(35 downto 0);
	clk,oe:		in std_logic;
	SOut:		out std_logic_vector(35 downto 0));
	end component;
end;
