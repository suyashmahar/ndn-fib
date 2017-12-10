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

       // Input for first lookup logic
       input [POINTER_SIZE - 1 : 0] 	 address_in_1,
       input [WORD_SIZE - 1 : 0] 	 lookup_cont_in_1,
       input [WORD_SIZE - 1 : 0] 	 next_lookup_cont_in_1,
  
       output wire [WORD_SIZE - 1 : 0] 	 word_mem_loc_read_1,
  
       output reg [POINTER_SIZE - 1 : 0] next_pointer_out_1,
       output wire 			 is_match_out_1,
       output reg 			 no_child_out_1,

       // Input for second pipeline
       input [POINTER_SIZE - 1 : 0] 	 address_in_2,
       input [WORD_SIZE - 1 : 0] 	 lookup_cont_in_2,
       input [WORD_SIZE - 1 : 0] 	 next_lookup_cont_in_2,
  
       output wire [WORD_SIZE - 1 : 0] 	 word_mem_loc_read_2,
  
       output reg [POINTER_SIZE - 1 : 0] next_pointer_out_2,
       output wire 			 is_match_out_2,
       output reg 			 no_child_out_2,

       // Input that forces vivado to use BRAM for all memories
       input [WORD_SIZE - 1 : 0] 	 fake_word_in,
       input [POINTER_SIZE - 1 : 0] 	 fake_add_in,
       input [POINTER_SIZE - 1 : 0] 	 fake_input_write_address
       );
   
   
   (*DONT_TOUCH = "true"*)reg [31:0] sample_RAM [4095:0];

   // Memory resources for first pipeline
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

       // Set all memory content to 0
       for (int t = 2; t < MEM_SIZE; t++) begin
	   word_mem[t] = {WORD_SIZE{1'b0}};
	   left_pointer_mem[t] = {POINTER_SIZE{1'b0}};
	   right_pointer_mem[t] = {POINTER_SIZE{1'b0}};
	   right_pointer_valid_bits[t] = {1'b0};
	   left_pointer_valid_bits[t] = {1'b0};
       end // for (int t = 2; t < MEM_SIZE; t++)
       
       $display(LEVEL_ID);

       // Load first pipeline
       $readmemh({"/home/suyash/Dropbox/Documents/NDN/simData/level", {LEVEL_ID+1{"_"}}, ".dat"}, word_mem);
       $readmemh({"/home/suyash/Dropbox/Documents/NDN/simData/level", {LEVEL_ID+1{"_"}}, "lp.dat"}, left_pointer_mem);
       $readmemh({"/home/suyash/Dropbox/Documents/NDN/simData/level", {LEVEL_ID+1{"_"}}, "rp.dat"}, right_pointer_mem);
       
       $readmemh({"/home/suyash/Dropbox/Documents/NDN/simData/vb_level", {LEVEL_ID+1{"_"}}, "lp.dat"}, left_pointer_valid_bits);
       $readmemh({"/home/suyash/Dropbox/Documents/NDN/simData/vb_level", {LEVEL_ID+1{"_"}}, "rp.dat"}, right_pointer_valid_bits);
   end // initial begin

   // Variables to handle intermediate data
   // Pipeline 1
   reg [WORD_SIZE - 1 : 0] mem_read_val_loc_1;
   reg [WORD_SIZE - 1 : 0] left_mem_res_1;
   reg [WORD_SIZE - 1 : 0] right_mem_res_1;

   wire [POINTER_SIZE - 1 : 0] next_pointer_match_1;
   wire [POINTER_SIZE - 1 : 0] next_pointer_no_match_1;
   
   assign word_mem_loc_read_1 =  mem_read_val_loc_1;
   assign is_match_out_1 = (word_mem_loc_read_1 == lookup_cont_in_1) ? 1'b1 : 1'b0;

   assign next_pointer_no_match_1 = (lookup_cont_in_1 < word_mem_loc_read_1) ?  left_pointer_mem[address_in_1] : right_pointer_mem[address_in_1];
   assign next_pointer_match_1 = (next_lookup_cont_in_1 <= lookup_cont_in_1) ? left_pointer_mem[address_in_1] : right_pointer_mem[address_in_1];
   assign next_pointer_out_1 = (lookup_cont_in_1 == word_mem_loc_read_1) ?  next_pointer_match_1 : next_pointer_no_match_1;

   
   // Pipeline 2
   reg [WORD_SIZE - 1 : 0]     mem_read_val_loc_2;
   reg [WORD_SIZE - 1 : 0]     left_mem_res_2;
   reg [WORD_SIZE - 1 : 0]     right_mem_res_2;

   wire [POINTER_SIZE - 1 : 0] next_pointer_match_2;
   wire [POINTER_SIZE - 1 : 0] next_pointer_no_match_2;
   
   assign word_mem_loc_read_2 =  mem_read_val_loc_2;
   assign is_match_out_2 = (word_mem_loc_read_2 == lookup_cont_in_2) ? 1'b1 : 1'b0;

   assign next_pointer_no_match_2 = (lookup_cont_in_2 < word_mem_loc_read_2) ?  left_pointer_mem[address_in_2] : right_pointer_mem[address_in_2];
   assign next_pointer_match_2 = (next_lookup_cont_in_2 <= lookup_cont_in_2) ? left_pointer_mem[address_in_2] : right_pointer_mem[address_in_2];
   assign next_pointer_out_2 = (lookup_cont_in_2 == word_mem_loc_read_2) ?  next_pointer_match_2 : next_pointer_no_match_2;

   // Pipeline 1
   always @(negedge clk_in) begin
       #26
	 mem_read_val_loc_1 = word_mem[address_in_1];
       left_mem_res_1 = left_pointer_mem[address_in_1];
       right_mem_res_1 = right_pointer_mem[address_in_1];
       
       if (lookup_cont_in_1 == mem_read_val_loc_1) begin
	   no_child_out_1 = 1'b0;
       end else begin
	   if (lookup_cont_in_1 <= mem_read_val_loc_1) begin
	       no_child_out_1 = ~left_pointer_valid_bits[address_in_1];
	   end else begin
	       no_child_out_1 = ~right_pointer_valid_bits[address_in_1];
	   end
       end // else: !if(lookup_cont_in_1 == mem[address_in_1])
       
       // Fake logic to force vivado to use BRAM for memories instead of registers
       word_mem[fake_input_write_address] = fake_word_in;
       left_pointer_mem[fake_input_write_address] = fake_add_in;
       right_pointer_mem[fake_input_write_address] = fake_add_in;
   end // always @ (negedge clk_in)
   
   // Pipeline 2
   always @(negedge clk_in) begin
       #26
	 mem_read_val_loc_2 = word_mem[address_in_2];
       left_mem_res_2 = left_pointer_mem[address_in_2];
       right_mem_res_2 = right_pointer_mem[address_in_2];
       
       if (lookup_cont_in_2 == mem_read_val_loc_2) begin
	   no_child_out_2 = 1'b0;
       end else begin
	   if (lookup_cont_in_2 <= mem_read_val_loc_2) begin
	       no_child_out_2 = ~left_pointer_valid_bits[address_in_2];
	   end else begin
	       no_child_out_2 = ~right_pointer_valid_bits[address_in_2];
	   end
       end
   end
   
endmodule
