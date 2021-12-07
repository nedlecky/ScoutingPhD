-- Bidirectional Serial I/O chip (SIO)
-- John E. Lecky
-- 2/23/98

library ieee;
use ieee.std_logic_1164.all;
use work.std_arith.all;

entity PPI is generic(width: integer := 8);
	port(
	-- clk is positive edge-sensitive; reset=1 is sync reset
	clk,reset:	in std_logic;

	-- mode is sampled when reset is asserted; 0=OUTPUT, 1=INPUT
	mode:		in std_logic;
	
	-- read/write lines to CPU bus
	read,write:	in std_logic;
	
	-- Interrupt CPU for read available or write complete
	readInt,writeInt:	out std_logic;
	
	-- CPU data bus
	data:		inout std_logic_vector(width-1 downto 0);
	
	-- Serial I/O lines
	sout:		out std_logic;
	sin:		in std_logic);
end;

architecture PPI_arch of PPI is
	-- output register (1 extra bit for start bit)
	signal outreg: std_logic_vector(width downto 0);

	-- serial input register
	signal inreg: std_logic_vector(width-1 downto 0);
	
	-- input and output bit counters
	signal incount,outcount: std_logic_vector(3 downto 0);
	
	-- internal bit registers to track mode
	signal send,receive: std_logic;
	begin
		
	proc: process begin
		wait until clk = '1';

		-- synchronous reset
		if (reset = '1') then
			send <= '0';
			incount <= (others => '0');
			outcount <= (others => '0');
		end if;
		
		-- Write from CPU to SIO (parallel)
		if (send = '0' and write = '1') then
			-- load internal reg and place start bit up top
			outreg <= '1' & data;
			
			-- set output bit count and set send
			send <= '1';
			outcount <= to_std_logic_vector(8,4);
		end if;

		-- Read SIO to CPU (parallel)
		if (read = '1') then
			-- comment out 1 line below for output simulation
			data <= inreg;
		end if;

		-- Detect serial input start bit		
		if (receive = '0' and sin = '1') then
			-- set receive flag and input counter
			receive <= '1';
			incount <= to_std_logic_vector(7,4);
		end if;

		-- serial output handler
		if (send = '1') then
			-- when counter decrements past 0, we're done
			if(outcount = "1111") then
				send <= '0';
				writeInt <= '1';  -- let CPU know complete
				sout <= '0';
			else
				-- send out next bit
				outcount <= outcount - 1;
				sout <= outreg(to_integer(outcount));
			end if;
		else
			-- clears interrupt flag after send complete
			writeInt <= '0';
		end if;

		-- serial input handler
		if (receive = '1') then
			-- if counter has decremented past 0, we're done
			if(incount = "1111") then
				receive <= '0';
				readInt <= '1';  -- let CPU know
			else
				-- shift in the next bit
				incount <= incount - 1;
				inreg <= inreg(width-2 downto 0) & sin;
			end if;
		else
			-- clear interrupt after receive complete
			readInt <= '0';
		end if;
	end process;
	
end;