`define NULL 0
`timescale 1ns/1ps
/*
 working of a level:
 1. all the hexadecimal content is loaded from a file to read
 2. there are three types of memory first contains strides, second and third contains pointer addresses for left and right pointer respectively.
 3. level then receives a single address and a single data corresponding to search
 4. After recieving the data next address is returned along with a signal that indicates if a match occured or not
 */


parameter WORD_SIZE = 32;
parameter POINTER_SIZE = 1;
parameter MAX_NAME_LENGTH = 8; // max length of name in words

module level
  #(
    parameter int MEM_SIZE = 2,
    parameter LEVEL_ID = 1
    )( 
       input 				 clk_in,
       input [POINTER_SIZE - 1 : 0] 	 address_in,
       input [WORD_SIZE - 1 : 0] 	 lookup_cont_in,
  
       output reg [POINTER_SIZE - 1 : 0] next_pointer_out,
       output reg 			 is_match_out,
       output reg 			 no_child_out);
   
   reg [WORD_SIZE - 1 : 0] 		 word_mem [0 : MEM_SIZE - 1];
   reg [POINTER_SIZE - 1 : 0] 		 left_pointer_mem [0 : MEM_SIZE - 1];
   reg [POINTER_SIZE - 1 : 0] 		 right_pointer_mem [0 : MEM_SIZE - 1];
   reg 					 left_pointer_valid_bits [0 : MEM_SIZE - 1];
   reg 					 right_pointer_valid_bits [0 : MEM_SIZE - 1];
   
   integer 				 i = 0; // Handles loops
   /* 
    Loads data into memory from following files:
    Memory words: data/level#.dat
    Left pointer addresses: data/level#_lp.dat
    Right pointer addresses: data/level#_rp.dat
    */
   initial begin
       $display(LEVEL_ID);
       
       $readmemh({"C:\\Users\\Suyash\\Dropbox\\backup\\","ndn_implementation\\em\\data\\level", {LEVEL_ID+1{"_"}}, ".dat"}, word_mem);
       $readmemh({"C:\\Users\\Suyash\\Dropbox\\backup\\","ndn_implementation\\em\\data\\level", {LEVEL_ID+1{"_"}}, "lp.dat"}, left_pointer_mem);
       $readmemh({"C:\\Users\\Suyash\\Dropbox\\backup\\","ndn_implementation\\em\\data\\level", {LEVEL_ID+1{"_"}}, "rp.dat"}, right_pointer_mem);
       
       $readmemh({"C:\\Users\\Suyash\\Dropbox\\backup\\","ndn_implementation\\em\\data\\vb_level", {LEVEL_ID+1{"_"}}, "lp.dat"}, left_pointer_valid_bits);
       $readmemh({"C:\\Users\\Suyash\\Dropbox\\backup\\","ndn_implementation\\em\\data\\vb_level", {LEVEL_ID+1{"_"}}, "rp.dat"}, right_pointer_valid_bits);
   end // initial begin

   reg [WORD_SIZE - 1 : 0] mem_read_val_loc;
   
   always @(posedge clk_in) begin
       mem_read_val_loc = word_mem[address_in];
       if (lookup_cont_in == mem_read_val_loc) begin
	   //TODO: fix this
	   $display("This is awesome!");
	   
	   no_child_out = 1'b0;
	   next_pointer_out = left_pointer_mem[address_in];
	   is_match_out = 1'b1;
       end else begin
	   is_match_out = 1'b0;
	   if (lookup_cont_in <= mem_read_val_loc) begin
	       next_pointer_out = left_pointer_mem[address_in];
	       no_child_out = ~left_pointer_valid_bits[address_in];
	   end else begin
	       next_pointer_out = right_pointer_mem[address_in];
	       no_child_out = ~right_pointer_valid_bits[address_in];
	   end
       end // else: !if(lookup_cont_in == mem[address_in])	   
   end
   
endmodule
