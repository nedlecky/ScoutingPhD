-- QuadAdd from Truth Table

LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
PACKAGE addpack IS
	COMPONENT add_tt
		PORT
		(
			a,b,cin		: IN	STD_LOGIC;
			co,s		: OUT	STD_LOGIC
		);
	END COMPONENT;
END addpack ;

LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.addpack.all;
ENTITY quadadd_single_tt IS
	PORT
	(
		a,b		: IN	STD_LOGIC_VECTOR(3 downto 0);
		cin		: IN	STD_LOGIC;
		s		: OUT	STD_LOGIC_VECTOR(3 downto 0);
		co		: OUT	STD_LOGIC
	);
	
END quadadd_single_tt ;

ARCHITECTURE a OF quadadd_single_tt IS
	SIGNAL csig : std_logic_vector(2 downto 0);
BEGIN
add0: add_tt PORT MAP (a(0),b(0),cin,csig(0),s(0));
add1: add_tt PORT MAP (a(1),b(1),csig(0),csig(1),s(1));
add2: add_tt PORT MAP (a(2),b(2),csig(1),csig(2),s(2));
add3: add_tt PORT MAP (a(3),b(3),csig(2),co,s(3));
END a;

