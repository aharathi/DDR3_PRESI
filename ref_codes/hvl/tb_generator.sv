//////////////////////////////////////////////////////////////
// tb_generator.sv
//
// Author: Vadiraja M N
// Date: 03-12-2018
//
// Description:
// ------------
// The generator class generates random packets and stores it in the generator mailbox  
// 
// Reference: http://www.verificationguide.com/p/systemverilog-testbench.html
////////////////////////////////////////////////////////////////////////////

//////////////////////// Generator Class ///////////////////////////
package generator_p;

import transaction_p::*;

class generator;

rand transaction trans;												//declaring transaction class
mailbox gen2driv;													//declaring mailbox
int  repeat_count;													//repeat count, to specify number of items to generate 
event ended;														//event
 
function new(mailbox gen2driv,event ended);							//constructor
    this.gen2driv = gen2driv;										//getting the mailbox handle from env
    this.ended    = ended;
endfunction
   
  //main task, generates(create and randomizes) the repeat_count number of transaction packets and puts into mailbox
task main();
		repeat(repeat_count) begin
		trans = new();
		if( !trans.randomize() ) $fatal("Gen:: trans randomization failed");   						// Generate random packets
		gen2driv.put(trans);																		// Store the packets in the mailbox
		end
-> ended;
endtask 

endclass

endpackage
