-- A Burst Memory Controller
-- Ned Lecky 2/13/98

library ieee;
use ieee.std_logic_1164.all;

entity BurstMemoryController is port(
	Bus_Id:		in std_logic_vector(7 downto 0);
	Reset:		in std_logic;
	Read_Write:	in std_logic;
	Xrdy:		in std_logic;
	Burst:		in std_logic;
	Clk:		in std_logic;
	OE:		out std_logic;
	WE:		out std_logic;
	Addr:		out std_logic_vector(1 downto 0));
end;

architecture BurstMemoryController_arch of BurstMemoryController is
	type state is (Idle,Decision,Write,Read1,Read2,Read3,Read4);
	signal PresentState,NextState: state;
	alias Ready: std_logic is Xrdy;  -- handles inconsistent notation from text
	begin
	
	-- 1st process handles state transition and outputs
	p1: process (PresentState,NextState,Ready,Burst,Bus_Id,Read_Write) begin
	-- By default, go nowhere
	NextState <= PresentState;
	
	-- handle next state; we only move if Ready='1', unless we're in Decision
	if (Ready='1' or PresentState=Decision) then
		-- By default, output nothing
		oe<='0'; we<='0'; Addr<="00";
		
		case PresentState is
		when Idle =>
			if (Bus_Id="10101010") then  -- arbtrary "unit ID"
				NextState <= Decision;
			end if;
		when Decision =>
			if (Read_Write='1') then
				NextState <= Read1;
			else
				NextState <= Write;
			end if;
		when Write =>
			we<='1';
			NextState <= Idle;
		when Read1 =>
			oe<='1';
			if (Burst='1') then
				NextState <= Read2;
			else
				NextState <= Idle;
			end if;
		when Read2 =>
			oe<='1'; Addr<="01";
			NextState <= Read3;
		when Read3 =>
			oe<='1'; Addr<="10";
			NextState <= Read4;
		when Read4 =>
			oe<='1'; Addr<="11";
			NextState <= Idle;
		when others =>
		end case;
	end if;
	end process;

	-- Standard leading-edge-triggered 2nd process with synchronous reset	
	p2: process (Clk)begin
		if (Clk'event and Clk='1') then
			if (Reset='1') then
				PresentState <= Idle;
			else
				PresentState <= NextState;
			end if;
		end if;
	end process;
end;
	
	
	