<<<<<<< HEAD

////////////////////////////////////////////////////////////////////////////
//	ddr3_all_mode_reg_test.sv - TEst to run all the modes sequences
//
//	Author:		Ashwin Harathi, Kirtan Mehta, Mohammad Suheb Zameer
//
///////////////////////////////////////////////////////////////////////////////

=======
//////////////////////////////////////////////////////////////////////////////////////////////////
//	ddr3_all_mode_reg_test.sv -  A sequence for doing Write operation 
//
//	Author:		Ashwin Harathi, Kirtan Mehta, Mohammad Suheb Zameer
//
/////////////////////////////////////////////////////////////////////////////////////////////////////
>>>>>>> a429f4291cdb6cafe2aa3542513eb7152eb20806


class ddr3_all_mode_reg_test extends ddr3_base_test;
`uvm_component_utils(ddr3_all_mode_reg_test)


	string m_name = "ddr3_all_mode_reg_test";

	ddr3_set_all_reg_seq m_all_reg_seq;


	function new (string name=m_name,uvm_component parent =null);
		super.new(name,parent);
	endfunction

	task run_phase(uvm_phase phase);
	begin
		m_all_reg_seq = ddr3_set_all_reg_seq::type_id::create("m_all_reg_seq");
		phase.raise_objection(this,$sformatf("%s:Starting m_all_reg_seq",m_name));
		`uvm_info(m_name,"Starting all mode register test ",UVM_HIGH)
		m_all_reg_seq.start(m_env.m_sequencer);
		phase.drop_objection(this,$sformatf("%s:Done driving the sequence",m_name));	
			
	end 
	endtask
	
endclass
