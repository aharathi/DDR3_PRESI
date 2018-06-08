////


class ddr3_mode_reg0_test extends ddr3_base_test;
`uvm_component_utils(ddr3_mode_reg0_test)


	string m_name = "ddr3_mode_reg0_test";

	ddr3_set_reg0_seq m_reg0_seq;


	function new (string name=m_name,uvm_component parent =null);
		super.new(name,parent);
	endfunction

	task run_phase(uvm_phase phase);
	begin
		m_reg0_seq = ddr3_set_reg0_seq::type_id::create("m_reg0_seq");
	phase.raise_objection(this,$sformatf("%s:Starting m_reg0_seq",m_name));
		m_reg0_seq.start(m_env.m_sequencer);
	phase.drop_objection(this,$sformatf("%s:Done driving the sequence",m_name));	
		
	end 
	endtask
	
endclass
