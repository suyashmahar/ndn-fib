`include "comm_tools.svh"
`timescale 1ns/1ps


module node_testbench;
   
   reg clk;
   
   reg enable_input_in;
   reg [POINTER_SIZE - 1:0] left_pointer_in;
   reg [POINTER_SIZE - 1:0] right_pointer_in;
   reg [WORD_SIZE - 1:0]    data_word_in;
   
   wire [POINTER_SIZE - 1:0] left_pointer_out;
   wire [POINTER_SIZE - 1:0] right_pointer_out;
   wire [WORD_SIZE - 1:0]    data_word_out;
   wire 		     valid_bit_out;
   wire 		     left_pointer_valid_bit_out;
   wire 		     right_pointer_valid_bit_out;

   // *************************************************************************
   // Debug variables
   time 		     current_time;

   node 
     #(
       .WORD_SIZE(16),
       .POINTER_SIZE(16)
       ) uut (
	      .clk_in(clk),
	      
	      .enable_input_in(enable_input_in),
	      .left_pointer_in(left_pointer_in),
	      .right_pointer_in(right_pointer_in),
	      .data_word_in(data_word_in),
	      
	      .left_pointer_out(left_pointer_out),
	      .right_pointer_out(right_pointer_out),
	      .data_word_out(data_word_out),
	      .valid_bit_out(valid_bit_out),
	      .left_pointer_valid_bit_out(left_pointer_valid_bit_out),
	      .right_pointer_valid_bit_out(right_pointer_valid_bit_out)
	      );

   initial begin
       clk = 1'b1;       
       enable_input_in = 1'b0;
   end

       
   int i = 1;
   always begin
       #50
       clk = ~clk;
       case (i) 
	 1: begin
	     #5
	     // Checks for valid bit change to 1
	     assert_init_valid_bit_state : assert (valid_bit_out == 1'b0) begin
		 $display("Assertion \'assert_init_valid_bit_state\' passsed.");
	     end else begin
		 current_time = $time;
		 #1 $error("Assertion \'assert_init_valid_bit_state\' failed at %0t", current_time);
	     end
	     enable_input_in = 1'b1;
	 end
	 2: begin
	     #5
	     // Checks for valid bit change to 1
	     assert_valid_bit_state : assert (valid_bit_out == 1'b1) begin
		 $display("Assertion \'assert_valid_bit_state\' passsed.");
	     end else begin
		 current_time = $time;
		 #1 $error("Assertion \'assert_valid_bit_state\' failed at %0t", current_time);
	     end
	     data_word_in = {WORD_SIZE{1'b1}};
	 end
	 5: begin
	     enable_input_in = 1'b0;
	 end
	 6: begin
	     #5
	     // Checks for retention of data in memory
	     assert_data_retention_0 : assert (data_word_out == {WORD_SIZE{1'b1}}) begin
		 $display("Assertion \'assert_data_retention_0\' passsed.");
	     end else begin
		 current_time = $time;
		 #1 $error("Assertion \'assert_data_retention_0\' failed at %0t", current_time);
	     end
	  end
	 7: begin
	     #5
	     // Checks for retention of data in memory
	     assert_data_retention_1 : assert (data_word_out == {WORD_SIZE{1'b1}}) begin
		 $display("Assertion \'assert_data_retention_1\' passsed.");
	     end else begin
		 current_time = $time;
		 #1 $error("Assertion \'assert_data_retention_1\' failed at %0t", current_time);
	     end
	     
	     enable_input_in = 1'b1;
	     left_pointer <= {POINTER_SIZE{1'b1}} - 1;
	 end // case: 7
	 
	 // Rising edge of clock
	 8: begin
	     // Checks for retention of data in memory
	     assert_data_retention_1 : assert (data_word_out == {WORD_SIZE{1'b1}}) begin
		 $display("Assertion \'assert_data_retention_1\' passsed.");
	     end else begin
		 current_time = $time;
		 #1 $error("Assertion \'assert_data_retention_1\' failed at %0t", current_time);
	     end	 end
	 13: begin
	     $display(i);
	     $finish;
	 end
       endcase // case (i)
       i++;
   end
endmodule
