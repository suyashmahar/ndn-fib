`timescale 1ns/1ps
`define NULL 0

// Parameters for generating names of data files easy
parameter GENERIC_FILENAME = "/home/suyash/Documents/GitHub/ndn_implementation/em/data/level";
parameter DATA_FILE_EXT = ".dat";
parameter DATA_FILE_LP = "_lp";
parameter DATA_FILE_RP = "_rp";
parameter MAX_NAME_LENGTH = 16; // max length of name in words
parameter WORD_SIZE = 16;
parameter POINTER_SIZE = 16;

module top
  #(
    parameter TREE_HEIGHT = 100
    )(
      input [WORD_SIZE - 1 : 0] next_name_in [MAX_NAME_LENGTH - 1 : 0]
      );
   
   // Signals for module
   reg 				clk;
   reg [WORD_SIZE - 1 : 0] 	wordsPiplineReg [TREE_HEIGHT - 1 : 0] [MAX_NAME_LENGTH - 1 : 0];
   reg [WORD_SIZE - 1 : 0] 	addressPipelineReg [TREE_HEIGHT - 1 : 0];
   reg 				matchBool [TREE_HEIGHT - 1 : 0];
   reg 				noChildBool [TREE_HEIGHT - 1 : 0];
   
   
   genvar 			levelId;
   generate
       for (levelId = 0; levelId < TREE_HEIGHT; levelId++) begin
	   
	   level #(
		   .WORD_SIZE(16),
		   .POINTER_SIZE(16),
		   .DATA_FILE_NAME({{GENERIC_FILENAME}, {levelId}, {DATA_FILE_EXT}}),
		   .LP_FILE_NAME({{GENERIC_FILENAME}, {levelId}, {DATA_FILE_LP}, {DATA_FILE_EXT}}),
		   .RP_FILE_NAME({{GENERIC_FILENAME}, {levelId}, {DATA_FILE_RP}, {DATA_FILE_EXT}})
		   ) level_instance 
		      (
		       .clk_in(clk),
		       .address_in(addressPipelineReg[levelId]),
		       .lookup_cont_in(wordsPiplineReg[levelId]),

		       .next_pointer_out(addressPipelineReg[levelId]),
		       .is_match_out(matchBool[levelId]),
		       .no_child_out(noChildBool[levelId])
		       );
       end // for (LevelId = 0; i < TREE_HEIGHT; i++)
   endgenerate

   // Moves data between pipeline stages in FIFO order
   integer pipelineStageId;
   always @(posedge clk) begin
       for (pipelineStageId = 0; pipelineStageId < TREE_HEIGHT; pipelineStageId++) begin
	   if (pipelineStageId == 0) begin
	       wordsPiplineReg[0] = next_name_in;
	   end else if (pipelineStageId < TREE_HEIGHT - 1) begin
	       wordsPiplineReg[pipelineStageId] = wordsPiplineReg[pipelineStageId - 1];
	   end
       end
   end

   // Moves data between pipeline stages in FIFO order
   integer pointPipeStageId;
   always @(posedge clk) begin
       for (pointPipeStageId = 0; pointPipeStageId < TREE_HEIGHT; pointPipeStageId++) begin
	   if (pointPipeStageId == 0) begin
	       wordsPiplineReg[0] = next_name_in;
	   end else if (pointPipeStageId < TREE_HEIGHT - 1) begin
	       wordsPiplineReg[pointPipeStageId] = wordsPiplineReg[pointPipeStageId - 1];
	   end
       end
   end
endmodule // top

