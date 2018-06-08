//////////////////////////////////////////////////////////////////////////////
//
//
//
//
//
///////////////////////////////////////////////////////////////////////////////////////////////


   `include "1024Mb_ddr3_parameters.vh"
   `include "uvm_macros.svh"
   import uvm_pkg::*;
interface ddr3_interface();

   
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
real tck;
wire ck_n = ~ck;

string m_name = "DDR3_INTERFACE";


initial
begin
	$timeformat (-9,3," ns",1);
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
	`uvm_info(m_name,"STARTING DDR3 RESET",UVM_HIGH)
    rst_n   <= 1'b0;
    cke     <= 1'b0;
    cs_n    <= 1'b1;
    odt_out <= 1'b0;
    //#10000;
    #200000000;
    @(negedge ck); 
    rst_n = 1'b1;
	`uvm_info(m_name,"ENDING DDR3 RESET",UVM_HIGH)
    //#10000;
    #500000000;
    @(negedge ck); 
    nop(TXPR/tck +1);
end
endtask

// load mode
task load_mode(input [BA_BITS-1:0] bank, input [ADDR_BITS-1:0] bus_addr);
    begin
        `uvm_info(m_name,"STARTING LOAD OPERATION",UVM_HIGH)
//        case (bank)
//            0:mode_reg0 = addr;
//            1:mode_reg1 = addr;
//            2:mode_reg2 = addr;
//        endcase

        cke   <= 1'b1;
        cs_n  <= 1'b0;
        ras_n <= 1'b0; 
        cas_n <= 1'b0;
        we_n  <= 1'b0;
        ba    <= bank;
        addr     <= bus_addr;
        @(negedge ck);
        nop(10);
        `uvm_info(m_name,"ENDING LOAD OPERATION",UVM_HIGH)
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
endtask

//precharge

task precharge (input [BA_BITS-1:0] bank,input [ROW_BITS-1:0] ap);
    begin
	`uvm_info(m_name,"STARTING DDR3 PRECHARGE",UVM_HIGH)
	if (ap[10] == 1) `uvm_info(m_name,"All Bank Precharge",UVM_HIGH) else `uvm_info(m_name,$sformatf("Precharging Bank %0d",bank),UVM_HIGH)
        cke   <= 1'b1;
        cs_n  <= 1'b0;
        ras_n <= 1'b0; 
        cas_n <= 1'b1;
        we_n  <= 1'b0;
        ba    <= bank;
        addr    <= ap;
        @(negedge ck);
    end
endtask

//activate 

task activate( input [BA_BITS-1:0] bank,input [ROW_BITS-1:0] row);
begin
    cke   <= 1'b1;
    cs_n  <= 1'b0;
    ras_n <= 1'b0; 
    cas_n <= 1'b1;
    we_n  <= 1'b1;
    ba    <= bank;
    addr     <= row;
    @(negedge ck);
end
endtask

// zq calibration

task zq_calibration(input long);
begin
    cke   <= 1'b1;
    cs_n  <= 1'b0;
    ras_n <= 1'b1; 
    cas_n <= 1'b1;
    we_n  <= 1'b0;
    ba    <= 0;
    addr    <= long << 10;
    @(negedge ck);
end
endtask

//nop

task nop(input [31:0] count);
begin
	`uvm_info(m_name,"STARTING DDR3 NO OPERATION",UVM_HIGH)
    cke   <= 1'b1;
    cs_n  <= 1'b0;
    ras_n <= 1'b1; 
    cas_n <= 1'b1;
    we_n  <= 1'b1;
    repeat(count)
    @(negedge ck);
	`uvm_info(m_name,"ENDING DDR3 NO OPERATION",UVM_HIGH)
end
endtask

// task write;
//     input   [BA_BITS-1:0] bank;
//     input  [COL_BITS-1:0] col;
//     input                 ap; //Auto Precharge
//     input                 bc; //Burst Chop  
//     input [8*DM_BITS-1:0] dm;
//     input [8*DQ_BITS-1:0] dq;
//     reg   [ADDR_BITS-1:0] atemp [2:0];
//     integer i;
//     begin
//         cke   <= 1'b1;
//         cs_n  <= 1'b0;
//         ras_n <= 1'b1;
//         cas_n <= 1'b0;
//         we_n  <= 1'b0;
//         ba    <= bank;

//         atemp[0] = col & 10'h3ff;         //a[ 9: 0] = COL[ 9: 0]
//         atemp[1] = ((col>>10) & 1'h1)<<11;//a[   11] = COL[   10]
//         atemp[2] = (col>>11)<<13;         //a[ N:13] = COL[ N:11]
//         addr     <= atemp[0] | atemp[1] | atemp[2] | (ap<<10) | (bc<<12);

//         casex ({bc, mode_reg0[1:0]})
//             3'bx00, 3'b101:bl=8;
//             3'bx1x, 3'b001:bl=4;
//         endcase

//         dqs_en <= #(wl*tck-tck/2) 1'b1;
//         dqs_out <= #(wl*tck-tck/2) {DQS_BITS{1'b1}};
//         for (i=0; i<=bl; i=i+1) begin
//             dqs_en <= #(wl*tck + i*tck/2) 1'b1;
//             if (i%2 == 0) begin
//                 dqs_out <= #(wl*tck + i*tck/2) {DQS_BITS{1'b0}};
//             end else begin
//                 dqs_out <= #(wl*tck + i*tck/2) {DQS_BITS{1'b1}};
//             end

//             dq_en  <= #(wl*tck + i*tck/2 + tck/4) 1'b1;
//             dm_out <= #(wl*tck + i*tck/2 + tck/4) dm>>i*DM_BITS;
//             dq_out <= #(wl*tck + i*tck/2 + tck/4) dq>>i*DQ_BITS;
//         end
//         dqs_en <= #(wl*tck + bl*tck/2 + tck/2) 1'b0;
//         dq_en  <= #(wl*tck + bl*tck/2 + tck/4) 1'b0;
//         @(negedge ck);  
//     end
// endtask


// WRITE : begin
//     en        = 1'b1;
//     max_count = T_CL-1+3;
//     if(v_count=='d0) begin
//         cont_if_mem.we_n  = 1'b0;											////	WRITE STATE BANK and ADDRESS BIFURCATION  with cas_n= 0
//         cont_if_mem.ba    = s_addr[12:10];
//         cont_if_mem.addr  = {s_addr[9:3],3'b0};
//         cont_if_mem.cas_n = 1'b0;
    

endinterface
