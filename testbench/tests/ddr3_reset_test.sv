/// reset test


class ddr3_reset_test extends ddr3_base_test;
`uvm_component_utils(ddr3_reset_test)

string m_name = "DDR3_RESET_TEST";

ddr3_rst_seq m_reset_seq;

function new(string name = m_name,uvm_component parent = null);
	super.new(name,parent);
endfunction


task run_phase(uvm_phase phase);
begin
       m_reset_seq = ddr3_rst_seq::type_id::create("m_reset_seq");

	phase.raise_objection(this,$sformatf("%s:Starting sequence m_reset_seq",m_name));
		#100;
	m_reset_seq.start(m_env.m_sequencer);
	#100;
	phase.drop_objection(this,$sformatf("%s:Done driving the sequence",m_name));	
end 
endtask 


endclass
