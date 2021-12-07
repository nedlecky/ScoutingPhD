module p3x3 ( 
	clk,
	reinit,
	rand,
	init,
	solved
	) ;

input  clk;
input  reinit;
input [1:0] rand;
input [35:0] init;
inout  solved;
