//ddr3 seq item 

class ddr3_seq_item extends uvm_sequence_item;

	`uvm_object_utils(ddr3_seq_item)


	command_t CMD;
	rand data_t data_proc [BL_MAX];
	cfg_mode_reg_t mode_cfg;
	proc_addr_t addr_proc;
	rand bit [DM_BITS-1:0] dm [BL_MAX];
	
	cfg_mode_reg_t wr_rd_cmd_addr;
	
	rand row_t row_addr;
	rand bank_t bank_sel;
	rand column_t col_addr;

	rand bit auto_pre;
	rand bit bc_bl_otf;

	u_int_t num_nop;

	


	string m_name = "DDR3_SEQ_ITEM";

	function new (string name = m_name);
		super.new(name);
	endfunction

	constraint data_c { foreach (data_proc[i]) data_proc[i] inside {[1:8]}; }
	//constraint addr_c { addr_proc inside {[1:100]}; }
	constraint row_c { row_addr inside {[1:4]}; }
	constraint bank_c { bank_sel inside {[0:7]};}
	constraint col_c { col_addr inside {[10:100]};}

	function void post_randomize();
		addr_proc = {row_addr,bank_sel,col_addr};
		wr_rd_cmd_addr = {bank_sel,1'b0,bc_bl_otf,1'b0,auto_pre,col_addr};	
	endfunction 

	function string conv_to_str();
		conv_to_str = $sformatf("%s::COMMAND:%s,DATA:%p,MODE_CFG:%b,ADDR:%h,ROW_ADDR:%h,BANK_SEL:%h,COLOMN_ADDR:%h,NUM_NOP:%0d,AP:%b,OTF:%b,WR/RD_cmd_addr:%h",m_name,CMD,data_proc,mode_cfg,addr_proc,row_addr,bank_sel,col_addr,num_nop,auto_pre,bc_bl_otf,wr_rd_cmd_addr);
	endfunction 
	
		


endclass
