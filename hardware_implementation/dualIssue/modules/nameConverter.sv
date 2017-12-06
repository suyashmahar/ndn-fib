`define NULL 0
`define DEFAULT_CHAR 8'h00

`timescale 1ns/1ps

parameter WORD_SIZE = 32;
parameter POINTER_SIZE = 6;
parameter MAX_NAME_LENGTH = 8;
parameter STRIDE_SIZE = 8;
parameter CHAR_SIZE = 8;

/*
 Converts ASCII name of fixed length to strides of certain maximum
 length for NDN processing. Uses psuedo code define in the paper
 */

module nameConverter
  (
   input 			  clk,
   input 			  dataValid,
   input [CHAR_SIZE - 1:0] 	  inputChar,

   output reg [STRIDE_SIZE -1 :0] strideCollection [WORD_SIZE/STRIDE_SIZE - 1:0][CHAR_SIZE - 1 : 0]
   );

   integer curLen;
   integer strideCount;
   integer strideCollecCounter;
   integer accumulatorCounter;

   integer 		   l_i, l_j; // Loop variables
   initial begin
       curLen = 0;
       strideCount = 0;
       strideCollecCounter = 0;
       accumulatorCounter = 0;
       
       // Fill strideCollection with its default value
       for (l_i = 0; l_i < STRIDE_SIZE; l_i++) begin
	   for (l_j = 0; l_j < WORD_SIZE/STRIDE_SIZE; l_j++) begin
	       strideCollection[l_i][l_j] = `DEFAULT_CHAR;
	   end
       end
       
   end
   
   always @(posedge clk) begin
       // Read data at each posedge and write them to output register
       if ((curLen >= STRIDE_SIZE) || (inputChar == "/")) begin
	   strideCount++;	// strideCount++
	   curLen = 1;		// curLen <- 1

	   // strideCollection.push_back(accumulator)
	   strideCollecCounter++; 
	   accumulatorCounter = 0;

	   // accumulator <- a
	   strideCollection[strideCollecCounter][accumulatorCounter]
	     = inputChar;
	   accumulatorCounter++;
       end else begin // if ((curLen >= STRIDE_SIZE) || (inputChar == "/"))
	   curLen++;

	   // accumulator <- {accumulator, a};
	   strideCollection[strideCollecCounter][accumulatorCounter]
	     = inputChar;
	   accumulatorCounter++;
       end // else: !if((curLen >= STRIDE_SIZE) || (inputChar == "/"))
   end // always @ (posedge clk)
endmodule // nameConverter
