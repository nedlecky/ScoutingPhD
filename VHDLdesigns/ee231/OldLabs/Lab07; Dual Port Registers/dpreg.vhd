-- Dual-Port Register File
-- John E. Lecky 2/16/98

library ieee;
use ieee.std_logic_1164.all;
use work.nreg_pkg.all;
use work.std_arith.all;

entity regfile is generic (
	w: integer := 8;	-- register width
	nAddr: integer := 3);	-- number of address bits
	port(
	Ain:		in std_logic_vector(w-1 downto 0);
	Aout,Bout:	out std_logic_vector(w-1 downto 0);
	Asel,Bsel:	in std_logic_vector(nAddr-1 downto 0);
	Wr:		in std_logic;
	clk:		in std_logic);
end;

architecture regfile_arch of regfile is
	constant nregs: integer := 2**nAddr;  -- number of registers
	type ram_array is array (nregs-1 downto 0) of std_logic_vector(w-1 downto 0);
	signal regOutputs: ram_array;
	signal regEn: std_logic_vector(nregs-1 downto 0);
	begin
	
	-- instantiate the registers; use generic outputs and enables
	regs: for i in 0 to nregs-1 generate
		reg: nreg generic map(w)
		port map(d=>Ain,q=>regOutputs(i),en=>regEn(i),clk=>clk);
	end generate;
	
	-- output selects by array lookup
	Aout <= regOutputs(to_integer(Asel));
	Bout <= regOutputs(to_integer(Bsel));

	-- the write process; enable only the selected register	
	write: process (Asel,Wr) begin
		for i in 0 to nregs-1 loop
			if (i = to_integer(Asel)) then
				regEn(i) <= Wr;
			else
				regEn(i) <= '0';
			end if;
		end loop;
	end process;
end;