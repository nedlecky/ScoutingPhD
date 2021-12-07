-- Design Problem 3A
-- ROM-based Arbitrary Counter

-- University of Vermont
-- EE 231: Digital Computer Design I Spring 2002
-- Dr. Ned Lecky

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity romcounter is
	port
	(
		clock	: in std_logic;
		q		: out std_logic_vector(3 downto 0)
	);
end romcounter;

architecture arch of romcounter is
	-- Right from the help page
	COMPONENT lpm_rom
	GENERIC (LPM_WIDTH: POSITIVE;
		LPM_TYPE: STRING := "LPM_ROM";
		LPM_WIDTHAD: POSITIVE;
		LPM_NUMWORDS: NATURAL := 0;
		LPM_FILE: STRING;
		LPM_ADDRESS_CONTROL: STRING := "REGISTERED";
		LPM_OUTDATA: STRING := "REGISTERED";
		LPM_HINT: STRING := "UNUSED");
	PORT (address: IN STD_LOGIC_VECTOR(LPM_WIDTHAD-1 DOWNTO 0);
		inclock: IN STD_LOGIC := '0';
		outclock: IN STD_LOGIC := '0';
		memenab: IN STD_LOGIC := '1';
		q: OUT STD_LOGIC_VECTOR(LPM_WIDTH-1 DOWNTO 0));
	END COMPONENT;
	signal	addr : std_logic_vector(3 downto 0);
begin
	-- hookup the rom to a counter
	rom: lpm_rom
		generic map (LPM_WIDTH => 4,
		LPM_WIDTHAD => 4,
		LPM_FILE => "ROM.MIF",
		LPM_ADDRESS_CONTROL => "UNREGISTERED",
		LPM_OUTDATA => "UNREGISTERED")
		port map (address => addr, q => q);

	-- the counter
	process(clock)
	begin
		wait until rising_edge(clock);
		addr <= addr + 1;
	end process;
end arch;


