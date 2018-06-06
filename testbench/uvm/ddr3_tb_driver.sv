



class ddr3_tb_driver extends uvm_driver;
	`uvm_conponent_utils(ddr3_tb_driver)

	string m_name = "DDR3_TB_DRIVER";

	virtual ddr3_interface m_intf;

    function new(string name = m_name, uvm_component parent = null);
	    super.new(name,parent);
    endfunction //new()

    function void build (uvm_phase phase);
	    super.build(phase);
 
	    assert(uvm_config_db #(virtual ddr3_interface)::get(null,"uvm_test_top","DDR3_interface",m_intf)) `uvm_info(m_name,"Got the interface in driver",UVM_HIGH)

    endfunction

    task run_phase(uvm_phase phase);

	    ddr3_seq_item ddr3_tran;

	    forever begin //{

		    seq_item_port.get_next_item(ddr3_tran);
		    phase.raise_objection(this,$sformatf("%s:Got a transaction from the sequencer",m_name));
			case (ddr3_tran.CMD)
				RESET: begin
					m_intf.power_up();
				end
				
				ZQ_CAL: begin
					m_intf.zq_calibration();
				end
		    endcase 

		    seq_item_port.item_done();

		    phase.drop_objection(this,$sformatf("%s:Done Transfer",m_name));

	    end //}

    endtask 

	


endclass //ddr3_tb_driver extends uvm_drive
