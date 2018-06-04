//////////////////////////////////////////////////////////////
// tb_scoreboard.sv
//
// Author: Vadiraja M N
// Date: 03-13-2018
//
// Description:
// ------------
// The scoreboard class extracts packets from the scoreboard mailbox and stores the write data  
// in the local memory if its a write operation or reads the data and compares it with the 
// data in the local memory if its a read operation
//
// Reference: http://www.verificationguide.com/p/systemverilog-testbench.html
////////////////////////////////////////////////////////////////////////////

package scoreboard_p;

import DDR3MemPkg::* ;
import transaction_p::* ;


class scoreboard;
    

mailbox mon2scb;														//creating mailbox handle
   
int no_transactions;													//used to count the number of transactions
int count; 																// Number of packets sent
logic [8*DQ_BITS-1:0] mem[bit [ADDR_MCTRL-1:0]];						//array to use as local memory
   
function new(mailbox mon2scb);											//constructor
this.mon2scb = mon2scb;													//getting the mailbox handles from  environment
endfunction
   
task main;
    transaction trans;
    repeat(count) begin
		mon2scb.get(trans);												// Get one packet from the scoreboard mailbox
		if(trans.i_cpu_valid && ~trans.i_cpu_cmd) begin					// If packet indicates read operation  
			if(!mem.exists(trans.i_cpu_addr))							// Condition to check if the data being read is from an address to which data had been earlier written to 
			$display("Data read is x since the Memory location read has not been written earlier");
		else begin
			if(mem[trans.i_cpu_addr] != trans.o_cpu_rd_data)			// Verify written data with read data
			$error("[Scoreboard-FAIL] Addr = %0h,\n \t   Data :: Expected = %0h Actual = %0h",trans.i_cpu_addr,mem[trans.i_cpu_addr],trans.o_cpu_rd_data);
        else
			$display("[Scoreboard-PASS] Addr = %0h,\n \t   Data :: Expected = %0h Actual = %0h",trans.i_cpu_addr,mem[trans.i_cpu_addr],trans.o_cpu_rd_data);
		end
		end
		else if(trans.i_cpu_valid && trans.i_cpu_cmd && trans.i_cpu_addr[31:27]==5'b00000) begin			// If packet indicates read operation
																											// trans.i_cpu_addr[31:27]==5'b00000 is checked because memory controller does not accept 
																											// higher 5 bits of address
			mem[trans.i_cpu_addr] = trans.i_cpu_wr_data;			
		end
    no_transactions++;													// Increment count of packets extracted
	end
endtask   
endclass

endpackage