//////////////////////////////////////////////////////////////////////////////////////////////////
//	ddr3_seq_item.sv -  A sequence item which iclues the signals and the commands of controller
//
//	Author:		Ashwin Harathi, Kirtan Mehta, Mohammad Suheb Zameer
//
/////////////////////////////////////////////////////////////////////////////////////////////////////


class ddr3_seq_item extends uvm_sequence_item;

	`uvm_object_utils(ddr3_seq_item)


	command_t CMD;							// controller commands
	rand data_t data_proc [BURST_LEN];		
	cfg_mode_reg_t mode_cfg;				// address and bank structure
	rand proc_addr_t addr_proc;
	
	row_t row_addr;							// row address
	bank_t bank_sel;						// bank address
	column_t col_addr;						// column address

	u_int_t num_nop;

	


	string m_name = "DDR3_SEQ_ITEM";

	function new (string name = m_name);
		super.new(name);
	endfunction																					// new 

	constraint data_c { foreach (data_proc[i]) data_proc[i] inside {[1:8]}; }		// contraints for data and address
	constraint addr_c { addr_proc inside {[1:100]}; }

	function string conv_to_str();														// function to convert into string
		conv_to_str = $sformatf("%s::COMMAND:%s,DATA:%p,MODE_CFG:%b,ADDR:%h,ROW_ADDR:%h,BANK_SEL:%h,COLOUM_ADDR:%h,NUM_NOP:%0d",m_name,CMD,data_proc,mode_cfg,addr_proc,row_addr,bank_sel,col_addr,num_nop);
	endfunction 
	

endclass
