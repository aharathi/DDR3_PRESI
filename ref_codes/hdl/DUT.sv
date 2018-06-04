/////////////////////////////////////////////////////////////////////////////////////
// DUT.sv -  DESIGN MODULE FOR DDR3 MEMORY CONTROLLER
//
// Author:			Sai Teja, Suraj Avinash, Tejas (  Ajna , Jyothsana : Assertions)
// Version:			1.1
// Last modified:	11-Mar-2018
//
//  Design Implemented following the protocols of DDR3 Memory Controller and its Timing parameters
//  Assertions written mainly with the focus to check timing and strobe signal change
//////////////////////////////////////////////////////////////////////////////////////




//  Package containing the parameterized definitions of TIMING and WIDTHS

import DDR3MemPkg::* ;

module DDR3_Controller (
	input logic            i_cpu_ck   ,
	input logic            i_cpu_ck_ps,
	mem_intf.MemController cont_if_cpu,
	mem_if.contr_sig       cont_if_mem
);


	logic  [31:0] v_count                       ;							//v_count: burst count for WRITE  
	logic  [31:0] max_count                = 'd0;							//max_count: TIMER count
	logic  [ 0:0] rst_counter              = 'd0;							//rst_counter = for the timer
	logic         rw_flag,timer_intr;										//rw_flag to indicate 1 and 0 for WRITE and READ, timer_intr for the timer count
	logic         t_flag                        ;							//t_flag: indicating the timer count
	logic         dqs_valid                     ;							//data strobe valid signal
	bit           t_dqs_flag,t_dqsn_flag        ;							//strobe complete flag signals		
	logic  [15:0] wdata              [3:0]      ;							//Wdata signal
	logic  [15:0] rdata              [3:0]      ;							//Rdata signal
	logic  [ 7:0] t_dq_local                    ;							//dq pin signal
	logic  [15:0] wdata_local                   ;							// wdata_local: write data 
	logic  [15:0] rdata_local                   ;							// rdata_local:  read data  
	logic         en                            ;							//enable for the controller
	logic  [26:0] s_addr                        ;							
	logic  [63:0] s_data                        ;							//source address, data and valid_data_read signals
	logic         s_valid_data_read             ;
	logic  [ 7:0] temp1, temp2;											    //temp variable declarations
	logic  [63:0] s_cpu_rd_data                 ;                           //source cpu_rd_data signal
	logic  [63:0] cpu_rd_data                   ;							// cpu_rd_data signal received from the CPU
	logic         s_cpu_rd_data_valid           ;							// s_cpu_rd_data_valid signal
	logic         cpu_rd_data_valid             ;							//cpu_rd_data_valid signal
	States        state                         ;							//FSM state : READ WRITE POWERUP IDLE .. 

	assign cont_if_mem.ck   = ~i_cpu_ck;									//Clock generation for Memory Controller
	assign cont_if_mem.ck_n = i_cpu_ck;

	counter i_counter (.clock(i_cpu_ck), .reset(cont_if_cpu.i_cpu_reset), .en(en), .max_count(max_count), .done(timer_intr), .count(v_count));

// Instantiate WBurst
	WriteBurst #(8) i_WriteBurst (.clock(i_cpu_ck_ps), .data(wdata_local), .out(t_dq_local), .valid_in(s_valid_data), .valid_out(dq_valid), .reset(cont_if_cpu.i_cpu_reset));
	read_burst #(8) i_ReadBurst (.clock(i_cpu_ck_ps), .data_in(cont_if_mem.dq), .out(rdata_local));
	
	
// Instantiate RBurst
    assign s_valid_data = (state==WBURST) & (v_count>=0);								// set s_valid_data in order to send the burst to memory	(Write operation)
                                                           								// Set s_valid_data_read in order ro receive burst from memory (Read operation)


//Driving the signals o_cpu_rd_data and cpu_rd_data from the CPU to the Memory Controller 
	always_ff@(posedge i_cpu_ck)
		begin
			cont_if_cpu.o_cpu_rd_data       <= cpu_rd_data;
			cont_if_cpu.o_cpu_rd_data_valid <= s_cpu_rd_data_valid;
		end

		
//Driving the cpu_rd_data burst coming from the Controller		
	always_ff @(negedge i_cpu_ck) begin : proc_r_burst
		if(cont_if_cpu.i_cpu_reset)
			cpu_rd_data <= 0;
		else if(state==RBURST) 
			unique case (v_count)
			3       : cpu_rd_data[63:48] <= rdata_local;
			2       : cpu_rd_data[47:32] <= rdata_local;
			1       : cpu_rd_data[31:16] <= rdata_local;
			0       : cpu_rd_data[15:0] <=  rdata_local;
			default : cpu_rd_data <= 0;
		endcase
	end

// STATE TRANSITION BLOCK
	always_ff@(posedge i_cpu_ck) begin
		if(cont_if_cpu.i_cpu_reset)
			state <= POWERUP;
		else
			unique case(state)
				POWERUP : begin
					if(timer_intr)			// TXPR cycle meet to escape CKE high
						state <= ZQ_CAL;
				end

				ZQ_CAL : begin
					if(timer_intr)
						state <= CAL_DONE;
				end

				CAL_DONE : begin
					state <= MRLOAD;
				end

				MRLOAD : begin
					if(timer_intr)				// Load all MRs
						state <= IDLE;
				end

				IDLE : begin
					if(cont_if_cpu.i_cpu_valid)
						state <= ACT;                         //IDLE till i_cpu_valid = 1
				end

				ACT : begin
					if(timer_intr) begin
						if(rw_flag == 1)
							state <= WRITE;                  //ACTIVATE  for WRITE if rw_flag = 1 , else for READ
						else
							state <= READ;
					end
				end

				WRITE : begin
					if(timer_intr)
						state <= WBURST;                    //Start WBURST while the timer_intr counts
				end

				READ : begin
					if(timer_intr)
						state <= RBURST;                    //Start RBURST while the timer_intr counts
				end

				WBURST : begin
					if(timer_intr)
						state <= AUTORP;                   // Start AUTORP  while the timer_intr counts   
				end

				RBURST : begin
					if(timer_intr)
						state <= AUTORP;                   //Start AUTORP  while the timer_intr counts     
				end

				AUTORP : begin
					if(timer_intr)
						state <= DONE;                    //Start DONE  while the timer_intr counts
				end

				DONE : begin
					state <= IDLE;                         //When DONE go to IDLE
				end

				default : state <= POWERUP;            


			endcase
	end

	always_comb cont_if_cpu.o_cpu_data_rdy <= (state==IDLE);

// Output Block

	always_comb begin
		cont_if_mem.rst_n   = 1'b1;
		cont_if_mem.odt     = 1'b1;
		cont_if_mem.ras_n   = 1'b1;
		cont_if_mem.cas_n   = 1'b1;
		cont_if_mem.cs_n    = 1'b0;
		cont_if_mem.we_n    = 1'b1;
		cont_if_mem.ba      = 'b0;
		cont_if_mem.addr    = 'b0;
		cont_if_mem.cke     = 'b1;
		t_flag              = 'b0;
		en                  = 'b0;
		s_cpu_rd_data_valid = 0;
		s_cpu_rd_data       = 0;
		case(state)
			POWERUP : begin
				// RESET
				max_count         = 'd57;
				cont_if_mem.rst_n = 1'b0;
				cont_if_mem.cke   = 1'b0;
				cont_if_mem.cs_n  = 1'b1;          ///   	// POWER UP AND CLOCKING DDR CHIP
				cont_if_mem.odt   = 1'b0;
				en                = 1'b1;
				
			   if(v_count>='d5) begin
					cont_if_mem.rst_n = 1'b1;         /// Count upon reaching 5, rst and odt to be 1 and 0
					cont_if_mem.odt   = 1'b0;
				end
				
				if(v_count>='d9) begin
					cont_if_mem.cke  = 1'b1;
					cont_if_mem.odt  = 1'b1;         ///Count upon reaching 9, cke odt cs_n and odt to be 1 1 0 and 0
					cont_if_mem.cs_n = 1'b0;
					cont_if_mem.odt  = 1'b0;
				end
			end

			ZQ_CAL : begin
				max_count       = 'd1;
				en              = 1'b1;
				cont_if_mem.odt = 1'b0;
				
				if(v_count=='d0) begin
					cont_if_mem.we_n = 1'b0;                       ///// ZQ CALIBRATION PRECHARGING ALL THE BANKS
					cont_if_mem.ba   = 'd0;
					cont_if_mem.addr = 14'b00010000000000;
					cont_if_mem.odt  = 1'b0;
				end
			end

			MRLOAD : begin
				cont_if_mem.odt = 1'b0;
				max_count       = 4*T_MRD;
				en              = 1'b1;
				if(v_count=='d0) begin		// Mode Register0 with DLL Reset
					cont_if_mem.ras_n = 1'b0;
					cont_if_mem.cas_n = 1'b0;
					cont_if_mem.we_n  = 1'b0;
					cont_if_mem.ba    = 3'b011;
					cont_if_mem.addr  = 14'b0;
					cont_if_mem.odt   = 1'b0;
				end
				else if(v_count==T_MRD) begin 	// Extended Mode Register1 with DLL Enable, AL=CL-1
					cont_if_mem.ras_n = 1'b0;
					cont_if_mem.cas_n = 1'b0;
					cont_if_mem.we_n  = 1'b0;
					cont_if_mem.ba    = 3'b010;
					cont_if_mem.addr  = 14'b00000000000000;
					cont_if_mem.odt   = 1'b0;
				end
				else if(v_count==2*T_MRD) begin	// Extended Mode Register2 with DCC Disable
					cont_if_mem.ras_n = 1'b0;
					cont_if_mem.cas_n = 1'b0;
					cont_if_mem.we_n  = 1'b0;
					cont_if_mem.ba    = 3'b001;
					cont_if_mem.addr  = 14'b00000000010110;
					cont_if_mem.odt   = 1'b0;
				end
				else if(v_count==3*T_MRD) begin //// Extended Mode Register3
					cont_if_mem.ras_n = 1'b0;
					cont_if_mem.cas_n = 1'b0;
					cont_if_mem.we_n  = 1'b0;
					cont_if_mem.ba    = 3'b000;
					cont_if_mem.addr  = 14'b00010100011000;
					cont_if_mem.odt   = 1'b0;
				end
			end


			CAL_DONE : cont_if_mem.odt   = 1'b0;

			ACT : begin
				max_count = T_RCD+1;
				en        = 1'b1;
				if(v_count=='d0) begin
					cont_if_mem.ba    = s_addr[12:10];                                        ////ACTIVATE STATE BANK and ADDRESS BIFURCATION  with ras_n = 0
					cont_if_mem.addr  = s_addr[26:13];
					cont_if_mem.ras_n = 1'b0;				
				end
			end

			READ : begin
				en              = 1'b1;
				max_count       = T_CL + 4;
				cont_if_mem.odt = 1'b0;
				if(v_count=='d0) begin
					cont_if_mem.we_n  = 1'b1;
					cont_if_mem.ba    = s_addr[12:10];                                       /////READ STATE BANK and ADDRESS BIFURCATION with cas_n= 0
					cont_if_mem.addr  = {s_addr[9:3],3'b0};
					cont_if_mem.cas_n = 1'b0;
				end
			end

			WRITE : begin
				en        = 1'b1;
				max_count = T_CL-1+3;
				if(v_count=='d0) begin
					cont_if_mem.we_n  = 1'b0;											////	WRITE STATE BANK and ADDRESS BIFURCATION  with cas_n= 0
					cont_if_mem.ba    = s_addr[12:10];
					cont_if_mem.addr  = {s_addr[9:3],3'b0};
					cont_if_mem.cas_n = 1'b0;
				end
			end

			RBURST : begin
				en              = 1'b1;
				max_count       = T_RAS-T_CL-T_RCD+1+2;
				cont_if_mem.odt = 1'b0;
				if(v_count=='d3) begin
							
				s_cpu_rd_data_valid <= 1;										////RBURST STATE: TIMING CHECK and assertion ofr the odt signal to be lowduring RBURST
				end
				assert(cont_if_mem.odt == 1'b0)
				else
				$warning("ODT SIGNAL HAS NOT GONE LOW");
			end

			WBURST : begin
				rst_counter = 'd0;
				en          = 1'b1;
				max_count   = T_RAS-T_CL-T_RCD+2;
				t_dqsn_flag = 'd0;
				wdata[0]    = s_data[15:0];
				wdata[1]    = s_data[31:16];
				wdata[2]    = s_data[47:32];
				wdata[3]    = s_data[63:48];
				t_flag      = (v_count > 0);
				if(v_count=='d0)
					wdata_local = wdata[0];    								///WBURST STATE: Write with the according to the timing followed by the protocol
				else if(v_count=='d1)
					wdata_local = wdata[1];
				else if(v_count=='d2)
					wdata_local = wdata[2];
				else if(v_count=='d3)
					wdata_local = wdata[3];
			end

			AUTORP : begin
				en        = 1'b1;
				max_count = T_RP;
				if(v_count=='d0) begin
					cont_if_mem.we_n  = 1'b0;                                           ////	AUTORP STATE BANK and ADDRESS BIFURCATION  with ras_n= 0
					cont_if_mem.ras_n = 1'b0;
					cont_if_mem.ba    = s_addr[12:10];
					cont_if_mem.addr  = 1<10;
				end
			end
		endcase
	end

// TRISTATING  DQ , DQS
	assign cont_if_mem.dq      = (dq_valid) ? t_dq_local	:'bz ;
	assign cont_if_mem.dqs     = (s_valid_data) ? i_cpu_ck	:'bz ;
	assign cont_if_mem.dqs_n   = (s_valid_data) ? ~i_cpu_ck	:'bz ;
	assign cont_if_mem.dm_tdqs = (dq_valid) ? 0 		:'bz ;

// PROC FOR READ WRITE FLAG FROM CPU CMD DURING ACT STATE
	always_ff @(posedge i_cpu_ck or negedge cont_if_cpu.i_cpu_reset) begin : proc_rw
		if((cont_if_cpu.i_cpu_reset) | (state==DONE)) begin
			rw_flag <= 0;
		end else if (cont_if_cpu.i_cpu_valid & cont_if_cpu.i_cpu_cmd)
			rw_flag <= 1;;
	end

// PROC FOR ADDR_DATA_LATCH
	always_ff @(posedge i_cpu_ck) begin : proc_addr_data_lacth
		if(cont_if_cpu.i_cpu_reset) begin
			s_addr <= 0;
			s_data <= 0;
		end else if ((cont_if_cpu.i_cpu_valid) & (state==IDLE)) begin
			s_addr <= cont_if_cpu.i_cpu_addr;
			s_data <= cont_if_cpu.i_cpu_wr_data;
		end
	end
	
	/////////////////////////////////////// WRITE  ASSERTIONS //////////////////////////


// Assertion to check in WRITE, cas_n = 0 , rw_flag = 1 followed by  ras_n = 1
	
property CAS_CMD;  // done
@(posedge cont_if_cpu.i_cpu_ck) disable iff (cont_if_cpu.i_cpu_reset && cont_if_mem.cs_n == 1'b1 && cont_if_mem.cke == 1'b0) 

 (cont_if_mem.cas_n == 1'b0  && rw_flag == 1'b1) |-> (cont_if_mem.ras_n == 1'b1);
 
endproperty
cas_check : assert property(CAS_CMD)
		    else $warning("CAS signal violation"); 

//Assertion to check in WRITE,is  cas_n = 0 , rw_flag = 1 is followed by ras_n = 0 after T_RCD + 1 on the same clock edge

property CAS_CMD_1;  
@(posedge cont_if_cpu.i_cpu_ck) disable iff (cont_if_cpu.i_cpu_reset && cont_if_mem.cs_n == 1'b1 && cont_if_mem.cke == 1'b0) 
 (cont_if_mem.cas_n == 1'b0  && rw_flag == 1'b1) |-> ($past(cont_if_mem.ras_n, T_RCD+1) == 1'b0);
endproperty
cas_check_1 : assert property(CAS_CMD_1)
		    else $warning("CAS 1 signal violation"); 			

			
//Assertion to check in WRITE, if cas_n = 0 , rw_flag = 1 is followed by cas_n = 1 on the next clock edge			
			
property cas_low; 
@(posedge cont_if_cpu.i_cpu_ck) disable iff (cont_if_cpu.i_cpu_reset && cont_if_mem.cs_n == 1'b1 && cont_if_mem.cke == 1'b0)
    ($fell(cont_if_mem.cas_n) && rw_flag == 1'b1) |=> ($rose(cont_if_mem.cas_n));
endproperty
cas_time_check : assert property(cas_low)
	         else $warning("CAS signal de-assertion violation");	
			 
//Assertion to check in WRITE, if ras_n = 0 , rw_flag = 1 and we_n = 1 is followed by cas_n = 1 on the same clock edge			

property ACT_CMD;  // checking for cas and we signals 
@(posedge cont_if_cpu.i_cpu_ck) disable iff (cont_if_cpu.i_cpu_reset && cont_if_mem.cs_n == 1'b1 && cont_if_mem.cke == 1'b0)
(cont_if_mem.ras_n == 1'b0 && rw_flag == 1'b1 && cont_if_mem.we_n == 1'b1 ) |->  (cont_if_mem.cas_n == 1'b1);
endproperty
act_ast : assert property(ACT_CMD)
          else $warning("RAS signal violation");
		  
//Assertion to check in WRITE, if ras_n = 0 , rw_flag = 1 is followed by ras_n = 1 on the next clock edge			
		  
property ras_low; 
@(posedge cont_if_cpu.i_cpu_ck) disable iff (cont_if_cpu.i_cpu_reset && cont_if_mem.cs_n == 1'b1 && cont_if_mem.cke == 1'b0)
  (cont_if_mem.ras_n == 1'b0 && rw_flag == 1'b1) |=> ($rose(cont_if_mem.ras_n));
endproperty
ras_check : assert property(ras_low)
	         else $warning("RAS signal de-assertion violation");
				

//Assertion to check in WRITE, if cas_n = 0 , rw_flag = 1 is followed by the delay of T_RCD and  cas_n = 0 on the next clock edge			

 property ras_timing; 
@(posedge cont_if_cpu.i_cpu_ck) disable iff (cont_if_cpu.i_cpu_reset && cont_if_mem.cs_n == 1'b1 && cont_if_mem.cke == 1'b0)
(cont_if_mem.ras_n == 1'b0 && $rose(rw_flag) && $fell(cont_if_cpu.o_cpu_data_rdy)) |=>  ##(T_RCD) (cont_if_mem.cas_n == 1'b0 && cont_if_mem.we_n == 1'b0);
endproperty
ras_timing_check : assert property(ras_timing)
          	       else $warning("RAS timing violation");
	
//Assertion to check in WRITE, if cas_n = 0 , rw_flag = 1 is followed by  the delay of T_WL dqs_n = 1  and dqs = 0 in the next clock edge			
	
property DQS; 
@(posedge cont_if_cpu.i_cpu_ck) disable iff (cont_if_cpu.i_cpu_reset && cont_if_mem.cs_n == 1'b1 && cont_if_mem.cke == 1'b0)
//(cont_if_mem.cas_n == 1'b0 && rw_flag ==1'b1) |-> ##(T_WL+1) (cont_if_mem.dqs == 1'b0 && cont_if_mem.dqs_n == 1'b1);
(cont_if_mem.cas_n == 1'b0 && rw_flag ==1'b1) |=> ##(T_WL) (cont_if_mem.dqs == 1'b0 && cont_if_mem.dqs_n == 1'b1);
endproperty
dqs_check : assert property(DQS)
             else $warning("DQS signal violation at posedge");	
			 

//Assertion to check in WRITE, if ras_n = 0 , rw_flag rises and is followed by the delay of (T_RC+6) with o_cpu_data_rdy = 1					 

property TRC_CHECK;
@(posedge cont_if_cpu.i_cpu_ck) disable iff (cont_if_cpu.i_cpu_reset && cont_if_mem.cs_n == 1'b1 && cont_if_mem.cke == 1'b0) 
(cont_if_mem.ras_n == 1'b0 && $rose(rw_flag)) |-> ##(T_RC+6) $rose(cont_if_cpu.o_cpu_data_rdy)
endproperty
trc_check : assert property (TRC_CHECK)
	    else $warning ("row cycle time violation");



/////////////////////////////////////////////// Coverpoints ///////////////////////////



// COVERAGE GROUP TO WATCH VALUES OF DIFFERENT COVERPOINTS  FOR THE MEMORY CONTROLLER STATES

covergroup cov_fsm @(posedge i_cpu_ck);
states : coverpoint state {
          bins valid_states = {RESET,POWERUP, MRLOAD, ZQ_CAL, CAL_DONE, IDLE, ACT, READ, WRITE, WBURST, RBURST, AUTORP, DONE};
	  bins state_trans[] = (POWERUP=>ZQ_CAL),(POWERUP=>ZQ_CAL=>CAL_DONE=>MRLOAD);
          bins state_trans1 = (CAL_DONE=>MRLOAD);
          bins state_trans2 = (IDLE => ACT);
	  bins state_trans3 = (ACT => WRITE, READ);
	  bins state_trans4[] = (WRITE => WBURST), (WRITE=>WBURST => AUTORP=>DONE);
          bins state_trans5[] = (READ => RBURST), (READ => RBURST => AUTORP =>DONE) ;
          bins state_trans6[] = (WBURST => AUTORP), (WBURST => AUTORP=>DONE);
          bins state_trans7[] = (RBURST => AUTORP), (RBURST => AUTORP =>DONE); 
          bins state_trans8[] = (AUTORP => DONE),(AUTORP => DONE => IDLE);
}
        endgroup
 
cov_fsm cov_fsm_inst = new();							//Instance of the cov_fsm 

endmodule:DDR3_Controller
