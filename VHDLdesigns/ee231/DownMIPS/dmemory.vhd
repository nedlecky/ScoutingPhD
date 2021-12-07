--
--
-- DMEMORY module (provides the data memory for the SPIM computer)
-- Only 2 locations implemented - Addresses 0 and 1 are read/write
-- Locations set to initial values, imemx, on reset
--
--
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;

entity dmemory is

 
   port(rd_bus : out std_logic_vector(7 downto 0);
        ra_bus : in std_logic_vector(7 downto 0);
        wd_bus : in std_logic_vector(7 downto 0);
        wadd_bus : in std_logic_vector(7 downto 0);
        MemRead, Memwrite, MemtoReg : in std_logic;
                clock,reset: in std_logic);

end dmemory;

--
-- DMEMORY architecture
--

architecture behavior of dmemory is
	  
  signal mem0,mem1 : std_logic_vector(7 downto 0);
  signal muxout,muxmem0,muxmem1,imem0,imem1 : std_logic_vector(7 downto 0);
  signal mem0write, mem1write : std_logic;
  signal address : std_logic_vector(2 downto 0);


begin

-- Read Data Memory
address <= ra_bus(2 downto 0);
muxout <= mem0 WHEN address=TO_STDLOGICVECTOR(B"000") ELSE
          mem1 WHEN address=TO_STDLOGICVECTOR(B"001") ELSE 
          To_stdlogicvector(X"FF");


-- Mux to skip data memory for Rformat instructions
rd_bus <= ra_bus(7 downto 0) WHEN (MemtoReg='0') ELSE muxout WHEN (MemRead='1')
                ELSE CONV_STD_LOGIC_VECTOR(255,8);

-- Write to data memory?
mem0write <= '1' When ((Memwrite='1') AND(wadd_bus(2 downto 0)="000"))
              ELSE '0';
mem1write <= '1' When ((Memwrite='1') AND (wadd_bus(2 downto 0)="001"))
              ELSE '0';
imem0 <= To_stdlogicvector(X"55");
imem1 <= To_stdlogicvector(X"AA");
muxmem0 <= wd_bus WHEN mem0write='1' ELSE mem0;
muxmem1 <= wd_bus WHEN mem1write='1' ELSE mem1;

Process
 Begin   
 Wait until clock'event and clock='1';
   if (reset = '1') then
     mem0 <= imem0;
     mem1 <= imem1;
   else
     mem0 <= muxmem0;
     mem1 <= muxmem1;
   end if;
 end process;
end behavior;

