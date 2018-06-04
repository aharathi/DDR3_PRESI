/////////////////////////////////////////////////////////////////////////////////////
// Burst.sv
//
// Author:			Sai Teja, Suraj Avinash, Tejas Chavan
// Version:			1.1
// Last modified:	11-Mar-2018
//
//  ReadBurst and WriteBurst logic to drive the 4 chunks of data 
//  
//////////////////////////////////////////////////////////////////////////////////////



module WriteBurst #(parameter BW=8)(
	input  logic        clock    ,
	input  logic        reset    ,
	input  logic [2*BW-1:0] data     ,
	input  logic        valid_in ,
	output logic [BW-1:0] out      ,
	output logic        valid_out
);
	logic [BW-1:0] temp1;
	logic [BW-1:0] temp2;
	logic valid_out1,valid_out2;

	
	assign out = (clock) ? temp2 : temp1;

	assign valid_out = (valid_out1 & valid_out2);
	
	always_ff @(negedge clock) begin : proc_valid1
		if(reset) begin
			valid_out1 <= 0;
		end else begin												// Valid signal for the negedge
			valid_out1 <= valid_in;
		end
	end
	always_ff @(posedge clock) begin : proc_valid2
		if(reset) begin
			valid_out2 <= 0;
		end else begin												//Valid signal for the posedge
			valid_out2 <= valid_in;
		end
	end
	
	always @ (posedge clock) begin
		if(valid_in)
			temp1 <= data[BW-1:0];									//Lower Burst to be READ / WRITTEN first
	end
	always @ (negedge clock) begin
		if(valid_in)
			temp2 <= data[2*BW-1:BW];								//Upper Burst to be READ / WRITTEN consecutively
	end

endmodule:WriteBurst



