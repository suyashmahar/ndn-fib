`include "comm_tools.svh"

`timescale 1ns/1ps

// Parameters for generating names of data files easy
parameter WORD_SIZE = 64;
parameter POINTER_SIZE = 16;
parameter MAX_NAME_LENGTH = 16; // max length of name in words
parameter GENERIC_FILENAME = "/home/suyash/Documents/GitHub/ndn_implementation/em/data/level";
parameter DATA_FILE_EXT = ".dat";
parameter DATA_FILE_LP = "_lp";
parameter DATA_FILE_RP = "_rp";
parameter STRIDE_INDEX_SIZE = 8;


module top
  #(
    parameter TREE_HEIGHT = 100
    )(
      input 			clk,
      input [WORD_SIZE - 1 : 0] next_name_in [MAX_NAME_LENGTH - 1 : 0],
      );
   
   // Signals for module
   reg [WORD_SIZE - 1 : 0] 	wordsPiplineReg [TREE_HEIGHT - 1 : 0] [MAX_NAME_LENGTH - 1 : 0];
   wire [POINTER_SIZE - 1 : 0] 	addressPipelineReg [TREE_HEIGHT - 1 : 0];
   wire 			matchBool [TREE_HEIGHT - 1 : 0];
   wire 			noChildBool [TREE_HEIGHT - 1 : 0];
   reg [STRIDE_INDEX_SIZE - 1 : 0] stageStrideIndex [TREE_HEIGHT - 1 : 0];
   
   
   genvar 			   levelId;
   generate
       for (levelId = 0; levelId < TREE_HEIGHT; levelId++) begin
	   level 
		      #(
			.MEM_SIZE(1<<levelId)
			) level_instance 
		      (
		       .clk_in(clk),
		       .address_in(addressPipelineReg[levelId]),
		       .lookup_cont_in(wordsPiplineReg[levelId][stageStrideIndex[levelId]]),

		       .next_pointer_out(addressPipelineReg[levelId]),
		       .is_match_out(matchBool[levelId]),
		       .no_child_out(noChildBool[levelId])
		       );
       end // for (LevelId = 0; i < TREE_HEIGHT; i++)
   endgenerate

   // Moves data between pipeline stages in FIFO order
   integer j;
   always @(posedge clk) begin
       for (j = 0; j < TREE_HEIGHT; j++) begin
	   if (j == 0) begin
	       wordsPiplineReg[0] = next_name_in;
	   end else if (j < TREE_HEIGHT - 1) begin
	       wordsPiplineReg[j] = wordsPiplineReg[j - 1];
	   end
       end
   end

   // Moves data between pipeline stages in FIFO order for keeping track of strides
   integer k;
   always @(posedge clk) begin
       for (k = 0; k < TREE_HEIGHT; k++) begin
	   if (k == 0) begin
	       stageStrideIndex[0] = {STRIDE_INDEX_SIZE{1'b0}};
           end else if (k < TREE_HEIGHT - 1) begin
    	      if (matchBool[k] == 1'b1) begin
		  stageStrideIndex[k]++;
	      end
	      else if (noChildBool[k]) begin
		  // TODO: complete this shit
	      end
	      stageStrideIndex[k] = stageStrideIndex[k - 1];
	   end
       end
   end

endmodule // top

