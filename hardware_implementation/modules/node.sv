`timescale 1ns/1ps
// Contains description of single node of FIB

// Notes:
// * 1'b1 indicates valid data while 1'b0 indicates invalid data

module node 
  #(
    parameter WORD_SIZE = 16,    // Size of each word
    parameter POINTER_SIZE = 16 // Size of each pointer for address info
    )(
      input 			  clk_in,

      input 			  enable_input_in,
      input [POINTER_SIZE - 1:0]  left_pointer_in,
      input [POINTER_SIZE - 1:0]  right_pointer_in,
      input [WORD_SIZE - 1:0] 	  data_word_in,
  
      output [POINTER_SIZE - 1:0] left_pointer_out,
      output [POINTER_SIZE - 1:0] right_pointer_out,
      output [WORD_SIZE - 1:0] 	  data_word_out,
      output 			  valid_bit_out,
      output 			  left_pointer_valid_bit_out,
      output 			  right_pointer_valid_bit_out
      );


   reg [WORD_SIZE - 1:0] 		data_word;
   reg 				valid_bit = 1'b0;
   reg [POINTER_SIZE - 1:0] 	left_pointer;
   reg [POINTER_SIZE - 1:0] 	right_pointer;
   reg 				left_pointer_valid_bit = 1'b0;
   reg 				right_pointer_valid_bit = 1'b0;


   assign data_word_out = data_word;
   assign valid_bit_out = valid_bit;
   
   assign left_pointer_out = left_pointer;
   assign right_pointer_out = right_pointer;
   
   assign left_pointer_valid_bit_out = left_pointer_valid_bit;
   assign right_pointer_valid_bit_out = right_pointer_valid_bit;
   
   initial begin
       left_pointer_valid_bit = 1'b0;
       right_pointer_valid_bit = 1'b0;
       valid_bit = 1'b0;
   end // UNMATCHED !!

   always @(posedge clk_in) begin
       if (enable_input_in == 1'b1) begin
	   data_word <= data_word_in;
	   left_pointer <= left_pointer_in;
	   right_pointer <= right_pointer_in;
	   valid_bit <= 1'b1;
       end
   end
endmodule
