-- Parallel I/O chip
-- John E. Lecky
-- 2/23/98

library ieee;
use ieee.std_logic_1164.all;

entity PPI is generic(width: integer := 4);
	port(
	-- clk is positive edge-sensitive, reset assert to one to set MODE
	clk,reset:	in std_logic;

	-- mode is sampled when reset is asserted; 0=OUTPUT, 1=INPUT
	mode:		in std_logic;
	
	-- Read/Write lines to CPU bus
	read,write:	in std_logic;
	
	-- Interrupt CPU
	interrupt:	out std_logic;
	
	-- CPU data bus, I/O data bus
	data,IOdata:	inout std_logic_vector(width-1 downto 0);
	
	-- full (INPUT) is also 'available' (OUTPUT)
	full:		out std_logic;
	
	-- strobe from I/O device means "I got it" (OUTPUT) or "new input" INPUT
	strobe:		in std_logic);
end;

architecture PPI_arch of PPI is
	signal reg: std_logic_vector(width-1 downto 0);
	signal curMode: std_logic; -- remember current mode
	alias available: std_logic is full;  -- makes code more readable
	begin
		
	proc: process begin
		wait until clk = '1';

		-- set mode register when reset
		if (reset = '1') then
			curMode <= mode;
		end if;
		
		-- perform INPUT or OUTPUT based on internal mode register
		if (curMode = '0') then
			-- WRITE (OUTPUT) MODE
			
			-- Write from CPU to PPI
			if (write = '1') then
				reg <= data;	  -- load internal reg from data
				available <= '1'; -- tell I/O it has something
			end if;
			
			-- I/O has received it
			if (strobe = '1') then
				available <= '0';  -- clear avaialable bit
				interrupt <= '1';  -- interrupt CPU
			else
				interrupt <= '0';  -- next clk will clear int
			end if;

			-- comment out 1 line below to simulate INPUT			
			IOdata <= reg;  -- drive register to I/O device
		else
			-- READ (INPUT) MODE
			
			-- CPU reads from PPI
			if (read = '1') then
				-- comment out 1 line below to simulate OUTPUT
				data <= reg;  -- send internal register to CPU data
				full <= '0';  -- signal I/O device buffer empty
			end if;
			
			-- I/O device writing another item
			if (strobe = '1') then
				reg <= IOdata;    -- load internal reg with IOdata
				full <= '1';      -- tell I/O device buffer is full
				interrupt <= '1'; -- signal CPU
			else
				interrupt <= '0'; -- clear int next clk
			end if;
		end if;
	end process;
	
end;