`timescale 1ns/1ps

// Parameters for generating names of data files easy
parameter GENERIC_FILENAME = "C:\\Users\\Suyash\\Dropbox\\backup\\ndn_implementation\\em\\data\\level";
parameter DATA_FILE_EXT = ".dat";
parameter DATA_FILE_LP = "_lp";
parameter DATA_FILE_RP = "_rp";
parameter STRIDE_INDEX_SIZE = 3;


(*DONT_TOUCH = "true"*)module top
  #(
    parameter TREE_HEIGHT =  100,
    parameter WORD_SIZE = 32,
    parameter POINTER_SIZE = 6,
    parameter MAX_NAME_LENGTH = 8 // max length of name in words
    )(
      input 				      clk,
      input [MAX_NAME_LENGTH * WORD_SIZE - 1 : 0] 	      name_in,
      
      // Inputs for forcing vivado to use RAMS for memories
      input wire 			      fake_word_in,
      input wire 			      fake_add_in,
      input wire 			      fake_input_write_address,
      // --------------------------------------------------
      
      output wire 			      dummy_output_0,
      output wire 			      dummy_output_1,
      output wire 			      dummy_output_2,
      output wire                 dummy_output_3,
      output wire                 dummy_output_4,
  
      output wire [POINTER_SIZE - 1 : 0]      debug_address_pipeline_reg_0
      );
   reg [WORD_SIZE - 1 : 0] 		      next_name_in [MAX_NAME_LENGTH - 1 : 0];
   wire 				      matchBool [TREE_HEIGHT - 1 : 0];
   
   genvar name_gv;
   generate
      for (name_gv = 0; name_gv < MAX_NAME_LENGTH; name_gv++) begin
         always @(posedge clk) begin
            next_name_in[MAX_NAME_LENGTH - name_gv - 1] <= name_in[(name_gv+1)*WORD_SIZE-1:(name_gv)*WORD_SIZE];
         end
      end
   endgenerate
    
   assign dummy_output_0 = matchBool[0];
   assign dummy_output_1 = matchBool[1];
   assign dummy_output_2 = matchBool[2];
   assign dummy_output_3 = matchBool[3];
   assign dummy_output_4 = matchBool[4];
   
   assign debug_address_pipeline_reg_0 = addressPipelineReg[1];
   
   
   
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
       for (levelId = 0; levelId < TREE_HEIGHT & levelId!=4; levelId++) begin
	   level 
		      #(
			.MEM_SIZE(16*1024/*1<<levelId*/),
			.LEVEL_ID(levelId)
			) level_instance 
		      (
		       .clk_in(clk),
		       .address_in(addressPipelineReg[levelId]),
		       .lookup_cont_in(wordsPiplineReg[levelId][stageStrideIndex[levelId]]),
		       .next_lookup_cont_in(wordsPiplineReg[levelId][stageStrideIndex[levelId]+1]),
		       // Inputs for forcing vivado to use RAMS for memories
		       .fake_word_in(fake_word_in),
		       .fake_add_in(fake_add_in),
		       .fake_input_write_address(fake_input_write_address),
		       // --------------------------------------------------
		       
		       .word_mem_loc_read(word_mem_loc_read[levelId]),
		       .next_pointer_out(addressPipelineOut[levelId]),
		       .is_match_out(matchBool[levelId]),
		       .no_child_out(noChildBool[levelId])
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
           .address_in(addressPipelineReg[4]),
           .lookup_cont_in(wordsPiplineReg[4][stageStrideIndex[4]]),
           .next_lookup_cont_in(wordsPiplineReg[4][stageStrideIndex[4]+1]),
           // Inputs for forcing vivado to use RAMS for memories
           .fake_word_in(fake_word_in),
           .fake_add_in(fake_add_in),
           .fake_input_write_address(fake_input_write_address),
           // --------------------------------------------------
           
           .word_mem_loc_read(word_mem_loc_read[4]),
           .next_pointer_out(addressPipelineOut[4]),
           .is_match_out(matchBool[4]),
           .no_child_out(noChildBool[4])
           );
           
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

