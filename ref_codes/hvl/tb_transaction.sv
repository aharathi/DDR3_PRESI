//////////////////////////////////////////////////////////////
// tb_transaction.sv
//
// Author: Vadiraja M N
// Date: 03-10-2018
//
// Description:
// ------------
// The transaction class consists of all the variables to be defined in a packet  
// It contains signals to be sent and received from the DUT
// 
// Reference: http://www.verificationguide.com/p/systemverilog-testbench.html
////////////////////////////////////////////////////////////////////////////

///////////////////////// Transaction Class ////////////////////////////
package transaction_p;

import DDR3MemPkg::* ;

class transaction;

rand bit 	[ADDR_MCTRL-1:0] 	i_cpu_addr;									// Address sent to Controller
rand bit 	[8*DQ_BITS-1:0]	 	i_cpu_wr_data;								// Data to be written to the memory via the memory controller
rand logic 						i_cpu_cmd;									// 0 for read and 1 or write
rand logic 						i_cpu_valid;								// Address sent is valid if i_cpu_valid=1


logic 							i_cpu_reset;								// All operations are valid if i_cpu_reset=0 only
logic 		[8*DQ_BITS-1:0] 	o_cpu_rd_data;								// Data Read from the Memory Controller
logic                     		o_cpu_data_rdy;								// Signal received from Memory Controller upon which next packet ca be transmitted
logic 							o_cpu_rd_data_valid;						// When 1, data being sent from Controller is valid.

constraint addr{i_cpu_addr inside {[0:(2**27)-1]};}							// Constraint to randomize address within a limit which the controller accepts 
																			// generating addresses which the controller does not accept

endclass

endpackage
