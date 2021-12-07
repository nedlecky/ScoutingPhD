-- John E. Lecky
-- Candy Dispensing Machine
-- 2/22/98

library ieee;
use ieee.std_logic_1164.all;
use work.std_arith.all;

entity CandyMachine is port(
	masterClk:	in std_logic;	-- assumed very fast WRT machine operation
	reset:		in std_logic;	-- asserted on candy machine powerup only
	
	-- coin receiver control
	gotCoin:	in std_logic;	-- goes high for 1 clock period when coin inserted
	coinType:	in std_logic_vector(1 downto 0);  -- defines coin value
	keep:		out std_logic;	-- assert to direct coin to hopper
	fallThru:	out std_logic;	-- assert to send coin to coin return

	-- customer selection panel control
	gotSelect:	in std_logic;	-- goes high for one clock period AFTER selection
	selection:	in std_logic_vector(3 downto 0); -- selection definition
	
	-- product dispenser control
	goDispense:	buffer std_logic;  -- asserted for one clock period to dispense product
	
	-- coin return button
	gotReturn:	in std_logic;	-- customer coin return button
	
	-- change maker control
	giveQuarter:	buffer std_logic;	-- assert for one clock period to return quarter
	giveNickel:	buffer std_logic;	-- nickel
	giveDime:	buffer std_logic);	-- dime

end;
	
architecture CandyMachine_arch of CandyMachine is
	-- budget width
	-- should be 6 to allow up to dime, dime, quarter (45)
	-- leave at 5 and keep total below 32 to get reasonable simulation speed
	constant w: integer := 5;

	-- product pricing for selections 0 - 15	
	type priceTable is array(0 to 15) of std_logic_vector(4 downto 0);
	constant prices: priceTable := (
		"01111",	-- price for item 0
		"01111",	-- price for item 1
		"01111",	-- price for item 2
		"01111",	-- price for item 3
		"01111",	-- price for item 4
		"10100",	-- price for item 5
		"10100",	-- price for item 6
		"10100",	-- price for item 7
		"10100",	-- price for item 8
		"10100",	-- price for item 9
		"11001",	-- price for item 10
		"11001",	-- price for item 11
		"11001",	-- price for item 12
		"11001",	-- price for item 13
		"11001",	-- price for item 14
		"11001");	-- price for item 15
		
	-- coinType definitions
	constant nickel: std_logic_vector(1 downto 0) := "01";
	constant dime: std_logic_vector(1 downto 0) := "10";
	constant quarter: std_logic_vector(1 downto 0) := "11";
	
	signal budget: std_logic_vector(w-1 downto 0);  -- amount customer has to spend
	signal price: std_logic_vector(w-1 downto 0);	-- price of selected item
	attribute synthesis_off of price: signal is true;  -- helps in debug
	signal makeChange: std_logic; -- set internally to drive change making
	begin

	-- price lookup for current selection
	--price <= '0' & prices(to_integer(selection));  -- when w = 6
	price <= prices(to_integer(selection));  -- when w = 5

	gotCoin: process begin
		wait until masterClk = '1';

		-- syncronous reset
		if (reset='1') then
			budget <= (others => '0');
			keep <= '0';
			fallThru <= '0';
			goDispense <= '0';
			giveQuarter <= '0';
			giveNickel <= '0';
			giveDime <= '0';
		end if;
			
		-- handle incoming coins
		if (gotCoin='1') then
			-- if we already have 25c, just route to the return
			if (budget>=25) then
				fallThru <= '1';
			else
				keep <= '1'; -- route coin to keep bucket
				
				-- keep track of total entered so far in 'budget'
				case coinType is
					when nickel => budget <= budget + 5;
					when dime => budget <= budget + 10;
					when quarter => budget <= budget + 25;
					when others => keep <= '0'; -- reject unknown coin!
				end case;
			end if;
		else
			-- if no coin in, set routing controls back to 0
			fallThru <= '0';
			keep <= '0';
		end if;

		-- handle the Coin Return button
		if (gotReturn='1') then
			-- this just has to set the make change bit
			makeChange <= '1';
		end if;
		
		-- customer has made a selection?
		if(gotSelect='1') then
			-- only allow if the selection is in the budget
			if (budget >= price) then
				-- dispense
				goDispense <= '1';
				
				-- deduct price from budget
				budget <= budget - price;
				
				-- enable change making process
				makeChange <= '1';
			end if;
		else
			-- if no selection, return goDispense to 0
			goDispense<='0';
		end if;

		-- change maker procedure (handles coin return, too)		
		-- if we're dispensing, wait until dispense complete before starting
		--  making change.  This way, if anything goes wrong with dispensing,
		--  we don't make change and keep the rest!
		if (goDispense = '0' and makeChange = '1') then
			-- if we're pulsing a coin return line, just clear it
			if (giveQuarter = '1' or giveDime = '1' or giveNickel = '1') then
				giveQuarter <= '0';
				giveDime    <= '0';
				giveNickel  <= '0';

			-- not already returning; now give back one of the biggest we can
			elsif (budget >= 25) then
				giveQuarter <= '1';
				budget <= budget - 25;
			elsif (budget >= 10) then
				giveDime <= '1';
				budget <= budget - 10;
			elsif (budget >= 5) then
				giveNickel <= '1';
				budget <= budget - 5;
			else
				-- change return complete
				budget <= (others => '0');
				makeChange <= '0';
			end if;
		end if;
		
	end process;
end;
	