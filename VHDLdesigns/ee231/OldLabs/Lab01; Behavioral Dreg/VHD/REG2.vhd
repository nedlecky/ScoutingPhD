
--  CYPRESS NOVA XVL Structural Architecture

--  JED2VHD Reverse Assembler - 4 IR x77


--    ViewLogic HDL File: REG2.vhd

--    Date: Tue Jan 20 16:25:58 1998

--  Disassembly from Jedec file for: c344

--  Device Ordercode is: CY7C344-20HC/HI
library primitive;
use primitive.c34xp.all;

ENTITY REG2 IS
     PORT(
	clk	: in  vlbit ;
	en	: in  vlbit ;
	q1	: inout vlbit ;
	q0	: inout vlbit ;
	jed_node5	: in vlbit ;
	jed_node6	: in vlbit ;
	jed_node7	: in vlbit ;
	jed_node8	: in vlbit ;
	jed_node9	: in vlbit ;
	jed_node10	: in vlbit ;
	jed_node11	: in vlbit ;
	jed_node12	: in vlbit ;
	d1	: in  vlbit ;
	d0	: in  vlbit ;
	jed_node15	: in vlbit ;
	jed_node16	: in vlbit ;
	jed_node17	: in vlbit ;
	jed_node18	: in vlbit ;
	jed_node19	: in vlbit ;
	jed_node20	: in vlbit ;
	jed_node21	: in vlbit ;
	jed_node22	: in vlbit ;
	jed_node23	: in vlbit ;
	jed_node24	: in vlbit ;
	jed_node25	: in vlbit ;
	jed_node26	: in vlbit ;
	jed_node27	: in vlbit ;
	jed_node28	: in vlbit
     );
END REG2;

ARCHITECTURE DSMB of REG2 is

SIGNAL  one:vlbit:='1';
SIGNAL  zero:vlbit:='0';
SIGNAL  jed_oept_1:vlbit:='0';
SIGNAL  jed_fb_1:vlbit:='0';
--Attribute PIN_NUMBERS of clk:SIGNAL is "   8";

SIGNAL  jed_oept_2:vlbit:='0';
SIGNAL  jed_fb_2:vlbit:='0';
--Attribute PIN_NUMBERS of en:SIGNAL is "   9";

SIGNAL  jed_oept_3:vlbit:='0';
SIGNAL  jed_xsum_3,jed_sum_3,jed_clkpt_3,jed_respt_3,jed_setpt_3,jed_yfb_3,jed_qfb_3,jed_fb_3:vlbit:='0';
--Attribute PIN_NUMBERS of q1:SIGNAL is "  10";

SIGNAL  jed_oept_4:vlbit:='0';
SIGNAL  jed_xsum_4,jed_sum_4,jed_clkpt_4,jed_respt_4,jed_setpt_4,jed_yfb_4,jed_qfb_4,jed_fb_4:vlbit:='0';
--Attribute PIN_NUMBERS of q0:SIGNAL is "  11";

SIGNAL  jed_oept_13:vlbit:='0';
SIGNAL  jed_fb_13:vlbit:='0';
--Attribute PIN_NUMBERS of d1:SIGNAL is "  20";

SIGNAL  jed_oept_14:vlbit:='0';
SIGNAL  jed_fb_14:vlbit:='0';
--Attribute PIN_NUMBERS of d0:SIGNAL is "  21";

SIGNAL  jed_oept_109:vlbit:='0';
SIGNAL  jed_node109,jed_invprodpt_109:vlbit:='0';
SIGNAL  jed_sum_109,jed_oe_109,jed_fb_109:vlbit:='0';

BEGIN
INP_CELL_1:c34xin
generic map(
   	5 ns,  --tin
	10 ns, --texp
	0  ns, --tpia
	7  ns, --tlac
	9  ns, --tlad
	8  ns, --tic
	2  ns, --tics
	6  ns, --tclr
	6  ns, --tpre
	5  ns, --trsu
	9  ns, --trh
	1  ns, --tcomb
	1  ns, --tlatch
	1  ns, --trd
	5  ns, --tio
	5  ns, --tod
	8  ns, --txz
	8  ns, --tzx
	1  ns, --tfd
	5  ns, --tpcw
	5  ns, --tpcr
	7  ns, --tch
	7  ns  --tcl
)
port map(
     x=>clk,
     fb=>jed_fb_1
   );

INP_CELL_2:c34xin
generic map(
   	5 ns,  --tin
	10 ns, --texp
	0  ns, --tpia
	7  ns, --tlac
	9  ns, --tlad
	8  ns, --tic
	2  ns, --tics
	6  ns, --tclr
	6  ns, --tpre
	5  ns, --trsu
	9  ns, --trh
	1  ns, --tcomb
	1  ns, --tlatch
	1  ns, --trd
	5  ns, --tio
	5  ns, --tod
	8  ns, --txz
	8  ns, --tzx
	1  ns, --tfd
	5  ns, --tpcw
	5  ns, --tpcr
	7  ns, --tch
	7  ns  --tcl
)
port map(
     x=>en,
     fb=>jed_fb_2
   );

MCELL_3:c34xm
generic map(
   	5 ns,  --tin
	10 ns, --texp
	0  ns, --tpia
	7  ns, --tlac
	9  ns, --tlad
	8  ns, --tic
	2  ns, --tics
	6  ns, --tclr
	6  ns, --tpre
	5  ns, --trsu
	9  ns, --trh
	1  ns, --tcomb
	1  ns, --tlatch
	1  ns, --trd
	5  ns, --tio
	5  ns, --tod
	8  ns, --txz
	8  ns, --tzx
	1  ns, --tfd
	5  ns, --tpcw
	5  ns, --tpcr
	7  ns, --tch
	7  ns  --tcl
)
port map(
     x1=>jed_xsum_3,
     x2=>jed_sum_3,
     as=>jed_setpt_3,
     ar=>jed_respt_3,
     clkpt=>jed_clkpt_3,
     clksel=>one,
     clklab=>jed_fb_109,
     oe=>jed_oept_3,
     y=>q1,
     qfb=>jed_qfb_3,
     yfb=>jed_yfb_3
   );

MCELL_4:c34xm
generic map(
   	5 ns,  --tin
	10 ns, --texp
	0  ns, --tpia
	7  ns, --tlac
	9  ns, --tlad
	8  ns, --tic
	2  ns, --tics
	6  ns, --tclr
	6  ns, --tpre
	5  ns, --trsu
	9  ns, --trh
	1  ns, --tcomb
	1  ns, --tlatch
	1  ns, --trd
	5  ns, --tio
	5  ns, --tod
	8  ns, --txz
	8  ns, --tzx
	1  ns, --tfd
	5  ns, --tpcw
	5  ns, --tpcr
	7  ns, --tch
	7  ns  --tcl
)
port map(
     x1=>jed_xsum_4,
     x2=>jed_sum_4,
     as=>jed_setpt_4,
     ar=>jed_respt_4,
     clkpt=>jed_clkpt_4,
     clksel=>one,
     clklab=>jed_fb_109,
     oe=>jed_oept_4,
     y=>q0,
     qfb=>jed_qfb_4,
     yfb=>jed_yfb_4
   );

INP_CELL_13:c34xin
generic map(
   	5 ns,  --tin
	10 ns, --texp
	0  ns, --tpia
	7  ns, --tlac
	9  ns, --tlad
	8  ns, --tic
	2  ns, --tics
	6  ns, --tclr
	6  ns, --tpre
	5  ns, --trsu
	9  ns, --trh
	1  ns, --tcomb
	1  ns, --tlatch
	1  ns, --trd
	5  ns, --tio
	5  ns, --tod
	8  ns, --txz
	8  ns, --tzx
	1  ns, --tfd
	5  ns, --tpcw
	5  ns, --tpcr
	7  ns, --tch
	7  ns  --tcl
)
port map(
     x=>d1,
     fb=>jed_fb_13
   );

INP_CELL_14:c34xin
generic map(
   	5 ns,  --tin
	10 ns, --texp
	0  ns, --tpia
	7  ns, --tlac
	9  ns, --tlad
	8  ns, --tic
	2  ns, --tics
	6  ns, --tclr
	6  ns, --tpre
	5  ns, --trsu
	9  ns, --trh
	1  ns, --tcomb
	1  ns, --tlatch
	1  ns, --trd
	5  ns, --tio
	5  ns, --tod
	8  ns, --txz
	8  ns, --tzx
	1  ns, --tfd
	5  ns, --tpcw
	5  ns, --tpcr
	7  ns, --tch
	7  ns  --tcl
)
port map(
     x=>d0,
     fb=>jed_fb_14
   );

jed_node109 <= jed_fb_109;
jed_setpt_3<=(one);

jed_respt_3<=(one);

jed_clkpt_3<=((jed_fb_2) and (jed_fb_1));

jed_oept_3<=(one);

jed_sum_3<= (((jed_fb_13)));

jed_setpt_4<=(one);

jed_respt_4<=(one);

jed_clkpt_4<=((jed_fb_2) and (jed_fb_1));

jed_oept_4<=(one);

jed_sum_4<= (((jed_fb_14)));

end DSMB;
