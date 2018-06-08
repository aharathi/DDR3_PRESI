//mode register 2
class mode_reg_2 extends uvm_object;
`uvm_object_utils(mode_reg_2)

string m_name_2 = "MODE_REG_2";

bit  [2:0] BA = 3'b011;
rand     bit       SRT;
rand     bit       ASR;
bit       RSV =   1'b0;
rand     bit [2:0] CWL; 
rand     bit [1:0] R_TT;



function new(string name = m_name_2);
super.new(name);
endfunction


constraint SRT_c     { SRT == 1'b0;   }        // Normal
constraint ASR_c     { ASR == 1'b0;   }        // Disabled: manual 
constraint CWL_c     { CWL == 3'b000; }        // 5 CK 
constraint R_TT_c    { R_TT == 3'b001;}        // RZQ/4   



function cfg_mode_reg_t pack;
return {BA,RSV,RSV,RSV,R_TT,RSV,SRT,ASR,CWL,RSV,RSV,RSV};
endfunction 


function string conv_to_str();
conv_to_str = $sformatf("MODE_REG_2:BA:%b,R_TT:%b,SRT:%b,ASR:%b,CWL:%b",BA,R_TT,SRT,ASR,CWL);
endfunction


endclass 
