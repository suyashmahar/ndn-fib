`define NULL 0

`timescale 1ns/1ps

module top_testbench;
   parameter DATA_FILE_NAME = "/home/suyash/Documents/GitHub/ndn_implementation/em/data/names_data.dat";
   parameter WORD_SIZE = 64;
   parameter POINTER_SIZE = 16;
   parameter MAX_NAME_LENGTH = 16; // max length of name in words
   
   // Variables for reading data from file
   integer 				data_file;
   integer 				scan_file;
   reg [WORD_SIZE - 1 : 0]  captured_data [MAX_NAME_LENGTH - 1 : 0];

   // Module variables
   reg 					clk;
   reg [WORD_SIZE - 1 : 0] nextName [MAX_NAME_LENGTH - 1 : 0];
   
   top
     #(
       .TREE_HEIGHT(4)
       ) dut (
	      .clk(clk),
	      .next_name_in(nextName));

   // Initializes file stream to read data from
   function int initializeDataFileStream();
       data_file = $fopen(DATA_FILE_NAME, "r");
   endfunction // initializeDataFileStream

   // Returns next name from file stream
   function string getNextName();
      string 		   result;    
       scan_file = $fscanf(data_file, "%s\n", result);
       return result;
   endfunction // getNextName
   
   initial begin
       // Initliazes file to read data from
       initializeDataFileStream();
       
       if (data_file == `NULL) begin
 	   $display("ERROR: data file can't be read");
	   $finish;
       end
       
       clk = 0;
   end

   reg [WORD_SIZE - 1 : 0] nextName [MAX_NAME_LENGTH - 1 : 0]
   always begin
       #10 clk = ~clk;
       #10 clk = ~clk;

       if ($feof(data_file)) begin
	   $finish;
       end
      string nextName = getNextName();
       
       $display(nextName);
       
       nextName = nextName;
       
   end
endmodule // top_testbench
