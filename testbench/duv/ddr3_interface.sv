//////////////////////////////////////////////////////////////////////////////
//
//
//
//
//
///////////////////////////////////////////////////////////////////////////////////////////////


interface ddr3_interface();

`ifdef den1024Mb
   `include "1024Mb_ddr_parameters.vh"
`else 
   ERROR: specify component density using +define+den____Mb.
`endif
   
bit   ck;
bit   rst_n;
bit   cke;
bit   cs_n;
bit   ras_n;
bit   cas_n;
bit   we_n;
bit   odt;
bit   odt_out;
bit   [BA_BITS-1:0] ba;
bit   [ADDR_BITS-1:0] addr;
tri   [DM_BITS-1:0] dm_tdqs; 
tri   [DQ_BITS-1:0] dq; 
tri   [DQS_BITS-1:0] dqs_n; 
tri   [DQS_BITS-1:0] dqs; 
tri   [DQS_BITS-1:0] tdqs_n; 

wire ck_n = ~ck;

initial
begin
    tck = TCK_MIN;
    ck  = 1'b1;
end

// clock generator
always @(posedge ck) 
begin
    ck <= #(tck/2) 1'b0;
    ck <= #(tck) 1'b1;
end

// power up	
task power_up;
begin
    rst_n   <= 1'b0;
    cke     <= 1'b0;
    cs_n    <= 1'b1;
    odt_out <= 1'b0;
    #(10000);
    @(negedge ck) rst_n = 1'b1;
    #(10000)
    @(negedge ck) nop(TXPR/tck +1);
end
endtask

// load mode
task load mode;
    input [BA_BITS-1:0] bank;
    input [ADDR_BITS-1:0] addr;
    begin
        case (bank)
            0:mode_reg0 = addr;
            1:mode_reg1 = addr;
            2:mode_reg2 = addr;
        endcase

        cke   <= 1'b1;
        cs_n  <= 1'b0;
        ras_n <= 1'b0; 
        cas_n <= 1'b0;
        we_n  <= 1'b0;
        ba    <= bank;
        a     <= addr;
        @(negedge ck);
    
    end
endtask

// refresh
task refresh;
begin
    cke   <= 1'b1;
    cs_n  <= 1'b0;
    ras_n <= 1'b0; 
    cas_n <= 1'b0;
    we_n  <= 1'b1;
    @(negedge ck);
end

//precharge

task precharge;
    input [BA_BITS-1:0] bank;
    input ap;
    begin
        cke   <= 1'b1;
        cs_n  <= 1'b0;
        ras_n <= 1'b0; 
        cas_n <= 1'b1;
        we_n  <= 1'b0;
        ba    <= bank;
        a     <= (ap<<10);
        @(negedge ck);
    end
endtask

//activate 

task actitvate;
input [BA_BITS-1:0] bank;
input [ROW_BITS-1:0] row;
begin
    cke   <= 1'b1;
    cs_n  <= 1'b0;
    ras_n <= 1'b0; 
    cas_n <= 1'b1;
    we_n  <= 1'b1;
    ba    <= bank;
    a     <= row;
    @(negedge ck);
end
endtask

// zq calibration

task zq_calibration;
input long;
begin
    cke   <= 1'b1;
    cs_n  <= 1'b0;
    ras_n <= 1'b1; 
    cas_n <= 1'b1;
    we_n  <= 1'b0;
    ba    <= 0;
    a     <= long << 10;
    @(negedge ck);
end
endtask

//nop

task nop;
input [31:0] count;
begin
    cke   <= 1'b1;
    cs_n  <= 1'b0;
    ras_n <= 1'b1; 
    cas_n <= 1'b1;
    we_n  <= 1'b1;
    repeat(count)
    @(negedge ck);
end
endtask

endinterface
