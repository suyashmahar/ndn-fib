`timescale 1ns/1ps

// Parameters for generating names of data files easy
parameter GENERIC_FILENAME = "C:\\Users\\Suyash\\Dropbox\\backup\\ndn_implementation\\em\\data\\level";
parameter DATA_FILE_EXT = ".dat";
parameter DATA_FILE_LP = "_lp";
parameter DATA_FILE_RP = "_rp";
parameter STRIDE_INDEX_SIZE = 3;


(*DONT_TOUCH = "true"*)module top
  #(
    parameter TREE_HEIGHT =  5,
    parameter WORD_SIZE = 32,
    parameter POINTER_SIZE = 6,
    parameter MAX_NAME_LENGTH = 8 // max length of name in words
    )(
      input 				      clk_in,
      input [WORD_SIZE - 1 : 0] 	      name_component_1,
      input [WORD_SIZE - 1 : 0] 	      name_component_2,
  
      // Inputs for forcing vivado to use RAMS for memories
      input wire 			      fake_word_in,
      input wire 			      fake_add_in,
      input wire 			      fake_input_write_address,
      // --------------------------------------------------
  
      output wire 			      dummy_output_0,
      output wire 			      dummy_output_1,
      output wire 			      dummy_output_2,
      output wire 			      dummy_output_3,
      output wire 			      dummy_output_4,
  
      // Outputs for debugging stride count
      output wire [STRIDE_INDEX_SIZE - 1 : 0] stageStrideIndex_0_out,
      output wire [STRIDE_INDEX_SIZE - 1 : 0] stageStrideIndex_1_out,
      output wire [STRIDE_INDEX_SIZE - 1 : 0] stageStrideIndex_2_out,
      output wire [STRIDE_INDEX_SIZE - 1 : 0] stageStrideIndex_3_out,
      //--------------------------------------

      // Debugging level memory read
      output wire [WORD_SIZE - 1 : 0] 	      word_mem_loc_read_0_out,
      output wire [WORD_SIZE - 1 : 0] 	      word_mem_loc_read_1_out,
      output wire [WORD_SIZE - 1 : 0] 	      word_mem_loc_read_2_out,
      output wire [WORD_SIZE - 1 : 0] 	      word_mem_loc_read_3_out,
      //------------------------------

      output wire 			      clk_mod,
  
      output wire [POINTER_SIZE - 1 : 0]      debug_address_pipeline_reg_0
      );

   // Pipeline 1   
   reg [WORD_SIZE - 1 : 0] 		      next_name_in_1 [MAX_NAME_LENGTH - 1 : 0];
   wire 				      matchBool_1 [TREE_HEIGHT - 1 : 0];
   
   // Pipeline 2
   reg [WORD_SIZE - 1 : 0] 		      next_name_in_2 [MAX_NAME_LENGTH - 1 : 0];
   wire 				      matchBool_2 [TREE_HEIGHT - 1 : 0];

   assign clk_mod = clk;
   
   assign dummy_output_0 = matchBool_1[0];
   assign dummy_output_1 = matchBool_1[1];
   assign dummy_output_2 = matchBool_1[2];
   assign dummy_output_3 = matchBool_1[3];
   assign dummy_output_4 = matchBool_1[4];
   
   assign debug_address_pipeline_reg_0 = addressPipelineReg_1[1];
   
   // assignement for debugging stride count
   assign stageStrideIndex_0_out = stageStrideIndex_1[0];
   assign stageStrideIndex_1_out = stageStrideIndex_1[1];
   assign stageStrideIndex_2_out = stageStrideIndex_1[2];
   assign stageStrideIndex_3_out = stageStrideIndex_1[3];
   //--------------------------------------

   // assignment statements for debugging level memory
   assign word_mem_loc_read_0_out = word_mem_loc_read_1[0];
   assign word_mem_loc_read_1_out = word_mem_loc_read_1[1];
   assign word_mem_loc_read_2_out = word_mem_loc_read_1[2];
   assign word_mem_loc_read_3_out = word_mem_loc_read_1[3];
   
   
   reg 					      clk = 0;			// Real clock for the module
   integer 				      mod_clk_counter = 0;		// Keeps count of module clock
   reg 					      flipper = 0;
   
   always @(posedge clk_in) begin
       if (mod_clk_counter == 2*MAX_NAME_LENGTH-1) begin
	   clk = ~clk;
       end else if (mod_clk_counter == MAX_NAME_LENGTH) begin
	   clk = 0;
       end
       mod_clk_counter = (mod_clk_counter + 1)%(2*MAX_NAME_LENGTH);
       flipper = ~flipper;
   end

   integer accumulator_counter = 0;

   always @(posedge flipper) begin
       // Pipeline 1
       next_name_in_1[accumulator_counter] = name_component_1;
       
       // Pipeline 2
       next_name_in_2[accumulator_counter] = name_component_2;

       accumulator_counter = (accumulator_counter+1)%MAX_NAME_LENGTH;
   end
   
   wire [STRIDE_INDEX_SIZE - 1 : 0]    stage_output_1 [TREE_HEIGHT - 1 : 0];
   wire [STRIDE_INDEX_SIZE - 1 : 0]    stage_output_2 [TREE_HEIGHT - 1 : 0];
   
   
   // Signals for module
   // Pipeline 2
   (*DONT_TOUCH = "true"*) reg [WORD_SIZE - 1 : 0] 	       wordsPiplineReg_1 [TREE_HEIGHT - 1 : 0] [MAX_NAME_LENGTH - 1 : 0];
   (*DONT_TOUCH = "true"*) reg [POINTER_SIZE - 1 : 0] 		      addressPipelineReg_1 [TREE_HEIGHT - 1 : 0];
   (*DONT_TOUCH = "true"*) reg [STRIDE_INDEX_SIZE - 1 : 0] 	      stageStrideIndex_1 [TREE_HEIGHT - 1 : 0];

   // Pipeline 2
   (*DONT_TOUCH = "true"*) reg [WORD_SIZE - 1 : 0] 	       wordsPiplineReg_2 [TREE_HEIGHT - 1 : 0] [MAX_NAME_LENGTH - 1 : 0];
   (*DONT_TOUCH = "true"*) reg [POINTER_SIZE - 1 : 0] 		      addressPipelineReg_2 [TREE_HEIGHT - 1 : 0];
   (*DONT_TOUCH = "true"*) reg [STRIDE_INDEX_SIZE - 1 : 0] 	      stageStrideIndex_2 [TREE_HEIGHT - 1 : 0];

   assign stage_output_1 = stageStrideIndex_1;
   assign stage_output_2 = stageStrideIndex_2;

   // Pipeline 1   
   wire [POINTER_SIZE - 1 : 0] 	       addressPipelineOut_1 [TREE_HEIGHT - 1 : 0];
   wire 			       noChildBool_1 [TREE_HEIGHT - 1 : 0];

   // Pipeline 2
   wire [POINTER_SIZE - 1 : 0] 	       addressPipelineOut_2 [TREE_HEIGHT - 1 : 0];
   wire 			       noChildBool_2 [TREE_HEIGHT - 1 : 0];

   wire 			       dummy_signal_inter_0;
   wire 			       dummy_signal_inter_1;
   wire 			       dummy_signal_inter_2;
   
   wire [WORD_SIZE - 1 : 0] 	       word_mem_loc_read_1 [TREE_HEIGHT - 1 : 0];
   wire [WORD_SIZE - 1 : 0] 	       word_mem_loc_read_2 [TREE_HEIGHT - 1 : 0];
   
   integer 			       dummy_loop;
   
   genvar 			       levelId;
   generate
       for (levelId = 0; levelId < TREE_HEIGHT-1; levelId++) begin
	   level 
		      #(
			.MEM_SIZE(16*1024/*1<<levelId*/),
			.LEVEL_ID(levelId)
			) level_instance 
		      (
		       .clk_in(clk),
		       
		       // Pipeline 1
		       .address_in_1(addressPipelineReg_1[levelId]),
		       .lookup_cont_in_1(wordsPiplineReg_1[levelId][stageStrideIndex_1[levelId]]),
		       .next_lookup_cont_in_1(wordsPiplineReg_1[levelId][stageStrideIndex_1[levelId]+1]),
		       
		       .word_mem_loc_read_1(word_mem_loc_read_1[levelId]),
		       .next_pointer_out_1(addressPipelineOut_1[levelId]),
		       .is_match_out_1(matchBool_1[levelId]),
		       .no_child_out_1(noChildBool_1[levelId]),
		       
		       
		       // Pipeline 2
		       .address_in_2(addressPipelineReg_2[levelId]),
		       .lookup_cont_in_2(wordsPiplineReg_2[levelId][stageStrideIndex_2[levelId]]),
		       .next_lookup_cont_in_2(wordsPiplineReg_2[levelId][stageStrideIndex_2[levelId]+1]),
		       
		       .word_mem_loc_read_2(word_mem_loc_read_2[levelId]),
		       .next_pointer_out_2(addressPipelineOut_2[levelId]),
		       .is_match_out_2(matchBool_2[levelId]),
		       .no_child_out_2(noChildBool_2[levelId]),
		       
		       // Inputs for forcing vivado to use RAMS for memories
		       .fake_word_in(fake_word_in),
		       .fake_add_in(fake_add_in),
		       .fake_input_write_address(fake_input_write_address)
		       );
       end // for (LevelId = 0; i < TREE_HEIGHT; i++)
   endgenerate
   
   
   // Generate level 4 seperately for testing BRAM
   level4 
     #(
       .MEM_SIZE(16*1024/*1<<levelId*/),
       .LEVEL_ID(4)
       ) level4_i
       (
        .clk_in(clk),
	
        .address_in_1(addressPipelineReg_1[4]),
        .lookup_cont_in_1(wordsPiplineReg_1[4][stageStrideIndex_1[4]]),
        .next_lookup_cont_in_1(wordsPiplineReg_1[4][stageStrideIndex_1[4]+1]),
        .word_mem_loc_read_1(word_mem_loc_read_1[4]),
        .next_pointer_out_1(addressPipelineOut_1[4]),
        .is_match_out_1(matchBool_1[4]),
        .no_child_out_1(noChildBool_1[4]),
	
	
        .address_in_2(addressPipelineReg_2[4]),
        .lookup_cont_in_2(wordsPiplineReg_2[4][stageStrideIndex_2[4]]),
        .next_lookup_cont_in_2(wordsPiplineReg_2[4][stageStrideIndex_2[4]+1]),
        .word_mem_loc_read_2(word_mem_loc_read_2[4]),
        .next_pointer_out_2(addressPipelineOut_2[4]),
        .is_match_out_2(matchBool_2[4]),
        .no_child_out_2(noChildBool_2[4]),
	
        
	// Inputs for forcing vivado to use RAMS for memories
        .fake_word_in(fake_word_in),
        .fake_add_in(fake_add_in),
        .fake_input_write_address(fake_input_write_address)
        // --------------------------------------------------
        
        );
   
   initial begin
      integer loop_var_0, loop_var_1;
       for (loop_var_0 = 0; loop_var_0 < TREE_HEIGHT; loop_var_0++) begin
	   addressPipelineReg_1[loop_var_0] = {POINTER_SIZE{1'b0}};
	   addressPipelineReg_2[loop_var_0] = {POINTER_SIZE{1'b0}};
       end
       
       stageStrideIndex_1[0] = {STRIDE_INDEX_SIZE{1'b0}};
       stageStrideIndex_2[0] = {STRIDE_INDEX_SIZE{1'b0}};       
   end

   // Moves data between pipeline stages in FIFO order
   integer i, j, m, n;
   always @(posedge clk) begin
       #1 
	 for (i = 0; i < MAX_NAME_LENGTH; i++) begin
	     wordsPiplineReg_1[0][i] <= next_name_in_1[i];
	     wordsPiplineReg_2[0][i] <= next_name_in_2[i];
	 end
       
       for (j = 0; j < TREE_HEIGHT - 1; j++) begin
	   for (m = 0; m < MAX_NAME_LENGTH; m++) begin
	       wordsPiplineReg_1[TREE_HEIGHT - 1 - j][m] <= wordsPiplineReg_1[TREE_HEIGHT - 1 - j - 1][m];
	       wordsPiplineReg_2[TREE_HEIGHT - 1 - j][m] <= wordsPiplineReg_2[TREE_HEIGHT - 1 - j - 1][m];
	   end
       end
   end
   
   // Moves adress between pipeline stages in FIFO order
   always @(posedge clk) begin
       #1
	 for (n = 0; n < TREE_HEIGHT - 1; n++) begin
	     addressPipelineReg_1[TREE_HEIGHT - 1 - n] <= addressPipelineOut_1[TREE_HEIGHT - 1 - n - 1];
	     addressPipelineReg_2[TREE_HEIGHT - 1 - n] <= addressPipelineOut_2[TREE_HEIGHT - 1 - n - 1];
	 end
   end
   
   // Moves adress between pipeline stages in FIFO order
   integer k;
   always @(posedge clk) begin
       stageStrideIndex_1[0] <= {STRIDE_INDEX_SIZE{1'b0}};
       stageStrideIndex_2[0] <= {STRIDE_INDEX_SIZE{1'b0}};
       
       #1
	 for (k = 0; k < TREE_HEIGHT-1; k++) begin
	     if (matchBool_1[TREE_HEIGHT - 2 - k] == 1'b1) begin
		 stageStrideIndex_1[TREE_HEIGHT - 1 - k] <= stageStrideIndex_1[TREE_HEIGHT - 1 - k - 1] + 1;
	     end else begin
		 stageStrideIndex_1[TREE_HEIGHT - 1 - k] <= stageStrideIndex_1[TREE_HEIGHT - 1 - k - 1];
	     end
	 end
       for (k = 0; k < TREE_HEIGHT-1; k++) begin
	   if (matchBool_2[TREE_HEIGHT - 2 - k] == 1'b1) begin
	       stageStrideIndex_2[TREE_HEIGHT - 1 - k] <= stageStrideIndex_2[TREE_HEIGHT - 1 - k - 1] + 1;
	   end else begin
	       stageStrideIndex_2[TREE_HEIGHT - 1 - k] <= stageStrideIndex_2[TREE_HEIGHT - 1 - k - 1];
	   end
       end
   end // always @ (posedge clk)
endmodule // top

