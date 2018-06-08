//////////////////////////////////////////////////////////////////////////////////////////////////
//	ddr3_tb_driver.sv -  Driver takes the value from the sequencer and 
//						depending upon the sequence various controller task are performed 
//
//	Author:		Ashwin Harathi, Kirtan Mehta, Mohammad Suheb Zameer
//
/////////////////////////////////////////////////////////////////////////////////////////////////////



class ddr3_tb_driver extends uvm_driver#(ddr3_seq_item);
	`uvm_component_utils(ddr3_tb_driver)

	string m_name = "DDR3_TB_DRIVER";

	virtual ddr3_interface m_intf; 	//interface

    function new(string name = m_name, uvm_component parent = null);
	    super.new(name,parent);
    endfunction //new()

    function void build_phase(uvm_phase phase);
	    super.build_phase(phase);
 
	    assert(uvm_config_db #(virtual ddr3_interface)::get(null,"uvm_test_top","DDR3_interface",m_intf)) `uvm_info(m_name,"Got the interface in driver",UVM_HIGH)

    endfunction

	//run phase
    task run_phase(uvm_phase phase);

	    ddr3_seq_item ddr3_tran;

	    forever begin 
			
			// handshake with the sequencer to take the transaction from the sequencer
		    seq_item_port.get_next_item(ddr3_tran);
		    phase.raise_objection(this,$sformatf("%s:Got a transaction from the sequencer",m_name));
			`uvm_info(m_name,ddr3_tran.conv_to_str(),UVM_HIGH)
			case (ddr3_tran.CMD)
				
				RESET: begin				// Reset and Poer up performs the same function
					m_intf.power_up();
				end

				PRECHARGE: begin			// Precharge 
					m_intf.precharge(ddr3_tran.bank_sel,ddr3_tran.row_addr);	
					end 
				
				ZQ_CAL_L: begin				// Calibration task
					m_intf.zq_calibration(1);
				end

				MSR: begin					// set the Mode registers
					m_intf.load_mode(ddr3_tran.mode_cfg.ba, ddr3_tran.mode_cfg.bus_addr);
				end

				NOP: begin					// no operation
					m_intf.nop(10);
					$display("inside nop case in driver");
				end

				WRITE: begin				// Write operation
					m_intf.write(ddr3_tran.bank_sel, ddr3_tran.col_addr,0,0,0,ddr3_tran.row_addr);
				end

		    endcase 

		    seq_item_port.item_done();

		    phase.drop_objection(this,$sformatf("%s:Done Transfer",m_name));	// Drop the objection once completed

	    end //}

	endtask 
	
endclass //ddr3_tb_driver extends uvm_drive
