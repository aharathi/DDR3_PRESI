/// reset sequence //

class ddr3_rst_seq extends uvm_sequence #(ddr3_seq_item);
	`uvm_object_utils(ddr3_rst_seq)

	string m_name = "DDR3_RST_SEQ";
	
	function new (string name = m_name);
		super.new(name);
	endfunction 

	task body;

	`uvm_info(m_name,"Starting RESET sequence")
		ddr3_seq_item ddr3_tran = ddr3_seq_item::type_id::create("ddr3_tran");

		start_item(ddr3_tran);
		ddr3_tran.CMD = RESET;
		finish_item(ddr3_tran);
	
	endtask 

endclass

