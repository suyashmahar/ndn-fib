`define NULL 0
`timescale 1ns/1ps
/*
 working of a level:
 1. all the hexadecimal content is loaded from a file to read
 2. there are three types of memory first contains strides, second and third contains pointer addresses for left and right pointer respectively.
 3. level then receives a single address and a single data corresponding to search
 4. After recieving the data next address is returned along with a signal that indicates if a match occured or not
 */


parameter WORD_SIZE = 64;
parameter POINTER_SIZE = 16;
parameter MAX_NAME_LENGTH = 16; // max length of name in words

module level
  #(
    parameter MEM_SIZE = 2,
    parameter LEVEL_ID = 1
    )( 
       input 				 clk_in,
       input [POINTER_SIZE - 1 : 0] 	 address_in,
       input [WORD_SIZE - 1 : 0] 	 lookup_cont_in,
  
       output reg [POINTER_SIZE - 1 : 0] next_pointer_out,
       output reg 			 is_match_out,
       output reg 			 no_child_out);

   string 				 levelIdStr =  $sformatf("%0d", LEVEL_ID);
   string 				 commPath = "/home/suyash/Documents/GitHub/ndn_implementation/em/data/level";
   string 				 data_file_name =  {commPath, levelIdStr, ".dat"};
   string 				 lp_file_name = {commPath, levelIdStr, "_lp.dat"};
   string 				 rp_file_name = {commPath, levelIdStr, "_rp.dat"};
   
   reg [WORD_SIZE - 1 : 0] 		 word_mem [0 : MEM_SIZE - 1];
   reg [POINTER_SIZE - 1 : 0] 		 left_pointer_mem [0 : MEM_SIZE - 1];
   reg [POINTER_SIZE - 1 : 0] 		 right_pointer_mem [0 : MEM_SIZE - 1];
   reg 					 left_pointer_valid_bits [0 : MEM_SIZE - 1];
   reg 					 right_pointer_valid_bits [0 : MEM_SIZE - 1];
   
   // declarations for reading textfile
   integer 				 data_file;
   integer 				 data_file_lp;
   integer 				 data_file_rp;
   integer 				 scan_file;
   integer 				 scan_file_lp;
   integer 				 scan_file_rp;
   reg [WORD_SIZE - 1 : 0] 		 captured_data;
   
   // Top 8 bits for flag indicating valid data in following two reg arr
   reg [WORD_SIZE + 7 : 0] 		 captured_data_lp; 
   reg [WORD_SIZE + 7 : 0] 		 captured_data_rp;

   integer 				 i = 0; // Handles loops

   /* 
    Loads data into memory from following files:
    Memory words: data/level#.dat
    Left pointer addresses: data/level#_lp.dat
    Right pointer addresses: data/level#_rp.dat
    */
   initial begin
       data_file  = $fopen(data_file_name, "r");
       data_file_lp  = $fopen(lp_file_name, "r");
       data_file_rp  = $fopen(rp_file_name, "r");

       // if (MEM_SIZE > LEVEL_ID) begin
       // 	   $display("ERROR: Memory size cannot be greater than level id at LEVEL_ID: %h", LEVEL_ID);
       // 	   $finish;
       // end
       
       if (data_file == `NULL | data_file_lp == `NULL | data_file_rp == `NULL) begin
	   $display("ERROR: File(s) couldn't be found or is(are) empty");
	   $finish;
       end else begin
	   for (i = 0; i < MEM_SIZE; i++) begin
	       if ($feof(data_file)) begin
		   $display("ERROR: End of file reached, exiting");
	       end else begin
		   scan_file = $fscanf(data_file, "%s\n", captured_data);
		   scan_file_lp = $fscanf(data_file_lp, "%s\n", captured_data_lp);
		   scan_file_rp = $fscanf(data_file_rp, "%s\n", captured_data_rp);
		   
		   word_mem[i] = captured_data;
		   left_pointer_mem[i] = captured_data_lp[WORD_SIZE - 1:0];
		   right_pointer_mem[i] = captured_data_rp[WORD_SIZE - 1:0];
		   
		   if (captured_data_lp == {(WORD_SIZE+8){1'b0}}) begin
		       left_pointer_valid_bits[i] = 1'b0;
		   end else begin
		       left_pointer_valid_bits[i] = 1'b1;
		   end
		   
		   if (captured_data_rp == {(WORD_SIZE+8){1'b0}}) begin
		       right_pointer_valid_bits[i] = 1'b0;
		   end else begin
		       right_pointer_valid_bits[i] = 1'b1;
		   end
	       end
	   end
       end // else: !if(data_file == `NULL | data_file_lp == `NULL | data_file_rp == `NULL)
   end // initial begin

   reg [WORD_SIZE - 1 : 0] mem_read_val_loc;
   
   always @(posedge clk_in) begin
       mem_read_val_loc = word_mem[address_in];
       if (lookup_cont_in == mem_read_val_loc) begin
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
