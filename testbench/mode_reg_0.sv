//

class mode_reg_0 extends uvm_object;
`uvm_object_utils(mode_reg_0);

string m_name="MODE_REG_0";

bit RSV='b0;
rand BL[1:0];
rand CL;
rand BT;
rand CAS[2:0];
rand DLL;
rand WR[2:0];
rand PD;
bit BA[2:0] = 3'b000;



function new(m_name);
super.new(m_name);
endfucntion 


constraint BL_c { BL == 2'b00; }
constraint CL_c { CL == 1'b1; }
constrint BT_c { BT == 1'b0; }
constraint CAS_c { CAS == CWL_MIN; }
constraint DLL_c { DLL == 1'b0; }
constraint WR_c { WR == WR_MIN; }
constraint PD_c { PD == 1'b0; }


function cfg_mode_reg_t pack;
return {BA,RSV,PD,WR,DLL,RSV,CAS,BT,CL,BL};
endfucntion 


function string conv_to_str();
conv_to_str = $sformatf("MODE_REG_0:BL:%b,CL:%b,BT:%b,CAS:%b,DLL:%b,WR:%b,PD:%b",BL,CL,BT,CAS,DLL,WR,PD);
endfunction


enclass 
