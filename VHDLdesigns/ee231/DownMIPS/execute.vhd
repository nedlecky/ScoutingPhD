--
--
-- Execute module (simulates SPIM (ALU) Execute module)
--
-- Copyright (c) 1996 J. Hamblen, Georgia Tech, School of ECE, Atlanta, GA
--
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;
entity  Execute is


        port(Readdata1 : in std_logic_vector(7 downto 0);
Readdata2 : in std_logic_vector(7 downto 0);
Extend : in std_logic_vector(7 downto 0);
Func_op : in std_logic_vector(5 downto 0);
ALUOp0 : in std_logic;
ALUOp1 : in std_logic; 
ALUSrc : in std_logic;
Zero : out std_logic;
ALUResult : out std_logic_vector(7 downto 0);
ADDResult : out std_logic_vector(7 downto 0);
PCadd : in std_logic_vector(7 downto 0);
clock: in std_logic);

end Execute;

architecture behavior of Execute is


 
Signal Ainput, Binput : std_logic_vector(7 downto 0);
Signal ResMux: std_logic_vector(7 downto 0);
Signal BAddout : std_logic_vector(8 downto 0);
Signal ALUctl: std_logic_vector(2 downto 0);
	begin
	 Ainput <= Readdata1;
         Binput <= Readdata2 WHEN (ALUSrc='0') ELSE Extend(7 downto 0);
         ALUctl(0) <= (Func_op(0) OR Func_op(3)) AND ALUOp1;
         ALUctl(1) <= (NOT Func_op(2)) OR (NOT ALUOp1);
         ALUctl(2) <= (Func_op(1) AND ALUOp1) OR ALUOp0;
-- Generate Zero Flag
    Zero <= '1' WHEN (ResMux(7 downto 0) = To_stdlogicvector(X"00")) ELSE '0';    
-- Select ALU output        
    ALUresult <= To_stdlogicvector(B"0000000") & Resmux(7) WHEN ALUctl="111" 
    ELSE ResMux(7 downto 0);
-- Adder for Branch Address
        BAddout<=PCadd + (Extend(6 downto 0) & '0' & '0');
        ADDresult <= BAddout(7 downto 0);        

Process (ALUctl,Ainput,Binput)
begin
 case ALUctl(2 downto 0) is
 -- Select ALU operation
 -- ALU performs ALUresult = bus_A AND bus_B
 WHEN "000" => ResMux <= Ainput AND Binput; 
 -- ALU performs ALUresult = bus_A OR bus_B
 WHEN "001" => ResMux <= Ainput OR Binput;
 -- ALU performs ALUresult = bus_A + bus_B
 WHEN "010" => ResMux <= Ainput + Binput;
 -- ALU performs SLT
 WHEN "011" => ResMux <= Ainput - Binput;
 -- ALU performs ?
 WHEN "100" => ResMux <= To_stdlogicvector(B"00000000");
 -- ALU performs ?
 WHEN "101" => ResMux <= To_stdlogicvector(B"00000000");
 -- ALU performs ALUresult = bus_A -bus_B
 WHEN "110" => ResMux <= Ainput - Binput;
 -- ALU performs SLT
 WHEN "111" => ResMux <= To_stdlogicvector(B"00000000");
 WHEN Others => ResMux <= To_stdlogicvector(B"00000000");
 end case;
end process;
end behavior;

