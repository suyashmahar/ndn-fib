`timescale 1ns/1ps

// Parameters for generating names of data files easy
parameter GENERIC_FILENAME = "C:\\Users\\Suyash\\Dropbox\\backup\\ndn_implementation\\em\\data\\level";
parameter DATA_FILE_EXT = ".dat";
parameter DATA_FILE_LP = "_lp";
parameter DATA_FILE_RP = "_rp";
parameter STRIDE_INDEX_SIZE = 3;


(*DONT_TOUCH = "true"*)module top
  #(
    parameter TREE_HEIGHT =  4,
    parameter WORD_SIZE = 32,
    parameter POINTER_SIZE = 6,
    parameter MAX_NAME_LENGTH = 8 // max length of name in words
    )(
      input 				      clk_in,
      input [WORD_SIZE - 1 : 0] 	      name_component,
      output wire 			      dummy_output_0,
      output wire 			      dummy_output_1,
      output wire 			      dummy_output_2,
      output wire 			      dummy_output_3,
  
      // Outputs for debuging pipeline stages
      output wire [WORD_SIZE - 1 : 0] 	      words_pipeline_3_0,
      output wire [WORD_SIZE - 1 : 0] 	      words_pipeline_3_1,
      output wire [WORD_SIZE - 1 : 0] 	      words_pipeline_3_2,
      output wire [WORD_SIZE - 1 : 0] 	      words_pipeline_3_3,
      output wire [WORD_SIZE - 1 : 0] 	      words_pipeline_3_4,
      output wire [WORD_SIZE - 1 : 0] 	      words_pipeline_3_5,
      output wire [WORD_SIZE - 1 : 0] 	      words_pipeline_3_6,
      output wire [WORD_SIZE - 1 : 0] 	      words_pipeline_3_7, 
      // -------------------------------------

      // Outputs for debugging stride count
      output wire [STRIDE_INDEX_SIZE - 1 : 0] stageStrideIndex_0,
      output wire [STRIDE_INDEX_SIZE - 1 : 0] stageStrideIndex_1,
      output wire [STRIDE_INDEX_SIZE - 1 : 0] stageStrideIndex_2,
      output wire [STRIDE_INDEX_SIZE - 1 : 0] stageStrideIndex_3,
      //--------------------------------------

      // Debugging level memory read
      output wire [WORD_SIZE - 1 : 0] 	      word_mem_loc_read_0,
      output wire [WORD_SIZE - 1 : 0] 	      word_mem_loc_read_1,
      output wire [WORD_SIZE - 1 : 0] 	      word_mem_loc_read_2,
      output wire [WORD_SIZE - 1 : 0] 	      word_mem_loc_read_3,
      //------------------------------

      output wire 			      clk_mod,
  
      output wire [POINTER_SIZE - 1 : 0]      debug_address_pipeline_reg_0
      );
   reg [WORD_SIZE - 1 : 0] 		      next_name_in [MAX_NAME_LENGTH - 1 : 0];
   wire 				      matchBool [TREE_HEIGHT - 1 : 0];

   assign clk_mod = clk;
   
   assign dummy_output_0 = matchBool[0];
   assign dummy_output_1 = matchBool[1];
   assign dummy_output_2 = matchBool[2];
   assign dummy_output_3 = matchBool[3];
   
   assign debug_address_pipeline_reg_0 = addressPipelineReg[1];
   

   // Assignments for words_pipelining
   assign words_pipeline_3_0 = wordsPiplineReg[3][0];
   assign words_pipeline_3_1 = wordsPiplineReg[3][1];
   assign words_pipeline_3_2 = wordsPiplineReg[3][2];
   assign words_pipeline_3_3 = wordsPiplineReg[3][3];
   assign words_pipeline_3_4 = wordsPiplineReg[3][4];
   assign words_pipeline_3_5 = wordsPiplineReg[3][5];
   assign words_pipeline_3_6 = wordsPiplineReg[3][6];
   assign words_pipeline_3_7 = wordsPiplineReg[3][7];
   // --------------------------------
   
   // assignement for debugging stride count
   assign stageStrideIndex_0 = stageStrideIndex[0];
   assign stageStrideIndex_1 = stageStrideIndex[1];
   assign stageStrideIndex_2 = stageStrideIndex[2];
   assign stageStrideIndex_3 = stageStrideIndex[3];
   //--------------------------------------

   // assignment statements for debugging level memory
   assign word_mem_loc_read_0 = word_mem_loc_read[0];
   assign word_mem_loc_read_1 = word_mem_loc_read[1];
   assign word_mem_loc_read_2 = word_mem_loc_read[2];
   assign word_mem_loc_read_3 = word_mem_loc_read[3];
   
   
   reg 					      clk = 0;			// Real clock for the module
   integer 				      mod_clk_counter = 0;		// Keeps count of module clock
   reg 					      flipper = 0;
   
   always @(posedge clk_in) begin
       if (mod_clk_counter == 2*MAX_NAME_LENGTH-1) begin
	   clk = ~clk;
       end else if (mod_clk_counter == 2*MAX_NAME_LENGTH - 3) begin
	   clk = 0;
       end
       mod_clk_counter = (mod_clk_counter + 1)%(2*MAX_NAME_LENGTH);
       flipper = ~flipper;
   end

   integer accumulator_counter = 0;
   
   always @(posedge flipper) begin
       next_name_in[accumulator_counter] = name_component;
       accumulator_counter = (accumulator_counter+1)%MAX_NAME_LENGTH;
   end
   
   wire [STRIDE_INDEX_SIZE - 1 : 0]    stage_output [TREE_HEIGHT - 1 : 0];
   
   assign stage_output = stageStrideIndex;
   
   // Signals for module
   (*DONT_TOUCH = "true"*) reg [WORD_SIZE - 1 : 0] 	       wordsPiplineReg [TREE_HEIGHT - 1 : 0] [MAX_NAME_LENGTH - 1 : 0];
   (*DONT_TOUCH = "true"*) reg [POINTER_SIZE - 1 : 0] 		      addressPipelineReg [TREE_HEIGHT - 1 : 0];
   (*DONT_TOUCH = "true"*) reg [STRIDE_INDEX_SIZE - 1 : 0] 	      stageStrideIndex [TREE_HEIGHT - 1 : 0];

   
   wire [POINTER_SIZE - 1 : 0] 	       addressPipelineOut [TREE_HEIGHT - 1 : 0];
   wire 			       noChildBool [TREE_HEIGHT - 1 : 0];

   wire 			       dummy_signal_inter_0;
   wire 			       dummy_signal_inter_1;
   wire 			       dummy_signal_inter_2;
   wire [WORD_SIZE - 1 : 0] 	       word_mem_loc_read [TREE_HEIGHT - 1 : 0];
   
   integer 			       dummy_loop;
   
   genvar 			       levelId;
   generate
       for (levelId = 0; levelId < TREE_HEIGHT; levelId++) begin
	   level 
		      #(
			.MEM_SIZE(4/*1<<levelId*/),
			.LEVEL_ID(levelId)
			) level_instance 
		      (
		       .clk_in(clk),
		       .address_in(addressPipelineReg[levelId]),
		       .lookup_cont_in(wordsPiplineReg[levelId][stageStrideIndex[levelId]]),
		       .word_mem_loc_read(word_mem_loc_read[levelId]),
		       .next_pointer_out(addressPipelineOut[levelId]),
		       .is_match_out(matchBool[levelId]),
		       .no_child_out(noChildBool[levelId])
		       );
       end // for (LevelId = 0; i < TREE_HEIGHT; i++)
   endgenerate

   initial begin
      integer loop_var_0, loop_var_1;
       for (loop_var_0 = 0; loop_var_0 < TREE_HEIGHT; loop_var_0++) begin
	   addressPipelineReg[loop_var_0] = {POINTER_SIZE{1'b0}};
       end       
       stageStrideIndex[0] = {STRIDE_INDEX_SIZE{1'b0}};
       
   end

   // Moves data between pipeline stages in FIFO order
   integer i, j, m, n;
   always @(posedge clk) begin
       #1 
	 for (i = 0; i < MAX_NAME_LENGTH; i++) begin
	     wordsPiplineReg[0][i] <= next_name_in[i];
	 end
       
       for (j = 0; j < TREE_HEIGHT - 1; j++) begin
	   for (m = 0; m < MAX_NAME_LENGTH; m++) begin
	       wordsPiplineReg[TREE_HEIGHT - 1 - j][m] <= wordsPiplineReg[TREE_HEIGHT - 1 - j - 1][m];
	   end
       end
   end
   
   // Moves adress between pipeline stages in FIFO order
   always @(posedge clk) begin
       #1
	 for (n = 0; n < TREE_HEIGHT - 1; n++) begin
	     addressPipelineReg[TREE_HEIGHT - 1 - n] <= addressPipelineOut[TREE_HEIGHT - 1 - n - 1];
	 end
   end
   
   // Moves adress between pipeline stages in FIFO order
   integer k;
   always @(posedge clk) begin
       stageStrideIndex[0] <= {STRIDE_INDEX_SIZE{1'b0}};
       #1
	 for (k = 0; k < TREE_HEIGHT-1; k++) begin
	     if (matchBool[TREE_HEIGHT - 2 - k] == 1'b1) begin
		 stageStrideIndex[TREE_HEIGHT - 1 - k] <= stageStrideIndex[TREE_HEIGHT - 1 - k - 1] + 1;
	     end else begin
		 stageStrideIndex[TREE_HEIGHT - 1 - k] <= stageStrideIndex[TREE_HEIGHT - 1 - k - 1];
	     end
	 end
   end // always @ (posedge clk)
endmodule // top

