////////////////////////////////////////////////////////////////////////////////
//
//
//
//
//
////////////////////////////////////////////////////////////////////////////////


// top for ddr3 verification environment 
`include "ddr3_tb_pkg.sv"
`include "ddr3_seq_item"
`include "ddr3_generator.sv"
`include "ddr3_interface.sv"
`include "ddr3_tb_driver.sv"
`include "ddr3_monitor.sv"
`include "ddr3_scoreboard.sv"
`include "ddr3_env.sv"
`include "ddr3_test.sv"
`include "ddr3_agent.sv"
`include "top.sv"

module ddr3_top;

logic clk,reset;

always
begin
	forever begin
		#5 clk = ~clk;	
	end
end  	
/*
initial begin
    //clk = 0;
	//rst_n = 0;
	#5
	rst_n = 1;
    #1000;
    $stop;
end
*/
ddr3_interface i;

//test t(i);

ddr dut(
    .rst_n(i.rst_n),
    .clk(i.HRESETn),
    .ck_n(i.ck_n),
    .ras_n(i.ras_n),
    .cas_n(i.cas_n),
    .we_n(i.we_n),
    .dm_tdqs(i.dm_tdqs),
    .ba(i.ba),
    .addr(i.addr);
    .dq(i.dq);  
    .dqs(i.dqs_n);
    .dqs_n(i.dqs_n);
    .tdqs_n(i.tdqs);
    .odt(i.odt)
);


initial begin
    run_test();
end

initial begin
 	$dumpfile("dump.vcd");
 	$dumpvars;
end

endmodule


