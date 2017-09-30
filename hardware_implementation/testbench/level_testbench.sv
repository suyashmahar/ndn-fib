`timescale 1ns/1ps

module level_testbench;
   parameter WORD_SIZE = 16;
   parameter POINTER_SIZE = 16;
   parameter DATA_FILE_NAME = "/home/suyash/Documents/GitHub/ndn_implementation/em/data/level1.dat";
   parameter MEM_SIZE = 2;
   parameter LEVEL_ID = 1;
   
   reg 				clk;
   reg [POINTER_SIZE - 1 : 0] 	address_in;
   reg [WORD_SIZE - 1 : 0] 	lookup_cont_in;
   
   wire [POINTER_SIZE - 1 : 0] 	next_pointer_out;
   wire 			is_match_out;
   wire 			no_child_out;
   
   level dut
       ( 
	 clk,
	 address_in,
	 lookup_cont_in,
       
	 next_pointer_out,
	 is_match_out,
	 no_child_out
	 );

   initial begin
       clk = 0;
       address_in = {POINTER_SIZE{1'b0}};
       lookup_cont_in = {WORD_SIZE{1'b0}};

       #50 clk = ~clk;
       #50 clk = ~clk;

       address_in = {POINTER_SIZE{1'b0}};
       lookup_cont_in = "{}";

       #50 clk = ~clk;
       #50 clk = ~clk;

       address_in = {{(POINTER_SIZE-1){1'b0}},{1'b1}};
       lookup_cont_in = "!!";
       
       #50 clk = ~clk;
       #50 clk = ~clk;

       address_in = {{(POINTER_SIZE-1){1'b0}},{1'b1}};
       lookup_cont_in = "\Xl";
       
       #50 clk = ~clk;
       #50 clk = ~clk;
       $finish;
       
   end


   
endmodule
