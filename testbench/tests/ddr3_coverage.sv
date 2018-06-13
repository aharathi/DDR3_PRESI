class ddr3_coverage;

    ddr3_seq_item sig;    
                                                                    
    covergroup group_1;                    

        cov_cmd: coverpoint sig.CMD;                               
        
        cov_ba: coverpoint sig.mode_cfg.ba;
        cov_bus_addr: coverpoint sig.mode_cfg.bus_addr;

        cov_ba_addr: cross cov_ba cov_bus_addr;

        
    endgroup

    covergroup group_2;                      
        
        cov_row_addr: coverpoint sig.row_addr;
        cov_bank_sel: coverpoint sig.bank_sel;
        cov_col_addr: coverpoint sig.col_addr;
        
        cov_row_bank_col: cross cov_row_addr cov_bank_sel cov_col_addr;

    endgroup
    
    function new(ddr3_seq_item sig);
        this.sig = sig;
        group_1   = new();                                                // creating the object of the handle
        group_2  = new();
    endfunction 

    task cov_sample;
        group_1.sample();                                         // sampling the covergroups
        group_2.sample();
    endtask

endclass