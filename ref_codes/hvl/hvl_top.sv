//////////////////////////////////////////////////////////////
// hvl_top.sv
//
// Author: Vadiraja M N
// Date: 03-12-2018
//
// Description:
// ------------
// The HVL top module creates a virtual interface which is    
// used to call tasks defined in the interface. The HVL top
// also instantiates the test program.
//
// References: http://www.verificationguide.com/p/systemverilog-testbench.html
//			   Booth example in $PSU_EXAMPLES
////////////////////////////////////////////////////////////////

class top;

virtual mem_intf intf;																	// Virtual interface handler
 
task set_vif (virtual mem_intf intf);													// Constructor
        this.intf = intf;
endtask

endclass
 
////////////////////////////////////////////////// HVL Top module ////////////////////////////////////
 
module hvltop;
  
  top inst;
  initial
  begin
	inst= new;
	inst.set_vif(hdltop.cpu_contr);														// Creating a virtual interface
  end
  
  //Testcase instance, interface handle is passed to test as an argument
  test t1(hdltop.cpu_contr);															// Instantiates the test program
    
endmodule