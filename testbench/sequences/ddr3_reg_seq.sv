// reg seq //

class ddr3_mode_reg0_seq extends uvm_sequence #(ddr3_seq_item);
	`uvm_object_utils(ddr3_mode_reg0_seq)


	string m_name = "DDR3_MODE_REG0_SEQ";
	
	//ddr3_seq_item ddr3_tran;

	mode_reg_0 reg_0;


	function new(string name = m_name);
		super.new(name);
	endfunction


	task body;

		`uvm_info(m_name,"creating and sending sequence item",UVM_HIGH)
		ddr3_seq_item ddr3_tran = ddr3_seq_item::type_id::create("ddr3_tran");
		start_item(ddr3_tran);
		ddr3_tran.CMD = PRECHARGE;
		ddr3_tran.row_addr = 14'b000010000000000; //all banks active
		ddr3_tran.bank_sel = 3'b111; //will be taken as don't care 
		finsh_item(ddr3_tran);

		`uvm_info(m_name,"configuring the Mode register",UVM_HIGH)
		reg_0 = mode_reg_0::type_id::create("reg_0");
		ddr3_seq_item ddr3_tran = ddr3_seq_item::type_id::create("ddr3_tran");
		start_item(ddr3_tran);
		assert(reg_0.randomize())
		`uvm_info(m_name,reg_0.conv_to_str(),UVM_HIGH)
		ddr3_tran = MSR;
		ddr3_tran.mode_cfg = reg_0.pack();
		finish_item(ddr3_tran);



	endtask 

endclass
