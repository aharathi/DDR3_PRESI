/////////////////////////////////////////////////////////////////////////////////////
// counter.sv
//
// Author:			Sai Teja, Suraj Avinash, Tejas , Tejas Chavan
// Version:			1.1
// Last modified:	11-Mar-2018
//
//  A simple counter which will be implemented in the design
//  
//////////////////////////////////////////////////////////////////////////////////////


module counter (
	input  logic       clock    ,
	input  logic       reset    ,
	input  logic       en,
	input  logic [31:0] max_count,								
	output bit         done     ,
	output logic [31:0] count
);

	always@(posedge clock) begin
		if((reset) | (count==max_count-1))
			count <= 0;                                        // Increment the count till the max_count-1 is reached
		else if(en)
			count <= count+1;
	end

	assign done = (count==max_count-1);                        // assert done when count reaches max_count-1

endmodule
