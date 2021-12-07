--
--
-- TOP_SPIM module
--
-- VHDL synthesis and simulation model of MIPS single clock cycle machine
-- as described in chapter 5 of Patterson and Hennessey
-- VHDL Submodules Ifetch,Control,Idecode,Execute and Dmemory
-- become different pipeline stages in chapter 6
--
-- NOTE: Full 32-bit instructions are used. The Data paths were limited
-- to 8 bits to speed synthesis and simulation for student projects.
-- Registers are limited to 8 bits and $R0..$R7 only
-- Program memory limited to locations 0..7 and Data to locations 0..1
--
-- Copyright (c) 1996 J. Hamblen, Georgia Tech, School of ECE, Atlanta, GA
-- Educational Use Rights Granted Provided Copyright Remains in Source Code
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;

entity TOP_SPIM is

port(reset,clock: in std_logic; PC,ALUresult,rr1d_bus,rr2d_bus,
     wrd_bus: out std_logic_vector(7 downto 0);
     Out_Inst: out std_logic_vector(31 downto 0));

end TOP_SPIM;



architecture structure of TOP_SPIM is

   component Ifetch

   port(Instruction: out std_logic_vector(31 downto 0);
        PCadd : out  std_logic_vector(7 downto 0);
        Addresult : in std_logic_vector(7 downto 0);
        Branch : in std_logic;
        clock,reset : in std_logic;
        Zero : in std_logic;
        PCout : out std_logic_vector(7 downto 0));

   end component;

   component Idecode

   port(rr1d_bus : out std_logic_vector(7 downto 0);
        rr2d_bus : out std_logic_vector(7 downto 0);
        Instruction : in std_logic_vector(31 downto 0);
        wrd_bus : in std_logic_vector(7 downto 0);
        RegWrite : in std_logic;
        RegDst : in std_logic;
        Extend : out std_logic_vector(7 downto 0);
        clock,reset: in std_logic);

	end component;



   component control


   port( Op : in std_logic_vector(5 downto 0);
                RegDst : out std_logic;
                ALUSrc : out std_logic;
                MemtoReg : out std_logic;
                RegWrite : out std_logic;
                MemRead : out std_logic;
                MemWrite : out std_logic;
                Branch : out std_logic;
                ALUop0 : out std_logic;
                ALUop1 : out std_logic;
                clock: in std_logic);
	
	 end component;

   component  Execute


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

	end component;

   component dmemory

   port(rd_bus : out std_logic_vector(7 downto 0);
        ra_bus : in std_logic_vector(7 downto 0);
        wd_bus : in std_logic_vector(7 downto 0);
        wadd_bus : in std_logic_vector(7 downto 0);
        MemRead, Memwrite, MemtoReg : in std_logic;
        clock,reset: in std_logic);

   end component;

   signal PCadd :  std_logic_vector(7 downto 0);
   signal rr1d_busl : std_logic_vector(7 downto 0);
   signal rr2d_busl : std_logic_vector(7 downto 0);
   signal Extend : std_logic_vector(7 downto 0);
   signal Addresult : std_logic_vector(7 downto 0);
   signal ALUresultl : std_logic_vector(7 downto 0);
   signal Branch : std_logic;
   signal Zero : std_logic;
   signal wrd_busl : std_logic_vector(7 downto 0);
   signal RegWrite : std_logic;
   signal RegDst :  std_logic;
   signal ALUSrc :  std_logic;
   signal MemtoReg :  std_logic;
   signal MemRead :  std_logic;
   signal MemWrite :  std_logic;
   signal ALUop :  std_logic_vector(1 downto 0);
   signal MIPS_Inst: std_logic_vector(31 downto 0);

begin
   Out_Inst <= MIPS_Inst;
   ALUresult <= ALUresultl;
   rr1d_bus <= rr1d_busl;
   rr2d_bus <= rr2d_busl;
   wrd_bus  <= wrd_busl;
   IFE : Ifetch

   port map (Instruction => MIPS_Inst,
        PCadd => PCadd,
	Addresult => Addresult,
	Branch => Branch,
        clock => clock,  reset => reset,
	Zero => Zero,
	PCout => PC);

   ID : Idecode

   port map (rr1d_bus => rr1d_busl,
        rr2d_bus => rr2d_busl,
        Instruction => MIPS_Inst,
        wrd_bus => wrd_busl,
	RegWrite => RegWrite,
	RegDst => RegDst,
	Extend => Extend,
        clock => clock,  reset => reset);

   CTL:   control

   port map ( Op => MIPS_Inst(31 downto 26),
		RegDst => RegDst,
		ALUSrc => ALUSrc,
		MemtoReg => MemtoReg,
		RegWrite => RegWrite,
		MemRead => MemRead,
		MemWrite => MemWrite,
		Branch => Branch,
		ALUop0 => ALUop(0),
		ALUop1 => ALUop(1),
                clock => clock);

   EXE:  Execute


   port map (Readdata1 => rr1d_busl,
                Readdata2 => rr2d_busl,
		Extend => Extend,
                Func_op => MIPS_Inst(5 downto 0),
		ALUOp0 => ALUop(0),
		ALUOp1 => ALUop(1), 
		ALUSrc => ALUSrc,
		Zero => Zero,
                ALUResult => ALUResultl,
		ADDResult => ADDResult,
		PCadd => PCadd,
                clock => clock);

   MEM:  dmemory

   port map (rd_bus => wrd_busl,
	ra_bus => ALUResultl,
	wd_bus => rr2d_busl,
        wadd_bus => ALUResultl,
	MemRead => MemRead, 
	Memwrite => MemWrite, 
	MemtoReg => MemtoReg,
                clock => clock,  reset => reset);
 
end structure;

