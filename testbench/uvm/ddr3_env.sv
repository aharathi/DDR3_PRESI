//environment//



class ddr3_env extends uvm_env;
	`uvm_component_utils(ddr3_env)

	string m_name = "DDR3_ENV";


	ddr3_tb_driver m_driver;
	ddr3_sequencer m_sequencer;


	function new(string name = m_name,uvm_component parent = null);
		super.new(name,parent);
	endfunction 

	
	function void build_phase(uvm_phase phase);

		super.build_phase(phase);

		m_driver = ddr3_tb_driver::type_id::create("m_driver",this);
		m_sequencer = ddr3_sequencer::type_id::create("m_sequencer",this);

	endfunction 

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
	endfunction 










endclass
