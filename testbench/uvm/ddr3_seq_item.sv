//ddr3 seq item 

class ddr3_seq_item extends uvm_sequence_item;

	`uvm_object_utils(ddr3_seq_item)


	command_t CMD;
	rand data_t data_proc [BURST_LEN];
	cfg_mode_reg_t mode_cfg;
	rand proc_addr_t addr_proc;
	
	row_t row_addr;
	bank_t bank_sel;
	column_t col_addr;


	string m_name = "DDR3_SEQ_ITEM";

	function new (string name = m_name);
		super.new(name);
	endfunction

	constraint data_c { foreach (data_proc[i]) data_proc[i] inside {[1:8]}; }
	constraint addr_c { addr_proc inside {[1:100]}; }

	function string conv_to_str();
		conv_to_str = $sformatf("%s:COMMAND:%s,DATA:%p,MODE_CFG:%b,ADDR:%0h",m_name,CMD,data_proc,mode_cfg,addr_proc);
	endfunction 
	
		


endclass
