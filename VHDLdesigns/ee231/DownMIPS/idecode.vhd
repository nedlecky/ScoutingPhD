--
--
--  Idecode module (provides the register file for the SPIM computer)
--
-- Copyright (c) 1996 J. Hamblen, Georgia Tech, School of ECE, Atlanta, GA
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;

entity Idecode is

        port(rr1d_bus : out std_logic_vector(7 downto 0);
        rr2d_bus : out std_logic_vector(7 downto 0);
        Instruction : in std_logic_vector(31 downto 0);
        wrd_bus : in std_logic_vector(7 downto 0);
        RegWrite : in std_logic;
        RegDst : in std_logic;
        Extend : out std_logic_vector(7 downto 0);
                clock,reset: in std_logic);

end Idecode;

--
-- Idecode architecture
--

architecture behavior of Idecode is

signal wraddress : std_logic_vector(4 downto 0);
signal reg1,reg2,reg3,reg4: std_logic_vector(7 downto 0);
signal reg5,reg6,reg7: std_logic_vector(7 downto 0);
signal ireg1,ireg2,ireg3,ireg4: std_logic_vector(7 downto 0);
signal ireg5,ireg6,ireg7: std_logic_vector(7 downto 0);
signal mrr1d_bus,mrr2d_bus: std_logic_vector(7 downto 0);
signal muxreg1,muxreg2,muxreg3,muxreg4: std_logic_vector(7 downto 0);
signal muxreg5,muxreg6,muxreg7: std_logic_vector(7 downto 0);
signal reg1wr,reg2wr,reg3wr,reg4wr: std_logic;
signal reg5wr,reg6wr,reg7wr: std_logic;
signal rr1add_bus,rr2add_bus,wra_bus,wra2_bus: std_logic_vector(4 downto 0);
signal Ivalue: std_logic_vector(15 downto 0);

begin
   rr1add_bus <= Instruction(25 downto 21);
   rr2add_bus <= Instruction(20 downto 16);
   wra_bus <=  Instruction(15 downto 11);
   wra2_bus <=  Instruction(20 downto 16);
   Ivalue <= Instruction(15 downto 0);

-- Read Register Operations
                WITH rr1add_bus(2 downto 0) SELECT
                mrr1d_bus <= To_stdlogicvector(X"00")  WHEN "000", 
		reg1 WHEN "001",
		reg2 WHEN "010",
		reg3 WHEN "011",
                reg4 WHEN "100",
                reg5 WHEN "101",
                reg6 WHEN "110",
                reg7 WHEN "111",
                To_stdlogicvector(X"FF") WHen others;
 
		 
                WITH rr2add_bus(2 downto 0) SELECT
                mrr2d_bus <= To_stdlogicvector(X"00")  WHEN "000", 
		reg1 WHEN "001",
		reg2 WHEN "010",
		reg3 WHEN "011",
                reg4 WHEN "100",
                reg5 WHEN "101",
                reg6 WHEN "110",
                reg7 WHEN "111",
                To_stdlogicvector(X"FF") WHen others;
		
    rr1d_bus <= mrr1d_bus;
    rr2d_bus <= mrr2d_bus;
-- Mux for Register Write Address
    wraddress <= wra_bus WHEN RegDst='1'     -- write address mux
                 ELSE wra2_bus;
-- Note: Initial values in registers set to register number during reset 
-- to provide simple test data for MIPS programs
 ireg1 <= To_stdlogicvector(X"01");
 ireg2 <= To_stdlogicvector(X"02");
 ireg3 <= To_stdlogicvector(X"03");
 ireg4 <= To_stdlogicvector(X"04");
 ireg5 <= To_stdlogicvector(X"05");
 ireg6 <= To_stdlogicvector(X"06");
 ireg7 <= To_stdlogicvector(X"07");
--  Use D FFs with enable (D input mux) to elminate hazards on clock line
--  muxregx is D input mux for register, regxwr is enable line for register
 muxreg1 <=reg1 WHEN reg1wr='0' ELSE wrd_bus;
 reg1wr <= '1' WHEN ((wraddress="00001") AND (RegWrite='1')) ELSE '0';
 muxreg2 <=reg2 WHEN reg2wr='0' ELSE wrd_bus;
 reg2wr <= '1' WHEN ((wraddress="00010") AND (RegWrite='1')) ELSE '0';
 muxreg3 <=reg3 WHEN reg3wr='0' ELSE wrd_bus;
 reg3wr <= '1' WHEN ((wraddress="00011") AND (RegWrite='1')) ELSE '0';
 muxreg4 <=reg4 WHEN reg4wr='0' ELSE wrd_bus;
 reg4wr <= '1' WHEN ((wraddress="00100") AND (RegWrite='1')) ELSE '0';
 muxreg5 <=reg5 WHEN reg5wr='0' ELSE wrd_bus;
 reg5wr <= '1' WHEN ((wraddress="00101") AND (RegWrite='1')) ELSE '0';
 muxreg6 <=reg6 WHEN reg6wr='0' ELSE wrd_bus;
 reg6wr <= '1' WHEN ((wraddress="00110") AND (RegWrite='1')) ELSE '0';
 muxreg7 <=reg7 WHEN reg7wr='0' ELSE wrd_bus;
 reg7wr <= '1' WHEN ((wraddress="00111") AND (RegWrite='1')) ELSE '0';
-- Sign Extend Unit  (NOTE: not needed for 8-bit only data path model)
--        Extend(15 downto 0) <= Ivalue;  -- Sign Extend 16 to 32 bits
--        Extend(31 downto 16) <= To_stdlogicvector(X"FFFF")
--        WHEN Ivalue(15)='1'ELSE To_stdlogicvector(X"0000");
                  Extend <= Ivalue(7 downto 0);
Process
 Begin
  wait until clock'event and clock='1';
  if reset='1' then
-- Initial register values on reset are reg=reg#
   reg1<=ireg1;
   reg2<=ireg2;
   reg3<=ireg3;
   reg4<=ireg4;
   reg5<=ireg5;
   reg6<=ireg6;
   reg7<=ireg7;
  else
-- Register loaded during write back?
   reg1<=muxreg1;
   reg2<=muxreg2;
   reg3<=muxreg3;
   reg4<=muxreg4;
   reg5<=muxreg5;
   reg6<=muxreg6;
   reg7<=muxreg7;
  end if;
 end process;
end behavior;

