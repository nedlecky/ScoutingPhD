module andgate ( PB1, PB2, LED);

	input PB1, PB2;
	output LED;

  	assign LED = PB1 & PB2;

endmodule

