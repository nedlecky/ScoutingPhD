-- Hardlogic implementation of vector summer
-- University of Vermont
-- EE 231  Dr. Ned Lecky

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;

entity hardlogic is
port(
	clock, start 	: in std_logic;
	data_in 		: in std_logic_vector(15 downto 0);
	addr 			: out std_logic_vector(7 downto 0);
	done			: out std_logic;
	sum				: out std_logic_vector(15 downto 0)
);
end hardlogic;

architecture arch of hardlogic is
	type state_type is (reset,waiting,summing,complete);
	signal state	: state_type;
	signal AC		: std_logic_vector(15 downto 0);
	signal MAR		: std_logic_vector(7 downto 0);
	signal COUNT	: std_logic_vector(15 downto 0);
begin
	addr <= MAR;

	process (clock)
	begin
		if rising_edge(clock) then
			case state is
				when reset =>
					AC <= (others => '0');
					COUNT <= (others => '0');
					MAR <= (others => '0');
					done <= '0';
					state <= waiting;
				when waiting =>
					if start='1' then
						COUNT <= data_in;
						MAR <= MAR + 1;
						done <= '0';
						state <= summing;
					end if;
				when summing =>
					AC <= AC + data_in;
					if COUNT=x"0000" then
						state <= complete;
					else
						MAR <= MAR + 1;
						COUNT <= COUNT - 1;
					end if;
				when complete =>
					sum <= AC;
					AC <= (others => '0');
					done <= '1';
					MAR <= (others => '0');
					state <= waiting;
				when others =>
					state <= reset;
			end case;
		end if;
	end process;
end arch;
