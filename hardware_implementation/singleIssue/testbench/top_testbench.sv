`define NULL 0

`timescale 1ns/1ps

module top_testbench;
   parameter DATA_FILE_NAME = "/home/suyash/Documents/GitHub/ndn-fib/hardware_implementation/data/names_data.dat";
   parameter WORD_SIZE = 32;
   parameter TREE_HEIGHT = 100;
   parameter POINTER_SIZE = 6;
   parameter MAX_NAME_LENGTH = 8; // max length of name in words
   parameter STRIDE_INDEX_SIZE = 3;

   
   integer counter = 0;

   // Module variables
   reg 	   clk;
   reg [MAX_NAME_LENGTH*WORD_SIZE - 1 : 0] nextName [7 : 0];
   wire 		   matchBool [TREE_HEIGHT - 1 : 0];
   
   integer 		   name_counter = 0;

   wire 		   dummy_output_0;
   wire 		   dummy_output_1;
   wire 		   dummy_output_2;
   wire 		   dummy_output_3;
   wire        dummy_output_4;
   wire 		   debug_address_pipeline_reg_0;

   
   // Wires for debugging stride count
   wire [STRIDE_INDEX_SIZE - 1 : 0] stageStrideIndex_0;
   wire [STRIDE_INDEX_SIZE - 1 : 0] stageStrideIndex_1;
   wire [STRIDE_INDEX_SIZE - 1 : 0] stageStrideIndex_2;
   wire [STRIDE_INDEX_SIZE - 1 : 0] stageStrideIndex_3;
   //--------------------------------------

   
   top
     #(
       .TREE_HEIGHT(100)
       ) dut (
	      .clk(clk),
	      .name_in(nextName[counter]),
	      .dummy_output_0(dummy_output_0),
	      .dummy_output_1(dummy_output_1),
	      .dummy_output_2(dummy_output_2),
         .dummy_output_3(dummy_output_3),
         .dummy_output_4(dummy_output_4),
	      
	      .debug_address_pipeline_reg_0(debug_address_pipeline_reg_0)
	      //.matchBool(matchBool)
	      );
   
   reg [WORD_SIZE - 1 : 0] 	    result;
   
   integer 			    data_file    ; // file handler
   integer 			    scan_file    ; // file handler
   integer 			    i,j;
   
   logic   signed [21:0] 	    captured_data;
   initial begin
       data_file = $fopen("/home/suyash/Documents/GitHub/ndn-fib/hardware_implementation/data/names_data_mod.dat", "r");
       for (i = 0; i < 8; i++) begin
	       scan_file = $fscanf(data_file, "%x", nextName[i]);
       end
       clk = 0;
       
   end

   reg first_time = 1;
   
   always begin
       if (first_time) begin
	   #50 first_time = 0;
       end
       #25 clk = ~clk;
       #25 clk = ~clk;


       counter++;

   end
endmodule // top_testbench
