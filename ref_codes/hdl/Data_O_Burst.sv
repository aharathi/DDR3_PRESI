/////////////////////////////////////////////////////////////////////////////////////
// Data_O_Burst.sv
//
// Author:			Sai Teja, Suraj Avinash, Tejas Chavan
// Version:			1.1
// Last modified:	11-Mar-2018
//
//  Design Implemented on the DUT driving the dqs and dqs_n 
//  
//////////////////////////////////////////////////////////////////////////////////////



module read_burst #(parameter BW = 8)(input logic clock,
				  input logic [BW-1:0] data_in,
				  output logic [BW*2-1:0] out);

logic [BW-1:0] temp1;								// Temporary variable to store output data
logic [BW-1:0] temp2;
logic valid_out;								// Data assigned to CPU only if valid_out is set

always @ (posedge clock) begin
	temp2 <= data_in;
end
                                             // Drive of data on posedge and negedge i,e on dqs and dqs_n
always @ (negedge clock) begin
	temp1 <= data_in;
end

always_ff @ (negedge clock) begin
	out <= {temp2, temp1};
end

endmodule // read_burst