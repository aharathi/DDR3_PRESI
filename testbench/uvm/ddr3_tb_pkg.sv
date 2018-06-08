/// testbench components ///

package ddr3_tb_pkg;

`include "uvm_macros.svh";
`include "1024Mb_ddr3_parameters.vh";
import uvm_pkg::*;

parameter BURST_LEN = 8; 

typedef enum {DESELECT,NOP,ZQ_CAL_L,ZQ_CAL_S,ACTIVATE,READ,WRITE,PRECHARGE,REFRESH,SELF_REFRESH,DLL_DIS,MSR,RESET} command_t;

typedef bit [ROW_BITS-1:0]  row_t;
typedef bit [BA_BITS-1:0]   bank_t;
typedef bit [COL_BITS-1:0]  column_t;

typedef bit [DQ_BITS-1:0]   data_t;

typedef bit [ADDR_BITS-1:0] bus_addr_t;

typedef struct packed {bank_t ba;bus_addr_t bus_addr;} cfg_mode_reg_t;

typedef struct packed {row_t row;bank_t bank;column_t column;} proc_addr_t;

typedef int unsigned u_int_t;

function u_int_t ceil(input real number);
	if (number > $rtoi(number))
		ceil = unsigned'($rtoi(number)) + 1;
	else
		ceil = unsigned'($rtoi(number));

endfunction


include "ddr3_seq_item.sv";
include "mode_reg_0.sv";
include "mode_reg_1.sv";
include "ddr3_sequencer.sv";
include "ddr3_tb_driver.sv";
include "ddr3_env.sv";
include "../sequences/ddr3_rst_seq.sv";
include "../sequences/ddr3_reg_seq.sv";
include "../tests/ddr3_base_test.sv";
include "../tests/ddr3_reset_test.sv";

endpackage  
