`timescale 1ns/1ps

// Parameters for generating names of data files easy
parameter GENERIC_FILENAME = "C:\\Users\\Suyash\\Dropbox\\backup\\ndn_implementation\\em\\data\\level";
parameter DATA_FILE_EXT = ".dat";
parameter DATA_FILE_LP = "_lp";
parameter DATA_FILE_RP = "_rp";
parameter STRIDE_INDEX_SIZE = 3;


module top
    #(
      parameter TREE_HEIGHT =  3,
      parameter WORD_SIZE = 32,
      parameter POINTER_SIZE = 1,
      parameter MAX_NAME_LENGTH = 8 // max length of name in words
      )(
      input 			clk,
      input [WORD_SIZE - 1 : 0] next_name_in [8 - 1 : 0],
      output 			vivado_snooper
      );
   
   // Signals for module
   reg [WORD_SIZE - 1 : 0] 	wordsPiplineReg [TREE_HEIGHT - 1 : 0] [MAX_NAME_LENGTH - 1 : 0];
   reg [POINTER_SIZE - 1 : 0] 	addressPipelineReg [TREE_HEIGHT - 1 : 0];
   wire [POINTER_SIZE - 1 : 0] 	addressPipelineOut [TREE_HEIGHT - 1 : 0];
   wire 			matchBool [TREE_HEIGHT - 1 : 0];
   wire 			noChildBool [TREE_HEIGHT - 1 : 0];
   reg [STRIDE_INDEX_SIZE - 1 : 0] stageStrideIndex [TREE_HEIGHT - 1 : 0];
   
   genvar 			   levelId;
   generate
       for (levelId = 0; levelId < TREE_HEIGHT; levelId++) begin
	   level 
		      #(
			.MEM_SIZE(2/*1<<levelId*/),
			.LEVEL_ID(levelId)
			) level_instance 
		      (
		       .clk_in(clk),
		       .address_in(addressPipelineReg[levelId]),
		       .lookup_cont_in(wordsPiplineReg[levelId][stageStrideIndex[levelId]]),

		       .next_pointer_out(addressPipelineOut[levelId]),
		       .is_match_out(matchBool[levelId]),
		       .no_child_out(noChildBool[levelId])
		       );
       end // for (LevelId = 0; i < TREE_HEIGHT; i++)
   endgenerate

   initial begin
      integer loop_var;
       for (loop_var = 0; loop_var < TREE_HEIGHT; loop_var++) begin
	   addressPipelineReg[loop_var] = {POINTER_SIZE{1'b0}};
       end       
       stageStrideIndex[0] = {STRIDE_INDEX_SIZE{1'b0}};
   end

   // Moves data between pipeline stages in FIFO order
   integer i, j;
   always @(posedge clk) begin
       #1 
	 wordsPiplineReg[0] <= next_name_in;
       for (j = 0; j < TREE_HEIGHT - 1; j++) begin
	   wordsPiplineReg[TREE_HEIGHT - 1 - j] <= wordsPiplineReg[TREE_HEIGHT - 1 - j - 1];
       end
   end
   
   // Moves adress between pipeline stages in FIFO order
   always @(posedge clk) begin
       #1
       for (j = 0; j < TREE_HEIGHT - 1; j++) begin
	   addressPipelineReg[TREE_HEIGHT - 1 - j] <= addressPipelineOut[TREE_HEIGHT - 1 - j - 1];
       end
   end
   
   // Moves adress between pipeline stages in FIFO order
   integer k;
   always @(posedge clk) begin

       stageStrideIndex[0] = {STRIDE_INDEX_SIZE{1'b0}};
       #1
       for (k = 0; k < TREE_HEIGHT-1; k++) begin
	   if (matchBool[TREE_HEIGHT - 2 - k] == 1'b1) begin
	       stageStrideIndex[TREE_HEIGHT - 1 - k] <= stageStrideIndex[TREE_HEIGHT - 1 - k - 1] + 1;
	   end else begin
	       stageStrideIndex[TREE_HEIGHT - 1 - k] <= stageStrideIndex[TREE_HEIGHT - 1 - k - 1];
	   end
       end
   end

endmodule // top

