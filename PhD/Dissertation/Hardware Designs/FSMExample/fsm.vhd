library ieee;
use ieee.std_logic_1164.all;

entity ttf_fsm is port(
	clk, rst:	in bit;
	id:		in bit;
	y:		out bit);
end ttf_fsm;

use work.table_bv.all;
architecture archttf_fsm of ttf_fsm is
	signal table_out: bit_vector(0 to 4);
	signal state: bit_vector(0 to 3);
constant state1:	x01_vector(0 to 3) := "0001";
constant state2: 	x01_vector(0 to 3) := "0010";
constant state3: 	x01_vector(0 to 3) := "0011";
constant state4: 	x01_vector(0 to 3) := "0100";
constant state5: 	x01_vector(0 to 3) := "0101";
constant state6: 	x01_vector(0 to 3) := "0110";
constant state7: 	x01_vector(0 to 3) := "0111";
constant state8: 	x01_vector(0 to 3) := "1000";
constant state9: 	x01_vector(0 to 3) := "1001";
constant state10: 	x01_vector(0 to 3) := "1010";
constant state11: 	x01_vector(0 to 3) := "1011";
constant state12: 	x01_vector(0 to 3) := "1100";

constant table: x01_table(0 to 23, 0 to 9) := (
--	present state  inputs  nextstate  output
--	-------------  ------  ---------  ------
	    state1    &  "0"  &  state2  &  "0",
	    state1    &  "1"  &  state3  &  "0",	    
	    state2    &  "0"  &  state4  &  "0",
	    state2    &  "1"  &  state5  &  "0",	    
	    state3    &  "0"  &  state6  &  "0",
	    state3    &  "1"  &  state7  &  "0",	    
	    state4    &  "0"  &  state8  &  "0",
	    state4    &  "1"  &  state9  &  "0",	    
	    state5    &  "0"  &  state10 &  "0",
	    state5    &  "1"  &  state11 &  "0",	    
	    state6    &  "0"  &  state4  &  "0",
	    state6    &  "1"  &  state12 &  "0",	    
	    state7    &  "0"  &  state10 &  "0",
	    state7    &  "1"  &  state12 &  "0",	    
	    state8    &  "0"  &  state8  &  "0",
	    state8    &  "1"  &  state1  &  "0",	    
	    state9    &  "0"  &  state10 &  "1",
	    state9    &  "1"  &  state1  &  "0",	    
	    state10   &  "0"  &  state4  &  "0",
	    state10   &  "1"  &  state1  &  "0",	    
	    state11   &  "0"  &  state2  &  "0",
	    state11   &  "1"  &  state1  &  "0",	    
	    state12   &  "0"  &  state2  &  "0",
	    state12   &  "1"  &  state1  &  "0");	    

begin
machine: process (clk, rst) 
	begin
		if rst ='1' then 
			table_out <= "00000";
		elsif (clk'event and clk='1') then
			table_out <= ttf(table,state & id);
		end if;
	end process;
state <= table_out(0 to 3);

--assign state outputs;
y <= table_out(4);
end archttf_fsm;
