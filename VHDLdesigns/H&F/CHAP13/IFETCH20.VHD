--
--
-- Ifetch module (provides the PC and instruction memory for the SPIM computer)
--
-- Copyright (c) 1996 J. Hamblen, Georgia Tech, School of ECE, Atlanta, GA
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity Ifetch20 is

        port(	signal Instruction : out std_logic_vector(31 downto 0);
        		signal PC_plus_4_out : out  std_logic_vector(7 downto 0);
        		signal Add_result : in std_logic_vector(7 downto 0);
        		signal Branch : in std_logic;
        		signal Zero : in std_logic;
        		signal PC_out : out std_logic_vector(7 downto 0);
        		signal clock, reset : in std_logic);

end Ifetch20;

--
-- Ifetch architecture
--
architecture behavior of Ifetch20 is
          signal PC, PC_plus_4 : std_logic_vector(7 downto 0);
          signal next_PC : std_logic_vector(7 downto 0);

-- Simulated ROM for Instruction Memory
-- Insert new MIPS Machine Language Test Programs Here
          constant mem0 : std_logic_vector(31 downto 0) := (
--          Field    | op | rs | rt | rd ?addr/immed|
					"10001100000000100000000000000000"); -- lw $2,0
          constant mem1 : std_logic_vector(31 downto 0) := (
					"10001100000000110000000000000001"); -- lw $3,1
          constant mem2 : std_logic_vector(31 downto 0) := (
					"00000000010000110000100000100000"); -- add $1,$2,$3
          constant mem3 : std_logic_vector(31 downto 0) := (
					"10101100000000010000000000000011"); -- sw $1,3
          constant mem4 : std_logic_vector(31 downto 0) := (
					"00010000001000101111111111111111"); -- beq $1,$2,-4
          constant mem5 : std_logic_vector(31 downto 0) := (
					"00010000001000011111111111111010"); -- beq $1,$1,-24
          constant mem6 : std_logic_vector(31 downto 0) := (
					"00000000000000000000000000000000"); -- nop                                   
          constant mem7 : std_logic_vector(31 downto 0) := (
					"00000000000000000000000000000000"); -- nop                                  
  

	begin
-- copy output signals also read inside module
		PC_out <= PC;
		PC_plus_4_out <= PC_plus_4;

-- Adder to increment PC by 4        
      	PC_plus_4(7 downto 2) <= PC(7 downto 2) + 1;
       	PC_plus_4(1 downto 0)<= "00";

-- Mux to select Branch Address or PC + 4        
		next_PC <= Add_result WHEN ((Branch='1') AND (Zero='1')) 
			ELSE PC_plus_4(7 downto 0);

-- Store PC in register and load next PC on clock edge
        PROCESS
        Begin
        Wait Until (clock'event) and (clock='1');
          If reset='1' then
          	PC <= "00000000"; 
		  else 
			PC <= next_PC;
          end if;
        end process;

-- Address decoder and mux for instruction memory     
-- Fetch next instruction from memory using PC
          Process (PC)
          begin
          	case PC(4 downto 2) is          
          		WHEN "000" => instruction <= mem0;
          		WHEN "001" => instruction <= mem1;
          		WHEN "010" => instruction <= mem2;
           		WHEN "011" => instruction <= mem3;
          		WHEN "100" => instruction <= mem4;
          		WHEN "101" => instruction <= mem5;
           		WHEN "110" => instruction <= mem6;
          		when "111" => instruction <= mem7;
           		When others => instruction <= "00000000";
          	end case;
          end process;

end behavior;

