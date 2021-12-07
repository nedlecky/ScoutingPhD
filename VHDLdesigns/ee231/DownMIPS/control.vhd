--
--
-- control module (simulates SPIM control module)
--
-- Copyright (c) 1996 J. Hamblen, Georgia Tech, School of ECE, Atlanta, GA
--

library IEEE;
use  IEEE.STD_LOGIC_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;
LIBRARY lpm;
USE lpm.lpm_components.ALL;

entity control is


   port( signal Op : in std_logic_vector(5 downto 0);
                signal RegDst : out std_logic;
                signal ALUSrc : out std_logic;
                signal MemtoReg : out std_logic;
                signal RegWrite : out std_logic;
                signal MemRead : out std_logic;
                signal MemWrite : out std_logic;
                signal Branch : out std_logic;
                signal ALUop0 : out std_logic;
                signal ALUop1 : out std_logic;
                signal clock: in std_logic);
		
		
end control;


--
-- SPIM control architecture
--

architecture behavior of control is
   
        Component LCELL
          Port (a_in: in std_logic; 
                a_out: out std_logic);
        End Component;

   signal  Rformat, Lw, Sw, Beq : std_logic;
   signal  Op_out: std_logic_vector(5 Downto 0);


begin           -- behavior of SPIM control
------------------------------------------------------------------------------
-- Patch to isolate logic and help in logic synthesis step
Op_Buf0: LCELL
         Port map (a_in => Op(0), a_out => Op_out(0));
Op_Buf1: LCELL
         Port map (a_in => Op(1), a_out => Op_out(1));
Op_Buf2: LCELL
         Port map (a_in => Op(2), a_out => Op_out(2));
Op_Buf3: LCELL
         Port map (a_in => Op(3), a_out => Op_out(3));
Op_Buf4: LCELL
         Port map (a_in => Op(4), a_out => Op_out(4));
Op_Buf5: LCELL
         Port map (a_in => Op(5), a_out => Op_out(5));
-- Normal Code
                Rformat <= '1' When Op_out = "000000" Else '0';


                Lw      <= '1' When Op_out = "100011" Else '0';

                Sw      <= '1' When Op_out = "101011" Else '0';

                Beq     <= '1' When Op_out = "000100" Else '0';
   
                RegDst <=  Rformat;
                ALUSrc <=  Lw or Sw;
                MemtoReg <=  Lw;
                RegWrite <=  Rformat or Lw;
                MemRead <=  Lw;
                MemWrite <=  Sw; 
                Branch <=  Beq;
                ALUOp1 <=  Rformat;
                ALUOp0 <=  Beq; 
end behavior;

