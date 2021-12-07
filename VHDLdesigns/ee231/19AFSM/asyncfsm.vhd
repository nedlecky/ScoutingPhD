-- Async FSM

-- Dr. John E. Lecky
-- EE231 Digital Computer Design 1
-- University of Vermont

library ieee;
use ieee.std_logic_1164.all;

library lpm;
use lpm.lpm_components.all;

entity asyncfsm is
	port
	(
		reset	: in	std_logic;
		w		: in	std_logic;
		z		: out	std_logic
	);
end asyncfsm;

architecture a of asyncfsm is
	signal y1,y2 : std_logic;
begin
	process(w)
	begin
		-- need a reset to get the simulator oriented!
		if reset='1' then
			y1 <= '0';
			y2 <= '0';
		else
			y2 <= (y1 and not w) or (y2 and w) or (y1 and y2);
			y1 <= (y1 and not w) or (not y2 and w) or (y1 and not y2);
			-- If we modify the state table and have an unstable state...
			--y1 <= (y1 and not w) or (not y1 and not y2 and w);
		end if;
	end process;
	z <= y1;
end a;

