library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity state_mach is
	port(clk, reset		: in	STD_LOGIC;
		Input1, Input2	: in	STD_LOGIC;
		Output1			: out	STD_LOGIC);
end state_mach;
architecture A of state_mach is
	type STATE_TYPE is (state_A, state_B, state_C);
	signal state: STATE_TYPE;
begin
	process (reset, clk)
	begin
		if reset = '1' then
			state <= state_A;
		elsif clk'EVENT and clk = '1' then
			case state is
				when state_A =>
					if Input1 = '0' then
						state <= state_B;
					else
						state <= state_C;
					end if;
				when state_B =>
						state <= state_C;
				when state_C =>
					if Input2 = '1' then
						state <= state_A;
					end if;
			end case;
		end if;
	end process;
	with state select
		Output1 	<=	'0'	when state_A,
						'0'	when state_B,
						'1'	when state_C,
						'0' when others;
end a;

