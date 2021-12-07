module orgate( PB1, PB2, LED );

   input  PB1, PB2;		             // Port Declaration
   output LED;

   assign LED = ! ( ! PB1 | ! PB2 ) // Concurrent Assignment

endmodule
