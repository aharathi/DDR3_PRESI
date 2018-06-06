//sequencer//


class ddr3_seqeuncer extends uvm_sequencer #(ddr3_seq_item,ddr3_seq_item);
		`uvm_component_utils(ddr3_seqeuncer)

			function new(string name = "ddr3_seqeuncer",uvm_component parent = null);
				super.new(name,parent);
			endfunction 
endclass
