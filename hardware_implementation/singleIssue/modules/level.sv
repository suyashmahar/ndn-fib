`define NULL 0
`timescale 1ns/1ps
/*
 working of a level:
 1. all the hexadecimal content is loaded from a file to read
 2. there are three types of memory first contains strides,
    second and third contains pointer addresses for left and right pointer respectively.
 3. level then receives a single address and a single data corresponding to search
 4. After recieving the data next address is returned along with a signal that indicates if a match occured or not
 */


parameter WORD_SIZE = 32;
parameter POINTER_SIZE = 6;
parameter MAX_NAME_LENGTH = 8; // max length of name in words

(*DONT_TOUCH = "true"*)module level
  #(
    parameter int MEM_SIZE = 16*1024,
    parameter LEVEL_ID = 1
    )( 
       input 				 clk_in,
       input [POINTER_SIZE - 1 : 0] 	 address_in,
       input [WORD_SIZE - 1 : 0] 	 lookup_cont_in,
       input [WORD_SIZE - 1 : 0] 	 next_lookup_cont_in,
       input [WORD_SIZE - 1 : 0] 	 fake_word_in, // Input that forces vivado to use BRAM for all memories 
       input [POINTER_SIZE - 1 : 0] 	 fake_add_in, 
       input [POINTER_SIZE - 1 : 0] 	 fake_input_write_address,

       output wire [WORD_SIZE - 1 : 0] 	 word_mem_loc_read,
         
       output reg [POINTER_SIZE - 1 : 0] next_pointer_out,
       output wire 			 is_match_out,
       output reg 			 no_child_out);
   (*DONT_TOUCH = "true"*)reg [31:0] sample_RAM [4095:0];
   
   (* ram_style = "ultra" *)reg [WORD_SIZE - 1 : 0] 		 word_mem [0 : MEM_SIZE - 1];
   (*DONT_TOUCH = "true"*)reg [POINTER_SIZE - 1 : 0] 		 left_pointer_mem [0 : MEM_SIZE - 1];
   (*DONT_TOUCH = "true"*)reg [POINTER_SIZE - 1 : 0] 		 right_pointer_mem [0 : MEM_SIZE - 1];
   (*DONT_TOUCH = "true"*)reg 					 left_pointer_valid_bits [0 : MEM_SIZE - 1];
   (*DONT_TOUCH = "true"*)reg 					 right_pointer_valid_bits [0 : MEM_SIZE - 1];
   
   integer 				 i = 0; // Handles loops
   /* 
    Loads data into memory from following files:
    Memory words: data/level#.dat
    Left pointer addresses: data/level#_lp.dat
    Right pointer addresses: data/level#_rp.dat
    */
   integer 				 t = 0;
   
   initial begin
       for (int t = 2; t < MEM_SIZE; t++) begin
	   word_mem[t] = {WORD_SIZE{1'b0}};
	   left_pointer_mem[t] = {POINTER_SIZE{1'b0}};
	   right_pointer_mem[t] = {POINTER_SIZE{1'b0}};
	   right_pointer_valid_bits[t] = {1'b0};
	   left_pointer_valid_bits[t] = {1'b0};
       end
       $display(LEVEL_ID);
       
       $readmemh({"/home/suyash/Dropbox/Documents/NDN/simData/level", {LEVEL_ID+1{"_"}}, ".dat"}, word_mem);
       $readmemh({"/home/suyash/Dropbox/Documents/NDN/simData/level", {LEVEL_ID+1{"_"}}, "lp.dat"}, left_pointer_mem);
       $readmemh({"/home/suyash/Dropbox/Documents/NDN/simData/level", {LEVEL_ID+1{"_"}}, "rp.dat"}, right_pointer_mem);
       
       $readmemh({"/home/suyash/Dropbox/Documents/NDN/simData/vb_level", {LEVEL_ID+1{"_"}}, "lp.dat"}, left_pointer_valid_bits);
       $readmemh({"/home/suyash/Dropbox/Documents/NDN/simData/vb_level", {LEVEL_ID+1{"_"}}, "rp.dat"}, right_pointer_valid_bits);
   end // initial begin

   reg [WORD_SIZE - 1 : 0] mem_read_val_loc;
   reg [WORD_SIZE - 1 : 0] left_mem_res;
   reg [WORD_SIZE - 1 : 0] right_mem_res;
   

   wire [POINTER_SIZE - 1 : 0] next_pointer_match;
   wire [POINTER_SIZE - 1 : 0] next_pointer_no_match;
   
   assign word_mem_loc_read =  mem_read_val_loc;
   assign is_match_out = (word_mem_loc_read == lookup_cont_in) ? 1'b1 : 1'b0;

   assign next_pointer_no_match = (lookup_cont_in < word_mem_loc_read) ?  left_pointer_mem[address_in] : right_pointer_mem[address_in];
   assign next_pointer_match = (next_lookup_cont_in <= lookup_cont_in) ? left_pointer_mem[address_in] : right_pointer_mem[address_in];
   assign next_pointer_out = (lookup_cont_in == word_mem_loc_read) ?  next_pointer_match : next_pointer_no_match;
   
   always @(negedge clk_in) begin
       #2
       mem_read_val_loc = word_mem[address_in];
       left_mem_res = left_pointer_mem[address_in];
       right_mem_res = right_pointer_mem[address_in];
       
       if (lookup_cont_in == mem_read_val_loc) begin
	   no_child_out = 1'b0;
       end else begin
	   if (lookup_cont_in <= mem_read_val_loc) begin
	       no_child_out = ~left_pointer_valid_bits[address_in];
	   end else begin
	       no_child_out = ~right_pointer_valid_bits[address_in];
	   end
       end // else: !if(lookup_cont_in == mem[address_in])
       
       // Fake logic to force vivado to use BRAM for memories instead of registers
       word_mem[fake_input_write_address] = fake_word_in;
       left_pointer_mem[fake_input_write_address] = fake_add_in;
       right_pointer_mem[fake_input_write_address] = fake_add_in;       
   end
   
endmodule
