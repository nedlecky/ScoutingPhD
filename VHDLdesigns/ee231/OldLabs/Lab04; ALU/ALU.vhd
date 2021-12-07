-- An N-bit Simple ALU
-- Ned Lecky 2/1/98
library ieee;
use ieee.std_logic_1164.all;
use work.std_arith.all;

entity nALU is
	generic( width: integer := 4);
	port(
	A,B:	in std_logic_vector(width-1 downto 0);
	sel:	in std_logic_vector(3 downto 0);
	Cin:	in std_logic;
	C:	out std_logic_vector(width-1 downto 0);
	Cout,Z:	out std_logic);
end;

architecture nALU_arch of nALU is
	-- ALU select constants
	constant ALU_ADD:     std_logic_vector(3 downto 0) := "0000";
	constant ALU_SUB:     std_logic_vector(3 downto 0) := "0001";
	constant ALU_INC:     std_logic_vector(3 downto 0) := "0010";
	constant ALU_DEC:     std_logic_vector(3 downto 0) := "0011";
	constant ALU_COMPARE: std_logic_vector(3 downto 0) := "0100";
	constant ALU_AND:     std_logic_vector(3 downto 0) := "0101";
	constant ALU_OR:      std_logic_vector(3 downto 0) := "0110";
	constant ALU_ROR:     std_logic_vector(3 downto 0) := "0111";
	constant ALU_ASL:     std_logic_vector(3 downto 0) := "1000";
	constant ALU_ASR:     std_logic_vector(3 downto 0) := "1001";
	signal Awide,Bwide,Cwide: std_logic_vector(width+1 downto 0);
	alias Ccenter: std_logic_vector(width-1 downto 0) is Cwide(width downto 1);
	begin
	process (A,Awide,B,Bwide,Cwide,Ccenter,Cin,sel)
	begin
		-- default outputs for Z and Cout are 0
		Cout <= '0';
		Z <= '0';
		case sel is
			when ALU_ADD =>
				-- trick so that '+' handles Cin and Cout
				Awide <= '0' & A & Cin;
				Bwide <= '0' & B & Cin;
				Cwide <= Awide + Bwide;
				Cout <= Cwide(width+1);
				if(Ccenter=0) then Z <= '1'; end if;
			when ALU_SUB =>
				Awide <= '0' & A & Cin;
				Bwide <= '0' & B & Cin;
				Cwide <= Awide - Bwide;
				Cout <= Cwide(width+1);
				if(Ccenter=0) then Z <= '1'; end if;
			when ALU_INC =>
				Awide <= '0' & A & '0';
				Cwide <= Awide + 2;  -- add 2 since we've got a dummy LSB
				Cout <= Cwide(width+1);
				if(Ccenter=0) then Z <= '1'; end if;
			when ALU_DEC =>
				Awide <= '0' & A & '0';
				Cwide <= Awide - 2;
				Cout <= Cwide(width+1);
				if(Ccenter=0) then Z <= '1'; end if;
			when ALU_COMPARE =>
				if(A=B) then
					Z <= '1';
				else
					Z <= '0';
				end if;
				Ccenter <= A;
			when ALU_AND =>
				Ccenter <= A and B;
				if(Ccenter=0) then Z <= '1'; end if;
			when ALU_OR =>
				Ccenter <= A or B;
				if(Ccenter=0) then Z <= '1'; end if;
			when ALU_ROR =>
				Ccenter <= A ror 1;
				if(Ccenter=0) then Z <= '1'; end if;
			when ALU_ASL =>
				-- manual ASL, ASR since none defined in std_arith
				Ccenter <= A(A'high) & A(A'high-2 downto 0) & '0';
				if(Ccenter=0) then Z <= '1'; end if;
			when ALU_ASR =>
				Ccenter <= A(A'high) & A(A'high downto 1);
				if(Ccenter=0) then Z <= '1'; end if;
			when others =>
				Cwide <= Awide;
		end case;
		-- pick up center bits of C as the output
		C <= Ccenter;
	end process;
end;
 
library ieee;
use ieee.std_logic_1164.all;
package nALU_pkg is
	constant ALU_ADD:     std_logic_vector(3 downto 0) := "0000";
	constant ALU_SUB:     std_logic_vector(3 downto 0) := "0001";
	constant ALU_INC:     std_logic_vector(3 downto 0) := "0010";
	constant ALU_DEC:     std_logic_vector(3 downto 0) := "0011";
	constant ALU_COMPARE: std_logic_vector(3 downto 0) := "0100";
	constant ALU_AND:     std_logic_vector(3 downto 0) := "0101";
	constant ALU_OR:      std_logic_vector(3 downto 0) := "0110";
	constant ALU_ROR:     std_logic_vector(3 downto 0) := "0111";
	constant ALU_ASL:     std_logic_vector(3 downto 0) := "1000";
	constant ALU_ASR:     std_logic_vector(3 downto 0) := "1001";
	component nALU generic( width: integer := 4);
	port(
	A,B:	in std_logic_vector(width-1 downto 0);
	sel:	in std_logic_vector(3 downto 0);
	Cin:	in std_logic;
	C:	out std_logic_vector(width-1 downto 0);
	Cout,Z:	out std_logic);
	end component;
end;
 