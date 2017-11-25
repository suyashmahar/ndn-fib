`define NULL 0

`timescale 1ns/1ps

module top_testbench;
   parameter DATA_FILE_NAME_1 = "/home/suyash/Documents/GitHub/ndn-fib/hardware_implementation/data/1/names_data.dat";
   parameter DATA_FILE_NAME_2 = "/home/suyash/Documents/GitHub/ndn-fib/hardware_implementation/data/2/names_data.dat";
   parameter WORD_SIZE = 32;
   parameter TREE_HEIGHT = 4;
   parameter POINTER_SIZE = 6;
   parameter MAX_NAME_LENGTH = 8; // max length of name in words
   parameter STRIDE_INDEX_SIZE = 3;

   
   integer counter = 0;

   // Module variables
   reg 	   clk;
   reg [WORD_SIZE - 1 : 0] nextName [7 : 0][MAX_NAME_LENGTH - 1 : 0];
   wire 		   matchBool [TREE_HEIGHT - 1 : 0];
   
   integer 		   name_counter = 0;

   wire 		   dummy_output_0;
   wire 		   dummy_output_1;
   wire 		   dummy_output_2;
   wire 		   dummy_output_3;
   wire 		   dummy_output_4;
   wire 		   debug_address_pipeline_reg_0;

   wire [WORD_SIZE - 1 : 0] words_pipeline_3_0;
   wire [WORD_SIZE - 1 : 0] words_pipeline_3_1;
   wire [WORD_SIZE - 1 : 0] words_pipeline_3_2;
   wire [WORD_SIZE - 1 : 0] words_pipeline_3_3;
   wire [WORD_SIZE - 1 : 0] words_pipeline_3_4;
   wire [WORD_SIZE - 1 : 0] words_pipeline_3_5;
   wire [WORD_SIZE - 1 : 0] words_pipeline_3_6;
   wire [WORD_SIZE - 1 : 0] words_pipeline_3_7;

   
   // Wires for debugging stride count
   wire [STRIDE_INDEX_SIZE - 1 : 0] stageStrideIndex_0;
   wire [STRIDE_INDEX_SIZE - 1 : 0] stageStrideIndex_1;
   wire [STRIDE_INDEX_SIZE - 1 : 0] stageStrideIndex_2;
   wire [STRIDE_INDEX_SIZE - 1 : 0] stageStrideIndex_3;
   //--------------------------------------

   
   top
     #(
       .TREE_HEIGHT(5)
       ) dut (
	      .clk_in(clk),
	      
	      .name_component_1(nextName[counter][name_counter]),
	      .name_component_2(nextName[counter][name_counter]),
	      
	      .dummy_output_0(dummy_output_0),
	      .dummy_output_1(dummy_output_1),
	      .dummy_output_2(dummy_output_2),
	      .dummy_output_3(dummy_output_3),
	      .dummy_output_4(dummy_output_4),
	      
	      // Wires for debugging stride count
	      .stageStrideIndex_0_out(stageStrideIndex_0),
	      .stageStrideIndex_1_out(stageStrideIndex_1),
	      .stageStrideIndex_2_out(stageStrideIndex_2),
	      .stageStrideIndex_3_out(stageStrideIndex_3),
	      //--------------------------------------
	      
	      .debug_address_pipeline_reg_0(debug_address_pipeline_reg_0)
	      //.matchBool(matchBool)
	      );
   
   reg [WORD_SIZE - 1 : 0] 	    result;
   
   integer 			    data_file    ; // file handler
   integer 			    scan_file    ; // file handler
   integer 			    i,j;
   
   logic   signed [21:0] 	    captured_data;
   initial begin
       data_file = $fopen("/home/suyash/Documents/GitHub/ndn-fib/hardware_implementation/data/1/names_data_mod.dat", "r");
       for (i = 0; i < 9; i++) begin
//	   for (j = 0; j < 8; j++) begin
	       scan_file = $fscanf(data_file, "%x", nextName[i]);
//	   end
       end
       clk = 0;
       
   end

   reg flipper = 0;
   reg first_time = 1;
   
   always begin
       if (first_time) begin
	   #50 first_time = 0;
       end
       #25 clk = ~clk;
       #25 clk = ~clk;


       if (counter != 8) begin
	   // Logic for flatening data to supply to module
	   if (flipper == 1'b1) begin
	       name_counter++;
	   end
	   if (name_counter == MAX_NAME_LENGTH) begin
	       counter++;
	       name_counter = 0;
	   end 
       end
       flipper = ~flipper;

   end
endmodule // top_testbench
