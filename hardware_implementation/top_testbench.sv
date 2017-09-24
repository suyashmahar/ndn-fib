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


   // Module variables
   reg 					clk;
   reg [WORD_SIZE - 1 : 0] 		nextName [MAX_NAME_LENGTH - 1 : 0];
   
   top
     #(
       .TREE_HEIGHT(4)
       ) dut (
	      .clk(clk),
	      .next_name_in(nextName)
	      );

   int 					counter = 0;
   reg [WORD_SIZE - 1 : 0] 		result;
   // Extracts next name from data stream and places in 'nextName' reg
   task extractNextName();
       counter = 0; 
       scan_file = $fscanf(data_file, "%s\n", result);
       
       while(result != "{{}}")     begin
       	   nextName[counter] = result;
	   $display("counter : %d", counter);
	   
	   counter++;
	   scan_file = $fscanf(data_file, "%s\n", result);
       end

       for (counter = counter; counter < MAX_NAME_LENGTH; counter++) begin
	   nextName[counter] = {WORD_SIZE{1'b0}};
       end
   endtask // getNextName
   
   initial begin
       data_file = $fopen(DATA_FILE_NAME, "r");
       
       if (data_file == `NULL) begin
 	   $display("ERROR: data file can't be read");
	   $finish;
       end
       
       clk = 1;
   end

   always begin
       #10 clk = ~clk;

       if ($feof(data_file)) begin
	   $display("End of file reached, continuing simulation");
       end

       extractNextName();
       
       #10 clk = ~clk;

   end

   always @(result) begin
       $display("%d", result);
   end
endmodule // top_testbench
