
//////////////////////////////////////////////////////////////////////////////
// interface.sv -  INTERFACE DECLARATION: COMMON BETWEEN DUT AND HVL
//
// Author:			Vadiraja , Jyothsna , Ajna
// Version:			1.1
// Last modified:	15-Mar-2018
//
// Module contains the definitions of signals required between the Memory Controller 
// and Memory and also with the CPU and Controller
/////////////////////////////////////////////////////////////////////////////


//  Package containing the parameterized definitions of TIMING and WIDTHS 
import DDR3MemPkg::* ;

//Interface declaration of the signals which are driven between CPU , MEMORY and MEMORY CONTROLLER

interface mem_if(input logic i_cpu_ck);	
	logic   rst_n;								//Reset: When asserted , makes the execution to stop
    logic   ck;									//clock for dq strobe
    logic   ck_n;						    	//clock neg-edge for dq_n strobe
    logic   cke;								 // clock enable: When 1, clock generation begins
    logic   cs_n;								//Chip Select: when asserted , selects the particular chip to be READ from / WRITTEN to
    logic   ras_n;								//Row Address Strobe: asserted high or low for READ/WRITE
    logic   cas_n;								//Column Address Strobe: asserted high or low for READ/WRITE
    logic   we_n;								// Write_enable to be asserted high when WRITE begins
    tri   [1-1:0]   dm_tdqs;					//Data Mask signal for the data strobes
    logic   [BA_BITS-1:0]   ba;					//BANKS in the DDR3
    logic   [ADDR_BITS-1:0] addr;				//Memory Address
    tri   [DQ_BITS-1:0]   dq;					//DQ pin of the DDR3 Controller
    tri   [1-1:0]  dqs;							//Data Strobe: latch the data for READ/ WRITE
    tri   [1-1:0]  dqs_n;						//Data Strobe low: latch the data at negedge 
    logic  [1-1:0]  tdqs_n;						// Dq Signal
    logic   odt;								//ODT: ON DIE TERMINATION pin 

//======Module port for controller signals===============================================================
	modport contr_sig (
		output ck, ck_n, rst_n, cs_n, cke, ras_n, cas_n, we_n, odt, ba, addr,tdqs_n,
		inout dm_tdqs, dq, dqs, dqs_n
	);


//======Module ports for Memory===========================================================================
	modport mem_sig (
		input ck, ck_n, rst_n, cs_n, cke, ras_n, cas_n, we_n, odt,ba, addr,tdqs_n,
		inout dm_tdqs,dq, dqs, dqs_n
	);

	// COVERAGE GROUP TO WATCH VALUES OF DIFFERENT COVERPOINTS  FOR THE MEMORY CONTROLLER
covergroup cov_mem @(posedge ck);

address : coverpoint addr {
           bins A1 = {[0: 2**7]};                            // For Address to be [0:14]  and [20:27] 
           bins A2 = {[2**10 : (2**14)-1]};
          }
clk_en : coverpoint cke {
          bins off = {0};				                     // Cke level check between 0 and 1
          bins enable = {1};
          }
activate : coverpoint ras_n {
            bins off = {1};									// RAS level check between 0 and 1
            bins on = {0};
           }
rd_wr : coverpoint cas_n{
             bins rw = {0};                                 // CAS level check between 0 and 1
             bins rw_off = {1};
           }
write : coverpoint we_n {
            bins wr = {0};                                 // we_n level check between 0 and 1
            bins rd = {1};
          }
ondie : coverpoint odt {
          bins off_odt = {1};		                      // odt level check between 0 and 1
          bins on_odt = {0};
         }
bank : coverpoint ba {
        bins bks = {0, 1, 2, 3, 4, 5, 6, 7};			   // bks: BANKS to be in the range of 0 to 7
       }

c1xc2 : cross ras_n, cas_n;// Checking the values of RAS and CAS at the same time			

c3xc4 : cross cas_n, we_n;// Checking the values of CAS and WRITE_EN at the same time
	
c5xc6 : cross ras_n, we_n;// Checking the values of RAS and WRITE_EN at the same time 

c7xc8 : cross ondie, cas_n;// Checking the values of ODT and CAS at the same time 

endgroup

cov_mem cov_mem_inst = new();      //Instance creation of cover group defined for memory

endinterface : mem_if

///////////////////////// Interface for Driver///////////////////////////


// Interface declaration of the signals which are driven between CPU , MEMORY and MEMORY CONTROLLER 

interface mem_intf(input logic i_cpu_ck);
   
  	//logic	     				i_cpu_ck;		// Clock from TB
	logic	     				i_cpu_reset;	// Reset passed to Controller from TB
	logic [ADDR_MCTRL-1:0]		i_cpu_addr;  	// Cpu Addr
	logic 	     				i_cpu_cmd;		// Cpu command READ or WRITE
	logic [8*DQ_BITS-1:0]		i_cpu_wr_data;	// Cpu Write Data 
	logic 	     				i_cpu_valid;	// Valid is set when passing CPU addr and command
	logic 	     				i_cpu_enable;	// Chip Select
	logic [BURST_L-1:0]  		i_cpu_dm;		// Data Mask - One HOT
	logic [$clog2(BURST_L):0]	i_cpu_burst;	// Define Burst Length - wont be used for now
	logic [8*DQ_BITS-1:0]		o_cpu_rd_data;	// Cpu data Read
	logic	     				o_cpu_data_rdy;	// Cpu data Read	
	logic 						o_cpu_rd_data_valid; // Signal for valid data sent to CPU   

// COVERAGE GROUP TO WATCH VALUES OF DIFFERENT COVERPOINTS FOR THE CPU
covergroup cov_cpu @(posedge i_cpu_ck);

cpu_addr : coverpoint i_cpu_addr {
           bins A1 = {[0: 2**4]};
           bins A2 = {[2**7: ((2**14)-1)]};                          //Cover point for the Address coming out from the CPU
           bins A3 = {[2**17 : 2**20]};
           bins A4 = {[2**21 : (2**24)-1]};
          }

cpu_cmd : coverpoint i_cpu_cmd {
          bins read = {0};										    //Cover point to check it to be either READ / WRITE
          bins write = {1};
          }
cpu_valid : coverpoint i_cpu_valid {
            bins off = {0};											//Cover point to check VALID -  1 or 0
            bins on = {1};
           }
cpu_rdy : coverpoint o_cpu_data_rdy {
          bins rdy_on = {1};									   //Cover point to check CPU_DATA_RDY -  1 or 0
          bins rdy_off = {0};
          }
cpu_rd_valid : coverpoint o_cpu_rd_data_valid {
               bins rd_valid = {1};		                          //Cover point to check CPU_RD_DATA_VALID - 1 or 0
               bins rd_off = {0};
              }
c1xc2 : cross cpu_cmd, cpu_valid;// Checking the values of cpu_cmd and cpu_valid at the same time								

c3xc4 : cross cpu_rdy, cpu_cmd;// Checking the values of cpu_rdy and cpu_cmd at the same time	

c5xc6 : cross cpu_valid, cpu_rdy;// Checking the values of cpu_valid and cpu_rdy at the same time	

c7xc8 : cross cpu_addr, cpu_valid;// Checking the values of cpu_addr and cpu_valid at the same time	

endgroup

cov_cpu cov_cpu_inst = new();	  //Instance creation of cover group defined for CPU

  
//============= Module ports for Memory Controller=====================  // DEFINING THE MEMORY CONTROLLER INPUT AND OUTPUT PORTS
  modport MemController (
		input i_cpu_ck,			//Clock from TB
		input 	i_cpu_reset,    //Reset : when asserted the Controller RESETS
		input 	i_cpu_addr,		//Address request to WRITE/READ from CPU
		input 	i_cpu_cmd,		//Command from the CPU to the Controller to perform READ/WRITE 
		input 	i_cpu_wr_data,  //Command from the CPU to Write Data
		input 	i_cpu_valid,	//Command VALID from CPU
		input 	i_cpu_enable,   //Command ENABLE from the CPU
		input 	i_cpu_dm,       //Command DATAMASK from CPU
		input 	i_cpu_burst,     //Command BURST from CPU
		output  o_cpu_rd_data,	 // READ_DATA from the CONTROLLER to MEMORY
		output  o_cpu_data_rdy,	 //DATA_RDY from the CONTROLLER to MEMORY
		output 	o_cpu_rd_data_valid);  //DATA_READ_VALID from CONTROLLER to MEMORY

int count;  // Number of transactions to be performed 
  
  
 // Task Reset : called in the driver , initially once to clear the previous transaction and  later on when required
task Reset();
		@(posedge i_cpu_ck);                                                                   
		$display("--------- [DRIVER] Reset Started ---------");
		i_cpu_reset = 1;
		i_cpu_valid = 0;                 //i_cpu_reset , i_cpu_valid and i_cpu_enable = 100 in RESET , no VALID or ENABLE signals sent
		i_cpu_enable= 0;
		@(posedge i_cpu_ck);
		i_cpu_reset = 0;
		i_cpu_enable = 1;                //After RESET, after a clock edge delay, ENABLE is asserted high to start with theh functionality of READ/WRITE
		$display("--------- [DRIVER] Reset Ended---------");
endtask

// Task Write:  called in the driver to begin WRITE
task Write(logic [ADDR_MCTRL-1:0] address, logic [8*DQ_BITS-1:0] write_data);
	@(posedge i_cpu_ck);
		wait (o_cpu_data_rdy);			//After a clock edge delay, after the WRITE_EN is high, WAIT for the o_cpu_data_rdy to begin WRITE
		@(posedge i_cpu_ck);
		i_cpu_valid=1'b1;  			   //After a clock edge delay, i_cpu_valid to be 1 and i_cpu_cmd to be 1 to indicate WRITE 
		i_cpu_cmd=1'b1;
		if (i_cpu_valid && i_cpu_cmd) begin												 				
				i_cpu_addr=address;   // When both VALID AND CMD are high, address and data are latched on to the lines of i_cpu_addr and i_cpu_wr_data
				i_cpu_wr_data=write_data;
		end
		@(posedge i_cpu_ck);
		i_cpu_valid=0;			 // After WRITE ,assert VALID to be 0 
endtask

// Task Read:  called in the driver to begin READ
task Read(logic [ADDR_MCTRL-1:0] address, output logic [8*DQ_BITS-1:0] read_data );
	@(posedge i_cpu_ck);
		wait(o_cpu_data_rdy);		   								//After a clock edge delay, WAIT for the o_cpu_data_rdy to begin WRITE
		@(posedge i_cpu_ck);
		i_cpu_valid=1'b1; 								            //After a clock edge delay, i_cpu_valid to be 1 and i_cpu_cmd to be 0 to indicate READ
		i_cpu_cmd=1'b0;
		if (i_cpu_valid && ~i_cpu_cmd) begin										
				i_cpu_addr=address;         						// When both VALID AND CMD are 1 and 0, address is latched on to the lines of i_cpu_addr 
				@(posedge i_cpu_ck);     
				i_cpu_valid=0;             							// assert VALID to be 0   ,indicate address sent to DUT  
				wait(o_cpu_rd_data_valid);							// Wait for a valid signal from the DUT to latch the data.
				read_data = o_cpu_rd_data;   						//  o_cpu_rd_data latched to read_data
				end
		
endtask


// Task Run:  Called in the driver to perform combinational WRITE and READ from the TESTBENCH perspective
task run(logic valid, logic cmd, logic [ADDR_MCTRL-1:0] address, logic [8*DQ_BITS-1:0] wr_data, output logic [8*DQ_BITS-1:0] rd_data);
		$display("Number of random transactions=%d", count++);
		@(posedge i_cpu_ck);
		wait (o_cpu_data_rdy);		                                       	// Wait for the DUT to send a ready signal to begin sending transactions
																			// from testbench to DUT					
		@(posedge i_cpu_ck);
		if(valid) begin															
		@(posedge i_cpu_ck);
		i_cpu_valid=valid;  												// Drive the VALID and CMD signals from the testbench environment
		i_cpu_cmd=cmd;														
		if (valid && cmd) begin												 				
				i_cpu_addr=address;
				i_cpu_wr_data=wr_data;                              		// WRITE when VALID and CMD are 1
				@(posedge i_cpu_ck);
				i_cpu_valid=0;
				end
		
		if (valid && ~cmd) begin							    			
				i_cpu_addr=address;
				@(posedge i_cpu_ck);
				i_cpu_valid=0;                                 				// READ when VALID and CMD are 1 & 0
				@(posedge o_cpu_rd_data_valid);								// Wait for a valid signal from the DUT to latch the data.
				rd_data = o_cpu_rd_data;          				
				end
		end
endtask

endinterface : mem_intf





