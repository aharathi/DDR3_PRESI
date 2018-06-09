////////////////////////////////////////////////////////////////////////////
//	ddr3_set_all_reg_seq.sv - Setting the all the reg mode and reset sequence 
//                    
//	Author:		Ashwin Harathi, Kirtan Mehta, Mohammad Suheb Zameer
///////////////////////////////////////////////////////////////////////////////

class ddr3_set_all_reg_seq extends uvm_sequence #(ddr3_seq_item);
    `uvm_object_utils(ddr3_set_all_reg_seq)

    string m_name = "DDR3_SET_ALL_REG_SEQ";
    
    ddr3_rst_seq m_rst_seq;
    ddr3_mode_reg0_seq m_mode_reg_0_seq;
    ddr3_mode_reg1_seq m_mode_reg_1_seq;
    ddr3_mode_reg2_seq m_mode_reg_2_seq;
    ddr3_mode_reg3_seq m_mode_reg_3_seq;

    function new (string name = m_name);
        super.new(name);
    endfunction


    task body;
    begin
    
        `uvm_info(m_name,"Starting mode reg 0 1 2 and 3 sequence",UVM_HIGH)
        
        m_rst_seq = ddr3_rst_seq::type_id::create("m_rst_seq");
        m_mode_reg_0_seq = ddr3_mode_reg0_seq::type_id::create("m_mode_reg_0_seq");
        m_mode_reg_1_seq = ddr3_mode_reg1_seq::type_id::create("m_mode_reg_1_seq");
        m_mode_reg_2_seq = ddr3_mode_reg2_seq::type_id::create("m_mode_reg_2_seq");
        m_mode_reg_3_seq = ddr3_mode_reg3_seq::type_id::create("m_mode_reg_3_seq");

        `uvm_info(m_name,"Starting reset sequence",UVM_HIGH)
        m_rst_seq.start(null,this);

        `uvm_info(m_name,"Starting mode reg 0 sequence",UVM_HIGH)
        m_mode_reg_0_seq.start(null,this);

        `uvm_info(m_name,"Starting mode reg 1 sequence",UVM_HIGH)
        m_mode_reg_1_seq.start(null,this);
        
        `uvm_info(m_name,"Starting mode reg 2 sequence",UVM_HIGH)
        m_mode_reg_2_seq.start(null,this);
        
        `uvm_info(m_name,"Starting mode reg 3 sequence",UVM_HIGH)
        m_mode_reg_3_seq.start(null,this);
    
    end
    endtask
    
    
endclass
