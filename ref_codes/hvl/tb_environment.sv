//////////////////////////////////////////////////////////////
// tb_environment.sv
//
// Author: Vadiraja M N
// Date: 03-12-2018
//
// Description:
// ------------
// The environment class instantiates tasks defined in the generator, driver and the scoreboard  
// 
// Reference: http://www.verificationguide.com/p/systemverilog-testbench.html
////////////////////////////////////////////////////////////////////////////

//////////////////////////////// Environment class /////////////////////////

package environment_p; 

import transaction_p::*;
import generator_p::*;
import driver_p::*;
import scoreboard_p::*;

class environment;
   
  
  generator gen;													// Generator instance
  driver    driv;     												// Driver instance
  scoreboard scb;													// Scoreboard instance
   
  mailbox gen2driv;													//mailbox handle's
  mailbox mon2scb;
  
   
  
  event gen_ended;													//event for synchronization between generator and test
   
  
  virtual mem_intf mem_vif;											//virtual interface
   
  
function new(virtual mem_intf mem_vif);								//constructor
    
    this.mem_vif = mem_vif;											//get the interface from test

    
    gen2driv = 	new();												//creating the mailbox (Same handle will be shared across generator and driver)
	mon2scb  = 	new();
     
    
    gen  = 	new(gen2driv,gen_ended);								//creating generator, driver and scoreboard
	driv = 	new(mem_vif,gen2driv,mon2scb);
	scb	 = 	new(mon2scb);
endfunction
 
task pre_test();
    driv.reset();				  									// call the reset task defined in the driver
	driv.directed_test();											// Directed test cases
	driv.consecutive_addresses();									// Write and Read from continuous addresses
	driv.write();   												// Single write to every bank
	driv.read();													// Read from the written addresses 
	driv.compare();													// Self check to verify written and read data
endtask
   
task test();
    fork
		gen.main();													// Generate random stimulus
		driv.drive();												// Drive the random stimulus
		scb.main();													//Verify the Results 
	join_any
endtask
   
task post_test();
    wait(gen_ended.triggered);
    wait(gen.repeat_count == driv.no_transactions);					// Wait until all packets have been extracted from the driver mailbox
	wait(gen.repeat_count == scb.no_transactions);					// Wait until all packets have been extracted from the scoreboard mailbox
endtask 
   
  //run task
task run();
    pre_test();														// Performs reset task and directed test cases
    test();															// Random stimulus generation
    post_test();													// Ensures all packets have been transmitted and verified
    $finish;
endtask
   
endclass

endpackage