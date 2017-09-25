`define NULL 0

`timescale 1ns/1ps

module top_testbench;
   parameter DATA_FILE_NAME = "C:\\Users\\Suyash\\Dropbox\\backup\\ndn_implementation\\em\\data\\names_data.dat";
   parameter WORD_SIZE = 32;
   parameter POINTER_SIZE = 16;
   parameter MAX_NAME_LENGTH = 8; // max length of name in words

   
   integer counter = 0;

   // Module variables
   reg 					clk;
   reg [WORD_SIZE - 1 : 0] 		nextName [8 : 0][MAX_NAME_LENGTH - 1:0];
   
   top
     #(
       .TREE_HEIGHT(4)
       ) dut (
	      .clk(clk),
	      .next_name_in(nextName[counter])
	      );
   
   reg [WORD_SIZE - 1 : 0] 		result;

   integer 				data_file    ; // file handler
   integer 				scan_file    ; // file handler
   integer 				i,j;
   
   logic   signed [21:0] 		captured_data;
   initial begin
       data_file = $fopen("C:\\Users\\Suyash\\Dropbox\\backup\\ndn_implementation\\em\\data\\names_data_mod.dat", "r");
       for (i = 0; i < 9; i++) begin
	   for (j = 0; j < 8; j++) begin
	       scan_file = $fscanf(data_file, "%x", nextName[i][j]);
	   end
       end
       
       clk = 0;
   end
   
   
   always begin
       #25 clk = ~clk;
       
       #25 clk = ~clk;


       if (counter != 8) begin
	   counter++;
       end
   end

   always @(result) begin
       //$display("%d", result);
   end
endmodule // top_testbench
