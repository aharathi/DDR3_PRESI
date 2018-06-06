///top testbench module ///



module ddr3_hvl_top;

import uvm_pkg::*;
import ddr3_tb_pkg::*;


initial begin


	uvm_config_db #(virtual ddr3_interface)::set(null,"uvm_test_top","DDR3_interface",ddr3_top.i);

	run_test();	
end 


endmodule 
